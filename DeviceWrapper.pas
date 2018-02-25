unit DeviceWrapper;
// Device and command wrappers.
// Device will create an interrogation thread. The interrogation thread will ask for data and
// make commands' interrogations.
// Implementation detail: there is a circular buffer to communicate between producer(interrogation)
// and consumer(gui) threads.

interface

uses BaseDevice, InputLine, Classes, Graphics, Windows, SyncObjs, Math, Activex, MSScriptControl_TLB;

const maxDataSize = 3 * 1024 * 1024;

type
TCommandState = (waitingInitialization, initialized, waitingExecution);

TCommand = class
public
  Constructor Create(command : ICommandInfo; state : TCommandState);
  function NeedInitialize : boolean;
  function NeedExecute : boolean;
  function Executable : boolean;
  function Initializable : boolean;
  function Initialize : boolean;
  procedure Execute;
  procedure SetInitialized;
  function ShowForm : integer;
  procedure SetState(state : TCommandState);
private
  commandInfo : ICommandInfo;
  commandState : TCommandState;
end;

TReadFromInputLineData = record // used in the circular buffer
  timeRead : double;
  data : double;
  lineIndex : integer;
end;

PReadFromInputLineData = ^TReadFromInputLineData;

TDevice = class
Constructor Create(baseRequestDevice : IBaseRequestOnlyDevice);
function IsConnected : boolean;
function GetInputLinesNumber : integer;
function GetInputLine(inputLineIndex : integer) : TInputLine;

function GetCommandsNumber : integer;
function GetCommandName(index : integer) : string;
function NeedSendInitializationForCommand(index : integer) : boolean;

procedure Disconnect;
procedure Connect(connectionCallback: IConnectionCallback);
function GetName : string;

procedure SetListeningFlag(flag : boolean);
function GetListeningFlag() : boolean;

function GetReadData() : PReadFromInputLineData;

procedure ClearReadData();
procedure AddCommand(command : TCommand); overload;
function AddCommand(index : integer; commandState : TCommandState) : TCommand; overload;
function CreateCommandWrapper(index : integer) : TCommand;

function GetWaitingCommand : TCommand;
function GetInitializedCommand : TCommand;
procedure DeleteCommand(command : TCommand);

private
  requestOnlyDevice : IBaseRequestOnlyDevice;
  inputLines : TList;

  isListening : boolean;

  listenThread : TThread;

  readDataCircularBuf : array[1..maxDataSize] of TReadFromInputLineData;
  readDataIndexStart : integer;
  readDataIndexEnd : integer;

  commands : TList;
  commandsCrit : TCriticalSection;

procedure CommitNewData();
function PrepareNewData() : PReadFromInputLineData;
end;


implementation

type TListeningThread = class(TThread)

Constructor Create(listenDevice : TDevice);
procedure Execute; override;

private
 device : TDevice;

function ArrToInt(var arr : array of byte) : integer;
end;


{ TDevice }

procedure TDevice.AddCommand(command: TCommand);
begin
  commandsCrit.Enter;
  self.commands.Add(command);
  commandsCrit.Leave;
end;

function TDevice.AddCommand(index: integer; commandState: TCommandState) : TCommand;
var
  commandWrapper : TCommand;
  commandInfo : ICommandInfo;
begin
  commandInfo := requestOnlyDevice.GetCommandInfo(index);
  commandWrapper := TCommand.Create(commandInfo, commandState);
  AddCommand(commandWrapper);
  Result := commandWrapper;
end;

procedure TDevice.ClearReadData;
begin
  readDataIndexStart := readDataIndexEnd;
end;

procedure TDevice.CommitNewData;
begin
  // This code will be used on x86 cpu, one thread is producer, another one is
  // consumer. For x86 here there is no need in memory fence or mutex.
  Inc(readDataIndexEnd);
  if (readDataIndexEnd = maxDataSize) then
    readDataIndexEnd := 1;
end;

procedure TDevice.Connect(connectionCallback: IConnectionCallback);
begin
  requestOnlyDevice.Connect(connectionCallback);
end;

constructor TDevice.Create(baseRequestDevice: IBaseRequestOnlyDevice);
var i : integer;
var inputLine : TInputLine;
var defaultGraphColors : Array of TColor;
begin
  isListening := false;

  commands := TList.Create;
  commandsCrit := TCriticalSection.Create;

  SetLength(defaultGraphColors, 5); // hardcoded
  defaultGraphColors[0] := clRed;
  defaultGraphColors[1] := clGreen;
  defaultGraphColors[2] := clYellow;
  defaultGraphColors[3] := clBlue;
  defaultGraphColors[4] := clOlive;


  requestOnlyDevice := baseRequestDevice;

  inputLines := TList.Create;
  for i := 0 to requestOnlyDevice.GetInputLinesNumber -1 do
  begin
    inputLine := TInputLine.Create(requestOnlyDevice, i);
    if (i >= Length(defaultGraphColors)) then
      inputLine.SetGraphColor(RGB(Random(255), Random(255), Random(255)))
    else
      inputLine.SetGraphColor(defaultGraphColors[i]);
    inputLines.Add(inputLine);
  end;

  listenThread := TListeningThread.Create(self);

  readDataIndexStart := 1;
  readDataIndexEnd := 1;
end;

function TDevice.CreateCommandWrapper(index: integer): TCommand;
var
  commandWrapper : TCommand;
  commandInfo : ICommandInfo;
begin
  commandInfo := requestOnlyDevice.GetCommandInfo(index);
  commandWrapper := TCommand.Create(commandInfo, waitingInitialization);
  Result := commandWrapper;
end;

procedure TDevice.DeleteCommand(command: TCommand);
var
  i : integer;
begin
  self.commandsCrit.Enter;
  try
  for i := 0 to self.commands.Count - 1 do
  begin
    if (commands[i] = command) then
    begin
      TCommand(commands[i]).Free;
      commands.Delete(i);
      exit;
    end;
  end;
  finally
  self.commandsCrit.Leave;
  end;
end;

procedure TDevice.Disconnect;
begin
  SetListeningFlag(false);
  requestOnlyDevice.Disconnect;
end;

function TDevice.GetCommandName(index: integer): string;
begin
  Result := requestOnlyDevice.GetCommandInfo(index).GetName;
end;

function TDevice.GetCommandsNumber: integer;
begin
  Result := requestOnlyDevice.GetCommandsNumber;
end;

function TDevice.GetInitializedCommand: TCommand;
var
  i : integer;
begin
  Result := nil;
  self.commandsCrit.Enter;
  try
  for i := 0 to self.commands.Count - 1 do
  begin
    if TCommand(commands[i]).commandState = initialized then
    begin
      Result := TCommand(commands[i]);
      commands.Delete(i);
    end;
  end;
  finally
  self.commandsCrit.Leave;
  end;
end;

function TDevice.GetInputLine(inputLineIndex: integer): TInputLine;
begin
  Result := TInputLine(inputLines[inputLineIndex]);
end;

function TDevice.GetInputLinesNumber: integer;
begin
  Result := requestOnlyDevice.GetInputLinesNumber;
end;

function TDevice.GetListeningFlag: boolean;
begin
  Result := isListening;
end;

function TDevice.GetName: string;
begin
  Result := requestOnlyDevice.GetName;
end;

function TDevice.GetReadData: PReadFromInputLineData;
begin
  if (readDataIndexStart = readDataIndexEnd) then
  begin
   Result := nil;
   exit;
  end;
  Result := @readDataCircularBuf[readDataIndexStart];
  // No mutex, memory fence needed
  Inc(readDataIndexStart);
  if (readDataIndexStart = maxDataSize) then
    readDataIndexStart := 1;
end;

function TDevice.GetWaitingCommand: TCommand;
var
  i : integer;
begin
  Result := nil;
  self.commandsCrit.Enter;
  try
  for i := 0 to self.commands.Count - 1 do
  begin
    if ((TCommand(commands[i])).commandState = waitingInitialization) or
      ((TCommand(commands[i])).commandState = waitingExecution) then
    begin
      Result := TCommand(commands[i]);
    end;
  end;
  finally
  self.commandsCrit.Leave;
  end;
end;

function TDevice.IsConnected : boolean;
begin
  Result := requestOnlyDevice.IsConnected;
end;

function TDevice.NeedSendInitializationForCommand(index: integer): boolean;
begin
  Result := requestOnlyDevice.GetCommandInfo(index).NeedSendInitialization;
end;

function TDevice.PrepareNewData: PReadFromInputLineData;
begin
  Result := @readDataCircularBuf[readDataIndexEnd];
end;

procedure TDevice.SetListeningFlag(flag: boolean);
begin
  isListening := flag;
  if (flag) then
    listenThread.Resume
  else
  begin

    listenThread.Suspend;
  end;
end;

{ TListeningThread }

function TListeningThread.ArrToInt(var arr: array of byte): integer;
var j : integer;
begin
  Result := arr[0];
  for j := 1 to Length(arr) - 1 do
  begin
    Result := Result shl 8;
    Result := Result + arr[j];
  end;
end;


constructor TListeningThread.Create(listenDevice: TDevice);
begin
  inherited Create(true);
  device := listenDevice;
end;

procedure TListeningThread.Execute;
var listenLines,requestLines : TLineIndexesArray;
var i,j,len : integer;
var maxPerRequest : integer;
var readResult, temp : TBytesArray;
var inputStart, timeNow : int64;
var freq : int64;
var readValue : integer;
var readData : PReadFromInputLineData;
var intervalFromStart : double;
var resBytesLen : integer;
var command : TCommand;
begin
//  SetThreadAffinityMask(Handle, 1);
  SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_HIGHEST);
  QueryPerformanceFrequency(freq);
  QueryPerformanceCounter(inputStart);

  while true do
  begin
    if (device.IsConnected) then
    begin
      command := device.GetWaitingCommand;
      if Assigned(command) then
      begin
        if command.NeedInitialize then
        begin
          if command.Initialize then
            command.SetInitialized
          else
            device.DeleteCommand(command);
        end
        else if command.NeedExecute then
        begin
          command.Execute;
          device.DeleteCommand(command);
        end;
      end;

      SetLength(listenLines, 0);
      for i := 0 to device.GetInputLinesNumber - 1 do
      begin
        if (device.GetInputLine(i).IsListening) then
        begin
          SetLength(listenLines, Length(listenLines) + 1);
          listenLines[Length(listenLines) - 1] := i;
        end;
      end;
      if (Length(listenLines) = 0) then
        Sleep(100)
      else
      begin
        if (Length(listenLines) = 1) then
        begin
          if (device.requestOnlyDevice.ReadFromInputLine(listenLines[0], readResult)) then
          begin
            QueryPerformanceCounter(timeNow);

            readValue := ArrToInt(readResult);

            intervalFromStart := (timeNow - inputStart) / freq;
            readData := device.PrepareNewData;
            readData^.data := device.GetInputLine(listenLines[0]).Calibrate(readValue);
            readData^.lineIndex := listenLines[0];
            readData^.timeRead := intervalFromStart;
            device.CommitNewData;
          end;
        end
        else
        begin
          maxPerRequest := device.requestOnlyDevice.GetMaxInputLinesNumberPerRequest;
          for j := 0 to Length(listenLines) div maxPerRequest do
          begin
            len := min(maxPerRequest, Length(listenLines) - j * maxPerRequest);
            if (len = 0) then
              break;
            requestLines := Copy(listenLines, j * maxPerRequest, len);
            if (device.requestOnlyDevice.ReadFromInputLines(requestLines, readResult)) then
            begin
              QueryPerformanceCounter(timeNow);
              resBytesLen := Length(readResult) div Length(requestLines);
               for i := 0 to len - 1 do
               begin
                  temp := Copy(readResult, i * resBytesLen, resBytesLen);
                  readValue := ArrToInt(temp);

                  intervalFromStart := (timeNow - inputStart) / freq;
                  readData := device.PrepareNewData;
                  readData^.lineIndex := listenLines[j * maxPerRequest + i];
                  readData^.data := device.GetInputLine(readData.lineIndex).Calibrate(readValue);
                  readData^.timeRead := intervalFromStart;
                  device.CommitNewData;
               end;
            end;
          end;
        end;
      end;
    end
    else
      Sleep(100);
  end;
end;

{ TCommand }

constructor TCommand.Create(command: ICommandInfo; state : TCommandState);
begin
  commandInfo := command;
  commandState := state;
end;

function TCommand.Executable: boolean;
begin
  Result := self.commandInfo.NeedExecute;
end;

procedure TCommand.Execute;
begin
  self.commandInfo.Execute;
end;

function TCommand.Initializable: boolean;
begin
  Result := self.commandInfo.NeedSendInitialization;
end;

function TCommand.Initialize: boolean;
begin
  Result := self.commandInfo.Initialize;
end;

function TCommand.NeedExecute: boolean;
begin
  Result := self.commandState = waitingExecution;
end;

function TCommand.NeedInitialize: boolean;
begin
  Result := self.commandState = waitingInitialization;
end;

procedure TCommand.SetInitialized;
begin
  self.commandState := initialized;
end;

procedure TCommand.SetState(state: TCommandState);
begin
  self.commandState := state;
end;

function TCommand.ShowForm: integer;
begin
  Result := self.commandInfo.ShowForm;
end;

end.
