; ===* ������� *===
; �������� ���������, ������� ��� ������� ������ SWi, ������������ �
; ������ ����� Px, �������������� �������� ��������� LEDj �� 40��.
; =================

.include "m8515def.inc"			;���� ����������� ��� ATmega8515

.def temp = r16
.def led = r20
.equ START = 0


.org $000
	; ������� ����������
	rjmp INIT
	rjmp BUTTON_PRESSED

; �������������
INIT:
	; C���� led.0 ��� ��������� LED0
	ldi led, 0xFE

	; ��������� ��������� ����� �� ��������� ������ ���
	ldi temp, $5F
	out SPL, temp
	ldi temp, $02
	out SPH, temp

	; C = 1, T = 1
	sec
	set

	; ������������� ����� PB �� �����
	ser temp
	out DDRB, temp

	; �������� ����������
	out PORTB, temp

	; ������������� 0-�� � 2-�� ������� ����� PD �� ����
	clr temp
	out DDRD, temp

	; ��������� "�������������" ���������� ����� PD
	ldi temp, 0x05
	out PORTD, temp

	; ���������� ���������� INT0
	ldi temp, (1 << INT0)
	out GICR, temp

	; ��������� ���������� INT0 �� ������� ������
	ldi temp, 0x00
	out MCUCR, temp

	; ���������� ���������� ����������
	sei

; ������� ������������
MAIN:
	rjmp MAIN

BUTTON_PRESSED:
	reti

