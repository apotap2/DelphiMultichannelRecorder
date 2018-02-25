program Project1;

uses
  Forms,
  MainForm in 'MainForm.pas' {MainProgramForm},
  BaseDevice in 'BaseDevice.pas',
  SimpleUsbDevice in 'SimpleUsbDevice.pas',
  EmulatorDevice in 'EmulatorDevice.pas',
  Recorder in 'Recorder.pas',
  RecorderControl in 'RecorderControl.pas',
  Engine in 'Engine.pas',
  mainGui in 'mainGui.pas',
  DeviceWrapper in 'DeviceWrapper.pas',
  InputLine in 'InputLine.pas',
  SetNewValForm in 'SetNewValForm.pas' {NewValForm},
  ChooseChannelForm in 'ChooseChannelForm.pas',
  SelectChannelForm in 'SelectChannelForm.pas' {ChannelsForm},
  InputLineInterfaces in 'InputLineInterfaces.pas',
  CalibrationForm in 'CalibrationForm.pas' {CalibrationChannelForm},
  PIC18SimulatorDllHelper in 'PIC18SimulatorDllHelper.pas',
  connectionForms in 'connectionForms.pas' {connectionForm},
  ScriptForm in 'ScriptForm.pas' {ScriptEditor},
  SetDigitalPin in 'SetDigitalPin.pas' {SetPinForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainProgramForm, MainProgramForm);
  Application.CreateForm(TNewValForm, NewValForm);
  Application.CreateForm(TChannelsForm, ChannelsForm);
  Application.CreateForm(TCalibrationChannelForm, CalibrationChannelForm);
  Application.CreateForm(TconnectionForm, connectionForm);
  Application.CreateForm(TScriptEditor, ScriptEditor);
  Application.CreateForm(TSetPinForm, SetPinForm);
  Application.Run;
end.
