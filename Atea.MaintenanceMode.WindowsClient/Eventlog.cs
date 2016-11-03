/*
 * Created by SharpDevelop.
 * User: Samuel Tegenfeldt
 * Date: 2013-02-07
 * Time: 16:14
 */
using System;
using System.Diagnostics;
using System.Diagnostics.Eventing.Reader;

namespace Atea_Request_Maintenance_Mode
{
    /// <summary>
    /// Handles all event log management for the Request Maintenance Mode application
    /// and it's companion Management Pack.
    /// </summary>
    public class OpsMMEventLog : IOpsMMEventLog
    {
        private string opsmgrEventLogName = "Operations Manager";
        private string mmStartSourceName = "AteaRequestMM";
        private string mmAckSourcName = "HealthService";
        private int mmStartEventId = 997;
        private int mmStopEventId = 998;
        private int mmAckEventId = 1215;
        private string mmStartCommand = "Stop";
        private string mmsStopCommand = "Start";
        private EventLog omEventLog;

        /// <summary>
        /// Initialize eventlog objects for later use.
        /// </summary>
        public OpsMMEventLog()
        {
            omEventLog = new EventLog();
        }

        /// <summary>
        /// Writes a "Start" event to the Operations Manager eventlog to request
        /// a maintenance windows on the local server.
        /// </summary>
        /// <param name="Duration">Duration of maintenance mode in minutes.</param>
        /// <param name="Reason">The reason for the maintenance mode.</param>
        /// <param name="opsClass">Obsolete: Operations Manager Class to request maintenance mode for.</param>
        /// <param name="opsInstance">Obsolete: Operations Manager Instance to request maintenance mode for.</param>
        /// <param name="Comment">Descriptive comment on the purpose of the maintenance mode.</param>
        /// <param name="Username">The requesting user.</param>
        /// <returns>bool true if successful, false if not</returns>
        public bool writeStartEvent(string Duration, string Reason, string opsClass, string opsInstance, string Comment, string Username)
        {

            bool eventCreated = false;
            Comment = Comment + ":" + Username + ":" + DateTime.Now;
            string[] eventStrings = new string[] { mmsStopCommand, Duration, Reason, opsClass, opsInstance, Comment };
            string eventDescription = String.Join(";", eventStrings);

            Debug.WriteLine("Debug Eventlog.writeStartEvent starting");
            Debug.Indent();
            Debug.WriteLine("eventDescription: " + eventDescription);
            try
            {
                Debug.WriteLine("opsmgrEventLogName: " + opsmgrEventLogName);
                omEventLog.Log = opsmgrEventLogName;
                Debug.WriteLine("eventSourceName: " + mmStartSourceName);
                omEventLog.Source = mmStartSourceName;

                omEventLog.WriteEntry(eventDescription, EventLogEntryType.Information, mmStartEventId);
                eventCreated = true;
            }
            catch
            {
                eventCreated = false;
            }

            Debug.Unindent();
            return eventCreated;
        }


        /// <summary>
        /// Writes a "Stop" event to the Operations Manager eventlog to request
        /// a maintenance windows on the local server.
        /// </summary>
        /// <param name="opsClass">Obsolete: Operations Manager Class to request maintenance mode for.</param>
        /// <param name="opsInstance">Obsolete: Operations Manager Instance to request maintenance mode for.</param>
        /// <param name="Comment">Descriptive comment on why the maintenance mode are stopped.</param>
        /// <param name="Username">The requesting user.</param>
        /// <returns>bool true if successful, false if not</returns>
        public bool writeStopEvent(string opsClass, string opsInstance, string Comment, string Username)
        {
            bool eventCreated = false;
            Comment = Comment + ":" + Username + ":" + DateTime.Now;
            string[] eventStrings = new string[] { mmStartCommand, "", "", opsClass, opsInstance, Comment };
            string eventDescription = String.Join(";", eventStrings);

            try
            {
                omEventLog.Log = opsmgrEventLogName;
                omEventLog.Source = mmStartSourceName;
                omEventLog.WriteEntry(eventDescription, EventLogEntryType.Information, mmStopEventId);
                eventCreated = true;
            }
            catch
            {
                eventCreated = false;
            }
            return eventCreated;
        }

        /// <summary>
        /// Search the Operations Manager event log for eventId 1215 which indicates
        /// that maintenance mode has started.
        /// </summary>
        public bool gotAckEvent()
        {
            bool gotAck = false;

            Debug.WriteLine("Debug Start Eventlog.gotAckEvent()");
            Debug.Indent();
            string queryString =
            "<QueryList>" +
            "	<Query Id=\"0\" Path=\"" + opsmgrEventLogName + "\">" +
            "		<Select Path=\"" + opsmgrEventLogName + "\">*[System[Provider[@Name='" + mmAckSourcName + "'] and (EventID=" + mmAckEventId + ") and TimeCreated[timediff(@SystemTime) &lt;= 20000]]]</Select>" +
            "	</Query>" +
            "</QueryList>";
            Debug.WriteLine("Querysting:");
            Debug.WriteLine(queryString);

            EventLogQuery eventsQuery = new EventLogQuery(opsmgrEventLogName, PathType.LogName, queryString);
            EventLogReader logReader = new EventLogReader(eventsQuery);

            int numberOfEvents = 0;
            for (EventRecord eventInstance = logReader.ReadEvent(); eventInstance != null; eventInstance = logReader.ReadEvent())
            {
                String eventData = eventInstance.ToXml();
                Debug.WriteLine(eventData);
                if (eventInstance.Id == mmAckEventId && eventInstance.ProviderName == mmAckSourcName)
                {
                    numberOfEvents++;
                    gotAck = true;
                }
            }

            Debug.WriteLine("Total Number of Events: " + numberOfEvents);
            Debug.Unindent();
            return gotAck;
        }
    }
}
