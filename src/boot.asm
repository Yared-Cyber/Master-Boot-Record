[BITS 16]           ; Tell assembler we are in 16-bit Real Mode
[ORG 0x7c00]        ; BIOS loads our code at memory origin address 0x7C00

start:
    ; 1. Clear interrupt flag and set up segment registers safely
    cli             ; Disable interrupts while setting up segments
    xor ax, ax      ; Set AX to 0
    mov ds, ax      ; Data Segment = 0
    mov es, ax      ; Extra Segment = 0
    mov ss, ax      ; Stack Segment = 0
    mov sp, 0x7c00  ; Stack pointer grows down from 0x7C00
    sti             ; Re-enable interrupts

    ; 2. Print character using BIOS interrupt 0x10 (Video Services)
    mov ah, 0x0e    ; AH = 0x0E (Teletype output sub-function)
    mov al, 'A'     ; AL = Character code to print
    mov bh, 0x00    ; BH = Page number (0 is standard)
    mov bl, 0x07    ; BL = Foreground color (light gray on black)
    int 0x10        ; Trigger BIOS video interrupt

hang:
    cli             ; Disable interrupts before halting
    hlt             ; Halt CPU execution until next interrupt
    jmp hang        ; Safety loop in case an NMI wakes the CPU

; 3. Padding and Magic Signature
times 510 - ($ - $$) db 0   ; Fill remaining space with zeroes up to 510 bytes
dw 0xAA55                   ; 2-byte magic boot signature (0x55 then 0xAA on disk)