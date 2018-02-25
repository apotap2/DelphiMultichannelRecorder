# DelphiMultichannelRecorder
Delphi 7 multichannel recorder

I did this multichannel recorder (more precisely "displayer" :) ) some time ago and decided to publish it. 
I believe there is a decent amount of similar solutions already, but it still can be useful for somebody.

It is written in delphi 7, quite ancient already.

In the application you can choose a device (right now this is "emulator" and "simple usb device", which I did using PIC18F2550, related info is in SimpleUsbDevice folder),
add/remove recorders, add/remove channels in the recorders, use calibration. Russian gui example file is rus_gui.png. Now it is only in English.

To build you need: delphi 7, teechart (buy it or use trial to test), import msscript.ocx. Msscript.osx is a microsoft script stuff,
deprecated already, but still should be available. I used it in "JScript" calibration mode for a channel.

To make code for your device, open BaseDevice.pas take a look into IBaseRequestOnlyDevice, ICommandInfo and IConnectionCallback.
Use "simple usb device" from SimpleUsbDevice.pas and "Emulator" from EmulatorDevice.pas as examples.

