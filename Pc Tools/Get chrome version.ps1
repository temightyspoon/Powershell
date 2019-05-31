$txtfile = "C:\Powershell\txt-files\...."
$Computers = get-content $txtfile
$array =@()



foreach( $computer in $computers) {

$chrome = get-wmiobject win32_product -ComputerName $computer  | where-Object {$_.name -eq "google chrome"}

$chromename = $chrome.name
$chromever = $chrome.version


"$computer - $chromename - $chromever"

$data = $computer + " - " + $chromename + " - " + $chromever

$export= [pscustomobject]@{
Computer         = $computer
Chrome_Name      = $chromename
Chrome_Version   = $chromever

}

$array += $export
  } 

$array | Export-Csv -Path 'C:\TEMP\Chrome Version.csv' -force -NoTypeInformation
