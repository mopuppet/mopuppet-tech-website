.global _start

_start: 
   stp     x29, x30, [sp, #-112]!
   mov     x29, sp
   str     x19, [sp, #16]
   mov     x19, x30
   add     x0, x29, #0x28
   bl      0x400580 <gets@plt>
   str     x19, [x29, #104]
   adrp    x0, 0x400000
   add     x0, x0, #0x820
   ldr     x1, [x29, #104]
   bl      0x400570 <printf@plt>
   nop
   ldr     x19, [sp, #16]
   ldp     x29, x30, [sp], #112
   ret