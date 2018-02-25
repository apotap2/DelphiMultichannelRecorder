object SetPinForm: TSetPinForm
  Left = 217
  Top = 273
  Width = 319
  Height = 149
  Caption = 'Set digital output'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object pinChoose: TComboBox
    Left = 16
    Top = 24
    Width = 145
    Height = 21
    ItemHeight = 13
    TabOrder = 0
  end
  object digitalVal: TComboBox
    Left = 176
    Top = 24
    Width = 49
    Height = 21
    ItemHeight = 13
    TabOrder = 1
    Text = '0'
    Items.Strings = (
      '0'
      '1')
  end
  object Button1: TButton
    Left = 16
    Top = 72
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 2
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 112
    Top = 72
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 3
    OnClick = Button2Click
  end
end
