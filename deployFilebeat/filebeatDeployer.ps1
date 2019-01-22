$filebeatServiceName = 'filebeat'
$filebeatFinalLocation = "C:\Program Files\Filebeat_tst"
$filebeatExecutableName = "filebeat.exe"
$filebeatConfigName = "filebeat.yml"



If (!(Get-Service $filebeatServiceName -ErrorAction SilentlyContinue)) {
    Write-Host("*****Installing filebeat*****")

    $PWD = (Get-Item -Path ".\").FullName
    $fullSrcPath = Join-Path $PWD "filebeat-6.5.4-windows-x86_64.zip"
    $tmpDest = Join-Path $PWD "tmpDir"

    Write-Host("*****Extracting $fullSrcPath to $tmpDest*****")
    Expand-Archive $fullSrcPath $tmpDest
    Write-Host("*****Finished extracting*****")

    $filebeatContentDir = Get-ChildItem -Recurse -Filter $filebeatExecutableName | Select-Object -ExpandProperty DirectoryName -Unique
    Write-Host("*****Found $filebeatExecutableName in $filebeatContentDir - copying to $filebeatFinalLocation*****")
    robocopy $filebeatContentDir $filebeatFinalLocation /MIR /W:5 /R:2 
    Write-Host("*****Finished copying, deleting $tmpDest*****")
    Remove-Item –path "$tmpDest" –recurse 

    # & $installScriptFullPath = Join-Path $filebeatFinalLocation "install-service-filebeat.ps1"

    Write-Host("*****Finished installing filebeat*****")
}

If ((Get-Service $filebeatServiceName).Status -eq 'Running') {
    Stop-Service $filebeatServiceName
    Write-Host "Stopping $filebeatServiceName"
}


$srcFileName = "filebeat_template.yml"
$destFileName = Join-Path $filebeatFinalLocation $filebeatConfigName

$privateKey = 'PRIVATE_KEY: "myPrivateKey"'
$companyId = 'COMPANY_ID: "myCompanyId"'
$appName = 'APP_NAME: "myAppName"'
$subsystem = 'SUB_SYSTEM: "mySubsystem1"'

Write-Host "Updating $destFileName"

(Get-Content $srcFileName) `
    -replace 'PRIVATE_KEY: .*', $privateKey `
    -replace 'COMPANY_ID: .*', $companyId `
    -replace 'APP_NAME: .*', $appName `
    -replace 'SUB_SYSTEM: .*', $subsystem |
    Out-File $destFileName

Write-Host "Starting service $filebeatServiceName"
Start-Service $filebeatServiceName
# TODO:
# 1) Restart the service (ideally by executing "filebeat.exe -e" - if that doesn't work out , by Start-Service or something like that)
# 2) Exit (as not to continue to other part)
