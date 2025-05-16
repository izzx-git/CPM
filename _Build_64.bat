del errors.lst
"C:\Program Files (x86)\DOSBox-0.74-3\DOSBox.exe" COMP_64.BAT -exit
notepad errors.lst

copy Sample.trd CPMZS64.trd
sjasmplus.exe Build_64.asm
rem  --lst=main.lst
rem pause

unreal.exe CPMZS64.trd