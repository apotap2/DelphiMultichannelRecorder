unit SetNewValForm;
// Set new val form, used in different places.

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TNewValForm = class(TForm)

    Edit1: TEdit;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function GetNewVal() : string;
    procedure SetPreviousVal(val : string);
  end;

var
  NewValForm: TNewValForm;

implementation

{$R *.dfm}

procedure TNewValForm.Button1Click(Sender: TObject);
begin
  self.ModalResult := mrYes;
end;

function TNewValForm.GetNewVal: string;
begin
  Result := self.Edit1.Text;
end;

procedure TNewValForm.SetPreviousVal(val: string);
begin
  self.Edit1.Text := val;
end;

end.
