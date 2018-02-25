unit WriteToExtEeprom;
// Write to external eeprom form, used in the simple usb device's command.

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TWriteToExtEepromForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Channel1: TCheckBox;
    Channel2: TCheckBox;
    Channel3: TCheckBox;
    Channel4: TCheckBox;
    Channel5: TCheckBox;
    IntervalEdit: TEdit;
    Label1: TLabel;
    writeMode: TComboBox;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  WriteToExtEepromForm: TWriteToExtEepromForm;

implementation

{$R *.dfm}

procedure TWriteToExtEepromForm.Button1Click(Sender: TObject);
begin
  self.ModalResult := MrYes;
end;

procedure TWriteToExtEepromForm.Button2Click(Sender: TObject);
begin
  self.ModalResult := MrNo;
end;

end.
