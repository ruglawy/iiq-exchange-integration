param (
    [Parameter(Mandatory = $true)]
    [string]$RawMember
)

$log = "C:\Scripts\DC-Trigger.log"
Add-Content $log "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  RAW=$RawMember"

# Normalize to samAccountName
if ($RawMember -match '\\') {
    # DOMAIN\sam
    $sam = $RawMember.Split('\')[-1]
}
elseif ($RawMember -match '^CN=') {
    # Distinguished Name -> lookup
    try {
        $user = Get-ADUser -Identity $RawMember -ErrorAction Stop
        $sam = $user.SamAccountName
    } catch {
        Add-Content $log "$(Get-Date) ERROR: Could not resolve DN $RawMember"
        exit
    }
}
else {
    $sam = $RawMember
}

Add-Content $log "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  SAM=$sam"

$cred = Import-Clixml "C:\Scripts\svc_mailbox_automate.cred"

Invoke-Command -ComputerName SPEXCHANGE `
    -Authentication CredSSP `
    -Credential $cred `
    -ScriptBlock {
        param($u)
        powershell.exe -ExecutionPolicy Bypass `
            -File "C:\Scripts\Mailbox-Reconcile-SingleUser.ps1" `
            -User $u
    } `
    -ArgumentList $sam
