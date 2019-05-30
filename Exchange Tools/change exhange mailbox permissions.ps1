#Change Mailbox permissions on exchange.

#pulls in user user input to create a credential, used to connect to exchange server
$cred = get-credential

#Initiates a remote session connection to the exhange server
#Change connectionURI to exchange server name/IP
$Session = New-PSSession -configurationname Microsoft.Exchange -connectionURI http://exchange2k10/Powershell -credential $cred

#Imports the command set from the remote server
Import-PSSession $Session -DisableNameChecking

#Execute commands from here down
#----------------------------------

#Pulls in a text file of users, creates a useable PSobject
$txt = "C:\temp\users.txt"
$users = Get-Content $txt

#Adds full access to "oneadmin" to each of the users listed in the text file.
foreach( $user in $users){
Add-MailboxPermission -Identity $user -User oneadmin -AccessRights Fullaccess -InheritanceType all
}


####
#Adds full access permission to "oneadmin" to the mailbox of "martin"
#Add-MailboxPermission -Identity martin -User 'oneadmin' -AccessRight FullAccess -InheritanceType All -Automapping $false
