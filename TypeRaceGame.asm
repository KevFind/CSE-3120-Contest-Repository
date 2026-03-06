INCLUDE Irvine32.inc

.data
word1 BYTE "apple",0
word2 BYTE "grapes",0
word3 BYTE "peach",0
;word4 BYTE "banana",0
;word5 BYTE "orange",0
;word6 BYTE "strawberry",0
;word7 BYTE "watermelon",0
;word8 BYTE "kiwi",0
;word9 BYTE "mango",0
;word10 BYTE "blueberry",0


test_words DWORD OFFSET word1, OFFSET word2, OFFSET word3;, OFFSET word4, OFFSET word5;,
                 ;OFFSET word6, OFFSET word7, OFFSET word8, OFFSET word9, OFFSET word10
WORD_COUNT = LENGTHOF test_words    ; Number of words in the list
curr_word DWORD 0                   ; Counter to track which word in use
curr_index DWORD 0                  ; Index for the current letter

blank_line BYTE 120 DUP(" "),0 

row_pos DWORD 0         ; Row position of the current falling word, starts at 0 and increases as the word falls
fall_timer DWORD 0      ; Timer to control the speed of the falling words
DEATH_ROW DWORD 25      ; Row number of the death line, if a word reaches this row, the game is over

gameOverMsg BYTE "GAME OVER",0   ; Message to display when the game is over
winGameMsg BYTE "YOU WIN!",0     ; Message to display when the player wins

.code
main PROC

game_loop:
  call Clrscr
  call DrawDeathLine
  call DrawWord
  call ProcessInput
  call UpdateFalling
  jmp game_loop
main ENDP


DrawWord PROC
            ; Draw the current word at its current position
    mov dh, BYTE PTR row_pos        ; row
    mov dl, 0                       ; col
    call Gotoxy
    
            ; Calculate the offset for the current word
    mov eax, curr_word
    mov esi, test_words[eax*4]
    
            ; Print remaining letters
    mov edx, esi
    mov eax, curr_index
    add edx, eax
    call WriteString
    ret
DrawWord ENDP


ProcessInput PROC
            ; Read a key and compare it to the current letter of the falling word
    call ReadKey                    
    jz no_input                     ; if no key is pressed, return
    mov bl, al                      ; store pressed key
    
            ; Compare with current letter
    mov eax, curr_index             
    mov al, [esi + eax]
    cmp bl, al
    jne no_input                    ; if incorrect letter, return

            ; Correct letter
    inc curr_index 
    mov eax, curr_index
    mov al, [esi + eax]
  
    cmp al, 0                       ; check for null character
    jne no_input

            ; Going to next word once one is completed
    inc curr_word
    mov curr_index, 0
    mov row_pos, 0

            ; Check if at the end of word list
    cmp curr_word, WORD_COUNT
    je win_game
  
  no_input:
    ret

  win_game:
    call WinGameScreen
    ret
ProcessInput ENDP


UpdateFalling PROC
    mov eax, 10
    call Delay

            ;Update the position of the falling word based on the timer
    add fall_timer, 10
    cmp fall_timer, 100
    jl no_fall              ; if timer hasn't reached threshold, return
    mov fall_timer, 0       ; reset timer
    inc row_pos
    mov eax, DEATH_ROW
    cmp row_pos, eax
    je game_over
  
  no_fall:
    ret
  game_over:
    call GameOverScreen
    ret
UpdateFalling ENDP

GameOverScreen PROC
    call Clrscr
    mov edx, OFFSET gameOverMsg
    call WriteString
    mov eax, 5000
    call Delay
    invoke ExitProcess,0
GameOverScreen ENDP


WinGameScreen PROC
    call Clrscr
    mov edx, OFFSET winGameMsg
    call WriteString
    mov eax, 5000
    call Delay
    invoke ExitProcess,0
WinGameScreen ENDP



DrawDeathLine PROC      ; If a word makes it to the death line, the game is over
    mov eax, DEATH_ROW
    mov dh, al      ; row
    mov dl, 0       ; col
    call Gotoxy
    mov eax, white + (white * 16)   ; white text on white background
    call SetTextColor
    mov edx, OFFSET blank_line 
    call WriteString 
    mov eax, lightGray + (black * 16)   ; restore normal colors
    call SetTextColor
    ret
DrawDeathLine ENDP

END main

COMMENT @
Utilizing call Delay which was not learned in class. Searched online for a way to create a pause within code.
@
