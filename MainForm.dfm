object MainProgramForm: TMainProgramForm
  Left = 253
  Top = 44
  Width = 1139
  Height = 826
  Caption = 'Multichannel recorder'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar1: TStatusBar
    Left = 0
    Top = 748
    Width = 1123
    Height = 19
    Panels = <>
  end
  object MainMenu1: TMainMenu
    Left = 16
    Top = 8
    object selectDeviceMenu: TMenuItem
      Caption = 'Select device'
    end
    object N2: TMenuItem
      Caption = 'Recorders'
      object N1: TMenuItem
        Caption = 'Add new recorder'
        OnClick = N1Click
      end
    end
    object commands: TMenuItem
      Caption = 'Commands'
    end
    object ChannelsSettings: TMenuItem
      Caption = 'Channel settings'
    end
    object N5: TMenuItem
      Caption = 'Help'
      object N6: TMenuItem
        Caption = 'About program'
        OnClick = N6Click
      end
      object N7: TMenuItem
        Caption = 'About device'
      end
    end
  end
  object Timer1: TTimer
    Interval = 100
    OnTimer = Timer1Timer
    Left = 72
    Top = 32
  end
end
