unit Engine;
// "engine" of all application.
// It works in the main gui thread. Main logic is here, time to time it checks
// if there are commands to do (look into commands in BaseDevice.pas)
// 
// Device will create an interrogation thread and produce data, the engine will
// get use this data to show in gui.
//
// Commands can have gui and interrogation parts, so they need to be processed in
// both threads (interrogation and gui).
//
// Currently there are 2 hardcoded devices - "emulator" and "simple usb device".


interface

uses inputLine, Recorder, Classes, EmulatorDevice, SimpleUsbDevice, BaseDevice, Forms, Windows, MainGui, DeviceWrapper, Graphics,
      ExtCtrls, SysUtils, Controls;

type

TEngine = class(TInterfacedObject, IConnectionCallback)
public
  Constructor Create(gui : IMainGui);

  function GetRecordersNumber() : integer;
  function GetRecorder(recorderIndex : integer) : TRecorder;

  function GetDevicesNumber() : integer;
  function GetDeviceName(deviceIndex : integer) : string;

  procedure ChooseDevice(deviceIndex : integer);

  procedure AddNewRecorder();

  function IsDeviceSelected() : boolean;

  procedure ChangeChannelName(channelIndex : integer; newName : string);
  function GetInputLinesNumber : integer;
  function GetInputLineName(inputLineIndex : integer) : string;

  function GetCommandsNumber : integer;
  function GetCommandName(commandIndex : integer) : string;
  procedure CommandClicked(commandIndex : integer);

  function GetInputLineGraphWidth(inputLineIndex : integer) : integer;
  procedure SetInputLineGraphWidth(inputLineIndex : integer; newWidth : integer);

  function GetInputLineGraphColor(inputLineIndex : integer) : TColor;
  procedure SetInputLineGraphColor(inputLineIndex : integer; newColor : TColor);

  procedure CheckIfHasData;

  function GetCalibrationOffset(inputLineIndex : integer) : double;
  function GetCalibrationMultiplier(inputLineIndex : integer) : double;

  procedure SetCalibrationOffsetAndMultiplier(inputLineIndex : integer; offset, multiplier : double);

  function GetScriptText(inputLineIndex : integer) : string;
  procedure SetScriptText(inputLineIndex : integer; scriptText : string);

  procedure Disconnect;
  procedure CancelConnection;

  procedure LoadSheetFromFile(inputLineIndex : integer; filePath : string);
  
  // IConnectionCallback
  procedure OnConnected;
  procedure OnConnectionStatusMessage(message: string);
  procedure OnConnectionProgress(percent: integer);
  procedure OnDisconnected;
  procedure OnErrorOnConnection;
  
private
  recorders : TList;

  currentDevice : TDevice;
  devicesList : TList;

  mainGui : IMainGui;
  reconnectOnDisconnect : boolean;
  connectOnTick : integer;
  timer : TTimer;

  procedure OnTimer(Sender: TObject);
  procedure DeleteAllRecorders;
  procedure RequestFromRecorderToDelete(Sender: TObject);
end;

implementation

{ TEngine }

const maxChartsWhenDisconnected = 1;
const maxChartsWhenConnected = 10;


procedure TEngine.AddNewRecorder;
var recorder : TRecorder;
begin
  if (Assigned(currentDevice) and currentDevice.IsConnected) then
  begin
    if (recorders.Count =  maxChartsWhenConnected) then
      exit;
    recorder := TRecorder.Create(currentDevice);
    recorder.CreateRecorderControl(mainGui.GetForm);
    recorder.GetRecorderControl.Parent := mainGui.GetForm;
    recorder.RequestToDelete := RequestFromRecorderToDelete;
    recorders.Add(recorder);
    mainGui.RedrawRecorders;
  end;
end;

procedure TEngine.ChangeChannelName(channelIndex: integer;
  newName: string);
begin
  currentDevice.GetInputLine(channelIndex).SetName(newName);
  mainGui.UpdateMenus;
end;

procedure TEngine.ChooseDevice(deviceIndex: integer);
var selectDevice : TDevice;
begin
if ((deviceIndex < 0) or (deviceIndex > devicesList.Count)) then
    exit;
  selectDevice := TDevice(devicesList[deviceIndex]);
  if (selectDevice <> currentDevice) then
  begin
    if (Assigned(currentDevice)) then
    begin
      currentDevice.Disconnect;
    end;
    currentDevice := selectDevice;
    mainGui.ShowConnectionForm;
    reconnectOnDisconnect := true;
    currentDevice.Connect(self);
  end;
end;

constructor TEngine.Create(gui : IMainGui);
var device : TDevice;
begin
  _AddRef;

  connectOnTick := 0;

  timer := TTimer.Create(gui.GetForm);
  timer.Interval := 500;
  timer.Enabled := true;
  timer.OnTimer := OnTimer;


  recorders := TList.Create;

  mainGui := gui;

  devicesList := TList.Create;
  device := TDevice.Create(TEmulatorDevice.Create(mainGui.GetForm));

  devicesList.Add(device);

  device := TDevice.Create(TSimpleUsbDevice.Create());

  devicesList.Add(device);

  AddNewRecorder;
end;

procedure TEngine.DeleteAllRecorders;
begin
  recorders.Clear;
end;

function TEngine.GetDeviceName(deviceIndex: integer): string;
begin
  Result := (TDevice(devicesList[deviceIndex])).GetName;
end;

function TEngine.GetDevicesNumber: integer;
begin
  Result := devicesList.Count;
end;

function TEngine.GetInputLineName(inputLineIndex: integer): string;
begin
  Result := currentDevice.GetInputLine(inputLineIndex).GetName;
end;

function TEngine.GetInputLinesNumber: integer;
begin
  Result := currentDevice.GetInputLinesNumber;
end;

function TEngine.GetInputLineGraphWidth(inputLineIndex: integer): integer;
begin
  Result := currentDevice.GetInputLine(inputLineIndex).GetGraphWidth;
end;

function TEngine.GetRecorder(recorderIndex: integer): TRecorder;
begin
  Result := TRecorder(recorders[recorderIndex]);
end;

function TEngine.GetRecordersNumber: integer;
begin
  Result := recorders.Count;
end;

function TEngine.IsDeviceSelected: boolean;
begin
  Result := Assigned(currentDevice);
end;

procedure TEngine.OnConnected;
begin
  mainGui.HideConnectionForm;
  DeleteAllRecorders;
  AddNewRecorder;
  mainGui.UpdateMenus;
  currentDevice.SetListeningFlag(true);
end;

procedure TEngine.OnConnectionProgress(percent: integer);
begin
  mainGui.SetConnectionProgress(percent);
end;

procedure TEngine.OnConnectionStatusMessage(message: string);
begin
  mainGui.ShowConnectionStatusMessage(message);
end;

procedure TEngine.OnDisconnected;
begin
  if reconnectOnDisconnect then
    InterlockedExchange(connectOnTick, 1);
end;

procedure TEngine.OnErrorOnConnection;
begin
  if reconnectOnDisconnect then
    InterlockedExchange(connectOnTick, 1);
end;

procedure TEngine.SetInputLineGraphWidth(inputLineIndex, newWidth: integer);
begin
  if ((newWidth >= 1) and (newWidth <= 10)) then
    currentDevice.GetInputLine(inputLineIndex).SetGraphWidth(newWidth);
end;

function TEngine.GetInputLineGraphColor(inputLineIndex: integer): TColor;
begin
  Result := currentDevice.GetInputLine(inputLineIndex).GetGraphColor;
end;

procedure TEngine.SetInputLineGraphColor(inputLineIndex: integer; newColor: TColor);
begin
  currentDevice.GetInputLine(inputLineIndex).SetGraphColor(newColor);
end;

procedure TEngine.CheckIfHasData;
// 1. Checks if there are commands that want to show forms
// 2. Checks if there is data from a device to show in gui
var readData : PReadFromInputLineData;
var recorder : TRecorder;
var i : integer;
var commandWrapper : TCommand;
begin
  mainGui.ShowStatusText('check');
  if (Assigned(currentDevice) and currentDevice.IsConnected) then
  begin
    commandWrapper := currentDevice.GetInitializedCommand;
    if Assigned(commandWrapper) then
    begin
    if (commandWrapper.ShowForm = MrYes) then
    begin
      if commandWrapper.Executable then
      begin
        commandWrapper.SetState(waitingExecution);
        currentDevice.AddCommand(commandWrapper);
      end
    end;
    end;

    readData := currentDevice.GetReadData;
    while Assigned(readData) do
    begin
      for i := 0 to recorders.Count - 1 do
      begin
        recorder := TRecorder(recorders[i]);
        if (recorder.GetListenLineFlag(readData^.lineIndex)) then
        begin
          recorder.AddDataFromInputLine(readData^.lineIndex, readData^.timeRead, readData^.data);
        end;
      end;

      readData := currentDevice.GetReadData;

    end;
  end;
  mainGui.ShowStatusText('');
end;

procedure TEngine.RequestFromRecorderToDelete(Sender: TObject);
var i : integer;
begin
  for i := 0 to recorders.Count - 1 do
  begin
    if (recorders[i] = Sender) then
    begin
      recorders.Delete(i);
      (TRecorder(Sender)).UnSubscribeInputLineObservers;
      (TRecorder(Sender)).GetRecorderControl.Parent := nil;
      (TRecorder(Sender)).GetRecorderControl.SetGuiCallback(nil);
      mainGui.RedrawRecorders;
      exit;
    end;
  end;
end;

function TEngine.GetCalibrationMultiplier(inputLineIndex: integer): double;
begin
  Result := currentDevice.GetInputLine(inputLineIndex).GetMultiplier;
end;

function TEngine.GetCalibrationOffset(inputLineIndex: integer): double;
begin
  Result := currentDevice.GetInputLine(inputLineIndex).GetOffset;
end;

procedure TEngine.Disconnect;
begin
  currentDevice.Disconnect;
end;

procedure TEngine.CancelConnection;
begin
  reconnectOnDisconnect := false;
  InterlockedExchange(connectOnTick, 0);
  currentDevice.Disconnect;
  mainGui.HideConnectionForm;
end;

procedure TEngine.OnTimer(Sender: TObject);
var wasConnect : integer;
begin
  wasConnect := InterlockedExchange(connectOnTick, 0);

  if (wasConnect <> 0) then
  begin
    mainGui.ShowConnectionForm;
    currentDevice.Connect(self);
  end;

end;

procedure TEngine.SetCalibrationOffsetAndMultiplier(inputLineIndex : integer; offset, multiplier : double);
begin
  currentDevice.GetInputLine(inputLineIndex).SetOffsetAndMultiplier(offset, multiplier);
end;

procedure TEngine.LoadSheetFromFile(inputLineIndex : integer; filePath: string);
var sl: TStringList;
    i: Integer;
    value: string;
    fmt: TFormatSettings;
    corr : TDoubleArr;
    rangeMax, rangeMin : integer;
begin
  rangeMin := currentDevice.GetInputLine(inputLineIndex).GetMinInputVal;
  rangeMax := currentDevice.GetInputLine(inputLineIndex).GetMaxInputVal;

  GetLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT, fmt);
  fmt.DecimalSeparator := ',';
  sl := TStringList.Create;
  try
    sl.LoadFromFile(filePath);
    sl.NameValueSeparator := ';';
    SetLength(corr, rangeMax - rangeMin + 1);
    for i := rangeMin to rangeMax do
      begin
        value := sl.Values[IntToStr(i)];
        if value = '' then
        begin
          MessageBox(0, PAnsiChar(Format('No correspondence for value %d', [i])), 'Error in the map file', MB_OK or MB_ICONERROR);
          exit;
        end;
        try
          corr[i] := StrToFloat(value, fmt);
        except
          on e: EConvertError do
          begin
            MessageBox(0, PAnsiChar(Format('Error in loading correspondence for value %d', [i])), 'Error in the map file', MB_OK or MB_ICONERROR);
            exit;
          end;
        end;
      end;
  finally
    sl.Free;
  end;
  currentDevice.GetInputLine(inputLineIndex).SetSheedData(corr);
end;

function TEngine.GetScriptText(inputLineIndex: integer): string;
begin
  Result := currentDevice.GetInputLine(inputLineIndex).GetScriptText;
end;

procedure TEngine.SetScriptText(inputLineIndex: integer; scriptText: string);
begin
  currentDevice.GetInputLine(inputLineIndex).SetScriptText(scriptText);
end;

procedure TEngine.CommandClicked(commandIndex: integer);
var
  commandWrapper : TCommand;
begin
  commandWrapper := currentDevice.CreateCommandWrapper(commandIndex);

  if (commandWrapper.Initializable) then
  begin
    currentDevice.AddCommand(commandWrapper);
    exit;
  end;
  if (commandWrapper.ShowForm = MrYes) then
  begin
    commandWrapper.SetState(waitingExecution);
    currentDevice.AddCommand(commandWrapper);
    exit;
  end;
  commandWrapper.Free;
end;

function TEngine.GetCommandName(commandIndex: integer): string;
begin
  Result := currentDevice.GetCommandName(commandIndex);
end;

function TEngine.GetCommandsNumber: integer;
begin
  Result := currentDevice.GetCommandsNumber;
end;

end.


