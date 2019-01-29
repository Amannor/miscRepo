#Usage example:
#.\filebeatDeployer.ps1 -appName ExplorationEngine.Web -subsystem TSS_QA -wd C:\LoggingArtifacts
param
(
    [string] $appName  = "ExplorationEngine.Web",
    [string] $subsystem  = "TSS_QA",
    [string] $wd = (Get-Item -Path ".\").FullName
)


$archiveFileFullPath = Join-Path $wd "filebeat-6.5.4-windows-x86_64.zip"
$configTemplateFullPath = Join-Path $wd "filebeat_template.yml"

$serviceName = 'filebeat'
$finalLocation = "C:\Program Files\Filebeat"
$exeName = "filebeat.exe"
$configName = "filebeat.yml"



If (!(Get-Service $serviceName -ErrorAction SilentlyContinue)) {
    Write-Host("*****Installing $serviceName*****") #Taken from: https://www.elastic.co/guide/en/beats/filebeat/6.5/filebeat-installation.html (see "win")

    $tmpDest = Join-Path $wd "tmpDir"

    Write-Host("*****Extracting $archiveFileFullPath to $tmpDest*****")
    Expand-Archive $archiveFileFullPath $tmpDest -Force
    Write-Host("*****Finished extracting*****")

    $filebeatContentDir = Get-ChildItem -Path $tmpDest -Recurse -Filter $exeName | Select-Object -ExpandProperty DirectoryName -Unique
    Write-Host("*****Found $exeName in $filebeatContentDir - copying to $finalLocation*****")
    robocopy $filebeatContentDir $finalLocation /MIR /W:5 /R:2 
    Write-Host("*****Finished copying, deleting $tmpDest*****")
    Remove-Item –path "$tmpDest" –recurse 

    $installScriptFullPath = Join-Path $finalLocation "install-service-filebeat.ps1"
    & $installScriptFullPath

    Write-Host("*****Finished installing filebeat*****")
}

If ((Get-Service $serviceName).Status -eq 'Running') {
    Stop-Service $serviceName
    Write-Host "Stopping $serviceName"
}

$certificationFile = Join-Path $wd "ca.crt"
Copy-Item $certificationFile $finalLocation #Copy-Item and not robocopy because $finalLocation doesn't contain a trailing backslash

 
$destFileName = Join-Path $finalLocation $configName

$appName = "APP_NAME: `"$appName`""
$subsystem = "SUB_SYSTEM: `"$subsystem`""

Write-Host "Updating $destFileName"

(Get-Content $configTemplateFullPath) `
    -replace 'APP_NAME: .*', $appName `
    -replace 'SUB_SYSTEM: .*', $subsystem |
    Out-File $destFileName

Write-Host "Starting service $serviceName"
Start-Service $serviceName
