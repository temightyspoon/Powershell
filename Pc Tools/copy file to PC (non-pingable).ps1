#For copying down shortcuts/files to computers that are setup to not respond to pings

$array=@()
$shortcut = "Location of shortcut to be copied
$txtfile = "C:\powershell\txt-files\xxxx.txt"
$computers = Get-Content $txtfile

#for one off use
#$computers = "For one offs"

#Runs through all of the computers listed in the txtfile
#Checks if the path c:\users is reachable, if it is then treats the computer as live
#if its live it copies down the file, checks it has arrived and logs both
#if it cant reach the above path writes to log the computer is offline & copy failed

foreach($computer in $Computers)
{
$date = Get-Date -Format u
$testpath= "\\$computer\c$\users"
if(Test-Path $testpath){
$Onlinestatus = "Online"
$mgrpath = "\\$computer\c$\Users\*mgr\desktop\"
$mgr = Get-ChildItem -Path $mgrpath
Copy-Item -Path $shortcut -Destination "$mgr\PlatinumLive11.rdp"
$newrdp = Get-ChildItem -Path "$mgr\PlatinumLive11.rdp"
if(Test-Path $newrdp){$CopyStatus = 'Complete' }else{$CopyStatus = "Failed"}
}else{
$Onlinestatus = "Offline"
$CopyStatus = "Failed"
}

$export = [pscustomobject]@{
Timestamp = $date
Computer = $computer
Online = $Onlinestatus
RDP_Copied = $CopyStatus
}

$array += $export
}

$this is exporting the log to a CSV
$array | Export-Csv -Path 'C:\Temp\platinum log.csv' -force -NoTypeInformation
