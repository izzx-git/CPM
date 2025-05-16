del errors.lst
"C:\Program Files (x86)\DOSBox-0.74-3\DOSBox.exe" COMP_GMX.BAT -exit
notepad errors.lst

copy Sample.trd CPMZSGMX.trd
sjasmplus.exe Build_GMX.asm
rem  --lst=main.lst
rem pause

unreal.exe CPMZSGMX.trd