;Program stores two 8-bit values in sectors #1 and #2 
;than reads them back, adds together and stores low and high bytes
; of the sum in sectors #3 and #4

org  100h  ; Origin, typical for a COM file.

; Main program execution starts here.
call ResetDiskSystem
jc   error

; Before read something we need to write something to the floppy
; Write 0AAh to the first byte of the first sector.
mov  al, 0AAh  ; Value to write
mov  cl, 1     ; Sector number (1 for first sector)
call WriteByteToSector
jc   error

; Write 0FFh to the first byte of the second sector.
mov  al, 0FFh  ; Value to write
mov  cl, 2     ; Sector number (2 for second sector)
call WriteByteToSector
jc   error

; Read back and sum values from the first and second sectors.
call ReadSectorAndSum
jc   error 

mov [buffer2+2], al  ; Store the low byte of AX
mov [buffer2+3], ah  ; Store the high byte of AX

mov  cl, 3     ; Sector number (3 for third sector)
call WriteByteToSector
jc   error

mov al, [buffer2+3] ; Store the high byte back to AL 
mov  cl, 4     ; Sector number (4 for fourth sector)
call WriteByteToSector
jc   error

jmp  done

; Function to reset the disk system.
ResetDiskSystem:
    mov  ah, 0     ; AH = 0 - reset disk system
    mov  dl, 0     ; DL = 0 - drive number (0 = first floppy disk)
    int  0x13      ; Call BIOS interrupt 0x13
    ret

; Function to write a byte to a specific sector.
WriteByteToSector:
    push ax        ; Save AX
    push bx        ; Save BX
    mov  bx, offset buffer ; BX points to the buffer
    mov  [bx], al  ; Place the byte to write at the beginning of the buffer
    mov  ah, 3     ; AH = 3 - function number (write sectors)
    mov  al, 1     ; AL = 1 - number of sectors to write
    mov  ch, 0     ; CH = 0 - cylinder number
    mov  dh, 0     ; DH = 0 - head number
    mov  dl, 0     ; DL = 0 - drive number (0 = first floppy disk)
    int  0x13      ; Call BIOS interrupt 0x13
    pop  bx        ; Restore BX
    pop  ax        ; Restore AX
    ret

; Function to read back and sum values from the first and second sectors.
ReadSectorAndSum:
    xor  ax, ax    ; Clear AX for sum
    
    mov  ah, 2     ; AH = 2 - function number (read sectors)
    mov  al, 1     ; AL = 1 - number of sectors to read
    mov  ch, 0     ; CH = 0 - cylinder number
    mov  cl, 1     ; CL = 1 - sector number (1 for first sector)
    mov  dh, 0     ; DH = 0 - head number
    mov  dl, 0     ; DL = 0 - drive number (0 = first floppy disk)
    mov  bx, offset buffer2 ; BX = offset of buffer
    int  0x13      ; Call BIOS interrupt 0x13
    ; read the second sector.
    mov  ah, 2     ; AH = 2 - function number (read sectors)
    mov  al, 1     ; AL = 1 - number of sectors to read
    mov  cl, 2     ; CL = 2 - sector number (2 for second sector)
    mov  bx, offset buffer2+1 ; BX = offset of buffer+1
    int  0x13      ; Call BIOS interrupt 0x13
    ; add bytes from buffer.
    mov  si, offset buffer2
    lodsb           ; Load first byte to AL and increment SI
    mov  bh, 0      ; Clear BH, zero-extend AL to BX
    mov  bl, al     ; Move AL to BL
    lodsb           ; Load second byte to AL and increment SI
    xor  ah, ah     ; Clear AH, zero-extend AL to AX
    add  ax, bx     ; Add BX to AX
    ret

error:
    ; Error handling
    hlt

done:
    ; Program termination
    ret

buffer db  512 dup(0) ; Buffer for the floppy_0 sector data.
buffer2 db 10 dup(0); Buffer to store intermediate data data