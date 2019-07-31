pushd ../6502system/emulator
sh build.sh
popd
64tass -q -c -D TARGET=2 -b unittest.asm  -L rom.lst -o rom.bin
if [ $? -eq 0 ]
then
	../6502system/emulator/em6502 rom.bin go
fi
