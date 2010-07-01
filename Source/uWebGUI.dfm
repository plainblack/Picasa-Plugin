object frmWebGUI: TfrmWebGUI
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'WebGUI Photo Upload'
  ClientHeight = 392
  ClientWidth = 561
  Color = clWindow
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    561
    392)
  PixelsPerInch = 96
  TextHeight = 13
  object lblPicCount: TLabel
    Left = 105
    Top = 364
    Width = 34
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = '0 items'
  end
  object pnlGUI: TPanel
    Left = 8
    Top = 8
    Width = 545
    Height = 337
    BevelInner = bvLowered
    BevelKind = bkFlat
    BevelOuter = bvNone
    TabOrder = 0
    object lblUser: TLabel
      Left = 43
      Top = 96
      Width = 48
      Height = 13
      Caption = 'Username'
    end
    object lblServer: TLabel
      Left = 16
      Top = 24
      Width = 75
      Height = 13
      Caption = 'WebGUI Server'
    end
    object lblPwd: TLabel
      Left = 45
      Top = 123
      Width = 46
      Height = 13
      Caption = 'Password'
    end
    object lblGallery: TLabel
      Left = 58
      Top = 197
      Width = 33
      Height = 13
      Caption = 'Gallery'
    end
    object lblAlbum: TLabel
      Left = 62
      Top = 264
      Width = 29
      Height = 13
      Caption = 'Album'
    end
    object edtUser: TEdit
      Left = 97
      Top = 93
      Width = 185
      Height = 21
      TabOrder = 3
    end
    object edtPwd: TEdit
      Left = 97
      Top = 120
      Width = 185
      Height = 21
      PasswordChar = '*'
      TabOrder = 4
    end
    object cbbServer: TComboBox
      Left = 97
      Top = 21
      Width = 418
      Height = 21
      ItemHeight = 13
      TabOrder = 0
      OnSelect = cbbServerSelect
    end
    object cbbGallery: TComboBox
      Left = 97
      Top = 194
      Width = 418
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 6
      OnSelect = cbbGallerySelect
    end
    object cbbAlbum: TComboBox
      Left = 97
      Top = 261
      Width = 418
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 8
    end
    object btnServerView: TButton
      Left = 97
      Top = 48
      Width = 88
      Height = 25
      Caption = 'View &Server'
      TabOrder = 1
      OnClick = btnServerViewClick
    end
    object btnAlbumCreate: TButton
      Left = 191
      Top = 288
      Width = 122
      Height = 25
      Caption = 'Create &New Album'
      TabOrder = 10
      OnClick = btnAlbumCreateClick
    end
    object btnAlbumView: TButton
      Left = 97
      Top = 288
      Width = 88
      Height = 25
      Caption = 'View &Album'
      TabOrder = 9
      OnClick = btnAlbumViewClick
    end
    object btnGalleryLoad: TButton
      Left = 97
      Top = 147
      Width = 88
      Height = 25
      Caption = '&Load Galleries'
      TabOrder = 5
      OnClick = btnGalleryLoadClick
    end
    object btnGalleryView: TButton
      Left = 97
      Top = 221
      Width = 88
      Height = 25
      Caption = 'View &Gallery'
      TabOrder = 7
      OnClick = btnGalleryViewClick
    end
    object btnServerRemove: TButton
      Left = 191
      Top = 48
      Width = 135
      Height = 25
      Caption = '&Remove Server from List'
      TabOrder = 2
      OnClick = btnServerRemoveClick
    end
  end
  object btnCancel: TButton
    Left = 392
    Top = 359
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    TabOrder = 2
    OnClick = btnCancelClick
  end
  object btnExport: TButton
    Left = 478
    Top = 359
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Export'
    Default = True
    TabOrder = 1
    OnClick = btnExportClick
  end
  object btnOptions: TButton
    Left = 8
    Top = 359
    Width = 75
    Height = 25
    Caption = '&Options'
    TabOrder = 3
    OnClick = btnOptionsClick
  end
end
