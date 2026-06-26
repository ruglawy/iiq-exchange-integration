# IdentityIQ Exchange Configuration Troubleshooting Points
- When testing WinRM connection using this command:
    
    ```powershell
    Test-WsMan <FQDN_OF_EXCHANGE_HERE> -UseSSL
    ```
    
    and it fails, showing this exact error:
    
    ```powershell
    Test-WsMan : <f:WSManFault xmlns:f="http://schemas.microsoft.com/wbem/wsman/1/wsmanfault" Code="12175"
    Machine="<FQDN_OF_EXCHANGE_HERE"><f:Message>The server certificate on the destination computer
    (<FQDN_OF_EXCHANGE_HERE>:5986) has the following errors:
    The SSL certificate could not be checked for revocation. The server used to check for revocation might be unreachable.
            </f:Message></f:WSManFault>
    At line:1 char:1
    + Test-WsMan <FQDN_OF_EXCHANGE_HERE> -UseSSL
    + ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        + CategoryInfo          : InvalidOperation: (rugl-exch.ruglawy.corp:String) [Test-WSMan], InvalidOperationExceptio
       n
        + FullyQualifiedErrorId : WsManError,Microsoft.WSMan.Management.TestWSManCommand
    ```
    
    It means one of the following:
    
    - The CA’s CRL / Delta CRL used to check this certificate’s revocation status had expired.
    - The machine trying to `Test-WsMan` can’t connect to the server used to check for revocation (i.e., CA)
    
    The fix is to make sure the CA’s machine is up and running. If it is, then you simply need to run these commands, in order, on the CA machine in an elevated (i.e., ran as administrator) PowerShell:
    
    ```powershell
    # Force the CA to generate and publish a new CRL / Delta CRL right now.
    certutil -crl
    
    # Tells the machine to refresh auto-enrollment / certificate-related policy activity immediately instead of waiting for normal background timing.
    certutil -pulse
    ```
    

---

- When trying to initiate a PSSession using this set of commands:
    
    ```powershell
    # 1. Catch credentials of the IQService and store it in $cred variable
    $cred = Get-Credential example\iqservice  # Adjust domain and account name accordingly
    
    # 2. Initiate a new PSSession
    New-PSSession `
      -ConfigurationName Microsoft.Exchange `
      -ConnectionUri https://<EXCHANGE_FQDN_HERE>/powershell `
      -Authentication Basic `
      -Credential $cred
    ```
    
    and it fails, you have to check the following:
    
    - The submitted credentials are fully accurate (i.e., domain, username, and password)
    - The Exchange server is using a trusted CA-signed certificate
    - The target machine you’re trying to connect to it online
    - WinRM is configured on the target machine
    - The PowerShell virtual directory URL is set on the Exchange server, and has both Windows Authentication and Basic Authentication enabled.
    - Exchange Management Tools is installed on the machine you’re trying to connect from
    - If the `$cred = Get-Credential` command is failing, you can try executing this command before it:
        
        ```powershell
        Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds" -Name "ConsolePrompting" -Value $True
        
        ```
        

---

- There are two important certificates in the whole process:
    1. Global Catalog Server Certificate (e.g., DC, or the one configured in the AD application)
        
        This certificate is responsible for the secure communication between IdentityIQ and the machine querying the domain. You have to make sure that you imported the correct certificate (either the server’s certificate or the certificate of the CA which signed the server’s certificate) into the truststore of the machine hosting IdentityIQ and that IdentityIQ is actually using that truststore (in the case of having multiple JDKs on the same machine)
        
    - Exchange Server Certificate
        
        This certificate is responsible for the secure communication between the machine hosting the IQService and the Exchange server. You have to make sure that you generated a certificate for the Exchange server signed by the CA (in that case, it was the DC). Attach that certificate to the Exchange server so that whenever IQService tries to remotely connect to it, it presents a trusted certificate and IQService trusts it and thus executes exchange commands successfully. If the certificate isn’t trusted, it will print out a log (in the IQService log file, found in the IQService folder from which IQService was installed) stating that it couldn’t establish an SSL communication channel with the target machine.
        

---

- On IdentityIQ, if test connection shows this error:
    
    ```powershell
    No subject alternative DNS name found for: example.local
    ```
    
    add a SAN DNS attribute equaling to `example.local` (i.e., your domain) to the Global Catalog server — the server configured in the Forest Configuration table — certificate (i.e., re-issue new certificate with the added SAN attribute).
    

---

- If IQService is failing to install, make sure that:
    - You’re running the command in a command prompt window ran as administrator
    - No other IQService instance is currently installed on the machine
    - The port you’re trying to install with is not currently in use
    - You’re running the command from the IQService directory (DO NOT REMOVE OR CHANGE THE LOCATION OF THE DIRECTORY AFTER INSTALLATION)

---

- On IdentityIQ, if test connection fails by IQService, make sure:
    - You added the user — configured in the IQService table on IIQ — to the IQService using the following command
        
        ```powershell
        IQService.exe -a example\iqservice # Adjust domain and user accordingly
        ```
        
    - The machine from which the IQService is running has a trusted certificate (i.e., signed by a trusted CA, or the certificate itself it stored in the truststore in the machine from which IdentityIQ is running)
    - The IQService service is running under the configured Log On account (i.e., the user configured to use the IQService service).
    - The IQService port (configured when installing IQService) is allowed in the firewall configuration for inbound traffic.

---

- When attaching IIS service to the newly-generated certificate signed by the trusted CA to the Exchange server using this command:
    
    ```powershell
    Enable-ExchangeCertificate -Thumbprint <THUMBPRINT> -Services IIS
    ```
    
    and it fails, make sure:
    
    - Copy-pasted the correct thumbprint
    - The certificate is present in the Exchange server’s Personal store
    - You’re running this command in an elevated Exchange Management Shell window (i.e., ran as administrator)

---

- When trying to create an HTTPS listener on WinRM using this command:
    
    ```powershell
    winrm create winrm/config/Listener?Address=*+Transport=HTTPS '@{Hostname="<FQDN_OF_EXCHANGE_SERVER_HERE>";CertificateThumbprint="<CERTIFICATE_THUMBPRINT_HERE>"}'
    ```
    
    and it fails, make sure:
    
    - You inserted the correct FQDN of the Exchange server
    - You inserted the correct CA-signed certificate’s thumbprint
    - No other HTTPS listener exists, check using this command:
        
        ```powershell
        winrm enumerate winrm/config/listener
        ```
        
    - WinRM is configured and running, check using this command:
        
        ```powershell
        winrm quickconfig
        ```
        

---

- When testing WinRM connection using this command:
    
    ```powershell
    Test-WsMan <FQDN_OF_EXCHANGE_HERE> -UseSSL
    ```
    
    and it fails, stating that it’s unreachable or timeouts, make sure:
    
    - An HTTPS listener actually exists on the Exchange server
    - WinRM is up and running on the Exchange server
    - WinRM was restarted after adding an HTTPS listener on the Exchange server
    - Firewall is not blocking port 5986 for inbound traffic on the Exchange server
    - WinRM HTTPS listener is bound to the trusted CA-signed Exchange server certificate
    - The FQDN of the Exchange server is written correctly in the command

---

- When trying to set the PowerShell virtual directory using this command:
    
    ```powershell
    Set-PowerShellVirtualDirectory -Identity "PowerShell (Default Web Site)" `
      -InternalUrl https://<EXCHANGE_FQDN_HERE>/PowerShell/ `
      -WindowsAuthentication $true `
      -BasicAuthentication $true
    ```
    
    and it fails, make sure:
    
    - The identity set in the `-Identity` argument actually exists using this command:
        
        ```powershell
        Get-PowerShellVirtualDirectory
        ```
        
        It should show the exact name that must be used in the `-Identity` argument in the `Set-PowerShellVirtualDirectory` command.
        
    - The URL set in the `-InternalUrl` argument is valid (make sure you replaced the placeholder)
    - You’re running the command inside an elevated (i.e., ran as administrator) Exchange Management Shell

---

- If IQService throws errors saying that mailbox couldn’t be created (found either in IQService logs in the IQService directory, or IdentityIQ itself), make sure the IQService account has the following security groups assigned:
    
    ```powershell
    Exchange Trusted Subsystem
    Recipient Management
    Domain Admins
    Account Operators
    ```
    

---

- If IQService doesn’t output any errors when creating a new AD account but still doesn’t provision any new mailbox, make sure you edited the Create Provisioning Policy in the Active Directory application by filling out the Exchange Alias field, you can use this sample script to auto-fill this field:
    
    ```powershell
    String mailalias = identity.getFirstname() + "_" + identity.getLastname();
    return mailalias;
    ```
    
    Also, make sure the Exchange Configuration table is filled with accurate information.
    

---
