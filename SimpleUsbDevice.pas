unit SimpleUsbDevice;
// "Simple usb device", contains device class which implements IBaseRequestOnlyDevice.
// Used with my pic18 device. 

interface

uses
  BaseDevice, PIC18SimulatorDllHelper, SysUtils, Windows, Controls, Classes, SetDigitalPin,
  AdcSettings, SetVal, WriteToExtEeprom, Dialogs;

type
  TPinInfo = class
  public
    Constructor Create(descr : string; portNum, pinNum : integer);
    function GetDescription : string;
    function GetPortNum : integer;
    function GetPinNum : integer;
  private
    description : string;
    port, pin : integer;
  end;

  TSetPort = class (TInterfacedObject, ICommandInfo)
  public
    Constructor Create();
    function GetName() : string; 
    function NeedSendInitialization() : boolean;
    function ShowForm() : integer; 
    function NeedExecute() : boolean; 
    procedure Execute; 
    function Initialize : boolean; 
  private
    choosenPort, choosenPin, choosenVal : integer;
    pins : TList;
    canExecute : boolean;
  end;

  TSetExtEEprom = class (TInterfacedObject, ICommandInfo)
  public
    function GetName() : string; 
    function NeedSendInitialization() : boolean; 
    function ShowForm() : integer; 
    function NeedExecute() : boolean; 
    procedure Execute; 
    function Initialize : boolean; 
  private
    extEEpromSize : integer;
  end;

  TWriteADCToExtEEprom = class (TInterfacedObject, ICommandInfo)
  public
    function GetName() : string; 
    function NeedSendInitialization() : boolean; 
    function ShowForm() : integer; 
    function NeedExecute() : boolean; 
    procedure Execute; 
    function Initialize : boolean; 
  private
    channelsMask, writeMode : byte;
    interval : integer;
  end;

  TReadFromExtEEprom = class (TInterfacedObject, ICommandInfo)
  public
    function GetName() : string; 
    function NeedSendInitialization() : boolean; 
    function ShowForm() : integer; 
    function NeedExecute() : boolean; 
    procedure Execute; 
    function Initialize : boolean; 
  private
    interval : integer;
    channelsMask : byte;
    filePath : string;
  end;

  TConfigureAdc = class (TInterfacedObject, ICommandInfo)
  public
    function GetName() : string; 
    function NeedSendInitialization() : boolean; 
    function ShowForm() : integer; 
    function NeedExecute() : boolean; 
    procedure Execute; 
    function Initialize : boolean; 
  private
    isVss, isVdd : boolean;
  end;

  TSimpleUsbDevice = class (TInterfacedObject, IBaseRequestOnlyDevice)
  public
  Constructor Create();
  function GetName() : string;
  function IsConnected() : boolean;
  procedure Connect(connectionCallback: IConnectionCallback);
  function GetInputLinesNumber() : integer;
  function ReadFromInputLine(lineNumber: integer; var output : TBytesArray) : boolean;
  function GetMaxInputLinesNumberPerRequest () : integer;
  function ReadFromInputLines(var lineNumbers : TLineIndexesArray; var output : TBytesArray) : boolean;
  function GetCommandsNumber() : integer;
  function GetCommandInfo(commandNumber : integer) : ICommandInfo;

  function GetMinimumValInInputLine(lineNumber : integer) : integer;
  function GetMaximumValInInputLine(lineNumber : integer) : integer;

  procedure Disconnect;
  procedure ShowAbout;

  private

  m_connectionCallback: IConnectionCallback;
  connected : boolean;

  commands : TList;
  end;

implementation
{ TSimpleUsbDevice }
// usb device constants.

const ReadFromAdc = $01;
const ReadFromAdcs = $02;
const SetDigitalPin = $03;
const GetAdcon1 = $04;
const SetAdcon1 = $05;
const ReadExtEepromSize = $06;
const SetExtEepromSize = $07;
const WriteToExtEeprom = $08;
const ReadOfflineIntervalAndMask = $09;
const StopOfflineReading = $0a;
const ReadFromExtMem = $0b;

procedure TReadFromExtEEprom.Execute;
var
  f: Textfile;
  dt : double;
  firstLine : string;
  res : Array[0..7] of Byte;
  i : integer;
  chanNum : integer;
  curt : integer;
  chanInLine : integer;
  j : integer;
  temp : integer;
begin
  if (HID_Detected = 0) then
  begin
    exit;
  end;

  chanNum := 0;
  curt := 0;
  firstLine := 'Time, sec';
    if (self.channelsMask and $01) > 0 then
    begin
      firstLine := firstLine + ';Channel 1';
      Inc(chanNum);
    end;
    if (self.channelsMask and $02) > 0 then
    begin
      firstLine := firstLine + ';Channel 2';
      Inc(chanNum);
    end;
    if (self.channelsMask and $04) > 0 then
    begin
      firstLine := firstLine + ';Channel 3';
      Inc(chanNum);
    end;
    if (self.channelsMask and $08) > 0 then
    begin
      firstLine := firstLine + ';Channel 4';
      Inc(chanNum);
    end;
    if (self.channelsMask and $10) > 0 then
    begin
      firstLine := firstLine + ';Channel 5';
      Inc(chanNum);
    end;

    if chanNum = 0 then
      exit;

    dt := interval * 65536 / 5000000; // 20Mhz / 4
    AssignFile(f, self.filePath);
    ReWrite(f);
    WriteLn(f, firstLine);

  try
  firstLine := '0';
  chanInLine := 0;

  for i := 0 to 8191 do
  begin
    HIDSendReport(ReadFromExtMem, (i * 8) shr 8 , byte(i * 8), 0, 0, 0, 0, 0);
    HIDReadReport(@res[0],@res[1],@res[2],@res[3],@res[4],@res[5],@res[6],@res[7]);

    for j := 0 to 3 do
    begin
      temp := res[j*2] shl 8 + res[j*2 + 1];
      if temp = $ffff then
      begin
        CloseFile(f);
        exit;
      end;
      firstLine := firstLine + ';' + IntToStr(temp);
      Inc(chanInLine);
      if (chanInLine = chanNum) then
      begin
         WriteLn(f, firstLine);
         chanInLine := 0;
         Inc(curt);
         firstLine := FloatToStr(curt * dt);
      end;
    end;
  end;

  except
  on Exception : EAccessViolation do
  begin
    CloseFile(f);
    exit;
  end;
  end;
  CloseFile(f);
end;

function TReadFromExtEEprom.GetName: string;
begin
  Result := 'Read from external eeprom';
end;

function TReadFromExtEEprom.Initialize: boolean;
var res : Array[0..7] of Byte;
begin
  if (HID_Detected = 0) then
  begin
    Result := false;
    exit;
  end;

  Result := true;

  try

  HIDSendReport(StopOfflineReading, 0, 0, 0, 0, 0, 0, 0);
  HIDSendReport(ReadOfflineIntervalAndMask, 0, 0, 0, 0, 0, 0, 0);
  HIDReadReport(@res[0],@res[1],@res[2],@res[3],@res[4],@res[5],@res[6],@res[7]);
  self.interval := res[0];
  interval := (interval shl 8) + res[1];
  self.channelsMask := res[2]
  except
  on Exception : EAccessViolation do
  begin
    Result := false;
    exit;
  end;
  end;
end;

function TReadFromExtEEprom.NeedExecute: boolean;
begin
  Result := true;
end;

function TReadFromExtEEprom.NeedSendInitialization: boolean;
begin
  Result := true;
end;

function TReadFromExtEEprom.ShowForm: integer;
var
  saveForm : TSaveDialog;
begin
  Result := MrNo;
  saveForm := TSaveDialog.Create(nil);
  saveForm.Title := 'Save adc data';
  if saveForm.Execute then
  begin
    self.filePath := saveForm.FileName;
    Result := MrYes;
  end;
end;



procedure TSimpleUsbDevice.Connect(
  connectionCallback: IConnectionCallback);
{ TReadFromExtEEprom }
begin
  m_connectionCallback := connectionCallback;
  Set_HID_VendorID($1234);
  Set_HID_ProductID($1234);
  HIDConnect;
  if (HID_Detected = 0) then
    m_connectionCallback.OnErrorOnConnection
  else
  begin
    self.connected := true;
    m_connectionCallback.OnConnected;
  end;
end;

constructor TSimpleUsbDevice.Create;
begin
  self.connected := false;

  commands := TList.Create;
  commands.Add(Pointer(ICommandInfo(TSetPort.Create)));
  commands.Add(Pointer(ICommandInfo(TConfigureAdc.Create)));
  commands.Add(Pointer(ICommandInfo(TSetExtEEprom.Create)));
  commands.Add(Pointer(ICommandInfo(TWriteADCToExtEEprom.Create)));
  commands.Add(Pointer(ICommandInfo(TReadFromExtEEprom.Create)));
end;

procedure TSimpleUsbDevice.Disconnect;
begin
  self.connected := false;
end;

function TSimpleUsbDevice.GetCommandInfo(
  commandNumber: integer): ICommandInfo;
begin
  Result := ICommandInfo(commands[commandNumber]);
  Result._AddRef;
end;

function TSimpleUsbDevice.GetCommandsNumber: integer;
begin
  Result := commands.Count;
end;

function TSimpleUsbDevice.GetInputLinesNumber: integer;
begin
  Result := 5;
end;

function TSimpleUsbDevice.GetMaximumValInInputLine(
  lineNumber: integer): integer;
begin
  Result := 1023;
end;

function TSimpleUsbDevice.GetMaxInputLinesNumberPerRequest: integer;
begin
  Result := 4;
end;

function TSimpleUsbDevice.GetMinimumValInInputLine(
  lineNumber: integer): integer;
begin
  Result := 0;
end;

function TSimpleUsbDevice.GetName: string;
begin
  Result := 'Simple usb';
end;

function TSimpleUsbDevice.IsConnected: boolean;
begin
  Result := (HID_Detected <> 0) and self.connected;
end;

function TSimpleUsbDevice.ReadFromInputLine(lineNumber: integer;
  var output: TBytesArray): boolean;
var res : Array[0..7] of Byte;
begin
  if (HID_Detected = 0) then
  begin
    Result := false;
    exit;
  end;

  Result := true;

  try
  HIDSendReport(ReadFromAdc, Byte(lineNumber), 0, 0, 0, 0, 0, 0);
  HIDReadReport(@res[0],@res[1],@res[2],@res[3],@res[4],@res[5],@res[6],@res[7]);
  except
  on Exception : EAccessViolation do
  begin
    Result := false;
    self.connected := false;
    self.m_connectionCallback.OnDisconnected;
    exit;
  end;
  end;

  SetLength(output, 2);
  output[0] := res[0];
  output[1] := res[1];
end;

function TSimpleUsbDevice.ReadFromInputLines(var lineNumbers: TLineIndexesArray;
  var output: TBytesArray): boolean;
var sendArr : Array[0..7] of Byte;
var res : Array[0..7] of Byte;
var i : integer;
begin
  if (HID_Detected = 0) then
  begin
    Result := false;
    exit;
  end;

  sendArr[0] := ReadFromAdcs;

  for i := 0 to Length(lineNumbers) - 1 do
  begin
    sendArr[i + 1] := lineNumbers[i];
  end;

  sendArr[Length(lineNumbers) + 1] := $ff;

  Result := true;

  try
  HIDSendReport(sendArr[0],sendArr[1],sendArr[2],sendArr[3],sendArr[4],sendArr[5],sendArr[6],sendArr[7]);
  HIDReadReport(@res[0],@res[1],@res[2],@res[3],@res[4],@res[5],@res[6],@res[7]);
  except
  on Exception : EAccessViolation do
  begin
    Result := false;
    self.connected := false;
    self.m_connectionCallback.OnDisconnected;
    exit;
  end;
  end;

  SetLength(output, Length(lineNumbers) * 2);
  Move(res, output[0], 2 * Length(lineNumbers));

end;

procedure TSimpleUsbDevice.ShowAbout;
begin

end;

{ TSetPort }

constructor TSetPort.Create;
begin
  _AddRef;
  self.canExecute := false;
  pins := TList.Create;
  pins.Add(TPinInfo.Create('B2', 1, 2));
  pins.Add(TPinInfo.Create('B3', 1, 3));
  pins.Add(TPinInfo.Create('B4', 1, 4));
  pins.Add(TPinInfo.Create('B5', 1, 5));
  pins.Add(TPinInfo.Create('B6', 1, 6));
  pins.Add(TPinInfo.Create('B7', 1, 7));

  pins.Add(TPinInfo.Create('C0', 2, 0));
  pins.Add(TPinInfo.Create('C1', 2, 1));
  pins.Add(TPinInfo.Create('C2', 2, 2));
end;

procedure TSetPort.Execute;
var
  mask : byte;
begin
  if (HID_Detected = 0) or not self.canExecute then
    exit;

  mask := 1 shl self.choosenPin;
  if (self.choosenVal = 0) then
    mask := not mask;
  try
  HIDSendReport(SetDigitalPin, self.choosenPort, mask, self.choosenVal, 0, 0, 0, 0);
  except
  on Exception : EAccessViolation do
  begin
    exit;
  end;
  end;
end;

function TSetPort.GetName: string;
begin
   Result := 'Set digital port';
end;

function TSetPort.Initialize : boolean;
begin
  Result := true;
end;

function TSetPort.NeedExecute: boolean;
begin
  Result := true;
end;

function TSetPort.NeedSendInitialization: boolean;
begin
  Result := false;
end;

function TSetPort.ShowForm: integer;
var
  chooseForm : TSetPinForm;
  i : integer;
  choosenIndex : integer;
  res : integer;
begin
  Result := MrNo;
  chooseForm := TSetPinForm.Create(nil);
  for i := 0 to pins.Count - 1 do
  begin
    chooseForm.pinChoose.Items.Add(TPinInfo(pins[i]).GetDescription);
  end;

  res := chooseForm.ShowModal;
  if (res = MrYes) then
  begin
    choosenIndex := chooseForm.pinChoose.ItemIndex;
    if choosenIndex <> -1 then
    begin
      self.choosenPort := TPinInfo(pins[choosenIndex]).port;
      self.choosenPin := TPinInfo(pins[choosenIndex]).pin;
      self.choosenVal := chooseForm.digitalVal.ItemIndex;
      if choosenVal = -1 then
        choosenVal := 0;
      self.canExecute := true;
      Result := MrYes;
    end;
  end;
end;

{ TPinInfo }

constructor TPinInfo.Create(descr: string; portNum, pinNum: integer);
begin
  self.description := descr;
  self.port := portNum;
  self.pin := pinNum;
end;

function TPinInfo.GetDescription: string;
begin
  Result := self.description;
end;

function TPinInfo.GetPinNum: integer;
begin
  Result := self.pin;
end;

function TPinInfo.GetPortNum: integer;
begin
  Result := self.port;
end;

{ TConfigureAdc }

procedure TConfigureAdc.Execute;
var
  adcCon1 : byte;
begin
  if (HID_Detected = 0) then
  begin
    exit;
  end;

  adcCon1 := $09;
  if not isVdd then
    adcCon1 := adcCon1 or $10;

  if not isVss then
    adcCon1 := adcCon1 or $20;

  try
  HIDSendReport(SetAdcon1, adcCon1, 0, 0, 0, 0, 0, 0);
  except
  on Exception : EAccessViolation do
  begin
    exit;
  end;
  end;

end;

function TConfigureAdc.GetName: string;
begin
  Result := 'ADC settings';
end;

function TConfigureAdc.Initialize: boolean;
var res : Array[0..7] of Byte;
begin
  if (HID_Detected = 0) then
  begin
    Result := false;
    exit;
  end;

  Result := true;

  try
  HIDSendReport(GetAdcon1, 0, 0, 0, 0, 0, 0, 0);
  HIDReadReport(@res[0],@res[1],@res[2],@res[3],@res[4],@res[5],@res[6],@res[7]);
  except
  on Exception : EAccessViolation do
  begin
    Result := false;
    exit;
  end;
  end;

  self.isVss := (res[0] and $20) = 0;
  self.isVdd := (res[0] and $10) = 0;
end;

function TConfigureAdc.NeedExecute: boolean;
begin
  Result := true;
end;

function TConfigureAdc.NeedSendInitialization: boolean;
begin
  Result := true;
end;

function TConfigureAdc.ShowForm: integer;
var
  adcSettings : TAdcSettingsForm;
begin
  adcSettings := TAdcSettingsForm.Create(nil);
  adcSettings.SetVssFlag(isVss);
  adcSettings.SetVddFlag(isVdd);

  Result := adcSettings.ShowModal;
  isVss := adcSettings.IsVss;
  isVdd := adcSettings.IsVdd;
end;

{ TSetExtEEprom }

procedure TSetExtEEprom.Execute;
begin
  if (HID_Detected = 0) then
  begin
    exit;
  end;

  try
  HIDSendReport(SetExtEepromSize, extEEpromSize shr 8, byte(extEEpromSize), 0, 0, 0, 0, 0);
  except
  on Exception : EAccessViolation do
  begin
    exit;
  end;
  end;

end;

function TSetExtEEprom.GetName: string;
begin
  Result := 'Set external eeprom size'
end;

function TSetExtEEprom.Initialize: boolean;
var res : Array[0..7] of Byte;
begin
  if (HID_Detected = 0) then
  begin
    Result := false;
    exit;
  end;

  Result := true;

  try
  HIDSendReport(ReadExtEepromSize, 0, 0, 0, 0, 0, 0, 0);
  HIDReadReport(@res[0],@res[1],@res[2],@res[3],@res[4],@res[5],@res[6],@res[7]);
  except
  on Exception : EAccessViolation do
  begin
    Result := false;
    exit;
  end;
  end;

  self.extEEpromSize := res[0];
  extEEpromSize := (extEEpromSize shl 8) + res[1];
end;

function TSetExtEEprom.NeedExecute: boolean;
begin
  Result := true;
end;

function TSetExtEEprom.NeedSendInitialization: boolean;
begin
  Result := true;
end;

function TSetExtEEprom.ShowForm: integer;
var
  setValForm : TSetValForm;
begin
  setValForm := TSetValForm.Create(nil);
  setValForm.valEdit.Text := IntToStr(self.extEEpromSize);
  setValForm.valDescr.Caption := 'External eeprom size, bytes';

  Result := MrNo;
  if (setValForm.ShowModal = MrYes) then
  begin
    try
    self.extEEpromSize := StrToInt(setValForm.valEdit.Text);
    Result := MrYes;
    except
    on Exception : EConvertError do
      exit
    end;
  end;
end;

{ TWriteADCToExtEEprom }

procedure TWriteADCToExtEEprom.Execute;
begin
  if (HID_Detected = 0) then
  begin
    exit;
  end;

  try
  HIDSendReport(WriteToExtEeprom, self.interval shr 8, byte(self.interval), self.channelsMask, self.writeMode, 0, 0, 0);
  except
  on Exception : EAccessViolation do
  begin
    exit;
  end;
  end;
end;

function TWriteADCToExtEEprom.GetName: string;
begin
  Result := 'Write adc data to external eeprom';
end;

function TWriteADCToExtEEprom.Initialize: boolean;
begin
  Result := true;
end;

function TWriteADCToExtEEprom.NeedExecute: boolean;
begin
  Result := true;
end;

function TWriteADCToExtEEprom.NeedSendInitialization: boolean;
begin
  Result := false;
end;

function TWriteADCToExtEEprom.ShowForm: integer;
var
 writeToExtEepromForm : TWriteToExtEepromForm;
begin
  writeToExtEepromForm := TWriteToExtEepromForm.Create(nil);
  Result := MrNo;
  if writeToExtEepromForm.ShowModal = MrYes then
  begin
    try
    self.interval := StrToInt(writeToExtEepromForm.intervalEdit.Text);
    self.writeMode := writeToExtEepromForm.writeMode.ItemIndex;
    self.channelsMask := 0;
    if writeToExtEepromForm.Channel1.Checked then
      channelsMask := channelsMask or $01;
    if writeToExtEepromForm.Channel2.Checked then
      channelsMask := channelsMask or $02;
    if writeToExtEepromForm.Channel3.Checked then
      channelsMask := channelsMask or $04;
    if writeToExtEepromForm.Channel4.Checked then
      channelsMask := channelsMask or $08;
    if writeToExtEepromForm.Channel5.Checked then
      channelsMask := channelsMask or $10;

    if channelsMask = 0 then
      exit;

    Result := MrYes;
    except
    on Exception : EConvertError do
      exit
    end;
  end;

end;

end.
