unit EmulatorDevice;
// Emulator device, implements IBaseRequestOnlyDevice (look into BaseDevice.pas)
// There are no commands, it just generate random data.


interface

uses
  BaseDevice, SysUtils, ExtCtrls, Classes, Forms;

type
  TEmulatorDevice = class (TInterfacedObject, IBaseRequestOnlyDevice)
  public
    Constructor Create(mainForm : TForm);

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
    connected : boolean;
    connectionCallback : IConnectionCallback;

    timer : TTimer;
    connectionProgress : integer;
    connecting : boolean;

    procedure OnTimer(Sender: TObject);
  end;

implementation


{ TEmulatorDevice }

procedure TEmulatorDevice.Connect(connectionCallback: IConnectionCallback);
begin
  connecting := true;
  self.connectionProgress := 0;
  self.connectionCallback := connectionCallback;
  self.connectionCallback.OnConnectionProgress(connectionProgress);
  self.connectionCallback.OnConnectionStatusMessage('connecting');
  timer.Enabled := true;
end;

constructor TEmulatorDevice.Create(mainForm : TForm);
begin
  connecting := false;
  connectionProgress := 0;
  timer := TTimer.Create(mainForm);
  timer.Interval := 500;
  timer.Enabled := false;
  timer.OnTimer := OnTimer;
  self.connected := false;
end;

procedure TEmulatorDevice.Disconnect;
begin
  self.connecting := false;
  self.timer.Enabled := false;
  self.connected := false;
end;

function TEmulatorDevice.GetCommandInfo(
  commandNumber: integer): ICommandInfo;
begin

end;

function TEmulatorDevice.GetCommandsNumber: integer;
begin
  Result := 0;
end;

function TEmulatorDevice.GetInputLinesNumber: integer;
begin
   Result := 5;
end;

function TEmulatorDevice.GetMaximumValInInputLine(
  lineNumber: integer): integer;
begin
  Result := 62;
end;

function TEmulatorDevice.GetMaxInputLinesNumberPerRequest: integer;
begin
  Result := 4;
end;

function TEmulatorDevice.GetMinimumValInInputLine(
  lineNumber: integer): integer;
begin
  Result := 10;
end;

function TEmulatorDevice.GetName: string;
begin
  Result := 'Emulator';
end;

function TEmulatorDevice.IsConnected: boolean;
begin
   Result := connected;
end;

procedure TEmulatorDevice.OnTimer(Sender: TObject);
begin
  self.connectionProgress := self.connectionProgress + 10;
  if (connectionProgress >= 100) then
  begin
    self.connected := true;
    self.timer.Enabled := false;
    self.connectionCallback.OnConnected;
  end
  else
    self.connectionCallback.OnConnectionProgress(connectionProgress);
end;

function TEmulatorDevice.ReadFromInputLine(lineNumber: integer;
  var output: TBytesArray): boolean;

begin
  Sleep(30);
  SetLength(output, 1);
  output[0] := Random(51) + 10;
  Result := true;
end;

function TEmulatorDevice.ReadFromInputLines(var lineNumbers: TLineIndexesArray;
  var output: TBytesArray): boolean;
var i : integer;
begin
  Sleep(50);
  SetLength(output, Length(lineNumbers));
  for i := 0 to Length(lineNumbers) -1 do
    output[i] := Random(51) + 10;
  Result := true;
end;

procedure TEmulatorDevice.ShowAbout;
begin

end;

end.
