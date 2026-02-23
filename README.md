# IIQ Exchange Onboarding Guide

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

## IIQ Integration

The approach we’ll be using to grant mailbox access to users is let DC and Exchange handle Mailbox provisioning to users by utilizing **PowerShell Scripts** and **Scheduled Tasks**

We’ll also create a new security group called `MailBox Access` on Active Directory. Any user with a membership in this group gets mailbox access (either newly created mailbox if they didn’t already have one, or get their access back to their mailbox if they already have one).

We have two tasks:

1. **Mailbox Reconciliation**: 
    
    This tasks runs every hour (can be modified) to ensure every member in the `MailBox Access` security group has mailbox access, and ensures that users outside of the security group has their mailbox access revoked. This task is hosted on the Exchange Server
    
    This task utilizes a PowerShell script that checks all Active Directory users that have mailbox access and their `MailBox Access` membership status:
    
    - If they’re in the security group but don’t have mailbox access, access is granted.
    - If they’re NOT in the security group but have mailbox access, their access gets revoked.
2. **Mailbox Access - Instant Trigger**: 
    
    This task gets triggered when a user joins/leaves the `MailBox Access` security group. It provides almost-instant mailbox access (or revocation) to the user who recently had their `MailBox Access` membership status changed (i.e., joined or left). However, sometimes it may fail for any reason, that’s why we have the **Mailbox Reconciliation** task to ensure everything is as expected. This task is hosted on the Domain Controller
    
    This task utilizes a PowerShell script that grants/revokes mailbox access based on their current membership status
    
    - If they just joined the security group, access is granted
    - If they just left the security group, access is revoked.

IIQ is the party responsible for provisioning/deprovisioning the `MailBox Access` security group (entitlement) to the users. Both DC and Exchange Server handle the rest of the mailbox access process.

**STEPS OF INTEGRATION:**

1. On the DC (logged in as `Administrator`)
    1. On Active Directory, create a new security group called `MailBox Access` (case sensitive)
    2. On Active Directory, create a new user with logon name of `svc_mailbox_automate` (Password never expires CHECKED, User must change password UNCHECKED), and add it to these security groups:
        
        ```
        Exchange Trusted Subsystem
        Recipient Management
        ```
        
    3. On Active Directory, Go to **Computers**, right-click on the Exchange computer (e.g., `SPEXCHANGE`), Go to *Delegation*, Choose “Trust this computer for delegation to specified services only” and choose “Use any authentication protocol”, Press on “Users or Computers…” and choose the DC machine, and add these services:
        
        ```powershell
        ldap      # Select the one with the machine name
        HOST      # Select the one with the machine name
        ```
        
    4. Run PowerShell as administrator and type in this commmand:
        
        ```powershell
        Enable-WSManCredSSP -Role Client -DelegateComputer <EXCHANGE_SERVER_MACHINE_NAME> -Force
        ```
        
    5. Create a new folder in the `C:\` folder called `Scripts\`
    6. Run PowerShell as administrator and type in this command:
        
        ```powershell
        Get-Credential <DOMAIN_NAME>\svc_mailbox_automate | Export-Clixml C:\Scripts\svc_mailbox_automate.cred
        ```
        
    7. Inside `Scripts\` , create a new file called `Trigger-Mailbox-Instant.ps1` and copy/paste the content found in the `PowerShell Scripts/Domain Controller/` directory
    8. Create a new XML file called `Mailbox Access - Instant Trigger.xml` and copy/paste the content found in the `Tasks XMLs/Domain Controller/` directory
    9. Open up *Task Scheduler*, right-click on *Task Scheduler Library*, and press *Import Task*
    10. Import the previously created XML file.
    11. For the “When running the task, use the following user account” option, choose `Administrator` (or any local account with administrative privileges on the DC)
    12. Press *OK*
2. On IdentityIQ, aggregate AD groups to add the newly-created security group to the entitlement catalog
3. On the Exchange Server (logged in as the Exchange User you created with `Domain Admins, Schema Admins, Enterprise Admins` capabilities)
    1. Run PowerShell as administrator and type in this command:
        
        ```powershell
        Enable-WSManCredSSP -Role Server -Force
        ```
        
    2. Open Exchange Management Shell and type in this command:
        
        ```powershell
        # Edit according to your domain (e.g., example.com), change password if needed as well.
        New-Mailbox -Name "IIQ Mail Bot" `
          -UserPrincipalName svc_iiq_mail@<DOMAIN> `
          -Password (ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force)
        ```
        
    3. In the Exchange Management Shell, type in this command:
        
        ```powershell
        Get-ExchangeCertificate | fl Thumbprint,Services,Subject
        ```
        
    4. Copy the thumbprint of the certificate with `Services : SMTP` and `Subject : CN=<EXCHANGE_SERVER_COMPUTER_NAME>`
    5. In the Exchange Management Shell, type in this command:
        
        ```powershell
        $cert = Get-ExchangeCertificate -Thumbprint <THUMBPRINT_HERE>
        # Then press enter, then type the next command
        Export-Certificate -Cert $cert -FilePath "<PATH_YOU_DESIRE>\exchange.cer"
        # Then press enter
        
        # YOU WILL NEED TO COPY THIS CERTIFICATE TO THE MACHINE THAT HOSTS IDENTITYIQ.
        ```
        
    6. Create a new folder in the `C:\` folder called `Scripts\`
    7. Inside `Scripts\` , create a new file called `Mailbox-Reconcile.ps1` and copy/paste the content found in the `PowerShell Scripts/Exchange Server/` directory
    8. Inside `Scripts\` , create a new file called `Mailbox-Reconcile-SingleUser.ps1` and copy/paste the content found in the `PowerShell Scripts/Exchange Server/` directory
    9. Create a new XML file called `Mailbox Reconciliation.xml` and copy/paste the content found in the `Tasks XMLs/Exchange Server/` directory
    10. Open up *Task Scheduler*, right-click on *Task Scheduler Library*, and press *Import Task*
    11. Import the previously created XML file.
    12. For the “When running the task, use the following user account” option, choose the user you’re logged in as.
4. On the machine where IdentityIQ is hosted
    1. Test out SMTP connection to Exchange server
        
        ```powershell
        telnet <EXCHANGE_SERVER_IP> 587
        ```
        
        It should work normally. If it doesn’t, troubleshoot and fix.
        
    2. Put the certificate you previously generated on the Exchange server on this machine.
    3. Open up terminal and execute this command:
        
        ```bash
        sudo keytool -importcert -alias exchange -file <PATH_TO_CERT>/exchange.cer -keystore <PATH_TO_JAVA_INSTALLATION>/lib/security/cacerts -storepass changeit
        ```
        
5. On IdentityIQ
    1. Go to Gear Icon → Global Settings → IdentityIQ Configuration
    2. For *Email Notification Type*, select **SMTP/Basic**
    3. For *Encryption*, select **TLS**
    4. For *Default SMTP Host*, type the Exchange server IP
    5. For *Default SMTP Port*, type `587`
    6. For *Default From Address*, type `svc_iiq_mail@<DOMAIN>` , replace `<DOMAIN>` with your domain (e.g., `svc_iiq_mail@example.com`)
    7. For the username and password, type in credentials for `svc_iiq_mail`
