; bootloader.asm
org 0x7C00              ; Стартовый адрес загрузчика
bits 16

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    sti

    call clear_screen
    call show_prompt

main_loop:
    call read_line
    cmp byte [input], 'h'      ; check if command starts with 'h'
    je .check_help
    cmp byte [input], 'a'
    je .check_about
    jmp .unknown

.check_help:
    mov si, input
    cmp byte [si+1], 'e'
    jne .unknown
    cmp byte [si+2], 'l'
    jne .unknown
    cmp byte [si+3], 'p'
    jne .unknown
    mov si, msg_help
    call print
    jmp after

.check_about:
    mov si, input
    cmp byte [si+1], 'b'
    jne .unknown
    cmp byte [si+2], 'o'
    jne .unknown
    cmp byte [si+3], 'u'
    jne .unknown
    cmp byte [si+4], 't'
    jne .unknown
    mov si, msg_about
    call print
    jmp after

.unknown:
    mov si, msg_unknown
    call print

after:
    call show_prompt
    jmp main_loop

; ========== Subroutines ==========

print:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print
.done:
    ret

read_line:
    mov di, input
.next_char:
    mov ah, 0
    int 0x16
    cmp al, 13         ; Enter
    je .done
    cmp al, 8          ; Backspace
    je .backspace
    mov ah, 0x0E
    int 0x10
    stosb
    jmp .next_char
.backspace:
    cmp di, input
    je .next_char
    dec di
    mov ah, 0x0E
    mov al, 8
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 8
    int 0x10
    jmp .next_char
.done:
    mov al, 0
    stosb
    ret

clear_screen:
    mov ax, 0x0600
    mov bh, 0x07
    mov cx, 0x0000
    mov dx, 0x184F
    int 0x10
    mov ah, 2
    mov bh, 0
    mov dx, 0
    int 0x10
    ret

show_prompt:
    mov si, msg_prompt
    call print
    ret

; ========== Data ==========

msg_prompt:     db 0x0D, 0x0A, '>', 0
msg_help:       db 0x0D, 0x0A, 'Available commands: help, about', 0
msg_about:      db 0x0D, 0x0A, 'Lunarch OS - 1.0 (c) 2025', 0
msg_unknown:    db 0x0D, 0x0A, 'Unknown command.', 0
input:          times 64 db 0

times 510-($-$$) db 0
dw 0xAA55
