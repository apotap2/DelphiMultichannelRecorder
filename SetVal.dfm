object SetValForm: TSetValForm
  Left = 381
  Top = 395
  Width = 298
  Height = 152
  Caption = 'Set'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object valDescr: TLabel
    Left = 8
    Top = 16
    Width = 27
    Height = 13
    Caption = 'Value'
  end
  object Button1: TButton
    Left = 8
    Top = 80
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 96
    Top = 80
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = Button2Click
  end
  object valEdit: TEdit
    Left = 8
    Top = 40
    Width = 121
    Height = 21
    TabOrder = 2
  end
end
