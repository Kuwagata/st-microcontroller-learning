PROJ_NAME=main
OPENOCD_CFG = /usr/share/openocd/scripts/board/stm32f4discovery.cfg

############################################
################# Folders ##################
############################################

# Github project directory
TOP = ../../..

# Local folders
BIN_FOLDER = bin
INC_FOLDER = inc
LIB_FOLDER = lib
OBJ_FOLDER = obj
SRC_FOLDER = src

# Drivers
CMSIS_FOLDER = $(TOP)/drivers/CMSIS
HAL_FOLDER   = $(TOP)/drivers/STM32F4xx_HAL_Driver
# BSP_FOLDER   = $(TOP)/drivers/BSP

LDSCRIPT_FOLDER = $(TOP)/linker_scripts

############################################
################# Commands #################
############################################

CC      = @arm-none-eabi-gcc
OBJCOPY = @arm-none-eabi-objcopy
OBJDUMP = @arm-none-eabi-objdump
SIZE    = @arm-none-eabi-size
GDB     = arm-none-eabi-gdb
RM      = @rm
MKDIR   = @mkdir
ECHO    = @echo

############################################
################## Files ###################
############################################

SRC_FILES_RAW = $(wildcard $(SRC_FOLDER)/*.c)
SRC_FILES     = $(filter-out $(SRC_FOLDER)/stm32f4xx_hal_msp.c, $(SRC_FILES_RAW))

OBJ_FILES = $(patsubst $(SRC_FOLDER)/%.c, $(OBJ_FOLDER)/%.o, $(SRC_FILES))

STARTUP_SRC = $(TOP)/drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/gcc/startup_stm32f401xc.s
STARTUP_OBJ = $(OBJ_FOLDER)/startup_stm32f401xc.o

############################################
########### Compilation Options ############
############################################

CFLAGS  = -g -ggdb -O0 -Wall -Wextra -Warray-bounds
CFLAGS += -mcpu=cortex-m4 -mthumb -mlittle-endian -mthumb-interwork
CFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
CFLAGS += -DUSE_STDPERIPH_DRIVER -DSTM32F4XX -DSTM32F401xC
CFLAGS += -ffunction-sections -fdata-sections

LDFLAGS  = -ggdb -O0 -Wall -Wextra -Warray-bounds
LDFLAGS += -mcpu=cortex-m4 -mthumb -mlittle-endian -mthumb-interwork
LDFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
LDFLAGS += -DUSE_STDPERIPH_DRIVER -DSTM32F4XX -DSTM32F401xC
LDFLAGS += -ffunction-sections -fdata-sections
LDFLAGS += -Wl,--gc-sections -Wl,-Map=$(BIN_FOLDER)/$(PROJ_NAME).map

INC  = -I$(CMSIS_FOLDER)/Include
INC += -I$(CMSIS_FOLDER)/Device/ST/STM32F4xx/Include
INC += -I$(HAL_FOLDER)/Inc
INC += -I$(INC_FOLDER)

############################################
################## Rules ###################
############################################

.PHONY: lib proj clean

all: lib proj

$(BIN_FOLDER):
	$(MKDIR) -p $@

$(OBJ_FOLDER):
	$(MKDIR) -p $@

lib:
	$(MAKE) -f stmf4lib.makefile

proj: $(PROJ_NAME).elf

$(OBJ_FOLDER)/%.o: $(SRC_FOLDER)/%.c | $(OBJ_FOLDER)
	$(ECHO) "CC $^ > $@"
	$(CC) $(CFLAGS) $(INC) $^ -c -o $@

$(STARTUP_OBJ): $(STARTUP_SRC) | $(OBJ_FOLDER)
	$(ECHO) "CC $^ > $@"
	$(CC) $(CFLAGS) $(INC) $^ -c -o $@

$(PROJ_NAME).elf: $(OBJ_FILES) $(STARTUP_OBJ) | $(BIN_FOLDER)
	$(ECHO) "LD $^ > $@"
	$(CC) $(LDFLAGS) $^ -o $(BIN_FOLDER)/$@ -L$(LIB_FOLDER) -lstmf4 -L$(LDSCRIPT_FOLDER) -TSTM32F401CC_FLASH.ld
	$(OBJCOPY) -O ihex $(BIN_FOLDER)/$(PROJ_NAME).elf $(BIN_FOLDER)/$(PROJ_NAME).hex
	$(OBJCOPY) -O binary $(BIN_FOLDER)/$(PROJ_NAME).elf $(BIN_FOLDER)/$(PROJ_NAME).bin
	$(OBJDUMP) -St $(BIN_FOLDER)/$(PROJ_NAME).elf > $(BIN_FOLDER)/$(PROJ_NAME).lst
	$(SIZE) $(BIN_FOLDER)/$(PROJ_NAME).elf

flash: $(PROJ_NAME).elf
	$(ECHO) "Flashing"
	openocd -f $(OPENOCD_CFG) -c "program $(BIN_FOLDER)/$< verify reset"

binflash: $(PROJ_NAME).bin
	$(ECHO) "Flashing"
	openocd -f $(OPENOCD_CFG) -c "program $(BIN_FOLDER)/$< verify reset 0x08000000"

# Connects to the controller
openocd:
	openocd -f $(OPENOCD_CFG)

# Runs a gdb server -- first run "make openocd" in a separate window
gdb: $(PROJ_NAME).elf
	$(GDB) -tui --eval-command="target remote localhost:3333" $(BIN_FOLDER)/$<

clean:
	$(MAKE) -f stmf4lib.makefile clean
	$(RM) -rf $(BIN_FOLDER)
