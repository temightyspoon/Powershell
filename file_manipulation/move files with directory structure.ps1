# Will Move files to new location while maintaining directory structure

$currentdate = Get-Date
$deletedate = $currentdate.AddDays(-500)
$user = "Enter User here"

$sourcedir = "\\Enter Source Directory\$user"
$targetdir = "\\Enter Target Directory\$user"

Get-ChildItem $sourceDir -Recurse |  Where-Object{$_.LastWriteTime -lt $deletedate}| % {
   $dest = $targetDir + $_.FullName.SubString($sourceDir.Length)

   If (!($dest.Contains('.')) -and !(Test-Path $dest))
   {
        mkdir $dest
   }

   move-Item $_.FullName -Destination $dest -Force -WhatIf
}
