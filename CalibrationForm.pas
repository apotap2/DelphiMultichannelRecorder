unit CalibrationForm;
// "Calibration" form. Used in "simple usb device" commands.

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TCalibrationChannelForm = class(TForm)
    offset: TEdit;
    multiplier: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CalibrationChannelForm: TCalibrationChannelForm;

implementation

{$R *.dfm}

procedure TCalibrationChannelForm.Button1Click(Sender: TObject);
begin
  self.ModalResult := MrYes;
end;

end.
