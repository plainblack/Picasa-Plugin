unit uUpload;

interface

uses
  {$IFDEF DEBUG} CodeSiteLogging, {$ENDIF}
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, StdCtrls, uOptions, uHTTP;

type
  TfrmUpload = class;

  TUploadThread = class(TThread)
  private
    FIdx : integer;
    FWeb : TWebHTTP;
    FAlbum : string;
    FAlbumURL : string;
    FUserID : string;
    FPwd : string;
    FOptions : TWebGUIOptions;
    FParent : TfrmUpload;
    procedure UpdateGUI;
  protected
    procedure Execute; override;
  public
    ErrorMessage : string;
    constructor Create(aParent : TfrmUpload; const aAlbum, aAlbumURL,aUser,aPwd : string; aOptions : TWebGUIOptions);
  end;

  TfrmUpload = class(TForm)
    lblUpload: TLabel;
    lblProgress: TLabel;
    btnCancel: TButton;
    pbUpload: TProgressBar;
    pnlUpload: TPanel;
    procedure btnCancelClick(Sender: TObject);
  private
    UploadThread : TUploadThread;
    FAlbum : string;
    procedure ThreadCompleted(var Msg : TMessage); message WM_USER+14;
    procedure CloseUploadThread(ByThread : Boolean);
  public
    function ShowModal(const aAlbum, aAlbumURL,aUser,aPwd : string; aOption : TWebGUIOptions) : integer; reintroduce;
  end;

var
  frmUpload: TfrmUpload;

implementation

{$R *.dfm}

procedure TfrmUpload.btnCancelClick(Sender: TObject);
begin
  {$IFDEF DEBUG}CodeSite.EnterMethod( Self, 'btnCancelClick' );{$ENDIF}
  CloseUploadThread(FALSE);
  Self.ModalResult := mrCancel;
  {$IFDEF DEBUG}CodeSite.ExitMethod( Self, 'btnCancelClick' );{$ENDIF}
end;

/// <summary>
/// Terminates and frees the upload thread if it is assigned
/// </summary>
/// <param name="ByThread"> If UpdateThread was terminated by the thread itself </param>
procedure TfrmUpload.CloseUploadThread(ByThread : Boolean);
begin
  {$IFDEF DEBUG}CodeSite.EnterMethod( Self, 'CloseUploadThread' );{$ENDIF}
  if Assigned(UploadThread) then
    begin
      UploadThread.Terminate;
      UploadThread.WaitFor;
      Screen.Cursor := crDefault;
      if (ByThread) then
        begin
          If (UploadThread.ErrorMessage <> '') then
            MessageBox(Application.Handle,PChar('Error while uploading pictures.'+#13#10+UploadThread.ErrorMessage),
               PChar(Application.Title), MB_OK+MB_ICONSTOP)
          else
            MessageBox(Application.Handle,PChar('Uploaded '+IntToStr(ParamCount)+' pictures to '+FAlbum),
               PChar(Application.Title), MB_OK);
        end;
      FreeAndNil(UploadThread);
    end;
  {$IFDEF DEBUG}CodeSite.ExitMethod( Self, 'CloseUploadThread' );{$ENDIF}
end;

/// <summary>
/// Displays the upload form modally
/// </summary>
/// <param name="aAlbum"> Name of the album </param>
/// <param name="aAlbumURL"> URL to the album </param>
/// <param name="aOption"> Options </param>
/// <returns>integer - result of the showmodal</returns>
function TfrmUpload.ShowModal(const aAlbum, aAlbumURL,aUser,aPwd : string; aOption: TWebGUIOptions): integer;
begin
  {$IFDEF DEBUG}CodeSite.EnterMethod( Self, 'ShowModal' );{$ENDIF}
  pbUpload.Position := 0;
  pbUpload.Max := ParamCount;
  FAlbum := aAlbum;
  UploadThread := TUploadThread.Create(Self,aAlbum, aAlbumURL,aUser,aPwd,aOption);
  Result := inherited ShowModal;
  {$IFDEF DEBUG}CodeSite.ExitMethod( Self, 'ShowModal' );{$ENDIF}
end;

/// <summary>
/// Called when the uploadthread has completed
/// </summary>
/// <param name="Msg"> Message </param>
procedure TfrmUpload.ThreadCompleted(var Msg: TMessage);
begin
  {$IFDEF DEBUG}CodeSite.EnterMethod( Self, 'ThreadCompleted' );{$ENDIF}
  CloseUploadThread(True);
  ModalResult := mrOk;
  {$IFDEF DEBUG}CodeSite.ExitMethod( Self, 'ThreadCompleted' );{$ENDIF}
end;

{ TUploadThread }
/// <summary>
/// Creates the thread that uploads the pictures
/// </summary>
/// <param name="aParent"> Upload Form that calls the thread </param>
/// <param name="aAlbum"> Name of the album </param>
/// <param name="aAlbumURL"> URL to the album </param>
/// <param name="aUser"> User ID </param>
/// <param name="aPwd"> Password </param>
/// <param name="aOption"> Options </param>
constructor TUploadThread.Create(aParent : TfrmUpload; const aAlbum, aAlbumURL,aUser,aPwd : string; aOptions: TWebGUIOptions);
begin
  {$IFDEF DEBUG}CodeSite.EnterMethod( Self, 'Create' );{$ENDIF}
  inherited Create(True);
  FParent := aParent;
  FOptions := aOptions;
  FUserID := aUser;
  FPwd := aPwd;
  FAlbum := aAlbum;
  FAlbumURL := aAlbumURL;
  FWeb := TWebHTTP.Create;
  Resume;
  {$IFDEF DEBUG}CodeSite.ExitMethod( Self, 'Create' );{$ENDIF}
end;

procedure TUploadThread.Execute;
const
  RetryMax = 2;
var
  Retry : integer;
  Res : Boolean;
begin
  {$IFDEF DEBUG}CodeSite.EnterMethod( Self, 'Execute' );{$ENDIF}
  inherited;
  FIdx := 1;
  ErrorMessage := '';
  Retry := 0;
  {$IFDEF DEBUG} CodeSite.Send('ParamCount',ParamCount); {$ENDIF}
  while (not Self.Terminated) and (FIdx <= ParamCount) do
    begin
      {$IFDEF DEBUG} CodeSite.Send('FIdx',FIdx); {$ENDIF}
      Synchronize(UpdateGUI);
      try
        Res := FWeb.PostPicture(FAlbumURL,FUserID,FPwd,ParamStr(FIdx),FOptions);
      except
        on e : Exception do
        	begin
        	  {$IFDEF DEBUG} CodeSite.SendException(e); {$ENDIF}
        		Res := FALSE;
            ErrorMessage := e.Message;
        	end;
      end;

      if not Res then
        begin
          if Retry < RetryMax then
            Inc(Retry)
          else
            Break; // break out of while loop if retry limit is reached.
        end
      else
        begin
          Inc(FIdx);
          Retry := 0;
          ErrorMessage := '';
        end;

    end;

  FUserID := '';
  FPwd := '';

  FreeAndNil(FWeb);
  if not Self.Terminated then
    PostMessage(FParent.Handle,WM_User+14,0,0);
  {$IFDEF DEBUG}CodeSite.ExitMethod( Self, 'Execute' );{$ENDIF}
end;

/// <summary>
/// Updates the form's label and progress
/// </summary>
procedure TUploadThread.UpdateGUI;
const
  ProgressTxt = 'Image %d of %d to %s';
begin
  {$IFDEF DEBUG}CodeSite.EnterMethod( Self, 'UpdateGUI' );{$ENDIF}
  FParent.lblProgress.Caption := Format(ProgressTxt,[FIdx,ParamCount,FAlbum]);
  FParent.pbUpload.Position := FIdx;
  {$IFDEF DEBUG}CodeSite.ExitMethod( Self, 'UpdateGUI' );{$ENDIF}
end;

end.

