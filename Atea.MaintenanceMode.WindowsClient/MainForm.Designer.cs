/*
 * Created by SharpDevelop.
 * User: saper
 * Date: 2013-01-29
 * Time: 15:21
 * 
 * To change this template use Tools | Options | Coding | Edit Standard Headers.
 */
 
using System.Drawing;
 
namespace Atea_Request_Maintenance_Mode
{
	partial class MainForm
	{
		/// <summary>
		/// Designer variable used to keep track of non-visual components.
		/// </summary>
		private System.ComponentModel.IContainer components = null;
		
		/// <summary>
		/// Disposes resources used by the form.
		/// </summary>
		/// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
		protected override void Dispose(bool disposing)
		{
			if (disposing) {
				if (components != null) {
					components.Dispose();
				}
			}
			base.Dispose(disposing);
		}
		
		/// <summary>
		/// This method is required for Windows Forms designer support.
		/// Do not change the method contents inside the source code editor. The Forms designer might
		/// not be able to load this method if it was changed manually.
		/// </summary>
		private void InitializeComponent()
		{
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(MainForm));
            this.cbDuration = new System.Windows.Forms.ComboBox();
            this.lblMessage = new System.Windows.Forms.Label();
            this.lblDuration = new System.Windows.Forms.Label();
            this.lblReason = new System.Windows.Forms.Label();
            this.cbReason = new System.Windows.Forms.ComboBox();
            this.lblComment = new System.Windows.Forms.Label();
            this.tbComment = new System.Windows.Forms.TextBox();
            this.lblCurrentUser = new System.Windows.Forms.Label();
            this.tbCurrentUser = new System.Windows.Forms.TextBox();
            this.btStartMaintenance = new System.Windows.Forms.Button();
            this.btnCancel = new System.Windows.Forms.Button();
            this.btStopMaintenance = new System.Windows.Forms.Button();
            this.epDuration = new System.Windows.Forms.ErrorProvider(this.components);
            this.epReason = new System.Windows.Forms.ErrorProvider(this.components);
            this.lblStatusMessages = new System.Windows.Forms.Label();
            this.epIllegalComment = new System.Windows.Forms.ErrorProvider(this.components);
            this.tmCheckForACK = new System.Windows.Forms.Timer(this.components);
            ((System.ComponentModel.ISupportInitialize)(this.epDuration)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.epReason)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.epIllegalComment)).BeginInit();
            this.SuspendLayout();
            // 
            // cbDuration
            // 
            this.cbDuration.DisplayMember = "30";
            this.cbDuration.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cbDuration.Location = new System.Drawing.Point(138, 322);
            this.cbDuration.Name = "cbDuration";
            this.cbDuration.Size = new System.Drawing.Size(290, 21);
            this.cbDuration.TabIndex = 2;
            this.cbDuration.SelectedIndexChanged += new System.EventHandler(this.CbDurationSelectedIndexChanged);
            // 
            // lblMessage
            // 
            this.lblMessage.BackColor = System.Drawing.SystemColors.Info;
            this.lblMessage.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.lblMessage.Font = new System.Drawing.Font("Segoe UI", 9.75F, System.Drawing.FontStyle.Italic, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblMessage.ForeColor = System.Drawing.SystemColors.InfoText;
            this.lblMessage.Location = new System.Drawing.Point(33, 180);
            this.lblMessage.Name = "lblMessage";
            this.lblMessage.Size = new System.Drawing.Size(504, 122);
            this.lblMessage.TabIndex = 0;
            this.lblMessage.Text = resources.GetString("lblMessage.Text");
            this.lblMessage.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // lblDuration
            // 
            this.lblDuration.Location = new System.Drawing.Point(32, 325);
            this.lblDuration.Name = "lblDuration";
            this.lblDuration.Size = new System.Drawing.Size(100, 23);
            this.lblDuration.TabIndex = 1;
            this.lblDuration.Text = "&Duration:";
            // 
            // lblReason
            // 
            this.lblReason.Location = new System.Drawing.Point(32, 348);
            this.lblReason.Name = "lblReason";
            this.lblReason.Size = new System.Drawing.Size(100, 23);
            this.lblReason.TabIndex = 3;
            this.lblReason.Text = "&Reason:";
            // 
            // cbReason
            // 
            this.cbReason.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cbReason.Location = new System.Drawing.Point(138, 345);
            this.cbReason.Name = "cbReason";
            this.cbReason.Size = new System.Drawing.Size(290, 21);
            this.cbReason.TabIndex = 4;
            this.cbReason.SelectedIndexChanged += new System.EventHandler(this.CbReasonSelectedIndexChanged);
            // 
            // lblComment
            // 
            this.lblComment.Location = new System.Drawing.Point(32, 371);
            this.lblComment.Name = "lblComment";
            this.lblComment.Size = new System.Drawing.Size(100, 23);
            this.lblComment.TabIndex = 5;
            this.lblComment.Text = "C&omment:";
            // 
            // tbComment
            // 
            this.tbComment.Location = new System.Drawing.Point(138, 371);
            this.tbComment.Name = "tbComment";
            this.tbComment.Size = new System.Drawing.Size(290, 20);
            this.tbComment.TabIndex = 6;
            this.tbComment.TextChanged += new System.EventHandler(this.TbCommentTextChanged);
            // 
            // lblCurrentUser
            // 
            this.lblCurrentUser.Location = new System.Drawing.Point(32, 398);
            this.lblCurrentUser.Name = "lblCurrentUser";
            this.lblCurrentUser.Size = new System.Drawing.Size(100, 23);
            this.lblCurrentUser.TabIndex = 7;
            this.lblCurrentUser.Text = "Current User:";
            // 
            // tbCurrentUser
            // 
            this.tbCurrentUser.Location = new System.Drawing.Point(139, 398);
            this.tbCurrentUser.Name = "tbCurrentUser";
            this.tbCurrentUser.ReadOnly = true;
            this.tbCurrentUser.Size = new System.Drawing.Size(289, 20);
            this.tbCurrentUser.TabIndex = 8;
            this.tbCurrentUser.TabStop = false;
            // 
            // btStartMaintenance
            // 
            this.btStartMaintenance.Location = new System.Drawing.Point(139, 424);
            this.btStartMaintenance.Name = "btStartMaintenance";
            this.btStartMaintenance.Size = new System.Drawing.Size(110, 23);
            this.btStartMaintenance.TabIndex = 9;
            this.btStartMaintenance.Text = "&Start Maintenance";
            this.btStartMaintenance.UseVisualStyleBackColor = true;
            this.btStartMaintenance.Click += new System.EventHandler(this.BtStartMaintenanceClick);
            // 
            // btnCancel
            // 
            this.btnCancel.Location = new System.Drawing.Point(461, 424);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(75, 23);
            this.btnCancel.TabIndex = 11;
            this.btnCancel.Text = "&Cancel";
            this.btnCancel.UseVisualStyleBackColor = true;
            this.btnCancel.Click += new System.EventHandler(this.BtnCancelClick);
            // 
            // btStopMaintenance
            // 
            this.btStopMaintenance.Location = new System.Drawing.Point(255, 424);
            this.btStopMaintenance.Name = "btStopMaintenance";
            this.btStopMaintenance.Size = new System.Drawing.Size(110, 23);
            this.btStopMaintenance.TabIndex = 10;
            this.btStopMaintenance.Text = "Stop &Maintenance";
            this.btStopMaintenance.UseVisualStyleBackColor = true;
            this.btStopMaintenance.Click += new System.EventHandler(this.BtStopMaintenanceClick);
            // 
            // epDuration
            // 
            this.epDuration.BlinkStyle = System.Windows.Forms.ErrorBlinkStyle.AlwaysBlink;
            this.epDuration.ContainerControl = this;
            // 
            // epReason
            // 
            this.epReason.BlinkStyle = System.Windows.Forms.ErrorBlinkStyle.AlwaysBlink;
            this.epReason.ContainerControl = this;
            // 
            // lblStatusMessages
            // 
            this.lblStatusMessages.Font = new System.Drawing.Font("Courier New", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblStatusMessages.ForeColor = System.Drawing.SystemColors.GrayText;
            this.lblStatusMessages.Location = new System.Drawing.Point(33, 450);
            this.lblStatusMessages.Name = "lblStatusMessages";
            this.lblStatusMessages.Size = new System.Drawing.Size(504, 32);
            this.lblStatusMessages.TabIndex = 12;
            this.lblStatusMessages.Text = "Request sent, waiting for ACK...";
            this.lblStatusMessages.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // epIllegalComment
            // 
            this.epIllegalComment.BlinkStyle = System.Windows.Forms.ErrorBlinkStyle.NeverBlink;
            this.epIllegalComment.ContainerControl = this;
            // 
            // tmCheckForACK
            // 
            this.tmCheckForACK.Interval = 5000;
            this.tmCheckForACK.Tick += new System.EventHandler(this.TmCheckForACKTick);
            // 
            // MainForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.SystemColors.Window;
            this.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("$this.BackgroundImage")));
            this.BackgroundImageLayout = System.Windows.Forms.ImageLayout.None;
            this.ClientSize = new System.Drawing.Size(570, 492);
            this.ControlBox = false;
            this.Controls.Add(this.lblStatusMessages);
            this.Controls.Add(this.btStopMaintenance);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.btStartMaintenance);
            this.Controls.Add(this.tbCurrentUser);
            this.Controls.Add(this.lblCurrentUser);
            this.Controls.Add(this.tbComment);
            this.Controls.Add(this.lblComment);
            this.Controls.Add(this.lblReason);
            this.Controls.Add(this.cbReason);
            this.Controls.Add(this.lblDuration);
            this.Controls.Add(this.cbDuration);
            this.Controls.Add(this.lblMessage);
            this.DoubleBuffered = true;
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "MainForm";
            this.Padding = new System.Windows.Forms.Padding(30, 180, 30, 10);
            this.ShowIcon = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Request Maintenance Mode";
            this.Load += new System.EventHandler(this.MainFormLoad);
            ((System.ComponentModel.ISupportInitialize)(this.epDuration)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.epReason)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.epIllegalComment)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

		}
		private System.Windows.Forms.Timer tmCheckForACK;
		private System.Windows.Forms.ErrorProvider epIllegalComment;
		private System.Windows.Forms.Label lblStatusMessages;
		private System.Windows.Forms.ErrorProvider epReason;
		private System.Windows.Forms.ErrorProvider epDuration;
		private System.Windows.Forms.Button btStopMaintenance;
		private System.Windows.Forms.Button btnCancel;
		private System.Windows.Forms.Button btStartMaintenance;
		private System.Windows.Forms.TextBox tbCurrentUser;
		private System.Windows.Forms.Label lblCurrentUser;
		private System.Windows.Forms.TextBox tbComment;
		private System.Windows.Forms.Label lblComment;
		private System.Windows.Forms.ComboBox cbReason;
		private System.Windows.Forms.Label lblReason;
		private System.Windows.Forms.Label lblDuration;
		private System.Windows.Forms.ComboBox cbDuration;
		private System.Windows.Forms.Label lblMessage;
		
		void BtnCancelClick(object sender, System.EventArgs e)
		{
			this.Close();
		}
		
		void BtStopMaintenanceClick(object sender, System.EventArgs e)
		{
			OpsMMEventLog opsEventlog = new OpsMMEventLog();
			string comment = tbComment.Text;
			string userName = tbCurrentUser.Text;
			if (epIllegalComment.GetError(tbComment) == "") {
				if (opsEventlog.writeStopEvent("","",comment,userName)){
					setStatusMessage("Stopping Maintenance Mode\n",STATUS_INFO);
					tmCheckForACK.Start();
					btStartMaintenance.Enabled = false;
					btStopMaintenance.Enabled = false;
					btnCancel.Text = "&Close";
				} else {
					setStatusMessage("Failed to write event! Are you running as administrator?",STATUS_ERROR);
				}
			}
		}
		
		void BtStartMaintenanceClick(object sender, System.EventArgs e)
		{
			bool allPropertiesSet = false;
			
			if (cbDuration.SelectedIndex >= 0){
				allPropertiesSet = true;
			} else {
				epDuration.SetError(cbDuration,"Must select duration!");
				allPropertiesSet = false;
			}
			if (cbReason.SelectedIndex >= 0){
				allPropertiesSet = true;
			} else {
				epReason.SetError(cbReason,"Must select reason!");
				allPropertiesSet = false;
			}
			if (epIllegalComment.GetError(tbComment) != "" 
			    	|| epReason.GetError(cbReason) != "" 
			    	|| epDuration.GetError(cbDuration) != "") {
				allPropertiesSet = false;
			}
			
			// All inputs looks OK, write start command to event log.
			if (allPropertiesSet) {
				OpsMMEventLog opsEventlog = new OpsMMEventLog();
				KeyValuePair kvpDuration = (KeyValuePair) cbDuration.SelectedItem;
				KeyValuePair kvpReason = (KeyValuePair) cbReason.SelectedItem;
				string comment = tbComment.Text;
				string userName = tbCurrentUser.Text;
				if (opsEventlog.writeStartEvent(kvpDuration.m_objectKey.ToString(),kvpReason.m_objectKey.ToString(),"","",comment,userName)){
					setStatusMessage("Maintenance mode requested, waiting for confirmation.\n",STATUS_INFO);
					tmCheckForACK.Start();
					btStartMaintenance.Enabled = false;
					btStopMaintenance.Enabled = false;
					btnCancel.Text = "&Close";
				} else {
					setStatusMessage("Failed to write event! Are you running as administrator?",STATUS_ERROR);
				}
			}
		}
		
		void CbDurationSelectedIndexChanged(object sender, System.EventArgs e)
		{
			epDuration.Clear();
		}
		
		void CbReasonSelectedIndexChanged(object sender, System.EventArgs e)
		{
			epReason.Clear();
			
		}
		
		private void setStatusMessage(string statusText,int statusLevel){
			Color statusColor;
			bool boldText = false;
			switch (statusLevel){
				case STATUS_INFO: // STATUS_INFO - Gray text
					statusColor = Color.Gray;
					break;
				case STATUS_OK: // STATUS_OK - Green text
					statusColor = Color.Green;
					boldText = true;
					break;
				case STATUS_WARNING: // STATUS_WARNING - Orange text
					statusColor = Color.Firebrick;
					boldText = true;
					break;
				case STATUS_ERROR: // STATUS_ERROR - Red text
					statusColor = Color.Crimson;
					boldText = true;
					break;
				default: // Unknown, assume STATUS_INFO
					statusColor = Color.Gray;
					break;
			}
			lblStatusMessages.ForeColor = statusColor;
			lblStatusMessages.Text = statusText;
			if (boldText) {
				lblStatusMessages.Font = new Font(lblStatusMessages.Font, FontStyle.Bold);
			} else {
				lblStatusMessages.Font = new Font(lblStatusMessages.Font, FontStyle.Regular);
			}
		}
		
		void TmCheckForACKTick(object sender, System.EventArgs e)
		{
			OpsMMEventLog opsEventLog = new OpsMMEventLog();
			if (opsEventLog.gotAckEvent()) {
				setStatusMessage("Server is in maintenance mode!\nYou may close this window.", STATUS_OK);
				btnCancel.Text = "&Close";
				btnCancel.Focus();
				tmCheckForACK.Stop();
				btStartMaintenance.Enabled = true;
				btStopMaintenance.Enabled = true;
			} else {
				setMMTimeout = setMMTimeout - tmCheckForACK.Interval;
				if (setMMTimeout > 30000) {
					setStatusMessage(lblStatusMessages.Text + ".",STATUS_INFO);
				} else if (setMMTimeout > 0) {
					setStatusMessage(lblStatusMessages.Text + ".",STATUS_WARNING);
				} else {
					setStatusMessage("Timed out waiting for maintenance mode.\nPlease contact service desk for assistance.",STATUS_ERROR);
					tmCheckForACK.Stop();
					setMMTimeout = MM_TIMEOUT;
				}
				
			}
		}
	}
}
