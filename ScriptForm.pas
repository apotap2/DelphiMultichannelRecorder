unit ScriptForm;
// Script form, used in input line's (channel) calibration.

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TScriptEditor = class(TForm)
    ScriptMemo: TMemo;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ScriptEditor: TScriptEditor;

implementation

{$R *.dfm}

procedure TScriptEditor.Button1Click(Sender: TObject);
begin
  self.ModalResult := MrYes;
end;

procedure TScriptEditor.Button2Click(Sender: TObject);
begin
  self.ModalResult := MrNo;
end;

end.
