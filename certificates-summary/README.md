We have three main connections that require TLS configurations:

1. IdentityIQ ➜ Global Catalog Server
2. IdentityIQ ➜ IQService
3. IQService ➜ Exchange Server

All three connections require trusted certificates in order to fully establish successful TLS connections.
<br><br>

Regarding IQService, it can be installed on ONE of the following machines:

1. **DC Server**
    
    If IQService is installed on the DC Server, we need to trust three certificates in the whole process:
    
    - Global Catalog Server certificate
        
        This is the certificate that’s presented when IdentityIQ tries establishing a TLS connection with the Global Catalog Server
        
    - DC Server certificate
        
        This is the certificate that’s presented when IdentityIQ tries establishing a TLS connection with the IQService machine when trying to connect to IQService
        
        > NOTE: If the DC Server is also the Global Catalog Server, then they’re essentially the same certificate (i.e., one machine = one certificate)
        > 
    - Exchange Server certificate
        
        This is the certificate that’s presented when IQService tries establishing a TLS connection with the Exchange Server when IQService attempts to remotely execute Exchange commands on the Exchange Server.
        
    
    We also need to have Exchange Management Tools installed on the DC, so it can execute the Exchange commands.
   <br><br>
    
3. **Exchange Server**
    
    If IQService is installed on the Exchange Server, we need to trust two certificates in the whole process:
    
    - Global Catalog Server certificate
        
        This is the certificate that’s presented when IdentityIQ tries establishing a TLS connection with the Global Catalog Server
        
    - Exchange Server certificate
        
        This is the certificate that’s presented when IdentityIQ tries establishing a TLS connection with the IQService machine when trying to connect to IQService
        
    
    We also need to have RSAT installed on the Exchange Server, so it can execute AD commands. This does NOT require any manual remote connection configurations.
   <br><br>
    
5. **Domain-joined Machine**
    
    If IQService is installed on a domain-joined machine, we need to trust three certificates in the whole process:
    
    - Global Catalog Server certificate
        
        This is the certificate that’s presented when IdentityIQ tries establishing a TLS connection with the Global Catalog Server
        
    - Exchange Server certificate
        
        This is the certificate that’s presented when IQService tries establishing a TLS connection with the Exchange Server when IQService attempts to remotely execute Exchange commands on the Exchange Server.
        
    - Domain-joined Machine certificate
        
        This is the certificate that’s presented when IdentityIQ tries establishing a TLS connection with the IQService machine when trying to connect to IQService.
        
    
    On that machine, we need to install the following two:
    
    - RSAT: This is used to execute AD commands on the machine
    - Exchange Management Tools: This is used to execute Exchange commands from the machine
   <br><br><br>

In all cases, the account used to log on to the IQService service has to have the required permissions/privileges to:

- Execute AD commands (i.e., create/modify/disable/delete users, add to/remove from security groups, etc…)
- Execute Exchange commands (i.e., create mailboxes, enable/disable mailboxes, etc…)
<br><br>

To execute AD commands, you can either delegate controls to specific OUs and set the granular permissions accordingly, or assign the account to this security group at the very least:

```powershell
Account Operators

# This security group can perform AD commands on standard users. It can NOT perform operations on Domain Admins, Account Operators, Enterprise Admins, and Built-in Administrators members.
```

It may also need permissions to manage (Read\Write) terminal service attributes, adjust permissions accordingly.
<br><br>

To execute Exchange commands, it has to be assigned to these security groups:

```powershell
Recipient Management
Account Operators
Organization Management

# Organization Management has overall higher capabilities than IQService needs, alternatively, you can create a new custom Exchange Admin Role Group with "Active Directory Permissions Exchange Role" added, and assign it to the account.
```
