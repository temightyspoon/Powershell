$TxtFile = "C:\powershell\txt-files\XXXXX.txt"
$pcs = Get-Content $TxtFile

#$pcs = "For one off use"

foreach($pc in $pcs){

# Closes outlook if its running to allow the .PST to be copied.	
(Get-WmiObject Win32_Process -ComputerName $pc | ?{ $_.ProcessName -match "outlook" }).Terminate()

$path = "\\" + $pc + "\C$\users"

#Finds the locations of the PSTs
$location = Get-ChildItem -Path $path -Recurse -Filter "*.pst"

$psts = $location.fullname

#makes a new directory to house the PST, named after the machine its copied from
mkdir E:\psts\$pc

foreach($pst in $psts){

#Copies PSt from the remote computer the specifed folder.
Copy-Item -Path $pst -Destination E:\psts\$pc

}

}
