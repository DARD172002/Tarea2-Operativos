; My Name Game
ORG 0x7E00                 ; Address where the game is loaded
BITS 16                    ; 16-bit code

section .data 
    welcome_msg db 'Bienvenido al juego! Presiona Enter para empezar...', 0
    ;name db 'DanielP', 0  ; Name to display
    name db '***     *   *   * ***** ***** *\n*  *   * *  **  *   *   *     *\n*   * *   * * * *   *   ***   *\n*  *  ***** *  **   *   *     *\n***   *   * *   * ***** ***** *****\n***** ****  ***** *   * *****\n  *   *   * *     **  * *\n  *   ****  ***   * * * ***\n  *   *  *  *     *  ** *\n***** *   * ***** *   * *****' ;names up
    ;name_length db $ - name   ; Length of the name
    name_length db $ - name   ; Length of the name1 - names up

section .text 

start:
    cli
    ; Initialize screen
    mov ax, 0x03             ; Text mode 80x25
    int 0x10

    ; Show the start screen
    call show_welcome
    call wait_for_enter

    ; Show the name in an initial position
    call show_name_random

    ; Wait for a key press
wait_key:
    ; Wait for a key press
    mov ah, 0x00
    int 0x16                   ; Keyboard interrupt
    jmp wait_key               ; Loop to wait for the key press

display_name:
    ; Clear the screen before showing the name
    mov ax, 0x03             ; Text mode 80x25
    int 0x10

    ; Show the name at the new position
    call show_name
    jmp wait_key

show_welcome:
    ; Show the welcome message
    mov si, welcome_msg
    mov dx, 10                 ; Row (example)
    mov cx, 0                  ; Column (example)

    mov ah, 0x02               ; Function to move cursor
    int 0x10                   ; Move cursor

    mov ah, 0x0E               ; Function to write a character
.show_welcome_loop:
    lodsb                      ; Load next byte of the message
    cmp al, 0                  ; End of string
    je .done_welcome
    int 0x10                   ; Write character to screen
    jmp .show_welcome_loop
.done_welcome:
    ret

wait_for_enter:
    ; Wait for Enter key
    mov ah, 0x00
    int 0x16                   ; Keyboard interrupt
    cmp al, 0x0D               ; Enter key
    jne wait_for_enter
    ret

show_name_random:
    ; Generate a random position for the name
    call generate_random_position

    ; Move cursor to the random position
    mov ah, 0x02               ; Function to move cursor
    mov bh, 0                  ; Page (0)
    mov dh, [random_row]       ; Row from random position
    mov dl, [random_col]       ; Column from random position
    int 0x10                   ; Move cursor

    ; Display the name at the new position
    call show_name

    ; Wait for a key press
wait_key_random:
    ; Wait for a key press
    mov ah, 0x00
    int 0x16                   ; Keyboard interrupt
    jmp wait_key_random        ; Loop to wait for the key press

generate_random_position:
    ; Get the system time for randomness
    mov ah, 0x00
    int 0x1A                  ; Interrupt to get system time
    ; Use the value in DX as a seed for randomness
    mov ax, dx                ; Use DX (part of the system time) as seed
    xor dx, dx
    mov cx, 25                ; Maximum row number + 1

    ; Generate a random row (0-24)
    div cx                     ; AX / 25 -> AX = quotient, DX = remainder
    mov [random_row], dl       ; Store remainder as random row

    mov ax, dx                ; Use remaining DX value as seed for column
    mov cx, 80                 ; Maximum column number + 1

    ; Generate a random column (0-79)
    div cx                     ; AX / 80 -> AX = quotient, DX = remainder
    mov [random_col], dl       ; Store remainder as random column

    ret

show_name:
    ; Display the name at the current cursor position
    mov si, name               ; Address of the name
    mov ah, 0x0E               ; Function to write a character
.show_loop:
    lodsb                      ; Load next byte of the name
    cmp al, 0                  ; End of string
    je .done
    int 0x10                   ; Write character to screen
    jmp .show_loop
.done:
    ret

section .bss
    ; Variables to store random values for cursor position
    random_row db 0
    random_col db 0

times 510 - ($ - $$) db 0
dw 0xAA55                     ; Boot signature
