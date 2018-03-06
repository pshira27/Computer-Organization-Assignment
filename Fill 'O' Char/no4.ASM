        .model  tiny

        .code
        org     0100h

main:   mov     ah, 00h         ; Set to 80x25
        mov     al, 03h
        int     10h

        mov     bh, 00h		; Set page 00 and Start pos at 0x25
        mov     dh, -1		; dh is row's pos
        mov     dl, 79		; dl is col's pos if u need start at 80-25 > dh 25 and dl 80
	mov     al, 'O'		; set char 'O' prepare to print	
        mov     bl, 0Fh		; set color black-white (bg-char)

p1:				; p1 line
	mov     ah, 02h		; switch to set pos mode
	inc	dh		; dh++ 
        int     10h		; end this mode

        mov     ah, 09h        	; switch to write w/ color at set pos mode
        mov     cx, 0001h	; print 1 time
        int     10h		; end this mode	

	mov 	bp, 25000	; set high number to delay
delay1:	
	dec 	bp		; bp--
	nop			; dont do anything
	cmp	bp, 0		; check if bp == 0 ?
	jne	delay1		; if not loop till bp ==0

	cmp	dh,24		; cmp dh with 24
	je	p2		; if dh == 24 jump do p2 line
	jl	p1		; if dh < 24 jump to p1 line (looping as well)


p2:				; p2 line
	mov 	ah, 02h		; switch mode to set pos
	dec	dl		; dl++ (col++)
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
	dec	dh		; dh--
	int 	10h		

	cmp	dh, -1		; check dh with 0
	je	p4		; if == 25 do p4
	jne	p3		; if > 0 do p3

p4:
	dec	dl		; dl++
	cmp	dl, 0		; check dl with 0
	jle	outline
	jne	p1		; if > 0 do p1 again

outline:
        ret			; End of program
        end     main
