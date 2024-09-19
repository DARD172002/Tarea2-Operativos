ORG 0x7E00                 ; Dirección donde se carga el juego
BITS 16                    ; Código de 16 bits

section .data
    welcome_msg db 'Bienvenido al juego! Presiona Enter para empezar...', 0
    name db 'D', 'a', 'n', 'i', 'e', 'l', 0  ; Nombre a mostrar
    name_length db $ - name                  ; Longitud del nombre
    random_row db 0                          ; Fila aleatoria
    random_col db 0                          ; Columna aleatoria

section .text 

start:
    cli
    ; Inicializa la pantalla
    mov ax, 0x03             ; Modo texto 80x25
    int 0x10

    ; Muestra la pantalla de bienvenida
    call show_welcome
    call wait_for_enter

    ; Muestra el nombre en una posición inicial aleatoria
    call show_name_random

    ; Espera una tecla
wait_key:
    mov ah, 0x00
    int 0x16                   ; Interrupción de teclado
    cmp al, 'a'                ; Verifica si se presionó la tecla 'a'
    je show_name_vertical       ; Si es 'a', muestra el nombre vertical
    jmp wait_key               ; De lo contrario, sigue esperando

display_name:
    ; Limpia la pantalla antes de mostrar el nombre
    mov ax, 0x03             ; Modo texto 80x25
    int 0x10

    ; Muestra el nombre en la nueva posición
    call show_name
    jmp wait_key

show_welcome:
    ; Muestra el mensaje de bienvenida
    mov si, welcome_msg
    mov dx, 10                 ; Fila (ejemplo)
    mov cx, 0                  ; Columna (ejemplo)

    mov ah, 0x02               ; Función para mover el cursor
    int 0x10                   ; Mueve el cursor

    mov ah, 0x0E               ; Función para escribir un carácter
.show_welcome_loop:
    lodsb                      ; Carga el siguiente byte del mensaje
    cmp al, 0                  ; Fin de la cadena
    je .done_welcome
    int 0x10                   ; Escribe el carácter en pantalla
    jmp .show_welcome_loop
.done_welcome:
    ret

wait_for_enter:
    ; Espera a que se presione Enter
    mov ah, 0x00
    int 0x16                   ; Interrupción de teclado
    cmp al, 0x0D               ; Tecla Enter
    jne wait_for_enter
    ret

show_name_random:
    ; Genera una posición aleatoria para el nombre
    call generate_random_position

    ; Mueve el cursor a la posición aleatoria
    mov ah, 0x02               ; Función para mover el cursor
    mov bh, 0                  ; Página (0)
    mov dh, [random_row]       ; Fila de la posición aleatoria
    mov dl, [random_col]       ; Columna de la posición aleatoria
    int 0x10                   ; Mueve el cursor

    ; Muestra el nombre en la nueva posición
    call show_name
    ret

generate_random_position:
    ; Obtiene la hora del sistema para generar aleatoriedad
    mov ah, 0x00
    int 0x1A                  ; Interrupción para obtener la hora del sistema
    ; Usa el valor en DX como semilla para la aleatoriedad
    mov ax, dx                ; Usa DX (parte de la hora del sistema) como semilla
    xor dx, dx
    mov cx, 25                ; Máximo número de filas + 1

    ; Genera una fila aleatoria (0-24)
    div cx                     ; AX / 25 -> AX = cociente, DX = residuo
    mov [random_row], dl       ; Guarda el residuo como fila aleatoria

    mov ax, dx                ; Usa el valor restante en DX como semilla para la columna
    mov cx, 80                 ; Máximo número de columnas + 1

    ; Genera una columna aleatoria (0-79)
    div cx                     ; AX / 80 -> AX = cociente, DX = residuo
    mov [random_col], dl       ; Guarda el residuo como columna aleatoria

    ret

show_name:
    ; Muestra el nombre en la posición actual del cursor
    mov si, name               ; Dirección del nombre
    mov ah, 0x0E               ; Función para escribir un carácter
.show_loop:
    lodsb                      ; Carga el siguiente byte del nombre
    cmp al, 0                  ; Fin de la cadena
    je .done
    int 0x10                   ; Escribe el carácter en pantalla
    jmp .show_loop
.done:
    ret

show_name_vertical:
    ; Limpia la pantalla antes de mostrar el nombre vertical
    mov ax, 0x03             ; Modo texto 80x25
    int 0x10

    ; Establece la posición inicial del cursor (fila 0, columna 0)
    mov ah, 0x02
    mov bh, 0x00   ; Página 0
    mov dh, 0x00   ; Fila 0
    mov dl, 0x00   ; Columna 0
    int 0x10       ; Mueve el cursor

    ; Muestra el nombre verticalmente
    mov si, name

print_char:
    lodsb          ; Carga un byte del nombre en AL
    or al, al      ; Comprueba si AL es 0 (fin del nombre)
    jz done_vertical
    mov ah, 0x0E   ; Función para mostrar un carácter en modo texto
    mov bh, 0x00   ; Página 0
    mov bl, 0x07   ; Color del texto (blanco sobre negro)
    int 0x10       ; Interrupción para mostrar el carácter

    ; Mueve el cursor hacia abajo (una línea)
    mov ah, 0x02
    mov bh, 0x00   ; Página 0
    mov dl, 0x00   ; Columna 0
    inc dh         ; Incrementa la fila
    int 0x10       ; Mueve el cursor
    jmp print_char ; Repite para el siguiente carácter

done_vertical:
    jmp wait_key   ; Vuelve a esperar otra tecla



times 510 - ($ - $$) db 0
dw 0xAA55                     ; Firma de arranque
