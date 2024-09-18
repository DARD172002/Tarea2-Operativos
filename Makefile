#variables


ASM=nasm

# carpeta de archivos fuente
SRC_DIR=src
# carpeta de archivos generados
BUILD_DIR=build

# archivos de entrada
BOOTLOADER_SRC=$(SRC_DIR)/bootloader.asm
myname_SRC=$(SRC_DIR)/myname.asm

# archivos de salida en la carpeta build
BOOTLOADER_BIN=$(BUILD_DIR)/bootloader.bin
myname_BIN=$(BUILD_DIR)/myname.bin
BOOTLOADER_IMG=$(BUILD_DIR)/bootloader.img
BINARY_IMG=$(BUILD_DIR)/BinarioImg.txt

# unir los binarios del bootloader y el juego en una imagen para escribirlo en el USB
$(BOOTLOADER_IMG): $(BOOTLOADER_BIN) $(myname_BIN)
	cat $(BOOTLOADER_BIN) $(myname_BIN) > $(BOOTLOADER_IMG)
	truncate -s 1440k $(BOOTLOADER_IMG)

# crear el binario del bootloader
$(BOOTLOADER_BIN): $(BOOTLOADER_SRC)
	$(ASM) $(BOOTLOADER_SRC) -f bin -o $(BOOTLOADER_BIN)

# crear el binario del juego
$(myname_BIN): $(myname_SRC)
	$(ASM) $(myname_SRC) -f bin -o $(myname_BIN)

# crear archivo para visualizar lo que se escribe en memoria
$(BINARY_IMG): $(BOOTLOADER_IMG)
	xxd $(BOOTLOADER_IMG) > $(BINARY_IMG)

# ejecutar juego
run:
	qemu-system-i386 -hda $(BOOTLOADER_IMG)

# limpiar el directorio build
clean:
	rm -rf $(BUILD_DIR)