unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Chart,
  Menus, TeePolar, ComCtrls, EmulatorDevice, BaseDevice, Engine, mainGui, SetNewValForm, CalibrationForm,
  connectionForms, scriptForm;

type
  TMainProgramForm = class(TForm, IMainGui)
    MainMenu1: TMainMenu;
    selectDeviceMenu: TMenuItem;
    commands: TMenuItem;
    StatusBar1: TStatusBar;
    ChannelsSettings: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N2: TMenuItem;
    N1: TMenuItem;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure N6Click(Sender: TObject);

    procedure N1Click(Sender: TObject);

    procedure Timer1Timer(Sender: TObject);

  private
    { Private declarations }
    engine : TEngine;
    connectionForm : TConnectionForm;
  private
    { Public declarations }
    procedure ChooseDevice(Sender: TObject);
    procedure ChangeChannelName(Sender: TObject);
    procedure ChangeChannelWidth(Sender: TObject);
    procedure ChangeChannelColor(Sender: TObject);
    procedure ChangeCalibrationToMultiplierOffset(Sender: TObject);
    procedure ChangeCalibrationToSheet(Sender: TObject);
    procedure ChangeCalibrationToScript(Sender: TObject);
    procedure CancelConnection(Sender: TObject);
    procedure CommandClicked(Sender: TObject);

    procedure FormResize(Sender: TObject);
  public

    // IMainGui
    procedure RedrawRecorders;
    function GetForm() : TForm;
    procedure UpdateMenus;
    procedure ShowConnectionForm;
    procedure HideConnectionForm;
    procedure SetConnectionProgress(progress : integer);
    procedure ShowConnectionStatusMessage(message : string);
    procedure ShowStatusText(status : string);

  end;

var
  MainProgramForm: TMainProgramForm;

implementation

{$R *.dfm}

procedure TMainProgramForm.FormCreate(Sender: TObject);
var i: integer;
var menuItem: TMenuItem;
begin
  engine := TEngine.Create(self);
  connectionForm := TConnectionForm.Create(self);
  connectionForm.OnCancelConnection := CancelConnection;
  OnResize := FormResize;

  for i := 0 to engine.GetDevicesNumber -1 do
  begin
    menuItem := TMenuItem.Create(self);
    menuItem.Caption := engine.GetDeviceName(i);
    menuItem.Tag := i;
    menuItem.OnClick := ChooseDevice;
    selectDeviceMenu.Add(menuItem);
  end;

end;

procedure TMainProgramForm.N6Click(Sender: TObject);
begin
  MessageBox(0, 'One day here will be better description', 'Blank', 0);
end;

procedure TMainProgramForm.ChooseDevice(Sender: TObject);
var deviceIndex : integer;
begin
  deviceIndex := (TMenuItem(Sender)).Tag;
  engine.ChooseDevice(deviceIndex);
end;

procedure TMainProgramForm.N1Click(Sender: TObject);
begin
  engine.AddNewRecorder;
end;

procedure TMainProgramForm.FormResize(Sender: TObject);
begin
  RedrawRecorders;
end;

procedure TMainProgramForm.RedrawRecorders;
var i : integer;
var chartHeight : integer;
var chartWidth : integer;
begin
  if (engine.GetRecordersNumber = 0) then
    exit;
  chartHeight := (ClientHeight - StatusBar1.Height) div engine.GetRecordersNumber;
  chartWidth := ClientWidth;

  for i := 0 to engine.GetRecordersNumber -1 do
  begin
    engine.GetRecorder(i).GetRecorderControl.Left := 0;
    engine.GetRecorder(i).GetRecorderControl.Top := chartHeight * i;
    engine.GetRecorder(i).GetRecorderControl.Width := chartWidth;
    engine.GetRecorder(i).GetRecorderControl.Height := chartHeight;
  end
end;

function TMainProgramForm.GetForm: TForm;
begin
  Result := self;
end;

procedure TMainProgramForm.UpdateMenus;
var i: integer;
var menuItem: TMenuItem;
var channelMenuSubitem : TMenuItem;
var calibrationMenuSubitem : TMenuItem;
begin
  ChannelsSettings.Clear;

  if (not engine.IsDeviceSelected) then
  begin
    exit;
  end;

  for i := 0 to engine.GetInputLinesNumber -1 do
  begin
    menuItem := TMenuItem.Create(self);
    menuItem.Caption := engine.GetInputLineName(i);

    channelMenuSubitem := TMenuItem.Create(self);
    channelMenuSubitem.Caption := 'Change channel name';
    channelMenuSubitem.Tag := i;
    channelMenuSubitem.OnClick := ChangeChannelName;
    menuItem.Add(channelMenuSubitem);

    channelMenuSubitem := TMenuItem.Create(self);
    channelMenuSubitem.Caption := 'Change line width';
    channelMenuSubitem.Tag := i;
    channelMenuSubitem.OnClick := ChangeChannelWidth;
    menuItem.Add(channelMenuSubitem);

    channelMenuSubitem := TMenuItem.Create(self);
    channelMenuSubitem.Caption := 'Change color';
    channelMenuSubitem.Tag := i;
    channelMenuSubitem.OnClick := ChangeChannelColor;
    menuItem.Add(channelMenuSubitem);

    channelMenuSubitem := TMenuItem.Create(self);
    channelMenuSubitem.Caption := 'Change calibration';
    menuItem.Add(channelMenuSubitem);

    calibrationMenuSubitem := TMenuItem.Create(self);
    calibrationMenuSubitem.Caption := 'Offset, multiplier';
    calibrationMenuSubitem.Tag := i;
    calibrationMenuSubitem.OnClick := ChangeCalibrationToMultiplierOffset;
    channelMenuSubitem.Add(calibrationMenuSubitem);

    calibrationMenuSubitem := TMenuItem.Create(self);
    calibrationMenuSubitem.Caption := 'Mapping';
    calibrationMenuSubitem.Tag := i;
    calibrationMenuSubitem.OnClick := ChangeCalibrationToSheet;
    channelMenuSubitem.Add(calibrationMenuSubitem);

    calibrationMenuSubitem := TMenuItem.Create(self);
    calibrationMenuSubitem.Caption := 'JScript';
    calibrationMenuSubitem.Tag := i;
    calibrationMenuSubitem.OnClick := ChangeCalibrationToScript;
    channelMenuSubitem.Add(calibrationMenuSubitem);

    ChannelsSettings.Add(menuItem);
  end;

  commands.Clear;
  for i := 0 to engine.GetCommandsNumber -1 do
  begin
    menuItem := TMenuItem.Create(self);
    menuItem.Caption := engine.GetCommandName(i);
    menuItem.Tag := i;
    menuItem.OnClick := CommandClicked;
    commands.Add(menuItem);
  end;
end;

procedure TMainProgramForm.ChangeChannelName(Sender: TObject);
var setNameForm : TNewValForm;
var inputLineIndex : integer;
begin
  setNameForm := TNewValForm.Create(self);
  inputLineIndex := (TMenuItem(Sender)).Tag;
  setNameForm.SetPreviousVal(engine.GetInputLineName(inputLineIndex));
  setNameForm.ShowModal;
  if (setNameForm.GetNewVal <> '') then
  begin
    engine.ChangeChannelName(inputLineIndex, setNameForm.GetNewVal);
  end;
end;

procedure TMainProgramForm.ChangeChannelWidth(Sender: TObject);
var setWidthForm : TNewValForm;
var inputLineIndex : integer;
var newWidth : integer;
begin
  try
  setWidthForm := TNewValForm.Create(self);
  setWidthForm.Caption := 'Set line width';
  inputLineIndex := (TMenuItem(Sender)).Tag;
  setWidthForm.SetPreviousVal(IntToStr(engine.GetInputLineGraphWidth(inputLineIndex)));
  setWidthForm.ShowModal;
  if (setWidthForm.GetNewVal <> '') then
  begin
    newWidth := StrToInt(setWidthForm.GetNewVal);
    engine.SetInputLineGraphWidth(inputLineIndex, newWidth);
  end;
  except
  on Exception : EConvertError do
    exit
  end;
end;

procedure TMainProgramForm.ChangeChannelColor(Sender: TObject);
var inputLineIndex : integer;
var colorDialog : TColorDialog;
begin
  inputLineIndex := (TMenuItem(Sender)).Tag;
  colorDialog := TColorDialog.Create(self);

  if colorDialog.Execute then
    engine.SetInputLineGraphColor(inputLineIndex, colorDialog.Color);
  begin
  end;
end;

procedure TMainProgramForm.Timer1Timer(Sender: TObject);
begin
  if Assigned(engine) then
    engine.CheckIfHasData;
end;

procedure TMainProgramForm.ChangeCalibrationToMultiplierOffset(Sender: TObject);
var calibrationForm : TCalibrationChannelForm;
var inputLineIndex : integer;
var offset, multiplier : double;
begin
  try
    inputLineIndex := (TMenuItem(Sender)).Tag;
    calibrationForm := TCalibrationChannelForm.Create(self);
    calibrationForm.offset.Text := FloatToStr(engine.GetCalibrationOffset(inputLineIndex));
    calibrationForm.multiplier.Text := FloatToStr(engine.GetCalibrationMultiplier(inputLineIndex));

    if (calibrationForm.ShowModal = MrYes) then
    begin
      offset := StrToFloat(calibrationForm.offset.Text);
      multiplier := StrToFloat(calibrationForm.multiplier.Text);

      engine.SetCalibrationOffsetAndMultiplier(inputLineIndex, offset, multiplier);
    end;
  except
  on Exception : EConvertError do
    exit
  end;
end;

procedure TMainProgramForm.ShowConnectionForm;
begin
  connectionForm.SetProgress(0);
  connectionForm.SetConnectionStatusMessage('');
  connectionForm.Show;
end;

procedure TMainProgramForm.HideConnectionForm;
begin
  connectionForm.Hide;
end;

procedure TMainProgramForm.SetConnectionProgress(progress: integer);
begin
  connectionForm.SetProgress(progress);
end;

procedure TMainProgramForm.ShowConnectionStatusMessage(message: string);
begin
  connectionForm.SetConnectionStatusMessage(message);
end;

procedure TMainProgramForm.CancelConnection(Sender: TObject);
begin
  engine.CancelConnection;
end;

procedure TMainProgramForm.ChangeCalibrationToSheet(Sender: TObject);
var
  inputLineIndex : integer;
  openDialog : TOpenDialog;
begin
  inputLineIndex := (TMenuItem(Sender)).Tag;
  openDialog := TOpenDialog.Create(self);
  openDialog.Title := 'Load mapping file';
  if openDialog.Execute then
  begin
    engine.LoadSheetFromFile(inputLineIndex, openDialog.FileName);
  end;
end;

procedure TMainProgramForm.ChangeCalibrationToScript(Sender: TObject);
var inputLineIndex : integer;
var scriptForm : TScriptEditor;
begin
  inputLineIndex := (TMenuItem(Sender)).Tag;
  scriptForm := TScriptEditor.Create(self);
  scriptForm.ScriptMemo.Text := engine.GetScriptText(inputLineIndex);
  if (scriptForm.ShowModal = MrYes) then
  begin
    engine.SetScriptText(inputLineIndex, scriptForm.ScriptMemo.Text);
  end;
end;

procedure TMainProgramForm.ShowStatusText(status: string);
begin
  StatusBar1.SimpleText := status;
end;

procedure TMainProgramForm.CommandClicked(Sender: TObject);
var commandIndex : integer;
begin
  commandIndex := (TMenuItem(Sender)).Tag;
  engine.CommandClicked(commandIndex);
end;

end.

