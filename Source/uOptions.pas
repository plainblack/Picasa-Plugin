unit uOptions;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,IniFiles;

type
  TWebGUIOptions = class
  private
    FFile : string; // file the stores the options
  public
    ProxyUse : Boolean;
    ProxyServer : string;
    ProxyPort : integer;
    constructor Create(OptionFile : string);
    procedure Save;
    procedure Load;
  end;

  TfrmOptions = class(TForm)
    grpProxy: TGroupBox;
    chkProxy: TCheckBox;
    lblServer: TLabel;
    edtServer: TEdit;
    lblPort: TLabel;
    edtPort: TEdit;
    btnSave: TButton;
    btnCancel: TButton;
    procedure chkProxyClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
  private
    procedure SetOptions(aOptions : TWebGUIOptions);
    procedure GetOptions(var aOptions : TWebGUIOptions);
    function ValidateOptions: Boolean;
  public
    function ShowModal(var aOptions : TWebGUIOptions) : integer; reintroduce;
  end;

var
  frmOptions: TfrmOptions;

implementation

{$R *.dfm}
/// <summary>
/// Validates the options before saving
/// </summary>
/// <returns>Boolean - returns true if options are valid</returns>
function TfrmOptions.ValidateOptions : Boolean;
begin
  Result := FALSE;
  if (chkProxy.Checked) then
    begin
      If (edtServer.Text = '') then
        MessageBox(Self.Handle,'Proxy server needs to be entered.',PChar(Application.Title),MB_OK)
      else
        if edtPort.Text = '' then
          MessageBox(Self.Handle,'Proxy port needs to be entered.',PChar(Application.Title),MB_OK)
        else
          Result := True;
    end
  else
    Result := TRUE;
end;

procedure TfrmOptions.btnSaveClick(Sender: TObject);
begin
  if ValidateOptions then
    ModalResult := mrOk;
end;

procedure TfrmOptions.chkProxyClick(Sender: TObject);
begin
  edtServer.Enabled := chkProxy.Checked;
  edtPort.Enabled := chkProxy.Checked;
  lblServer.Enabled := chkProxy.Checked;
  lblPort.Enabled := chkProxy.Checked;
end;

{ TWebGUIOptions }

constructor TWebGUIOptions.Create(OptionFile: string);
begin
  FFile := OptionFile;
  ProxyUse := FALSE;
  ProxyServer := '';
  ProxyPort := 80;
  Load;
end;

/// <summary>
/// Loads the Web GUI options from file
/// </summary>
procedure TWebGUIOptions.Load;
var
  OpIni : TIniFile;
begin
  if FileExists(FFile) then
    begin
      OpIni := TIniFile.Create(FFile);
      ProxyUse := OpIni.ReadBool('Proxy','Use',FALSE);
      ProxyServer := OpIni.ReadString('Proxy','Server','');
      ProxyPort := OpIni.ReadInteger('Proxy','Port',80);
      FreeAndNil(OpIni);
    end;
end;

/// <summary>
/// Saves the web gui options to file
/// </summary>
procedure TWebGUIOptions.Save;
var
  OpIni : TIniFile;
begin
  if not DirectoryExists(ExtractFileDir(FFile)) then
    ForceDirectories(ExtractFileDir(FFile));

  OpIni := TIniFile.Create(FFile);
  OpIni.WriteBool('Proxy','Use',ProxyUse);
  OpIni.WriteString('Proxy','Server',ProxyServer);
  OpIni.WriteInteger('Proxy','Port',ProxyPort);
  FreeAndNil(OpIni);
end;

/// <summary>
/// Transfers control values to the TWebGUIOptions object
/// </summary>
/// <param name="aOptions"> TWebGUIOptions </param>
procedure TfrmOptions.GetOptions(var aOptions: TWebGUIOptions);
begin
  aOptions.ProxyUse := chkProxy.Checked;
  aOptions.ProxyServer := edtServer.Text;
  aOptions.ProxyPort := StrToInt(edtPort.Text);
end;

/// <summary>
/// Sets the controls on the form to the items in TWebGUIOptions
/// </summary>
/// <param name="aOptions"> TWebGUIOptions </param>
procedure TfrmOptions.SetOptions(aOptions: TWebGUIOptions);
begin
  chkProxy.Checked := aOptions.ProxyUse;
  edtServer.Text := aOptions.ProxyServer;
  edtPort.Text := IntToStr(aOptions.ProxyPort);
  chkProxyClick(Self);
end;

/// <summary>
/// Displays the options screen
/// </summary>
/// <param name="aOptions"> TWebGUIOptions </param>
function TfrmOptions.ShowModal(var aOptions: TWebGUIOptions): integer;
begin
  SetOptions(aOptions);
  Result := inherited ShowModal;
  if Result = mrOk then
    begin
      GetOptions(aOptions);
      aOptions.Save;
    end;
end;

end.
