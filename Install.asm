;Установщик CP/M на HDD SMUC
;izzx
	device ZXSPECTRUM48
col_fon equ 1 ;цвет фона
col_fnt equ 7 ;цвет шрифта
col_fon_err equ 2 ;цвет фона ошибка
part_size equ 9*255+9 ;8388608/512 ;размер бэкапа в секторах
hstbuf equ #8000 ;буфер
sys_sec equ 4*64 ;системных секторов пропустить при бэкапе

	org #6000
start_inst
	call cls_pic
	ld hl,mes_title
	call print_mes ;печать

	ld a,010h ;переменная
	ld (05b5ch),a
	ld a,(05d19h) ;текущий диск
	ld (cur_drive),a
	
	call mount_part
	jp c,dskerr ;выход с ошибкой
	
	;ждать выбор
wait 
	halt
	ld a,(23556) ;сист. переменная нажатая клавиша 
	cp 255
	jr z,wait
	cp "1"
	jr c,wait
	cp "4"
	jr nc,wait
	;отметить выбор
	ld (choice),a
	sub "1"-3
	ld (mes_choice+1),a
	ld hl,mes_choice
	call print_mes 	
	;запрос
	ld hl,mes_quest
	call print_mes ;печать	

wait2
	halt
	ld a,(23556)
	cp 255
	jr z,wait2
	cp "Y"
	jr z,select
	cp "N"
	jr z,start_inst
	jr wait2

select ;выбор подтверждён
	ld a,(choice)
	cp "1"
	jr z,loader
	cp "2"
	jp z,backup
	jp restore
	
mount_part
	;подключение раздела	
	ld a,00bh ;%00001011 раздел монтируется по имени в DE
	ld de,hdd_smuc_part
	ld bc,00023h ;функция подключить раздел С=35
	rst 8
	db 081h
	ret

loader
	;запись загрузчика
	ld a,13
	rst 16
	ld a,13
	rst 16
	call cls_buf
	;найти файл
	ld hl,name_1
	call print_mes
	ld hl,name_1 ;BOOTSEC
	call find_file
	jp c,dskerr_fdd
	ld hl,hstbuf
	ld de,(#5cf4)
	ld      a,(#5cea)
    ld      b,a ;длина в секторах
	ld      c,#05 ;читаем
    call    trdos
	jp 		c,dskerr_fdd	
	;записать
	call mount_part
	jp c,dskerr ;выход с ошибкой
	ld de,0 ;адрес сектора
	ld hl,hstbuf ;адрес откуда читать
	ld bc,02025h ;писать #20 секторов
	rst 8
	db 081h
	jp c,dskerr_hdd ;выход с ошибкой

	call cls_buf	
	ld hl,name_2
	call print_mes
	ld hl,name_2 ;BIOS
	call find_file
	jp c,dskerr_fdd
	ld hl,hstbuf
	ld de,(#5cf4)
	ld      a,(#5cea)
    ld      b,a ;длина в секторах
	ld      c,#05 ;читаем
    call    trdos
	jp 		c,dskerr_fdd	
	;записать
	call mount_part
	jp c,dskerr ;выход с ошибкой
	ld de,1+32 ;адрес сектора
	ld hl,hstbuf ;адрес откуда читать
	ld bc,02025h ;писать #20 секторов
	rst 8
	db 081h
	jp c,dskerr_hdd ;выход с ошибкой

	call cls_buf
	ld hl,name_3
	call print_mes	
	ld hl,name_3 ;DRV
	call find_file
	jp c,dskerr_fdd
	ld hl,hstbuf
	ld de,(#5cf4)
	ld      a,(#5cea)
    ld      b,a ;длина в секторах
	ld      c,#05 ;читаем
    call    trdos
	jp 		c,dskerr_fdd	
	;записать
	call mount_part
	jp c,dskerr ;выход с ошибкой
	ld de,1+32+32 ;адрес сектора
	ld hl,hstbuf ;адрес откуда читать
	ld bc,02025h ;писать #20 секторов
	rst 8
	db 081h
	jp c,dskerr_hdd ;выход с ошибкой

	call cls_buf
	ld hl,name_4
	call print_mes
	ld hl,name_4 ;FONT
	call find_file
	jp c,dskerr_fdd
	ld hl,hstbuf
	ld de,(#5cf4)
	ld      a,(#5cea)
    ld      b,a ;длина в секторах
	ld      c,#05 ;читаем
    call    trdos
	jp 		c,dskerr_fdd	
	;записать
	call mount_part
	jp c,dskerr ;выход с ошибкой
	ld de,1+32+32+32 ;адрес сектора
	ld hl,hstbuf ;адрес откуда читать
	ld bc,02025h ;писать #20 секторов
	rst 8
	db 081h
	jp c,dskerr_hdd ;выход с ошибкой
	ld hl,mes_ok
	call print_mes 	
	call wait_
	jp start_inst
	ret
	
	
backup
	;бэкап
	ld hl,part_size
	ld (cycl),hl
	call toDecimal
	ld hl,decimalS
	ld de,progr2
	ld bc,5
	ldir
	ld hl,mes_progr
	call print_mes	
	;найти файл для бэкапа
	ld hl,back_name
	call find_file
	jp c,dskerr_fdd
	ld de,sys_sec
	ld (cur_trk_hdd),de
backup_c ;цикл
	call mount_part
	jp c,dskerr ;выход с ошибкой
	ld de,(cur_trk_hdd) ;адрес сектора
	inc de
	ld (cur_trk_hdd),de
	ld hl,hstbuf ;адрес куда читать
	ld bc,00124h ;сколько секторов читать, функция читать сектор С=36
	rst 8
	db 081h
	jp c,dskerr_hdd ;выход с ошибкой
	;записать
	ld a,(cur_drive)
	ld (05d19h),a
    ld c,1 ;инициализация дисковода
    call trdos
	jp c,dskerr_fdd	
	
	ld hl,hstbuf
	ld de,(#5cf4)
	ld      bc,#0106 ;пишем 1 сектор по 256 из буфера
    call    trdos
	jp 		c,dskerr_fdd	
	
	ld bc,(cycl) ;сколько готово
	ld hl,part_size
	and a
	sbc hl,bc
	inc hl
	call toDecimal
	ld hl,decimalS
	ld de,progr1
	ld bc,5
	ldir
	ld hl,mes_progr
	call print_mes	

	ld bc,(cycl)
	dec bc
	ld (cycl),bc
	ld a,b
	or c
	jr nz,backup_c
	ld hl,mes_ok
	call print_mes 	
	call wait_
	jp start_inst
	
restore
	;восстановление
	ld hl,hstbuf ;вторые половинки секторов будут чистые
	ld de,hstbuf+1
	ld bc,512
	ld (hl),0
	ldir
	
	ld hl,part_size
	ld (cycl),hl
	call toDecimal
	ld hl,decimalS
	ld de,progr2
	ld bc,5
	ldir
	ld hl,mes_progr
	call print_mes	
	;найти файл для восстановления
	ld hl,back_name
	call find_file
	jp c,dskerr_fdd
	ld de,sys_sec
	ld (cur_trk_hdd),de
restore_c ;цикл
	ld a,(cur_drive)
	ld (05d19h),a
    ld c,1 ;инициализация дисковода
    call trdos
	jp c,dskerr_fdd
	
	ld hl,hstbuf
	ld de,(#5cf4)
	ld      bc,#0105 ;читаем 1 сектор по 256 в буфер
    call    trdos
	jp 		c,dskerr_fdd
	;записать
	call mount_part
	jp c,dskerr ;выход с ошибкой
	ld de,(cur_trk_hdd) ;адрес сектора
	inc de
	ld (cur_trk_hdd),de
	ld hl,hstbuf ;адрес откуда читать
	ld bc,00125h ;сколько секторов писать, функция записать сектор С=37
	rst 8
	db 081h
	jp c,dskerr_hdd ;выход с ошибкой
	
	ld bc,(cycl) ;сколько готово
	ld hl,part_size
	and a
	sbc hl,bc
	inc hl
	call toDecimal
	ld hl,decimalS
	ld de,progr1
	ld bc,5
	ldir
	ld hl,mes_progr
	call print_mes	

	ld bc,(cycl)
	dec bc
	ld (cycl),bc
	ld a,b
	or c
	jr nz,restore_c
	ld hl,mes_ok
	call print_mes 	
	call wait_
	jp start_inst
	
	
dskerr
	ld hl,mes_error
	call print_mes 
	ret
dskerr_fdd
	ld hl,mes_err_fdd
	call print_mes	
	ret
dskerr_hdd
	ld hl,mes_err_hdd
	call print_mes	
	ret	

trdos ;вызов с контролем ошибки
    call    #3d13
    ld      a,c
	cp 		#ff
	ccf
	ret nz
	scf ;ошибка
	ret

find_file ;поиск файла на дискете, в HL адрес имени
;WAITKEY	XOR A:IN A,(0FEh):CPL:AND 01Fh:JR Z,WAITKEY
	ld (temp_hl),hl
	ld a,(cur_drive)
	ld (05d19h),a
    ld c,1 ;инициализация дисковода
    call trdos
	jp c,fnderr_fdd
    ; ld c,#18
    ; call trdos
	; jp c,fnderr_fdd
	ld hl,(temp_hl)
	ld      c,#13 ;move file info to syst var
    call    trdos
	jp 		c,fnderr_fdd
    ld      c,#0a ;find file
    call    trdos
	jp 		c,fnderr_fdd ;если не нашли файла
    ld      c,#08 ;read file title
    call    trdos
	jp 		c,fnderr_fdd
    ld      de,(#5ceb) ;начало файла сектор дорожка
    ld      (#5cf4),de ;текущая позиция	
	or a
	ret
fnderr_fdd
	scf
	ret

wait_ ;any key
	halt
	ld a,(23556)
	cp 255
	jr z,wait_
	ret
	
print_mes ; печать строки до цифры 255. В hl адрес строки
	push bc
	ld b,0 ;не больше 256
print_mes1
	ld a,(hl)
	cp 255
	jr z,print_mes_e
	rst 16
	inc hl
	djnz print_mes1
print_mes_e
	pop bc
	ret
	
cls_pic
			ld hl,#4000
			ld de,#4001
			ld bc,6144
			ld (hl),0
			ldir
			ld (hl),col_fon*7+col_fnt
			ld bc,768-1	
			ldir
			ld a,col_fon
			out (#fe),a
			ret
	
toDecimal		;конвертирует 2 байта в 5 десятичных цифр
				;на входе в HL число
			ld de,10000 ;десятки тысяч
			ld a,255
toDecimal10k			
			and a
			sbc hl,de
			inc a
			jr nc,toDecimal10k
			add hl,de
			add a,48
			ld (decimalS),a
			ld de,1000 ;тысячи
			ld a,255
toDecimal1k			
			and a
			sbc hl,de
			inc a
			jr nc,toDecimal1k
			add hl,de
			add a,48
			ld (decimalS+1),a
			ld de,100 ;сотни
			ld a,255
toDecimal01k			
			and a
			sbc hl,de
			inc a
			jr nc,toDecimal01k
			add hl,de
			add a,48
			ld (decimalS+2),a
			ld de,10 ;десятки
			ld a,255
toDecimal001k			
			and a
			sbc hl,de
			inc a
			jr nc,toDecimal001k
			add hl,de
			add a,48
			ld (decimalS+3),a
			ld de,1 ;единицы
			ld a,255
toDecimal0001k			
			and a
			sbc hl,de
			inc a
			jr nc,toDecimal0001k
			add hl,de
			add a,48
			ld (decimalS+4),a		
			ret
decimalS	ds 5 ;десятичные цифры	

; ; DE - trk/sec
; ; B - sectors step
; ; Returns:
; ; DE - trk/sec	
; calc_next_pos		;вперёд на N секторов	
			; ;ld b,4 
			; ;ld  de,(#5ceb) 
; calc_next_pos2		
			; inc e
			; ld a,e
			; cp 16
			; jr c,calc_next_pos1
			; inc d
			; ld e,0
; calc_next_pos1
			; ;ld (#5ceb),de
			; djnz calc_next_pos2
			; ret
cls_buf	
	ld hl,hstbuf
	ld de,hstbuf+1
	ld (hl),0
	ld bc,16384-1
	ldir
	ret
	
	
mes_title 	db #16,0,0,#10,col_fnt,#11,col_fon,"CP/M v2.2 for Scorpion ZS",13,13
	db "Install to SMUC HDD:",13
	db "1. Install system",13
	db "2. Backup data to FDD",13
	db "3. Restore data from FDD",13,255
mes_quest 	db #16,8,0,#10,col_fnt,#11,col_fon,"Are you sure (Y/N)?",255
mes_error 	db #16,20,0,#10,col_fnt,#11,col_fon_err,"Partition "
hdd_smuc_part db "D:\CPMZS0 " ;имя раздела 
	db "not mounted.",255
mes_err_hdd 	db #16,20,0,#10,col_fnt,#11,col_fon_err,"HDD error.",255
mes_err_fdd 	db #16,20,0,#10,col_fnt,#11,col_fon_err,"FDD error.",255
mes_progr 	db #16,10,0,#10,col_fnt,#11,col_fon,"Progress: "
progr1		db "00000/"
progr2		db "00000",255
mes_choice 	db #16,0,0,#10,col_fnt,#11,col_fon_err
choice		db "0",255
back_name	db "BACKUP0 C"
cur_trk_fdd	dw 0
cur_trk_hdd	dw 0
cycl		dw 0
mes_ok 	db #16,15,0,#10,col_fnt,#11,col_fon,"OK. Press a key.",255
name_1	db "BOOTSEC C",13,255
name_2	db "BIOS    C",13,255
name_3	db "DRV     C",13,255
name_4	db "FONT    C",13,255
cur_drive db 0
temp_hl dw 0
temp_de dw 0
temp_bc dw 0
temp_af dw 0
	
end_inst




	org #8000
start_boots ;загрузочный сектор
	jr start_boots_
	db "CP/M-ZS boot sector"
start_boots_	
	;подключение раздела
	ld a,010h ;переменная
	ld (05b5ch),a
	ld a,00bh ;%00001011 раздел монтируется по имени в DE
	ld de,hdd_smuc_part_b
	ld bc,00023h ;функция подключить раздел С=35
	rst 8
	db 081h
	jr c,dskerr_b ;выход с ошибкой

	ld a,17
	ld bc,#7ffd
	out (c),a
	ld de,1+32 ;адрес сектора ;BIOS
	ld hl,61440 ;адрес куда читать
	ld bc,00824h ;читать #08 секторов
	rst 8
	db 081h
	jp c,dskerr_hdd_b ;выход с ошибкой	
	
	ld a,22
	ld bc,#7ffd
	out (c),a
	ld de,1+32+32 ;адрес сектора ;DRV
	ld hl,49152 ;адрес куда читать
	ld bc,02024h ;читать #20 секторов
	rst 8
	db 081h
	jp c,dskerr_hdd_b ;выход с ошибкой	
	
	ld a,23
	ld bc,#7ffd
	out (c),a
	ld de,1+32+32+32 ;адрес сектора ;FONT
	ld hl,56064 ;адрес куда читать
	ld bc,01324h ;читать #13 секторов
	rst 8
	db 081h
	jp c,dskerr_hdd_b ;выход с ошибкой	
	
	ld a,17
	ld bc,#7ffd
	out (c),a
	jp 61440 ;старт CP/M
	
dskerr_hdd_b
	ld hl,mes_error_b2
	call print_mes_b
	ret	
dskerr_b
	ld hl,mes_error_b
	call print_mes_b
	ret

print_mes_b ; печать строки до цифры 255. В hl адрес строки
	push bc
	ld b,0 ;не больше 256
print_mes_b1
	ld a,(hl)
	cp 255
	jr z,print_mes_b_e
	rst 16
	inc hl
	djnz print_mes_b1
print_mes_b_e
	pop bc
	ret	
mes_error_b 	db "Partition "
hdd_smuc_part_b db "D:\CPMZS0 " ;имя раздела 
	db "not mounted.",255 
mes_error_b2 	db "Read HDD error",255

end_boots