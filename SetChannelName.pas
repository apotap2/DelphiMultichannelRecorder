unit SetChannelName;
// Set channel name form. Used in input line(channel) settings.

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TChannelNameVal = class(TForm)

    Edit1: TEdit;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function GetNewName() : string;
    procedure SetPreviousName(name : string);
  end;

var
  ChannelNameVal: TChannelNameVal;

implementation

{$R *.dfm}

procedure TChannelNameVal.Button1Click(Sender: TObject);
begin
  self.ModalResult := mrYes;
end;

function TChannelNameVal.GetNewName: string;
begin
  Result := self.Edit1.Text;
end;

procedure TChannelNameVal.SetPreviousName(name: string);
begin
  self.Edit1.Text := name;
end;

end.
