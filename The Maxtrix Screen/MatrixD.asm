    .model  tiny
	
	.data
	char		db	80	dup (0)
	row		db	80	dup	(0)
	column		db	80	dup (0)
	len		db	80	dup (10)
	leni		db	?	
	
	ex		db	1
	i		dw	?
	j 		dw  3
	seed	db	?
	seed10	db 	?
	seed80	db 	?
	seed94	db 	?
	temp 	dw	?
	count	db  	?

    .code
    org     0100h

main:   
	mov		ah, 00h
	int		1Ah
	mov		seed, dl
	
	mov     ah, 00h         ; Set to 80x25
    	mov     al, 03h
   	 int     10h
	
	mov  	ch, 32   		; Hide cursor on screen
	mov  	ah, 1
	int 	10h

	mov		i, 0
	mov		di, i
	mov		bl, 02h
	mov		ah, 02h	
	mov		dh, [row + di]
	mov		dl, [column + di]
	int 	10h
	
	MOV    ah, 00h          ; get system time as seed of seed94
    	INT    1Ah
    	MOV    seed94, dl
	
	MOV    ah, 00h          ; get system time as seed of seed80
    	INT    1Ah
    	MOV    seed80, dl

start1:
	mov		i, 0
lp:	
	mov		temp, ax
	call		newJ
	mov		ax, temp
	
	call		setpos
	call		randLen
	call 		randRow
	call		randCol

	inc		i
	cmp		i, 40
	jl		lp

;; --------------------- Main Loop -----------------------------
loopInf:
	mov		i, 0
lp2:					; print 
	call	setpos
	call	getChar		; Get random char & print 1 time
	call 	printWhite
	inc	i			; move to next index of array
	cmp	i, 40		; check i < 40 ?
	jl	lp2
	
	call 	delay
	
	mov	i, 0		; reset i 
lp3:
	call	setpos
	call 	moveDown
	call 	printBlack	; clear char with random len
	inc	i
	call	setpos
	cmp	[row + di], 40
	jl	nxt
	call	newLine
nxt:
	cmp	i, 40
	jl	lp3

	
	cmp	ex, 0		; Infinite loop until ex turn to 1
	jne	loopInf
	jmp	endMain
;------------------------- End Loop ------------------------------
	
	; Function Zone
newLine:
	mov	temp, ax
	call	newJ
	mov	ax, temp
	
	call	setpos
	call	randLen
	call 	randRow
	call	randCol
	ret
	
newJ:								; j getter when j = i^2 - i
	mov		ax, i
	mul		i
	sub		ax, i
	mov		j, ax
	ret
	
setpos:								; set pos
	mov		di, i
	mov		ah, 02h	
	mov		dh, [row + di]
	mov		dl, [column + di]
	int		10h
	ret

randLen:							; random len to del.
	mov		ah, 00h   
	mov		al, seed10
	xor		dx, dx
	mov		cx, 10
	div		cx
	add		dl, 8
	mov		[len + di], dl
	mov		dh, [row + di]
	mov		dl, [column + di]
	ret
	
randRow:							; random start row
	mov		ah, 00h
	mov		al, seed10
	mov		cx, 10
	mul		cx
	add		ax, j
	mov		cx, 40
	xor		dx, dx
	div		cx
	sub		dl, 15
	mov		seed10, dl
	mov		[row + di], dl
	mov		dh, [row + di]
	mov		dl, [column + di]
	ret

randCol:							; random start column
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
	mov		dh, [row + di]
	mov		dl, [column + di]
	ret
	
getChar:							; get 1 random char and print 1 time
	mov		ah, 00h   
	mov		al, seed94
	mov		cx, 95
	mul		cx
	add		ax, 17
	mov		cx, 94
	xor		dx, dx
	div		cx
	add		dl, 33
	mov		seed94, dl				; got random char
	mov		al, dl
	mov		dh, [row + di]
	mov		dl, [column + di]
	call	printWhite				; print it white
	mov		[char + di], al
	int		10h
	ret
		
delay:								; delay FN.
	mov		ah, 86h
	mov		cx, 1
	mov		dx, 40h
	int		15h
	mov		dh, [row + di]
	mov		dl, [column + di]
	ret
	
delay2:								; Option delay (faster than delay)
	mov		ah, 86h
	mov		cx, 00h
	mov		dx, 10h
	int		15h
	ret

printWhite:
	mov		bl, 0Fh
	mov		ah, 09h
	mov		cx, 1
	int		10h
	ret

printBlack:							; del char according to len 
	mov		dh, [row + di]
	sub		dh,	[len + di]
	mov		ah, 02h
	int		10h
	mov		bl, 00h
	mov		ah, 09h
	mov		cx, 1
	int		10h
	mov		dh, [row + di]
	mov		ah, 02h
	int		10h
	ret

printGreen:
	mov		bl, 02h
	mov		ah, 09h
	mov		cx, 1
	int		10h
	ret
	
printGray:
	mov		bl, 07H
	mov		ah, 09h
	mov		cx, 1
	int		10h
	ret

moveDown:						; printGreen > printGray and then set pos row +1
	call	getChar
	add		seed94, 3
	mov		al, seed94
	mov		dh, [row + di]
	dec		dh
	mov		ah, 02h
	int		10h
	call	printGreen
	mov		dh, [row + di]
	mov		ah, 02h
	int		10h
	mov		al, [char + di]
	call	printGray
	inc		[row + di]
	mov		ah, 02h
	int		10h
	ret

endMain:
        ret			; End of program
        end     main
