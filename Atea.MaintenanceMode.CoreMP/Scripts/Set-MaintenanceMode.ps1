$rsPendingMM = "249"
$rsCloseAlert = "255"

## Create and instantiate SCOM object
If ((Get-Module).Name -eq "OperationsManager") {
	New-SCOMManagementGroupConnection -ComputerName localhost
} else {
	Import-Module -Name OperationsManager
	New-SCOMManagementGroupConnection -ComputerName localhost
}

$omApi = New-Object -ComObject 'MOM.ScriptAPI'

$mmAlertRule = Get-SCOMRule -Name "Atea.MaintenanceMode.WindowsMP.StartMMAlertRule"
$mmRequests = Get-SCOMAlert -ResolutionState 0,249 -Severity 0 -Priority 0 | Where {$_.RuleId -eq $mmAlertRule.Id}
$scomManagementServers = Get-SCOMManagementServer

foreach ($mmRequest in $mmRequests) {
	# Define the "checkpoint" variable. 
	# If this is not $true, maintenance mode will not be enabled
	$setMaintenanceMode = $true
	$mmLogMessage = ""

	# Set resolution state of alert to "Acknowledged" to signal that
	# it's being processed.
	Set-SCOMAlert -Alert $mmRequest -ResolutionState $rsPendingMM -Comment "Verifying request..."

	## Gather information from Alert
	$mmRequestTarget = $mmRequest.PrincipalName
	$mmRequestDescription = $mmRequest.Description
	[array]$mmRequestDetails = $mmRequestDescription.Split(";")
	$mmRequestCommand = $mmRequestDetails[0]
	$mmRequestDuration = $mmRequestDetails[1]
	$mmRequestReason = $mmRequestDetails[2]
	$mmRequestClass = $mmRequestDetails[3]
	$mmRequestInstance = $mmRequestDetails[4]
	$mmRequestComment = $mmRequestDetails[5]


	## Calculate end date in UTC
	$mmEndDate = 0
	if ($mmRequestCommand -eq "Start") {
		$mmEndDate = ((Get-Date).ToUniversalTime()).AddMinutes($mmRequestDuration)
	} elseif ($mmRequestCommand -eq "Stop") {
		$mmEndDate = (Get-Date).ToUniversalTime()
	} else {
		# Invalid mmRequestCommand, skip request
		$setMaintenanceMode = $false
		Set-SCOMAlert -Alert $mmRequest -ResolutionState $rsCloseAlert -Comment "Invalid request"
	}

	## Check if $mmRequestTarget is a Management Server
	## If so, exit the script
	foreach ($scomManagementServer in $scomManagementServers){
		if ($scomManagementServer.PrincipalName -eq $mmRequestTarget) {
			# This is a management server, skip request
			$setMaintenanceMode = $false
			Set-SCOMAlert -Alert $mmRequest -ResolutionState $rsCloseAlert -Comment "This is a management server, request will be ignored."
		}
	}

	if ($setMaintenanceMode) {
		## Get the computer object to set in maintenance mode
		$scomComputerClass = Get-SCOMClass -Name "Microsoft.Windows.Computer"
		$scomComputerObject = Get-SCOMClassInstance -Class $scomComputerClass | Where-Object {$_.DisplayName -eq $mmRequestTarget}

		if ($scomComputerObject.InMaintenanceMode -eq $true){
			# Computer is already in maintenance mode
			# adjust current maintenance mode to match the new request
			$currentMaintenanceMode = Get-SCOMMaintenanceMode -Instance $scomComputerObject
			Set-SCOMMaintenanceMode -MaintenanceModeEntry $currentMaintenanceMode -EndTime $mmEndDate -Reason $mmRequestReason -Comment $mmRequestComment
			Set-SCOMAlert -Alert $mmRequest -ResolutionState $rsCloseAlert -Comment "Extending maintenance mode to $mmEndDate for $mmRequestReason"
		} else {
			if ($mmRequestCommand -eq "Start"){
				Start-SCOMMaintenanceMode -Instance $scomComputerObject -EndTime $mmEndDate -Reason $mmRequestReason -Comment $mmRequestComment 
				Set-SCOMAlert -Alert $mmRequest -ResolutionState $rsCloseAlert -Comment "Starting maintenance mode until $mmEndDate for $mmRequestReason"
			} else {
				# Anything but "Start" is irrelevant if the server/object
				# is not already in maintenance mode
				Set-SCOMAlert -Alert $mmRequest -ResolutionState $rsCloseAlert -Comment "Maintenance Mode request is invalid and will have to be re-sent."
			}
		}
	} else {
		Set-SCOMAlert -Alert $mmRequest -ResolutionState $rsCloseAlert -Comment $mmLogMessage
	}
}
