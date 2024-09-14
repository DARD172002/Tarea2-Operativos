ORG 0x7c00                 ; Dirección de inicio del código
BITS 16                    ; Código de 16 bits
jmp short start            ; Salta al inicio del código

start:
    cli                     ; Limpia el flag de interrupción

    ; Inicializa los registros
    xor ax, ax              ; Limpia el registro ax
    mov ds, ax              ; Establece ds en 0
    mov es, ax              ; Establece es en 0
    mov ss, ax              ; Establece el segmento de la pila en 0
    mov fs, ax
    mov gs, ax
    mov sp, 0x6ef0          ; Establece el puntero de la pila
    sti                     ; Establece el flag de interrupción


    mov ah, 0               ; se resetea el modo del disco
    int 0x13                ; interrupcion para usar el disco con el BIOS

    ; leer del disco y escribir en ram
    mov bx, 0x7e00          ; direccion de memoria para leer
    mov al, 0x4             ; cantidad de sectores para lectura
    mov ch, 0               ; cilindro
    mov dh, 0               ; cabeza
    mov cl, 2               ; sector
    mov ah, 2               ; lee desde el disco
    int 0x13
    jmp 0x7e00
    
    jc disk_error           ; Salta si se establece el flag de carry (error)

    ; Salta a la aplicación cargada
    jmp 0x0000:0x7e00       ; Salta a la dirección donde se cargó la aplicación

disk_error:
    ; Maneja el error del disco (por simplicidad, detiene la CPU)
    hlt

; Define una firma para indicar un sector de arranque válido
times 510-($-$$) db 0
dw 0xAA55                  ; Firma de arranque