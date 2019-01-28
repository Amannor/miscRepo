#Usage example:
#.\filebeatDeployer.ps1 -appName ExplorationEngine.Web  -subsystem TSS_QA
param
(
    [string] $appName  = "ExplorationEngine.Web",
    [string] $subsystem  = "TSS_QA"
)

$PWD = (Get-Item -Path ".\").FullName

$archiveFileFullPath = Join-Path $PWD "filebeat-6.5.4-windows-x86_64.zip"
$configTemplateFullPath = Join-Path $PWD "filebeat_template.yml"

$filebeatServiceName = 'filebeat'
$filebeatFinalLocation = "C:\Program Files\Filebeat"
$filebeatExecutableName = "filebeat.exe"
$filebeatConfigName = "filebeat.yml"



If (!(Get-Service $filebeatServiceName -ErrorAction SilentlyContinue)) {
    Write-Host("*****Installing filebeat*****")

    $tmpDest = Join-Path $PWD "tmpDir"

    Write-Host("*****Extracting $archiveFileFullPath to $tmpDest*****")
    Expand-Archive $archiveFileFullPath $tmpDest
    Write-Host("*****Finished extracting*****")

    $filebeatContentDir = Get-ChildItem -Recurse -Filter $filebeatExecutableName | Select-Object -ExpandProperty DirectoryName -Unique
    Write-Host("*****Found $filebeatExecutableName in $filebeatContentDir - copying to $filebeatFinalLocation*****")
    robocopy $filebeatContentDir $filebeatFinalLocation /MIR /W:5 /R:2 
    Write-Host("*****Finished copying, deleting $tmpDest*****")
    Remove-Item –path "$tmpDest" –recurse 

    $installScriptFullPath = Join-Path $filebeatFinalLocation "install-service-filebeat.ps1"
    & $installScriptFullPath

    Write-Host("*****Finished installing filebeat*****")
}

If ((Get-Service $filebeatServiceName).Status -eq 'Running') {
    Stop-Service $filebeatServiceName
    Write-Host "Stopping $filebeatServiceName"
}

 
$destFileName = Join-Path $filebeatFinalLocation $filebeatConfigName

# $privateKey = "PRIVATE_KEY: \`"$privateKey \`""
# $companyId = "COMPANY_ID: \`"$companyId \`"" 
# $appName = 'APP_NAME: "'+${appName}+'"'
$appName = "APP_NAME: \`"$appName \`""
# $subsystem = 'SUB_SYSTEM: "mySubsystem1"'
$subsystem = "SUB_SYSTEM: \`"$subsystem\`""

Write-Host "Updating $destFileName"

(Get-Content $configTemplateFullPath) `
    # -replace 'PRIVATE_KEY: .*', $privateKey `
    # -replace 'COMPANY_ID: .*', $companyId `
    -replace 'APP_NAME: .*', $appName `
    -replace 'SUB_SYSTEM: .*', $subsystem |
    Out-File $destFileName

Write-Host "Starting service $filebeatServiceName"
Start-Service $filebeatServiceName