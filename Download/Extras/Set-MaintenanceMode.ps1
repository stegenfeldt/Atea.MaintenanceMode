[CmdletBinding()]
param(
	[Parameter(Mandatory = $true)]
	[string]
	$ManagementServer,
	[string]
	$ComputerName = "",
	[string]
	$ServiceName = "",
	[string]
	$GroupName = "",
	[int]
	$Minutes = 5,
	[ValidateSet(
		"PlannedApplicationMaintenance",
		"PlannedHardwareMaintenance",
		"PlannedHardwareInstallation",
		"PlannedOperatingSystemReconfiguration",
		"PlannedOther",
		"ApplicationInstallation",
		"ApplicationUnresponsive",
		"ApplicationUnstable",
		"SecurityIssue",
		"UnplannedOperatingSystemReconfiguration",
		"UnplannedHardwareInstallation",
		"UnplannedHardwareMaintenance",
		"UnplannedOther",
		"LossOfNetworkConnectivity"
		)]
	[string]
	$Reason = "PlannedOther",
	[string]
	$Comment = "",
	[Switch]
	$Force,
	[Switch]
	$Stop,
	[Switch]
	$UseCredentials
)
##SANITY CHECK on script parameters
if (($ComputerName -eq "") -and ($GroupName -eq "")) {
	Write-Host "The parameters -ComputerName and -GroupName cannot both be empty" -ForegroundColor Red
	Exit
}
if (($ComputerName -ne "") -and ($GroupName -ne "")){
	Write-Host "The parameters -ComputerName and -GroupName cannot both be set at the same time" -ForegroundColor Red
	Exit	
}
if (($ServiceName -ne "") -and ($ComputerName -eq "")){
	Write-Host "When setting -ServiceName, -ComputerName must also be defined. Groups are not supported." -ForegroundColor Red
	Exit
}
if ($Minutes -lt 5){
	Write-Host "5 minutes is the smallest possible time for Maintenance Mode" -ForegroundColor Red
	Exit
}
Write-Verbose -Message ("Starting script with parameters -ComputerName `"{0}`" -ServiceName `"{1}`" -GroupName `"{2}`" -Verbose {3} -Minutes {4}" -f $ComputerName,$ServiceName,$GroupName,$Verbose,$Minutes)
##/SANITY CHECK


## Create and instantiate SCOM object
If ((Get-Module).Name -eq "OperationsManager") {
	
} else {
	$importResult = Import-Module -Name OperationsManager -PassThru
	Write-Verbose -Message $importResult
}

if ($UseCredentials) {
	$userCredentials = Get-Credential
	$scomMGConnectionResult = New-SCOMManagementGroupConnection -ComputerName $ManagementServer -Credential $userCredentials -PassThru
} else {
	$scomMGConnectionResult = New-SCOMManagementGroupConnection -ComputerName $ManagementServer -PassThru
}
if (!$?) {Exit}

$scomMGConnection = Get-SCOMManagementGroupConnection
Write-Verbose ("Connected to Management Group {0} on {1} as {2}" -f $scomMGConnection.ManagementGroupName,$scomMGConnection.ManagementServerName,$scomMGConnection.UserName)

$omApi = New-Object -ComObject 'MOM.ScriptAPI'

# Get a list of management servers so we can avoid setting them into maintenance mode
$scomManagementServers = Get-SCOMManagementServer

# Define the "checkpoint" variable. 
# If this is not $true, maintenance mode will not be enabled
$setMaintenanceMode = $true
$mmLogMessage = ""

## Set default MM target type to 0
# 0	= Skip
# 1	= Computer
# 2	= Service
# 3	= Group
$mmTargetType = 0

## Calculate end date in UTC
if($Stop -eq $false){
	$mmEndDate = ((Get-Date).ToUniversalTime()).AddMinutes($Minutes+1)
} else {
	$mmEndDate = ((Get-Date).ToUniversalTime()).AddMinutes(1)
}
Write-Verbose -Message "Setting Maintenance Mode end-time (UTC) to: $mmEndDate"

## If -ComputerName is set, get the computer object from SCOM
if ($ComputerName -ne "") {
	$scomComputerClass = Get-SCOMClass -Name "Microsoft.Windows.Computer"
	$scomComputerObject = Get-SCOMClassInstance -Class $scomComputerClass | Where-Object {$_.DisplayName -eq $ComputerName}
	if($ComputerName -ne $scomComputerObject.DisplayName){
		Write-Host "Could not find a computer named $ComputerName" -ForegroundColor Red
		Exit
	} else {
		# Setting the $ComputerName to the exact result from the management group.
		$ComputerName = $scomComputerObject.DisplayName
		Write-Verbose -Message "Found computer(s): $scomComputerObject"
		$mmTargetType = 1
	}
}

## Get windows service object, -ComputerName is implied.
# In fact, if -ServiceName was set and the script has gotten this far,
# -ComputerName has passed the checks too.
if ($ServiceName -ne "") {
	switch ($ServiceName) {
		"omsdk" {
			Write-Host "omsdk, the SCOM Data Access Service, is critical for SCOM and should not be in maintenance mode" -ForegroundColor Red
			Exit
		}
		"cshost" {
			Write-Host "omsdk, the SCOM Configuration Service, is critical for SCOM and should not be in maintenance mode" -ForegroundColor Red
			Exit
		}
		"healthservice" {
			Write-Host "healthservice, the SCOM workflow service, is critical for SCOM and should not be in maintenance mode" -ForegroundColor Red
			Exit
		}
	}
	$scomNTServiceClass = Get-SCOMClass -Name "Microsoft.Windows.LocalService"
	$scomNTService = Get-SCOMClassInstance -Class $scomNTServiceClass | Where{($_.Path -eq $ComputerName) -and ($_.Name -eq $ServiceName)}
	if ($scomNTService.Count -lt 1) {
		# No services found, exit script
		Write-Host "Could not find a service named $ServiceName on $ComputerName" -ForegroundColor Red
		Exit
	} else {
		Write-Verbose -Message "Found windows service(s): $scomNTService"
		$mmTargetType = 2
	}
}

## Get SCOM group
# If -ServiceName or -ComputerName has been specified,
# -GroupName will be "" or initial sanity checks will have exited script.
if ($GroupName -ne "") {
	$scomGroup = Get-SCOMGroup | Where {$_.DisplayName -eq $GroupName}
	if ($scomGroup.Count -lt 1) {
		Write-Host "Could not find a group named $GroupName" -ForegroundColor Red
		Exit
	} else {
		$GroupName = $scomGroup.DisplayName
		Write-Verbose -Message "Found SCOM Group: $GroupName"
		$mmTargetType = 3
	}
}

## MM Target Type 1, a Computer
# Make sure target is not an OMMS
if ($mmTargetType -eq 1) {
	foreach ($scomManagementServer in $scomManagementServers){
		if ($scomManagementServer.PrincipalName -eq $ComputerName) {
			# This is a management server, skip request
			Write-Host "$ComputerName is a Management Server.`nSetting a management server in maintenance mode is bad." -ForegroundColor Red
			Exit
		} else {
			Write-Verbose -Message "$ComputerName is not a Management Server and is a valid target for Maintenance Mode"
		}
	}
}

## Set the scom object(s) in maintenance mode
switch ($mmTargetType) {
	1 {$mmTargets = $scomComputerObject}
	2 {$mmTargets = $scomNTService}
	3 {$mmTargets = $scomGroup}
}

$currentMaintenanceMode = "No Maintenance Mode set..."
foreach ($mmTarget in $mmTargets) {
	Write-Verbose -Message "Checking for maintenance mode on $mmTarget"
	if ($mmTarget.InMaintenanceMode -eq $true){
		# Target is already in maintenance mode
		if($Stop) {
			# -Stop has been set, stop maintenance mode and finish the script.
			$currentMaintenanceMode = $mmTarget.StopMaintenanceMode([DateTime]::Now.ToUniversalTime(),[Microsoft.EnterpriseManagement.Common.TraversalDepth]::Recursive)
		} else {
			# -Stop command has not been issued
			# Adjust current maintenance mode, if necessary, to match the new request
			$currentMaintenanceMode = Get-SCOMMaintenanceMode -Instance $mmTarget
			if ($Force) {
				# -Force has been set, override current maintenance mode
				$currentMaintenanceMode = Set-SCOMMaintenanceMode -MaintenanceModeEntry $currentMaintenanceMode -EndTime $mmEndDate -Reason $Reason -Comment $Comment -PassThru
			} else {
				if ((New-TimeSpan -Start $currentMaintenanceMode.ScheduledEndTime -End $mmEndDate).TotalMinutes -lt 0) {
					# Current maintenance mode end time is later than the new one
					Write-Verbose -Message "Target is already in Maintenance Mode that ends later than the current request.`nIf you want to enforce a change, re-run command with -Force"
					$currentMaintenanceMode = "Already in maintenance mode"
				} else {
					# Current maintenance mode ends before requested one. Set new ScheduledEndTime to match the request.
					Write-Verbose -Message "Setting $mmTarget in Maintenance Mode until $mmEndDate"
					$currentMaintenanceMode = Set-SCOMMaintenanceMode -MaintenanceModeEntry $currentMaintenanceMode -EndTime $mmEndDate -Reason $Reason -Comment $Comment -PassThru
				}
			}
		}
	} else {
		Write-Verbose -Message "Setting $mmTarget in Maintenance Mode until $mmEndDate"
		$currentMaintenanceMode = Start-SCOMMaintenanceMode -Instance $mmTarget -EndTime $mmEndDate -Reason $Reason -Comment $Comment -PassThru
	}
}
Write-Verbose -Message "Maintenance Mode set: $currentMaintenanceMode"
