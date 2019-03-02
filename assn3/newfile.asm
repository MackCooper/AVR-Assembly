/*
 * newfile.asm
 *
 *  Created: 11/10/2018 2:52:20 PM
 *   Author: mackcooper
 */ 

 #define LCD_LIBONLY
 .include "lcd.asm"

 .cseg
	CALL	lcd_init; call lcd_init to Initialize the LCD
	CALL	lcd_clr
	
		; initialize the Analog to Digital conversion

		ldi r16, 0x87
		sts ADCSRA, r16
		ldi r16, 0x40
		sts ADMUX, r16

		; initialize PORTB and PORTL for ouput
		ldi	r16, 0xFF
		out DDRB,r16
		sts DDRL,r16



	CALL	pointer_init_1
	CALL	pointer_init_2
	CALL	init_strings

	
 loop:	
	CALL	lcd_clr			;Clear line 1 and line 2
	CALL	display_strings	;Display line 1 and line 2


	ldi r19,	0xFF
	sts DDRL,	r19
	out DDRB,	r19

	;Causes the lights to blink while the text is scrolling
	ldi r19,	0b00000000
	sts PORTL,	r19
	ldi r19,	0b00000000
	out PORTB,	r19



	CALL	assin			;Copy the pointer from msg1 to line1
	CALL	assin_2
	CALL	display_strings
	CALL	scroll
	CALL	scroll_2
	CALL	delay
	

;----------------------------	PART	II	-----------------------------------	



;----------------------------	ADD LED	SEGMENT	TO	LOOP-----------------------



	;If the button is pressed, the lights stop blinking and go solid.

	ldi r19,	0b00100010
	sts PORTL,	r19
	ldi	r19,	0b00000010




	;The goal is too have both LEDS on while text is scrolling. Then have them turn off while it's not scrolling.
	CALL	check_button
	CPI		r24, 2

	BREQ	button_pressed	
	JMP		loop

 done:
	JMP	done

;----------------------------	PART	II	-----------------------------------

button_pressed:
;Should do nothing, until button down is presssed (r24 is 4)
	CALL	check_button
	CPI		r24, 4
	BREQ	resume_scrolling
	JMP button_pressed

resume_scrolling:
	jmp		loop						;****************************************** I think my stack gets fucked??????*************************

;Improved button Code from Resources in Assignment#3

;
; An improved version of the button test subroutine
;
; Returns in r24:
;	0 - no button pressed
;	1 - right button pressed
;	2 - up button pressed
;	4 - down button pressed
;	8 - left button pressed
;	16- select button pressed
;
; this function uses registers:
;	r16
;	r17
;	r24
;
; if you consider the word:
;	 value = (ADCH << 8) +  ADCL
; then:
;
; value > 0x3E8 - no button pressed
;
; Otherwise:
; value < 0x032 - right button pressed
; value < 0x0C3 - up button pressed
; value < 0x17C - down button pressed
; value < 0x22B - left button pressed
; value < 0x316 - select button pressed
; 
check_button:
		PUSH r16
		PUSH r17
		
		; start a2d
		LDS	r16, ADCSRA	
		ORI r16, 0x40
		STS	ADCSRA, r16

		; wait for it to complete
		wait:	
			LDS r16, ADCSRA
			ANDI r16, 0x40
			BRNE wait

		; read the value
			LDS r16, ADCL
			LDS r17, ADCH

			CLR r24
			CPI r17, 3			;  if > 0x3E8, no button pressed 
			BRNE bsk1		    ;  
			CPI r16, 0xE8		; 
			BRSH bsk_done		; 
		bsk1:	
			TST r17				; if ADCH is 0, might be right or up  
			BRNE bsk2			; 
			CPI r16, 0x32		; < 0x32 is right
			BRSH bsk3
			LDI r24, 0x01		; right button
			RJMP bsk_done
		bsk3:	
			CPI r16, 0xC3		
			BRSH bsk4	
			LDI r24, 0x02		; up			
			RJMP bsk_done
		bsk4:	
			LDI r24, 0x04		; down (can happen in two tests)
			RJMP bsk_done
		bsk2:	
			CPI r17, 0x01		; could be up,down, left or select
			BRNE bsk5
			CPI r16, 0x7c		; 
			BRSH bsk7
			LDI r24, 0x04		; other possiblity for down
			RJMP bsk_done
		bsk7:	
			LDI r24, 0x08		; left
			RJMP bsk_done
		bsk5:	
			CPI r17, 0x02
			BRNE bsk6
			CPI r16, 0x2b
			BRSH bsk6
			LDI r24, 0x08
			RJMP bsk_done
		bsk6:	
			LDI r24, 0x10
		bsk_done:
			POP r17
			POP r16
	RET



;Delay subroutine taken from Assignment #2 
delay:	
del1:		NOP
		LDI r21,0x60
del2:		NOP
		LDI r22, 0x60
del3:		NOP
		DEC r22
		BRNE del3
		DEC r21
		BRNE del2
		DEC r20
		BRNE del1	
		RET


scroll:
	PUSH	xH
	PUSH	xL
	PUSH	r17

	LDS	xL,	l1ptr
	LDS	xH,	l1ptr	+	1
	ADIW	xH:xL,	1
	LD	r17,	x
	CPI	r17,	0
	BREQ	null_term
	JMP	no_null_term

	null_term:
		;reset ptr1
		PUSH r16

		LDI r16, low(msg1)
		STS l1ptr, r16
		LDI r16, high(msg1)
		STS l1ptr	+	1,	r16

		POP r16

		JMP done_move

	no_null_term:
		STS l1ptr, xL
		STS l1ptr	+	1,	xH
		JMP done_move
	
	done_move:
		POP r17
		POP xL
		POP xH
		RET


scroll_2:
	PUSH	xH
	PUSH	xL
	PUSH	r17

	LDS	xL,	l2ptr
	LDS	xH,	l2ptr	+	1
	ADIW	xH:xL,	1
	LD	r17,	x
	CPI	r17,	0
	BREQ	null_term_2
	JMP	no_null_term_2

	null_term_2:
		;reset ptr1
		CALL pointer_init_2
		JMP done_move_2

	no_null_term_2:
		STS l2ptr, xL
		STS l2ptr	+	1,	xH
		JMP done_move_2
	
	done_move_2:
		pop r17
		pop xL
		pop xH
		
RET

assin:
;method for copying the pointer from msg1 to line1
	PUSH	xH
	PUSH	xL
	PUSH	yH
	PUSH	yL
	PUSH	r17
	PUSH	r18
	
	CLR	r17
	LDI	r18, 0x00
	LDI	xH, high(line1); set x to line 1
	LDI	xL, low(line1)
	LDS yL, l1ptr ;sets y to point to the same thing as l1ptr
	LDS yH, l1ptr	+	1;

	charCopy:
		LD	r17, y+
		CPI	r17, 0x00
		BREQ	wrap_around; if null char is found, reset pointer.
		JMP	continue ; if the no null char is found, jump to handle situation accordingly.

	wrap_around:
		LDI	yH, high(msg1)
		LDI	yL, low(msg1)
		LD	r17, y+

	continue:
		ST	X+, r17
		INC	r18
		CPI	r18, 16
		BREQ	doneCharCopy
		JMP	charCopy

	doneCharCopy:
		LDI	r18, 0x00
		ST	X, r18

		POP	r18
		POP	r17
		POP	yL
		POP	yH
		POP xL
		POP xH

RET



assin_2:
;method for copying the pointer from msg1 to line1
	PUSH	xH
	PUSH	xL
	PUSH	yH
	PUSH	yL
	PUSH	r17
	PUSH	r18
	
	CLR	r17
	LDI	r18, 0x00
	LDI	xH, high(line2); set x to line 1
	LDI	xL, low(line2)
	LDS yL, l2ptr ;sets y to point to the same thing as l1ptr
	LDS yH, l2ptr	+	1;

	char_copy_2:
		LD	r17,	y+
		CPI	r17,	0x00
		BREQ	wrap_around_2; if null char is found, reset pointer.
		JMP	continue_2 ; if the no null char is found, jump to handle situation accordingly.

	wrap_around_2:
		LDI	yH, high(msg2)
		LDI	yL, low(msg2)
		LD	r17, y+

	continue_2:
		ST	X+, r17
		INC	r18
		CPI	r18, 16
		BREQ	done_char_copy_2
		JMP	char_copy_2



	done_char_copy_2:
		LDI	r18, 0x00
		ST	X, r18

		POP	r18
		POP	r17
		POP	yL
		POP	yH
		POP xL
		POP xH

		RET


 pointer_init_1:
	PUSH	r16
	;first pointer
	LDI	r16, low(msg1)
	STS	l1ptr, r16
	LDI	r16, high(msg1)
	STS l1ptr	+	1, r16

	POP	r16

	RET

 pointer_init_2:
	PUSH	r16

	LDI	r16, low(msg2)
	STS	l2ptr, r16
	LDI	r16, high(msg2)
	STS	l2ptr	+	1,	r16

	POP r16

	RET
	
init_strings:
;Copied from lcd_example.asm. Work smart not hard.
	push r16
	; copy strings from program memory to data memory
	ldi r16, high(msg1)		; this the destination
	push r16
	ldi r16, low(msg1)
	push r16
	ldi r16, high(msg1_p << 1) ; this is the source
	push r16
	ldi r16, low(msg1_p << 1)
	push r16
	call str_init			; copy from program to data
	pop r16					; remove the parameters from the stack
	pop r16
	pop r16
	pop r16

	ldi r16, high(msg2)
	push r16
	ldi r16, low(msg2)
	push r16
	ldi r16, high(msg2_p << 1)
	push r16
	ldi r16, low(msg2_p << 1)
	push r16
	call str_init
	pop r16
	pop r16
	pop r16
	pop r16

	pop r16
	ret


display_strings:
;Copied from lcd_example.asm.
	; This subroutine sets the position the next
	; character will be output on the lcd
	;
	; The first parameter pushed on the stack is the Y position
	; 
	; The second parameter pushed on the stack is the X position
	; 
	; This call moves the cursor to the top left (ie. 0,0)

	push r16

	call lcd_clr

	ldi r16, 0x00
	push r16
	ldi r16, 0x00
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	; Now display msg1 on the first line
	ldi r16, high(line1)
	push r16
	ldi r16, low(line1)
	push r16
	call lcd_puts
	pop r16
	pop r16

	; Now move the cursor to the second line (ie. 0,1)
	ldi r16, 0x01
	push r16
	ldi r16, 0x00
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	; Now display msg1 on the second line
	ldi r16, high(line2)
	push r16
	ldi r16, low(line2)
	push r16
	call lcd_puts
	pop r16
	pop r16

	pop r16
	ret

;Code below was pretty much given to us in the assignment documentation. 
msg1_p:	.db "Anyways, trying to do the rest of this assignment", 0	
msg2_p: .db "-------------------------------------------- But it do. -", 0

.dseg
; *****  !!!!WARNING!!!!  *****
; Do NOT put a .org directive here.  The
; LCD library does that for you.
; *****  !!!!WARNING!!!!  *****
;
; The program copies the strings from program memory
; into data memory.  These are the strings
; that are actually displayed on the lcd
;
msg1:	.byte 200
msg2:	.byte 200

;These strings contain the 16 characters to be displayed on the LCD
; Each time through the loop, the pointers l1ptr and l2ptr are incremented
; and then 16 characters are copied into these memory locations
line1:	.byte 17
line2:	.byte 17


;These keep track of where in the string each line currently is
l1ptr:	.byte 2
l2ptr:	.byte 2


