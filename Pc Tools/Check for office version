$infile = "D:\Libraries\Documents\Text docs\HO-PC's.txt"
$outfile = 'C:\temp\office.csv'


    $office = @()
    $computers = Get-Content $infile
    $i=0
    $count = $computers.count

    foreach($computer in $computers)
     {
     $i++
     Write-Progress -Activity "Querying Computers" -Status "Computer: $i of $count " `
      -PercentComplete ($i/$count*100)
        $info = @{}
        $version = 0
        try{
          $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $computer) 
          $reg.OpenSubKey('software\Microsoft\Office').GetSubKeyNames() |% {
            if ($_ -match '(\d+)\.') {
              if ([int]$matches[1] -gt $version) {
                $version = $matches[1]
              }
            }    
          }
          if ($version) {
            Write-Debug("$computer : found $version")
            switch($version) {
                "12" {$officename = 'Office 2003' }
                "13" {$officename = 'Office 2007' }
                "14" {$officename = 'Office 2010' }
                "15" {$officename = 'Office 2013' }
                "16" {$officename = 'Office 2016' }
                default {$officename = 'Unknown Version'}
            }
    
          }
          }
          catch{
              $officename = 'Not Installed/Not Available'
          }

     $UserL = Get-WMIObject -class Win32_ComputerSystem -computer $computer
     $user = $UserL.username
     $user
    $info.Computer = $computer
    $info.Name= $officename
    $info.version =  $version
    $info.User = $user

    $object = new-object -TypeName PSObject -Property $info
    $office += $object
    }
    $office | select computer,version,name,user | Export-Csv -NoTypeInformation -Path $outfile
    

  write-output ("Done")
