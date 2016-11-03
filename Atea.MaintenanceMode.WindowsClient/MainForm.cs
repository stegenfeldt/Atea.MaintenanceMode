/*
 * Created by SharpDevelop.
 * User: Samuel Tegenfeldt
 * Date: 2013-01-29
 * Time: 15:21
 * 
 * To change this template use Tools | Options | Coding | Edit Standard Headers.
 */
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Windows.Forms;

namespace Atea_Request_Maintenance_Mode
{
    /// <summary>
    /// Description of MainForm.
    /// </summary>
    public partial class MainForm : Form
    {
        private const int STATUS_INFO = 0;
        private const int STATUS_OK = 1;
        private const int STATUS_WARNING = 2;
        private const int STATUS_ERROR = 3;
        private const int MM_TIMEOUT = 300000;
        private Color ATEA_GREEN = Color.FromArgb(255, 108, 172, 32);
        private int setMMTimeout = MM_TIMEOUT;

        /// <summary>
        /// Main form initialization
        /// </summary>
		public MainForm()
        {
            //
            // The InitializeComponent() call is required for Windows Forms designer support.
            //
            InitializeComponent();

            //
            // TODO: Add constructor code after the InitializeComponent() call.
            //
        }

        void MainFormLoad(object sender, EventArgs e)
        {
            // Fill Duration drop-down with selectables
            this.cbDuration.Items.Add(new KeyValuePair("30", "30 minutes"));
            this.cbDuration.Items.Add(new KeyValuePair("60", "1 hour"));
            this.cbDuration.Items.Add(new KeyValuePair("120", "2 hours"));
            this.cbDuration.Items.Add(new KeyValuePair("240", "4 hours"));
            this.cbDuration.Items.Add(new KeyValuePair("480", "8 hours"));
            this.cbDuration.Items.Add(new KeyValuePair("720", "12 hours"));
            this.cbDuration.Items.Add(new KeyValuePair("1400", "1 day"));
            this.cbDuration.Items.Add(new KeyValuePair("2880", "2 days"));
            this.cbDuration.Items.Add(new KeyValuePair("10080", "1 week"));
            this.cbDuration.Items.Add(new KeyValuePair("20160", "2 weeks"));
            this.cbDuration.Items.Add(new KeyValuePair("40320", "4 weeks"));

            // Fill Reason drop-down with selectables
            this.cbReason.Items.Add(new KeyValuePair("PlannedApplicationMaintenance", "Planned Application Maintenance"));
            this.cbReason.Items.Add(new KeyValuePair("PlannedHardwareMaintenance", "Planned Hardware Maintenance"));
            this.cbReason.Items.Add(new KeyValuePair("PlannedHardwareInstallation", "Planned Hardware Installation"));
            this.cbReason.Items.Add(new KeyValuePair("PlannedOperatingSystemReconfiguration", "Planned Operating System Reconfiguration"));
            this.cbReason.Items.Add(new KeyValuePair("PlannedOther", "Planned Other"));
            this.cbReason.Items.Add(new KeyValuePair("ApplicationInstallation", "Application Installation"));
            this.cbReason.Items.Add(new KeyValuePair("ApplicationUnresponsive", "Application Unresponsive"));
            this.cbReason.Items.Add(new KeyValuePair("ApplicationUnstable", "Application Unstable"));
            this.cbReason.Items.Add(new KeyValuePair("SecurityIssue", "Security Issue"));
            this.cbReason.Items.Add(new KeyValuePair("UnplannedOperatingSystemReconfiguration", "Unplanned Operating System Reconfiguration"));
            this.cbReason.Items.Add(new KeyValuePair("UnplannedHardwareInstallation", "Unplanned Hardware Installation"));
            this.cbReason.Items.Add(new KeyValuePair("UnplannedHardwareMaintenance", "Unplanned Hardware Maintenance"));
            this.cbReason.Items.Add(new KeyValuePair("UnplannedOther", "Unplanned Other"));
            this.cbReason.Items.Add(new KeyValuePair("LossOfNetworkConnectivity", "Loss of Network Connectivity"));


            // Clear the status lable
            lblStatusMessages.Text = "";

            // Set the Current user information
            tbCurrentUser.Text = System.Security.Principal.WindowsIdentity.GetCurrent().Name;
            btStopMaintenance.Visible = false;

            //TODO: Load custom logo if available
            String logoPath = Application.StartupPath + @"\logo.png";
            if (System.IO.File.Exists(logoPath))
            {
                this.BackgroundImage = Image.FromFile(logoPath);
            }
        }

        void TbCommentTextChanged(object sender, EventArgs e)
        {
            string errorMessage = "Semi-colon is not allowed in comments!";
            if (tbComment.Text.IndexOfAny(";".ToCharArray()) != -1)
            {
                epIllegalComment.SetError(tbComment, errorMessage);
                setStatusMessage(errorMessage, 3);
            }
            else
            {
                epIllegalComment.Clear();
                setStatusMessage("", 0);
            }
        }

        private void coloredProgressBar1_Click(object sender, EventArgs e)
        {

        }
    }
}
