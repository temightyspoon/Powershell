#Gets and exports the folder size of all top level subfolders.

$startfolder = "Path to directory"
$array = @()

$colItems = Get-ChildItem $startFolder | Where-Object {$_.PSIsContainer -eq $true} | Sort-Object
foreach ($i in $colItems)
{
    $subFolderItems = Get-ChildItem $i.FullName -recurse -force | Where-Object {$_.PSIsContainer -eq $false} | Measure-Object -property Length -sum | Select-Object Sum
    $i.FullName + " -- " + "{0:N2}" -f ($subFolderItems.sum / 1MB) + " MB" 
    $foldername = $i.Fullname
    $foldersize = ($subFolderItems.sum / 1MB)

    $export = [PScustomobject]@{
Folder  = $foldername
Size    = $foldersize
        }

$array += $export

}

$array | Export-Csv -Path 'C:\Temp\(XXXXX).csv' -force -NoTypeInformation
