namespace Atea_Request_Maintenance_Mode
{
    /// <summary>
    /// Interface for OpsMMEventLog
    /// </summary>
    public interface IOpsMMEventLog
    {
        /// <summary>
        /// Has an ACK event been found?
        /// </summary>
        /// <returns>true/false</returns>
        bool gotAckEvent();

        /// <summary>
        /// Write the start event
        /// </summary>
        /// <param name="Duration"></param>
        /// <param name="Reason"></param>
        /// <param name="opsClass"></param>
        /// <param name="opsInstance"></param>
        /// <param name="Comment"></param>
        /// <param name="Username"></param>
        /// <returns>true/false</returns>
        bool writeStartEvent(string Duration, string Reason, string opsClass, string opsInstance, string Comment, string Username);

        /// <summary>
        /// Write the stop event
        /// </summary>
        /// <param name="opsClass"></param>
        /// <param name="opsInstance"></param>
        /// <param name="Comment"></param>
        /// <param name="Username"></param>
        /// <returns>true/false</returns>
        bool writeStopEvent(string opsClass, string opsInstance, string Comment, string Username);
    }
}