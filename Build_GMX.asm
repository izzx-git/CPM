	device ZXSPECTRUM48
start_0
	incbin "BIOS.COM"
end_0
	SAVETRD "CPMZSGMX.trd",|"BIOS.C",start_0,end_0-start_0

start_1
	incbin "DRV.COM"
end_1
	SAVETRD "CPMZSGMX.trd",|"DRV.C",start_1,end_1-start_1

start_2
	incbin "FONT80.COM"
end_2
	SAVETRD "CPMZSGMX.trd",|"FONT.C",start_2,end_2-start_2
	
	include "Install.asm"
	SAVETRD "CPMZSGMX.trd",|"INSTALL.C",start_inst,end_inst-start_inst
	
	SAVETRD "CPMZSGMX.trd",|"BOOTSEC.C",start_boots,end_boots-start_boots
	
	SAVETRD "CPMZSGMX.trd",|"BACKUP0.C",0,#ff00
	SAVETRD "CPMZSGMX.trd",|"BACKUP1.C",0,#ff00
	SAVETRD "CPMZSGMX.trd",|"BACKUP2.C",0,#ff00
	SAVETRD "CPMZSGMX.trd",|"BACKUP3.C",0,#ff00
	SAVETRD "CPMZSGMX.trd",|"BACKUP4.C",0,#ff00
	SAVETRD "CPMZSGMX.trd",|"BACKUP5.C",0,#ff00
	SAVETRD "CPMZSGMX.trd",|"BACKUP6.C",0,#ff00
	SAVETRD "CPMZSGMX.trd",|"BACKUP7.C",0,#ff00
	SAVETRD "CPMZSGMX.trd",|"BACKUP8.C",0,#ff00
	SAVETRD "CPMZSGMX.trd",|"BACKUP9.C",0,9*256