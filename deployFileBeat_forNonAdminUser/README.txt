Sample usage:

 -  From a Powershell CLI:
$(SolutionDir)LoggingArtifacts\filebeatDeployer.ps1 -appName $(ProjectName) -subsystem $(ConfigurationName) -wd $(SolutionDir)LoggingArtifacts

 - From a regular cmd:
powershell -file $(SolutionDir)LoggingArtifacts\filebeatDeployer.ps1 -appName $(ProjectName) -subsystem $(ConfigurationName) -wd $(SolutionDir)LoggingArtifacts

Since this should be run as a Visual Studio post build event, here's a list of possible values for the different aforementioned args:
$(SolutionDir): C:\script\
$(ProjectName): MyProject
$(ConfigurationName): Myubsystem

*Note: to improve running time, the part of unarchiving the filebeat zip file was skipped. Instead this code ships with the (unarchived) filebeat folder 
