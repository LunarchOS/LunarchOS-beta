org 0x7C00
bits 16

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    sti

    call clear_screen
    call show_logo
    call pause_moment
    call show_prompt

main_loop:
    call read_line
    cmp byte [input], 'h'
    je .check_help
    cmp byte [input], 'a'
    je .check_about
    cmp byte [input], 'c'
    je .check_cls
    cmp byte [input], 'q'
    je .check_quit
    jmp .unknown

.check_help:
    mov si, input
    cmp byte [si+1], 'e'
    jne .unknown
    cmp byte [si+2], 'l'
    jne .unknown
    cmp byte [si+3], 'p'
    jne .unknown
    cmp byte [si+4], 0
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
    cmp byte [si+5], 0
    jne .unknown
    mov si, msg_about
    call print
    jmp after

.check_cls:
    mov si, input
    cmp byte [si+1], 'l'
    jne .unknown
    cmp byte [si+2], 's'
    jne .unknown
    cmp byte [si+3], 0
    jne .unknown
    call clear_screen
    jmp after

.check_quit:
    mov si, input
    cmp byte [si+1], 'u'
    jne .unknown
    cmp byte [si+2], 'i'
    jne .unknown
    cmp byte [si+3], 't'
    jne .unknown
    cmp byte [si+4], 0
    jne .unknown
    call shutdown

.unknown:
    mov si, msg_unknown
    call print

after:
    call show_prompt
    jmp main_loop

; ===== Subroutines =====

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

show_logo:
    mov si, msg_line
    call print
    mov si, msg_welcome
    call print
    mov si, msg_lunarch
    call print
    mov si, msg_line
    call print
    ret

pause_moment:
    mov cx, 0xFFFF
.pause:
    loop .pause
    ret

show_prompt:
    mov si, msg_prompt
    call print
    ret

read_line:
    mov di, input
.next_char:
    mov ah, 0
    int 0x16
    cmp al, 13
    je .done
    cmp al, 8
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

print:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print
.done:
    ret

shutdown:
    mov ax, 0x5307
    mov bx, 0x0001
    mov cx, 0x0003
    int 0x15
    ; Если не сработало — просто остановим процессор
.halt:
    cli
    hlt
    jmp .halt

; ===== Messages and Data =====

msg_prompt:     db 0x0D, 0x0A, '>', 0
msg_help:       db 0x0D, 0x0A, 'Available commands: help, about, cls, quit', 0
msg_about:      db 0x0D, 0x0A, 'Lunarch OS v0.1 (c) 2025 - made by Lunarch Co.', 0
msg_unknown:    db 0x0D, 0x0A, 'Unknown command.', 0

msg_line:       db 0x0D, 0x0A, '-------------------------', 0
msg_welcome:    db 0x0D, 0x0A, '      Welcome to', 0
msg_lunarch:    db 0x0D, 0x0A, '    Lunarch', 0

input:          times 64 db 0

times 1024-2-($-$$) db 0  ; заполняем до 1022 байт
dw 0xAA55                 ; сигнатура bootloader в конце 1-го сектора
