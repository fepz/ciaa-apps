# FreeRTOS library Makefile

GCC_BIN ?= $(GCC_BIN_PATH)
PROJECT = libfreertos

OBJECTS += ./$(FREERTOS_KERNEL_VERSION_NUMBER)/tasks.o
OBJECTS += ./$(FREERTOS_KERNEL_VERSION_NUMBER)/queue.o 
OBJECTS += ./$(FREERTOS_KERNEL_VERSION_NUMBER)/list.o 
OBJECTS += ./$(FREERTOS_KERNEL_VERSION_NUMBER)/portable/MemMang/heap_1.o 
OBJECTS += ./$(FREERTOS_KERNEL_VERSION_NUMBER)/portable/GCC/ARM_CM4F/port.o

INCLUDE_PATHS += -I./$(FREERTOS_KERNEL_VERSION_NUMBER)/include
INCLUDE_PATHS += -I./$(FREERTOS_KERNEL_VERSION_NUMBER)/portable/GCC/ARM_CM4F
INCLUDE_PATHS += -I../../$(APP_DIR)/inc

############################################################################### 
AR = $(GCC_BIN)arm-none-eabi-ar
CC = $(GCC_BIN)arm-none-eabi-gcc

INCLUDE_PATHS += $(foreach m, $(MODULES), -I../../$(m)/inc)
INCLUDE_PATHS += -I../lpc_chip_43xx/inc/usbd/

CC_FLAGS += $(CFLAGS)
CC_FLAGS += -c -fmessage-length=0 -fno-exceptions -ffunction-sections -fdata-sections -fno-builtin -Wall
CC_FLAGS += -MMD -MP

AR_FLAGS = -r

all: $(PROJECT).a

clean:
	+@echo "Cleaning FreeRTOS object files..."
	@rm -f $(PROJECT).bin $(PROJECT).a $(OBJECTS) $(DEPS)	

.c.o:
	+@echo "Compile: $<"
	@$(CC) $(CC_FLAGS) $(INCLUDE_PATHS) -o $@ $<

$(PROJECT).a: $(OBJECTS)
	+@echo "Linking: $@"
	@$(AR) $(AR_FLAGS) $@ $^ -c

DEPS = $(OBJECTS:.o=.d) $(SYS_OBJECTS:.o=.d)
-include $(DEPS)
