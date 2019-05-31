#Check if Remote PC is a Laptop

#Defines an Array to store data
$array = @()

#Define the Computers to be tested
#Pulls the list from a text file.
$TxtFile = "C:\TEMP\text-files\HO-PC's.txt"
$Computers = Get-Content $TxtFile
 
 #For each of the PC's in the text file, run through get several values.
foreach($Computer in $Computers) 

{
#Pull in the value for each of the below Objects
#sets value for $islaptop to false
    $computerSystem = get-wmiobject Win32_ComputerSystem -Computer $Computer
    $Computerchassis = Get-WmiObject Win32_SystemEnclosure -Computer $Computer
    $ComputerBattery = Get-WmiObject Win32_Battery -Computer $Computer
    $islaptop =$false

#runs through the values pulled in above and if there is a match sets $islaptop to $true
    if($Computerchassis | Where-Object { $_.chassistypes -eq 9 -or $_.chassistypes -eq 10 -or $_.chassistypes -eq 14})
    { $isLaptop = $true }

#if Pc has a battery sets $islaptop to $true
    if($ComputerBattery) {$islaptop = $true }

    $islaptop

#creates a PSobject to cast to the array
    $export = [PScustomobject]@{
    Computer = $Computer
    Laptop = $islaptop
        }
        
#adds the PSobject to the array. 
        $array+= $export


 }

#exports the array to a CSV
 $array | Export-Csv -Path 'C:\Temp\pc info\misc\laptop.csv' -force -NoTypeInformation
