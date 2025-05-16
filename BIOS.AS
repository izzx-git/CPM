

                extrn stkey, getkey, intkey, keybnk
                extrn ttyout, ttyinit, ttyint, ttybnk
                extrn lpr, lprst, lprbnk

                extrn strcpp    ; cppbnk in batch

                public biobnk

                include cpm2_2.inc

biobnk       equ CBANK

.z80

;there is bios started

        .phase bios

        jp boot
        jp wboot
        jp const
        jp conin
        jp conout
        jp list
        jp punch
        jp reader
        jp home
        jp seldsk
        jp settrk
        jp setsec
        jp setdma
        jp read
        jp write
        jp prstat
        jp sectran

bootdisk:  db 0

;-----------------------------------------------------


const:  ld hl,stkey     ; function in driver
        ld d,keybnk
        call gate       ; call driver
        ei              ; interrupts disabled by gate
        ret 


conin1: ei 
        halt            ; wait for one frame
conin:  call const      ; keyboard buffer empty ?
        or a 
        jr z,conin1     ; empty
        ld hl,getkey
        ld d,keybnk
        call gate
        ei 
        ret 

conout: ld a,c
        ld hl,ttyout
        ld d,ttybnk
        call gate
        ei 
        ret 

list:   ld a,c
        ld hl,lpr
        ld d,lprbnk
        call gate
        ei
        ret        

punch:  ret 

reader: ld a,1ah  ; punch,reader - not released
        ret 

prstat: ld hl,lprst
        ld d,lprbnk
        call gate
        ei
        ret 

intadr: di              ; disable interrupts  ЭТО HАДО !  ОБЯЗАТЕЛЬHО !
        ld (intsp),sp   ; escape stack
        ld sp,intstack
        push af         ; escape all registers
        push bc 
        push de 
        push hl 
        exx 
        ex af,af'
        push af 
        push bc 
        push de 
        push hl 
        push ix 
        push iy 
        ld hl,intkey    ; int function in driver
        ld d,keybnk
        call gate
        ld hl,ttyint    ; int function in driver
        ld d,ttybnk
        call gate
        pop iy          ; restore all registers
        pop ix 
        pop hl 
        pop de 
        pop bc 
        pop af 
        exx 
        ex af,af'
        pop hl 
        pop de 
        pop bc 
        pop af 
        ld sp,0
intsp   equ $-2
        ei              ; enable interrupts
        reti            ; special z80 instruction
                        ; to return from interrupt.


;----------------------------------------------------

dpbase: dw      trans_moa,0     ;disk param block base
        dw      0,0
        dw      dirbf,dpblk_moa
        dw      chk_moa0,all_moa0
;       disk parameter header for disk 01
        dw      trans_moa,0
        dw      0,0
        dw      dirbf,dpblk_moa
        dw      chk_moa1,all_moa1
;       disk parameter header for disk 02
        dw      trans_atm,0
        dw      0,0
        dw      dirbf,dpblk_atm
        dw      chk_atm,all_atm
;       disk parameter header for disk 03
        dw      trans_profi,0
        dw      0,0
        dw      dirbf,dpblk_profi
        dw      chk_profi,all_profi
;		disk parameter header for disk 04 SMUC
		dw      trans_smuc,0     
        dw      0,0
        dw      dirbf,dpblk_smuc
        dw      chk_smuc0,all_smuc0



trans_moa: db 0,1,4,5,8,9,12,13,16,17,20,21,24,25,28,29
          db 2,3,6,7,10,11,14,15,18,19,22,23,26,27,30,31

trans_profi:
trans_atm: db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
          db 16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
;only for profi
          db 32,33,34,35,36,37,38,39
trans_smuc: db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
          db 16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
		  db 32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47
		  db 48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63

;disk parameter block
dpblk_moa:
        dw      32              ;sectors per track
        db      5               ;block shift factor
        db      1fh             ;block mask
        db      3               ;null mask
        dw    009bh             ;disk size-1
        dw      63              ;directory max
        db     0c0h              ;alloc 0
        db      0               ;alloc 1
        dw    0010h             ;check size
        dw      4               ;track offset
        dw 0102h  ;extra +15 H=hszmsk L=hszshf


dpblk_atm: dw 32
           db 4
           db 0fh
           db 0
           dw 317
           dw 127
           db 0c0h
           db 0
           dw 32
           dw 2
           dw 0102h

dpblk_profi: dw 0028h
             db 4
             db 0fh
             db 0
             dw 018fh
             dw 007fh
             db 0c0h
             db 00
             dw 0020h
             dw 0000h
             dw 0704h

dpblk_smuc:
        dw 64 ;sectors per track	;SPT - количество секторов (по 128 байт) на дорожку;
        db 5 ;block shift factor	;BSH - количество бит, на которое необходимо сдвинуть размер логического сектора, чтобы получить размер кластера;
        db 31 ;block mask			;BLM - маска кластера - (размер_кластера/128)-1;  
        db 0 ;null mask				;ЕХМ - маска директорной записи : если ЕХМ=0), то максимальный размер, адресуемый одной директорной записью, равен 16К; если ЕХМ=1, то - 32К и т.д.  
        dw 501 ;disk size-1			;DSM - количество BLS -1 (не считая системных дорожек)
        dw 255 ;directory max		;DRM - количество входов в директорию -1
        db 0c0h ;224 ;alloc 0		;AL0,1 - битовая шкала занятости BLS директорией. Начало шкалы - бит 7 AL0, конец - бит 0 AL1. Количество единиц, заполняющих AL0,1 (от начала шкалы) - (DRM+BLS/32)/(BLS/32).
        db 0 ;alloc 1				;AL1
        dw 64 ;0 ;check size		;CKS - размер области CSV в DPH. Для сменных дисков - (DRM+1)/4, для не сменных - 0.
        dw 4 ;track offset			;OFF - количество зарезервированных дорожек на диске (с системой например).
        dw 0102h ;extra +15 H=hszmsk L=hszshf
									;Размер области ALV в DPH - (DSM/8)+1
									;BLS = 1024 (3,7), 2048 (4,15), 4096 (5,31), 8192 (6,63), 16384 (7,127)


		
; ram areas for bdos use

dirbf:    ds 128     ;scratch directory area
          dw 0       ;extra word

all_moa0: ds 64 ;20  ;allocation vector
all_moa1: ds 64 ;20
all_atm:  ds 64 ;40
all_profi: ds 64 ;50
all_smuc0: ds 128 ;20 

chk_moa0: ds 32 ;16  ;check vector
chk_moa1: ds 32 ;16
chk_atm:  ds 32
chk_profi: ds 32
chk_smuc0: ds 64 ;16 

;--------------------------------------------------------

boot:   di 
        ld sp,biosstack
        ld bc,7ffdh
        ld a,biobnk
        out (c),a

        ld hl,ttyinit
        ld d,ttybnk
        call gate
        ld hl,signon        
        call biosprint

        call cache_on
        ld hl,0
        ld (hl),l
        inc (hl)
        jr z,nocache
        dec (hl)
        jr nz,nocache
        ld hl,cache_on
        ld (trdoff),hl
        ld hl,cache_off
        ld (trdon),hl
        jr fboot

nocache: call p01ffd_on
         ld hl,0
         ld (hl),l
         inc (hl)
         jr z,bootfail
         dec (hl)
         jr nz,bootfail
         ld hl,p01ffd_on
         ld (trdoff),hl
         ld hl,p01ffd_off
         ld (trdon),hl
         jr fboot

bootfail: ld hl,failtxt
          call biosprint
          halt
          jp $-1

fboot:   ld a,4 ;диск по умолчанию
         ld (tdrive),a
		 xor a
         ld (iobyte),a 

wboot:  di
        xor a
        ld (hstempt),a  ; host buffer empty
        ld (flush),a    ; data saved
        ld sp,0100h
        ld a,0c3h        ; jp instruction
        ld hl,bios+3    ; warmboot address
        ld (jpboot),a 
        ld (jpboot+1),hl       ; 0: jp wboot
        ld hl,bdos
        ld (entry),a 
        ld (entry+1),hl       ; 5: jp bdos
        ld hl,0c9fbh    ; ei : ret 
        ld (38h),hl     ; rst #38
        ld hl,45edh     ; retn code
        ld (66h),hl 
        ld a,intvec/256
        ld i,a
        im 2
        ld bc,0080h
        call setdma     ; default dma address

           ld hl,movecpp     
           ld de,100h
           ld bc,movecppsize
           ldir
           call 100h

        ld a,(tdrive)
        ld c,a 
        push af 
        call seldsk
        call home
        pop af 
        ld c,a 
        ei 
        jp cpmb         ; go to CPP

movecpp:  ld bc,7ffdh
          ld de,biobnk*256+cppbnk
          out (c),e
          exx
          ld hl,strcpp
          ld de,100h+movecppsize
          push de
          ld bc,bios-cpmb   ; bdos ***
          push bc
          ldir
          exx
          out (c),d
          pop bc
          pop hl
          ld de,cpmb
          ldir
          ret
movecppsize equ ($-movecpp)


biosprint:  ld a,(hl)
            cp 0ffh
            ret z    
            push hl
            ld hl,ttyout
            ld d,ttybnk
            call gate
            pop hl
            inc hl
            jr biosprint

signon: db 0,0,0,0
        db 27,"]",27,"Q",27,"V",0,27,"P",7
        db 12                 ; clear screen code
        db 7                  ; beep
        db 27,"P",4,"CP/M version 2.2"
        db 13,10
        db 27,"P",66,"(C) 1979 Digital Research Ltd"
        db 13,10
        db 27,"P",69,"BIOS Ver 2.0 for Scorpion/Kay/Pentagon"
        db 13,10
        db 27,"P",1,"(L) 26-12-1999 Kirill Frolov 2:5030/827.2"
        db 27,"P",7,13,10,13,10
        db 0ffh

failtxt: db 7
         db 27,"P",66,"RAM at addr. 0000..3FFF not found !",13,10
         db 27,"P",6,"SYSTEM HALTED !",0ffh

cache_on:   push af
            in a,(0fbh)
            pop af
            ret
cache_off:  push af
            in a,(07bh)
            pop af
            ret

p01ffd_on:  push bc
            push af
            ld bc,1ffdh
            ld a,01h
            out (c),a
            pop af
            pop bc
            ret
p01ffd_off: push bc
            push af
            ld bc,1ffdh
            xor a
            out (c),a
            pop af
            pop bc
            ret


;--------------------------------------------------------

home:   xor a 
        ld (sektrk),a 
        ret 

seldsk: ld hl,0                 ;default dph
        ld a,c                  ;selected disk number
        cp 5                    ;disk max number+1
        ret nc                  ;error - no disk

        ld (sekdsk),a           ;seek disk number
        add a,a 
        add a,a 
        add a,a 
        ld l,a 
        ld h,0
        add hl,hl               ; multiplay by 16
        ld de,dpbase            ;base of parm block
        add hl,de               ;hl=.dpb(curdsk)
        ex de,hl 
        ld hl,0ah  ; dpb address here
        add hl,de 
        ld c,(hl)
        inc hl
        ld b,(hl)  ; bc=dpb address
        ld hl,0dh  ; track offset rel.adr.
        add hl,bc
        ld c,(hl)
        inc hl
        ld b,(hl)
        ld (hst_ts),bc ; system tracks
        inc hl     ; extra info:
        ld a,(hl)  ; L=host size shift
        ld (hszshf),a 
        inc hl
        ld a,(hl)  ; H=host size mask
        ld (hszmsk),a
        ex de,hl 
        ret 
;
settrk: ;set track given by registers BC 
        ld (sektrk),bc          ;track to seek
        ret 
;
setsec:
        ;set sector given by register c 
        ld a,c 
        ld (seksec),a           ;sector to seek
        ret 
;
setdma: ;set dma address given by BC 
        ld (dmaadr),bc 
        ret 
;
sectran: ;translate sector number BC, de=table -> hl=sector
        ex de,hl 
        add hl,bc 
        ld a,(hl) 
        ld l,a 
        ld h,0
        ld (seksec),a 
        ret 

;reading sector from disk
read:   ld (cpmsp),sp    ; save cpm stack
        ld sp,biosstack ; and set bios stack
        ld a,0ebh        ; ex de,hl  instuctions, reading flag
        ld (rwflag),a
        jr rwoper

;write sector to disk
write:  ld (cpmsp),sp 
        ld sp,biosstack
        xor a           ; NOP if writing
        ld (rwflag),a 
;        ld a,c          ; operation type
           ld bc,0
hst_ts     equ $-2   ; system tracks
           ld hl,(sektrk)
           scf           ; a=0 ^^^
           sbc hl,bc 
           jr nc,$+3  ; seek > system
           inc a 
        ld (wrtype),a 


rwoper: ld bc,0         ; seek track
sektrk  equ $-2
        inc b
        dec b
        jp nz,rwbad     ; track > 255 !

        push bc 
        ld a,0          ; seek logical sector
seksec  equ $-1
        ld c,a 
        and 0
hszmsk  equ $-1         ; host size mask
        ld e,0
        srl a 
        rr e 
        ld d,a
        ld hl,hstbuf
        add hl,de       ; hl=address in host buffer
        ex de,hl 
        ld a,c          ; seek logical sector
        add a,a 
        ld b,0
hszshf  equ $-1         ; host size shift
        rra 
        or a 
        djnz $-2        ; compute phisical seek sector
        inc a           ; 1..n
        ld c,a
        ld a,(hszmsk)
        cp 07          ; sector size = 1kb ?
        jr nz,rwoper1   ; no
        ld a,(sektrk)
        or a            ; seek track 0 ?
        jr nz,rwoper1   ; no

;its a 1kb sector size disk from profi
;if track=0 change sector 5 to sector 9
        ld a,c
        cp 5
        jr nz,rwoper1
        ld c,9

rwoper1: ld a,c          ; phisical seek sector 1..n
        pop bc          ; seek track in C 
        ld b,a          ; seek sector in B 
        ld a,(hstsec)   ; host sector
        cp b            ; seek == host sector ?
        jr nz,rwdiff    ; data not in host buffer
        ld a,(hstdsk)   ; host disk
        cp 0            ; seek disk
sekdsk  equ $-1
        jr nz,rwdiff
        ld a,(hsttrk)   ; host track
        cp c            ; seek track
        jr nz,rwdiff    ; data not in host buffer
        ld a,0
hstempt equ $-1         ; host buffer empty ?
        or a
        jr nz,rwmove    ; not empty, move from host buffer to dma adress

; data not in host buffer,
; host buffer saved ?
rwdiff: push de         ; save address in host buffer
        push bc         ; save seek sector in B 
        ld a,0
flush   equ $-1
        or a
        jr z,rwsaved    ; data saved

; save host buffer to disk
        call writehst
        ld a,0          ; CY - error flag
        ld (flush),a    ; reset flush flag
        jr c,rwbad      ; disk error

; Lset new host disk, track and sector
; and read phisical sector in host buffer
rwsaved: pop af          ; phisical seek sector
        ld (hstsec),a   ; set sector
        ld a,(sektrk)   ; set track
        ld (hsttrk),a 
        ld a,(sekdsk)   ; set disk
        ld (hstdsk),a 
        call readhst    ; readng
        pop de          ; restore address in host buffer
        jr nc,rwmove    ; no errors
        xor a
        ld (hstempt),a  ; set flag host buffer empty
        jr rwbad        ; disk error

; data in host buffer,
; move logical sector from/to host buffer
rwmove: ld a,1
        ld (hstempt),a  ; host buffer not empty
        ld hl,0
dmaadr  equ $-2         ; dma address
rwflag: ex de,hl        ; r/w flag, nop for writing
        ld bc,128       ; cp/m sector size
        ldir

; it's all right if reading data
        ld a,(rwflag)
        or a
        jr nz,rwend     ; read operation complete

; set flush flag if writing
        ld a,1
        ld (flush),a

; directory writing ?
        ld a,0
wrtype  equ $-1
        dec a
        jr nz,rwend     ; type <> 1  -  not dir. writing

; save host buffer to disk
        call writehst
        ld a,0          ; CY - error flag
        ld (flush),a    ; data saved
        jr c,rwbad      ; disk error

; succesfull end of r/w operations
rwend:  xor a           ; A=0 - no errors
        ld sp,0         ; restore CP/M stack pointer
cpmsp   equ $-2
        ret             ; return to CP/M

; error
rwbad:  ld a,0ffh        ; a=#ff - error
        ld sp,(cpmsp)   ; restore CP/M stack
        ret 






;  DISK DRIVER FUNCTION READHST AND WRITEHST      




; reading sector from
; hstdrv, hsttrk, hstsec
readhst: ld a,80h       ; m=0 C=0 E=0
         ld (rwcomm),a  ; read command for WG93
         jr initfdd

; write sector to
; hstdrv, hsttrk, hstsec
writehst: ld a,0a0h      ; m=0 C=0 E=0
          ld (rwcomm),a  ; write command for WG93

; set ROM basic-48 at page 00h-04000h
initfdd: di            ; disabe interrupts
         ld (intstack-2),sp
         ld sp,intstack-2
         call cache_off
trdon    equ $-2

; set retry counter
        ld a,10       ; attepmpts
        ld (errcnt),a 

retry:

; set 0FFh register of BETA DISK
        ld a,(hstdsk) ; host disk
		cp 4
		jp z,hdd_smuc ;если обращение к HDD
        and 3         ; only 4 phisical
        ld d,a        ; drives present
        ld a,0        ; host track
hsttrk  equ $-1
        rrca 
        ld b,a        ; save track
        rrca 
        rrca 
        rrca 
        cpl 
        and 16        ; side
        or 44         ; 02ch mask
        or d          ; set drive
        ld c,255
        call wrdos

; drive initialized ?
        ld l,d        ; drive
        ld h,0
        ld de,drvparam
        add hl,de 
        ld a,(hl)     ; current track
        ex de,hl      ; store drvparam address
        cp 0ffh       ; drive initialized ?
        jr nz,defdrv  ; yes

;reset drive
        ld a,08       ; h=1 V=0
        call whwrk    ; wait while working
        xor a

; set track register (in B)
defdrv: ld c,63       ; TRACK register
        call wrdos

; set destination track in DATA register
        ld a,b        ; track and side in 7 bit 
        and 127       ; real phisical track
        ex de,hl      ; drvparam address
        ld (hl),a 
        ld c,127      ; DATA register
        call wrdos

; send SEEK command to controller
        ld a,24     ; h=1 V=0 f1,f2=0
        call whwrk  ; wait while working

; set sector number
        ld c,95     ; 05fh SECTOR register of WG93
        ld a,0      ; host sector
hstsec  equ $-1
        call wrdos

; FDD now alwise ready.
; write rw command to WG93
;        ld a,(hsttrk)
;        and 1
;        rlca 
;        rlca 
;        rlca          ; side
;        ld b,a        ; command mask
        ld c,31       ; 01fh COMMAND register
        ld a,0        ; command for WG93
rwcomm  equ $-1
;        or b 
        ld b,a 

; define operation type and set routine address
        and 32        ; command type ?  R/W
        ld de,16341   ; 03fd5h reading routine address
        ld a,28       ; 01ch read error mask
        jr z,soper    ; read sector
        ld a,124      ; 07ch write error mask
        ld de,16314   ; 03fbah writing routine address

; reading/writing sector from WG93
soper:  ld (errmsk),a 
        ld a,b        ; command for WG93
        call wrdos    ; send it
        ld c,127      ; 07fh DATA register
        call soper1   ; read or write
        ld c,31       ; STATUS register
        push af       ; flag Z time out 

; error ?
        call rd1f     ; read STATUS
        ld b,a
        pop af 
        jr z,rwerr1   ; z,a=0 timeout
        ld a,b        ; status
        and 0         ; error mask
errmsk  equ $-1
        jr z,noerr    ; no errors

; write protect ?
        bit 6,a
        jr nz,dskerr

; set track as undefined
rwerr1: ld l,0
hstdsk  equ $-1
        ld h,0
        ld de,drvparam
        add hl,de 
        ld (hl),0ffh

; decrease error counter
rwerr2: ld hl,errcnt  ; error counter
        dec (hl) 
        jr z,dskerr   ; no more attempts

; read again
        jp retry      ; restart driver

;--------------------------------------
; write command in A to WG93 and 
; wait while command working
whwrk:  push bc
        push de
        ld c,31      ; command register
        call wrdos   ; write command
        ld de,3fcah
        ld c,3fh
        call soper1
        pop de
        pop bc
        ret 

; fatal error
dskerr:  ld a,0ffh
         scf          ; its error
         jr endwork

; no errors
noerr:  xor a   ; z,nc,a=0

; restore ram at page 00h-04000h
endwork: call cache_on
trdoff   equ $-2        
         ld sp,(intstack-2)
         ei               
         ret 


soper1: push de       ; address of r/w routine
        ld hl,hstbuf  ; place for sector
        jp 15663      ; 032fh

wrdos:   ld hl,10835  ; 02a53h addr: out (c),a 
         jr godos

; 2740:   in a,(1fh)
;         ld (5ccdh),a
;         ld e,d
;         push de
;         ld a,e
;         out (7fh),a
;         ld a,18h
;         call 3d9ah
;
; 3d9a:   out (1fh),a
;         push hl
;         rst 20h
;         dw 1f54h
;
; 0020:   jp 2f72h
;
; 2f72:   ld (5d02h),hl
;         ld (5d04h),de        
;         pop hl
;         ld e,(hl)
;         inc hl
;         ld d,(hl)
;         inc hl
;         push hl
;         ld hl,3d2fh
;         push hl
;         push de
;         ld hl,5cc2h
;         push hl
;         ld hl,(5d02h)
;         ld de,(5d04h)
;         ret

rd1f:    ld a,(5cc2h)
         push af
         ld hl,(5cc3h)
         push hl
         ld hl,(5d04h)
         push hl
         ld a,(5ccdh)
         push af        ; сохp. что будет испоpчено

         ld hl,5cc2h
         ld (hl),0c3h
         ld hl,rd1fret
         ld (5cc3h),hl  ; пеpехват RST 20h в TR-DOS

         ld a,(hstdsk)
         ld l,a
         ld h,0
         ld de,drvparam
         add hl,de
         ld d,(hl)    ; текущий тpек -- куда позициониpовать
           
         ld hl,2740h  ; куда в тp-дос идти
         push hl
         ld hl,(5d02h)  ; тоже чтобы не испоpтилось
         jp 3d2fh       ; gate address

rd1fret:
;         pop hl   ; 1f54h
;         pop hl   ; 3d2fh
;         pop hl   ; rst 20h ...
;         pop hl   ; push hl
;         pop hl   ; call 3d9ah ...
;         pop hl   ; de                                
         ld hl,12
         add hl,sp
         ld sp,hl        ; restore stack

         ld a,(5ccdh)  ; e = reg(1fh)
         ld e,a
         pop af         ; восстановление испоpченной памяти
         ld (5ccdh),a
         pop hl
         ld (5d04h),hl
         pop hl
         ld (5cc3h),hl
         pop af
         ld (5cc2h),a
         ld a,e
         ret

godos:   push hl 
         jp 15663     ; 03d2fh

; tracks for drives A,B,C,D 
drvparam: db 0ffh,0ffh,0ffh,0ffh

errcnt:  db 0

        db "ASDFG"
hstbuf: ds 1024
        db "qwerty"

;
; END OF DISK DRIVER
;
;-----------------------------------------------------------


;--------------------
;HDD SMUC DISK DRIVER
; reading/write sector from
; hstdrv, hsttrk, hstsec
hdd_smuc:
	;подключение раздела
	ld a,(hdd_smuc_if)
	or a
	jr nz,hdd_smuc_iok ;если инициализация была, пропустим
	;ld a,083h ;%10000011 раздел CP/M уже должен быть смонтирован на диск D
	ld a,00bh ;%00001011 раздел монтируется по имени в DE
	ld de,hdd_smuc_part
	ld bc,00023h ;функция подключить раздел С=35
	call rst8s
	jp c,dskerr ;выход с ошибкой
	;проверка что раздел CP/M 
	; xor a
	; ld hl,hstbuf ;адрес куда читать
	; ld bc,00026h ;функция вернуть таблицу (каталог) подраздела С=38
	; rst 8
	; db 081h
	; jp c,dskerr
	; ld a,(hstbuf)
	; and 31
	; cp 2 ;MicroDOS?
	; jp nz,dskerr
	
	; ld de,00001h ;адрес сектора
	; ld hl,hstbuf1 ;адрес откуда писать
	; ld bc,00125h ;сколько секторов писать, функция записать сектор С=37
	; rst 8
	; db 081h
	; jp noerr
; hstbuf1: "CPM-ZS00"
	ld a,1
	ld (hdd_smuc_if),a ;раздел подключили только в первый раз


hdd_smuc_iok:	
	ld a,(rwcomm)
	and 32 
	jr z,hdd_smuc_read ;если команда чтение
	jr hdd_smuc_write ;если запись
	;jr dskerr 
	;jr noerr ;выход без ошибки
	;ret

hdd_smuc_read: ;чтение сектора
	ld a,(hsttrk) ;дорожка
	ld l,a
	ld h,0
	add hl,hl ;умножить на секторы на каждой (надо бы использовать переменную dpblk_smuc)
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl ;*32
	add hl,hl ;*64
	ld a,(hstsec)
	ld e,a
	ld d,0
	add hl,de ;прибавить сектор на дорожке
	ex de,hl
	;ld de,00001h ;адрес сектора
	ld hl,hstbuf ;адрес куда читать
	ld bc,00124h ;сколько секторов читать, функция читать сектор С=36
	call rst8s
	jp c,dskerr
	jp noerr

	
hdd_smuc_write: ;запись сектора
	ld a,(hsttrk) ;дорожка
	ld l,a
	ld h,0
	add hl,hl ;умножить на секторы на каждой
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl ;*32
	add hl,hl ;*64
	ld a,(hstsec)
	ld e,a
	ld d,0
	add hl,de ;прибавить сектор на дорожке
	ex de,hl
	;теперь записать
	;ld de,00001h ;адрес сектора
	ld hl,hstbuf ;адрес откуда писать
	ld bc,00125h ;сколько секторов писать, функция записать сектор С=37
	call rst8s
	db 081h
	jp c,dskerr
	jp noerr

;вызов rst 8 с контролем экрана
rst8s:
	push af ;задать экран
	ld a,(05b5ch) 
	ld (hdd_smuc_5b5c),a ;сохранить что было
	ld a,019h ;переменная
	ld (05b5ch),a
	pop af
	rst 8
	db 081h
	push af
	ld a,(hdd_smuc_5b5c) ;вернуть ячейку
	ld (05b5ch),a
	pop af
	ret
	
;процедура вызова rst 8 если включено ОЗУ вместо ПЗУ	
; bRST8:	ex	(sp),hl
	; push	af
	; ld	a,(hl)
	; inc	hl
	; ld	(xxx),a
	; pop	af
	; ex	(sp),hl
	; push	bc
	; push	af
	; ld	bc,01FFDh
	; xor	a
	; out	(c),a
; ; 	ld	b,07Fh
; ;	ld	a,010h
; ;	out	(c),a
	; pop	af
	; pop	bc
	; rst	008h
; xxx:	db	0
; ;	push	bc
; ;	push	af
; ;	ld	bc,01FFDh		
; ;	ld	a,001h
; ;	out	(c),a
; ;	pop	af
; ;	pop	bc
	; ret

;hdd_smuc_cs: db 0 ;номер сектора 128 внутри сектора 512	
hdd_smuc_if: db 0 ;флаг инициализации
;hdd_smuc_sec: dw 0 ;текущий сектор для записи
hdd_smuc_part: db "D:\CPMZS0  " ;имя раздела 
hdd_smuc_5b5c: db 0 ;переменная

;END HDD SMUC DISK DRIVER
;-----------------------


;interrupt stack

        ds (0feffh-$) ; 20 bytes for all registers

intstack equ $

intvec:  dw intadr  ; im_2 vector  #feff

;stack of bios HERE

        ds (0fff8h-10-$)

biosstack   equ $

;to scren bank
gate:   di 
        ld (stack),sp 
        ld bc,7ffdh
        out (c),d 
;from screen bank 0fff8h !
        ld sp,0
stack   equ $-2
        ret 

        .dephase


