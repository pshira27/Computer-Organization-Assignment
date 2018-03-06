        .model  tiny

        .code
        org     0100h

main:   MOV     ah, 00h         ; Set to 80x25
        MOV     al, 03h
        int     10h

        MOV     bh, 00h		; Set page 00 and Start pos at 24x79
        MOV     dh, 24		; dh is row's pos
        MOV     dl, 80		; dl is col's pos 
	MOV     al, 'O'		; set char 'O' prepare to print	
        MOV     bl, 0Fh		; set color black-white (bg-char)

p1:				; p1 line
	MOV     ah, 02h		; switch to set pos mode
	dec	dl		; dl--  //
        int     10h		; end this mode

        MOV     ah, 09h        	; switch to write w/ color at set pos mode
        MOV     cx, 0001h	; print 1 time
        int     10h		; end this mode	

	MOV 	bp, 25000	; set number to delay //
delay1:	
	dec 	bp		; bp--
	nop			; dont do anything
	cmp	bp, 0		; check if bp == 0 ?
	jne	delay1		; if not loop till bp ==0

	cmp	dl,0		; cmp dl with 0 //
	je	p2		; if dl == 0 jump do p2 line
	jne	p1		; if dl != 0 jump to p1 line (looping as well)


p2:				; p2 line
	mov 	ah, 02h		; switch mode to set pos
	dec	dh		; dl-- (rol--) //
	int 	10h
	
p3:				; p3 line
	mov	ah, 09h		; switch mode to print w/ color
	mov	cx, 0001h	; print 1 time
	int	10h

	mov 	bp, 25000	; same delay from above just change delay name
delay2:	
	dec 	bp
	nop
	cmp	bp, 0
	jne	delay2

	mov 	ah, 02h		; switch mode to set pos
	inc     dl		; dl++ //
	int 	10h		

	cmp	dl, 80		; check dl with 79 //
	jne	p3		; if != 80 do p3 again
	je	p4		; if == 80 do p4

p4:
	dec	dh		; dh-- //
	cmp	dh, -1		; check dh with -1
	jle	outline
	jne	p1		; if != -1 do p1 again


outline:
        ret			; End of program
        end     main
