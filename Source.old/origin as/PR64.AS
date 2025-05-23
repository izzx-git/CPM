
        .z80

        extrn  font, font2      ; �p���� �� 2048 ���� (���� � �p���)
                                ; ��� p����� �㦥� ⮫쪮 �� font,
                                ; ��p�� ����p�p���� �p� ���樠����樨
                                                                                
        extrn  tblcod           ; ⠡��� ��p�����p���� 256 ����.

        public ttyout     ; c=�㪢� �� ��p��
        public ttyinit    ; ���樠������, � ��p�� p�� ��易⥫쭮 !
        public ttyint     ; 50 p�� � ᥪ㭤�

        public ttybnk   ; �����

ttybnk     equ CBANK

;
; 0D                            ����p�� ��p�⪨
; 0A                            ��p���� ��p���
; 09                            ⠡����
; 08                            �����
; 18                            ��p���
; 19                            ���p�
; 1A                            ����
; 0B    <ESC>H                  ������ 0,0
; 0C                            ���⪠ ��p���
; 16    <ESC>K                  ���⪠ �� ���� ��p���
; 15                            ���⪠ ��p���
; 01                            ᫥�. ᨬ��� ��� �p���p��
; 07                            ������
; 0F                            ������� ���-8
; 0E                            ������� ���-7 p��.
;       <ESC>Y[line+32][col+32] ��⠭���� ����樨
;       <ESC>[line+128][col]    ��⠭���� ����樨
;       <ESC>P[color]           ��⠭���� 梥�           
;       <ESC>V[1=on,0=off]      ��⠭���� ����pᨨ
;       <ESC>J                  ���⪠ �� ���� ��p��� (����)
;       <ESC>Q                  ������� ��p�p
;       <ESC>R                  �몫���� ��p�p
;       <ESC>[                  ������� 866 ����p����
;       <ESC>Z                  ������� ���-8
;       <ESC>]                  ������� ���-8
;       <ESC>\                  ������� ���-7 ���.
;       <�SC>@                  ������� ���-7 p��.
;

blink   equ 12
border  equ 7

width   equ 64
hsize    equ 24

ttyinit::
        ld hl,font
        push ix
        push hl
        push hl
        ld ix,font2  ; �㪢� ���p� �p���.
        ld e,0fh
        call fontmake
        pop hl
        pop ix
        ld e,0f0h
        call fontmake
        pop ix
        ld hl,tblcod
@@loop: ld (hl),l       ; ����p��� ⠡���� ��p�����p����, ���砫� 866 codepage
        inc l
        jr nz,@@loop
        call cls
        ret

fontmake:  ld bc,0800h
fmloop:    ld a,(hl)
           and e
           ld (ix),a
           inc hl
           inc ix
           dec bc
           ld a,b
           or c
           jr nz,fmloop
           ret           

ttyout::
        ld hl,curlock
        ld (hl),1
        call curs_off
        jp prcod
fjump   equ $-2        

prcod:  cp 20h
        jp nc,prchr          ; ����� ᨬ��� ?
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
        jp z,clrln        ; ���⪠ ��p���
        cp 01h
        jp z,grf          ; ����� ��᫥���饣� ᨬ���� ��� ��p���⪨
        cp 07h
        jp z,bell
        cp 0fh
        jp z,mkkoi8       ; ����祭�� koi8
        cp 0eh
        jp z,mkkoi7r      ; koi7-r

prchr:  ld l,a 
        ld h,tblcod/256
tblhi   equ $-1                ; ��p�����p���� �� ⠡���
        ld l,(hl) 

         ld de,0
coord    equ $-2
         srl e
         jr c,prright

         ld h,font/256
         ld c,0fh
         jp prcalc
        
prright: ld h,font2/256
         ld c,0f0h

prcalc:  ld a,c
         cpl
         and 0
inverse  equ $-1
         ld b,a
                
         ld a,d
         rrca
         rrca
         rrca
         and 0e0h
         or e
         ld e,a
         ld a,d
         and 18h
         or 0c0h
         ld d,a

        ld a,(de)     ; �뢮� �㪢�
        and c
        or (hl)
        xor b
        ld (de),a
        inc d
        inc h        
        ld a,(de)
        and c
        or (hl)
        xor b
        ld (de),a
        inc d
        inc h
        ld a,(de)
        and c
        or (hl)
        xor b
        ld (de),a
        inc d
        inc h
        ld a,(de)
        and c
        or (hl)
        xor b
        ld (de),a
        inc d
        inc h
        ld a,(de)
        and c
        or (hl)
        xor b
        ld (de),a
        inc d
        inc h
        ld a,(de)
        and c
        or (hl)
        xor b
        ld (de),a
        inc d
        inc h
        ld a,(de)
        and c
        or (hl)
        xor b
        ld (de),a
        inc d
        inc h
        ld a,(de)
        and c
        or (hl)
        xor b
        ld (de),a
                      ; cf=0 d=110xx111  xx<>11
        ld a,d
        rra
        rra
        rra
        ld d,a          ; cf=1 d=110110xx
        ld a,038h
color   equ $-1
        ld (de),a       ; ��⠭���� 梥�

        ld hl,curs_on
        ld (curs_jp),hl ; ��p�p �ᥣ�� ��������� (���p� �㪢��)

        ld hl,(coord)
right:  inc l           ; �� ᫥�. ������.
        ld a,l
        cp width        
        jr nc,nxtln     ; ��p�室 �� �p���� �p����� ��p��� ?

ctaddr: ld (coord),hl     ; ��⠭���� ���p�����.
        xor a
        ld (curlock),a
        ret


home:   ld hl,0         ; ��⠭���� ���p����� 0,0.
        jr ctaddr

nxtln:  ld l,0           ; ��p�室 �� ��砫� ᫥�. ��p��� 
lf:     ld a,hsize-1      ; ��p�室 �� ᫥������ ��p���
        inc h 
        cp h 
        jp nc,ctaddr
        dec h 
        jp scroll
lfovadr equ $-2

scroll: push hl         ; �p��� ��p��� �� ��p��� ���p�
        ld hl,0c020h
        ld de,0c000h
scroll0: ld a,d          ; ��p���� 梥⮢
         rrca
         rrca
         rrca
         or 0c0h
         ld d,a
         ld a,h
         rrca
         rrca
         rrca
         or 0c0h
         ld h,a
         call ldi32
         sla d
         sla d
         sla d
         sla h
         sla h
         sla h
scroll1: call ldi32     ; ��p���� ����p������
        inc h
        inc d
        ld a,h
        and 7
        jp nz,scroll1   ; ��p��� (8 ����. ����) ��p���� ?
        ld a,l
        add a,20h
        ld l,a          ; �� ᫥�. ��p���
        ld a,h 
        jr z,scroll2    ; ��p�襫 �� ᫥�. 1/3 ��p���
        sub 8
        ld h,a 
        jp scroll4

scroll2: cp 0d1h
        jr c,scroll4
        ld hl,0d0e0h
        ld e,l
        ld c,1
        call clrl01      ; ���⪠ ��᫥���� ��p���
        pop hl 
        jp ctaddr

scroll4: ld a,e 
        add a,20h       ; �� ᫥�. ��p��� (⥯�p� �p������)
        ld e,a 
        jp z,scroll0
        ld a,d 
        sub 8           ; �� ᫥�. 1/3 ��p���
        ld d,a 
        jp scroll0

ldi32:   ldi 
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
        and 0e0h
        ld l,a
        ld a,e 
        and 0e0h
        ld e,a 
        ret 


tab:    ld a,l          ; ⠡����
        or 07h
        ld l,a
        jp right

cr:     ld l,0          ; ����p�� ��p�⪨
        jp ctaddr

down:   inc h           ; ����
        ld a,h 
        cp hsize
        jp c,ctaddr
        ld h,0
        jp ctaddr

left:   dec l           ; �����
        ld a,l
        inc a
        jp nz,ctaddr
        ld l,width-1
up:     dec h           ; ���p�
        ld a,h
        inc a 
        jp nz,ctaddr
        ld h,hsize-1
        jp ctaddr

clrel:  push hl           ; clear to end of line
        ld hl,ctaddr
        ld (lfovadr),hl 
clrel1: ld a,20h
        call prchr
        ld a,l
        or a
        jr nz,clrel1
        ld hl,scroll
        ld (lfovadr),hl 
        pop hl
        jp ctaddr

esc:    ld hl,esc1       ; ESC ��᫥����⥫쭮���
setfjp: ld (fjump),hl
rcurs:  ld hl,curlock
        ld (hl),0
        ret 

esc1:   cp 80h
        jr nc,posit       ; ��⠭���� ����樨 ᥩ�� [+1 byte]
        cp 'Y'
        jr z,pposit       ; ��⠭���� ����樨 �� ᫥�. ᨬ���� [+2 bytes]
        cp 'P'
        jp z,setcol       ; ��⠭���� 梥⮢ [+1 byte]
        cp 'V'
        jp z,setinv       ; ��⠭���� ����pᨨ [+1 bytes]
        ld hl,prcod
        ld (fjump),hl     ; ᫥���騩 ᨬ��� �� �㤥� �p���������� ESC ���.
        cp 'H'
        jp z,home         ; ��⠭���� 0,0.
        ld hl,(coord)
        cp 'K'
        jr z,clrel        ; ���⪠ �� ���� ��p���
        cp 'J'
        jp z,clres        ; ���⪠ �� ���� ��p���
        cp 'Q'
        jp z,cmode0       ; \
        cp 'R'            ;  | ������� / �몫���� ��p�p
        jp z,cmode1       ; /
        cp '['
        jp z,mkalt        ; set 866 code page
        cp 'Z'
        jp z,mkkoi8       ; set koi8 code page
        cp ']'
        jp z,mkkoi8       ; set koi8
        cp 05ch
        jp z,mkkoi7l      ; koi7 latin characters
        cp '@'
        jp z,mkkoi7r      ; koi7 with russian characters
        jp prchr

pposit: ld hl,pposit1     ; ��⠭���� ����樨 �� ᫥�. ᨬ���� [+2 bytes]
        jr setfjp
pposit1: sub 20h           ; ��p��� ���p����� -- ��p���
        ld (pcoord),a 
        ld hl,pposit2
        jr setfjp
pposit2: sub 20h           ; �������
        jr setpos

posit:  and 7fh           ; ��⠭���� ����樨 ᥩ�� [+1 byte]
        ld (pcoord),a     ; ���p����� ��p���.
        ld hl,posit1
        jr setfjp
posit1: and 7fh           ; �������
setpos: ld hl,prcod
        ld (fjump),hl
        cp width          ; �p���p�� ��⠭���������� ���p�����
        jp nc,rcurs       ; �� ᮮ⢥��⢨� ��p����p�� ��p���
        ld l,a
        ld a,hsize-1
        ld h,0
pcoord  equ $-1
        cp h
        jp c,rcurs        ; CF ���p������ �� �p������� ��p���
        jp ctaddr

grf:    ld hl,grf1        ; ����� ��᫥���饣� ᨬ���� ��� ��p���⪨
        jp setfjp
grf1:   ld hl,prcod
        ld (fjump),hl
        jp prchr

bell:   ld a,border     ; ������.
data_fe equ $-1
        ld c,120      ; parity  numbers only
bell1:  xor 10h
        out (0feh),a       ; use beeper
        ld b,80
        djnz $
        dec c
        jr nz,bell1
        jp rcurs

cls:    ld hl,0              ; ���⪠ ��p���
        ld (coord),hl
        ld h,0c0h
        ld c,hsize
        ld e,l 
        jr clrl01


clrln:  ld c,1          ; ���⪠ ��p���
        jr clrln1

clres:  ld a,hsize               ; ���⪠ �� ���� ��p���
        sub h 
        ld c,a 
clrln1: ld hl,(coord)
           srl l
           ld a,h
           rrca
           rrca
           rrca
           and 0e0h
           or l
           ld l,a
           ld a,h
           and 18h
           or 0c0h
           ld h,a
        ld a,l 
        and 0e0h
clrl0:  ld e,a
clrl01:    ld l,e               ; p��p�᪠ ��p���
           ld a,h
           rrca
           rrca
           rrca
           or 0c0h
           ld h,a
           ld a,(color)
           call fill32
           sla h
           sla h
           sla h
clrl1:  ld l,e                 ; ���⪠ ��p���
        xor a 
        call fill32
        inc l 
        inc h 
        ld a,h
        and 7
        jp nz,clrl1
        dec c
        jp z,rcurs
        ld a,l
        or a
        jr z,clrl0
        ld a,h
        sub 8
        ld h,a 
        ld a,l 
        jp clrl0

fill32: ld (hl),a 
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
        ret

setcol: ld hl,setcol1       ; ��⠭���� 梥�
        jp setfjp
setcol1: ld (color),a
        and 38h
        rrca 
        rrca 
        rrca 
        ld (data_fe),a 
        out (0feh),a
restfjp: ld hl,prcod
        ld (fjump),hl 
        jp rcurs

setinv: ld hl,setinv1      ; ��⠭���� ����pᨨ.
        jp setfjp
setinv1: and 1
        jr z,setinv2
        ld a,0ffh
setinv2: ld (inverse),a
        jr restfjp

cmode0: xor a               ; ������� / �몫���� ��p�p
        jr cmodes
cmode1: ld a,1
cmodes: ld (curmode),a 
        jp rcurs

mkalt:  ld hl,rcurs          ; 866 code page
        push hl 
        ld bc,0c040h
mkalt1: ld hl,(tblhi-1)
        ld l,40h
mkalt2: ld (hl),c 
        inc c 
        inc l
        djnz mkalt2
        ret 

mkkoi8: ld bc,4040h          ; koi8
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

mkkoi7r: ld hl,(tblhi-1)
         ld l,40h 
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


ttyint::
        ld a,0         ; ������� ��� ��p�p�
curlock equ $-1        ; ����p
        dec a 
        ret z 
        ld a,0
curmode equ $-1        ; ��p�p ����祭 ?
        dec a
        ret z 
        ld hl,curcnt
        dec (hl)        ; �p��� ����諮 ?
        ret nz 
        ld (hl),blink   ; ���� �������
        jp curs_on
curs_jp equ $-2

curs_on: ld hl,(coord)    ; ����祭�� ��p�p�
           srl l
           jr c,curight
           ld c,0f0h
           jp cucalc
curight:   ld c,0fh     
cucalc:    ld a,h
           rrca
           rrca
           rrca
           and 0e0h
           or l 
           ld l,a
           ld a,h
           and 18h
           or 0c7h
           ld h,a
        ld (curaddr),hl
        ld a,(hl)
        ld e,a
        or c
        ld (hl),a
        dec h
        ld a,(hl)
        ld d,a
        or c
        ld (hl),a
        ld (cursafe),de
        ld hl,curs_off
        ld (curs_jp),hl
        ld (hl),021h    ; LD HL,NN
        ret 

curs_off: ld hl,0            ; �몫�祭�� ��p�p�
curaddr  equ $-2
         ld de,0
cursafe  equ $-2
         ld (hl),e
         dec h
         ld (hl),d
         ld hl,curs_on
         ld (curs_jp),hl 
         ld hl,curcnt
         ld (hl),blink
         ld hl,curs_off
         ld (hl),0c9h   ; RET
         ret 

curcnt: db blink             ; ����稪 ��� �������

tkoi1:  db 9eh,80h,81h,96h,84h,85h,94h,83h,95h
tkoi2:  db 086h,082h,09ch,09bh,087h,098h,09dh,099h,097h

