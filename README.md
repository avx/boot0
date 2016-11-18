# Bootloader for STM32 with LZMA decompression into RAM

stage2.img is binary image which will be uncompressed into RAM. 

main.h defines the address where image will be uncompressed to (APP_START_ADDRESS).

stage2.img should be compiled with base APP_START_ADDRESS.

memory layout is defined in linker script.

itself bootloader has size about 4800 bytes.

# LZMA SDK from Igor Pavlov.

http://www.7-zip.org/sdk.html
