

        extrn  font

        public ttyinit, ttyout, ttyint, ttybnk

ttybnk  equ CBANK
        

        .z80

                        ;€‡Œ…™€’œ ‘ €„…‘€ Š€’HŽƒŽ 256 !
tblcod: ds 256


ttyinit:        ld hl,tblcod
@@ll1:          ld (hl),l
                inc l
                jr nz,@@ll1
                ld bc,0eff7h
                ld a,2
                out (c),a
                jp cls

;----------------------------------------


;    043210  21054321
; %11cllvvv %lllccccc


; #fc     cccccc00
; #03 #f0 000000cc cccc0000
; #0f #c0          0000cccc cc000000
;     #3f                   00cccccc


;prc(0..3):
; hl=scr de=font c=mask -> hl=scr+700h


width   equ 85
high    equ 24

blink   equ 10

border  equ 00


ttyout: ld c,a
        ld hl,curlock
        ld (hl),1
        call curs_off
        ld a,c 
        jp prall
fjump   equ $-2

prall:  cp 20h
        jp nc,prchr
        ld hl,(coord)
        cp 1bh
        jp z,esc
        cp 0dh
        jp z,cr
        cp 0ah
        jp z,lf
        cp 09h
        jp z,tab
        cp 08h
        jp z,left
        cp 18h
        jp z,right
        cp 19h
        jp z,up
        cp 1ah
        jp z,down
        cp 0bh
        jp z,home
        cp 0ch
        jp z,cls
        cp 16h
        jp z,clrel
        cp 15h
        jp z,clrln
        cp 01h
        jp z,grf
        cp 07h
        jp z,bell
        cp 0fh
        jp z,mkkoi8
        cp 0eh
        jp z,mkkoi7r

prchr:  ld l,a 
        ld h,tblcod/256
        ld e,(hl) 
        ld d,font/256
        ld bc,0000000011111100b
prcmsk  equ $-2
        ld a,b 
        ld b,0
inverse equ $-1
        ld hl,0c000h
praddr  equ $-2
        jp prc00
prc_ad  equ $-2



;--------------------------------------

prc00:
        ld a,(de) 
        xor b 
        xor (hl)
        and c 
        xor (hl)
        ld (hl),a
        inc h
        inc d 
        ld a,(de) 
        xor b 
        xor (hl)
        and c 
        xor (hl)
        ld (hl),a
        inc h
        inc d 
        ld a,(de) 
        xor b 
        xor (hl)
        and c 
        xor (hl)
        ld (hl),a
        inc h
        inc d 
        ld a,(de) 
        xor b 
        xor (hl)
        and c 
        xor (hl)
        ld (hl),a
        inc h
        inc d 
        ld a,(de) 
        xor b 
        xor (hl)
        and c 
        xor (hl)
        ld (hl),a
        inc h
        inc d 
        ld a,(de) 
        xor b 
        xor (hl)
        and c 
        xor (hl)
        ld (hl),a
        inc h
        inc d 
        ld a,(de) 
        xor b 
        xor (hl)
        and c 
        xor (hl)
        ld (hl),a
        inc h
        inc d 
        ld a,(de) 
        xor b 
        xor (hl)
        and c 
        xor (hl)
        ld (hl),a

        jp endpr

;-----------------------

prc01:  push hl 
        exx 
        ld c,a 
        pop hl
        ld a,h
        add a,00100000b
        jr nc,prc01_1
        or 11000000b
        inc l
prc01_1: ld h,a
        exx 

        ld a,(de) 
        xor b 
        exx 
        rlca
        rlca 
        ld b,a 
        xor (hl)
        and c 
        xor (hl) 
        ld (hl),a
        inc h 
        ld a,b 
        exx 
        xor (hl) 
        and c 
        xor (hl)
        ld (hl),a 
        inc h 
        inc d 
        ld a,(de) 
        xor b 
        exx 
        rlca
        rlca 
        ld b,a 
        xor (hl)
        and c 
        xor (hl) 
        ld (hl),a
        inc h 
        ld a,b 
        exx 
        xor (hl) 
        and c 
        xor (hl)
        ld (hl),a 
        inc h 
        inc d 
        ld a,(de) 
        xor b 
        exx 
        rlca
        rlca 
        ld b,a 
        xor (hl)
        and c 
        xor (hl) 
        ld (hl),a
        inc h 
        ld a,b 
        exx 
        xor (hl) 
        and c 
        xor (hl)
        ld (hl),a 
        inc h 
        inc d 
        ld a,(de) 
        xor b 
        exx 
        rlca
        rlca 
        ld b,a 
        xor (hl)
        and c 
        xor (hl) 
        ld (hl),a
        inc h 
        ld a,b 
        exx 
        xor (hl) 
        and c 
        xor (hl)
        ld (hl),a 
        inc h 
        inc d 
        ld a,(de) 
        xor b 
        exx 
        rlca
        rlca 
        ld b,a 
        xor (hl)
        and c 
        xor (hl) 
        ld (hl),a
        inc h 
        ld a,b 
        exx 
        xor (hl) 
        and c 
        xor (hl)
        ld (hl),a 
        inc h 
        inc d 
        ld a,(de) 
        xor b 
        exx 
        rlca
        rlca 
        ld b,a 
        xor (hl)
        and c 
        xor (hl) 
        ld (hl),a
        inc h 
        ld a,b 
        exx 
        xor (hl) 
        and c 
        xor (hl)
        ld (hl),a 
        inc h 
        inc d 
        ld a,(de) 
        xor b 
        exx 
        rlca
        rlca 
        ld b,a 
        xor (hl)
        and c 
        xor (hl) 
        ld (hl),a
        inc h 
        ld a,b 
        exx 
        xor (hl) 
        and c 
        xor (hl)
        ld (hl),a 
        inc h 
        inc d 
        ld a,(de) 
        xor b 
        exx 
        rlca
        rlca 
        ld b,a 
        xor (hl)
        and c 
        xor (hl) 
        ld (hl),a
        ld a,b 
        exx 
        xor (hl) 
        and c 
        xor (hl)
        ld (hl),a 

        jp endpr

;------------------------------------

prc10:  push hl 
        exx
        ld c,a 
        pop hl
        ld a,h
        add a,00100000b
        jr nc,prc10_1
        or 11000000b
        inc l
prc10_1: ld h,a
        exx 

        ld a,(de) 
        xor b 
        rlca
        rlca
        rlca
        rlca 
        exx 
        ld b,a
        xor (hl)
        and c
        xor (hl)
        ld (hl),a
        inc h 
        ld a,b
        exx
        xor (hl)
        and c
        xor (hl)
        ld (hl),a
        inc h 
        inc d 
        ld a,(de) 
        xor b 
        rlca
        rlca
        rlca
        rlca 
        exx 
        ld b,a
        xor (hl)
        and c
        xor (hl)
        ld (hl),a
        inc h 
        ld a,b
        exx
        xor (hl)
        and c
        xor (hl)
        ld (hl),a
        inc h 
        inc d 
        ld a,(de) 
        xor b 
        rlca
        rlca
        rlca
        rlca 
        exx 
        ld b,a
        xor (hl)
        and c
        xor (hl)
        ld (hl),a
        inc h 
        ld a,b 
        exx
        xor (hl)
        and c
        xor (hl)
        ld (hl),a
        inc h 
        inc d 
        ld a,(de) 
        xor b 
        rlca
        rlca
        rlca
        rlca 
        exx 
        ld b,a
        xor (hl)
        and c
        xor (hl)
        ld (hl),a
        inc h 
        ld a,b
        exx
        xor (hl)
        and c
        xor (hl)
        ld (hl),a
        inc h 
        inc d 
        ld a,(de) 
        xor b 
        rlca
        rlca
        rlca
        rlca 
        exx 
        ld b,a
        xor (hl)
        and c
        xor (hl)
        ld (hl),a
        inc h 
        ld a,b
        exx
        xor (hl)
        and c
        xor (hl)
        ld (hl),a
        inc h 
        inc d 
        ld a,(de) 
        xor b 
        rlca
        rlca
        rlca
        rlca 
        exx 
        ld b,a
        xor (hl)
        and c
        xor (hl)
        ld (hl),a
        inc h 
        ld a,b
        exx
        xor (hl)
        and c
        xor (hl)
        ld (hl),a
        inc h 
        inc d 
        ld a,(de) 
        xor b 
        rlca
        rlca
        rlca
        rlca 
        exx 
        ld b,a
        xor (hl)
        and c
        xor (hl)
        ld (hl),a
        inc h 
        ld a,b
        exx
        xor (hl)
        and c
        xor (hl)
        ld (hl),a
        inc h 
        inc d 
        ld a,(de) 
        xor b 
        rlca
        rlca
        rlca
        rlca 
        exx 
        ld b,a
        xor (hl)
        and c
        xor (hl)
        ld (hl),a
        ld a,b
        exx
        xor (hl)
        and c
        xor (hl)
        ld (hl),a

        jp  endpr

;-------------------------------------

prc11:
        ld a,(de) 
        xor b 
        rrca
        rrca
        xor (hl)
        and c
        xor (hl)
        ld (hl),a
        inc h 
        inc d 
        ld a,(de) 
        xor b 
        rrca
        rrca
        xor (hl)
        and c
        xor (hl)
        ld (hl),a
        inc h 
        inc d 
        ld a,(de) 
        xor b 
        rrca
        rrca
        xor (hl)
        and c
        xor (hl)
        ld (hl),a
        inc h 
        inc d 
        ld a,(de) 
        xor b 
        rrca
        rrca
        xor (hl)
        and c
        xor (hl)
        ld (hl),a
        inc h 
        inc d 
        ld a,(de) 
        xor b 
        rrca
        rrca
        xor (hl)
        and c
        xor (hl)
        ld (hl),a
        inc h 
        inc d 
        ld a,(de) 
        xor b 
        rrca
        rrca
        xor (hl)
        and c
        xor (hl)
        ld (hl),a
        inc h 
        inc d 
        ld a,(de) 
        xor b 
        rrca 
        rrca 
        xor (hl)
        and c
        xor (hl)
        ld (hl),a
        inc h 
        inc d 
        ld a,(de) 
        xor b 
        rrca
        rrca
        xor (hl)
        and c
        xor (hl)
        ld (hl),a 

;--------------------------------------

endpr:  ld hl,0
coord   equ $-2

right:  inc l 
        ld a,width-1
        cp l 
        jr c,nxtln

ctaddr: ld (coord),hl 
        ex de,hl 
        ld a,e 
        add a,a
        add a,e 
        rrca 
        rrca 
        ld c,a 
        and 00111111b
        rra 
        ld l,a      ; a=(e*3/4)/2
        rra 
        rrca 
        rrca 
        or d 
        and 11111000b
        or 11000000b
        ld h,a 
        ld a,d 
        rrca
        rrca 
        rrca
        and 11100000b
        or l 
        ld l,a 
        ld (praddr),hl 

        ld a,c 
        rla 
        jr nc,prn0x
        rla
        jr nc,prn10
        ld hl,prc01
        ld (prc_ad),hl
        ld hl,1111000000000011b
        ld (prcmsk),hl
        ld hl,curlock
        ld (hl),0
        ret 
prn10:  ld hl,prc10
        ld (prc_ad),hl
        ld hl,1100000000001111b
        ld (prcmsk),hl 
        ld hl,curlock
        ld (hl),0
        ret 

prn0x:  rla 
        jp c,prn11
        ld hl,prc00
        ld (prc_ad),hl 
        ld hl,0000000011111100b
        ld (prcmsk),hl 
        ld hl,curlock
        ld (hl),0
        ret 
prn11:  ld hl,prc11
        ld (prc_ad),hl
        ld hl,0000000000111111b
        ld (prcmsk),hl 
        ld hl,curlock
        ld (hl),0
        ret 

home:   ld hl,0
        jr ctaddr

nxtln:  ld l,0
lf:     ld a,high-1
        inc h 
        cp h 
        jp nc,ctaddr
        dec h 
        jp scroll
lfovadr equ $-2

scroll: push hl 
        ld hl,0c020h
        ld de,0c000h
scroll1: call ldi32
        set 5,h 
        set 5,d 
        call ldi32
        res 5,h
        res 5,d 
        inc h
        inc d
        ld a,h
        and 00000111b
        jp nz,scroll1
        ld a,l
        add a,00100000b
        ld l,a
        ld a,h 
        jr z,scroll2
        sub 00001000b
        ld h,a 
        jp scroll4

scroll2: cp 11011000b
        jr c,scroll4
        ld hl,1101000011100000b
        ld e,l
        ld c,1
        call clrl1
        pop hl 
        jp ctaddr

scroll4: ld a,e 
        add a,00100000b
        ld e,a 
        jp z,scroll1
        ld a,d 
        sub 00001000b
        ld d,a 
        jp scroll1

ldi32:  ldi 
        ldi
        ldi
        ldi 
        ldi
        ldi
        ldi
        ldi 
        ldi
        ldi
        ldi
        ldi 
        ldi
        ldi
        ldi
        ldi 
        ldi 
        ldi
        ldi
        ldi 
        ldi
        ldi
        ldi
        ldi 
        ldi
        ldi
        ldi
        ldi 
        ldi
        ldi
        ldi
        ldi 
        dec hl 
        dec de
        ld a,l 
        and 11100000b
        ld l,a
        ld a,e 
        and 11100000b
        ld e,a 
        ret 


tab:    ld a,l 
        or 07
        ld l,a
        jp right

cr:     ld l,0
        jp ctaddr

down:   inc h
        ld a,h 
        cp high
        jp c,ctaddr
        ld h,0
        jp ctaddr

left:   dec l 
        ld a,l
        inc a
        jp nz,ctaddr
        ld l,width-1
up:     dec h 
        ld a,h
        inc a 
        jp nz,ctaddr
        ld h,high-1
        jp ctaddr

clrel:  push hl     ; clear to end of line
        ld hl,ctaddr
        ld (lfovadr),hl 
clrel1: ld a,20h
        call prchr
        ld a,e
        or a
        jr nz,clrel1
        ld hl,scroll
        ld (lfovadr),hl 
        pop hl
        jp ctaddr

esc:    ld hl,esc1
setfjp: ld (fjump),hl
rcurs:  ld hl,curlock
        ld (hl),0
        ret 

esc1:   cp 80h
        jr nc,posit
        cp "Y"
        jr z,pposit
        cp "P"
        jp z,setcol
        cp "V"
        jp z,setinv
        ld hl,prall
        ld (fjump),hl 
        cp "H"
        jp z,home
        ld hl,(coord)
        cp "K"
        jr z,clrel
        cp "J"
        jp z,clres
        cp "Q"
        jp z,cmode0
        cp "R"
        jp z,cmode1
        cp "["
        jp z,mkalt
        cp "Z"
        jp z,mkkoi8
        cp "]"
        jp z,mkkoi8
        cp "\"
        jp z,mkkoi7l
        cp "@"
        jp z,mkkoi7r
        jp prchr

pposit: ld hl,pposit1
        jr setfjp
pposit1: sub 20h
        ld (pcoord),a 
        ld hl,pposit2
        jr setfjp
pposit2: sub 20h
        jr setpos

posit:  and 7fh
        ld (pcoord),a 
        ld hl,posit1
        jr setfjp
posit1: and 7fh
setpos: ld hl,prall
        ld (fjump),hl
        cp width
        jp nc,rcurs
        ld l,a
        ld a,high-1
        ld h,0
pcoord  equ $-1
        cp h
        jp c,rcurs
        jp ctaddr

grf:    ld hl,grf1
        jp setfjp
grf1:   ld hl,prall
        ld (fjump),hl
        jp prchr

bell:   ld a,border
data_fe equ $-1
        ld c,120      ; parity
bell1:  xor 10h
        out (0feh),a
        ld b,80
        djnz $
        dec c
        jr nz,bell1
        jp rcurs

cls:    ld hl,prc00
        ld (prc_ad),hl 
        ld hl,0000000011111100b
        ld (prcmsk),hl 
        ld l,0
        ld (coord),hl
        ld h,0c0h
        ld (praddr),hl 
        ld c,high
        ld e,l 
        jr clrl1


clrln:  ld c,1
        jr clrln1

clres:  ld a,high
        sub h 
        ld c,a 
clrln1: ld hl,(praddr)
        ld a,l 
        and 11100000b
clrl0:  ld e,a 
clrl1:  ld b,2
clrl2:  ld l,e 
        xor a 
        ld (hl),a 
        inc l 
        ld (hl),a 
        inc l 
        ld (hl),a 
        inc l 
        ld (hl),a 
        inc l 
        ld (hl),a 
        inc l 
        ld (hl),a 
        inc l 
        ld (hl),a 
        inc l 
        ld (hl),a 
        inc l 
        ld (hl),a 
        inc l 
        ld (hl),a 
        inc l 
        ld (hl),a 
        inc l 
        ld (hl),a 
        inc l 
        ld (hl),a 
        inc l 
        ld (hl),a 
        inc l 
        ld (hl),a 
        inc l 
        ld (hl),a 
        inc l 
        ld (hl),a 
        inc l 
        ld (hl),a 
        inc l 
        ld (hl),a 
        inc l 
        ld (hl),a 
        inc l 
        ld (hl),a 
        inc l 
        ld (hl),a 
        inc l 
        ld (hl),a 
        inc l 
        ld (hl),a 
        inc l 
        ld (hl),a 
        inc l 
        ld (hl),a 
        inc l 
        ld (hl),a 
        inc l 
        ld (hl),a 
        inc l 
        ld (hl),a 
        inc l 
        ld (hl),a 
        inc l 
        ld (hl),a 
        inc l 
        ld (hl),a 
        inc l 
        ld a,h
        xor 00100000b
        ld h,a 
        djnz clrl2
        inc h 
        ld a,h
        and 00000111b
        jp nz,clrl1
        dec c
        jp z,rcurs
        ld a,l
        or a
        jr z,clrl0
        ld a,h
        sub 08
        ld h,a 
        ld a,l 
        jp clrl0

setcol: ld hl,setcol1
        jp setfjp
setcol1: and 00111000b
        rrca 
        rrca 
        rrca 
        ld (data_fe),a 
        out (0feh),a
restfjp: ld hl,prall
        ld (fjump),hl 
        jp rcurs

setinv:  ld hl,setinv1
        jp setfjp
setinv1: and 00000001b
        jr z,setinv2
        ld a,0ffh
setinv2: ld (inverse),a
        jr restfjp

cmode0: xor a
        jr cmodes
cmode1: ld a,1
cmodes: ld (curmode),a 
        jp rcurs

mkalt:  ld hl,rcurs
        push hl 
        ld bc,0c040h   
mkalt1: ld hl,tblcod+40h
mkalt2: ld (hl),c 
        inc c 
        inc l
        djnz mkalt2
        ret 

mkkoi8: ld bc,4040h
        call mkalt1
mkkoi8h: ld bc,20c0h
        call mkalt2
        ld bc,10f0h
        call mkalt2
        ld bc,10b0h
        call mkalt2
        call koi7s
        ld (hl),0eah
        inc l 
        call koi7b
        ld (hl),9ah
        jp rcurs

mkkoi7l: ld bc,2040h
        call mkalt1
mkkoi7e: call koi7b
        ld (hl),l 
        inc l 
        jr mkkoi8h

mkkoi7r: ld hl,tblcod+40h
        call koi7s
        ld (hl),l 
        inc hl
        jr mkkoi7e

koi7b:  ld de,tkoi1
        call koi7m
        ld bc,0888h
        call mkalt2
        ld (hl),9fh
        inc l
        ld bc,0490h
        call mkalt2
        ld de,tkoi2
koi7m:  ex de,hl
        ld bc,9
        ldir
        ex de,hl
        ret 

koi7s:  ld de,tkoi1
        call koi7n
        ld bc,08a8h
        call mkalt2
        ld (hl),0efh
        inc l
        ld bc,04e0h
        call mkalt2
        ld de,tkoi2
koi7n:  ld b,9
koi71:  ld a,(de) 
        inc de 
        bit 4,a
        jr z,koi72
        and 0efh
        or 40h
koi72:  or 20h
        ld (hl),a
        inc l
        djnz koi71
        ret 

ttyint: ld a,0
curlock equ $-1
        dec a 
        ret z 
        ld a,0
curmode equ $-1
        dec a
        ret z 
        ld hl,curcnt
        dec (hl)
        ret nz 
        ld (hl),blink
        jp curs_on
curs_jp equ $-2

curs_on: ld bc,(prcmsk)
        ld hl,(praddr)
        ld a,h 
        add a,7
        ld h,a 
        ld (c_adr1),hl
        ld a,(hl)
        ld (c_dat1),a 
        xor c 
        ld (hl),a
        ld a,h 
        add a,00100000b
        jr nc,curs1
        or 11000000b
        inc l 
curs1:  ld h,a
        ld (c_adr2),hl 
        ld a,(hl) 
        ld (c_dat2),a 
        xor b 
        ld (hl),a
        ld hl,curs_off
        ld (curs_jp),hl
        ld (hl),3eh
        ret 

curs_off: ld a,0
c_dat1   equ $-1
         ld (0c000h),a 
c_adr1   equ $-2
         ld a,0
c_dat2   equ $-1
         ld (0c000h),a 
c_adr2   equ $-2
         ld hl,curs_on
         ld (curs_jp),hl 
         ld hl,curcnt
         ld (hl),blink
         ld hl,curs_off
         ld (hl),0c9h
         ret 

curcnt: db blink


tkoi1:  db 9eh,80h,81h,96h,84h,85h,94h,83h,95h
tkoi2:  db 086h,082h,09ch,09bh,087h,098h,09dh,099h,097h

