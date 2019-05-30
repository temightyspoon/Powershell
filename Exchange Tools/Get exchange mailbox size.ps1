#pop up box to ask for credential (use bgr account)
$cred = get-credential
#pulls in the commands from exchange server, and starts a remote session
$Session = New-PSSession -configurationname Microsoft.Exchange -connectionURI http://exchange2k10/Powershell -credential $cred


#pulls in user names from txt file
$txt = "C:\temp\users.txt"
$users = Get-Content $txt


#runs through each user and exports a break down of the mailbox size to a txt file, 
foreach($user in $users){
$mailbox = Get-MailboxFolderStatistics  -Identity briscoes\$user
$folders= ($mailbox | Select Name,FolderPath,FolderSize,FolderAndSubfolderSize )
$user | Out-File c:\temp\emailfoldersize.txt -Append
$folders | Out-File c:\temp\emailfoldersize.txt -Append

 }
