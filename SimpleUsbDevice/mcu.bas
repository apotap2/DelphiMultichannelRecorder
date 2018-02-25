Define CLOCK_FREQUENCY = 20
Define CONFIG1L = 0x24
Define CONFIG1H = 0x0c
Define CONFIG2L = 0x3e
Define CONFIG2H = 0x00
Define CONFIG3L = 0x00
Define CONFIG3H = 0x83
Define CONFIG4L = 0x80
Define CONFIG4H = 0x00
Define CONFIG5L = 0x0f
Define CONFIG5H = 0xc0
Define CONFIG6L = 0x0f
Define CONFIG6H = 0xe0
Define CONFIG7L = 0x0f
Define CONFIG7H = 0x40

UsbSetVendorId 0x1234
UsbSetProductId 0x1234
UsbSetVersionNumber 0x1122
UsbSetManufacturerString "Potapchuk"
UsbSetProductString "Simple usb device"
UsbSetSerialNumberString "1111111111"
UsbOnIoInGosub input_report_before_sending
UsbOnIoOutGosub output_report_received
UsbOnFtInGosub feature_report_before_sending
UsbOnFtOutGosub feature_report_received

'internal eeprom addresses
Const exteepromsizeh = 0x00
Const exteepromsizel = 0x01
Const writemode = 0x02
Const channelsmask = 0x03
Const intervalh = 0x04
Const intervall = 0x05

Symbol sda = PORTB.0
Symbol scl = PORTB.1

Define ADC_CLOCK = 6
Define ADC_SAMPLEUS = 40

AllDigital

TRISA = 0xff
ADCON1 = 0x09

Dim addrfrom As Word
Dim offlinechannelsmask(5) As Byte
Dim offmode As Byte
Dim offpointer As Word
Dim timeoutcounter As Word
Dim interval As Word
Dim eepromsize As Word
Dim offmask As Byte


Read intervalh, interval.HB
Read intervall, interval.LB

Read exteepromsizeh, eepromsize.HB
Read exteepromsizel, eepromsize.LB

Read writemode, offmode

If offmode = 1 Then
	'check if data is read - first word isn't 0xffff
	Dim firstword As Word
	Dim eeaddr As Word
	eeaddr = 0
	I2CRead sda, scl, 0xa0, eeaddr, firstword.HB
	eeaddr = 1
	I2CRead sda, scl, 0xa0, eeaddr, firstword.LB
	If firstword = 0xffff Then
		Read channelsmask, offmask
	
		Gosub turn_timer_on
	Endif
	'if something was read - wait until it will be retrieved.
Endif

UsbStart
TRISC = TRISC And %11111000
TRISB = TRISB And %00000011

loop:
UsbService
Goto loop
End                                               


feature_report_received:
Return                                            

feature_report_before_sending:
Return                                            
'usb commands
Const readfromadc = 0x01
Const readfromadcs = 0x02
Const setdigitalpin = 0x03
Const getadcon1 = 0x04
Const setadcon1 = 0x05
Const readexteepromsize = 0x06
Const setexteepromsize = 0x07
Const writetoexteeprom = 0x08
Const readofflineintervalandmask = 0x09
Const stopofflinereading = 0x0a
Const readfromextmem = 0x0b

output_report_received:
Dim adcval As Word
Select Case UsbIoBuffer(0)
	Case readfromadc
		Adcin UsbIoBuffer(1), adcval
		UsbIoBuffer(0) = adcval.HB
		UsbIoBuffer(1) = adcval.LB
		
	Case readfromadcs
		Dim adcnum As Byte
		Dim i As Byte
		Dim j As Byte
		i = 1
		j = 0
		adcnum = UsbIoBuffer(1)
		Dim out(8) As Byte
		While adcnum <> 0xff
			Adcin adcnum, adcval
			out(j) = adcval.HB
			j = j + 1
			out(j) = adcval.LB
			j = j + 1
			i = i + 1
			adcnum = UsbIoBuffer(i)
		Wend
		For j = 0 To 7 Step 1
			UsbIoBuffer(j) = out(j)
		Next j
		
	Case setdigitalpin
		Dim mask As Byte
		mask = UsbIoBuffer(2)
		If UsbIoBuffer(1) = 1 Then
		'portb
		If UsbIoBuffer(3) = 0 Then
		PORTB = PORTB And mask
		Else
		PORTB = PORTB Or mask
		Endif
		Else
		If UsbIoBuffer(1) = 2 Then
		'portc
		If UsbIoBuffer(3) = 0 Then
		PORTC = PORTC And mask
		Else
		PORTC = PORTC Or mask
		Endif

		Endif
		Endif
	Case getadcon1
		UsbIoBuffer(0) = ADCON1
	Case setadcon1
		ADCON1 = UsbIoBuffer(1)
	Case readexteepromsize
		Read exteepromsizeh, UsbIoBuffer(0)
		Read exteepromsizel, UsbIoBuffer(1)
	Case setexteepromsize
		Write exteepromsizeh, UsbIoBuffer(1)
		Write exteepromsizel, UsbIoBuffer(2)
		eepromsize.HB = UsbIoBuffer(1)
		eepromsize.LB = UsbIoBuffer(2)
	Case writetoexteeprom
		Write intervalh, UsbIoBuffer(1)
		Write intervall, UsbIoBuffer(2)
		Write channelsmask, UsbIoBuffer(3)
		Write writemode, UsbIoBuffer(4)

		interval.HB = UsbIoBuffer(1)
		interval.LB = UsbIoBuffer(2)
		offmask = UsbIoBuffer(3)
		offmode = UsbIoBuffer(4)
		'turn off timer, "clear" external eeprom - set 0xff
		T0CON.TMR0ON = 0
		INTCON.GIE = 0
		Dim eeaddr As Word
		eeaddr = 0
		I2CWrite sda, scl, 0xa0, eeaddr, 0xff
		WaitMs 5
		eeaddr = eeaddr + 1
		I2CWrite sda, scl, 0xa0, eeaddr, 0xff
				
		If UsbIoBuffer(4) = 0 Then
		'write now
		Gosub turn_timer_on
		Endif
	Case readofflineintervalandmask
		UsbIoBuffer(0) = interval.HB
		UsbIoBuffer(1) = interval.LB
		UsbIoBuffer(2) = offmask
	Case stopofflinereading
		T0CON.TMR0ON = 0
		INTCON.GIE = 0
	Case readfromextmem
		addrfrom.HB = UsbIoBuffer(1)
		addrfrom.LB = UsbIoBuffer(2)
		
				For i = 0 To 7 Step 1
			I2CRead sda, scl, 0xa0, addrfrom, UsbIoBuffer(i)
									addrfrom = addrfrom + 1
		Next i
EndSelect

Return                                            
turn_timer_on:
		offlinechannelsmask(0) = offmask And 0x01
		offlinechannelsmask(1) = offmask And 0x02
		offlinechannelsmask(2) = offmask And 0x04
		offlinechannelsmask(3) = offmask And 0x08
		offlinechannelsmask(4) = offmask And 0x10

		T0CON.T08BIT = 1
		T0CON.T0PS0 = 1
		T0CON.T0PS1 = 1
		T0CON.T0PS2 = 1
		T0CON.PSA = 0
		T0CON.T0CS = 0

		INTCON.TMR0IE = 1
		TMR0L = 0x0

		offpointer = 0
		timeoutcounter = 0
	
		Enable High
		T0CON.TMR0ON = 1
Return                                            

input_report_before_sending:
Return                                            

On High Interrupt
If INTCON.TMR0IE Then
	If INTCON.TMR0IF Then
		INTCON.TMR0IF = 0

		timeoutcounter = timeoutcounter + 1
		If timeoutcounter = interval Then
			timeoutcounter = 0
			If offpointer < eepromsize Then
			If offpointer > 2 Then
			offpointer = offpointer - 2
			Endif
			Dim adcval As Word
			'copy-pasting. no refactoring-optimization due to fear of compiler
			If offlinechannelsmask(0) > 0 Then
				Adcin 0, adcval
				I2CWrite sda, scl, 0xa0, offpointer, adcval.HB
				WaitMs 5
				offpointer = offpointer + 1
				I2CWrite sda, scl, 0xa0, offpointer, adcval.LB
				WaitMs 5
				offpointer = offpointer + 1
			Endif
			If offlinechannelsmask(1) > 0 Then
				Adcin 1, adcval
				I2CWrite sda, scl, 0xa0, offpointer, adcval.HB
				WaitMs 5
				offpointer = offpointer + 1
				I2CWrite sda, scl, 0xa0, offpointer, adcval.LB
				WaitMs 5
				offpointer = offpointer + 1
			Endif
			If offlinechannelsmask(2) > 0 Then
				Adcin 2, adcval
				I2CWrite sda, scl, 0xa0, offpointer, adcval.HB
				WaitMs 5
				offpointer = offpointer + 1
				I2CWrite sda, scl, 0xa0, offpointer, adcval.LB
				WaitMs 5
				offpointer = offpointer + 1
			Endif
			If offlinechannelsmask(3) > 0 Then
				Adcin 3, adcval
				I2CWrite sda, scl, 0xa0, offpointer, adcval.HB
				WaitMs 5
				offpointer = offpointer + 1
				I2CWrite sda, scl, 0xa0, offpointer, adcval.LB
				WaitMs 5
				offpointer = offpointer + 1
			Endif
			If offlinechannelsmask(4) > 0 Then
				Adcin 4, adcval
				I2CWrite sda, scl, 0xa0, offpointer, adcval.HB
				WaitMs 5
				offpointer = offpointer + 1
				I2CWrite sda, scl, 0xa0, offpointer, adcval.LB
				WaitMs 5
				offpointer = offpointer + 1
			Endif
			'write end marker - 0xffff
			I2CWrite sda, scl, 0xa0, offpointer, 0xff
			WaitMs 5
			offpointer = offpointer + 1
			I2CWrite sda, scl, 0xa0, offpointer, 0xff
			offpointer = offpointer + 1

			If offpointer > eepromsize Then
			'if memory is full, turn off the timer
			T0CON.TMR0ON = 0
			INTCON.GIE = 0
			Endif
			
			Endif
		Endif
	Endif
Endif
Resume                                            
