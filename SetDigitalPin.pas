unit SetDigitalPin;
// Set digital pin form, used in simple usb device's command.

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TSetPinForm = class(TForm)
    pinChoose: TComboBox;
    digitalVal: TComboBox;
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SetPinForm: TSetPinForm;

implementation

{$R *.dfm}

procedure TSetPinForm.Button1Click(Sender: TObject);
begin
  ModalResult := MrYes;
end;

procedure TSetPinForm.Button2Click(Sender: TObject);
begin
  ModalResult := MrNo;
end;

end.
