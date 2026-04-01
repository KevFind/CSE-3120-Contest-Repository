INCLUDE Irvine32.inc

.data
filename BYTE "words.txt",0
fileBuffer BYTE 4096 DUP(?)   ; raw file data
bytesRead DWORD ?
wordPtrs DWORD 256 DUP(?)     ; array of pointers
wordCount DWORD 0

curr_word DWORD 0                   ; Counter to track which word in use
curr_index DWORD 0                  ; Index for the current letter
blank_line BYTE 120 DUP(" "),0 
row_pos DWORD 0         ; Row position of the current falling word, starts at 0 and increases as the word falls
fall_timer DWORD 0      ; Timer to control the speed of the falling words
DEATH_ROW DWORD 25      ; Row number of the death line, if a word reaches this row, the game is over

gameOverMsg BYTE "GAME OVER",0   ; Message to display when the game is over
winGameMsg BYTE "YOU WIN!",0     ; Message to display when the player wins

MAX_WORDS DWORD 4   ; Maximum number of words to load from the file, can be adjusted as needed

currentWordPtr DWORD ?  ; Pointer to the current word being processed, used for input comparison and display

.code
main PROC
call Clrscr
call LoadWords
call ParseWords
call Randomize
mov eax, wordCount
call RandomRange
mov eax, wordPtrs[eax*4]
mov currentWordPtr, eax


game_loop:
  call DrawDeathLine
  call ProcessInput
  call DrawWord
  call UpdateFalling
  jmp game_loop
main ENDP

; Helper macro to set cursor position
GotoxyM MACRO row, col
    mov dh, row
    mov dl, col
    call Gotoxy
ENDM

LoadWords PROC
    ; Load words from the file into fileBuffer and store the number of bytes read
    mov edx, OFFSET filename
    call OpenInputFile
    mov ebx, eax
    mov edx, OFFSET fileBuffer
    mov ecx, SIZEOF fileBuffer
    call ReadFromFile
    mov bytesRead, eax
    call CloseFile
    ret
LoadWords ENDP

; Parse the raw file data in fileBuffer to populate wordPtrs with pointers to each word and count the total number of words
ParseWords PROC
    mov esi, OFFSET fileBuffer
    mov ecx, bytesRead

    mov edi, OFFSET wordPtrs
    mov wordCount, 0

next_word:
    cmp ecx, 0
    je done
    ; store pointer to start of word
    mov [edi], esi
    add edi, 4
    inc wordCount

scan_word:
    ; Scan until we find a newline or carriage return, which indicates the end of a word
    cmp BYTE PTR [esi], 0Dh
    je skip_cr
    cmp BYTE PTR [esi], 0Ah
    je end_word

    inc esi
    dec ecx
    jnz scan_word
    jmp done

skip_cr:
    mov BYTE PTR [esi], 0
    inc esi
    dec ecx
    jmp scan_word
end_word:
    mov BYTE PTR [esi], 0
    inc esi
    dec ecx
    jmp next_word
done:
    ret
ParseWords ENDP


DrawWord PROC
            ; Draw the current word at its current position
    GotoxyM BYTE PTR row_pos, 0
    
            ; Calculate the offset for the current word
    mov esi, currentWordPtr
    
            ; Print remaining letters
    mov edx, esi
    mov eax, curr_index
    add edx, eax
    call WriteString
    ret
DrawWord ENDP

EraseWord PROC
    mov dh, BYTE PTR row_pos
    mov dl, 0
    call Gotoxy

    mov edx, OFFSET blank_line
    call WriteString
    ret
EraseWord ENDP


ProcessInput PROC

            ; Read a key and compare it to the current letter of the falling word
    call ReadKey                    
    jz no_input                     ; if no key is pressed, return
    mov bl, al                      ; store pressed key
    
            ; Compare with current letter
    mov esi, currentWordPtr
    mov eax, curr_index             
    mov al, [esi + eax]
    cmp bl, al
    jne no_input                    ; if incorrect letter, return

    inc curr_index                    ; move to next letter
            ; Correct letter
    call EraseWord
    mov eax, curr_index
    mov al, [esi + eax]
  
    cmp al, 0                       ; check for null character
    jne no_input

            ; Going to next word once one is completed
    call EraseWord
    inc curr_word
    mov curr_index, 0
    mov row_pos, 0

    mov eax, wordCount
    call RandomRange
    mov eax, wordPtrs[eax*4]
    mov currentWordPtr, eax

            ; Check if at the end of word list
    mov eax, MAX_WORDS
    cmp curr_word, eax
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
    call EraseWord
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
    mov eax, 2000
    call Delay
    invoke ExitProcess,0
GameOverScreen ENDP


WinGameScreen PROC
    call Clrscr
    mov edx, OFFSET winGameMsg
    call WriteString
    mov eax, 2000
    call Delay
    invoke ExitProcess,0
WinGameScreen ENDP



DrawDeathLine PROC      ; If a word makes it to the death line, the game is over
    mov eax, DEATH_ROW
    GotoxyM al,0
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
Utilizing external files and randomization. Also searched online for how to read from files and parse them into usable data.
Used randomization to shuffle the words each time the game is played.
@
