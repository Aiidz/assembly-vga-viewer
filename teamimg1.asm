; =====================================================================
; COSC 65A Final Project - Image 1 (DASH2)
; Group Name: TeamAlpha
; Lead Programmer: Adrian G. Mangampat
; Description: Sets VGA Mode 13h (320x200, 256 colors), loads a custom 
;              palette from 'dash2.raw', and reads pixel data directly
;              into video memory segment 0A000h. Resets to text mode on key.
; =====================================================================

.model small
.stack 100h

.data
    ; Filename must be null-terminated for DOS function 3Dh
    filename    db 'dash2.raw', 0
    file_handle dw ?
    
    ; Buffer to temporarily hold the 256-color palette (256 colors * 3 RGB = 768 bytes)
    palette_buf db 768 dup(0)
    
    ; Error and UI messages
    error_msg   db 'Error: Cannot open dash2.raw. Make sure it is in the same directory.', 13, 10, '$'
    loading_msg db 'Loading DASH2 VGA Canvas...', 13, 10, '$'

.code
main proc
    ; Initialize data segment register
    mov ax, @data
    mov ds, ax
    
    ; Step 1: Print loading message
    mov ah, 09h
    lea dx, loading_msg
    int 21h
    
    ; Step 2: Open the image data file
    mov ah, 3Dh         ; DOS open file service
    mov al, 0           ; Access mode: Read-only
    lea dx, filename    ; DS:DX points to filename
    int 21h
    jc file_error       ; Jump if carry flag set (open failed)
    mov file_handle, ax ; Save file handle returned in AX
    
    ; Step 3: Switch to VGA Mode 13h (320x200 pixels, 256 colors)
    mov ax, 0013h
    int 10h
    
    ; Step 4: Read palette data from the file (768 bytes)
    mov ah, 3Fh         ; DOS read file service
    mov bx, file_handle ; BX = file handle
    mov cx, 768         ; CX = bytes to read (256 colors * 3 bytes)
    lea dx, palette_buf ; DS:DX points to destination buffer
    int 21h
    jc restore_and_exit ; If read fails, cleanup and exit
    
    ; Step 5: Upload the custom palette to VGA DAC registers
    mov dx, 03C8h       ; VGA Palette Index Port
    mov al, 0           ; Start at color index 0
    out dx, al          ; Tell VGA we are modifying colors starting at 0
    
    mov dx, 03C9h       ; VGA Palette Data Port
    lea si, palette_buf ; DS:SI points to palette data
    mov cx, 768         ; 768 bytes of RGB values to output
    
send_palette:
    lodsb               ; Load AL from [SI], SI = SI + 1
    out dx, al          ; Write color byte (R, G, or B) to VGA port
    loop send_palette   ; Loop 768 times
    
    ; Step 6: Read pixel data (64,000 bytes) directly into VGA video memory
    ; We save DS because we need to point DS to the VGA segment 0A000h
    mov bx, file_handle ; Save file handle in BX (since DS changes)
    push ds             ; Save data segment (points to @data)
    
    mov ax, 0A000h      ; Video memory segment for Mode 13h
    mov ds, ax          ; Point DS to VGA segment
    xor dx, dx          ; Set offset to 0 (DS:DX = 0A000h:0000h)
    
    mov ah, 3Fh         ; DOS read file service
    mov cx, 64000       ; Read exactly 64,000 bytes (320 columns * 200 rows)
    int 21h             ; Execute read directly into frame buffer!
    
    pop ds              ; Restore DS back to @data
    
    ; Step 7: Close the data file
    mov ah, 3Eh         ; DOS close file service
    mov bx, file_handle ; BX = file handle
    int 21h
    
    ; Step 8: Wait for a key press before exiting
    mov ah, 00h         ; BIOS keystroke service
    int 16h             ; Wait for keyboard input
    
restore_and_exit:
    ; Step 9: Reset video mode to standard 80x25 text mode (Mode 03h)
    mov ax, 0003h
    int 10h
    
    ; Exit program successfully
    mov ax, 4C00h
    int 21h

file_error:
    ; Print error message and exit to DOS
    mov ah, 09h
    lea dx, error_msg
    int 21h
    
    mov ax, 4C01h       ; Exit with error code 1
    int 21h

main endp
end main
