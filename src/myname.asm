; My Name Game
ORG 0x7E00                 ; Dirección donde se carga el juego
BITS 16                    ; Código de 16 bits

section .data
    welcome_msg db 'Bienvenido al juego! Presiona Enter para empezar...', 0
    name db 'Daniel', 0  ; Nombre a mostrar
    name_length db $ - name     ; Longitud del nombre
    cursor_x db 40              ; Posición inicial en X (columna)
    cursor_y db 12              ; Posición inicial en Y (fila)

section .text 


start:
    cli
    ; Inicializa la pantalla
    mov ax, 0x0003             ; Modo de texto 80x25
    int 0x10

    ; Muestra la pantalla de inicio
    call show_welcome
    call wait_for_enter

    ; Muestra el nombre en una posición inicial
    call show_name



    

    ; Espera a que se presione una tecla
wait_key:
    ; Espera a que se presione una tecla
    mov ah, 0x00
    int 0x16                   ; Leer teclado
   ret 





display_name:
    ; Limpia la pantalla antes de mostrar el nombre
    mov ax, 0x0003             ; Modo de texto 80x25
    int 0x10

    ; Muestra el nombre en la nueva posición
    call show_name
    jmp wait_key

show_welcome:
    ; Muestra el mensaje de bienvenida
    mov si, welcome_msg
    mov dx, 10                 ; Fila (ejemplo)
    mov bx, 40                 ; Columna (ejemplo)

    mov ah, 0x0E               ; Función para escribir un carácter
.show_welcome_loop:
    lodsb                      ; Carga el siguiente byte del mensaje
    cmp al, 0                  ; Fin de cadena
    je .done_welcome
    int 0x10                   ; Escribe el carácter en pantalla
    jmp .show_welcome_loop
.done_welcome:
    ret

wait_for_enter:
    ; Espera a que se presione Enter
    mov ah, 0x00
    int 0x16                   ; Leer teclado
    cmp al, 0x0D               ; Enter
    jne wait_for_enter
    ret

show_name:
    ; Mueve el cursor a la posición
    mov ah, 0x02               ; Función para mover el cursor
    mov bh, 0                  ; Página (0)
    mov dx, [cursor_y]         ; Fila (Y)
    mov cx, [cursor_x]         ; Columna (X)
    int 0x10                   ; Mueve el cursor

    ; Muestra el nombre
    mov si, name               ; Dirección del nombre
    mov ah, 0x0E               ; Función para escribir un carácter
.show_loop:
    lodsb                      ; Carga el siguiente byte del nombre
    cmp al, 0                  ; Fin de cadena
    je .done
    int 0x10                   ; Escribe el carácter en pantalla
    jmp .show_loop
.done:
    ret

times 510 - ($ - $$) db 0
dw 0xAA55                     ; Firma de arranque
