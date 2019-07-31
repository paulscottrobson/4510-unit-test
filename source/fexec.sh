sh prelim.sh
64tass -q --m4510 -D TARGET=1 -b unittest.asm  -L rom.lst -o rom.bin
if [ $? -eq 0 ]
then
	../../mega65-core/src/tools/monitor_load -b nexys4ddr.bit -R rom.bin -k HICKUP.M65 -p
fi
