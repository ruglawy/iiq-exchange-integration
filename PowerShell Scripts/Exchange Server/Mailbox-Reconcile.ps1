Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn -ErrorAction SilentlyContinue
Import-Module ActiveDirectory

# ==============================
# Configuration
# ==============================
$MailboxGroup = "MailBox Access"
$LogFile = "C:\Scripts\Mailbox-Reconcile.log"

$ExcludedAccounts = @(
    "SPEXCHANGE", # <--- Change this according to your Exchange Server Computer Name
    "Administrator",
    "krbtgt",
    "svc_iiq_mail",
    "IIQ Mail Bot"
)

# ==============================
# Logging helper
# ==============================
function Log($msg) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content $LogFile "$timestamp  $msg"
}

Log "=== Mail access reconciliation started ==="

try {

    # ==============================
    # INTENT: Users who SHOULD have mail access
    # ==============================
    $groupMembers = Get-ADGroupMember $MailboxGroup -Recursive |
        Where-Object {$_.objectClass -eq "user"} |
        ForEach-Object {$_.SamAccountName}

    # ==============================
    # REALITY: Users who have mailboxes
    # ==============================
    $mailboxUsers = Get-Mailbox -ResultSize Unlimited |
        ForEach-Object {$_.SamAccountName}

    # ==============================
    # ENABLE SECTION
    # ==============================
    foreach ($user in $groupMembers) {

        if ($ExcludedAccounts -contains $user) { continue }

        try {

            $recipient = Get-Recipient $user -ErrorAction SilentlyContinue

            # If mailbox does not exist, create it
            if (-not $recipient -or $recipient.RecipientTypeDetails -ne "UserMailbox") {

                $adUser = Get-ADUser -Filter "SamAccountName -eq '$user'" -Properties GivenName,Surname,mailNickname -ErrorAction Stop

                        # Build alias first_last (first word only)
                $first = ($adUser.GivenName -split '\s+')[0]
                $last  = $adUser.Surname
                $alias = ($first + "_" + $last).ToLower() -replace '[^a-z0-9_]', ''

                if ([string]::IsNullOrEmpty($adUser.mailNickname)) {
                    Set-ADUser $user -Replace @{ mailNickname = $alias }
                    Log "SET mailNickname for $user to $alias"
                }

                if ($recipient -and $recipient.RecipientTypeDetails -eq "MailUser") {
                    $tempExternal = "temp_$alias@example.local" # <--- Change this domain according to your Active Directory domain
                    Set-MailUser $user -ExternalEmailAddress $tempExternal
                    Log "SET TEMP ExternalEmailAddress for $user"
                }

                # Clean slate
                Disable-MailUser -Identity $user -Confirm:$false -ErrorAction SilentlyContinue
                Disable-Mailbox -Identity $user -Confirm:$false -ErrorAction SilentlyContinue

                Enable-Mailbox -Identity $user
                Log "ENABLED mailbox for $user"
            }

            # Ensure CAS protocols are enabled
            Set-CASMailbox $user `
                -MAPIEnabled $true `
                -OWAEnabled $true `
                -ActiveSyncEnabled $true `
                -EwsEnabled $true `
                -PopEnabled $true `
                -ImapEnabled $true

            # Log "ENSURED mail access enabled for $user"

        } catch {
            Log "ERROR enabling mail access for $user : $_"
        }
    }

    # ==============================
    # DISABLE SECTION (CAS ONLY)
    # ==============================
    $toDisable = $mailboxUsers | Where-Object {$_ -notin $groupMembers}

    foreach ($user in $toDisable) {

        if ($ExcludedAccounts -contains $user) { continue }

        try {

            Set-CASMailbox $user `
                -MAPIEnabled $false `
                -OWAEnabled $false `
                -ActiveSyncEnabled $false `
                -EwsEnabled $false `
                -PopEnabled $false `
                -ImapEnabled $false

            Log "DISABLED mail access (CAS) for $user"

        } catch {
            Log "ERROR disabling mail access for $user : $_"
        }
    }

} catch {
    Log "FATAL ERROR during reconciliation : $_"
}

Log "=== Mail access reconciliation finished ==="
