#Usage example:
#PS > .\winlogbeatDeployer.ps1 -appName ExplorationEngine.Web  -subsystem TSS_QA -wd C:\LoggingArtifacts
param
(
    [string] $appName = "ExplorationEngine.Web",
    [string] $subsystem = "TSS_QA",
    [string] $wd = (Get-Item -Path ".\").FullName
)


$archiveFileFullPath = Join-Path $wd "winlogbeat-6.5.4-windows-x86_64.zip"
$configTemplateFullPath = Join-Path $wd "winlogbeat_template.yml"

$serviceName = 'winlogbeat'
$finalLocation = "C:\Program Files\Winlogbeat"
$exeName = "winlogbeat.exe"
$configFile = "winlogbeat.yml"



If (!(Get-Service $serviceName -ErrorAction SilentlyContinue)) {
    Write-Host("*****Installing $serviceName*****") #Steps were taken from here: https://www.elastic.co/guide/en/beats/winlogbeat/current/winlogbeat-installation.html

    $tmpDest = Join-Path $wd "tmpDir"

    Write-Host("*****Extracting $archiveFileFullPath to $tmpDest*****")
    Expand-Archive $archiveFileFullPath $tmpDest
    Write-Host("*****Finished extracting*****")

    $contentDir = Get-ChildItem -Recurse -Filter $exeName | Select-Object -ExpandProperty DirectoryName -Unique
    Write-Host("*****Found $exeName in $contentDir - copying to $finalLocation*****")
    robocopy $contentDir $finalLocation /MIR /W:5 /R:2 
    Write-Host("*****Finished copying, deleting $tmpDest*****")
    Remove-Item –path "$tmpDest" –recurse 

    $installScriptFullPath = Join-Path $finalLocation "install-service-winlogbeat.ps1"
    & $installScriptFullPath

    Write-Host("*****Finished installing $serviceName*****")
}

If ((Get-Service $serviceName).Status -eq 'Running') {
    Stop-Service $serviceName
    Write-Host "Stopping $serviceName"
}

$certificationFile = Join-Path $wd "ca.crt"
Copy-Item $certificationFile $finalLocation #Copy-Item and not robocopy because $finalLocation doesn't contain a trailing backslash
 
$destFileName = Join-Path $finalLocation $configFile

$appName = "APP_NAME: `"$appName`""
$subsystem = "SUB_SYSTEM: `"$subsystem`""

Write-Host "Updating $destFileName"

(Get-Content $configTemplateFullPath) `
    -replace 'APP_NAME: .*', $appName `
    -replace 'SUB_SYSTEM: .*', $subsystem |
    Out-File $destFileName

Write-Host "Starting service $serviceName"
Start-Service $serviceName