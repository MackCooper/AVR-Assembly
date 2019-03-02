;
; a2q2.asm
;
;
; Turn the code you wrote in a2q1.asm into a subroutine
; and then use that subroutine with the delay subroutine
; to have the LEDs count up in binary.

		ldi r16, 0xFF
		out DDRB, r16		; PORTB all output
		sts DDRL, r16		; PORTL all output

; Your code here
; Be sure that your code is an infite loop
		ldi r16, 0
		mov r0, r16
start:
		CALL display
		INC r0
		ldi r20, 0x40
		CALL delay
		mov r16, r0
		JMP start



done:		jmp done	; if you get here, you're doing it wrong

;
; display
; 
; display the value in r0 on the 6 bit LED strip
;
; registers used:
;	r0 - value to display
;
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
		ANDI r16, 0x01
		CPI r16, 0x01
		BREQ equal1

	back1:	MOV r16, r0
		ANDI r16, 0x02
		CPI r16, 0x02
		BREQ equal2

	back2:	MOV r16, r0
		ANDI r16, 0x04
		CPI r16, 0x04
		BREQ equal3

	back3:	MOV r16, r0
		ANDI r16,0x08
		CPI r16, 0x08
		BREQ equal4

	back4:	MOV r16, r0
		ANDI r16, 0x10
		CPI r16, 0x10
		BREQ equal5

	back5:	MOV r16, r0
		ANDI r16, 0x20
		CPI r16, 0x20
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
;
; delay
;
; set r20 before calling this function
; r20 = 0x40 is approximately 1 second delay
;
; registers used:
;	r20
;	r21
;	r22
;

delay:	
del1:	nop
		ldi r21,0xFF
del2:	nop
		ldi r22, 0xFF
del3:	nop
		dec r22
		brne del3
		dec r21
		brne del2
		dec r20
		brne del1	
		ret
