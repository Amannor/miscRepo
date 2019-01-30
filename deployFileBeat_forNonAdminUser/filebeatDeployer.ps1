#Usage example (doesn't have to run in Admin Mode):
#.\filebeatDeployer.ps1 -appName ExplorationEngine.Web -subsystem TSS_QA -wd C:\LoggingArtifacts
param
(
    [string] $appName = "ExplorationEngine.Web",
    [string] $subsystem = "TSS_QA",
    [string] $wd = (Get-Item -Path ".\").FullName
)

Function Grace-First-Kill-Process {
    param( $processNameToKill )
    $processToKill = Get-Process $processNameToKill -ErrorAction SilentlyContinue
    if ($processToKill) {
        Write-Host("Found process $processNameToKill - trying to close it gracefully")
        $processToKill.CloseMainWindow()
        
        # kill after sleep
        Sleep 3
        if (!$processToKill.HasExited) {
            Write-Host("Gracefully didn't work - stopping it by force")
            $processToKill | Stop-Process -Force
        }
        else {
            Write-Host("Closed it gracefully")
        }
    }
    Remove-Variable $processName -ErrorAction SilentlyContinue
}

$configTemplateFullPath = Join-Path $wd "filebeat_template.yml"

$finalLocation = "C:\Filebeat"
$exeName = "filebeat.exe"
$configName = "filebeat.yml"

$filebeatSrcDir = Join-Path $wd "filebeat-6.5.4-windows-x86_64"

$filebeatContentDir = Get-ChildItem -Path $filebeatSrcDir -Recurse -Filter $exeName | Select-Object -ExpandProperty DirectoryName -Unique
robocopy $filebeatContentDir $finalLocation /MIR /W:5 /R:2 

$certificationFile = Join-Path $wd "ca.crt"
Copy-Item $certificationFile $finalLocation #Copy-Item and not robocopy because $finalLocation doesn't contain a trailing backslash

 
$configFullPath = Join-Path $finalLocation $configName

$appName = "APP_NAME: `"$appName`""
$subsystem = "SUB_SYSTEM: `"$subsystem`""

Write-Host "Updating $configFullPath"

(Get-Content $configTemplateFullPath) `
    -replace 'APP_NAME: .*', $appName `
    -replace 'SUB_SYSTEM: .*', $subsystem |
    Out-File $configFullPath

$exeFullPath = Join-Path $finalLocation $exeName

Write-Host "Executing $exeFullPath"

#Running it directly and not by Start-Service since we don't know if we run in Admin Mode or not
$processName = "filebeat"
Grace-First-Kill-Process($processName )
Start-Process $exeFullPath "-c $configFullPath -e"

