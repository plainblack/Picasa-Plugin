object frmOptions: TfrmOptions
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'Options'
  ClientHeight = 173
  ClientWidth = 428
  Color = clWindow
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  DesignSize = (
    428
    173)
  PixelsPerInch = 96
  TextHeight = 13
  object grpProxy: TGroupBox
    Left = 8
    Top = 8
    Width = 412
    Height = 105
    Caption = 'Proxy Information'
    TabOrder = 0
    object lblServer: TLabel
      Left = 56
      Top = 47
      Width = 32
      Height = 13
      Caption = 'Server'
      FocusControl = edtServer
    end
    object lblPort: TLabel
      Left = 56
      Top = 72
      Width = 20
      Height = 13
      Caption = 'Port'
      FocusControl = edtPort
    end
    object chkProxy: TCheckBox
      Left = 24
      Top = 24
      Width = 129
      Height = 17
      Caption = 'Use Proxy Server'
      TabOrder = 0
      OnClick = chkProxyClick
    end
    object edtServer: TEdit
      Left = 104
      Top = 44
      Width = 177
      Height = 21
      TabOrder = 1
    end
    object edtPort: TEdit
      Left = 104
      Top = 71
      Width = 73
      Height = 21
      NumbersOnly = True
      TabOrder = 2
    end
  end
  object btnSave: TButton
    Left = 256
    Top = 140
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    TabOrder = 1
    OnClick = btnSaveClick
  end
  object btnCancel: TButton
    Left = 345
    Top = 140
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
