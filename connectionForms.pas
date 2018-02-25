unit connectionForms;
// "Connecting" form. Shows progress of connection.

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ComCtrls;

type
  TconnectionForm = class(TForm)
    ProgressBar1: TProgressBar;
    BitBtn1: TBitBtn;
    StaticText1: TStaticText;
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  FOnCancelConnection : TNotifyEvent;
  public
    { Public declarations }
    property OnCancelConnection : TNotifyEvent read FOnCancelConnection write FOnCancelConnection;

    procedure SetProgress(value : integer);
    procedure SetConnectionStatusMessage(message : string);
  end;

var
  connectionForm: TconnectionForm;

implementation

{$R *.dfm}

procedure TconnectionForm.BitBtn1Click(Sender: TObject);
begin
  if Assigned(FOnCancelConnection) then FOnCancelConnection(Self);
  self.ModalResult := MrNo;
end;

procedure TconnectionForm.SetConnectionStatusMessage(message: string);
begin
  self.StaticText1.Caption := message;
end;

procedure TconnectionForm.SetProgress(value: integer);
begin
  self.ProgressBar1.Position := value;
end;

end.
