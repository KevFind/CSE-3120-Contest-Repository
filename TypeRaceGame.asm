INCLUDE Irvine32.inc

.data
word1 BYTE "apple",0
word2 BYTE "grapes",0
word3 BYTE "peach",0
word4 BYTE "banana",0
word5 BYTE "orange",0
;word6 BYTE "strawberry",0
;word7 BYTE "watermelon",0
;word8 BYTE "kiwi",0
;word9 BYTE "mango",0
;word10 BYTE "blueberry",0


test_words DWORD OFFSET word1, OFFSET word2, OFFSET word3, OFFSET word4, OFFSET word5;,
                 ;OFFSET word6, OFFSET word7, OFFSET word8, OFFSET word9, OFFSET word10
WORD_COUNT = LENGTHOF test_words ; Number of words in the list
curr_word DWORD 0 ; Counter to track which word in use
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
  mov eax, curr_word
  mov esi, test_words[eax*4]
  
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

  cmp bl, al
  jne incorrect_letter

  ; Correct letter
  inc curr_index
  mov eax, curr_index
  mov al, [esi + eax]
  
  cmp al, 0   ; check for null character
  jne continue_loop

  ; Going to next word once one is completed
  inc curr_word
  mov curr_index, 0
  call Clrscr
  call WriteString
  call Crlf
  
  ; Check if at the end of word list
  cmp curr_word, WORD_COUNT
  je game_over
   
  incorrect_letter:
    jmp game_loop

  continue_loop:
    call Clrscr
    jmp game_loop

  game_over:
    invoke ExitProcess,0

main ENDP
END main
