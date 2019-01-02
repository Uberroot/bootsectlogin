as -o "boot sector.o" "boot sector.s"
objcopy -O binary "boot sector.o" "boot sector.tmp"
del "boot sector.o"
stripleading "boot sector.tmp" "boot sector.bin" 31744
del "boot sector.tmp"
makeimg "boot sector.s.img" 1474560 "boot sector.bin"
echo del "boot sector.bin"