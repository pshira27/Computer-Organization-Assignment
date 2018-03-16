	.model tiny
	
	.data
;///////////////// Setting /////////////////
	easyMode	dw	04h
	normalMode	dw	02h
	hardMode	dw	01h
	
;//////////////// Screening ////////////////
	endProgram	db 'End of Program $', 0
;				   '0         1         2         3         4         5         6         7         '
;                  '01234567890123456789012345678901234567890123456789012345678901234567890123456789'
	titleScreen	db '     _|_|      _|_|   _|_|   _|      _| _|_|_|_|_| _|_|_|   _| _|      _|       ', 0
				db '     _|  _|  _|  _| _|    _|   _|  _|       _|     _|    _| _|   _|  _|         ', 0
				db '     _|  _|  _|  _| _|_|_|_|     _|         _|     _|_|_|   _|     _|           ', 0
				db '     _|    _|    _| _|    _|   _|  _|       _|     _|    _| _|   _|  _|         ', 0
				db '     _|    _|    _| _|    _| _|      _|     _|     _|    _| _| _|      _|       ', 0
				db '                                                                                ', 0
				db '       _|_|_| _|_|_|                                                            ', 0
				db '       _|  _| _|                                                                ', 0
				db '       _|_|_| _|_|_|                                                            ', 0
				db '       _|     _|                                                                ', 0
				db '       _|     _|_|_|                                                            ', 0
				db '                                                                                ', 0
				db '                                                                                ', 0
				db '                                                                                ', 0
				db '                                                                                ', 0
				db '                                                                                ', 0
				db '                                                                                ', 0
				db '                                                                                ', 0
				db '                                                                                ', 0
				db '                                                                                 $', 0

;//////////////// Variable /////////////////
	row			db	10 	dup (-1)
	column		db	10	dup	(-1)
	char		db	10  dup	(0)
	
	hp			db	10			; Start HP = 10
	score		db	0			; Start Score = 0
	
	i			dw	0
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
	
	mov		count, 0			; Start Round 0
	mov		i, 0				; index of array
	mov		di, i				; and store in di 
;	call	getStart			; Get start variable for game
	
gameloop:						; Game Processing
	call	checkKey
	
	
	mov		keyin, 0			; clear keyin b4 loop
	jmp		gameloop
	
	
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
	ctrl1:						; buffer is clear do not thing
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
	
	cmp		i, 10
	jl		for1
	ret
	
;//////////// Random Function //////////////
randChar:
	mov		ah, 00h   
	mov		al, seed94
	mov		cx, 95
	mul		cx
	add		ax, 17
	mov		cx, 94
	xor		dx, dx
	div		cx
	add		dl, 33
	mov		seed94, dl		
	mov		[char + di], dl
	ret 
	
randColumn:
	mov		ah, 00h
	mov		al, seed80
	mov		cx, 81
	mul		cx
	add		ax, 17
	mov		cx, 80
	xor		dx, dx
	div		cx
	mov		seed80, dl
	mov		[column + di], dl
	ret

;//////////// Print-Display Function //////////////
printChar:						; check keyin
	mov		dh, [row + di]
	mov		dl, [column + di]
	mov		al, [char + di]
	call	printWhite
	call	printGray
	call	printGreen
	ret

printWhite:						; print white at pos
	mov		bl, 0Fh
	mov		cx, 01h
	mov		ah, 09h
	int		10h
	ret

printGray:						; update pos row-- and print gray at pos
	dec		dh
	mov		bl, 07H
	mov		cx, 01h
	mov		ah, 09h
	int		10h
	ret
	
printGreen:						; update pos row-- and print green at pos
	dec		dh
	mov		bl, 07H
	mov		cx, 01h
	mov		ah, 09h
	int		10h
	ret
	
;//////////// Game Logic Function //////////////
decHP:
	dec		hp
	cmp		hp, 0				; Check hp == 0 ?
	jg		alive				; no ? still alive :D 
	jmp		gameOver			; yes ... aw gameover
	alive:
	ret

gameOver:
	ret
	
;//////////// End Program //////////////
endMain:
	call	setScreen
	mov		ah, 09h
	mov		dx, offset endProgram
	int		21h
	int		20h
	end 	main
	