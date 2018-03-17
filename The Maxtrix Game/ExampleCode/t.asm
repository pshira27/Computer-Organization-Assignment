	.model tiny
	
	.data
;///////////////// Setting /////////////////
	easyMode	dw	04h
	normalMode	dw	02h
	hardMode	dw	01h

;//////////////// Variable /////////////////
	row			db	10 	dup (-1)
	column		db	10	dup	(-1)
	char		db	10  dup	(0)
	
	hp			db	0			; Start HP = 10
	score		db	0			; Start Score = 0
	
	i			dw	?
	j			dw	?
	ex			db	?
	count		db	0
	keyin		db	0
	
;/////////////// Seed /////////////////////	
	seed	db	?
	seed80	db 	?
	seed94	db 	?
	
	.code
	org		0100h

;/////////////// Main Start /////////////////////
main:
	call	setScreen
	call	hideCursor
	call	getSeed
	
	mov		ex, 1
	mov		count, 0			; Start Round 0
	mov		i, 0				; index of array
	mov		di, i				; and store in di 
	call	getStart			; Get start variable for game
	
gameloop:						; Game Processing
	mov		al, hp
	add		al, 'A'
	call	printWhite
	inc		hp
	cmp		hp, 26
	jne		gameloop
	jmp		endProgram
	
	
;//////////////// Function Zone Start ////////////////
;//////////////// System Function ////////////////
deleyinit:						; delay FN
	mov		ah, 86h
	mov		cx, 1
	mov		dx, 40h
	int		15h
	ret
	
delay:							; delay FN assign by game mode
	ret
	
setScreen:
	mov		ah,	00h				; Set screen 80x25 and use to clear screen
	mov		al, 03h
	int		10h
	ret
	
hideCursor:
	mov  	ch, 32   			; Hide cursor
	mov  	ah, 1
	int 	10h
	ret
	
checkKey:
	mov		ah, 01h
	int 	16h
	jz		ctrl1				; is buffer clear ? no getchar
	mov		ah, 00h				; getchar
	int		16h	
	mov		keyin, al			; store in keyin
	
	cmp		al, 27				; is keyin ESC ? yes end the game
	je		escf
	
	mov		i, 0
	cloop:
	mov		di, i
	mov		al, keyin
	cmp		[char + di], al		; is keyin ==
	je		ctrl2
	jne		ctrl1
	ctrl2:
	call	delLine
	call	newLine
	ctrl1:						; buffer is clear do not thing
	inc		i
	cmp		i, 10
	jl		cloop
	ret
	
	escf:
	jmp		endMain
	
getSeed:
	mov		ah, 00h
	int		1Ah
	mov		seed, dl
	call	deleyinit
	mov		ah, 00h
	int		1Ah
	mov		seed80, dl
	call	deleyinit
	mov		ah, 00h
	int		1Ah
	mov		seed94, dl
	call	deleyinit
	ret
	
getStart:
	mov		i, 0
	for1:
	mov		di, i
	call	randChar
	call	randColumn
	inc		i
	cmp		i, 10
	jl		for1
	ret
	
newLine:
	mov		[row + di], 0
	call	randChar
	call	randColumn
	ret
	
delLine:
	mov		j, 0
	jloop:
	mov		dh, j
	mov		dl, [column + di]
	call	setpos
	call	printBlack
	inc		j
	cmp		j, 30
	jl		jloop
	ret
	
setpos:
	mov		ah, 02h
	int		10h
	ret
	
;//////////// Random Function //////////////
randChar:
	mov		ah, 00h   
	mov		al, seed94
	mov		cx, 95
	mul		cx
	add		ax, 17
	mov		cx, 26
	xor		dx, dx
	div		cx
	add		dl, 97
	mov		seed94, dl		
	mov		[char + di], dl
	ret 
	
randColumn:
	mov		ah, 00h
	mov		al, seed80
	mov		cx, 81
	mul		cx
	add		ax, 17
	mov		cx, 65
	xor		dx, dx
	div		cx
	mov		seed80, dl
	mov		[column + di], dl
	ret

;//////////// Print-Display Function //////////////
printChar:			
	mov		di, i
	mov		dh, [row + di]		; set pos
	mov		dl, [column + di]
	mov		ah, 02h
	int		10h
	
	mov		al, [char + di]
	call	printWhite
	call	printGray
	call	printGreen
	call	printGreen
	call	printGreen
	call	printGreen
	call	printGreen
	call	printGreen
	call	printGreen
	dec		dh
	call	printBlack
	ret
	
printBlack:						; print black at pos
	call	setpos
	mov		bl, 00h
	mov		cx, 01h
	mov		ah, 09h
	int		10h
	ret

printWhite:						; print white at pos
	call	setpos
	mov		bl, 0Fh
	mov		cx, 01h
	mov		ah, 09h
	int		10h
	ret

printGray:						; update pos row-- and print gray at pos
	dec		dh
	call	setpos
	mov		bl, 07H
	mov		cx, 01h
	mov		ah, 09h
	int		10h
	ret
	
printGreen:						; update pos row-- and print green at pos
	dec		dh
	call	setpos
	mov		bl, 02h
	mov		cx, 01h
	mov		ah, 09h
	int		10h
	ret
	
;//////////// Game Logic Function //////////////
gameOver:
	jmp		endMain
	
;//////////// End Program //////////////
endMain:
	call	setScreen
	mov		ah, 09h
	mov		dx, offset endProgram
	int		21h
	int		20h
	end 	main
	