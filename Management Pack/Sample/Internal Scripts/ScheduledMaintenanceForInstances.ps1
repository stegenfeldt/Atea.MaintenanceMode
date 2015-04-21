#************************************************************************************************************
# ScheduledMaintenanceForInstances.ps1
#
# This script sets the maintenance mode for the windows computer (TargetFQDN), defined classes and instances. It also sets the
# maintenance mode for hosted clustered resources. The given event description defines the duration, reason, comment and
# if classes or instances are defined.
#
# Usage:
# powershell "&'.\ScheduledMaintenanceForInstances.ps1'-debug True -debugFileName '<full path to debug log>' 
# -logSuccessEvent <True|False> -TargetFQDN '<string>' -eventdescription '<string>' -FallBackMS '<string>'"
#
# Example:
# powershell "&'C:\test\ScheduledMaintenanceForInstances.ps1'-Debug True -debugFileName 'c:\it\mom\schedmm.log'
# -LogSuccessEvent True -TargetFQDN 'servername.abc.def' -eventdescription 'Start;10;Application: Maintenance;;;Domain\Username;12/12/2011 6:14:04 AM' 
# -FallBackMS 'servernamerms.abc.def'"
#
# 2012 NH
# changes in version 1.1:
# added stop maintenance mode for class "AOS Agent Maintenance Mode Class"
# 2012 TPE
# change in version 1.2:
# stop command completed
#************************************************************************************************************

param($StartStopCommand, $debug, $debugfilename, $logSuccessEvent, $TargetFQDN, $eventdescription, $FallBackMS);

# constants
$SCRIPT_NAME = "ScheduledMaintenanceForInstances.ps1";
$SCRIPT_VERSION = "1.2";
$VOID_STRING = "VOID"

# event constants
$EVENT_TYPE_SUCCESS = 0
$EVENT_TYPE_ERROR = 1
$EVENT_TYPE_WARNING = 2
$EVENT_TYPE_INFORMATION = 4

$EVENT_ID_SUCCESS = 1000           # use IDs in the range 1 - 1000
$EVENT_ID_SCRIPTERROR = 999        # then you can use eventcreate.exe for testing
$EVENT_ID_PROCESSING_ERROR = 998

#$debug = $True
#$debugfilename = 'c:\temp\ScheduledMaintenanceForInstances.log'
#$logSuccessEvent = $True
#$TargetFQDN = 'servername.abc.def'
#$FallBackMS = 'servernamerms.abc.def'
#$eventdescription = 'Stop;10;ApplicationInstallation;Microsoft.Windows.Client.Win7.DiskPartition;Disk #0;domain\username;12/12/2012 05:40:00 PM'

# function for logging to stdout and log file simultaneously
function Log($msg, $debug, $debugLog)
{
    write-host $msg;
    # write to debug log if required
    if ($debug -eq $true) 
    {
        $debugLog.writeline($msg)
    }
}

# function to stop the maintenance mode on an object 
function StopMaintenance 
{
	param ($msg, $debug, $debugLog, $mmEndDate, $comment, $object)
	
	$msg = "Function StopMaintenance for object: " + $object;
    Log -msg $msg -debug $debug -debugLog $debugLog;
	$object.StopMaintenanceMode([System.DateTime]::Now.ToUniversalTime(),[Microsoft.EnterpriseManagement.Common.TraversalDepth]::Recursive);
}


# function to extend the maintenance mode on an object that already is in maintenance mode.
function ExtendMaintenance 
{
	param ($msg, $debug, $debugLog, $mmEndDate, $comment, $object)
	$msg = "The instance is already in maintenance.`r`nCheck whether the current maintenance end time will occur after the scheduled end time...";
    Log -msg $msg -debug $debug -debugLog $debugLog;
    
	# calculate the date difference between the scheduled end date and the current end date to check if the current maintenance window has to be extended. 
    # this will positive if the current end date is in the future 
    $currentEndTime = $object.GetMaintenanceWindow().ScheduledEndTime;
    $dateDiffScheduledEnd = New-TimeSpan $mmEndDate $currentEndTime; 
    if ($dateDiffScheduledEnd.TotalMinutes -lt 0)
    {
        $comment = $object.GetMaintenanceWindow().Comments + "`r`nExtended: " + $comment;
      
		$msg = "The scheduled UTC end time " + $mmEndDate + " will occur after the current UTC end time " + $currentEndTime + ".`r`nExtend the current maintenance window...`r`nUsing comment: " + $comment;
        Log -msg $msg -debug $debug -debugLog $debugLog;
        
		$mmEndDate = $mmEndDate.ToUniversalTime();
		
		# the Set-MaintenanceWindow cmdlet did not work during the tests on R2. Use the SDK method instead.
        $object.UpdateMaintenanceMode($mmEndDate, $object.GetMaintenanceWindow().Reason, $comment);
    }
    else
    {
        $msg = "The current UTC end time " + $currentEndTime + " will occur after or is the same as the scheduled UTC end time " + $mmEndDate + ". No action is required.";
        Log -msg $msg -debug $debug -debugLog $debugLog;
    }
}

# Function to set All Computer related Objects into Maintenance Mode because the new Start-NewMaintenanceMode CMDlet only set the computer object itself into MM
# this behaviour has changed related to 2007 R2
#
function SetMMAll($comp)
{
	if ($comp.InMaintenanceMode -eq $true)
	{
		if ($StartStopCommand -eq "Start")
		{
			$msg = "Object already in maintenance. Extend Maintenance!";
			Log -msg $msg -debug $debug -debugLog $debugLog;
			ExtendMaintenance -msg $msg -debug $debug -debugLog $debugLog -mmEndDate $mmEndDate -comment $comment -object $comp;
		}
		else
		{
			# stop Maintenance Mode
			StopMaintenance -msg $msg -debug $debug -debugLog $debugLog -mmEndDate $mmEndDate -comment $comment -object $comp;
		}
	}
    else	
	{
		if ($StartStopCommand -eq "Start")
		{
			$mmEndDate = $mmEndDate.ToUniversalTime();
			# Put the Windows Computer and all its contained objects into maintenance mode
			$msg = "Putting " + $comp.Name + " into maintenance mode";
			Log -msg $msg -debug $debug -debugLog $debugLog;
			Start-SCOMMaintenanceMode -instance $comp -endTime:$mmEndDate -comment:$comment -Reason:$Reason;  
		}
		else
		{
			# Stop Maintenance Mode requested -> Computer currently not in Maintenance Mode -> nothing to to (only log)
			$msg = "The computer is currently not in maintenance. No Maintenance Mode stop required for " + $comp.Name;
			Log -msg $msg -debug $debug -debugLog $debugLog;
		}

	}

    $HealthServiceWatcherClass = Get-SCOMClass -DisplayName "Health Service Watcher"
    $HealthServiceWatcher = Get-SCOMClassInstance -Class:$HealthServiceWatcherClass | where{$_.Displayname -match $comp.DisplayName} 
    If ($HealthServiceWatcher -is [Object])
    {
		if ($HealthServiceWatcher.InMaintenanceMode -eq $true)
		{
			if ($StartStopCommand -eq "Start")
			{
				$msg = "Object already in maintenance. Extend Maintenance for HealthServiceWatcher " + $HealthServiceWatcher.DisplayName;
				Log -msg $msg -debug $debug -debugLog $debugLog;
				ExtendMaintenance -msg $msg -debug $debug -debugLog $debugLog -mmEndDate $mmEndDate -comment $comment -object $HealthServiceWatcher;
			}
			else
			{
				# stop Maintenance Mode
				StopMaintenance -msg $msg -debug $debug -debugLog $debugLog -mmEndDate $mmEndDate -comment $comment -object $HealthServiceWatcher;
			}
		}
		else	
		{
			if ($StartStopCommand -eq "Start")
			{
				# Put the Windows Computer and all its contained objects into maintenance mode
				$msg = "Putting HealthServiceWatcher for " + $HealthServiceWatcher.DisplayName + " into maintenance mode";
				Log -msg $msg -debug $debug -debugLog $debugLog;
				Start-SCOMMaintenanceMode -instance $HealthServiceWatcher -endTime:$mmEndDate -comment:$comment -Reason:$Reason;  
			}
			else
			{
				# Stop Maintenance Mode requested -> Computer currently not in Maintenance Mode -> nothing to to (only log)
				$msg = "The HealthServiceWatcher is currently not in maintenance. No Maintenance Mode stop required for HealthServiceWatcher of " + $HealthServiceWatcher.DisplayName;
				Log -msg $msg -debug $debug -debugLog $debugLog;
			}
		}
    }
    else
    {
        $msg = "No Healthservice Watcher Object to set into maintenance mode"
        Log -msg $msg -debug $debug -debugLog $debugLog;
    }
    
    $instancetemp = get-SCOMClassInstance | Where-Object {$_.Path -match $comp}
	Foreach ($object in $instancetemp)
	{
        if ($object.InMaintenanceMode -eq $true)
        {
			if ($StartStopCommand -eq "Start")
			{
				$msg = "Object already in maintenance. Extend Maintenance for " + $object.FullName;
				Log -msg $msg -debug $debug -debugLog $debugLog;
				ExtendMaintenance -msg $msg -debug $debug -debugLog $debugLog -mmEndDate $mmEndDate -comment $comment -object $object;
			}
			else
			{
				# stop Maintenance Mode
				StopMaintenance -msg $msg -debug $debug -debugLog $debugLog -mmEndDate $mmEndDate -comment $comment -object $object;
			}
			
		}
        else
        {
			if ($StartStopCommand -eq "Start")
			{
                $msg = "The instance is currently not in maintenance. Create a new maintenance window for " + $object.FullName;
                Log -msg $msg -debug $debug -debugLog $debugLog;
				$mmEndDate = $mmEndDate.ToUniversalTime();
                Start-SCOMMaintenanceMode -instance $object -endtime $mmEndDate -reason $Reason -comment $comment
                # $object.ScheduleMaintenanceMode($StartDate, $mmEndDate, $Reason, $comment);
			}
			else
			{
				# Stop Maintenance Mode requested -> Instance currently not in Maintenance Mode -> nothing to to (only log)
				$msg = "The Instance is currently not in maintenance. No Maintenance Mode stop required for " + $object.FullName;
				Log -msg $msg -debug $debug -debugLog $debugLog;
			}
        }
    }

	if ($StartStopCommand -eq "Start")
	{
		# $MaintModeClass = Get-SCOMClass -DisplayName "AOS Agent Maintenance Mode Class"
		$MaintModeClass = Get-SCOMClass -Name "AOS.Agent.MaintenanceMode.AgentMaintModeClass"
		$MaintModeInstance = Get-SCOMClassInstance -Class:$MaintModeClass | where{$_.Path -match $comp.Name} 
		$MaintModeInstance.StopMaintenanceMode([System.DateTime]::Now.ToUniversalTime(),[Microsoft.EnterpriseManagement.Common.TraversalDepth]::Recursive);
		$msg = "Remove the following Instance from Maintenance Mode:" + $MaintModeClass.Name + "." + $MaintModeInstance.Path
		Log -msg $msg -debug $debug -debugLog $debugLog;

	}
}


# create debug file if required
if ($debug -eq $true) 
{
  $debugLog = New-Object System.IO.StreamWriter($debugFileName);
}
$currentuser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name;
$MSFQDN = [System.Net.Dns]::GetHostEntry([System.Net.Dns]::GetHostName()).HostName;
$msg = "Script started -- " + (get-date).ToString() + "`r`nUsing security context: " + $currentuser;
Log -msg $msg -debug $debug -debugLog $debugLog;

$msg = "`r`nDebug = " + $debug + "`r`nDebug file name: " + $debugFileName + "`r`nLog success event: " + $logSuccessEvent;
$msg += "`r`nManagement Server: " + $MSFQDN + "`r`nComputer Principalname: " + $TargetFQDN + "`r`neventdescription: " + $eventdescription;
Log -msg $msg -debug $debug -debugLog $debugLog;

# create MOM Script API COM object 
$api = New-Object -comObject "MOM.ScriptAPI"; 

# Check if OperationsManager module is loaded
If (Get-Module -Name "OperationsManager")
{
    $msg = "`r`nOperations Manager module already loaded";
    Log -msg $msg -debug $debug -debugLog $debugLog;

}
else
     {
 try {
 # Try to load the module
 Import-Module -Name "OperationsManager"
 } catch {
 # Did not work, exit the script
	$msg = "`r`nCould not load Operations Manager module! Exit script";
	Log -msg $msg -debug $debug -debugLog $debugLog;
	if ($debug -eq $true) 
	{
		$debugLog.close();
	}
	exit
 }
}

# Module is loaded, connect to Management Group/Server
New-SCOMManagementGroupConnection -ComputerName $MSFQDN;
$MGC = Get-SCOMManagementGroup;

if (-not $MGC)
{
	 $msg = "`r`nCould not Connect to Management Group using MS " + $MSFQDN + "! Trying now FallBack MS";
	 Log -msg $msg -debug $debug -debugLog $debugLog;

	 New-SCOMManagementGroupConnection -ComputerName $FallBackMS;
	 $MGC = Get-SCOMManagementGroup;

	 if (-not $MGC)
	 {
		$msg = "`r`nCould not Connect to Management Group using the FallBackMS " + $FallBackMS + "! Exit script";
		Log -msg $msg -debug $debug -debugLog $debugLog;
		if ($debug -eq $true) 
			{$debugLog.close()}
		exit
	 }
	 else
	 {
		$msg = "`r`nConnected to Management Group " + $MGC.Name + " using MS " + $FallBackMS;
		Log -msg $msg -debug $debug -debugLog $debugLog;
	 }
}
else
{
	$msg = "`r`nConnected to Management Group " + $MGC.Name + " using MS " + $MSFQDN;
	Log -msg $msg -debug $debug -debugLog $debugLog;
}


$logentries = $eventdescription.Split(";")

$StartStopCommand = $logentries[0].Split(":")[1].trim()
if ($StartStopCommand -ne "Stop") {$StartStopCommand = "Start"}

$DurationInMin = $logentries[1]
$Reason = $logentries[2]
$class = $logentries[3]
$instance = $logentries[4]
$comment = $logentries[5]

$msg = "`r`nCommand = " + $StartStopCommand + "`r`nDuration = " + $DurationInMin + "`r`nReason = " + $Reason + "`r`nClass = " + $class + "`r`nInstance = " + $instance + "`r`nComment = " + $comment;
Log -msg $msg -debug $debug -debugLog $debugLog;

if ($StartStopCommand -eq "Start")
	{
	# Get the start time and calculate the end time
	# $startTime = [System.DateTime]::Now.ToUniversalTime()
	$startDate = $(Get-Date).ToUniversalTime();
	$mmEndDate = $startDate.AddMinutes($DurationInMin)
	}
else
	{
	$mmEndDate = $(Get-Date).ToUniversalTime();
	}
	
$msg = "Maintenance End time: " + $mmEndDate;
Log -msg $msg -debug $debug -debugLog $debugLog;

# ---------------------------- MAINTENANCE -------------------------------------
# process the scheduled maintenance

# get all Management Servers - a management server may not enter maintenance mode!
$managementServerNames = $null
$managementServer = Get-SCOMManagementServer
# check whether more than one server is returned
# if not convert output to an array
if ($managementServer -is [Array]) {$managementServers = $managementServer} else {$managementServers = ,$managementServer}
# loop through the returned servers
    $i = 0;
    while ($i -lt $managementServers.count) 
    {
        if ($managementServerNames -eq $null) 
        {
            $managementServerNames = $managementServers[$i].PrincipalName,$managementServers[$i].ComputerName
        }
        else
        {
            $managementServerNames += $managementServers[$i].PrincipalName
            $managementServerNames += $managementServers[$i].ComputerName
        }
        $i++;
    }
    $msg = "Retrieved Ops Mgr Management Server: " + [System.String]::Join(", ", $managementServerNames)
    Log -msg $msg -debug $debug -debugLog $debugLog;
    
	# check whether the hosting Windows computer acts as an OpsMgr management server
    # if it is skip the entry
    if ($managementServerNames -contains $TargetFQDN)
    {
        $msg = "The computer " + $TargetFQDN + " is an Ops Mgr Management Server! Skipping..."
        Log -msg $msg -debug $debug -debugLog $debugLog;
    }
    else
    {
    	$msg = "The computer " + $TargetFQDN + " is not an Ops Mgr Management Server! Continue..."
        Log -msg $msg -debug $debug -debugLog $debugLog;
		
		$msg = "Check whether the instance is already in maintenance...";
    	Log -msg $msg -debug $debug -debugLog $debugLog;

		# if no class is defined, the whole computer will be set into maintenance mode.
		if ($class -ne "")
    	{
            $instancetempClass = Get-SCOMClass  -name $class;

            if ($instance -eq "") 
            {
                $msg = "Looking for an instance of '" +  $class + "' using the criteria Path match " + $TargetFQDN;
                Log -msg $msg -debug $debug -debugLog $debugLog;
                $instancetemp = get-SCOMClassInstance -Class $instancetempClass | Where-Object {$_.Path -match $TargetFQDN} 
                $msg = "Found instance " +  $instancetemp;
                Log -msg $msg -debug $debug -debugLog $debugLog;
            }
            else
            {
                $msg = "Looking for an instance of '" +  $class + "' using the criteria Path match " + $TargetFQDN + " and Displayname match " + $instance;
                Log -msg $msg -debug $debug -debugLog $debugLog;
                $instancetemp = get-SCOMClassInstance -Class $instancetempClass | Where-Object {($_.Path -match $TargetFQDN) -and ($_.Displayname -match $instance)}
                $msg = "Found instance " +  $instancetemp;
                Log -msg $msg -debug $debug -debugLog $debugLog;
            }

		    Foreach ($object in $instancetemp)
		    {
			
                if ($object.InMaintenanceMode -eq $true)
                {
					if ($StartStopCommand -eq "Start")
					{
						$msg = "Object already in maintenance. Extend Maintenance for " + $object.FullName;
						Log -msg $msg -debug $debug -debugLog $debugLog;
						ExtendMaintenance -msg $msg -debug $debug -debugLog $debugLog -mmEndDate $mmEndDate -comment $comment -object $object;
					}
					else
					{
						# stop Maintenance Mode
						StopMaintenance -msg $msg -debug $debug -debugLog $debugLog -mmEndDate $mmEndDate -comment $comment -object $object;
					}
				}
                else
                {
					if ($StartStopCommand -eq "Start")
					{
						$msg = "The instance is currently not in maintenance. Create a new maintenance window for " + $object.FullName;
						Log -msg $msg -debug $debug -debugLog $debugLog;
						$mmEndDate = $mmEndDate.ToUniversalTime();
						Start-SCOMMaintenanceMode -instance $object -endtime $mmEndDate -reason $Reason -comment $comment
					}
					else
					{
						# Stop Maintenance Mode requested -> Object currently not in Maintenance Mode -> nothing to to (only log)
						$msg = "The instance is currently not in maintenance. No Maintenance Mode stop required for " + $object.FullName;
						Log -msg $msg -debug $debug -debugLog $debugLog;
					}
                }
           }
		}
		else
		{
			if ($StartStopCommand -eq "Start")
			{
				$msg = "No class defined, set the server object into maintenance.";
				Log -msg $msg -debug $debug -debugLog $debugLog;
			}
			Else
			{
				$msg = "No class defined, remove the server from maintenance mode.";
				Log -msg $msg -debug $debug -debugLog $debugLog;
			}
			
            $computerClass = Get-SCOMClass -name "Microsoft.Windows.Computer";
            $computer = Get-SCOMClassInstance  -Class $computerClass | Where-Object {$_.DisplayName -like $TargetFQDN +".*" -or $_.DisplayName -match $TargetFQDN };

            $msg = "Object: " + $computer.Name
            Log -msg $msg -debug $debug -debugLog $debugLog;
			
            If ($computer -is [Object])
            {
                SetMMAll $computer
            }
            Else
            {
                $msg = "No Oject to set into maintenance mode"
                Log -msg $msg -debug $debug -debugLog $debugLog;
                Exit
            }

			# check if agent is part of a cluster and hosts virtual machines
			$msg = "Check whether the computer is hosting virtual machines";
			Log -msg $msg -debug $debug -debugLog $debugLog;
			$agent = get-SCOMagent | where {$_.DisplayName -eq $computer.DisplayName}
			$clusterMachines = $agent.GetRemotelyManagedComputers()
			
			if ($clusterMachines -is [Object])
			{
				foreach ($cluster in $clusterMachines)
				{
                    $computer = Get-SCOMClassInstance  -Class $computerClass | Where-Object {$_.DisplayName -like $cluster.displayname +".*" -or $_.DisplayName -match $cluster.displayname };
                    If ($computer -is [Object])
                    {
                        SetMMAll $computer
                    }
                    else
                    {
                        $msg = "No object to set into maintenance mode"
                        Log -msg $msg -debug $debug -debugLog $debugLog;
                    }
				}
			}
   		}						
	}
										
# log success event if required
if ($logSuccessEvent -eq $true)
{
  $api.LogScriptEvent($SCRIPT_NAME + " " + $SCRIPT_VERSION, $EVENT_ID_SUCCESS, $EVENT_TYPE_INFORMATION, "Successfully executed the script.");
}

$msg = "`r`n`r`nFinished processing the maintenance mode scheduling.`r`nScript finished -- " + (get-date).ToString() + "`r`n";
Log -msg $msg -debug $debug -debugLog $debugLog;

# close debug log if required
if ($debug -eq $true) 
{
  $debugLog.close();
}