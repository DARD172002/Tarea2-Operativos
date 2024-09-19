ORG 0x7E00                 ; Dirección donde se carga el juego
BITS 16                    ; Código de 16 bits

section .data
    welcome_msg db 'Bienvenido al juego! Presiona Enter para empezar...', 0
    name db 'D', 'a', 'n', 'i', 'e', 'l', 0  ; Nombre a mostrar
    name_length db $ - name                  ; Longitud del nombre

section .bss
    current_row resb 1      ; Variable para guardar la fila actual del cursor (no inicializada)
    current_col resb 1      ; Variable para guardar la columna actual del cursor (no inicializada)
    random_row resb 1       ; Variable para la fila aleatoria
    random_col resb 1       ; Variable para la columna aleatoria

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
    cmp ah, 0x4D               ; Verifica si se presionó la tecla 'a'
    je show_name_vertical       ; Si es 'a', muestra el nombre vertical
    cmp ah, 0x4B               ; Verifica si se presionó la tecla 'b'
    je show_name_vertical_up    ; Si es 'b', muestra el nombre vertical hacia arriba
    cmp ah, 0x13
   
    je reset_game
    jmp wait_key               ; De lo contrario, sigue esperando

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

show_welcome:
    ; Muestra el mensaje de bienvenida
    mov si, welcome_msg
    mov ah, 0x02               ; Función para mover el cursor
    mov bh, 0                  ; Página (0)
    mov dh, 0                 ; Fila fija para el mensaje de bienvenida
    mov dl, 0                  ; Columna fija para el mensaje de bienvenida
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
    mov dh, [random_row]        ; Fila de la posición aleatoria
    mov dl, [random_col]        ; Columna de la posición aleatoria
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
    mov cx, 20                ; Máximo número de filas + 1

    ; Genera una fila aleatoria (0-24)
    div cx                     ; AX / 25 -> AX = cociente, DX = residuo
    mov [random_row], dl       ; Guarda el residuo como fila aleatoria

    mov ax, dx                ; Usa el valor restante en DX como semilla para la columna
    mov cx, 70                 ; Máximo número de columnas + 1

    ; Genera una columna aleatoria (0-79)
    div cx                     ; AX / 80 -> AX = cociente, DX = residuo
    mov [random_col], dl       ; Guarda el residuo como columna aleatoria

    ret

show_name_vertical:
    ; Limpia la pantalla antes de mostrar el nombre vertical
    call clear_screen

    ; Obtiene las coordenadas actuales del cursor
    mov ah, 0x03               ; Función para obtener la posición del cursor
    mov bh, 0x00               ; Página 0
    int 0x10                   ; Interrupción 0x10, servicio 0x03
    ; DH tiene la fila actual
    ; DL tiene la columna actual

    ; Guarda las coordenadas actuales
    mov [current_row], dh
    mov [current_col], dl

    ; Muestra el nombre verticalmente a partir de las coordenadas actuales
    mov si, name
    mov ah, 0x0E               ; Función para escribir un carácter

print_char_vertical:
    lodsb                      ; Carga un byte del nombre en AL
    or al, al                  ; Comprueba si es el final del nombre
    jz done_vertical

    ; Verifica que la posición vertical esté dentro de los límites de la pantalla
    mov dh, [current_row]       ; Recupera la fila
    cmp dh, 25                  ; Verifica si está fuera del límite inferior
    jge done_vertical

    ; Mueve el cursor a la fila actual y la columna actual
    mov dl, [current_col]       ; Recupera la columna
    mov ah, 0x02               ; Función para mover el cursor
    int 0x10                   ; Mueve el cursor

    ; Escribe el carácter en la posición actual
    mov ah, 0x0E               ; Función para escribir el carácter
    int 0x10                   ; Escribe el carácter

    ; Incrementa la fila para la siguiente letra
    inc byte [current_row]      ; Mueve una fila hacia abajo
    jmp print_char_vertical     ; Repite para el siguiente carácter

done_vertical:
    jmp wait_key               ; Vuelve a esperar otra tecla

show_name_vertical_up:
    ; Limpia la pantalla antes de mostrar el nombre vertical
    call clear_screen

    ; Obtiene las coordenadas actuales del cursor
    mov ah, 0x03               ; Función para obtener la posición del cursor
    mov bh, 0x00               ; Página 0
    int 0x10                   ; Interrupción 0x10, servicio 0x03
    ; DH tiene la fila actual
    ; DL tiene la columna actual

    ; Guarda las coordenadas actuales
    mov [current_row], dh
    mov [current_col], dl

    ; Muestra el nombre verticalmente hacia arriba a partir de las coordenadas actuales
    mov si, name
    mov ah, 0x0E               ; Función para escribir un carácter

print_char_vertical_up:
    lodsb                      ; Carga un byte del nombre en AL
    or al, al                  ; Comprueba si es el final del nombre
    jz done_vertical_up

    ; Verifica que la posición vertical esté dentro de los límites de la pantalla
    mov dh, [current_row]       ; Recupera la fila
    cmp dh, 0                   ; Verifica si está fuera del límite superior
    jle done_vertical_up

    ; Mueve el cursor a la fila actual y la columna actual
    mov dl, [current_col]       ; Recupera la columna
    mov ah, 0x02               ; Función para mover el cursor
    int 0x10                   ; Mueve el cursor

    ; Escribe el carácter en la posición actual
    mov ah, 0x0E               ; Función para escribir el carácter
    int 0x10                   ; Escribe el carácter

    ; Decrementa la fila para la siguiente letra
    dec byte [current_row]      ; Mueve una fila hacia arriba
    jmp print_char_vertical_up  ; Repite para el siguiente carácter

done_vertical_up:
    jmp wait_key               ; Vuelve a esperar otra tecla

reset_game:
    ; Limpia la pantalla
    call clear_screen

    ; Muestra el mensaje de bienvenida
    call show_welcome
    call wait_for_enter

    ; Muestra el nombre en una posición inicial aleatoria
    call show_name_random

    ; Regresa a esperar una tecla
    jmp wait_key

clear_screen:
    ; Limpia la pantalla
    mov ah, 0x06               ; Función para desplazar pantalla
    mov al, 0x00               ; Desplaza hacia arriba
    mov bh, 0x07               ; Atributo de fondo
    mov ch, 0x00               ; Fila superior
    mov cl, 0x00               ; Columna izquierda
    mov dh, 0x19               ; Fila inferior
    mov dl, 0x4F               ; Columna derecha
    int 0x10                   ; Interrupción 0x10
    ret
   

times 510 - ($ - $$) db 0  ; Rellena hasta el tamaño del sector
dw 0xAA55                  ; Firma del sector de arranque
