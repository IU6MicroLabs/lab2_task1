; ===* ������� *===
; �������� ���������, ������� ��� ������� ������ SWi, ������������ �
; ������ ����� Px, �������������� �������� ��������� LEDj �� 40��.
; =================

.include "m8515def.inc" ;���� ����������� ��� ATmega8515

.def temp = r16
.def led = r20
.def timerCount = r21

.equ TARGET_BUTTON = 3 ; ������ ������
.equ TARGET_LED = ~0b00000001 ; ����� �������� ������ ���������
.equ TIMER_COUNT = 160 ; ���, �.�. 40�� �������� => 4000 (��, ������� ����������) / (40 / 1000 (��)))


.org $000
	; ������� ����������
	rjmp INIT
	reti ; INT0
	reti ; INT1
	reti
	reti
	reti
	reti
	rjmp ON_TIMER_OVERFLOW ; T/C0 OVF

; �������������
INIT:
	; C���� led.0 ��� ��������� LED0
	ldi led, 0xFE

	; ��������� ��������� ����� �� ��������� ������ ���
	ldi temp, $5F
	out SPL, temp
	ldi temp, $02
	out SPH, temp

	; ������������� ����� PB �� �����
	ser temp
	out DDRB, temp

	; �������� ����������
	out PORTB, temp

	; ������������� ������� ������ ����� PD �� ���� � �������������� ���������
	ldi temp, (1 << TARGET_BUTTON)
	out DDRD, temp
	out PORTD, temp

	; ���������� ���������� ������������ timer0
	ldi temp, (1 << TOIE0)
	out TIMSk, temp

	; ��������� timer0
	clr temp
	out TCCR0, temp

	; ���������� ���������� ����������
	sei

; ������� ������������
MAIN:
	; case TARGET_BUTTON
	sbis PIND, TARGET_BUTTON
	rcall ON_BUTTON_PRESSED

	; default
	rjmp MAIN

; ���������� ������� ������
ON_BUTTON_PRESSED:
	; ���������� ���������� ������� timer0
	clr temp
	out TCNT0, temp

	; ���������� ������� ���������� �������
	ldi timerCount, TIMER_COUNT

	; �������� timer0 ��� ���������������
	ldi temp, (1 << CS00)
	out TCCR0, temp

	; �������� ��������
	ldi led, TARGET_LED
	out PORTB, led

	ret

; ���������� ������������ �������� �������
ON_TIMER_OVERFLOW:
	; ��������� ������� ����������
	dec timerCount

	; ���� timerCount != 0, �� ��������� ��������� ����������
	clr temp
	cpse timerCount, temp
	reti

	; ����� ��������� �������� � ������
	rjmp ON_TIMER_DONE
	reti

; ������ �������� 40��
ON_TIMER_DONE:
	; ��������� ��������
	ser led
	out PORTB, led

	; ��������� timer0
	clr temp
	out TCCR0, temp

	ret

