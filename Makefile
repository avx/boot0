# or hexdump -v -e '"BYTE(0x" 1/1 "%02X" ")\n"' stage2.img > stage2.ld

PROJECT   = boot0

DEFS      = -DSTM32F40_41xxx
OPTIMIZE  = -fpack-struct -Os
DEBUG     = -g3 -ggdb

##########################

PRE       = arm-none-eabi-
CC        = $(PRE)gcc
AS        = $(PRE)as
LD        = $(PRE)ld
OC        = $(PRE)objcopy
OD        = $(PRE)objdump
SIZE      = $(PRE)size

LDSCRIPT  = app/stm32f407vgt.ld

STARTUP   = app/startup_stm32f40xx.s

INCLUDES  = -I. -I./cmsis -I./app -I./lzma

CCFLAGS   = $(OPTIMIZE) -std=c99 -mlittle-endian -mcpu=cortex-m4 -mthumb -mlittle-endian -mthumb-interwork $(DEBUG) $(DEFS)
CCFLAGS  += -fdata-sections -ffunction-sections -fno-common -fno-builtin -nostdlib $(INCLUDES) 
ASFLAGS   = -mcpu=cortex-m4  -mthumb -mapcs-32 
LDFLAGS   = -T $(LDSCRIPT) -Map $(PROJECT).map -static --gc-sections -nostdlib

SRCS      = $(shell find app cmsis lzma -name '*.c' | sort)

OBJS      = $(addprefix .build/tmp/,$(SRCS:.c=.o))

STARTUP_O = $(addprefix .build/tmp/,$(STARTUP:.s=.o))

all:      stage2_img.h $(PROJECT).elf $(PROJECT).bin $(PROJECT).hex

.build/tmp/%.o: %.c
	@mkdir -p $(dir $@)
	@echo "compiling $<"
	@$(CC) $(CCFLAGS) $< -c -o $@

.build/tmp/%.o: %.s
	@mkdir -p $(dir $@)
	@echo "compiling $<"
	@$(CC) $(CCFLAGS) $< -c -o $@

stage2.img.lzma: stage2.img
	lzma -z -6 -e stage2.img -c > stage2.img.lzma

stage2_img.h: stage2.img.lzma
#	xxd -i stage2.img > stage2_img.h
	@echo "generating stage2_img.h"
	@echo "#define STAGE2_LZMA_IMAGE_LEN $(shell stat --printf "%s" stage2.img.lzma)\n" > stage2_img.h
	@cat stage2.img.lzma | ( echo "const unsigned char STAGE2_LZMA_IMAGE[] = {"; xxd -i; echo "};") >> stage2_img.h

$(PROJECT).elf: $(STARTUP_O) $(OBJS) $(LDSCRIPT) $(STAGE2_OBJ)
	@echo ""
	@echo "Linking $(PROJECT).elf..."
	$(LD) $(LDFLAGS) $(STARTUP_O) $(OBJS) -o $@
	$(OD) -St $@ > $(PROJECT).lst
	$(OD) -d $@ > $(PROJECT).dis
	@echo ""
	$(SIZE) $(PROJECT).elf
	@echo ""


$(PROJECT).bin: $(PROJECT).elf
	$(OC) -O binary $< $@

$(PROJECT).hex: $(PROJECT).elf
	$(OC) -O ihex $< $@

clean:
	@echo -n "Cleaning dir..."
	@find ./ -name '*~' | xargs rm -f
	@rm -rf ./.build
	@rm -rf stage2.img.lzma stage2_img.h
	@rm -f $(PROJECT).elf
	@rm -f $(PROJECT).hex
	@rm -f $(PROJECT).bin
	@rm -f $(PROJECT).map
	@rm -f $(PROJECT).lst
	@rm -f $(PROJECT).dis
	@echo "done"

flash:
	sudo ./tools/st-flash write $(PROJECT).bin 0x8000000

sflash:
	sudo ./tools/stm32flash -R -w $(PROJECT).bin /dev/ttyUSB0 -v -g 0x0

dfu:
	./tools/dfu-util -d 0483:df11 -a 0 -s 0x08000000 -D $(PROJECT).bin

dfu-reset:
	./tools/dfu-util -d 0483:df11 -a 0 --reset-stm32

.PHONY: all clean flash sflash dfu-dfu-reset
.DEFAULT:
.SUFFIXES:
