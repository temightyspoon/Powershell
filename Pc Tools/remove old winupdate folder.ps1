$TxtFile = "C:\temp\winupdate.txt"
$Computers = Get-Content $TxtFile

#$computers = "FOR ONE OFF"

foreach($computer in $computers){

$service = Get-Service -ComputerName $computer -Name wuauserv
$service.Stop()

Start-Sleep -Seconds 5

$winfolder = "\\" + $computer + "\C$\windows\softwaredistribution"
$winfolderold = "\\" + $computer + "\C$\windows\xsoftwaredistributionxx"
$GPold = "\\" + $computer + "\C:\ProgramData\Microsoft\Group Policy\History\*"

if(Test-Path $winfolderold){ Remove-Item -force -Recurse $winfolderold}

remove-item -force -recurse $Gpold



Rename-Item -Path $winfolder -NewName "xsoftwaredistributionxx"

Start-Sleep -Seconds 5

$service.Start()

Start-Sleep -Seconds 5

}
