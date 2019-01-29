Sample usage:

 -  From a Powershell CLI:
$(SolutionDir)LoggingArtifacts\winlogbeatDeployer.ps1 -appName $(ProjectName) -subsystem $(ConfigurationName) -wd $(SolutionDir)LoggingArtifacts

 - From a regular cmd:
powershell -file $(SolutionDir)LoggingArtifacts\winlogbeatDeployer.ps1 -appName $(ProjectName) -subsystem $(ConfigurationName) -wd $(SolutionDir)LoggingArtifacts

Since this should be run as a Visual Studio post build event, here's a list of possible values for the different aforementioned args:
$(SolutionDir): C:\Optimove\Source\Repos\ExplorationEngine\
$(ProjectName): ExplorationEngine.Web
$(ConfigurationName): TSS_QA