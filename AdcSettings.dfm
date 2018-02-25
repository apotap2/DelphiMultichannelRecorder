object AdcSettingsForm: TAdcSettingsForm
  Left = 432
  Top = 341
  Width = 338
  Height = 181
  Caption = 'ADC settings'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 161
    Height = 81
    Caption = 'Reference voltage, -'
    TabOrder = 0
    object Vss: TRadioButton
      Left = 16
      Top = 24
      Width = 113
      Height = 17
      Caption = 'Vss'
      TabOrder = 0
    end
    object VrefMinus: TRadioButton
      Left = 16
      Top = 48
      Width = 113
      Height = 17
      Caption = 'Vref-'
      TabOrder = 1
    end
  end
  object GroupBox2: TGroupBox
    Left = 176
    Top = 8
    Width = 146
    Height = 81
    Caption = 'reference voltage, +'
    TabOrder = 1
    object Vdd: TRadioButton
      Left = 8
      Top = 24
      Width = 113
      Height = 17
      Caption = 'Vdd'
      TabOrder = 0
    end
    object VRefPlus: TRadioButton
      Left = 8
      Top = 48
      Width = 113
      Height = 17
      Caption = 'Vref+'
      TabOrder = 1
    end
  end
  object Button1: TButton
    Left = 8
    Top = 104
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 2
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 96
    Top = 104
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 3
    OnClick = Button2Click
  end
end
