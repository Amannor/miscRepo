$PWD = (Get-Item -Path ".\").FullName
$fullSrcPath = Join-Path $PWD "filebeat-6.5.4-windows-x86_64.zip"
$dest =  Join-Path $PWD "tmpDir"

Write-Host("*****Extracting $fullSrcPath to $dest*****")
Expand-Archive $fullSrcPath $dest
Write-Host("*****Finished extracting*****")

$filebeatExecutableName = "filebeat.exe"
$filebeatContentDir = Get-ChildItem -Recurse -Filter $filebeatExecutableName | Select-Object -ExpandProperty DirectoryName -Unique
# Join-Path $PWD $filebeatContentDir "*"
$filebeatFinalLocation = "C:\tmp\tmp folder with spaces\existingDir\newDir"#"C:\Program Files\Filebeat"
Write-Host("*****Found $filebeatExecutableName in $filebeatContentDir - copying to $filebeatFinalLocation*****")
robocopy $filebeatContentDir $filebeatFinalLocation /MIR /W:5 /R:2 
Write-Host("*****Finished copying, deleting $fullSrcPath*****")
Write-Host($dest)
Remove-Item –path "$dest" –recurse 


# $installScriptFullPath = Join-Path $filebeatFinalLocation "install-service-filebeat.ps1"


