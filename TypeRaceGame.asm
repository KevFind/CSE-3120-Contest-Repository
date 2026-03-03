INCLUDE Irvine32.inc

.data
test_word  BYTE "apple",0
wordLength  DWORD LENGTHOF test_word
curr_index  DWORD 0

.code
main PROC
    call Clrscr

game_loop:
  ; Move cursor to top left corner
  mov dh, 0        ; row
  mov dl, 0        ; col
  call Gotoxy

  ; Print remaining letters
  mov edx, OFFSET test_word
  add edx, curr_index
  call WriteString

  ; Read a key
  call ReadChar
  mov bl, al        ; store pressed key

  ; Compare with current letter
  mov esi, OFFSET test_word
  add esi, curr_index
  mov al, [esi]

  cmp bl, al
  jne wrong_key

  ; Correct letter
  inc curr_index

  ; Check if done
  mov eax, curr_index
  cmp eax, wordLength
  jne continue_game

  ; Word completed
  call Clrscr
  call WriteString
  call Crlf
  exit

continue_game:
  call Clrscr
  jmp game_loop

wrong_key:
  ; Ignore incorrect input for now
  jmp game_loop

  ; write wait message
  
  invoke ExitProcess,0
main ENDP
END main
