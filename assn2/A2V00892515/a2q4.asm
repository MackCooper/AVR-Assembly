;
; a2q4.asm
;
; Fix the button subroutine program so that it returns
; a different value for each button
;
		; initialize the Analog to Digital conversion

		ldi r16, 0x87
		sts ADCSRA, r16
		ldi r16, 0x40
		sts ADMUX, r16

		; initialize PORTB and PORTL for ouput
		ldi	r16, 0xFF
		out DDRB,r16
		sts DDRL,r16

		clr r0
		call display
lp:
		call check_button
		tst r24
		breq lp
		mov	r0, r24

		call display
		ldi r20, 99
		call delay
		ldi r20, 0
		mov r0, r20
		call display
		rjmp lp

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
;	r24
;
; if you consider the word:
;	 value = (ADCH << 8) +  ADCL
; then:
;
; value > 0x3E8 - no button pressed		//done
;
; Otherwise:
; value < 0x032 - right button pressed
; value < 0x0C3 - up button pressed
; value < 0x17C - down button pressed
; value < 0x22B - left button pressed
; value < 0x316 - select button pressed //done
; 
check_button:
		; start a2d
		lds	r16, ADCSRA	
		ori r16, 0x40
		sts	ADCSRA, r16

		; wait for it to complete
wait:	lds r16, ADCSRA
		andi r16, 0x40
		brne wait

		; read the value
		lds r16, ADCL
		lds r17, ADCH

		; put your new logic here:
		clr r24
		;comparisons for all cases of buttons
		cpi r17, 0x03
		BREQ case1

		cpi r17, 0x00
		BREQ case2 

		cpi r17, 0x01
		BREQ case3
		;depending on high bit, jump to branch for button


case1:	cpi r16, 0xE8
		BRSH no_button
		jmp select

	no_button:	ldi r24, 0
				jmp r

	select:	ldi r24, 16	
			jmp r
		
case2:	cpi r16, 0x32
		BRSH up_button
		jmp right
	
	right:	ldi r24, 1
			jmp r

	up_button:	ldi r24, 2
				jmp r


case3:	cpi r16, 0x7D
		BRLO down
		jmp left

	left:	ldi r24, 8
				jmp r

	down:	ldi r24, 4
			jmp r

r:		ret

;
; delay
;
; set r20 before calling this function
; r20 = 0x40 is approximately 1 second delay
;
; this function uses registers:
;
;	r20
;	r21
;	r22
;
delay:	
del1:		nop
		ldi r21,0xFF
del2:		nop
		ldi r22, 0xFF
del3:		nop
		dec r22
		brne del3
		dec r21
		brne del2
		dec r20
		brne del1	
		ret

;
; display
; 
; display the value in r0 on the 6 bit LED strip
;
; registers used:
;	r0 - value to display
;
display:
		; copy your code from a2q2.asm here
					;Code from a2q1 (Start)
		;
; a2q1.asm
;
; Write a program that displays the binary value in r16
; on the LEDs.
;
; See the assignment PDF for details on the pin numbers and ports.
;

; Your code here
		CLR r25
		CLR r18
		
		mov r19, r0
		ANDI r19, 0x01
		CPI r19, 0x01
		BREQ equal1

	back1:	MOV r19, r0
		ANDI r19, 0x02
		CPI r19, 0x02
		BREQ equal2

	back2:	MOV r19, r0
		ANDI r19, 0x04
		CPI r19, 0x04
		BREQ equal3

	back3:	MOV r19, r0
		ANDI r19,0x08
		CPI r19, 0x08
		BREQ equal4

	back4:	MOV r19, r0
		ANDI r19, 0x10
		CPI r19, 0x10
		BREQ equal5

	back5:	MOV r19, r0
		ANDI r19, 0x20
		CPI r19, 0x20
		BREQ equal6

	back6:	JMP LED


;Port A below
	equal1:	ORI r25,0b10000000
		JMP back1

	equal2: ORI r25, 0b00100000
		JMP back2

	equal3: ORI r25, 0b00001000
		JMP back3

	equal4: ORI r25, 0b00000010
		JMP back4
	;Port B below

	equal5:	ORI r18, 0b00001000
		JMP back5

	equal6: ORI r18, 0b00000010
		JMP back6


	LED:	STS PORTL, r25
			OUT PORTB, r18

;
; Don't change anything below here
;

		;Code from a2q2 (End)


		ret

