@echo off

set PAL=1

IF EXIST s1built.32x move /Y s1built.32x s1built.prev.32x >NUL
asmsh /k /p /o psh2,#+ /e PAL=%PAL% _32X/Program.asm,_32X/Program.bin, ,_32X/Program.lst
asm68k /k /p /o ae-,c+,op+,os+,ow+,oz+,oaq+,osq+,omq+ /e PAL=%PAL% sonic.asm, s1built.32x, , sonic.lst
pause
