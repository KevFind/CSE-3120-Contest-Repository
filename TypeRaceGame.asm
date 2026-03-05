INCLUDE Irvine32.inc

.data
word1 BYTE "apple",0
word2 BYTE "grapes",0
word3 BYTE "peach",0

test_words DWORD OFFSET word1, OFFSET word2, OFFSET word3
word_count = LENGTHOF test_words
word_counter DWORD 0 ; Counter to track which word in use
curr_index DWORD 0    ; Index for the current letter

.code
main PROC
  call Clrscr

game_loop:
  ; Move cursor to top left corner
  mov dh, 0        ; row
  mov dl, 0        ; col
  call Gotoxy

  ; Calculate the offset for the current word
  mov eax, word_counter
  mov esi, test_words[eax*4]
  
  ;mov ecx, 0      ; Reset index for word length
  ;next_char:
  ;  mov al,[test_words + eax]
  ;  cmp al, 0
  ;  jz continue_code
  ;  inc eax
  ;  inc ecx
  ;  loop next_char
 
  continue_code:
  ; Print remaining letters
  mov edx, esi
  mov eax, curr_index
  add edx, eax
  call WriteString

  ; Read a key
  call ReadChar
  mov bl, al        ; store pressed key

  ; Compare with current letter
  mov eax, curr_index
  mov al, [esi + eax]

  ; Correct letter
  .IF bl == al
    inc curr_index

    mov eax, curr_index
    mov al, [esi + eax]
    .IF al == 0
      ; Move to next word
      inc word_counter
      mov curr_index, 0
      call Clrscr
      call WriteString
      call Crlf
      
      .IF word_counter == word_count
        ; All words completed, reset
        invoke ExitProcess,0
      .ENDIF
    .ENDIF
  .ELSE
     ; Incorrect letter, reset current word
  .ENDIF

  call Clrscr
  jmp game_loop

main ENDP
END main
