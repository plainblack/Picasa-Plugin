unit uAlbum;

interface

uses
  {$IFDEF DEBUG} CodeSiteLogging, {$ENDIF}
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, StdCtrls, Character;

type
  TfrmAlbum = class(TForm)
    lblAlbum: TLabel;
    btnCancel: TButton;
    pnlUpload: TPanel;
    edtAlbum: TEdit;
    btnCreate: TButton;
    chkAllow: TCheckBox;
    bhAlbum: TBalloonHint;
    procedure btnCreateClick(Sender: TObject);
    procedure edtAlbumKeyPress(Sender: TObject; var Key: Char);
  public
    function ShowModal(var Album : string; var AllowOthers : Boolean) : integer; reintroduce;
  end;

var
  frmAlbum: TfrmAlbum;

implementation

{$R *.dfm}

resourcestring
  msgAlbumCreateBlank = 'Enter an album name.';

procedure TfrmAlbum.btnCreateClick(Sender: TObject);
begin
  if Trim(edtAlbum.Text) = '' then
    begin
      MessageBox(Self.Handle,PChar(msgAlbumCreateBlank),PChar(Application.Title),MB_OK or MB_ICONERROR);
      edtAlbum.SetFocus;
    end
  else
    ModalResult := mrOk;
end;

/// <summary>
/// Displays the Create Album window. If "Create" is clicked, will return the album name
/// </summary>
/// <param name="Album"> var - Name of album to create </param>
/// <param name="AllowOthers"> var - if others are allowed to post </param>
procedure TfrmAlbum.edtAlbumKeyPress(Sender: TObject; var Key: Char);
var
  ptHint : TPoint;
begin
  if (not (
       (TCharacter.IsLetterOrDigit(Key)) or
       (CharInSet(Key,[' ',',','-','_'])) or
       (TCharacter.IsControl(Key)))) then
    begin
      {$IFDEF DEBUG} CodeSite.Send('Key',Key); {$ENDIF}
      Key := #0;
      ptHint := edtAlbum.ClientOrigin;
      ptHint.Y := ptHint.Y+edtAlbum.ClientHeight;
      ptHint.X := ptHint.X+(edtAlbum.ClientWidth div 2);
      bhAlbum.ShowHint(ptHint);
    end
  else
    if bhAlbum.ShowingHint then
      bhAlbum.HideHint;
end;

/// <summary>
/// Displays the create album screen
/// </summary>
/// <param name="Album"> var - Name of album </param>
/// <param name="AllowOthers"> var - Allow other to post </param>
/// <returns>integer - modal integer result</returns>
function TfrmAlbum.ShowModal(var Album : string; var AllowOthers : Boolean): integer;
begin
  bhAlbum.Title := 'Invalid Character';
  bhAlbum.Description := 'Albums can only contain the characters:'+Chr(13)+'A..Z, 0..9, space, comma, dash, or underscore'+Chr(13);

  Result := inherited ShowModal;
  if Result = mrOk then
    begin
      Album := edtAlbum.Text;
      AllowOthers := chkAllow.Checked;
    end
  else
    Album := '';
end;

end.
