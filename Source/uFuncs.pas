unit uFuncs;

interface
uses
  Windows,SysUtils,ShellAPI, SHFolder, JwaWinCred;

function DeleteFullDirectory(aDirectory : String) : Boolean;
function GetFolderPath(SFolder : integer) : string;
function GetUserCredentials(AHandle : Cardinal; ACaption, AMessage : WideString; var AUser, APassword : WideString) : Boolean;

implementation

/// <summary>
/// Delete directory and all files/directories under it
/// </summary>
/// <param name="aDirectory"> Directory to delete </param>
function DeleteFullDirectory(aDirectory : String) : Boolean;
var
  FileOp : TShFileOpStruct;
begin
  aDirectory := ExcludeTrailingPathDelimiter(aDirectory);

  If DirectoryExists(aDirectory) then
    begin
      try
        FileOp.pFrom := PChar(aDirectory+#0+#0);
        FileOp.pTo := nil;
        FileOp.Wnd := 0;
        FileOp.wFunc := FO_DELETE;
        FileOp.fFlags := FOF_NOCONFIRMATION or FOF_SILENT or FOF_NOERRORUI;
        FileOp.fAnyOperationsAborted := FALSE;
        FileOp.hNameMappings := nil;
        FileOp.lpszProgressTitle := nil;
        Result := SHFileOperation(FileOp) = 0;
      except
        Result := FALSE;
      end;
    end
  else
    Result := FALSE;
end;

/// <summary>
/// Retrieves the shell folder path, does not include a trailing path delimiter
/// </summary>
/// <param name="SFolder"> CSIDL to retrieve the path for </param>
/// <returns>String - returns folder path</returns>
function GetFolderPath(SFolder : integer) : string;
var
  tmpres : PChar;
begin
  Result := '';
  GetMem(tmpres,255);
  try
    If SHGetFolderPath(0,SFolder, 0,0,tmpres) = NOERROR then
      Result := ExcludeTrailingPathDelimiter(StrPas(tmpres));
  finally
    FreeMem(tmpres);
  end;
end;


/// <summary>
/// Displays the Windows user certificate window
/// </summary>
/// <param name="AHandle"> Parent for certificate window </param>
/// <param name="ACaption"> Caption for window </param>
/// <param name="AMessage"> Message text for window </param>
/// <param name="AUser"> var - User ID returned </param>
/// <param name="ADomain"> var - Domain returned </param>
/// <param name="APassword"> var - Password returned </param>
function GetUserCredentials(AHandle : Cardinal; ACaption, AMessage : WideString; var AUser, APassword : WideString) : Boolean;
var
  cui : CREDUI_INFOW;
  pszName : PWideChar;
  pszPwd : PWideChar;
  fSave: LongBool;
  dwErr: Cardinal;
  Flags : DWORD;
  Target: WideString;
begin
  {$IFDEF DEBUGSYS}CodeSite.EnterMethod( 'GetUserCredentials' );{$ENDIF}
  Result := False;
  pszName := nil;
  pszPwd := nil;
  try
    GetMem(pszName,CREDUI_MAX_USERNAME_LENGTH+1);
    GetMem(pszPwd,CREDUI_MAX_PASSWORD_LENGTH+1);

    cui.cbSize := sizeof(CREDUI_INFO);
    cui.hwndParent := AHandle;
    cui.pszMessageText := @AMessage[1];
    cui.pszCaptionText := @ACaption[1];
    cui.hbmBanner := 0;
    fSave := FALSE;
    Flags:= CREDUI_FLAGS_DO_NOT_PERSIST or
            CREDUI_FLAGS_GENERIC_CREDENTIALS;
    Target := '';
    {$IFDEF DEBUGSYS} CodeSite.Send('target',Target); {$ENDIF}
    ZeroMemory(pszName, sizeof(pszName));
    ZeroMemory(pszPwd, sizeof(pszPwd));
    dwErr := 0;
    while (not Result) and (dwErr <> ERROR_CANCELLED) do
      begin
        dwErr := CredUIPromptForCredentialsW(
            @cui,                         // CREDUI_INFO structure
            nil,                  // Target for credentials (usually a server)
            nil,                         // Reserved
            0,                            // Reason
            pszName,                      // User name
            CREDUI_MAX_USERNAME_LENGTH+1, // Max number of char for user name
            pszPwd,                       // Password
            CREDUI_MAX_PASSWORD_LENGTH+1, // Max number of char for password
            fSave,                       // State of save check box
            Flags);
        {$IFDEF DEBUGSYS} CodeSite.Send('credui called'); {$ENDIF}
        {$IFDEF DEBUGSYS} CodeSite.Send('dwErr',dwErr); {$ENDIF}
        if dwErr = 0 then
          begin
            {$IFDEF DEBUGSYS} CodeSite.Send('after parse'); {$ENDIF}
            {$IFDEF DEBUGSYS} CodeSite.Send('pszPwd',pszPwd); {$ENDIF}
            AUser := WideCharToString(pszName);
            APassword := WideCharToString(pszPwd);
            Result := TRUE;
          end;
      end;

  finally
    {$IFDEF DEBUGSYS} CodeSite.Send('before name zero'); {$ENDIF}
    if pszName <> nil then
      ZeroMemory(pszName, sizeof(pszName));
    {$IFDEF DEBUGSYS} CodeSite.Send('before pwd zero'); {$ENDIF}
    if pszPwd <> nil then
      ZeroMemory(pszPwd, sizeof(pszPwd));
    {$IFDEF DEBUGSYS} CodeSite.Send('before free'); {$ENDIF}
    FreeMem(pszName);
    {$IFDEF DEBUGSYS} CodeSite.Send('name freed'); {$ENDIF}
    FreeMem(pszPwd);
    {$IFDEF DEBUGSYS} CodeSite.Send('pwd freed'); {$ENDIF}
    {$IFDEF DEBUGSYS} CodeSite.Send('domain freed'); {$ENDIF}
  end;

  {$IFDEF DEBUGSYS}CodeSite.ExitMethod( 'GetUserCredentials' );{$ENDIF}
end;



end.
