unit Recorder;
// the module contains Recorder class, contains Recorder logic.
// implements IInputLineChangedCallback to react to input line changes,
// IRecorderControlCallback to react to gui events.

interface

uses RecorderControl, Controls, Classes, DeviceWrapper, inputLine, SelectChannelForm;

type TRecorder = class(TInterfacedObject, IInputLineChangedCallback, IRecorderControlCallback)
private
FOnRequestToDelete : TNotifyEvent;
public
  Constructor Create(connectedDevice : TDevice);
  Destructor Destroy; override;
  function GetRecorderControl() : TRecorderControl;
  procedure CreateRecorderControl(AOwner: TComponent);

  procedure SetListenLineFlag(lineIndex : integer; flag : boolean);
  function GetListenLineFlag(lineIndex : integer) : boolean;

  procedure AddDataFromInputLine(inputLineNumber : integer; secs : double; data : double);

  // observer interface
  procedure OnInputLineChanged(inputLine : TInputLine);

  // control callbacks
  procedure SetRelativeMeasure;
  procedure SetAbsoluteMeasure;
  procedure AddChannel;
  procedure RemoveChannel;
  procedure DeleteRecorder;

  property RequestToDelete : TNotifyEvent read FOnRequestToDelete write FOnRequestToDelete;

  procedure UnSubscribeInputLineObservers;
private
recorderControl : TRecorderControl;
listeningInputLines : Array of Byte;
device : TDevice;
recorderControlOwner : TComponent;
relativeMeasure : boolean;
relativeChannelIndex : integer;
relativeData : double;

  function ShowChooseChannelForm() : integer;
  function ShowChoosePresentChannelForm() : integer;
  function ShowChooseAbsentChannelForm() : integer;
end;

implementation

{ TRecorder }

procedure TRecorder.AddChannel;
var lineIndex : integer;
begin
  lineIndex := ShowChooseAbsentChannelForm;
  if (lineIndex <> -1) then
  begin
    self.SetListenLineFlag(lineIndex, true);
    self.recorderControl.AddGraphLine(lineIndex, device.GetInputLine(lineIndex).GetName, device.GetInputLine(lineIndex).GetGraphColor);
    self.recorderControl.SetGraphWidth(lineIndex, device.GetInputLine(lineIndex).GetGraphWidth);
  end;
end;

procedure TRecorder.AddDataFromInputLine(inputLineNumber: integer; secs,
  data: double);
begin
  if not self.GetListenLineFlag(inputLineNumber) then
    exit;
  if self.relativeMeasure then
  begin
    if (inputLineNumber = self.relativeChannelIndex) then
    begin
      self.relativeData := data;
    end;
    if (relativeData <> 0) and ((inputLineNumber <> self.relativeChannelIndex) or recorderControl.HasInputLineGraph(inputLineNumber)) then
      recorderControl.AddPointToGraphLine(inputLineNumber, secs, data / relativeData);
    exit;
  end;
  recorderControl.AddPointToGraphLine(inputLineNumber, secs, data);
end;

constructor TRecorder.Create(connectedDevice: TDevice);
var i : integer;
begin
  device := connectedDevice;
  relativeMeasure := false;
  relativeData := 0;

  SetLength(listeningInputLines, device.GetInputLinesNumber);

  for i := 0 to device.GetInputLinesNumber - 1 do
  begin
    device.GetInputLine(i).SubscribeOnInputLineChanged(self);
    self.SetListenLineFlag(i, true);
  end;
end;

procedure TRecorder.CreateRecorderControl(AOwner: TComponent);
var i : integer;
begin
  recorderControl := TRecorderControl.Create(AOwner);
  recorderControlOwner := AOwner;
  recorderControl.SetGuiCallback(self);

  for i := 0 to device.GetInputLinesNumber - 1 do
  begin
    if (self.GetListenLineFlag(i)) then
      self.recorderControl.AddGraphLine(i, device.GetInputLine(i).GetName, device.GetInputLine(i).GetGraphColor);
      self.recorderControl.SetGraphWidth(i, device.GetInputLine(i).GetGraphWidth);
  end;
end;

procedure TRecorder.DeleteRecorder;
begin
  if Assigned(FOnRequestToDelete) then FOnRequestToDelete(Self);
end;

destructor TRecorder.Destroy;
var i : integer;
begin
  for i := 0 to device.GetInputLinesNumber - 1 do
  begin
    self.SetListenLineFlag(i, false);
  end;
  if Assigned(self.GetRecorderControl()) then
    self.GetRecorderControl.Parent := nil;
  inherited;
end;

function TRecorder.GetListenLineFlag(lineIndex: integer): boolean;
begin
  Result := self.listeningInputLines[lineIndex] > 0;
end;

function TRecorder.GetRecorderControl: TRecorderControl;
begin
  Result := recorderControl;
end;

procedure TRecorder.OnInputLineChanged(inputLine: TInputLine);
begin
  self.GetRecorderControl.RenameGraphLine(inputLine.GetIndeviceIndex, inputLine.GetName);
  self.GetRecorderControl.SetGraphWidth(inputLine.GetIndeviceIndex, inputLine.GetGraphWidth);
  self.GetRecorderControl.SetGraphColor(inputLine.GetIndeviceIndex, inputLine.GetGraphColor);
end;

procedure TRecorder.RemoveChannel;
var lineIndex : integer;
begin
  lineIndex := ShowChoosePresentChannelForm;
  if (lineIndex <> -1) then
  begin
    if not (self.relativeMeasure and (self.relativeData = lineIndex)) then
    self.SetListenLineFlag(lineIndex, false);
    self.GetRecorderControl.DeleteGraphLine(lineIndex);
  end;
end;

procedure TRecorder.SetAbsoluteMeasure;
var wasRelative : boolean;
begin
  wasRelative := self.relativeMeasure;
  self.relativeMeasure := false;
  if (wasRelative) then begin
    if (not self.GetRecorderControl.HasInputLineGraph(self.relativeChannelIndex)) then
      self.SetListenLineFlag(self.relativeChannelIndex, false);
  end;
end;

procedure TRecorder.SetListenLineFlag(lineIndex: integer; flag: boolean);
var flagBefore : integer;
begin
  flagBefore := self.listeningInputLines[lineIndex];
  if (flag) then
    self.listeningInputLines[lineIndex] := 1
  else
    self.listeningInputLines[lineIndex] := 0;

  if (flagBefore <> self.listeningInputLines[lineIndex]) then
    device.GetInputLine(lineIndex).SetListeningFlag(flag);
end;

procedure TRecorder.SetRelativeMeasure;
var lineIndex : integer;
begin
  lineIndex := ShowChooseChannelForm;
  if (lineIndex <> -1) then
  begin
    relativeData := 0;
    self.relativeMeasure := true;
    self.relativeChannelIndex := lineIndex;
    self.SetListenLineFlag(lineIndex, true);
    self.GetRecorderControl.DeleteGraphLine(lineIndex);
  end;
end;

function TRecorder.ShowChooseAbsentChannelForm: integer;
var chooseChannelForm : TChannelsForm;
var i : integer;
var listNotEmpty : boolean;
begin
    Result := -1;
    listNotEmpty := false;

   chooseChannelForm := TChannelsForm.Create(self.recorderControlOwner);
   for i := 0 to device.GetInputLinesNumber -1 do
   begin
    if (not self.GetRecorderControl.HasInputLineGraph(i)) then
    begin
      chooseChannelForm.AddChannel(device.GetInputLine(i).GetName, device.GetInputLine(i).GetIndeviceIndex);
      listNotEmpty := true;
    end;
   end;

   if not listNotEmpty then
    exit;

   if (chooseChannelForm.ShowModal = MrYes) and chooseChannelForm.ChannelSelected then
   begin
    Result := chooseChannelForm.SelectedChannelIndex;
   end;
end;

function TRecorder.ShowChooseChannelForm: integer;
var chooseChannelForm : TChannelsForm;
var i : integer;
begin
  Result := -1;

   chooseChannelForm := TChannelsForm.Create(self.recorderControlOwner);
   for i := 0 to device.GetInputLinesNumber -1 do
   begin
    chooseChannelForm.AddChannel(device.GetInputLine(i).GetName, device.GetInputLine(i).GetIndeviceIndex);
   end;


   if (chooseChannelForm.ShowModal = MrYes) and chooseChannelForm.ChannelSelected then
   begin
    Result := chooseChannelForm.SelectedChannelIndex;
   end;
end;

function TRecorder.ShowChoosePresentChannelForm: integer;
var chooseChannelForm : TChannelsForm;
var i : integer;
var listNotEmpty : boolean;
begin
    Result := -1;
    listNotEmpty := false;

   chooseChannelForm := TChannelsForm.Create(self.recorderControlOwner);
   for i := 0 to device.GetInputLinesNumber -1 do
   begin
    if (self.GetRecorderControl.HasInputLineGraph(i)) then
    begin
      chooseChannelForm.AddChannel(device.GetInputLine(i).GetName, device.GetInputLine(i).GetIndeviceIndex);
      listNotEmpty := true;
    end;
   end;

   if not listNotEmpty then
    exit;

   if (chooseChannelForm.ShowModal = MrYes) and chooseChannelForm.ChannelSelected then
   begin
    Result := chooseChannelForm.SelectedChannelIndex;
   end;
end;

procedure TRecorder.UnSubscribeInputLineObservers;
var i : integer;
begin
  for i := 0 to device.GetInputLinesNumber - 1 do
  begin
    self.device.GetInputLine(i).UnSubscribeOnInputLineChanged(self);
  end;
end;

end.
