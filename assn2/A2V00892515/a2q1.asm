;
; a2q1.asm
;
; Write a program that displays the binary value in r16
; on the LEDs.
;
; See the assignment PDF for details on the pin numbers and ports.
;


		ldi r16, 0xFF
		out DDRB, r16		; PORTB all output
		sts DDRL, r16		; PORTL all output

		ldi r16, 0x12		; display the value
		mov r0, r16			; in r0 on the LEDs

; Your code here

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;JMP DONE before it reaches this
equal1:	ORI r17,0b10000000
		JMP back1

equal2: ORI r17, 0b00100000
		JMP back2

equal3: ORI r17, 0b00001000
		JMP back3

equal4: ORI r17, 0b00000010
		JMP back4
;;;;;;;;;;;;;Port B below

equal5:	ORI r18, 0b00001000
		JMP back5

equal6: ORI r18, 0b00000010
		JMP back6


LED:	STS PORTL, r17
		OUT PORTB, r18

;
; Don't change anything below here
;
done:	jmp done
