        .model tiny

;------------------ SOUND DEF ------------------
Bj = 2415                               ; B low
C = 2280
Ck = 2152                               ; C#
D = 2031
Dk = 1917                               ; D#
E = 1809
F = 1715
Fk = 1612                               ; F#
G = 1521
A = 1355
B = 1207

        .data
;------------------- SETTING -------------------

; delay
easydelay       DW     04h
mediumdelay     DW     02h
harddelay       DW     01h

; repeat n time(s) then new column begin
rptN    DW     3                        ; default: 3

; variables in linear congruential generator
a80     DW     81                       ; a (default: 81)
c80     DW     17                       ; c (default: 17)
a36     DW     37                       ; a (default: 37)
c36     DW     7                        ; c (default: 7)

; colors of matrix
color   DB     0Fh, 0Ah, 02h, 07h, 08h
;-----------------------------------------------

;------------------ TITLE TEXT -----------------

hptext  DB     ' SCORE:   0                                                              HP: 10$', 0

tittxt  DB     '                  _|_|    _|        _|_|_|    _|    _|    _|_|                 ', 0
        DB     '                _|    _|  _|        _|    _|  _|    _|  _|    _|               ', 0
        DB     '                _|_|_|_|  _|        _|_|_|    _|_|_|_|  _|_|_|_|               ', 0
        DB     '                _|    _|  _|        _|        _|    _|  _|    _|               ', 0
        DB     '                _|    _|  _|_|_|_|  _|        _|    _|  _|    _|               ', 0
        DB     '                                                                               ', 0
        DB     '       _|_|_|  _|    _|    _|_|      _|_|    _|_|_|_|_|  _|_|_|_|  _|_|_|      ', 0
        DB     '     _|        _|    _|  _|    _|  _|    _|      _|      _|        _|    _|    ', 0
        DB     '       _|_|    _|_|_|_|  _|    _|  _|    _|      _|      _|_|_|    _|_|_|      ', 0
        DB     '           _|  _|    _|  _|    _|  _|    _|      _|      _|        _|    _|    ', 0
        DB     '     _|_|_|    _|    _|    _|_|      _|_|        _|      _|_|_|_|  _|    _|    $', 0

anyk    DB     '                          press any key to continue                            $', 0

modetxt DB     '                    _   _   _   _     _   _   _   _   _   _                    ', 0
        DB     '                   / \ / \ / \ / \   / \ / \ / \ / \ / \ / \                   ', 0
        DB     '                  ( M | O | D | E ) ( S | E | L | E | C | T )                  ', 0
        DB     '                   \_/ \_/ \_/ \_/   \_/ \_/ \_/ \_/ \_/ \_/                   ', 0
        DB     '                                                                               ', 0
        DB     '                                                                               ', 0
        DB     '                                                                               ', 0
        DB     '                                      EASY                                     ', 0
        DB     '                                      MEDIUM                                   ', 0
        DB     '                                      HARD                                     ', 0
        DB     '                                                                               ', 0
        DB     '                                                                               ', 0
        DB     '                                                                               ', 0
        DB     '                                                                               ', 0
        DB     '                                                                               ', 0
        DB     '                                                                               ', 0
        DB     '                                                                               ', 0
        DB     '                         ALPHA SHOOTER  Copyright 2017                         $', 0

overtxt DB     '                        _   _   _   _     _   _   _   _                        ', 0
        DB     '                       / \ / \ / \ / \   / \ / \ / \ / \                       ', 0
        DB     '                      ( G | A | M | E ) ( O | V | E | R )                      ', 0
        DB     '                       \_/ \_/ \_/ \_/   \_/ \_/ \_/ \_/                       $', 0

;------------------- SOUND -------------------
starttune DW     E, 5                   ; start sound
        DW     D, 2
        DW     C, 4
        DW     D, 4
        DW     E, 4
        DW     Dk, 1
        DW     E, 4
        DW     Dk, 1
        DW     E, 8

        DW     D, 4
        DW     Ck, 1
        DW     D, 4
        DW     Ck, 1
        DW     D, 8

        DW     E, 4
        DW     G, 4
        DW     Fk, 1
        DW     G, 8

        DW     00h, 00h

overtune DW     E, 5                    ; game over sound
        DW     D, 2
        DW     C, 4
        DW     D, 4
        DW     E, 4
        DW     Dk, 1
        DW     E, 4
        DW     Dk, 1
        DW     E, 8

        DW     D, 4
        DW     Ck, 1
        DW     D, 4
        DW     E, 4
        DW     D, 4
        DW     C, 8

        DW     00h, 00h

shoottune DW     E, 1                   ; shoot sound

        DW     00h, 00h

;------------------ VARIABLES ------------------
arrs    DB     80 DUP(-1)
arre    DB     80 DUP(-1)
arrd    DB     80 DUP(0)
arrc    DB     80 DUP(0)

delay   DW     ?
seed80  DB     ?
seed36  DB     ?

score   DW     0
hp      DB     10
len     DB     23

m       DB     0
i       DW     ?
j       DW     ?
n       DW     ?
allc    DW     ?
cnt     DB     ?
round   DB     ?
;-----------------------------------------------

        .code
        ORG    0100h

main:
        MOV    ah, 00h                  ; set video mode to 80x25
        MOV    al, 03h
        INT    10h

        MOV    ah, 01h                  ; hide cursor
        MOV    cx, 2607h
        INT    10h

        CALL   printtitle               ; show title page

mode:
        MOV    ah, 00h                  ; clear screen
        MOV    al, 03h
        INT    10h

        MOV    ah, 01h                  ; hide cursor
        MOV    cx, 2607h
        INT    10h

        CALL   modeselect               ; show mode select page

        CMP    m, 0                     ; easy mode
        JNE    checkmode1
        MOV    ax, easydelay            ; set delay for easy mode
        MOV    delay, ax
        JMP    begin

checkmode1:
        CMP    m, 1                     ; medium mode
        JNE    checkmode2
        MOV    ax, mediumdelay          ; set delay for medium mode
        MOV    delay, ax
        JMP    begin

checkmode2:
        MOV    ax, harddelay            ; hard mode
        MOV    delay, ax                ; set delay for hard mode

begin:
        MOV    ah, 00h                  ; clear screen
        MOV    al, 03h
        INT    10h

        MOV    ah, 01h                  ; hide cursor
        MOV    cx, 2607h
        INT    10h

rand:                                   ; random columns
        MOV    ah, 00h                  ; get system time as seed of seed80
        INT    1Ah
        MOV    seed80, dl

        MOV    ah, 86h                  ; some delay
        MOV    cx, 00h
        MOV    dx, 050h
        INT    15h

        MOV    ah, 00h                  ; get system time as seed of seed36
        INT    1Ah
        MOV    seed36, dl

        MOV    ah, 02h                  ; move cursor to
        MOV    dl, 0                    ;      column 0
        MOV    dh, 24                   ;      row 24
        MOV    bh, 0
        INT    10h

        MOV     ah, 09h                 ; print initial hp text
        MOV     dx, offset hptext
        INT     21h

        MOV    cx, 80
charlp:                                 ; random char into each column
        PUSH   cx
        CALL   rand36
        MOV    dl, seed36
        ADD    dl, 48

        CMP    dl, 58                   ; add 7 to ascii to skip unused ascii
        JL     skipunused
        ADD    dl, 7
; end charlp loop

skipunused:                             ; print dash to bottom of screen
        POP    cx
        DEC    cx
        MOV    si, cx
        MOV    [arrc + si], dl

        MOV    ah, 02h                  ; move cursor to
        MOV    dl, cl                   ;      column cl
        MOV    dh, 23                   ;      row 23
        MOV    bh, 0
        INT    10h

        PUSH   cx
        MOV    ah, 0Ah
        MOV    al, '-'                  ; print dash
        MOV    bh, 0
        MOV    cx, 1
        INT    10h
        POP    cx

        INC    cx
        LOOP   charlp
; end charlp loop

        MOV    round, 0                 ; count round
mnlp:
        CALL   rand80                   ; get some new random number

        MOV    bh, 00h
        MOV    bl, seed80
        MOV    di, bx

        MOV    [arrs + di], 0           ; set start/end row to 0
        MOV    [arre + di], 0

        MOV    n, 0
rptlp:
        MOV    allc, 0                  ; reset counter
        MOV    i, 0
chklp:
        MOV    di, i
        CMP    [arrs + di], -1          ; if start row = -1
        JE     ddctn2                   ;       then don't print

        MOV    bh, 00h                  ;       else set j to start row
        MOV    bl, [arrs + di]
        MOV    j, bx
        MOV    cnt, 0

pntlp:

        MOV    ah, 02h                  ; move cursor to
        MOV    bx, j
        MOV    dx, i                    ;     column i
        MOV    dh, bl                   ;     row j
        MOV    bh, 0
        INT    10h

        MOV    ah, 09h

        CALL   pntColor                 ; select color to print
        MOV    di, i
        MOV    al, [arrc + di]          ; use ramdomized character to print

        JMP    cont

;-------------------- DUMMY --------------------
        JMP    skip
ddctn2:
        JMP    dctn2
dpntlp:
        JMP    pntlp
skip:
;-----------------------------------------------

ctn4:
        MOV    ah, 02h                  ; move cursor to
        MOV    bx, j
        MOV    dx, i                    ;      column i
        MOV    dh, bl                   ;      row j
        MOV    bh, 0
        INT    10h

        MOV    ah, 09h
        MOV    al, 0                    ; print blank character
        MOV    bl, 00h

cont:
        MOV    bh, 0
        MOV    cx, 1
        INT    10h

        MOV    ah, 01h                  ; check buffer is not empty?
        INT    16h
        JZ     ctn5

        MOV    ah, 00h                  ; if not empty
        INT    16h                      ;       then get character from buffer

        CMP    al, 27                   ; if 'ESC' is pressed
        JE     ddexit                   ;       then exit game

        MOV    cx, 80
cmplp:
        PUSH   cx
        DEC    cx

        CMP    al, 97                   ; else if ASCII is between 'a'
        JL     ctn6
        CMP    al, 122                  ; and 'z'
        JG     ctn6
        SUB    al, 32                   ;       then make it upper case

ctn6:
        MOV    di, cx
        CMP    [arrc + di], al          ; else if key pressed is in array
        JNE    ctn7
        MOV    di, cx
        CMP    [arrs + di], -1          ; and that column is falling
        JNE    incsc                    ;       then increase score

ctn7:
        POP    cx
        LOOP   cmplp
; end cmplp loop

ctn5:
        INC    j
        INC    cnt
        MOV    bl, len
        MOV    di, i
        CMP    cnt, bl                  ; if printed all character in column
        JGE    dechp                    ;      then reset column

        MOV    di, i
        MOV    bh, 00h
        MOV    bl, [arre + di]
        CMP    j, bx                    ; if not print to end of row to print
        JLE    dpntlp                   ;      then continue printing
        JMP    ctn3                     ;      else print next column
; end pntlp loop

incsc:
        INC    score                    ; increase score counter

        CALL   shootsound               ; play shoot sound

        XOR    dx, dx                   ; printing score..
        MOV    ax, score
        MOV    cx, 100
        DIV    cx                       ; divide score by 100
        PUSH   dx

        CMP    al, 0                    ; if score/100 = 0 then skip printing
        JE     ctn8

        MOV    ah, 02h                  ; move cursor to
        MOV    dl, 8                    ;      column 8
        MOV    dh, 24                   ;      row 24
        MOV    bh, 0
        INT    10h

        MOV    ah, 0Ah                  ; print score MSB
        ADD    al, '0'
        MOV    bh, 0
        MOV    cx, 1
        INT    10h

;-------------------- DUMMY --------------------
        JMP    skip3
ddexit:
        JMP    exitgame
skip3:
;-----------------------------------------------

ctn8:
        POP    ax
        XOR    dx, dx
        MOV    cx, 10
        DIV    cx                       ; divide score/100 by 10
        PUSH   dx

        CMP    al, 0                    ; if (score/100)/10 = 0 then skip
        JE     ctn9

        MOV    ah, 02h                  ; move cursor to
        MOV    dl, 9                    ;      column 9
        MOV    dh, 24                   ;      row 24
        MOV    bh, 0
        INT    10h

        MOV    ah, 0Ah                  ; print score
        ADD    al, '0'
        MOV    bh, 0
        MOV    cx, 1
        INT    10h

ctn9:
        POP    ax

        MOV    ah, 02h                  ; move cursor to
        MOV    dl, 10                   ;      column 10
        MOV    dh, 24                   ;      row 24
        MOV    bh, 0
        INT    10h

        MOV    ah, 0Ah                  ; print score LSB
        ADD    al, '0'
        MOV    bh, 0
        MOV    cx, 1
        INT    10h

        JMP    reset

dechp:
        DEC    hp                       ; decrease hp counter

        MOV    ah, 02h                  ; move cursor to
        MOV    dl, 77                   ;      column 77
        MOV    dh, 24                   ;      row 24
        MOV    bh, 0
        INT    10h

        MOV    ah, 0Ah
        MOV    al, 0                    ; print blank character
        MOV    bh, 0
        MOV    cx, 1
        INT    10h

        MOV    ah, 02h                  ; move cursor to
        MOV    dl, 78                   ;      column 78
        MOV    dh, 24                   ;      row 24
        MOV    bh, 0
        INT    10h

        MOV    ah, 0Ah
        MOV    al, hp                   ; print hp to bottom-right
        ADD    al, '0'
        MOV    bh, 0
        MOV    cx, 1
        INT    10h

        CMP    hp, 0                    ; if hp = 0
        JE     dexit                    ;       then game over

reset:
        MOV    [arrs + di], -1          ; reset start row of column i
        MOV    [arre + di], -1          ; reset end row of column i

        MOV    cx, 23
dellp:
        PUSH   cx
        DEC    cx
        MOV    ah, 02h                  ; move cursor to
        MOV    bx, cx
        MOV    dx, di                   ;      column i
        MOV    dh, bl                   ;      row cx
        MOV    bh, 0
        INT    10h

        MOV    ah, 0Ah
        MOV    al, 0                    ; print blank character
        MOV    bh, 0
        MOV    cx, 1
        INT    10h

        POP    cx
        LOOP   dellp
; end dellp loop

cont2:
        MOV    di, i
        MOV    bh, 00h
        MOV    bl, [arrs + di]          ; set start row to arrs[i]
        MOV    j, bx

        MOV    bh, 00h
        MOV    bl, cnt
        ADD    allc, bx                 ; count printed character
        MOV    cnt, 0                   ; reset count

;-------------------- DUMMY --------------------
        JMP    skip2
dmnlp:
        JMP    mnlp
drptlp:
        JMP    rptlp
dchklp:
        JMP    chklp
drand:
        JMP    rand
dctn2:
        JMP    ctn2
dexit:
        JMP    exit
skip2:
;-----------------------------------------------

ctn3:
        MOV    bh, 00h
        MOV    bl, cnt
        ADD    allc, bx                 ; count printed character

        MOV    di, i
        INC    [arre + di]              ; arre[i]++

ctn2:
        INC    i
        CMP    i, 80                    ; if i < 80
        JL     dchklp                   ;      then continue printing
; end chklp loop

ctn1:
        MOV    cx, 2000
        SUB    cx, allc                 ; 2000 - printed character

dummy:
        PUSH   cx

        MOV    ah, 02h                  ; move cursor to
        MOV    dh, 24                   ;      row 24
        MOV    dl, 40                   ;      column 40
        MOV    bh, 0
        INT    10h

        MOV    ah, 09h                  ; print dummy character
        MOV    al, 0
        MOV    bl, 00h
        MOV    bh, 0
        MOV    cx, 1
        INT    10h

        POP    cx
        LOOP   dummy

        MOV    ah, 86h                  ; apply delay base on mode select
        MOV    cx, delay
        MOV    dx, 00h
        INT    15h

        INC    n
        MOV    bx, rptN
        CMP    n, bx                    ; if n < rptN
        JL     drptlp                   ;      then repeat printing

        JMP   dmnlp
; end mnlp loop

exit:
        MOV    cx, 80
reall:
        PUSH   cx

        SUB    cx, 1
        MOV    di, cx
        MOV    [arrs + di], -1          ; reset start row of column i
        MOV    [arre + di], -1          ; reset end row of column i

        MOV    score, 0
        MOV    hp, 10
        MOV    m, 0

        POP    cx
        LOOP   reall
; end reall loop

        MOV    ah, 00h                  ; clear screen
        MOV    al, 03h
        INT    10h

        MOV    ah, 01h                  ; hide cursor
        MOV    cx, 2607h
        INT    10h

        CALL   printover                ; show game over page

        JMP    mode

exitgame:
        MOV    ah, 00h                  ; clear screen
        MOV    al, 03h
        INT    10h

        ; RET
        .exit                           ; exit game

;------------------- DELAY FN ------------------
givemesomedelay:
        MOV    ah, 86h                  ; some delay
        MOV    cx, 05h
        MOV    dx, 00h
        INT    15h

        RET

;------------------ RANDOM FN ------------------

; mod 80 random
rand80:
        MOV    ah, 00h
        MOV    al, seed80

        MOV    cx, a80                  ; linear congruential generator
        MUL    cx
        ADD    ax, c80

        MOV    cx, 80                   ; mod 80
        XOR    dx, dx
        DIV    cx

        MOV    seed80, dl

        RET

; mod 36 random
rand36:
        MOV    ah, 00h
        MOV    al, seed36

        MOV    cx, a36                  ; linear congruential generator
        MUL    cx
        ADD    ax, c36



        MOV    cx, 36                   ; mod 36
        XOR    dx, dx
        DIV    cx

        MOV    seed36, dl

        RET
;------------------ PRINT FN -------------------
pntColor:

        MOV    bl, len
        SUB    bl, 2
        CMP    cnt, bl                  ; if j = [len-2, len]
        JGE    pnt0                     ;      then print color 0

        MOV    bl, len
        SUB    bl, 5
        CMP    cnt, bl                  ; else if j = [len-5, len-3]
        JGE    pnt1                     ;      then print color 1

        CMP    cnt, 2                   ; else if j = [2, len-6]
        JGE    pnt2                     ;      print color 2

        CMP    cnt, 1                   ; else if j = 1
        JGE    pnt3                     ;      print color 3

        JMP    pnt4                     ; else print color 4


pnt0:
        MOV    bl, [color + 0]          ; set bl to color 0
        JMP    fin
pnt1:
        MOV    bl, [color + 1]          ; set bl to color 1
        JMP    fin
pnt2:
        MOV    bl, [color + 2]          ; set bl to color 2
        JMP    fin
pnt3:
        MOV    bl, [color + 3]          ; set bl to color 3
        JMP    fin
pnt4:
        MOV    bl, [color + 4]          ; set bl to color 4

fin:
        RET

;----------------- PRINT TITLE -----------------
printtitle:
        MOV    ah, 02h                  ; move cursor to
        MOV    dl, 0                    ;      column 0
        MOV    dh, 7                    ;      row 7
        MOV    bh, 0
        INT    10h

        MOV     ah, 09h                 ; print title text
        MOV     dx, offset tittxt
        INT     21h

        CALL   startsound               ; play start sound

        MOV    ah, 02h                  ; move cursor to
        MOV    dl, 0                    ;      column 0
        MOV    dh, 21                   ;      row 21
        MOV    bh, 0
        INT    10h

        MOV     ah, 09h                 ; print 'press any key' text
        MOV     dx, offset anyk
        INT     21h

pntany:
        MOV    ah, 02h                  ; move cursor to
        MOV    dl, 51                   ;      column 51
        ADD    dl, bl
        MOV    dh, 21                   ;      row 21
        MOV    bh, 0
        INT    10h

        MOV     ah, 0Ah                 ; print dot character
        MOV     al, '.'
        MOV     bh, 0
        MOV     cx, 1
        INT     10h

        MOV    ah, 01h                  ; if any key pressed
        INT    16h
        JNZ    exitany                  ;      then go to next page
        CALL   givemesomedelay          ; give it some delay

        MOV    ah, 02h                  ; move cursor to
        MOV    dl, 52                   ;      column 52
        ADD    dl, bl
        MOV    dh, 21                   ;      row 21
        MOV    bh, 0
        INT    10h

        MOV     ah, 0Ah                 ; print dot character
        MOV     al, '.'
        MOV     bh, 0
        MOV     cx, 1
        INT     10h

        MOV    ah, 01h                  ; if any key pressed
        INT    16h
        JNZ    exitany                  ;      then go to next page
        CALL   givemesomedelay          ; give it some delay

        MOV    ah, 02h                  ; move cursor to
        MOV    dl, 51                   ;      column 51
        ADD    dl, bl
        MOV    dh, 21                   ;      row 21
        MOV    bh, 0
        INT    10h

        MOV     ah, 0Ah                 ; clear first dot
        MOV     al, 0
        MOV     bh, 0
        MOV     cx, 1
        INT     10h

        MOV    ah, 02h                  ; move cursor to
        MOV    dl, 52                   ;      column 52
        ADD    dl, bl
        MOV    dh, 21                   ;      row 21
        MOV    bh, 0
        INT    10h

        MOV     ah, 0Ah                 ; clear second dot
        MOV     al, 0
        MOV     bh, 0
        MOV     cx, 1
        INT     10h

        MOV    ah, 01h                  ; if any key pressed
        INT    16h
        JNZ    exitany                  ;      then go to next page
        CALL   givemesomedelay          ; give it some delay

        JMP    pntany                   ; infinite loop
; end pntany loop

exitany:
        MOV    ah, 00h                  ; clear buffer
        INT    16h
        RET

modeselect:
        MOV    ah, 02h                  ; move cursor to
        MOV    dl, 0                    ;      column 0
        MOV    dh, 5                    ;      row 5
        MOV    bh, 0
        INT    10h

        MOV     ah, 09h                 ; print mode select text
        MOV     dx, offset modetxt
        INT     21h

        MOV    ah, 02h                  ; move cursor to
        MOV    dl, 36                   ;      column 36
        MOV    dh, 12                   ;      row 12
        MOV    bh, 0
        INT    10h

        MOV    ah, 0Ah                  ; clear all '>'
        MOV    al, 0
        MOV    bh, 0
        MOV    cx, 1
        INT    10h

        MOV    ah, 02h                  ; move cursor to
        MOV    dh, 13                   ;      row 13
        INT    10h

        MOV    ah, 0Ah                  ; clear
        INT    10h

        MOV    ah, 02h                  ; move cursor to
        MOV    dh, 14                   ;      row 14
        INT    10h

        MOV    ah, 0Ah                  ; clear
        INT    10h

        MOV    ah, 02h                  ; move cursor to
        MOV    dh, 12                   ;      row 12
        ADD    dh, m
        INT    10h

        MOV    ah, 0Ah                  ; print '>' to selected menu
        MOV    al, '>'
        INT    10h

inflp:
        MOV    ah, 01h                  ; wait for key pressed
        INT    16h
        JZ     inflp

        MOV    ah, 00h                  ; get key from buffer
        INT    16h

checkup:
        CMP    ah, 72                   ; arrow up
        JNE    checkdown

        CMP    m, 0
        JE     inflp
        DEC    m                        ; decrease menu
        JMP    modeselect

checkdown:
        CMP    ah, 80                   ; arrow down
        JNE    checkesc

        CMP    m, 2
        JE     inflp
        INC    m                        ; increase menu
        JMP    modeselect

checkesc:
        CMP    al, 27                   ; esc
        JNE    checkenter

        JMP    exitgame                 ; exit game

checkenter:
        CMP    al, 13                   ; carriage return
        JNE    inflp                    ; if no key pressed then infinite loop

        RET

printover:
        MOV    ah, 02h                  ; move cursor to
        MOV    dl, 0                    ;      column 0
        MOV    dh, 9                    ;      row 9
        MOV    bh, 0
        INT    10h

        MOV     ah, 09h                 ; print game over text
        MOV     dx, offset overtxt
        INT     21h

        CALL   oversound                ; play game over sound

        RET

;------------------ SOUND FX -------------------
startsound:                             ; start sound
        push ds
        pop  es
        mov  si, offset starttune

        mov  dx,61h                  ; turn speaker on
        in   al,dx                   ;
        or   al,03h                  ;
        out  dx,al                   ;
        mov  dx,43h                  ; get the timer ready
        mov  al,0B6h                 ;
        out  dx,al                   ;

LoopIt: lodsw                        ; load desired freq.
        or   ax,ax                   ; if freq. = 0 then done
        jz   short LDone             ;
        mov  dx,42h                  ; port to out
        out  dx,al                   ; out low order
        xchg ah,al                   ;
        out  dx,al                   ; out high order
        lodsw                        ; get duration
        mov  cx,ax                   ; put it in cx (16 = 1 second)
        call PauseIt                 ; pause it
        jmp  short LoopIt

LDone:  mov  dx,61h                  ; turn speaker off
        in   al,dx                   ;
        and  al,0FCh                 ;
        out  dx,al                   ;

        RET

PauseIt:                                ; some delay
        MOV    ah, 86h
        MOV    dx, 00h
        INT    15h

        RET

oversound:                              ; game over sound
        push ds
        pop  es
        mov  si, offset overtune

        mov  dx,61h                  ; turn speaker on
        in   al,dx                   ;
        or   al,03h                  ;
        out  dx,al                   ;
        mov  dx,43h                  ; get the timer ready
        mov  al,0B6h                 ;
        out  dx,al                   ;

        CALL   LoopIt

        RET

shootsound:                             ; shoot sound
        push ds
        pop  es
        mov  si, offset shoottune

        mov  dx,61h                  ; turn speaker on
        in   al,dx                   ;
        or   al,03h                  ;
        out  dx,al                   ;
        mov  dx,43h                  ; get the timer ready
        mov  al,0B6h                 ;
        out  dx,al                   ;

        CALL   LoopIt

        RET
;-----------------------------------------------

        END    main