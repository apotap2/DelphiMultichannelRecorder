unit AdcSettings;
// "Adc settings" form. Used in "simple usb device" commands.

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TAdcSettingsForm = class(TForm)
    GroupBox1: TGroupBox;
    Vss: TRadioButton;
    VrefMinus: TRadioButton;
    GroupBox2: TGroupBox;
    Vdd: TRadioButton;
    VRefPlus: TRadioButton;
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    function IsVss : boolean;
    function IsVdd : boolean;

    procedure SetVssFlag(flag : boolean);
    procedure SetVddFlag(flag : boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AdcSettingsForm: TAdcSettingsForm;

implementation

{$R *.dfm}

procedure TAdcSettingsForm.Button1Click(Sender: TObject);
begin
  self.ModalResult := MrYes;
end;

procedure TAdcSettingsForm.Button2Click(Sender: TObject);
begin
  self.ModalResult := MrNo;
end;

function TAdcSettingsForm.IsVdd: boolean;
begin
  Result := self.Vdd.Checked;
end;

function TAdcSettingsForm.IsVss: boolean;
begin
  Result := self.Vss.Checked;
end;

procedure TAdcSettingsForm.SetVddFlag(flag: boolean);
begin
  self.Vdd.Checked := flag;
  self.VRefPlus.Checked := not flag;
end;

procedure TAdcSettingsForm.SetVssFlag(flag: boolean);
begin
  self.Vss.Checked := flag;
  self.VrefMinus.Checked := not flag;
end;

end.
