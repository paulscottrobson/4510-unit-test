64tass -q --m4510 -D TARGET=1 -b unittest.asm  -L rom.lst -o rom.bin
if [ $? -eq 0 ]
then
../xmega65.native 1>/dev/null
fi
