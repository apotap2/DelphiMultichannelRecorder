unit Unit1;
// Recorder form.


interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, TeEngine, Series, ExtCtrls, TeeProcs, Chart,
  Menus, TeePolar, ComCtrls;

type
  TForm1 = class(TForm)
    Chart1: TChart;
    BitBtn1: TBitBtn;
    Series1: TLineSeries;
    Timer1: TTimer;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    Help1: TMenuItem;
    StatusBar1: TStatusBar;
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.BitBtn1Click(Sender: TObject);
var
i:integer;
begin
Series1.Clear;
 for i:=0 to 22 do
 begin
  Series1.AddXY(i*0.29,10*sin(i*0.29),'',clGreen);
 end;
end;

const Count = 50;

procedure TForm1.FormCreate(Sender: TObject);
var i: integer;
begin
  Series1.Clear;


  for i := 0 to Count do
    Series1.Add(Random(100));
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var i: integer;
begin
  for i := 0 to Count-1 do
    Series1.ValuesList[1].Value[i] := Series1.ValuesList[1].Value[i+1];
  Series1.ValuesList[1].Value[Count] := Random(100);
  Chart1.Invalidate;

end;

end.
