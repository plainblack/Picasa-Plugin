unit uWebGUI;

interface

uses
  {$IFDEF DEBUG} CodeSiteLogging, {$ENDIF}
  Windows, Messages, SysUtils, Variants, Classes, Controls, Forms,
  ExtCtrls, StdCtrls, uOptions, uHTTP,ShellAPI, Types;

type
  TfrmWebGUI = class(TForm)
    lblServer: TLabel;
    lblUser: TLabel;
    lblPwd: TLabel;
    lblGallery: TLabel;
    lblAlbum: TLabel;
    cbbServer: TComboBox;
    edtUser: TEdit;
    edtPwd: TEdit;
    cbbGallery: TComboBox;
    cbbAlbum: TComboBox;
    btnServerView: TButton;
    btnServerRemove: TButton;
    btnGalleryLoad: TButton;
    btnGalleryView: TButton;
    btnAlbumView: TButton;
    btnAlbumCreate: TButton;
    btnCancel: TButton;
    btnExport: TButton;
    pnlGUI: TPanel;
    lblPicCount: TLabel;
    btnOptions: TButton;
    procedure btnExportClick(Sender: TObject);
    procedure btnAlbumCreateClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnGalleryLoadClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cbbServerSelect(Sender: TObject);
    procedure btnGalleryViewClick(Sender: TObject);
    procedure btnServerViewClick(Sender: TObject);
    procedure btnAlbumViewClick(Sender: TObject);
    procedure btnServerRemoveClick(Sender: TObject);
    procedure btnOptionsClick(Sender: TObject);
    procedure cbbGallerySelect(Sender: TObject);
  private
    FMRUFile : string;
    FOptions : TWebGUIOptions;
    Web : TWebHTTP;
    FGalleryArray : TStringDynArray;
    FAlbumArray : TStringDynArray;
    function UIValidateLoadGallery: Boolean;
    function UIValidateExport : Boolean;
    procedure RemoveTempDirectory;
    procedure ServerSaveMRU;
    procedure ServerLoadMRU;
    procedure ServerManageMRU;
    procedure FormatServerURL;
    procedure ClearAlbums;
    procedure ClearGalleries;
    procedure AppException(Sender: TObject; E: Exception);
  public
    { Public declarations }
  end;

var
  frmWebGUI: TfrmWebGUI;

implementation
uses uUpload, uAlbum, uFuncs, ShlObj;
{$R C:\DELPHI~1\~Win32AddOns\vistainvoker.RES}
{$R *.dfm}

resourcestring
  msgValidationError  = 'The following items need to be filled out before continuing:'#13#10;
  msgServerMRUError   = 'Could not load previously used server list.';
  msgGalleryViewError = 'A gallery must first be selected.';
  msgAlbumViewError   = 'A album must first be selected.';
  msgGalleryNone      = 'No galleries were found.';
  msgAlbumNone        = 'No albums found for this gallery.';

/// <summary>
/// Handles application errors, if WinPE will reboot the machine if windows program will exit.
/// </summary>
/// <param name="Sender">Sender</param>
/// <param name="e"> Exception </param>
procedure TfrmWebGUI.AppException(Sender: TObject; E: Exception);
begin
  // ensures cursor is returned to default before error is displayed
  Screen.Cursor := crDefault;
  Application.ShowException(e);
end;

procedure TfrmWebGUI.btnAlbumCreateClick(Sender: TObject);
var
  Album : string;
  AllowOthers : Boolean;
  i: integer;
begin
  {$IFDEF DEBUG}CodeSite.EnterMethod( Self, 'btnAlbumCreateClick' );{$ENDIF}
  if cbbGallery.ItemIndex > -1 then
    begin
      frmAlbum := TfrmAlbum.Create(Self);
      If frmAlbum.ShowModal(Album,AllowOthers) = mrOk then
        begin
          Screen.Cursor := crHourGlass;
          Web.CreateAlbum(FGalleryArray[Integer(cbbGallery.Items.Objects[cbbGallery.ItemIndex])],
                AllowOthers,edtUser.Text,edtPwd.Text,Album,FAlbumArray,cbbAlbum,FOptions);
          i := cbbAlbum.Items.IndexOf(Album);
          cbbAlbum.ItemIndex := i;
          Screen.Cursor := crDefault;
        end;
      FreeAndNil(frmAlbum);
    end
  else
    MessageBox(Self.Handle,PChar(msgGalleryViewError),PChar(Application.Title),MB_OK);

  {$IFDEF DEBUG}CodeSite.ExitMethod( Self, 'btnAlbumCreateClick' );{$ENDIF}
end;

procedure TfrmWebGUI.btnAlbumViewClick(Sender: TObject);
begin
  if cbbAlbum.ItemIndex > -1 then
    begin
      ShellExecute(0,'open',PWideChar(FAlbumArray[Integer(cbbAlbum.Items.Objects[cbbAlbum.ItemIndex])]),nil,nil,SW_SHOWNORMAL)
    end
  else
    MessageBox(Self.Handle,PChar(msgAlbumViewError),PChar(Application.Title),MB_OK);
end;

procedure TfrmWebGUI.btnCancelClick(Sender: TObject);
begin
  {$IFDEF DEBUG}CodeSite.EnterMethod( Self, 'btnCancelClick' );{$ENDIF}
  Application.Terminate;
  {$IFDEF DEBUG}CodeSite.ExitMethod( Self, 'btnCancelClick' );{$ENDIF}
end;

procedure TfrmWebGUI.btnExportClick(Sender: TObject);
begin
  {$IFDEF DEBUG}CodeSite.EnterMethod( Self, 'btnExportClick' );{$ENDIF}
  if UIValidateExport then
    begin
      Screen.Cursor := crHourGlass;
      frmUpload := TfrmUpload.Create(Self);
      frmUpload.ShowModal(cbbAlbum.Text,FAlbumArray[Integer(cbbAlbum.Items.Objects[cbbAlbum.ItemIndex])],edtUser.Text,edtPwd.Text,FOptions);
      FreeAndNil(frmUpload);
      Screen.Cursor := crDefault;
      ServerSaveMRU;
      Application.Terminate;
    end;
  {$IFDEF DEBUG}CodeSite.ExitMethod( Self, 'btnExportClick' );{$ENDIF}
end;

procedure TfrmWebGUI.btnGalleryLoadClick(Sender: TObject);
begin
  {$IFDEF DEBUG}CodeSite.EnterMethod( Self, 'btnGalleryLoadClick' );{$ENDIF}
  FormatServerURL;
  // Clear galleries and albums since we're loading
  ClearGalleries;
  ClearAlbums;

  if UIValidateLoadGallery then
    begin
      Screen.Cursor := crHourGlass;
      Web.GetWebList(cbbServer.Text+urlGetGalleries,edtUser.Text,edtPwd.Text,FGalleryArray,cbbGallery,FOptions);
      Screen.Cursor := crDefault;
      if cbbGallery.Items.Count > 0 then
        begin
          ServerManageMRU;
          ServerSaveMRU;
          cbbGallery.SetFocus;
          cbbGallery.DroppedDown := True;
        end
      else
        MessageBox(Self.Handle,PChar(msgGalleryNone),PChar(Application.Title),MB_OK or MB_ICONWARNING);
    end;
  {$IFDEF DEBUG}CodeSite.ExitMethod( Self, 'btnGalleryLoadClick' );{$ENDIF}
end;

procedure TfrmWebGUI.btnGalleryViewClick(Sender: TObject);
begin
  if cbbGallery.ItemIndex > -1 then
    ShellExecute(0,'open',PWideChar(FGalleryArray[Integer(cbbGallery.Items.Objects[cbbGallery.ItemIndex])]),nil,nil,SW_SHOWNORMAL)
  else
    MessageBox(Self.Handle,PChar(msgGalleryViewError),PChar(Application.Title),MB_OK or MB_ICONERROR);
end;

procedure TfrmWebGUI.btnOptionsClick(Sender: TObject);
begin
  frmOptions := TfrmOptions.Create(Self);
  frmOptions.ShowModal(FOptions);
  FreeAndNil(frmOptions);
end;

procedure TfrmWebGUI.btnServerRemoveClick(Sender: TObject);
begin
  if cbbServer.ItemIndex > -1 then
    begin
      cbbServer.DeleteSelected;
      if cbbServer.Items.Count > 0 then
        cbbServer.ItemIndex := 0;
      // saving MRU list so the user doesn't need to remove it multiple times.
      ServerSaveMRU;
    end
  else
    cbbServer.Text := '';
end;

procedure TfrmWebGUI.btnServerViewClick(Sender: TObject);
begin
  if cbbServer.Text <> '' then
    begin
      FormatServerURL;
      ServerManageMRU;
      ShellExecute(0,'open',PWideChar(cbbServer.Text),nil,nil,SW_SHOWNORMAL);
      ServerSaveMRU;
    end
  else
    MessageBox(Self.Handle,'A server must be selected before you can view.',PChar(Application.Title),MB_OK or MB_ICONERROR);
end;

/// <summary>
/// Clears the galleries
/// </summary>
procedure TfrmWebGUI.ClearGalleries;
begin
  cbbGallery.Clear;
  FGalleryArray := nil;
end;

/// <summary>
/// Clears the Albums
/// </summary>
procedure TfrmWebGUI.ClearAlbums;
begin
  cbbAlbum.Clear;
  FAlbumArray := nil;
end;

procedure TfrmWebGUI.cbbGallerySelect(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  Web.GetWebList(FGalleryArray[Integer(cbbGallery.Items.Objects[cbbGallery.ItemIndex])]+urlGetAlbums,edtUser.Text,edtPwd.Text,FAlbumArray,cbbAlbum,FOptions);
  Screen.Cursor := crDefault;
  if cbbAlbum.Items.Count > 0 then
    begin
      cbbAlbum.SetFocus;
      cbbAlbum.DroppedDown := True;
    end
  else
    MessageBox(Self.Handle,PChar(msgAlbumNone),PChar(Application.Title),MB_OK or MB_ICONWARNING);
end;

procedure TfrmWebGUI.cbbServerSelect(Sender: TObject);
begin
  // Clear gallery and album drop-downs
  ClearGalleries;
  ClearAlbums;
end;

/// <summary>
/// Make sure currently selected server is formatted correctly
/// </summary>
procedure TfrmWebGUI.FormatServerURL;
begin
  if (cbbServer.Text <> '') and (Pos('://',cbbServer.Text) = 0) then
    cbbServer.Text := 'http://'+cbbServer.Text;
end;

procedure TfrmWebGUI.FormCreate(Sender: TObject);
begin
  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := TRUE;
  CodeSite.Destination := TCodeSiteDestination.Create(CodeSite);
  CodeSite.Destination.LogFile.FileName := '.csl';
  CodeSite.Destination.LogFile.FilePath := 'C:\program files\enterprise desktop\';
  CodeSite.Destination.LogFile.Active := FALSE;
  CodeSite.Destination.TCP.Host := 'q73491-2k1.kcc.com';
  //CodeSite.Destination.TCP.Active := TRUE;
  //CodeSite.ConnectUsingTCP;
  CodeSite.Destination.Viewer.Active := True;
  CodeSite.Category := 'WebGUI';
  //	CodeSite.CategoryColor:= $;
  CodeSite.Clear;
  {$ENDIF}
  {$IFDEF DEBUG}CodeSite.EnterMethod( Self, 'FormCreate' );{$ENDIF}
  Application.OnException := Self.AppException;
  lblPicCount.Caption := IntToStr(ParamCount)+' items';
  ServerLoadMRU;
  FOptions := TWebGUIOptions.Create(IncludeTrailingPathDelimiter(GetFolderPath(CSIDL_APPDATA))+'WebGUI\WebGUIUploadOptions.txt');
  Web := TWebHTTP.Create;
  {$IFDEF DEBUG}CodeSite.ExitMethod( Self, 'FormCreate' );{$ENDIF}
end;

procedure TfrmWebGUI.FormDestroy(Sender: TObject);
begin
  {$IFDEF DEBUG}CodeSite.EnterMethod( Self, 'FormDestroy' );{$ENDIF}
  FreeAndNil(FOptions);
  FreeAndNil(Web);
  FGalleryArray := nil;
  FAlbumArray := nil;
  RemoveTempDirectory;
  {$IFDEF DEBUG}CodeSite.ExitMethod( Self, 'FormDestroy' );{$ENDIF}
end;

/// <summary>
/// Delete the temp directory that Picasa exports the photos from
/// </summary>
procedure TfrmWebGUI.RemoveTempDirectory;
var
  sDir: string;
begin
  {$IFDEF DEBUG}CodeSite.EnterMethod( Self, 'RemoveTempDirectory' );{$ENDIF}
  sDir := ExtractFileDir(ParamStr(1));
  if DirectoryExists(sDir) then
    DeleteFullDirectory(sDir);
  {$IFDEF DEBUG}CodeSite.ExitMethod( Self, 'RemoveTempDirectory' );{$ENDIF}
end;

/// <summary>
/// Determine MRU path, load MRU file if found and set to first item if items found
/// </summary>
procedure TfrmWebGUI.ServerLoadMRU;
begin
  {$IFDEF DEBUG}CodeSite.EnterMethod( Self, 'ServerLoadMRU' );{$ENDIF}
  FMRUFile := GetFolderPath(CSIDL_APPDATA);
  {$IFDEF DEBUG} CodeSite.Send('FMRUFile',FMRUFile); {$ENDIF}
  if FMRUFile <> '' then
    begin
      FMRUFile := IncludeTrailingPathDelimiter(FMRUFile)+'WebGUI\WebGUIUpload.txt';
      {$IFDEF DEBUG} CodeSite.Send('FMRUFile',FMRUFile); {$ENDIF}
      if FileExists(FMRUFile) then
        begin
          cbbServer.Items.LoadFromFile(FMRUFile);
          if cbbServer.Items.Count > 0 then
            cbbServer.ItemIndex := 0;
        end;
    end
  else
    MessageBox(Handle, PChar(msgServerMRUError), PChar(Application.Title),
      MB_OK + MB_ICONWARNING);
  {$IFDEF DEBUG}CodeSite.ExitMethod( Self, 'ServerLoadMRU' );{$ENDIF}
end;

/// <summary>
/// Manages the server's MRU list. Adds current entry to list if not already there,
/// if already there, then move position up to the top.
/// </summary>
procedure TfrmWebGUI.ServerManageMRU;
var
  i: Integer;
begin
  i := cbbServer.ItemIndex;
  {$IFDEF DEBUG} CodeSite.Send('Server index',i); {$ENDIF}
  // if not in list and not in first position
  if (i > -1) and (i<>0) then
    begin
      cbbServer.Items.BeginUpdate;
      cbbServer.Items.Move(i,0);
      cbbServer.ItemIndex := 0;
      cbbServer.Items.EndUpdate;
    end
  else
    begin
      cbbServer.Items.BeginUpdate;
      cbbServer.Items.Insert(0,cbbServer.Text);
      cbbServer.ItemIndex := 0;
      cbbServer.Items.EndUpdate;
    end;
end;

/// <summary>
/// Saves the server list. If no entries then deletes the MRU files.
/// </summary>
procedure TfrmWebGUI.ServerSaveMRU;
begin
  {$IFDEF DEBUG}CodeSite.EnterMethod( Self, 'ServerSaveMRU' );{$ENDIF}
  {$IFDEF DEBUG} CodeSite.Send('FMRUFile',FMRUFile); {$ENDIF}
  if FMRUFile <> '' then
    begin
      {$IFDEF DEBUG} CodeSite.Send('cbbServer.Items.Count',cbbServer.Items.Count); {$ENDIF}
      if cbbServer.Items.Count = 0 then
        begin
          if FileExists(FMRUFile) then
            DeleteFile(FMRUFile);
        end
      else
        begin
          {$IFDEF DEBUG} CodeSite.Send('ExtractFileDir(FMRUFile)',ExtractFileDir(FMRUFile)); {$ENDIF}
          if ForceDirectories(ExtractFileDir(FMRUFile)) then
            cbbServer.Items.SaveToFile(FMRUFile);
        end;
    end;
  {$IFDEF DEBUG}CodeSite.ExitMethod( Self, 'ServerSaveMRU' );{$ENDIF}
end;

/// <summary>
/// Validate items required for "Export"
/// </summary>
/// <returns>Boolean - returns TRUE if validation successful</returns>
function TfrmWebGUI.UIValidateExport: Boolean;
var
  sVal : String;
begin
  {$IFDEF DEBUG}CodeSite.EnterMethod( Self, 'UIValidateExport' );{$ENDIF}
  sVal := '';
  if Trim(cbbServer.Text) = '' then
    sVal := sVal+#13#10+'*  WebGUI Server';

  if cbbGallery.ItemIndex = -1 then
    sVal := sVal+#13#10+'*  Gallery';

  if cbbAlbum.ItemIndex = -1 then
    sVal := sVal+#13#10+'*  Album';

  Result := sVal = '';
  if not Result then
    MessageBox(Handle, PChar(msgValidationError+sVal),
      PChar(Application.Title), MB_OK + MB_ICONSTOP);
  {$IFDEF DEBUG} CodeSite.Send('Result',Result); {$ENDIF}
  {$IFDEF DEBUG}CodeSite.ExitMethod( Self, 'UIValidateExport' );{$ENDIF}
end;

/// <summary>
/// Validate items required for "Load Gallery"
/// </summary>
/// <returns>Boolean - returns TRUE if validation successful</returns>
function TfrmWebGUI.UIValidateLoadGallery: Boolean;
var
  sVal : String;
begin
  {$IFDEF DEBUG}CodeSite.EnterMethod( Self, 'UIValidateLoadGallery' );{$ENDIF}
  sVal := '';
  if Trim(cbbServer.Text) = '' then
    sVal := sVal+#13#10+'*  WebGUI Server';

  if Trim(edtUser.Text) = '' then
    sVal := sVal+#13#10+'*  Username';

  if Trim(edtPwd.Text) = '' then
    sVal := sVal+#13#10+'*  Password';

  Result := sVal = '';
  if not Result then
    MessageBox(Handle, PChar(msgValidationError+sVal),
      PChar(Application.Title), MB_OK + MB_ICONSTOP);
  {$IFDEF DEBUG} CodeSite.Send('Result',Result); {$ENDIF}
  {$IFDEF DEBUG}CodeSite.ExitMethod( Self, 'UIValidateLoadGallery' );{$ENDIF}
end;

end.

