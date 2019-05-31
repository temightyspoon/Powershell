$TxtFile = "C:\Powershell\txt-files\Computers\XXXX.txt"
$computers = Get-Content $TxtFile
#$computers = "for one off machines"
$array=@()


foreach($computer in $computers){

 $screen = Get-WmiObject win32_desktopmonitor -computername $computer


 $M = $screen.screenwidth | measure
 $count = $M.Count

$export = [PScustomobject]@{
      Computer = $Computer
      screens = $count
      }

      $array+= $export
 }


$array | Export-Csv -Path 'C:\temp\Monitors.csv' -force -NoTypeInformation -Append
