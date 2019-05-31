#Define the Computers to be inventorised 
$txtfile = "C:\temp\PC list.txt"
$Computers = Get-Content $TxtFile
 
#runs through each machine defined in the txt file
#pulls in all of the information, and dumps it into a .txt file named after the machine
foreach($Computer in $Computers) 

{
    $computerSystem = get-wmiobject Win32_ComputerSystem -Computer $Computer
    $computerBIOS = get-wmiobject Win32_BIOS -Computer $Computer
    $computerOS = get-wmiobject Win32_OperatingSystem -Computer $Computer
    $computerCPU = get-wmiobject Win32_Processor -Computer $Computer
    $computerHDDs = Get-WmiObject Win32_LogicalDisk -ComputerName $Computer -Filter drivetype=3 
    $disks = Get-WmiObject Win32_LogicalDisk -ComputerName $Computer -Filter drivetype=3 
    $Networkconfig = Get-WmiObject Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ComputerName $Computer
    $PcFile = $computerSystem.Name + ".TXT"

#Creates an object to hold all of the inventory data of the currently queried machine.
      [Object[]] $Inventory = @("SERVER: " + $computerSystem.Name, ` 
                             ""   
                             ""
                             "HARDWARE INFORMATION"
                             "--------------------"
                             "Operating System: " + $computerOS.Caption,`
                             ""
                             "Service Pack: " + $computerOS.CSDVersion, `
                             ""
                             "Architecture: " + $computerOS.OSArchitecture, `
                             ""
                             "Current Status: " + $computerOS.Status, `
                             ""
                             "Manufacturer: " + $computerSystem.Manufacturer, ` 
                             ""                           
                             "Model: " + $computerSystem.Model, `
                             ""
                             "Serial Number: " + $computerBIOS.SerialNumber, ` 
                             ""
                             "CPU: " + $computerCPU.Name -join "-", ` 
                             ""
                             "RAM: " + "{0:N2}" -f ($computerSystem.TotalPhysicalMemory/1GB) + "GB", ` 
                             ""
                             "IP Address: " + $NetworkConfig.IpAddress -join "-", ` 
                             ""
                             "MAC Address: " + $NetworkConfig.MACAddress
                             "----------------------"
                             ""                            
                             "DISK INFORMATION"
                             ""
                             )
          #adds in the above inventory information to the $PCfile
                       add-content -path $Dir\$Pcfile $inventory       

      foreach ($disk in $disks) 
    { 
        [Object[]] $data = @("Drive: " + $disk.DeviceID, `
                            ""
                            "Drive Name: " + $disk.VolumeName, ` 
                            ""
                            "Disk Size: " + [Math]::Round(($disk.Size /1GB), 0) + "GB", ` 
                            ""
                            "Used Space: " + [Math]::Round(($disk.Size - $disk.FreeSpace) /1GB, 0) + "GB"
                            
                            "Free Space: " + [Math]::Round(($disk.FreeSpace / 1GB), 0) + "GB", ` 
                            ""
                            
                            "-----------------"
                             )
          #adds all of the above disk information to the end of the $Pcfile
                       add-content -path $Dir\$Pcfile $data
    }
}
