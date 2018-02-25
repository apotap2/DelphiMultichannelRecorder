unit SelectChannelForm;
// Select channel form. Used in add/remove input line (channel).


interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TChannelsForm = class(TForm)
    ComboBox1: TComboBox;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);

    procedure AddChannel(channelName : string; inDeviceIndex : integer);
    function ChannelSelected : boolean;
    function SelectedChannelIndex : integer;

  private
    { Private declarations }
    deviceIndexes : Array of integer;
  public
    { Public declarations }
  end;

var
  ChannelsForm: TChannelsForm;

implementation

{$R *.dfm}

procedure TChannelsForm.AddChannel(channelName: string; inDeviceIndex : integer);
begin
  self.ComboBox1.Items.Add(channelName);
  SetLength(deviceIndexes, Length(deviceIndexes) + 1);
  deviceIndexes[Length(deviceIndexes) - 1] := inDeviceIndex;
end;

procedure TChannelsForm.Button1Click(Sender: TObject);
begin
  self.ModalResult := MrYes;
end;

function TChannelsForm.ChannelSelected: boolean;
begin
  Result := self.ComboBox1.ItemIndex <> -1;
end;

function TChannelsForm.SelectedChannelIndex: integer;
begin
  Result := self.deviceIndexes[self.ComboBox1.ItemIndex];
end;

end.
