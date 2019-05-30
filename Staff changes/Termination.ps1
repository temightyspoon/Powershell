# ********************************************************************************
#
# Script Name: Termination.ps1
# Version: 2.1
# Author: Aaron Buchan
# Date: 16/5/2019
# Applies to: Users
#
# Description: This script performs the normal steps involved in terminating 
# access for a specific user, including: disabling in AD, exporting security 
# group membership, removing user from security groups, exporting distribution 
# group member ship, removing user from distribution groups, forwarding their
# future emails, option to disable mailbox, and disabling ActiveSync.
#
# Note: Skips the following protected users; "user1", "user2", "user3", "user4", "user5"
#
# ********************************************************************************

#Import Modules
#Import-Module ActiveDirectory
#Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Admin

# Set Variables 
$NetAdmin = "First Last"
$SecMgr = "First Last"
$PathLog = "\\enter\network\path"
$Random = -join ((65..90) + (97..122) | Get-Random -Count 5 | % {[char]$_})
$ProtectedUsers = "user1", "user2", "user3", "user4", "user5"
$DTStamp = get-date -Format u | foreach {$_ -replace "z"}

# Welcome Banner
Write-Host "##############################################"
Write-Host "#                                            #"
Write-Host "#   Welcome to the Terminate a User Script!  #"
Write-Host "#                                            #"
Write-Host "##############################################"
Write-Host " "

#Get username to terminate and verify username isn't protected
Function Get-Username {
	$Global:Username = Read-Host "Enter username to terminate"
	if ($Username -eq $null){
		Write-Host "Username cannot be blank. Please re-enter username"
		Get-Username
	}
	$UserCheck = Get-ADUser $Username
	if ($UserCheck -eq $null){
		Write-Host "Invalid username. Please verify this is the logon id / username for the account"
		Get-Username}
    $Protected = $ProtectedUsers -contains "$Username"
	if ($Protected -eq $True){
        Write-Host "$Username is a protected user and should not be deleted. See $NetAdmin or $SecMgr for details"
        Get-Username}
}
Get-Username

#Confirm username input accuracy
$No = "n", "N", "No", "NO"
$Yes = "y", ",Y", "Yes", "YES"
Write-Host " "
Write-Host "____________________________________________"
$Confirm = Read-Host "Are you sure you want to terminate: $Username (Y/N)"
if ($No -contains $Confirm){
        Get-Username
    }

#Set variables
$Protected = $ProtectedUsers -contains "$Username"
$UserDisabled = (Get-ADUser $Username).Enabled
$UserGroups = Get-ADPrincipalGroupMembership $Username | Select Name
$UserOU = Get-ADUser $Username | select @{l='Parent';e={([adsi]"LDAP://$($_.DistinguishedName)").Parent}}

#Disable Active Directory account
Disable-ADAccount -Identity $Username -Confirm:$false
Write-Host "User $Username disabled"

#Set random password for user
Set-ADAccountPassword -Identity $Username -NewPassword (ConvertTo-SecureString -AsPlainText "P!1$Random" -Force)

#Setups up Text file with users name
$usr = (Get-ADUser $Username).Name 
Add-Content $PathLog\$Username.txt "Termination log for $usr"
Add-Content $PathLog\$Username.txt "------------------------"

#Export list of security groups user is a Member Of
Add-Content $PathLog\$Username.txt "Group MemberShip"
Add-Content $PathLog\$Username.txt "=========================="
$SecGroups = Get-ADPrincipalGroupMembership $Username | Select Name 
$SecGroups -replace '.*=' -replace '}' | Add-Content $PathLog\$Username.txt
Write-Host "$Username Groups exported"
Add-Content $PathLog\$Username.txt "--------------------------"

#Remove user from all groups except 'Domain Users'
Get-ADPrincipalGroupMembership -Identity $Username | where {$_.Name -notlike "Domain Users"} |% {Remove-ADPrincipalGroupMembership -Identity $Username -MemberOf $_ -Confirm:$false}
Write-Host "$Username removed from groups"

#Export list of distrubution groups user is a Member Of 
$Recipient = Get-Recipient $Username
$DistGroups = Get-Recipient -Filter "members -eq '$($Recipient.DistinguishedName)'"
$DGs = $DistGroups.name
Add-Content $PathLog\$Username.txt "DISTRUBTION GROUP MEMBERSHIP"
Add-Content $PathLog\$Username.txt "==========================="
Add-Content $PathLog\$Username.txt $dgs
Write-Host "$Username Distrubution Groups exported"
Add-Content $PathLog\$Username.txt "--------------------------"

#Remove user from all distribution groups
$UserMail = (Get-ADUser $Username -Properties mail).mail
foreach( $distgroup in $DGs){
Remove-DistributionGroupMember $distgroup -Member $UserMail -Confirm:$false
}


#Get supervisor name to forward emails
Function Get-Supervisorname {
	$Global:Supervisorname = Read-Host "Enter supervisor / manager username to forward emails to"
	if ($Supervisorname -eq $null){
		Write-Host "Supervisor name cannot be blank. Please re-enter"
		Get-Username
	}
	$SuperCheck = Get-ADUser $Username
	if ($SuperCheck -eq $null){
		Write-Host "Invalid username. Please verify this is the logon id for the supervisor"
		Get-Username
	}
}
Get-Supervisorname

#Get supervisor SMTP address
$SupSMTP = (Get-ADUser $Supervisorname -Properties mail).mail

#Forward mail to supervisor
Set-Mailbox -Identity $Username -ForwardingAddress $SupSMTP
$SupName = (Get-Mailbox -identity $Username).forwardingaddress.name
Write-Host "Forwarding $Username's mail to: $SupName"

#Disable ActiveSync
set-casmailbox -identity $Username -ActiveSyncEnabled $false
$ActiveSync = (Get-casmailbox -identity $Username).activesyncenabled
Write-Host "ActiveSync Enabled: $ActiveSync"

#Move disabled user to Disabled OU in ADUC
Move-ADObject -Identity (Get-ADuser $Username).objectGUID -TargetPath 'OU=DISABLED User Accounts,DC=domain,Dc=com,DC=com'
$UserDisabled2 = (Get-ADUser $Username).Enabled
$UserGroups2 = Get-ADPrincipalGroupMembership $Username | Select Name
$DistGroups2 = Get-Recipient -Filter "members -eq '$($Recipient.DistinguishedName)'"
$DistGroup2 = $DistGroups2.name
$UserOU2 = Get-ADUser $Username | select @{l='Parent';e={([adsi]"LDAP://$($_.DistinguishedName)").Parent}}
$SupName2 = (Get-Mailbox -identity $Username).forwardingaddress -replace ".*Accounts"
$ActiveSync2 = (Get-casmailbox -identity $Username).activesyncenabled

#Create a PST Backup of $Username's Mailbox


#Append text file to confirming actions taken
Add-Content “$PathLog\$username.txt” " "
Add-Content “$PathLog\$username.txt” "BEGIN LOG"
Add-Content “$PathLog\$username.txt” "=========================="
Add-Content “$PathLog\$username.txt” "DateTime: $DTStamp"
Add-Content “$PathLog\$username.txt” "Account Enabled: $UserDisabled2"
Add-Content “$PathLog\$username.txt” "Security Group Membership: $UserGroups2"
Add-Content “$PathLog\$username.txt” "Distribution Group Membership: $DistGroup2"
Add-Content “$PathLog\$username.txt” "Forwarding $Username's email to: $SupName2"
Add-Content “$PathLog\$username.txt” "ActiveSync Enabled: $ActiveSync2"
Add-Content “$PathLog\$username.txt” "$Username moved to $UserOU2"
Add-Content “$PathLog\$username.txt” "______________________________________________________"
#& “$PathLog\$username.txt”

#Disable Mailbox and mark for deletion - needs a confirmation clause.
Write-Host "Do you want to disable the users mailbox?"
Write-Host "This will disable all fowarding rules"
$MailConfirm = Read-Host "Are you sure you want to Disable the Mailbox for: $Username (Y/N)"
if ($Yes -contains $MailConfirm){  
Disable-Mailbox -Identity $Username -Confirm:$false
Write-Host " Mailbox for $Username has be disabled"
Add-Content “$PathLog\$username.txt” "Mailbox for $Username has been disabled"
}else{}


Write-Host "##############################################"
Write-Host "#                                            #"
Write-Host "#               User Terminated!             #"
Write-Host "#                                            #"
Write-Host "##############################################"
Write-Host " "

Write-Host "Press any key to continue ..."
