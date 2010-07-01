object frmAlbum: TfrmAlbum
  Left = 0
  Top = 0
  BorderStyle = bsNone
  ClientHeight = 120
  ClientWidth = 434
  Color = clWindow
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object pnlUpload: TPanel
    Left = 0
    Top = 0
    Width = 434
    Height = 120
    Align = alClient
    BevelInner = bvRaised
    BevelKind = bkTile
    BevelOuter = bvNone
    TabOrder = 0
    object lblAlbum: TLabel
      Left = 16
      Top = 22
      Width = 29
      Height = 13
      Caption = 'Album'
    end
    object btnCancel: TButton
      Left = 263
      Top = 80
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 3
    end
    object edtAlbum: TEdit
      Left = 51
      Top = 19
      Width = 368
      Height = 21
      Hint = 'testing123'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnKeyPress = edtAlbumKeyPress
    end
    object btnCreate: TButton
      Left = 344
      Top = 80
      Width = 75
      Height = 25
      Caption = '&Create'
      Default = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      OnClick = btnCreateClick
    end
    object chkAllow: TCheckBox
      Left = 51
      Top = 46
      Width = 254
      Height = 17
      Caption = 'Allow others to add images'
      Color = clWindow
      ParentColor = False
      TabOrder = 1
    end
  end
  object bhAlbum: TBalloonHint
    Left = 64
    Top = 80
  end
end
