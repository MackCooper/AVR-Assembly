;
; a2q3.asm
;
; Write a main program that increments a counter when the buttons are pressed
;
; Use the subroutine you wrote in a2q2.asm to solve this problem.
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

; Your code here
; make sure your code is an infinite loop
		clr r17
		clr r18
		ldi r19, 0
		mov r0, r19

start:	
		ldi r20, 0x20
		call check_button
		breq stuff
		jmp start




done:		jmp done		; if you get here, you're doing it wrong


stuff:	
		inc r0
		mov r19, r0
		call display
		call delay

		jmp start

;
; the function tests to see if the button
; UP or SELECT has been pressed
;
; on return, r24 is set to be: 0 if not pressed, 1 if pressed
;
; this function uses registers:
;	r16
;	r17
;	r24
;
; This function could be made much better.  Notice that the a2d
; returns a 2 byte value (actually 12 bits).
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
; This function 'cheats' because I observed
; that ADCH is 0 when the right or up button is
; pressed, and non-zero otherwise.
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

		clr r24
		cpi r17, 0
		brne skip		
		ldi r24,1
skip:	ret

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
; copy your display subroutine from a2q2.asm here
 
; display the value in r0 on the 6 bit LED strip
;
; registers used:
;	r0 - value to display
;	r17 - value to write to PORTL
;	r18 - value to write to PORTB
;
;   r16 - scratch
display:
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
		CLR r17
		CLR r18
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
	equal1:	ORI r17,0b10000000
		JMP back1

	equal2: ORI r17, 0b00100000
		JMP back2

	equal3: ORI r17, 0b00001000
		JMP back3

	equal4: ORI r17, 0b00000010
		JMP back4
	;Port B below

	equal5:	ORI r18, 0b00001000
		JMP back5

	equal6: ORI r18, 0b00000010
		JMP back6


	LED:	STS PORTL, r17
			OUT PORTB, r18

;
; Don't change anything below here
;

		;Code from a2q2 (End)

		ret


