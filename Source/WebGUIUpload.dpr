program WebGUIUpload;

uses
  Windows,
  Forms,
  uWebGUI in 'uWebGUI.pas' {frmWebGUI},
  uUpload in 'uUpload.pas' {frmUpload},
  uAlbum in 'uAlbum.pas' {frmAlbum},
  uFuncs in 'uFuncs.pas',
  uOptions in 'uOptions.pas' {frmOptions},
  uHTTP in 'uHTTP.pas';

{$R *.res}
resourcestring
  msgNoPictures = 'No pictures supplied. Program cannot continue.';

begin
  // if there are no parameters (no pictures) then display error message and exit.
  if ParamCount = 0 then
    MessageBox(0, PChar(msgNoPictures),
      PChar('WebGUI Photo Upload'), MB_OK + MB_ICONSTOP)
  else
    begin
      Application.Initialize;
      Application.MainFormOnTaskbar := True;
      Application.Title := 'WebGUI Photo Upload';
      Application.CreateForm(TfrmWebGUI, frmWebGUI);
  Application.Run;
    end;
end.
