# SailPoint IdentityIQ Exchange Onboarding Guide

> This guide will go through the steps of onboarding Exchange onto IdentityIQ, starting from the very scratch of installing Windows Server.
> 

> This guide sets up Mailboxes for employees found in the Active Directory.
> 

> We’ll be installing **Windows Server 2022**, and **Exchange 2019 CU14**. This guide should work on other versions as well, make sure to check version compatibilities in the following link: [Exchange Server Supportability Matrix](https://learn.microsoft.com/en-us/exchange/plan-and-deploy/supportability-matrix)
> 

> Reference Link: [Exchange Server 2019 Prerequisites](https://learn.microsoft.com/en-us/exchange/plan-and-deploy/prerequisites)
> 

## Exchange Server Installation & Configuration

1. Install Windows Server 2022 on the machine
2. [FOR LAB ONLY] Disable all firewalls
    
    > If not in lab environment, adjust firewall configurations later on.
    > 
    
3. Set up a static IP address and DNS server address for the Windows Server.
    
    > The Windows Server must be in the same subnet of the Domain Controller
    > 
    
    > Set the DNS server address to the DC’s IP. DC must have DNS role installed. Only set up the *Preferred DNS* server, make sure to NOT set up the *Alternate DNS* server.
    > 
    
4. Change the name of the Exchange Server Computer
    1. Run PowerShell as Administrator and type in this command:
        
        ```powershell
        Rename-Computer -NewName <NEW_NAME_HERE> -Restart
        ```
        
    2. After reboot, check the new name by typing this command in command prompt or PowerShell:
        
        ```powershell
        hostname
        ```
        

1. On the DC, create a new user for the Exchange Server
    
    > You can also use any user account in the domain with required permissions to create a new user in the domain, using the DC is not mandatory
    > 
    1. Open up Active Directory Users and Computers
    2. Right Click on *Users* OU and Select New → User
    3. Fill up the required fields (i.e., First name, User logon name)
    4. Set password
    5. After the user is created, right click on the user and select “*Add to a group…”*
        
        > You can also double-click on the user, go to the *Member Of* tab, and click “*Add…”*
        > 
    6. Add these:
        
        ```powershell
        Domain Admins
        Enterprise Admins
        Schema Admins
        ```
        
    
2. Join the machine to your Active Directory domain
    1. Press `Win + R` , type, and press Enter:
        
        ```powershell
        sysdm.cpl
        ```
        
    2. On Computer Name tab, press *Change*.
    3. Select *Domain*
    4. Enter your domain name (e.g., `example.local`) and click *OK*
    5. Enter enterprise admin credentials (e.g., `EXAMPLE\Administrator` & `password`)
        
        > If it prompts you with “Welcome to example.local domain”, you’re good to go.
        > 
    6. Press *OK*, then press *Apply*.
    7. Reboot, and log in with the new user you created previously.

1. Install **.NET Framework 4.8.1**
    
    > Download Link: [.NET Framework 4.8.1](https://dotnet.microsoft.com/download/dotnet-framework/thank-you/net481-offline-installer)
    > 
    
    > For other Exchange Server versions, check the **Supportability Matrix** link found at the top of this guide to install the compatible **.NET Framework** version.
    > 
    
2. Install **Visual C++ 2012** and **Visual C++ 2013**
    
    > C++ 2012 Download Link: [Visual C++ 2012](https://www.microsoft.com/download/details.aspx?id=30679)
    > 
    
    > C++ 2013 Download Link: [Visual C++ 2013](https://support.microsoft.com/help/4032938/update-for-visual-c-2013-redistributable-package)
    > 
    
3. Install **Unified Communications Managed API**
    
    > Download Link: [UCMA 4.0](https://www.microsoft.com/download/details.aspx?id=34992)
    > 
    
4. Restart the server

1. Open PowerShell as Administrator, and type in this command:
    
    > If installing another Exchange Server version other than 2019, check the Microsoft Documentation for the exact relevant command.
    > 
    
    ```powershell
    Install-WindowsFeature Server-Media-Foundation, NET-Framework-45-Core, NET-Framework-45-ASPNET, NET-WCF-HTTP-Activation45, NET-WCF-Pipe-Activation45, NET-WCF-TCP-Activation45, NET-WCF-TCP-PortSharing45, RPC-over-HTTP-proxy, RSAT-Clustering, RSAT-Clustering-CmdInterface, RSAT-Clustering-Mgmt, RSAT-Clustering-PowerShell, WAS-Process-Model, Web-Asp-Net45, Web-Basic-Auth, Web-Client-Auth, Web-Digest-Auth, Web-Dir-Browsing, Web-Dyn-Compression, Web-Http-Errors, Web-Http-Logging, Web-Http-Redirect, Web-Http-Tracing, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Metabase, Web-Mgmt-Console, Web-Mgmt-Service, Web-Net-Ext45, Web-Request-Monitor, Web-Server, Web-Stat-Compression, Web-Static-Content, Web-Windows-Auth, Web-WMI, Windows-Identity-Foundation, RSAT-ADDS
    ```
    

1. Install **IIS URL Rewrite Module**
    
    > Download Link: [URL Rewrite](https://www.iis.net/downloads/microsoft/url-rewrite)
    > 

1. Download **Exchange Server 2019 CU14** ISO
    
    > Download Link: [Exchange Server 2019 CU14 Download](https://www.microsoft.com/en-us/download/details.aspx?id=105878)
    > 
    
2. Mount the downloaded ISO by right clicking on it and select *Mount*.
3. Open command prompt as administrator and head to the DVD Drive (usually D:/)
4. Type in the following commands in order:
    1. Prepare Schema
        
        ```powershell
        setup.exe /PrepareSchema /IAcceptExchangeServerLicenseTerms_DiagnosticDataON
        ```
        
    2. Prepare AD
        
        ```powershell
        setup.exe /PrepareAD /OrganizationName "<YOUR_ORG_NAME>" /IAcceptExchangeServerLicenseTerms_DiagnosticDataON
        ```
        
    3. Prepare All Domains
        
        ```powershell
        setup.exe /PrepareAllDomains /IAcceptExchangeServerLicenseTerms_DiagnosticDataON
        ```
        

1. Head to the DVD Drive, and double-click *setup.exe*.
    
    > It will prompt you if you want to check for updates or not. Choose any, preferably not if you intend to only install the version you downloaded and not another version.
    > 
    
2. In the **Select Role Selection**, choose **Mailbox Role**
    
    > For the **Automatically install Windows Server roles …**, you don’t need to select it as we already installed the required roles and features using PowerShell in step 11.
    > 

1. When checking for prerequisites, if an error pops up in the error logs, simply click the link it provided and download whatever’s missing from there, then press *retry* after installing.
2. During installation, the process may take a while, just wait until it’s done.
3. After installation is complete, restart the server
4. Open up browser, and head to this link:
    
    ```powershell
    https://localhost/ecp/
    
    # Use your admin credentials - the user you created specifically for exchange server
    ```
    
5. From the left-side panel, head to *servers*
6. On the top-side panel, click on *virtual directories*
    
    > This list contains all links to all websites related to Exchange. Most of them have Internal and External URLs which you can modify according to your needs. Highly recommended to set all of them as the same URL, except for the path itself.
    > 
    
    > *owa* stands for Outlook Web App, from which an employee can access their mailbox. Modify it according to your needs, but make sure to modify *ecp* as well, both have to be the URL except for the path itself (e.g., `/owa` and `/ecp` remain the same after the URL.
    > 
    
7. On the DC, open up DNS Manager
8. Head to *Forward Lookup Zones → <Your_Domain>*
9. Right click and select *New Host (A or AAAA)*
10. Assuming you changed the URL to `mail.example.com` , write `mail` in the **Name** field, so **Fully qualified domain name** resolves to `mail.example.com` 
11. For the **IP address**, type the Exchange Server IP address, then press *Add Host*.
12. Now, on the Exchange Server, try accessing the OWA using the URL you set. (e.g., `mail.example.com/owa`)

<br><br>

## IdentityIQ Exchange Configuration

This guide will focus on how to configure Exchange on IdentityIQ, enabling IQService to perform Exchange operations natively originating from IdentityIQ.

In this guide, we’ll be deploying IQService on the DC, having it perform Exchange operations remotely.

1. Use TLS for Forest Configuration in IdentityIQ
    1. Import the DC certificate (or more preferably, the CA certificate) into the Java Truststore from which IdentityIQ is running
        
        ```bash
        sudo keytool -importcert \
        -alias <NEW_ALIAS_HERE> \
        -file <PATH_TO_CERT>/root-ca.cer \
        -keystore <PATH_TO_JAVA_HOME>/lib/security/cacerts 
        ```
        
    2. Check the `Use TLS` box in the Forest Configuration table in the Active Directory application on IdentityIQ, then try testing the connection by clicking the `Test Connection` button at the end of the page
        
        > TIP: If it gives you an error regarding `No subject alternative DNS name found for: example.local` , add a SAN DNS attribute equaling to `example.local` (i.e., your domain) to the DC certificate (i.e., re-issue new certificate with the added SAN attribute).
        > 

1. Install IQService on the DC having TLS configured
    
    > If you already had IQService installed and was configured to be used with **NON-TLS** connection, uninstall it first by using `IQService.exe -u` command.
    > 
    
    1. Head to the IQService directory on the DC, open command prompt as Administrator, and type this command:
        
        ```bash
        IQService.exe -i -o 6060      # You can use any other available port
        ```
        
    2. Add the IQService user account that will be used to log on to the IQService service
        
        ```bash
        IQService.exe -a example\iqservice
        ```
        
    3. Open up Services, right click on the `SailPoint IQService-Instance1` service, click properties
    4. Go to Logon tab
    5. For “Log on as:”, choose “This account” and choose the IQService account and fill out the credentials
    6. Start up the service (or restart if it was already running)
    7. On IdentityIQ, go to the IQService Configuration table, fill out the fields appropriately
        - **IQService Host**: ****The FQDN of the machine hosting the IQService service (i.e., the DC in our case)
        - **IQService Port**: The port you configured in step a (i.e., `6060`)
        - **IQService User**: The user that logs on to the IQService service (i.e., `example\iqservice`)
        - **IQService Password**: The password of the IQService user
    8. Test the connection using the Test Connection button at the end of the page

1. Change the Exchange Server certificate to one signed by the CA in the domain
    
    > If the Exchange Server already has a CA-signed certificate, you can move on to step 4
    > 
    
    1. On the Exchange Server, open up Exchange Management Shell, and type this command
        
        ```bash
        Get-ExchangeCertificate | ft Thumbprint,Subject,Issuer,Services
        ```
        
    2. Look at the Services column (if you can’t see it, expand the shell window and re-run the command), you’ll notice that the IIS service is issued to a self-signed certificate (i.e., the Exchange Server itself), we need the IIS certificate to be signed by a trusted CA (which will be the DC)
    3. On the Exchange Server, open up IIS Manager
        
        > If it doesn’t open and gives errors, open up command prompt, type `mmc.exe` and press Enter, go to File, then Add/Remove Snap-in, then Internet Information Services (IIS) Manager, then press Add, then OK.
        > 
    4. On the left-hand section, click on your server name
    5. After that, in the middle section, double-click on “Server Certificates”
    6. After that, in the right-hand section, click “Create Certificate Request…”
    7. Fill the fields appropriately, with the Common Name filled with the FQDN of the Exchange Server (e.g., `exch-serv.example.local`), then click Next
        
        > The most important field if the Common Name, other fields are considered meta-data and don’t have to be accurate for labs.
        > 
        
    8. For the Bit length, choose at least 2048, then click Next
    9. Specify the name and path of the new CSR file, and edit the extension to be `.csr` instead of `.txt` , then click Finish
    10. Copy the `.csr` file to the DC.
    11. On the DC, make sure you have the following roles installed:
        1. Certificate Enrollment Web Service
        2. Certification Authority Web Enrollment
        
    12. Go to `http://localhost/certsrv` 
    13. Click “Request a certificate”, then click “advanced certificate request”
    14. Open up the `.csr` file in any text editor, copy the contents (EVERYTHING, INCLUDING THE DASHES), and paste them in the “Saved Request” field in the browser.
        
        > **IMPORTANT**: Make sure there are no trailing spaces or blank lines, if there are, remove them.
        > 
        
    15. For the Certificate Template, choose “Web Server”, then click the Submit button
    16. Download the certificate (download the chain just in case, not necessarily needed)
    17. Copy the new `.cer` certificate to the Exchange server
    18. On the Exchange Server, go to the IIS Manager (assuming you never closed the window), on the right-hand section, click on “Complete Certificate Request”
    19. Select the `.cer` file, fill out any friendly name (e.g., `Exchange-Signed-IIS`), and certificate store `Personal` , then click OK.
    20. Verify that the certificate was successfully imported using this command in Exchange Management Shell:
        
        ```bash
        Get-ExchangeCertificate | ft Thumbprint,Subject,Issuer,Services
        ```
        
        > You’ll notice that the newly-imported certificate — signed by the CA — has no services. We need to attach the IIS service to it.
        > 
        
    21. Take the new certificate’s thumbprint, and put it in this command, and run it in Exchange Management Shell:
        
        ```bash
        Enable-ExchangeCertificate -Thumbprint <NEW_THUMBPRINT_HERE> -Services IIS
        ```
        
    22. Restart IIS by running this command in the Exchange Management Shell:
        
        ```bash
        iisreset
        ```
        
        > If it fails, make sure you opened the Exchange Management Shell as Administrator (i.e., Run As Administrator)
        > 
        
    23. Verify that now the new certificate has the IIS service attached to it by running this command again in the Exchange Management Shell:
        
        ```bash
        Get-ExchangeCertificate | ft Thumbprint,Subject,Issuer,Services
        ```
        
        > You should now see IIS listed in the Services column of the new certificate
        > 
        
    24. On the Exchange Server, run PowerShell as Administrator, and run these commands in order
        
        ```bash
        # 1. Check if WinRM is running
        winrm quickconfig     # Should indicate that WinRM is running
        
        # 2. Check listeners
        winrm enumerate winrm/config/listener  # Expected port 5985, we want to use 5986
        
        # 3. Create HTTPS listener using the new certificate (NOTE: EDIT PLACEHOLDERS)
        winrm create winrm/config/Listener?Address=*+Transport=HTTPS '@{Hostname="<FQDN_OF_EXCHANGE_SERVER_HERE>";CertificateThumbprint="<CERTIFICATE_THUMBPRINT_HERE>"}'
        
        # OPTIONAL STEP: If running on production environment, and have a firewall up:
        New-NetFirewallRule -DisplayName "WinRM HTTPS 5986" -Direction Inbound -Protocol TCP -LocalPort 5986 -Action Allow
        
        # 4. Restart WinRM
        Restart-Service WinRM
        
        # 5. Check listeners again
        winrm enumerate winrm/config/listener  # Now listens for HTTPS on port 5986
        ```
        
    25. On the DC (or the machine hosting IQService), run this command to test WinRM connectivity:
        
        ```bash
        Test-WsMan rugl-exch.ruglawy.corp -UseSSL
        
        # Should execute with no errors, showing some information
        ```
        

1. On the DC (or the machine running the IQService service), mount the Exchange ISO used for the Exchange Server setup, open up command prompt as administrator, head to the CD drive, and run this command
    
    ```bash
    # Make sure you're in the CD drive in the command prompt
    Setup.exe /Role:ManagementTools /IAcceptExchangeServerLicenseTerms_DiagnosticDataON
    ```
    
    > It will check for prerequisites. If any found missing, just install them and execute the command again.
    > 

1. Restart the machine
2. On the Exchange Server, open up Exchange Management Shell as administrator and run these commands in order:
    
    ```bash
    # 1. Make sure you have the PowerShell virtual directory set to use HTTPS instead of HTTP,
    # Take the URL found in the ECP -> Servers -> Virtual directories and place it in the 
    # InternalURL paramater in this command
    Set-PowerShellVirtualDirectory -Identity "PowerShell (Default Web Site)" `
      -InternalUrl https://<EXCHANGE_FQDN_HERE>/PowerShell/ `
      -WindowsAuthentication $true `
      -BasicAuthentication $true
      
    # 2. Reset IIS
    iisreset
    ```
    

1. Test connecting to Exchange powershell remotely using the IQService account credentials from the machine (e.g., the machine hosting the IQService) by opening up PowerShell as administrator and running these in order
    
    ```bash
    # 1. Catch credentials of the IQService and store it in $cred variable
    $cred = Get-Credential example\iqservice  # Adjust domain and account name accordingly
    
    # 2. Initiate a new PSSession
    New-PSSession `
      -ConfigurationName Microsoft.Exchange `
      -ConnectionUri https://<EXCHANGE_FQDN_HERE>/powershell `
      -Authentication Basic `
      -Credential $cred
    ```
    
    > You should now see an entry printed on the window having `State` column as `Opened` and `Availibility` column as `Available`
    > 

1. On IdentityIQ, go to the Active Directory application, head to the Provisioning Policies, click on the Create provisioning policy.
2. In the Exchange section, open up the Exchange Alias field, and adjust a script to auto-fill it whenever the provisioning policy is used in a provisioning plan, sample script is as follows:
    
    ```bash
    String mailalias = identity.getFirstname() + "_" + identity.getLastname();
    return mailalias;
    ```
    

1. On DC, make sure the IQService account has the following security groups:
    
    ```bash
    Exchange Trusted Subsystem
    Recipient Management
    Domain Admins
    Account Operators   # <-- Not required, but sometimes operations fail without it
    ```
    
2. On IdentityIQ, go to Active Directory application, head to Configuration → Settings, and fill out the Exchange Configuration table accordingly, then click Add.
3. Test onboarding a new Joiner onto IIQ having an AD account created for them and see if they successfully get a mailbox.
