object CalibrationChannelForm: TCalibrationChannelForm
  Left = 495
  Top = 355
  BorderStyle = bsDialog
  Caption = 'Channel calibration'
  ClientHeight = 118
  ClientWidth = 323
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
    Left = 24
    Top = 24
    Width = 28
    Height = 13
    Caption = 'Offset'
  end
  object Label2: TLabel
    Left = 184
    Top = 24
    Width = 40
    Height = 13
    Caption = 'multiplier'
  end
  object offset: TEdit
    Left = 24
    Top = 48
    Width = 121
    Height = 21
    TabOrder = 0
  end
  object multiplier: TEdit
    Left = 184
    Top = 48
    Width = 121
    Height = 21
    TabOrder = 1
  end
  object Button1: TButton
    Left = 24
    Top = 80
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 2
    OnClick = Button1Click
  end
end
