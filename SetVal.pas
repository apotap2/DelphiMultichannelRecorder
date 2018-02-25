unit SetVal;
// Set val form, used in different places.

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TSetValForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    valEdit: TEdit;
    valDescr: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SetValForm: TSetValForm;

implementation

{$R *.dfm}

procedure TSetValForm.Button1Click(Sender: TObject);
begin
  self.ModalResult := MrYes;
end;

procedure TSetValForm.Button2Click(Sender: TObject);
begin
  self.ModalResult := MrNo;
end;

end.
