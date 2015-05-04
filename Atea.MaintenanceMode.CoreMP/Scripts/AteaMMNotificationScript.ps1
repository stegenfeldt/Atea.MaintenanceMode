param(
    $alertId, 
    $scomManagementServerFQDN = "localhost"
)

Import-Module -Name "OperationsManager"
$scomConnection = New-SCOMManagementGroupConnection -ComputerName $scomManagementServerFQDN

## Get SCOM Alert from AlertId (received from notification subscription)
$mmRequest = Get-SCOMAlert -Id $alertId
Set-SCOMAlert -Alert $mmRequest -ResolutionState "249"

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
    # Invalid mmRequestCommand, exit script
    exit
}

## Check if $mmRequestTarget is a Management Server
## If so, exit the script
$scomManagementServers = Get-SCOMManagementServer
foreach ($scomManagementServer in $scomManagementServers){
    if ($scomManagementServer.PrincipalName -eq $mmRequestTarget) {
        "This is a management server, exit script"
        exit
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
    Set-SCOMAlert -Alert $mmRequest -ResolutionState "255"
} else {
    if ($mmRequestCommand -eq "Start"){
        Start-SCOMMaintenanceMode -Instance $scomComputerObject -EndTime $mmEndDate -Reason $mmRequestReason -Comment $mmRequestComment 
        Set-SCOMAlert -Alert $mmRequest -ResolutionState "255"
    } else {
        # Anything but "Start" is irrelevant if the server/object
        # is not already in maintenance mode
        Set-SCOMAlert -Alert $mmRequest -ResolutionState "255"
        exit
    }
}