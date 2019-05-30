#sets up an array for later use
$array=@()

#sets log length: currently is set for 7 days
$maxage = (Get-Date).AddDays(-7)

#defines text file to be used and pulls the data in an object
$TxtFile = "C:\Powershell\txt-files\Computers\All Store PC.txt"
$Computers = Get-Content $TxtFile


foreach($computer in $computers){

#pulls the service info into a object
$service = Get-Service -ComputerName $computer -Name *NAME OF SERVICE*

#Check if the Service is running, if its stopped then it restarts the service and writes to a logfile
    if($service.Status -eq 'Stopped'){

    $service.Start()

    $date = get-date -Format u
          
    #creates and formats the object to be added into the array
      $export = [PScustomobject]@{
      Timestamp = $date
      Computer = $Computer
      ServiceStatus = "Service Restarted"
        }

        #adds the data from the above custom object to the array
        $array+= $export
    }

}
#appends the data from the array to the log csv
$array | Export-Csv -Path 'C:\Powershell\Logs\Pos service log.csv' -force -NoTypeInformation -Append

start-sleep -s 5

#removes data from the CSV that is older than 7 days
Copy-Item "C:\Powershell\Logs\Pos service log.csv" -Destination "C:\Powershell\Logs\Pos service log old.csv" -Force

  Import-Csv "C:\Powershell\Logs\Pos service log old.csv" | 
     Where{ [DateTime]$_.'Timestamp' -gt $maxage } |
        Export-Csv "C:\Powershell\Logs\Pos service log.csv" -NoType -Force
  Remove-Item "C:\Powershell\Logs\Pos service log old.csv"
