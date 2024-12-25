.model small

data_seg segment 'data'
  character db 'A'
  blank_character db ' '
  row db 12
  col db 38
data_seg ends

; we are not using the stack
stack_seg segment 'stack'
  dw 100 DUP(?)
stack_seg ends

code_seg segment 'code'
  assume cs:code_seg, ds:data_seg, ss:stack_seg
main proc far
  ; for storing the data segment address in the data segment register
  mov ax, data_seg
  mov ds, ax

  ; clearing the screen
  mov al, 25   ; mov 25 lines
  mov bh, 07h
  mov cx, 0000h ; upper left row=0, upper left col = 0, so 00 for ch, 00 for cl
  mov dx, 184Fh ; lower right row=24, lower right col=79
  mov ah, 06h
  int 10h 

  ; change the cursor position
  mov bh, 0   ; page no. 0
  mov dh, row ; total rows = 25, half = 25/2
  mov dl, col ; total cols = 80, half = 80/2 = 40 - (string length / 2) 7 = 33
  mov ah, 02  ; service routine code for changing cursor
  int 10h     ; 10h/02 is the subroutine code of changing the cursor

  ; printing the character
  mov dl, [character]
  mov ah, 02
  int 21h

  ; WAITING LOGIC
  mov ax, 40H ; this will be the segment where bios stores the time
  mov es, ax ; default segment is data segment, so we have to change it using extra segment

  character_loop:
    mov dx, es:[6Ch]  ; Get current ticks (low word)
    mov cx, es:[6Eh]  ; Get current ticks (high word)
  
     ; Calculate the target time (current time + 18 ticks)
    add dx, 9         ; Add half second delay to the low word
    adc cx, 0         ; Add carry to the high word
  
    delay:
      mov ax, es:[6Ch]  ; Read current ticks (low word)
      mov bx, es:[6Eh]  ; Read current ticks (high word)
      cmp bx, cx        ; Compare high words
      jl delay          ; Loop if not reached
      je delay_next     ; if higher word is equal, check in the lower word, 'delay_next'
      jmp delay_end
  
      delay_next:
        cmp ax, dx        ; Compare low words if high words are equal
        jl delay          ; Loop if not reached
      
      delay_end:
        ; down forward
        inc row
        inc col
        jmp action
      
        up_forward:
          dec row
          inc col
          jmp action

        action: 
          ; change the cursor position
          mov bh, 0   ; page no. 0
          mov dh, row ; incremented row
          mov dl, col ; incremented col
          mov ah, 02  ; service routine code for changing cursor
          int 10h     ; 10h/02 is the subroutine code of changing the cursor

          ; printing the character
          mov dl, [character]
          mov ah, 02
          int 21h

        ; do it till the last row
        cmp row, 24
        jl character_loop


exit_program:
  ; exiting the program
  mov ah, 04ch
  int 21h

main endp
code_seg ends
end main
