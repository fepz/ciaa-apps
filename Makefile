#
# Modify example to build in Makefile.mine. 
#
-include Makefile.mine

APP_DIR = ./apps
BUILD_DIR = ./build
LIBS_DIR = ./libs

APP = $(APP_DIR)/$(APP_NAME)

TARGET=$(BUILD_DIR)/$(APP_NAME).elf

MAKE_FLAGS += --no-print-directory

MODULES += libs/lpc/lpc_chip_43xx
MODULES += libs/lpc/lpc_board_ciaa_edu_4337

DEFINES += CORE_M4
DEFINES += __USE_LPCOPEN

SRC += $(wildcard $(APP)/*/src/*.c)
SRC += $(wildcard $(APP)/src/*.c)

INCLUDES += $(foreach m, $(MODULES), -I$(m)/inc)
INCLUDES += -I$(LIBS_DIR)/lpc/lpc_chip_43xx/inc/usbd/ 
INCLUDES += $(foreach i, $(wildcard $(APP)/*/inc), -I$(i))
INCLUDES += $(foreach i, $(wildcard $(APP)/inc), -I$(i))

INCLUDE_PATHS += -I$(LIBS_DIR)/FreeRTOS/$(FREERTOS_KERNEL_VERSION_NUMBER)/include
INCLUDE_PATHS += -I$(LIBS_DIR)/FreeRTOS/$(FREERTOS_KERNEL_VERSION_NUMBER)/portable/GCC/ARM_CM4F
INCLUDE_PATHS += -I$(LIBS_DIR)/sAPI/$(SAPI_VERSION_NUMBER)/inc

INCLUDES += $(INCLUDE_PATHS)

_DEFINES=$(foreach m, $(DEFINES), -D$(m))

OBJECTS = $(SRC:.c=.o)
DEPS = $(SRC:.c=.d)

LDSCRIPT = ldscript/ciaa_lpc4337.ld

ARCH_FLAGS += -mcpu=cortex-m4 
ARCH_FLAGS += -mthumb
ARCH_FLAGS += -mfloat-abi=hard
ARCH_FLAGS += -mfpu=fpv4-sp-d16

CFLAGS += $(ARCH_FLAGS) 
CFLAGS += $(INCLUDES) 
CFLAGS += $(_DEFINES) 
CFLAGS += -ggdb3 
CFLAGS += -Og

LDFLAGS += $(ARCH_FLAGS)
LDFLAGS += -T$(LDSCRIPT)
LDFLAGS += -nostartfiles
LDFLAGS += -Wl,-gc-sections
LDFLAGS += $(foreach l, $(LIBS), -l$(l))

SAPI_DIR = $(LIBS_DIR)/sAPI
FREERTOS_DIR = $(LIBS_DIR)/FreeRTOS
LPC_DIR = $(LIBS_DIR)/lpc
LIBRARY_PATHS += -L$(FREERTOS_DIR)
LIBRARY_PATHS += -L$(LPC_DIR)
LIBRARY_PATHS += -L$(SAPI_DIR)
LIBRARIES += -lfreertos
LIBRARIES += -llpc
LIBRARIES += -lsapi

export CFLAGS MODULES FREERTOS_KERNEL_VERSION_NUMBER SAPI_VERSION_NUMBER

all: $(TARGET)

test_build_all:
	@rm logs/*.log
	@./logs/test_build_all.sh | tee logs/test_build_all.log

_:
	@echo $(CFLAGS)
	@echo $(LDFLAGS)

CROSS=arm-none-eabi-
CC=$(CROSS)gcc
LD=$(CROSS)gcc
SIZE=$(CROSS)size
OBJCOPY=$(CROSS)objcopy
LIST=$(CROSS)objdump -xCedlSwz
GDB=$(CROSS)gdb
OOCD=C:\\Users\\fep\\Documents\\bin\\openocd-0.10.0\\bin\\openocd

ifeq ("$(origin V)", "command line")
BUILD_VERBOSE=$(V)
endif
ifndef BUILD_VERBOSE
BUILD_VERBOSE = 0
endif
ifeq ($(BUILD_VERBOSE),0)
Q = @
else
Q =
endif

-include $(DEPS)

%.o: %.c
	+@echo "Compile: $<"
	$(Q)$(CC) -MMD $(CFLAGS) -c -o $@ $<

$(TARGET): $(OBJECTS)
	@$(MAKE) $(MAKE_FLAGS) -C ./libs/lpc/ -f Makefile.mk
	@$(MAKE) $(MAKE_FLAGS) -C ./libs/sAPI/ -f Makefile.mk
	@$(MAKE) $(MAKE_FLAGS) -C ./libs/FreeRTOS/ -f Makefile.mk APP_DIR=$(APP)
	@echo "LD $@"
	$(Q)$(LD) -o $@ $(OBJECTS) $(LDFLAGS) $(LIBRARIES) $(LIBRARY_PATHS)
	$(Q)$(OBJCOPY) -v -O binary $@ $(BUILD_DIR)/$(APP_NAME).bin
	$(Q)$(LIST) $@ > $(BUILD_DIR)/$(APP_NAME).lst
	$(Q)$(SIZE) $@

.PHONY: clean debug openocd

openocd:
	$(Q)$(OOCD) -f ciaa-nxp.cfg

debug: $(TARGET)
	$(Q)$(GDB) $< -ex "target remote :3333" -ex "mon reset halt" -ex "load" -ex "continue"

run: $(TARGET)
	$(Q)$(GDB) $< -batch -ex "target remote :3333" -ex "mon reset halt" -ex "load" -ex "mon reset run" -ex "quit"

download: $(TARGET)
	$(Q)$(OOCD) -f ciaa-nxp.cfg \
		-c "init" \
		-c "halt 0" \
		-c "flash write_image erase unlock build/$(APP_NAME).bin 0x1A000000 bin" \
		-c "reset run" \
		-c "shutdown"

erase:
	$(Q)$(OOCD) -f ciaa-nxp.cfg \
		-c "init" -c "halt 0" -c "flash erase_sector 0 0 last" -c "shutdown"

clean:
	@echo "Cleaning..."
	@$(MAKE) $(MAKE_FLAGS) -C ./libs/sAPI/ -f Makefile.mk clean
	@$(MAKE) $(MAKE_FLAGS) -C ./libs/lpc/ -f Makefile.mk clean
	@$(MAKE) $(MAKE_FLAGS) -C ./libs/FreeRTOS/ -f Makefile.mk clean
	$(Q)rm -fR $(OBJECTS) $(TARGET) $(DEPS) $(BUILD_DIR)/$(APP_NAME).lst $(BUILD_DIR)/$(APP_NAME).bin
