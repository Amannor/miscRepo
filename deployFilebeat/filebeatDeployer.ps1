$serviceName = 'filebeat'
If (Get-Service $serviceName -ErrorAction SilentlyContinue) {
    Write-Host("Service $serviceName already exists on machine! Exiting...")
    Exit
}


$PWD = (Get-Item -Path ".\").FullName
$fullSrcPath = Join-Path $PWD "filebeat-6.5.4-windows-x86_64.zip"
$dest = Join-Path $PWD "tmpDir"

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




# & $installScriptFullPath = Join-Path $filebeatFinalLocation "install-service-filebeat.ps1"



# function DoesEerviceExist($serviceName) {
#     If (Get-Service $serviceName -ErrorAction SilentlyContinue) {

#         If ((Get-Service $serviceName).Status -eq 'Running') {

#             Stop-Service $serviceName
#             Write-Host "Stopping $serviceName"

#         }
#         Else {

#             Write-Host "$serviceName found, but it is not running."

#         }

#     }
#     Else {

#         Write-Host "$serviceName not found"

#     }
# }
