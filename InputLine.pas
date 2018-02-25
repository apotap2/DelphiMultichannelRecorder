unit InputLine;

interface

uses BaseDevice, SysUtils, Graphics, Classes, Windows, MSScriptControl_TLB, Activex, ComObj, SyncObjs;

type
TDoubleArr = array of Double;
TCurrentCalibration = (MultiplierOffset, Sheet, Script);

TInputLine = class;

IInputLineChangedCallback = interface
  procedure OnInputLineChanged(inputLine : TInputLine);
end;

TInputLine = class
  Constructor Create(device : IBaseRequestOnlyDevice; index : integer);
  function IsListening() : boolean;
  procedure SetListeningFlag(flag : boolean);
  procedure SetName(newName : string);
  function GetName() : string;
  procedure SetGraphColor(newColor : TColor);
  function GetGraphColor() : TColor;
  function GetIndeviceIndex() : integer;

  function GetGraphWidth() : integer;
  procedure SetGraphWidth(newWidth : integer);

  function GetOffset() : double;
  function GetMultiplier() : double;

  procedure SetOffsetAndMultiplier(newOffset, newMultiplier: double);

  function GetScriptText() : string;
  procedure SetScriptText(scriptText : string);

  function Calibrate(val : integer) : double;

  procedure SubscribeOnInputLineChanged(callback : IInputLineChangedCallback);
  procedure UnSubscribeOnInputLineChanged(callback : IInputLineChangedCallback);

  function GetMinInputVal : integer;
  function GetMaxInputVal : integer;

  procedure SetSheedData(corr : TDoubleArr);
  Destructor Destroy; override;
private
  requestOnlyDevice : IBaseRequestOnlyDevice;

  inDeviceIndex : integer;

  name : string;
  graphColor : TColor;
  graphWidth : integer;
  inputLineChangedObservers : TList;

  offset : double;
  multiplier : double;

  listenersCount : integer;

  currentCalibration : TCurrentCalibration;

  scriptSection : TCriticalSection;
  scriptText : string;
  scriptMachine : TScriptControl;
  needRecompileScript : boolean;

  sheetData : TDoubleArr;

  procedure fireInputLineChanged;

  function CalibrateMultiplierOffset(val : integer) : double;
  function CalibrateSheet(val : integer) : double;
  function CalibrateScript(val : integer) : double;
end;

implementation

{ TInputLine }

function TInputLine.Calibrate(val: integer): double;
begin
  case self.currentCalibration of
     MultiplierOffset:
      Result := self.CalibrateMultiplierOffset(val);
     Sheet:
      Result := self.CalibrateSheet(val);
     Script:
      Result := self.CalibrateScript(val);
      else
      Result := 0;
  end;
end;

function TInputLine.CalibrateMultiplierOffset(val: integer): double;
begin
  Result := val * self.multiplier + offset;
end;

function TInputLine.CalibrateScript(val: integer): double;
begin
   if not Assigned(self.scriptMachine) then
   begin
    CoInitialize(nil);
    self.scriptMachine := TScriptControl.Create(nil);
    scriptMachine.Language := 'JScript';
   end;
   scriptSection.Enter;
   if self.needRecompileScript then
   begin
    scriptMachine.AddCode('var Calibrate = function(inputData){'+#10+#13+scriptText+#10+#13+'}');
    needRecompileScript := false;
   end;
   scriptSection.Leave;

  try
    Result := double(scriptMachine.Eval('Calibrate(' + FloatToStr(val) + ')'));
  except
  on Exception : EOleException do
  begin
    Result := 0;
    exit;
  end;
  end;

end;

function TInputLine.CalibrateSheet(val: integer): double;
begin
  Result := sheetData[val];
end;

constructor TInputLine.Create(device: IBaseRequestOnlyDevice;
  index: integer);
begin
  offset := 0;
  multiplier := 1;

  listenersCount := 0;
  self.inDeviceIndex := index;
  self.requestOnlyDevice := device;

  name := 'Channel ' + IntToStr(index + 1);

  graphWidth := 1;
  inputLineChangedObservers := TList.Create;

  self.currentCalibration := MultiplierOffset;

  scriptText := 'return inputData';
  self.scriptSection := TCriticalSection.Create;
  needRecompileScript := false;
end;

destructor TInputLine.Destroy;
var i : integer;
begin
  for i := 0 to self.inputLineChangedObservers.Count - 1 do
  begin
    (IInputLineChangedCallback(self.inputLineChangedObservers[i]))._Release;
  end;
end;

procedure TInputLine.fireInputLineChanged;
var i : integer;
begin
  for i := 0 to self.inputLineChangedObservers.Count - 1 do
  begin
    (IInputLineChangedCallback(self.inputLineChangedObservers[i])).OnInputLineChanged(self);
  end;
end;

function TInputLine.GetGraphColor: TColor;
begin
  Result := self.graphColor;
end;

function TInputLine.GetGraphWidth: integer;
begin
  Result := self.graphWidth;
end;

function TInputLine.GetIndeviceIndex: integer;
begin
  Result := self.inDeviceIndex;
end;

function TInputLine.GetMaxInputVal: integer;
begin
  Result := requestOnlyDevice.GetMaximumValInInputLine(self.inDeviceIndex);
end;

function TInputLine.GetMinInputVal: integer;
begin
  Result := requestOnlyDevice.GetMinimumValInInputLine(self.inDeviceIndex);
end;

function TInputLine.GetMultiplier: double;
begin
  Result := self.multiplier;
end;

function TInputLine.GetName: string;
begin
  Result := name;
end;

function TInputLine.GetOffset: double;
begin
  Result := self.offset;
end;

function TInputLine.GetScriptText: string;
begin
  Result := self.scriptText;
end;

function TInputLine.IsListening: boolean;
begin
  Result := self.listenersCount > 0;
end;

procedure TInputLine.SetGraphColor(newColor: TColor);
begin
  graphColor := newColor;
  self.fireInputLineChanged;
end;

procedure TInputLine.SetGraphWidth(newWidth: integer);
begin
  self.graphWidth := newWidth;
  self.fireInputLineChanged;
end;

procedure TInputLine.SetListeningFlag(flag: boolean);
begin
  if (flag) then
    InterlockedIncrement(self.listenersCount)
  else
    InterlockedDecrement(self.listenersCount);

end;

procedure TInputLine.SetName(newName: string);
begin
  name := newName;
  self.fireInputLineChanged;
end;

procedure TInputLine.SetOffsetAndMultiplier(newOffset, newMultiplier: double);
begin
  self.offset := newOffset;
  self.multiplier := newMultiplier;
  self.currentCalibration := MultiplierOffset;
end;

procedure TInputLine.SetScriptText(scriptText: string);
var
  testScriptMachine : TScriptControl;
begin
  CoInitialize(nil);
  testScriptMachine := TScriptControl.Create(nil);
  try
    testScriptMachine.Language := 'JScript';
    testScriptMachine.AddCode('var testFunc = function(inputData){'+#10+#13+scriptText+#10+#13+'}');
    testScriptMachine.Eval('testFunc(1)');
  except
  on Exception : EOleException do
  begin
    MessageBox(0, PAnsiChar(Exception.Message), 'Error in script', MB_OK or MB_ICONERROR);
    exit;
  end;
  end;
  scriptSection.Enter;
  self.scriptText := scriptText;
  needRecompileScript := true;
  self.currentCalibration := Script;
  scriptSection.Leave;
end;

procedure TInputLine.SetSheedData(corr: TDoubleArr);
var
  rangeMin, rangeMax : integer;
begin
  rangeMin := self.GetMinInputVal;
  rangeMax := self.GetMaxInputVal;
  if (Length(corr) = (rangeMax - rangeMin + 1)) then
  begin
    self.sheetData := corr;
    self.currentCalibration := Sheet;
  end;
end;

procedure TInputLine.SubscribeOnInputLineChanged(
  callback: IInputLineChangedCallback);
begin
  callback._AddRef;
  self.inputLineChangedObservers.Add(Pointer(callback));
end;

procedure TInputLine.UnSubscribeOnInputLineChanged(
  callback: IInputLineChangedCallback);
var i : integer;
var callbackInList : IInputLineChangedCallback;
begin
  for i := 0 to inputLineChangedObservers.Count - 1 do
  begin
    callbackInList := IInputLineChangedCallback(inputLineChangedObservers[i]);
    if (callbackInList = callback) then
    begin
      inputLineChangedObservers.Delete(i);
      callback._Release;
      exit;
    end;
  end;
end;

end.
