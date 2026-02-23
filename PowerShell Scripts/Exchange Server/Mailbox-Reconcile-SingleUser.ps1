param (
    [Parameter(Mandatory = $true)]
    [string]$User
)

# -------------------------------
# Load Exchange environment
# -------------------------------
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn -ErrorAction SilentlyContinue

Import-Module ActiveDirectory

$MailboxGroup = "MailBox Access"
$LogFile = "C:\Scripts\Mailbox-Instant.log"

function Log($msg) {
    Add-Content $LogFile "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $msg"
}

# Safety exclusions
$ExcludedAccounts = @("SPEXCHANGE", "Administrator", "krbtgt", "svc_iiq_mail", "IIQ Mail Bot")

if ($ExcludedAccounts -contains $User) {
    Log "SKIP $User : excluded account"
    exit
}

try {
    $adUser = Get-ADUser -Filter "SamAccountName -eq '$User'" -Properties GivenName,Surname,mailNickname -ErrorAction Stop
} catch {
    Log "ERROR $User : AD user not found"
    exit
}

# Check group membership (intent)
$inGroup = Get-ADPrincipalGroupMembership $User |
           Where-Object { $_.Name -eq $MailboxGroup }

# Check mailbox state (reality)
$recipient = Get-Recipient $User -ErrorAction SilentlyContinue

if ($recipient) {
    Log "RecipientTypeDetails = $($recipient.RecipientTypeDetails)"
} else {
    Log "Recipient NOT FOUND"
}


# -------------------------------
# ENABLE MAILBOX
# -------------------------------
if ($inGroup)
{

    if ($recipient -and $recipient.RecipientTypeDetails -eq "UserMailbox") {

        $cas = Get-CASMailbox $User

        if (-not ($cas.MAPIEnabled -and $cas.OWAEnabled -and $cas.ActiveSyncEnabled -and $cas.EwsEnabled -and $cas.PopEnabled -and $cas.ImapEnabled)) {

            Set-CASMailbox $User `
                -MAPIEnabled $true `
                -OWAEnabled $true `
                -ActiveSyncEnabled $true `
                -EwsEnabled $true `
                -PopEnabled $true `
                -ImapEnabled $true

            Log "MAIL ACCESS ENABLED for $User"
        }
        else { # If already enabled
            Log "MAIL ACCESS already enabled for $User"
        }

    } else { # If doesn't initially have a mailbox

        # Build alias first_last (first word only)
        $first = ($adUser.GivenName -split '\s+')[0]
        $last  = $adUser.Surname
        $alias = ($first + "_" + $last).ToLower() -replace '[^a-z0-9_]', ''

        if ([string]::IsNullOrEmpty($adUser.mailNickname)) {
            Set-ADUser $User -Replace @{ mailNickname = $alias }
            Log "SET mailNickname for $User to $alias"
        }

        if ($recipient -and $recipient.RecipientTypeDetails -eq "MailUser") {
            $tempExternal = "temp_$alias@example.local" # <--- Change this domain according to your Active Directory domain
            Set-MailUser $User -ExternalEmailAddress $tempExternal
            Log "SET TEMP ExternalEmailAddress for $User"
        }

        # Clean slate
        Disable-MailUser -Identity $User -Confirm:$false -ErrorAction SilentlyContinue
        Disable-Mailbox -Identity $User -Confirm:$false -ErrorAction SilentlyContinue

        Enable-Mailbox -Identity $User
        Log "MAILBOX ENABLED for $User"
        }
}

# -------------------------------
# DISABLE MAILBOX
# -------------------------------
elseif (-not $inGroup -and $recipient -and $recipient.RecipientTypeDetails -eq "UserMailbox") {

    $cas = Get-CASMailbox $User

    if ($cas.MAPIEnabled -or $cas.OWAEnabled -or $cas.ActiveSyncEnabled -or $cas.EwsEnabled -or $cas.PopEnabled -or $cas.ImapEnabled) {

        Set-CASMailbox $User `
            -MAPIEnabled $false `
            -OWAEnabled $false `
            -ActiveSyncEnabled $false `
            -EwsEnabled $false `
            -PopEnabled $false `
            -ImapEnabled $false

        Log "MAIL ACCESS DISABLED for $User"
    }
    else {
        Log "MAIL ACCESS already disabled for $User"
    }
}

else {
    Log "NO ACTION for $User"
}
