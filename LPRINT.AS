
            public lpr       ; c=код для пpинтеpа
            public lprst     ; a=статус пpинтеpа, a=0 всё ок.    

            public lprbnk ; банка

lprbnk  equ CBANK

          .z80      

lpr:     ret

lprst:   xor a
            ret

