object frmUpload: TfrmUpload
  Left = 0
  Top = 0
  BorderStyle = bsNone
  ClientHeight = 101
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
    Height = 101
    Align = alClient
    BevelInner = bvRaised
    BevelKind = bkTile
    BevelOuter = bvNone
    TabOrder = 0
    object lblUpload: TLabel
      Left = 24
      Top = 8
      Width = 68
      Height = 16
      Caption = 'Uploading...'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lblProgress: TLabel
      Left = 24
      Top = 30
      Width = 3
      Height = 13
    end
    object pbUpload: TProgressBar
      Left = 24
      Top = 60
      Width = 313
      Height = 17
      Position = 40
      Step = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 343
      Top = 56
      Width = 75
      Height = 25
      Caption = '&Cancel'
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
end
