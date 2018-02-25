unit BaseDevice;
// This module has an abstract device interface the program will work with.
// Each device should have it implementation. Also it has an abstraction of
// command info.

interface

type TBytesArray = Array of Byte;
type TLineIndexesArray = Array of Integer;

type IConnectionCallback = interface
  // A device will get this interface and call it on some events.
  // Callbacks names are self describing.
  procedure OnConnected;
  procedure OnConnectionStatusMessage(message: string);
  procedure OnConnectionProgress(percent: integer);
  procedure OnDisconnected;
  procedure OnErrorOnConnection;
end;

type ICommandInfo = interface
  // Command interface
  // Command for a device
  // Commands can show forms, these forms can be used to show some data or get input from an operator
  // The form is shown in the gui thread
  //
  // Some commands want to send initialization before showing the form.
  // This initialization will be done in the interrogation thread.
  //
  // Some commands want to execute some interrogation after showing the form.
  // It will be done in the interrogation thread.

  function GetName() : string;
  function NeedSendInitialization() : boolean;
  function ShowForm() : integer; //  show a form, the form should return MrYes or MrNo. MrNo means "don't execute"
  function NeedExecute() : boolean;
  procedure Execute;
  function Initialize : boolean;
end;

type IBaseRequestOnlyDevice = interface
  // An interface for request only device. Such device can't spam with data, it can be only requested to send data
  // Input line here is a data provider, most probably it will be adc.
  function GetName() : string;
  function IsConnected() : boolean;
  procedure Connect(connectionCallback: IConnectionCallback);
  procedure Disconnect;
  function GetInputLinesNumber() : integer;
  function GetMinimumValInInputLine(lineNumber : integer) : integer; // Minimal value that the input line can send.
  function GetMaximumValInInputLine(lineNumber : integer) : integer; // Maximum value that the input line can send.
  function ReadFromInputLine(lineNumber: integer; var output : TBytesArray) : boolean;
  function GetMaxInputLinesNumberPerRequest () : integer; // Maximum input lines that can be requested to send data.
  function ReadFromInputLines(var lineNumbers : TLineIndexesArray; var output : TBytesArray) : boolean;
  function GetCommandsNumber() : integer;
  function GetCommandInfo(commandNumber : integer) : ICommandInfo;
  procedure ShowAbout;
end;

implementation

end.
