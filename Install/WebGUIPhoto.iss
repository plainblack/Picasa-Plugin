[_TopOfScript]

[ISPP]
#define MyAppName "WebGUI Photo Upload"
#define MyAppVerName "WebGUI Photo Upload 1.0"
#define MyAppPublisher "PlainBlack"
#define MyAppURL "http://www.plainblack.com/"

[ISG-ScriptDefines]
; Folder of Inno Compiler for compiling
FolderOfInno=C:\Program Files\Inno Setup 5\
; Filename for own defined constants
ConstantFile=

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{BB2C394B-203B-432F-AEC4-616169087567}
AppName=WebGUI Photo Upload
AppVerName=WebGUI Photo Upload 1.0
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf}\{#MyAppName}
DefaultGroupName=RemoveMe
DisableProgramGroupPage=yes
OutputDir=C:\Users\q73491\Desktop\PB Picasa\Inno Install\Output
OutputBaseFilename=setup
SetupIconFile=C:\Users\q73491\Desktop\PB Picasa\WebGUI Files\WebGUIIcon.ICO
Compression=lzma
SolidCompression=yes
AppCopyright=plainblack
AllowUNCPath=False
VersionInfoVersion=1.0.0.0
VersionInfoCompany=plainblack
AppVersion=1.0
VersionInfoDescription=WebGUI Photo Upload Installer

[Languages]
Name: english; MessagesFile: compiler:Default.isl

[Files]
Source: C:\Users\q73491\Desktop\PB Picasa\WebGUI Files\Bin\WebGUIUpload.exe; DestDir: {app}; Flags: ignoreversion
Source: C:\Users\q73491\Desktop\PB Picasa\WebGUI Files\Bin\libeay32.dll; DestDir: {app}; Flags: ignoreversion
Source: C:\Users\q73491\Desktop\PB Picasa\WebGUI Files\Bin\ssleay32.dll; DestDir: {app}; Flags: ignoreversion
Source: C:\Users\q73491\Desktop\PB Picasa\WebGUI Files\Bin\WebGUI.pbz; DestDir: {code:GetPicasaPath}
; NOTE: Don't use "Flags: ignoreversion" on any shared system files



[Registry]
Root: HKLM; Subkey: Software\PlainBlack\WebGUIPhoto; ValueType: string; ValueData: {app}; Flags: uninsdeletekey

[Code]
function GetPicasaPath(Param: String) : string;
var
  PicasaPath : string;
begin
  If RegQueryStringValue(HKEY_LOCAL_MACHINE,'SOFTWARE\Google\Picasa\Picasa2','',PicasaPath) then
    Result := AddBackslash(PicasaPath)+'buttons\'
  else
    Result := '';
end;

function IsPicasaInstalled(Param: String) : Boolean;
begin
  Result := GetPicasaPath('') <> '';
end;

function InitializeSetup(): Boolean;
begin
  Result := IsPicasaInstalled('');
  If Result = FALSE then
    MsgBox('Cannot locate Picasa. WebGUI Photo Upload cannot be installed without Picasa.', mbError, MB_OK);
end;
