unit RecorderControl;
// Recorder's gui. separates gui from logic, the logic is in the Recorder class (Recorder.pas)

interface

uses Chart, Controls, Classes, Series, Graphics, Menus, SetNewValForm, SysUtils, TeeProcs;

type

IRecorderControlCallback = interface
  procedure SetRelativeMeasure;
  procedure SetAbsoluteMeasure;
  procedure AddChannel;
  procedure RemoveChannel;
  procedure DeleteRecorder;
end;

TRecorderControl = class(TChart)
public

constructor Create(AOwner: TComponent); override;
procedure AddPointToGraphLine(inputLineNumber : integer; x : double; y : double);
procedure RenameGraphLine(inputLineNumber : integer; name : string);
procedure SetGraphWidth(inputLineNumber : integer; newWidth : integer);
procedure SetGraphColor(inputLineNumber : integer; newColor : TColor);
function AddGraphLine(inputLineNumber : integer; graphName : string; graphColor : TColor) : integer;
procedure DeleteGraphLine(inputLineNumber : integer);

function GetDisplayInterval() : double;
procedure SetDisplayInterval(interval : double);

procedure ChangeInterval(Sender: TObject);
procedure RelativeMeasure(Sender: TObject);
procedure AbsoluteMeasure(Sender: TObject);
procedure AddChannel(Sender: TObject);
procedure RemoveChannel(Sender: TObject);
procedure DeleteThisRecorder(Sender: TObject);


procedure SetGuiCallback(callback : IRecorderControlCallback);
function HasInputLineGraph(inputLineNumber : integer) : boolean;

private
  displayInterval : double;
  controlSeriesNumbers : Array of integer;
  guiCallback : IRecorderControlCallback;

  procedure MaintainControlSeriesNumbers;
end;

implementation

{ TRecorderControl }

procedure TRecorderControl.AbsoluteMeasure(Sender: TObject);
begin
  self.guiCallback.SetAbsoluteMeasure;
end;

procedure TRecorderControl.AddChannel(Sender: TObject);
begin
  self.guiCallback.AddChannel;
end;

function TRecorderControl.AddGraphLine(inputLineNumber : integer; graphName: string; graphColor : TColor): integer;
var series : TLineSeries;
begin
  Result := 0;
  if HasInputLineGraph(inputLineNumber) then
    exit;

  Result := self.SeriesCount;
  series := TLineSeries.Create(self);
  series.Title := graphName;
  series.Color := graphColor;
  series.Tag := inputLineNumber;
  AddSeries(series);

  self.MaintainControlSeriesNumbers;
end;

procedure TRecorderControl.AddPointToGraphLine(inputLineNumber: integer; x,
  y: double);
var seriesNum : integer;
begin
  seriesNum := controlSeriesNumbers[inputLineNumber];
  if (seriesNum >= self.SeriesCount) then
    exit;

  Series[seriesNum].AddXY(x, y);

  while ((Series[seriesNum].ValuesList[0].Count > 0) and
   ((x - Series[seriesNum].ValuesList[0].Value[0]) > self.displayInterval)) do
  begin
    Series[seriesNum].Delete(0);
  end;
end;

procedure TRecorderControl.ChangeInterval(Sender: TObject);
var setIntervalForm : TNewValForm;
begin
  try
  setIntervalForm := TNewValForm.Create(self);
  setIntervalForm.Caption := 'Set interval';
  setIntervalForm.SetPreviousVal(FloatToStr(displayInterval));
  setIntervalForm.ShowModal;
  if (setIntervalForm.GetNewVal <> '') then
  begin
    displayInterval := StrToFloat(setIntervalForm.GetNewVal);
  end;
  except
  on Exception : EConvertError do
    exit
  end;
end;

constructor TRecorderControl.Create(AOwner: TComponent);
var
  popupMenu : TPopupMenu;
  menuItem: TMenuItem;
begin
  inherited;
  View3D := false;
  Legend.LegendStyle := lsSeries;
  Legend.Visible := true;
  self.displayInterval := 10;
  self.AllowZoom := false;
  self.AllowPanning := pmNone;

  popupMenu := TPopupMenu.Create(self);
  menuItem := TMenuItem.Create(self);
  menuItem.Caption := 'Change view interval';
  menuItem.OnClick := ChangeInterval;
  popupMenu.Items.Add(menuItem);

  menuItem := TMenuItem.Create(self);
  menuItem.Caption := 'View relatively to a channel';
  menuItem.OnClick := self.RelativeMeasure;
  popupMenu.Items.Add(menuItem);

  menuItem := TMenuItem.Create(self);
  menuItem.Caption := 'Absolute values';
  menuItem.OnClick := self.AbsoluteMeasure;
  popupMenu.Items.Add(menuItem);

  menuItem := TMenuItem.Create(self);
  menuItem.Caption := 'Add a channel';
  menuItem.OnClick := self.AddChannel;
  popupMenu.Items.Add(menuItem);

  menuItem := TMenuItem.Create(self);
  menuItem.Caption := 'Remove a channel';
  menuItem.OnClick := self.RemoveChannel;
  popupMenu.Items.Add(menuItem);

  menuItem := TMenuItem.Create(self);
  menuItem.Caption := 'Remove the recorder';
  menuItem.OnClick := self.DeleteThisRecorder;
  popupMenu.Items.Add(menuItem);


  self.PopupMenu := popupMenu;
end;

procedure TRecorderControl.DeleteGraphLine(inputLineNumber: integer);
var serNum : integer;
begin
  if not HasInputLineGraph(inputLineNumber) then
    exit;
  serNum := self.controlSeriesNumbers[inputLineNumber];
  self.RemoveSeries(serNum);
  self.MaintainControlSeriesNumbers;
end;

procedure TRecorderControl.DeleteThisRecorder(Sender: TObject);
begin
  self.guiCallback.DeleteRecorder;
end;

function TRecorderControl.GetDisplayInterval: double;
begin
  Result := self.displayInterval;
end;

function TRecorderControl.HasInputLineGraph(
  inputLineNumber: integer): boolean;
var i : integer;
begin
  Result := false;
  for i := 0 to self.SeriesCount -1 do
  begin
    if Series[i].Tag = inputLineNumber then
    begin
      Result := true;
      exit;
    end;
  end;
end;

procedure TRecorderControl.MaintainControlSeriesNumbers;
var i : integer;
begin
  SetLength(self.controlSeriesNumbers, 0);
  for i := 0 to self.SeriesCount -1 do
  begin
    if (Length(self.controlSeriesNumbers) <= self.Series[i].Tag) then
      SetLength(self.controlSeriesNumbers, self.Series[i].Tag + 1);

    self.controlSeriesNumbers[self.Series[i].Tag] := i;
  end;
end;

procedure TRecorderControl.RelativeMeasure(Sender: TObject);
begin
  self.guiCallback.SetRelativeMeasure;
end;

procedure TRecorderControl.RemoveChannel(Sender: TObject);
begin
  self.guiCallback.RemoveChannel;
end;

procedure TRecorderControl.RenameGraphLine(inputLineNumber: integer;
  name: string);
var serNum : integer;
begin
  if not HasInputLineGraph(inputLineNumber) then
    exit;
  serNum := self.controlSeriesNumbers[inputLineNumber];

  self.Series[serNum].Title := name;
end;

procedure TRecorderControl.SetDisplayInterval(interval: double);
begin
  self.displayInterval := interval;
end;

procedure TRecorderControl.SetGraphColor(inputLineNumber: integer;
  newColor: TColor);
var serNum : integer;
begin
  if not HasInputLineGraph(inputLineNumber) then
    exit;
  serNum := self.controlSeriesNumbers[inputLineNumber];

  (TLineSeries(Series[serNum])).Color := newColor;
end;

procedure TRecorderControl.SetGraphWidth(inputLineNumber: integer;
  newWidth: integer);
var serNum : integer;
begin
  if not HasInputLineGraph(inputLineNumber) then
    exit;
  serNum := self.controlSeriesNumbers[inputLineNumber];

  (TLineSeries(Series[serNum])).LinePen.Width := newWidth;
end;

procedure TRecorderControl.SetGuiCallback(
  callback: IRecorderControlCallback);
begin
  self.guiCallback := callback;
end;

end.
