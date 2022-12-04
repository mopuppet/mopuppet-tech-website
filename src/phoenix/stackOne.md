# Stack-One

Stack-One is very similiar to Stack-Zero, only `strcopy()` is used instead of `gets()` and to exploit the buffer overflow vulnerability will need to change `locals.changme` to a specific value. Below is the main function of stack-one disassembled in gdb:

``` 
0x0000000000400794 <+0>:	stp	x29, x30, [sp, #-112]!
0x0000000000400798 <+4>:	mov	x29, sp
0x000000000040079c <+8>:	str	w0, [x29, #28]
0x00000000004007a0 <+12>:	str	x1, [x29, #16]
0x00000000004007a4 <+16>:	adrp	x0, 0x400000
0x00000000004007a8 <+20>:	add	x0, x0, #0x868
0x00000000004007ac <+24>:	bl	0x400600 <puts@plt>
0x00000000004007b0 <+28>:	ldr	w0, [x29, #28]
0x00000000004007b4 <+32>:	cmp	w0, #0x1
0x00000000004007b8 <+36>:	b.gt	0x4007d0 <main+60>
0x00000000004007bc <+40>:	adrp	x0, 0x400000
0x00000000004007c0 <+44>:	add	x0, x0, #0x8b8
0x00000000004007c4 <+48>:	mov	x1, x0
0x00000000004007c8 <+52>:	mov	w0, #0x1                   	// #1
0x00000000004007cc <+56>:	bl	0x400610 <errx@plt>
0x00000000004007d0 <+60>:	str	wzr, [x29, #104]
0x00000000004007d4 <+64>:	ldr	x0, [x29, #16]
0x00000000004007d8 <+68>:	add	x0, x0, #0x8
0x00000000004007dc <+72>:	ldr	x1, [x0]
0x00000000004007e0 <+76>:	add	x0, x29, #0x28
0x00000000004007e4 <+80>:	bl	0x4005e0 <strcpy@plt>
0x00000000004007e8 <+84>:	ldr	w1, [x29, #104]
0x00000000004007ec <+88>:	mov	w0, #0x5962                	// #22882
0x00000000004007f0 <+92>:	movk	w0, #0x496c, lsl #16
0x00000000004007f4 <+96>:	cmp	w1, w0
0x00000000004007f8 <+100>:	b.ne	0x40080c <main+120>  // b.any
0x00000000004007fc <+104>:	adrp	x0, 0x400000
0x0000000000400800 <+108>:	add	x0, x0, #0x8f0
0x0000000000400804 <+112>:	bl	0x400600 <puts@plt>
0x0000000000400808 <+116>:	b	0x40081c <main+136>
0x000000000040080c <+120>:	ldr	w1, [x29, #104]
0x0000000000400810 <+124>:	adrp	x0, 0x400000
0x0000000000400814 <+128>:	add	x0, x0, #0x938
0x0000000000400818 <+132>:	bl	0x4005f0 <printf@plt>
0x000000000040081c <+136>:	mov	w0, #0x0                   	// #0
0x0000000000400820 <+140>:	bl	0x400630 <exit@plt>
```

From the source code and the assembly we can see the buffer is the same size as the previous challenge. Except this time, the important instructions after `strcpy()` at `+80` are:

```
ldr	w1, [x29, #104]
mov	w0, #0x5962                	// #22882
movk	w0, #0x496c, lsl #16
cmp	w1, w0
b.ne	0x40080c <main+120>  // b.any
```

In Pseudo C:
```c
w1 = *(x29 + 104)
w0 = 0x5962 
w0 = 0x496c // this only effects the higher 16 bits of the registers due to the lsl #16
if (w1 != w0){
    go to main+120 // if this branch is taken, challenge is not sovled
}
```
Not the most gracious pseudo code, so let me explain what the `mov` and `movk` instructions are achieving here. All ARM64 instructions have a standard instruction length of 32 bits. Several things need to be encoded in each instruction such as opcodes, and which registers to operate on. This leaves less space for immediate values. Because of this ARM64 will use more than one instruction or shift operations to transfer larger data than one instruction can hold.

# The MOVK Instruction

MOVK stands for [Move wide with keep](https://developer.arm.com/documentation/ddi0602/2022-09/Base-Instructions/MOVK--Move-wide-with-keep-?lang=en). **MOVK moves a 16-bit imediate value into a register at a given left shift without changing the other bits in the register.** Lets take the above as an example:

```
mov	    w0, #0x5962                
```
| | 32-16 | 15-0 |
| :----:| :----: | :---: |
| w0| 0000 0000 0000 0000 | 0x5962 |

The mov instruction moves 0x5962 into w0 ands zeros all other bits in the register.

```
movk	w0, #0x496c, lsl #16               
```
| Bits| 32-16 | 15-0 |
| :----:| :----: | :---: |
| w0| 0x496c | 0x5962 |

The movk moves 0x496c into w0 except shifts the value 16 bits left, to store the value in the upper bits of w0. And unlike mov, movk does not effect any of the other bits in the register.
