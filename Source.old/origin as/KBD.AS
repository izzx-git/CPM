

        public intkey   ; 50 p�� � ᥪ㭤�
        public getkey   ; a=������  (0 �᫨ ���p ����)
        public stkey    ; a=ff ���p �� ����, a=0 ����

        public keybnk ; �����

             
keybnk   equ CBANK

DELAY1    equ 1  ; ��⨤p����� �p� ����⨨
DELAY2    equ 10 ; ����p��� ��⮯���p�
DELAY3    equ 2  ; ��p��� ��⮯���p�
RIPDEL    equ 3  ; �p��� ᬥp� ������ (��� �p�������� ��������p)
RUSTIME1  equ 50 ; ���ᨬ��쭮� �p��� 㤥p����� CAPS ��� RUS/LAT ��p�����⥫�       
RUSTIME2  equ 50-2  ; �������쭮� �p��� ^^^ (����� �� ���ᨬ��쭮��!)

; ������� _H�_�����_ ���������� ������� � ���O� 0.
; ��� ������������ ��� ��H����H�����H�� ������ ��������.

; ��� 1 ����� �����襩 CAPS LOCK ! (�� ����� �ᯮ�짮������ ��� ��p�����p����)

; KOI-7R coding:
;    @ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~
;    ��������������H�����������������椥�娩�������p��㦢������� 

; ���-8 ⠡���:
;  A3  B3
;  �   �
;
;  C0 C1 C2 C3 C4 C5 C6 C7 C8 C9 CA CB CC CD CE CF 
;  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  
;
;  D0 D1 D2 D3 D4 D5 D6 D7 D8 D9 DA DB DC DD DE DF
;  �  �  p  �  �  �  �  �  �  �  �  �  �  �  �  �
;
;  E0 E1 E2 E3 E4 E5 E6 E7 E8 E9 EA EB EC ED EE EF 
;  �  �  �  �  �  �  �  �  �  �  �  �  �  �  H  �  
;
;  F0 F1 F2 F3 F4 F5 F6 F7 F8 F9 FA FB FC FD FE FF
;  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �
;


keylat:  db " ",0,"MNB",0Dh,"LKJHPOIUY0987612345QWERTASDFG",0,"ZXCV"
key866:  db " ",0,"���",0Dh,"���������0987612345����������",0,"����"
keykoi:  db " ",0,"���",0Dh,"���������0987612345����������",0,"����"
symlat:  db 1Bh,0,".,*",0Bh,"=+-^",22h,";",0Ch,"][_)('&!@#$%",1,0Fh,6,"<>~|\{}",0,":`?/"
sym866:  db 1Bh,0,".,*",0Bh,"=+-^",22h,";",0Ch,"][_)('&!","�","#$%",1,0Fh,6,"<>�����",0,":`?/"
symkoi:  db 1Bh,0,".,*",0Bh,"=+-^",22h,";",0Ch,"][_)('&!","�","#$%",1,0Fh,6,"<>�����",0,":`?/"

;            0   1   2   3   4   5   6   7   8   9 
capsnum: db 7Fh,09h,0FCh,12h,03h,08h,18h,05h,04h,07h
ctrlnum: db 1bh,1ah,1ah,1ah,1ah,1bh,1bh,1bh,1bh,1bh

SS_     equ 1
CS_     equ 35  ; scan codes 4 caps & sybol shift

CL_KEY  equ 96h         ; CAPS LOCK scan code          \
KOI_KEY equ 0d2h        ; EXT-8 ��p����祭�� � ���-8    | ᪠�����, H� ASCII !
KEY_866 equ 0d1h        ; EXT-9 ��p����祭�� � 866     /

CS_SPC  equ 1Bh         ; BREAK = ESCAPE
CS_ENT  equ 0Ah         ; LINE FEED

CTRL_ENT  equ 1ah       ; CTRL-Z �� ����� �p�� Z (Z � SPC � EXT �� ����������)

keybuf:        db 0,0,0,0,0,0,0,0,0,0,0,0  ; 0=empty
keybuftop      equ $

ripcnt:        db 0

.z80


;----------------------------------------------------------------------                


        
set_866:        ld de,key866
                ld hl,sym866
                jr set_codepage

set_koi:        ld de,keykoi
                ld hl,symkoi

set_codepage:   xor a
                ld (keycnt),a   ; ��⮯���p ���p�饭
                ld (keyrus),de
                ld (symrus),hl
                ld hl,(keytbl)
                ld de,keylat    ; �������� ��p�� ⠡���
                sbc hl,de
                jr z,tolat
                jr torus


ripkey:         bit 7,d       
                ld a,0
ruscnt          equ $-1
                jr z,riprus   ; CAPS ���饭 ?
                or a
                jr z,ripcont  ; ����祭
                dec a
                jr nz,ripcont    ; 㬥��訫�
                inc a
                jr ripcont      ; ����� 1 �����

riprus:         cp 2
                jr c,ripnorus     ; �p���p�� 1<time<max ��� CAPS
                cp RUSTIME2   
                jr nc,ripnorus          

                ld hl,(keytbl)  ; ��p����祭�� RUS / LAT
                ld de,keylat
                or a
                sbc hl,de
                jr z,torus

tolat:          ld hl,symlat
                jr ruslat

torus:          ld de,key866
keyrus          equ $-2
                ld hl,sym866
symrus          equ $-2

ruslat:         ld (keytbl),de
                ld (symtbl),hl

ripnorus:       ld a,RUSTIME1   ; ��p���p���/������p��� CAPS
ripcont:        ld (ruscnt),a

                ld hl,ripcnt
                dec (hl)
                ret nz          ; ��p⢠� ������ ? (��⨤p����� ���᪠���)
                
                xor a
                jr newkey       ; 㡨�� ������, � ��� ��⠫� � ��諠


kscend:         xor a        ; too many keys  DEAD KEY
                ld (ruscnt),a  ; RUS/LAT ���p�饭

newkey:         ld (lastkey),a  ; new key pressed
                ld a,1
                ld (repkeyflag),a
                ld a,DELAY1
                ld (keycnt),a
                ld a,RIPDEL
                ld (ripcnt),a
                ret

ksc_cs:         set 7,d
                jr ksc3
ksc_ss:         set 6,d
                jr ksc3

intkey::        ld de,0ffh     ; ���� �����
                ld h,e
                ld bc,7ffeh
                        
kscloop:        ld l,h
                in a,(c)
                cpl
                and 1fh
                jr z,kscnxt

ksc1:           inc l          ; ����� ������ � p�� ����� ?
                srl a
                jr nc,ksc1

                ex af,af'
                ld a,l
                cp CS_
                jr z,ksc_cs  ; CAPS SHIFT ?
                cp SS_
                jr z,ksc_ss  ; SYMBOL SHIFT ?
                inc e
                jr nz,kscend ; ����� ����� ������

                ld e,a
ksc3:           ex af,af'
ksc2:           jr nz,ksc1    ; ���� p� �p�᪠��p���� ?

kscnxt:         ld a,h
                add a,5
                ld h,a
                rrc b
                jr c,kscloop  ; ᫥���騩 ��p�� �� ����� 

                              ; E=������ ������, bits 6,7 = ����.
                              ; E=FF ��祣� �� �����
                ld a,e
                inc a
                or d
                ld e,a
                and 3fh
                jp z,ripkey    ; 㡨����� ���饭��� ������

                ld hl,ruscnt
                ld (hl),0  ; rus/lat LOCKED !

                ld a,e                        
                cp 0
lastkey         equ $-1
                jr nz,newkey    ; ��p�� ������

                ld a,0
keycnt          equ $-1
                or a
                ret z           ; ���� ���� -- �����p���� ��⮯���p�.
                dec a
                ld (keycnt),a
                ret nz          ; ��⨤p����� �p� ����⨨  RET -- �� �����

  ;�H���� H�����, ��������� ���H����

                ld a,e
                cp KOI_KEY
                jp z,set_koi
                cp KEY_866
                jp z,set_866
                cp CL_KEY       ; �p���p�� CAPS LOCK ?
                jr nz,nosyskey
                
                ld a,(capsflag) ; ��p����祭�� CAPS LOCK 䫠��
                and 1
                dec a
                ld (capsflag),a
                xor a
                ld (keycnt),a   ; ��⮯���p ���p�饭 
                ret
                
nosyskey:       and 3fh         ; ��p�����p���� ᪠�-��� -> ASCII
                ld b,0
                ld c,a
                dec c    ; 0 -- �� �ᯮ������
                bit 6,e
                jr nz,symbol    ; ������ �� SYMBOL SHIFT 

                ld hl,keylat    ; ����� ���� ⮫쪮 �㪢�, ��p�
keytbl          equ $-2         ; ���p � �p����
                add hl,bc
                ld a,(hl)       ; ��� ����⮩ ������ �� ⠡����

                cp '9'+1
                jr nc,nodig     ; �㪢� ��� ᨬ���
                bit 7,e
                jr z,nocaps      ; CAPS �� �����

                cp 0dh          ; ��p�����p���� CAPS SHIFT
                jr z,capsent    ; ��� 0..9, SPACE � ENTER
                cp 20h
                jr z,capsspc
                sub '0'
                ld c,a
                ld b,0
                ld hl,capsnum
                add hl,bc
                ld a,(hl)
                jr nocaps

capsent:        ld a,CS_ENT
                jr nocaps
capsspc:        ld a,CS_SPC
                jr nocaps

                         ;  ������������� (������H��) ��� ���� ONLY !!!
nodig:          ld a,0ffh       ; 00/FF only
capsflag        equ $-1
                xor e           ; ��p�������� CAPS LOCK � CAPS SHIFT
                and 80h                
                ld a,(hl)       ; ��� ����⮩ ������ �� ⠡����
                jr z,nocaps     

                ld hl,(keytbl)
                ld bc,keykoi
                sbc hl,bc
                jr nz,caps866   ; �� KOI-8 ����p����

                         ; ������������� ��� ���-8
                cp 0b3h       
                jr z,koia3      ; � -> �
                cp 0c0h
                jr c,latcaps    ; no koi-8 char
                sub 20h
                jr nocaps
koia3:          dec a
                jr nocaps

                        ; ��� 866 ��������� � ����H���� ����
caps866:        cp '�'          ; p���� �㪢� �� p������ ��p�����p�����
                jr z,ruscaps
                cp '�'  
                jr c,latcaps

                add a,50h       ; �..� -> p..�
                jr nocaps

ruscaps:        inc a
                jr nocaps       ; � -> �

latcaps:        add a,20h       ; A..Z -> a..z   �..� -> �..�
                jr nocaps
       
symbol:         bit 7,e
                jr nz,extkey     ; SYMBOL+CAPS �����p������
                ld hl,symlat
symtbl          equ $-2
                add hl,bc       ; ������ � SYMBOL SHIFT
                ld a,(hl)
                cp 80h
                jr c,nocaps     ; �� p��᪠� �㪢� -- ᨬ���
                jr nodig        ; p��᪠� �㪢� �������� CAPS ��pp��樨

extkey:         ld hl,keylat
                add hl,bc
                ld a,(hl)
                sub 'A'-1
                jr nc,nocaps    ; CTRL-<?> keys
                add a,'A'-1
                sub '0'
                jr c,ctrlent    ; CTRL-ENTER
                ld c,a
                ld hl,ctrlnum   ; CTRL-<NUMBER>
                add hl,bc
                ld a,(hl)
                jr nocaps

ctrlent:        ld a,CTRL_ENT


nocaps:         ld c,a
                ld hl,keycnt
                ld a,1      ; 0=��⮯���p 1=��p���쭮�
repkeyflag      equ $-1
                or a
                jr z,arepeatdel
                dec a
                ld (repkeyflag),a
                ld (hl),DELAY2     ; ����p��� ��p�� ��⮯���p��
                jr putkey
arepeatdel:     ld (hl),DELAY3     ; ����p��� ��⮯���p�

putkey:         ld hl,keybuf
keybufwr        equ $-2
                ld a,(hl)
                or a
                ret nz          ; ��� ���� � ���p� ?

                ld (hl),c
                inc hl
                ex de,hl
                ld hl,keybuftop
                sbc hl,de
                jr nz,notroundwr   ; �� ����� ���p�
                ld de,keybuf
notroundwr:     ld (keybufwr),de
                ret

;--------------------------------------------------------------------------

getkey::        ld hl,keybuf
keybufrd        equ $-2
                ld a,(hl)
                or a
                jr nz,iskey
                ret                     ; ���p ����

stkey::         ld hl,(keybufrd)
                ld a,(hl)
                or a
                ret z
                ld a,0ffh
                ret

iskey:          ld (hl),0
                inc hl
                ex de,hl
                ld hl,keybuftop
                sbc hl,de
                jr nz,rdkeynoround
                ld de,keybuf
rdkeynoround:   ld (keybufrd),de
                ret



