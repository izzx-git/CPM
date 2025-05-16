
echo > errors.lst

rem DRIVERS
ma80 /DCBANK:1eh =kbd.as     >> errors.lst
ma80 /DCBANK:1eh =lprint.as  >> errors.lst
ma80 /DCBANK:1fh =pr64.as    >> errors.lst
ma80 /DCBANK:1fh =pr85.as    >> errors.lst

rem BIOS
ma80 /DCBANK:19h /Dcppbnk:1eh /l =bios.as >> errors.lst

rem CP/M
ma80 =bdos2_2.as             >> errors.lst
ma80 =cpp2_2.as              >> errors.lst

rem OTHER
ma80 =font64.as         >> errors.lst
ma80 =font42.as         >> errors.lst
ma80 =gate.as           >> errors.lst

mlink @link85.lst
