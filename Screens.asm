INCLUDE Irvine32.inc

.data
titleMsg BYTE "This is a TYPING GAME",0
instr1 BYTE "Type the falling word before it reaches the bottom.",0
instr2 BYTE "Each correct letter removes part of the word.",0
instr3 BYTE "Finish [this many levels] to win.",0
startMsg BYTE "Press ENTER to begin...",0

gameOverMsg BYTE "GAME OVER",0   ; Message to display when the game is over
winGameMsg BYTE "YOU WIN!",0     ; Message to display when the player wins

.code
; Helper macro to set cursor position
GotoxyM MACRO row, col
    mov dh, row
    mov dl, col
    call Gotoxy
ENDM

TitleScreen PROC
    call Clrscr
    GotoxyM 0, 0
    mov edx, OFFSET titleMsg
    call WriteString

    GotoxyM 1, 0
    mov edx, OFFSET instr1
    call WriteString

    GotoxyM 2, 0
    mov edx, OFFSET instr2
    call WriteString

    GotoxyM 3, 0
    mov edx, OFFSET instr3
    call WriteString

    GotoxyM 4, 0
    mov edx, OFFSET startMsg
    call WriteString

wait_enter:
    call ReadChar
    cmp al, 13
    jne wait_enter
    call Clrscr
    ret
TitleScreen ENDP


GameOverScreen PROC
    call Clrscr
    mov edx, OFFSET gameOverMsg
    call WriteString
    mov eax, 1000
    call Delay
    call ReadChar
    invoke ExitProcess,0
GameOverScreen ENDP


WinGameScreen PROC
    call Clrscr
    mov edx, OFFSET winGameMsg
    call WriteString
    mov eax, 1000
    call Delay
    call ReadChar
    invoke ExitProcess,0
WinGameScreen ENDP

END