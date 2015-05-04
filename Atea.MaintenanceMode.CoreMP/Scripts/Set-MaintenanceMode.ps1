$rsPendingMM = "249"
$rsCloseAlert = "255"

### Utility Functions
Function SkipAndClose ($scomAlert) {
	Set-SCOMAlert -Id $scomAlert -ResolutionState $rsCloseAlert
	Continue
}

Function CloseRequest ($scomAlert) {
	Set-SCOMAlert -Id $scomAlert -ResolutionState $rsCloseAlert
}
### END Utility Functions

## Create and instantiate SCOM object
If ((Get-Module).Name -eq "OperationsManager") {
	New-SCOMManagementGroupConnection -ComputerName localhost
} else {
	Import-Module -Name OperationsManager
	New-SCOMManagementGroupConnection -ComputerName localhost
}

$omApi = New-Object -ComObject 'MOM.ScriptAPI'

$mmAlertRule = Get-SCOMRule -Name "Atea.MaintenanceMode.WindowsMP.StartMMAlertRule"
$mmRequests = Get-SCOMAlert -ResolutionState 0 -Severity 0 -Priority 0 | Where {$_.RuleId -eq $mmAlertRule.Id}

foreach ($mmRequest in $mmRequests) {
	Set-SCOMAlert -Alert $mmRequest -ResolutionState $rsPendingMM

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
		SkipAndClose $mmRequest
	}

	## Check if $mmRequestTarget is a Management Server
	## If so, exit the script
	$scomManagementServers = Get-SCOMManagementServer
	foreach ($scomManagementServer in $scomManagementServers){
		if ($scomManagementServer.PrincipalName -eq $mmRequestTarget) {
			# This is a management server, skip request
			SkipAndClose $mmRequest
		}
	}

	## Get the computer object to set in maintenance mode
	$scomComputerClass = Get-SCOMClass -Name "Microsoft.Windows.Computer"
	$scomComputerObject = Get-SCOMClassInstance -Class $scomComputerClass | Where-Object {$_.DisplayName -eq $mmRequestTarget}

	if ($scomComputerObject.InMaintenanceMode -eq $true){
		# Computer is already in maintenance mode
		# adjust current maintenance mode to match the new request
		$currentMaintenanceMode = Get-SCOMMaintenanceMode -Instance $scomComputerObject
		Set-SCOMMaintenanceMode -MaintenanceModeEntry $currentMaintenanceMode -EndTime $mmEndDate -Reason $mmRequestReason -Comment $mmRequestComment
		CloseRequest $mmRequest
	} else {
		if ($mmRequestCommand -eq "Start"){
			Start-SCOMMaintenanceMode -Instance $scomComputerObject -EndTime $mmEndDate -Reason $mmRequestReason -Comment $mmRequestComment 
			CloseRequest $mmRequest
		} else {
			# Anything but "Start" is irrelevant if the server/object
			# is not already in maintenance mode
			SkipAndClose $mmRequest
		}
	}
}
