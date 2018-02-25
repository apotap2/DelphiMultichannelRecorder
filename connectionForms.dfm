object connectionForm: TconnectionForm
  Left = 447
  Top = 333
  BorderStyle = bsDialog
  Caption = 'Connecting'
  ClientHeight = 124
  ClientWidth = 276
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object ProgressBar1: TProgressBar
    Left = 24
    Top = 24
    Width = 233
    Height = 25
    TabOrder = 0
  end
  object BitBtn1: TBitBtn
    Left = 24
    Top = 64
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = BitBtn1Click
  end
  object StaticText1: TStaticText
    Left = 24
    Top = 96
    Width = 4
    Height = 4
    TabOrder = 2
  end
end
