# Stack-Zero

The first challenge of the Phoenix machine covers a simple buffer overflow vulnerability present in the `gets()` C library function. Below is the main function of stack-zero disassembled in gdb:

```objdump
0x00000000004006c4 <+0>:     stp     x29, x30, [sp, #-112]!
0x00000000004006c8 <+4>:     mov     x29, sp
0x00000000004006cc <+8>:     str     w0, [x29, #28]
0x00000000004006d0 <+12>:    str     x1, [x29, #16]
0x00000000004006d4 <+16>:    adrp    x0, 0x400000
0x00000000004006d8 <+20>:    add     x0, x0, #0x760
0x00000000004006dc <+24>:    bl      0x400540 <puts@plt>
0x00000000004006e0 <+28>:    str     wzr, [x29, #104]
0x00000000004006e4 <+32>:    add     x0, x29, #0x28
0x00000000004006e8 <+36>:    bl      0x400530 <gets@plt>
0x00000000004006ec <+40>:    ldr     w0, [x29, #104]
0x00000000004006f0 <+44>:    cmp     w0, #0x0
0x00000000004006f4 <+48>:    b.eq    0x400708 <main+68>  // b.none
0x00000000004006f8 <+52>:    adrp    x0, 0x400000
0x00000000004006fc <+56>:    add     x0, x0, #0x7b0
0x0000000000400700 <+60>:    bl      0x400540 <puts@plt>
0x0000000000400704 <+64>:    b       0x400714 <main+80>
0x0000000000400708 <+68>:    adrp    x0, 0x400000
0x000000000040070c <+72>:    add     x0, x0, #0x7e8
0x0000000000400710 <+76>:    bl      0x400540 <puts@plt>
0x0000000000400714 <+80>:    mov     w0 #0x0                        // #0
0x0000000000400718 <+84>:    bl      0x400560 <exit@plt>
```
# The stp Instruction
```
stp     x29, x30, [sp, #-112]!
```
While not essential to solving this challenge, the `stp` instruction is an important one to understand. The instruciton stands for *[Store Pair of Registers](https://developer.arm.com/documentation/dui0801/g/A64-Data-Transfer-Instructions/STP)*. **The instruciton stores the values of two registers at a memory address calculated from a base register and a given offset.**  

In this case, `x29` and `x30` are the values to be stored. `sp` is the base register and `-112` is the offset.
Here is the C pseudo code for the `stp` instruction above:
```c
sp -= 112
*(sp) = x29
*(sp + 8) = x30
```
You'll see that the `sp` register itself is modified by the `stp` instruction. In our case it is modified before storing the values, this is due to the `!` in the instruciton. **The `!` signifies the instruction is *pre-index* otherwise it is *post-index.*** Here is an example of post-index:

``` 
stp     x5, x6, [sp, #-16]
```
```c
*(sp) = x5
*(sp+8) = x6
sp -= 16
```
Taking a quick look through the assembly code, `x30` is never mentioned again after the `stp` instruction. This seems like a waste of 8 bytes, which it is. **[ARM hardware requires that `sp` is always 16-byte aligned. This means we can only add and subtract from `sp` with multiples of 16.](https://www.amazon.com/Programming-64-Bit-ARM-Assembly-Language-ebook/dp/B0881Z2VJG)** This also means, if we stored only one value instead of two we would still waste 8 bytes.

Let's return to the challenge. We can see `gets()` is called on `+36`. Looking at the man page for `gets()` we see it takes one char pointer as input. **In 64-bit ARM assembly the first 8 parameters to a function will be passed by convention using registers `X0-X7`.** We can assume `X0` will be passed to `gets()`.

Indeed x0 is modifed in the instruction immediately before `gets()` is called:

```
add     x0, x29, #0x28
```
In Pseudo C: 
``` c
x0 = x29 + 40
```

We know from lines `+4` and `+0` that `x29` has stored the stack pointer from the beginning of `main()`:

```
stp     x29, x30, [sp, #-112]!
mov     x29, sp
```
In Pseudo C:
```c
sp -= 112
*(sp) = x29
*(sp + 8) = x30
x29 = sp
```

From the source code for this challenge we know the objective is to change the value of `locals.changeme`. Looking at the instructions after line `+36` we want to change the value of `x29+104`.

```   
ldr     w0, [x29, #104]
cmp     w0, #0x0
b.eq    0x400708 <main+68>  // b.none
```
In Pseudo C:
``` c
w0 = *(x29 + 104)
if (w0 == 0){
    go to main+68 // Taking this branch will successfully complete the challenge
}
```        
Considering `gets()` is called with `x29+40` and we want to change `x29+104`:

`104-40 = 64`

Therefore to change `x29+104` we need to enter 65 bytes of data to overflow the buffer and complete the challenge.
65 characters will do the trick.