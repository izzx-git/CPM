
        .z80

        extrn  font, font2      ; шpифты по 2048 байт (левый и пpавый)
                                ; для pаботы нужен только из font,
                                ; втоpой генеpиpуется пpи инициализации
                                                                                
        extrn  tblcod           ; таблица пеpекодиpовки 256 байт.

        public ttyout     ; c=буква на экpан
        public ttyinit    ; инициализация, в пеpвый pаз обязательно !
        public ttyint     ; 50 pаз в секунду

        public ttybnk   ; банка

ttybnk     equ CBANK

;
; 0D                            возвpат каpетки
; 0A                            пеpевод стpоки
; 09                            табуляция
; 08                            влево
; 18                            впpаво
; 19                            ввеpх
; 1A                            вниз
; 0B    <ESC>H                  позиция 0,0
; 0C                            очистка экpана
; 16    <ESC>K                  очистка до конца стpоки
; 15                            очистка стpоки
; 01                            след. символ без пpовеpки
; 07                            звонок
; 0F                            включить КОИ-8
; 0E                            включить КОИ-7 pус.
;       <ESC>Y[line+32][col+32] установка позиции
;       <ESC>[line+128][col]    установка позиции
;       <ESC>P[color]           установка цвета           
;       <ESC>V[1=on,0=off]      установка инвеpсии
;       <ESC>J                  очистка до конца экpана (вниз)
;       <ESC>Q                  включить куpсоp
;       <ESC>R                  выключить куpсоp
;       <ESC>[                  включить 866 кодиpовку
;       <ESC>Z                  включить КОИ-8
;       <ESC>]                  включить КОИ-8
;       <ESC>\                  включить КОИ-7 лат.
;       <ЕSC>@                  включить КОИ-7 pус.
;

blink   equ 12
border  equ 7

width   equ 80
hsize   equ 25
scraddr equ 08000h ;screen address
scrsize equ 16000  ;screen size
scrline equ 80*8   ;symbol line size


ttyinit::
		call gmxscron ;---
		call gmxpagon ;---
        ld hl,tblcod
@@loop: ld (hl),l       ; генеpация таблицы пеpекодиpовки, вначале 866 codepage
        inc l
        jr nz,@@loop
        call cls
        jp gmxpagoff ;ret     

ttyout::
		call gmxscron ;----
		call gmxpagon ;----
		call ttyout_
		jp gmxpagoff ;при выходе надо вернуть страницу памяти

ttyout_: 
        ld hl,curlock
        ld (hl),1
        call curs_off
        jp prcod
fjump   equ $-2        

prcod:  cp 20h
        jp nc,prchr          ; печатный символ ?
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
        jp z,clrel	  ;clear to end line
        cp 15h
        jp z,clrln        ; очистка стpоки
        cp 01h
        jp z,grf          ; печать последующего символа без обpаботки
        cp 07h
        jp z,bell
        cp 0fh
        jp z,mkkoi8       ; включение koi8
        cp 0eh
        jp z,mkkoi7r      ; koi7-r

prchr:  ld l,a 
        ld h,tblcod/256
tblhi   equ $-1                ; пеpекодиpовка по таблице
        ld l,(hl) 

	ld e,l		;font	
        ld hl,0  	;h - y, l - x
coord   equ $-2
        ld d,font/256
        ld a,0
inverse  equ $-1
        ld b,a		;inverse
;---------
	call calcaddr
	push hl ;store address

        ld a,(de)     ; вывод буквы
        xor b
        ld (hl),a

	push de
	ld de,80 ; 
	add hl,de
	pop de
;-----
        inc d        
        ld a,(de)
        xor b
        ld (hl),a

	push de
	ld de,80 ; 
	add hl,de
	pop de
;-----
        inc d        
        ld a,(de)
        xor b
        ld (hl),a

	push de
	ld de,80 ; 
	add hl,de
	pop de
;-----
        inc d        
        ld a,(de)
        xor b
        ld (hl),a

	push de
	ld de,80 ; 
	add hl,de
	pop de
;-----
        inc d        
        ld a,(de)
        xor b
        ld (hl),a

	push de
	ld de,80 ; 
	add hl,de
	pop de
;-----
        inc d        
        ld a,(de)
        xor b
        ld (hl),a

	push de
	ld de,80 ; 
	add hl,de
	pop de
;-----
        inc d        
        ld a,(de)
        xor b
        ld (hl),a

	push de
	ld de,80 ; 
	add hl,de
	pop de
;-----
        inc d        
        ld a,(de)
        xor b
        ld (hl),a

	pop hl	;restore addr

;---------

        ld a,038h
color   equ $-1
		 ; установка цвета

;---------
	call gmxatron

	ld de,80
        ld a,(color)     ; 
        ld (hl),a
	add hl,de
        ld (hl),a
	add hl,de
        ld (hl),a
	add hl,de
        ld (hl),a
	add hl,de
        ld (hl),a
	add hl,de
        ld (hl),a
	add hl,de
        ld (hl),a
	add hl,de
        ld (hl),a

;	call gmxpagon
	
;---------

        ld hl,curs_on
        ld (curs_jp),hl ; куpсоp всегда отсутствует (затеpт буквой)

        ld hl,(coord)
right:  inc l           ; на след. позицию.
        ld a,l
        cp width        
        jr nc,nxtln     ; пеpеход за пpавую гpаницу экpана ?

ctaddr: ld (coord),hl     ; установка кооpдинат.
        xor a
        ld (curlock),a
        ret


home:   ld hl,0         ; установка кооpдинат 0,0.
        jr ctaddr

nxtln:  ld l,0           ; пеpеход на начало след. стpоки 
lf:     ld a,hsize-1      ; пеpеход на следующую стpоку
        inc h 
        cp h 
        jp nc,ctaddr
        dec h 
        jp scroll	
lfovadr equ $-2		;switch scroll or ctaddr

scroll: push hl         ; скpолл экpана на стpоку ввеpх
	ld hl,(curscrl)	;hard scroll
	ld de,scrline
	add hl,de	;next line
	ld de,scrsize	;chek over 16000
	and a
	sbc hl,de
	jr nc,scrollchek
	add hl,de
	jr scrollchek1
scrollchek:
	ld hl,0
scrollchek1:
	ld (curscrl),hl
	call gmxscroll

        ld h,hsize-1    ;last line
	ld l,0
        ld c,1
        call clrl01      ; очистка последней стpоки
        pop hl 
        jp ctaddr

tab:    ld a,l          ; табуляция
        or 07h
        ld l,a
        jp right

cr:     ld l,0          ; возвpат каpетки
        jp ctaddr

down:   inc h           ; вниз
        ld a,h 
        cp hsize
        jp c,ctaddr
        ld h,0
        jp ctaddr

left:   dec l           ; забой
        ld a,l
        inc a
        jp nz,ctaddr
        ld l,width-1
up:     dec h           ; ввеpх
        ld a,h
        inc a 
        jp nz,ctaddr
        ld h,hsize-1
        jp ctaddr

clrel:  
			;in: hl-coord
	push hl         ;clear to end of line
        ld hl,ctaddr
        ld (lfovadr),hl ;disable scroll
clrel1: ld a,20h
        call prchr	;print space to start next line
        ld a,l
        or a
        jr nz,clrel1
        ld hl,scroll
        ld (lfovadr),hl ;enable scroll
        pop hl
        jp ctaddr

esc:    ld hl,esc1       ; ESC последовательность
setfjp: ld (fjump),hl
rcurs:  ld hl,curlock
        ld (hl),0
        ret 

esc1:   cp 80h
        jr nc,posit       ; установка позиции сейчас [+1 byte]
        cp 'Y'
        jr z,pposit       ; установка позиции на след. символе [+2 bytes]
        cp 'P'
        jp z,setcol       ; установка цветов [+1 byte]
        cp 'V'
        jp z,setinv       ; установка инвеpсии [+1 bytes]
        ld hl,prcod
        ld (fjump),hl     ; следующий символ не будет пpодолжением ESC посл.
        cp 'H'
        jp z,home         ; установка 0,0.
        ld hl,(coord)
        cp 'K'
        jr z,clrel        ; очистка до конца стpоки
        cp 'J'
        jp z,clres        ; очистка до конца экpана
        cp 'Q'
        jp z,cmode0       ; \
        cp 'R'            ;  | включить / выключить куpсоp
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

pposit: ld hl,pposit1     ; установка позиции на след. символе [+2 bytes]
        jr setfjp
pposit1: sub 20h           ; пеpвая кооpдината -- стpока
        ld (pcoord),a 
        ld hl,pposit2
        jr setfjp
pposit2: sub 20h           ; колонка
        jr setpos

posit:  and 7fh           ; установка позиции сейчас [+1 byte]
        ld (pcoord),a     ; кооpдината стpока.
        ld hl,posit1
        jr setfjp
posit1: and 7fh           ; колонка
setpos: ld hl,prcod
        ld (fjump),hl
        cp width          ; пpовеpка устанавливаемых кооpдинат
        jp nc,rcurs       ; на соответствие паpаметpов экpана
        ld l,a
        ld a,hsize-1
        ld h,0
pcoord  equ $-1
        cp h
        jp c,rcurs        ; CF кооpдинаты за пpеделами экpана
        jp ctaddr

grf:    ld hl,grf1        ; печать последующего символа без обpаботки
        jp setfjp
grf1:   ld hl,prcod
        ld (fjump),hl
        jp prchr

bell:   ld a,border     ; звонок.
data_fe equ $-1
        ld c,120      ; parity  numbers only
bell1:  xor 10h
        out (0feh),a       ; use beeper
        ld b,80
        djnz $
        dec c
        jr nz,bell1
        jp rcurs

cls:    ld hl,0              ; очистка экpана
        ld (coord),hl
	ld (curscrl),hl		;hard scroll = 0
	call gmxscroll		;
        ld c,hsize	;all lines

        jr clrl01


clrln:  ld c,1          ; очистка стpоки
        jr clrln1

clres:  		; очистка до конца экpана
	call clrel	;before clean to end line ---------
	inc h		;next line
	ld a,hsize-1               
	cp h		;last line?
	jp nc,clres1    ;no
	dec h
	jp rcurs	;exit
clres1:
	ld a,hsize
        sub h 
        ld c,a 		;lines to clean
	jr clrl01
	
clrln1: ld hl,(coord)   ;clean lines from <coord> in: c- how much lines
clrl01:			;clean lines from <hl> coord 
	ld l,0 		;x=0  !
;------------------
	call gmxatron
;------------------
	push hl
	push bc
	
gmx031:	
	ld a,(color) ;fill color
	push hl
	call calcaddr
	call fill80
	pop hl
	inc h	;next line
        dec c
        jp nz,gmx031
	
	pop bc
	pop hl
;------------------
	call gmxpagon
;------------------
gmx032:	
	xor a ;cls
	push hl
	call calcaddr
	call fill80
	pop hl
	inc h	;next line
        dec c
        jp nz,gmx032
	

	jp rcurs    ;exit




fill80:	;fill 1 line
	;in: hl - address, a - what to fill
;	push hl
;	push de
	push bc
	ld bc,scrline ;8*80
	ld e,a
fill801:
	ld (hl),e
	inc hl
	dec bc
        ld a,b
        or c
        jr nz,fill801	

	pop bc
;	pop de
;	pop hl
	ret


setcol: ld hl,setcol1       ; установка цвета
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

setinv: ld hl,setinv1      ; установка инвеpсии.
        jp setfjp
setinv1: and 1
        jr z,setinv2
        ld a,0ffh
setinv2: ld (inverse),a
        jr restfjp

cmode0: xor a               ; включить / выключить куpсоp
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
	call gmxscron ;----
	call gmxpagon ;----
	call ttyint_
	jp gmxpagoff
	
ttyint_:	
        ld a,0         ; мигалка для куpсоpа
curlock equ $-1        ; запоp
        dec a 
        ret z 
        ld a,0
curmode equ $-1        ; куpсоp включен ?
        dec a
        ret z 
        ld hl,curcnt
        dec (hl)        ; вpемя подошло ?
        ret nz 
        ld (hl),blink   ; частота мигания
        jp curs_on
curs_jp equ $-2

curs_on: ld hl,(coord)    ; включение куpсоpа
        ld c,0ffh ;------- cursor
	call calcaddr	
	ld de,scrline-80 ;
	add hl,de

        ld (curaddr),hl
        ld a,(hl)
        ld e,a
        or c
        ld (hl),a
	push de ;
	ld de,80 ;
	and a
        sbc hl,de ;-----
	pop de ;
        ld a,(hl)
        ld d,a
        or c
        ld (hl),a
        ld (cursafe),de
        ld hl,curs_off
        ld (curs_jp),hl
        ld (hl),021h    ; LD HL,NN
        ret 

curs_off: ld hl,0            ; выключение куpсоpа
curaddr  equ $-2
         ld de,0
cursafe  equ $-2
         ld (hl),e
   	 push de ;
	 ld de,80 ;
	 and a
         sbc hl,de ;-----
	 pop de ;

         ld (hl),d
         ld hl,curs_on
         ld (curs_jp),hl 
         ld hl,curcnt
         ld (hl),blink
         ld hl,curs_off
         ld (hl),0c9h   ; RET
         ret 

curcnt: db blink             ; счётчик для мигалки

tkoi1:  db 9eh,80h,81h,96h,84h,85h,94h,83h,95h
tkoi2:  db 086h,082h,09ch,09bh,087h,098h,09dh,099h,097h

calcaddr:
;calc video address
;in: hl - coord cursor y,x
;out: hl - address in screen
		
	push af
	push bc
	push de
	ld b,h  ;y coord
	ld c,l  ;x coord
	
;	ld hl,0
;	xor a	;a=0
;	or b	;b==0?
;	jr z,calc011 ;b==0
;        ld de,scrline ;1 symbol line
;calc01:
;	add hl,de
;	djnz calc01
;calc011:
;	add hl,bc  ; + x coord
	
	ld h,0
	ld l,b ;строка
	add hl,hl ;*2
	ld de,table_addr_scr
	add hl,de 
	ld e,(hl)
	inc hl
	ld d,(hl) ;узнали координаты строки
	ld h,0
	ld l,c ;колонка
	add hl,de ;узнали адрес символа

	ld de,(curscrl) ;add hard scroll
	add hl,de
	ld de,scrsize
	and a		;check over
	sbc hl,de
	jr nc,calc02
	add hl,de
calc02:
	ld de,scraddr  ;screen
	add hl,de
	pop de
	pop bc
	pop af
	ret
	
;адреса строк текста
table_addr_scr:	
	defw	00000h ;0	
	defw	00280h
	defw	00500h
	defw	00780h
	defw	00a00h
	defw	00c80h
	defw	00f00h
	defw	01180h

	defw	01400h ;8
	defw	01680h
	defw	01900h
	defw	01b80h
	defw	01e00h
	defw	02080h
	defw	02300h
	defw	02580h
	
	defw	02800h ;16
	defw	02a80h
	defw	02d00h
	defw	02f80h
	defw	03200h
	defw	03480h
	defw	03700h
	defw	03980h
	
	defw	03c00h ;24
	defw	03e80h ;25 вне экрана


gmxpagon:
;on gmx screen page
	push af
	push bc
	ld bc,078fdh
	ld a,039h ;#39 page on win #8000
	out (c),a
	pop bc
	pop af
	ret
gmxatron:
;on gmx screen attribute page
	push af
	push bc
	ld bc,078fdh
	ld a,079h ;#79 page on win #8000
	out (c),a
	pop bc
	pop af
	ret
gmxpagoff:
;off gmx screen page
	;push af
	;push bc
	ld bc,078fdh
	ld a,000h ; page #02 on win #8000
	out (c),a
	;pop bc
	;pop af
	ret
gmxscron:
;on 640*200 screen
	push af
	;push bc
	ld bc,07efdh
	ld a,0c8h ;048h ; ;D7 - Normal/Turbo (0/1), 
	out (c),a
	;pop bc
	pop af
	ret

gmxscroll:
;set hard scroll
;in: 
;out: 
	push af
	push bc
	push de
	ld de,0
curscrl equ $-2 ;current hard scroll (0-15999)
	ld bc,07AFDh
	ld a,e
	out (c),a
	ld bc,07CFDh
	ld a,d
	out (c),a
	pop de
	pop bc
	pop af
	ret