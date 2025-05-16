

;  publuc interface:   de=file handle for all functions
;
;     seek  : set r/w pointer de,hl=32 unsigned byte ptr
;             a=0 from start of file
;             a=1 from end of file
;             a=2 from current position, de,hl is signed !
;             ->  a=error code  cf=1 if error
;     getpos : de,hl=32 byte ptr of start of file.
;     read  : bc=bytes to read   ->  bc=bytes read  a=error code  cf=1 if error
;     write : bc=bytes to write  ->  a=error code  cf=1 if error occured
;


; Disk Parameters Block:
;
;   bytes per sector   : word
;   sectors in cluster : byte
;   reserved sectors   : word
;   copies of FAT      : byte
;   root dir. entries  : word
;   logic sectors      : word
;   byte ?             : byte
;   sectors for FAT    : word
;



; File Control Block:
;   first cluster in FAT    : word
;   current cluster in FAT  : word
;   seek pointer            : dword
;
;

       
;
; File functions:  seek, getpos, read, write
;
; DISK block control:  getblock, flush
;
;
;
;






