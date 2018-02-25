unit PIC18SimulatorDllHelper;

interface
uses windows;

function HIDConnect(): uint; stdcall; external 'hidterm.dll';
function HID_Detected(): uint; stdcall; external 'hidterm.dll';
function HID_VendorID(): uint; stdcall; external 'hidterm.dll';
function HID_ProductID(): uint; stdcall; external 'hidterm.dll';
function HID_ManufacturerString(): PChar; stdcall; external 'hidterm.dll';
function HID_ProductString(): PChar; stdcall; external 'hidterm.dll';
function HID_SerialNumberString(): PChar; stdcall; external 'hidterm.dll';
function HID_VersionNumber(): uint; stdcall; external 'hidterm.dll';
function HID_InputReportLength(): uint; stdcall; external 'hidterm.dll';
function HID_OutputReportLength(): uint; stdcall; external 'hidterm.dll';
function HID_FeatureReportLength(): uint; stdcall; external 'hidterm.dll';
function Set_HID_VendorID(newvalue : uint): uint; stdcall; external 'hidterm.dll';
function Set_HID_ProductID(newvalue : uint): uint; stdcall; external 'hidterm.dll';
function HIDSendReport(byte0, byte1, byte2, byte3, byte4, byte5, byte6, byte7 : Byte): uint; stdcall; external 'hidterm.dll';
function HIDReadReport(byte0, byte1, byte2, byte3, byte4, byte5, byte6, byte7 : PByte): uint; stdcall; external 'hidterm.dll';
function HIDSendFeature(byte0, byte1, byte2, byte3, byte4, byte5, byte6, byte7 : Byte): uint; stdcall; external 'hidterm.dll';
function HIDReadFeature(byte0, byte1, byte2, byte3, byte4, byte5, byte6, byte7 : PByte): uint; stdcall; external 'hidterm.dll';

implementation

end.
