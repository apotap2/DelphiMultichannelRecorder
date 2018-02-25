object Form1: TForm1
  Left = 245
  Top = 14
  Width = 1139
  Height = 826
  Caption = 'Form1'
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
  object Chart1: TChart
    Left = 40
    Top = 40
    Width = 1041
    Height = 225
    BackWall.Brush.Color = clWhite
    BackWall.Brush.Style = bsClear
    Legend.Visible = False
    Title.Text.Strings = (
      'Recorder')
    View3D = False
    TabOrder = 0
    object Series1: TLineSeries
      Marks.Arrow.Visible = True
      Marks.Callout.Brush.Color = clBlack
      Marks.Callout.Arrow.Visible = True
      Marks.Visible = False
      Title = 'y(x) = sin(x)'
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      Pointer.Visible = False
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
  end
  object BitBtn1: TBitBtn
    Left = 8
    Top = 728
    Width = 75
    Height = 25
    Caption = 'BitBtn1'
    TabOrder = 1
    OnClick = BitBtn1Click
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 753
    Width = 1106
    Height = 19
    Panels = <>
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 96
    Top = 728
  end
  object MainMenu1: TMainMenu
    Left = 16
    Top = 8
    object N1: TMenuItem
      Caption = 'File'
    end
    object Help1: TMenuItem
      Caption = 'Help'
    end
  end
end
