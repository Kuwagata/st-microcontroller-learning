############################################
################# Folders ##################
############################################

# Github project directory
TOP = ../../..

# Local folders
INC_FOLDER = inc
LIB_FOLDER = lib
OBJ_FOLDER = obj
SRC_FOLDER = src

# Drivers
CMSIS_FOLDER = $(TOP)/drivers/CMSIS
HAL_FOLDER   = $(TOP)/drivers/STM32F4xx_HAL_Driver
# BSP_FOLDER   = $(TOP)/drivers/BSP

############################################
################# Commands #################
############################################

CC    = @arm-none-eabi-gcc
AR    = @arm-none-eabi-ar
RM    = @rm
MKDIR = @mkdir
ECHO  = @echo

############################################
################## Files ###################
############################################

HAL_MSP_SRC       = $(SRC_FOLDER)/stm32f4xx_hal_msp.c
HAL_MSP_TEMPlATE  = $(HAL_FOLDER)/Src/stm32f4xx_hal_msp_template.c
HAL_SRC_FILES_RAW = $(wildcard $(HAL_FOLDER)/Src/*.c)
HAL_SRC_FILES     = $(filter-out $(HAL_MSP_TEMPlATE), $(HAL_SRC_FILES_RAW))

HAL_MSP_OBJ   = $(OBJ_FOLDER)/stm32f4xx_hal_msp.o
HAL_OBJ_FILES = $(patsubst $(HAL_FOLDER)/Src/%.c, $(OBJ_FOLDER)/%.o, $(HAL_SRC_FILES))

############################################
########### Compilation Options ############
############################################

CFLAGS  = -ggdb -O0 -Wall -Wextra -Warray-bounds
CFLAGS += -mcpu=cortex-m4 -mthumb -mlittle-endian -mthumb-interwork
CFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
CFLAGS += -DUSE_STDPERIPH_DRIVER -DSTM32F4XX -DSTM32F401xC

INC  = -I$(CMSIS_FOLDER)/Include
INC += -I$(CMSIS_FOLDER)/Device/ST/STM32F4xx/Include
INC += -I$(HAL_FOLDER)/Inc
INC += -I$(INC_FOLDER)

############################################
################## Rules ###################
############################################

.PHONY: libstmf4.a clean

all: libstmf4.a

$(LIB_FOLDER):
	$(MKDIR) -p $@

$(OBJ_FOLDER):
	$(MKDIR) -p $@

$(OBJ_FOLDER)/%.o : $(HAL_FOLDER)/Src/%.c | $(OBJ_FOLDER)
	$(ECHO) "CC $^ > $@"
	$(CC) $(CFLAGS) $(INC) -c -o $@ $^

$(HAL_MSP_OBJ) : $(HAL_MSP_SRC) | $(OBJ_FOLDER)
	$(ECHO) "CC $^ > $@"
	$(CC) $(CFLAGS) $(INC) -c -o $@ $^

libstmf4.a: $(HAL_MSP_OBJ) $(HAL_OBJ_FILES) | $(LIB_FOLDER)
	$(ECHO) "AR $^ > $@"
	$(AR) -r $(LIB_FOLDER)/$@ $(HAL_MSP_OBJ) $(HAL_OBJ_FILES)

clean:
	$(RM) -rf $(LIB_FOLDER)
	$(RM) -rf $(OBJ_FOLDER)
