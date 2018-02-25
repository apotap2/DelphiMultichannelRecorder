object WriteToExtEepromForm: TWriteToExtEepromForm
  Left = 327
  Top = 305
  Width = 423
  Height = 282
  Caption = 'Write to external eeprom'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 136
    Top = 24
    Width = 92
    Height = 13
    Caption = 'Interval, 79 ~ 1 sec'
  end
  object Button1: TButton
    Left = 8
    Top = 216
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 96
    Top = 216
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Channel1: TCheckBox
    Left = 8
    Top = 16
    Width = 97
    Height = 17
    Caption = 'Channel 1'
    TabOrder = 2
  end
  object Channel2: TCheckBox
    Left = 8
    Top = 48
    Width = 97
    Height = 17
    Caption = 'Channel 2'
    TabOrder = 3
  end
  object Channel3: TCheckBox
    Left = 8
    Top = 80
    Width = 97
    Height = 17
    Caption = 'Channel 3'
    TabOrder = 4
  end
  object Channel4: TCheckBox
    Left = 8
    Top = 112
    Width = 97
    Height = 17
    Caption = 'Channel 4'
    TabOrder = 5
  end
  object Channel5: TCheckBox
    Left = 8
    Top = 144
    Width = 97
    Height = 17
    Caption = 'Channel 5'
    TabOrder = 6
  end
  object IntervalEdit: TEdit
    Left = 136
    Top = 56
    Width = 145
    Height = 21
    TabOrder = 7
  end
  object writeMode: TComboBox
    Left = 136
    Top = 104
    Width = 145
    Height = 21
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 8
    Text = 'Write now?'
    Items.Strings = (
      'Write now?'
      'Write after power reset')
  end
end
