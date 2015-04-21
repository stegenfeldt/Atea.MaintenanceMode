; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{2B4F6FC0-D244-4E29-B01A-4C6C516D59E3}
AppName=Atea Request Maintenance Mode
AppVersion=1.0.0.12
;AppVerName=Atea Request Maintenance Mode 1.0
AppPublisher=Atea Sverige AB
DefaultDirName={pf}\Atea Request Maintenance Mode
DisableDirPage=yes
DefaultGroupName=Atea\Request Maintenance Mode
DisableProgramGroupPage=yes
LicenseFile=C:\Data\Dropbox\Atea\Atea\Project Engine\WIP\Dev\Request Maintenance Mode\Request Maintenance Mode\setup\license.rtf
OutputDir=C:\Data\Dropbox\Atea\Atea\Project Engine\WIP\Dev\Request Maintenance Mode\Request Maintenance Mode\setup
OutputBaseFilename=setup
Compression=lzma2/ultra
SolidCompression=yes
ShowLanguageDialog=no
DisableWelcomePage=True
AppCopyright=Samuel Tegenfeldt - Atea Sverige AB
AppContact=Samuel Tegenfeldt

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 0,6.1

[Files]
Source: "C:\Data\Dropbox\Atea\Atea\Project Engine\WIP\Dev\Request Maintenance Mode\Request Maintenance Mode\bin\Release\Request Maintenance Mode.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Data\Dropbox\Atea\Atea\Project Engine\WIP\Dev\Request Maintenance Mode\Request Maintenance Mode\Management Pack\Atea.Agent.MaintenanceMode.mp"; DestDir: "{app}\Management Pack"; Flags: ignoreversion; Components: ManagementPack
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\Atea Request Maintenance Mode"; Filename: "{app}\Request Maintenance Mode.exe"
Name: "{commondesktop}\Atea Request Maintenance Mode"; Filename: "{app}\Request Maintenance Mode.exe"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\Atea Request Maintenance Mode"; Filename: "{app}\Request Maintenance Mode.exe"; Tasks: quicklaunchicon


[Components]
Name: "ManagementPack"; Description: "Install companion Management Packs"

[Dirs]
Name: "{app}\ManagementPack"; Components: ManagementPack
