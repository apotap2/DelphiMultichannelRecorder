object ScriptEditor: TScriptEditor
  Left = 192
  Top = 126
  BorderStyle = bsDialog
  Caption = 'Javascript editor'
  ClientHeight = 398
  ClientWidth = 648
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
    Left = 192
    Top = 368
    Width = 156
    Height = 20
    Caption = 'Input data - inputData'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object ScriptMemo: TMemo
    Left = 8
    Top = 8
    Width = 633
    Height = 353
    Lines.Strings = (
      'ScriptMemo')
    TabOrder = 0
  end
  object Button1: TButton
    Left = 8
    Top = 368
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 96
    Top = 368
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = Button2Click
  end
end
