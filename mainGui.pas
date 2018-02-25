unit mainGui;
// main gui form


interface
  uses Forms;

type IMainGui = interface
  procedure RedrawRecorders;
  procedure UpdateMenus;
  function GetForm() : TForm;
  procedure ShowConnectionForm;
  procedure HideConnectionForm;
  procedure SetConnectionProgress(progress : integer);
  procedure ShowConnectionStatusMessage(message : string);
  procedure ShowStatusText(status : string);
end;

implementation

end.
