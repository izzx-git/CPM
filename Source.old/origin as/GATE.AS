

        extrn biobnk

        .phase 0ffefh

        .z80

stack:  dw gate

gate:   ld bc,7ffdh
        ld d,biobnk
        out (c),d
;
        ld sp,stack
        jp (hl)

        .dephase

