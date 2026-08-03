[BITS 16]
[ORG 0x7C00]

start:
    ; 1. Set up segment registers and stack safely
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    ; 2. Clear Screen & Set Background Color
    ; AH=06h (Scroll Up), AL=00h (Clear screen), BH=Color attribute (0x1F = Bright White on Blue)
    mov ah, 0x06
    mov al, 0x00
    mov bh, 0x1F         ; Background: Blue (1), Foreground: Bright White (F)
    mov cx, 0x0000       ; Top-left corner (Row 0, Col 0)
    mov dx, 0x184F       ; Bottom-right corner (Row 24, Col 79)
    int 0x10

    ; 3. Print Header Border
    mov dh, 8            ; Set cursor to row 8
    mov dl, 18           ; Column 18
    call set_cursor
    mov si, border_top
    mov bl, 0x1E         ; Yellow on Blue
    call print_colored_string

    ; 4. Print Main Welcome Message (Centered)
    mov dh, 10           ; Row 10
    mov dl, 20           ; Column 20
    call set_cursor
    mov si, msg_welcome
    mov bl, 0x1F         ; Bright White on Blue
    call print_colored_string

    ; 5. Print Subtitle
    mov dh, 12           ; Row 12
    mov dl, 25           ; Column 25
    call set_cursor
    mov si, msg_sub
    mov bl, 0x1A         ; Light Green on Blue
    call print_colored_string

    ; 6. Print Bottom Border
    mov dh, 14           ; Row 14
    mov dl, 18           ; Column 18
    call set_cursor
    mov si, border_bot
    mov bl, 0x1E         ; Yellow on Blue
    call print_colored_string

    ; 7. Print Prompt at bottom
    mov dh, 20           ; Row 20
    mov dl, 23           ; Column 23
    call set_cursor
    mov si, msg_reboot
    mov bl, 0x17         ; Light Gray on Blue
    call print_colored_string

wait_key:
    ; Wait for key press using BIOS INT 0x16
    mov ah, 0x00
    int 0x16

reboot:
    ; Perform a soft reboot via BIOS jump
    jmp 0xFFFF:0000

; HELPER FUNCTIONS

; Sets the cursor position: DH = Row, DL = Column
set_cursor:
    mov ah, 0x02
    mov bh, 0x00         ; Page number 0
    int 0x10
    ret

; Prints a null-terminated string with color attribute in BL
print_colored_string:
.loop:
    lodsb                ; Load character at DS:SI into AL
    cmp al, 0
    je .done

    mov ah, 0x0E         ; Teletype output
    mov bh, 0x00         ; Page number 0
    int 0x10
    jmp .loop
.done:
    ret

; DATA SECTION

border_top:  db "+-------------------------------------------+", 0
border_bot:  db "+-------------------------------------------+", 0
msg_welcome: db "  Hello, Welcome to BIOS Real Mode  ", 0
msg_sub:     db " System running on 16-bit Architecture ", 0
msg_reboot:  db "Press any key on your keyboard to reboot...", 0

; Pad remaining space to 512 bytes
times 510 - ($ - $$) db 0
dw 0xAA55