; ===* Задание *===
; Написать программу, которая при нажатии кнопки SWi, подключённой к
; выводу порта Px, кратковременно включает светодиод LEDj на 40мс.
; =================

.include "m8515def.inc"			;файл определений для ATmega8515

.def temp = r16
.def led = r20
.equ START = 0


.org $000
	; Векторы прерываний
	rjmp INIT
	rjmp BUTTON_PRESSED

; Инициализация
INIT:
	; Cброс led.0 для включения LED0
	ldi led, 0xFE

	; Установка указателя стека на последнюю ячейку ОЗУ
	ldi temp, $5F
	out SPL, temp
	ldi temp, $02
	out SPH, temp

	; C = 1, T = 1
	sec
	set

	; Инициализация порта PB на вывод
	ser temp
	out DDRB, temp

	; Погасить светодиоды
	out PORTB, temp

	; Инициализация 0-го и 2-го выводов порта PD на ввод
	clr temp
	out DDRD, temp

	; Включение "подтягивающих" резисторов порта PD
	ldi temp, 0x05
	out PORTD, temp

	; Разрешение прерывания INT0
	ldi temp, (1 << INT0)
	out GICR, temp

	; Обработка прерывание INT0 по низкому уровню
	ldi temp, 0x00
	out MCUCR, temp

	; Глобальное разрешение прерываний
	sei

; Главная подпрограмма
MAIN:
	rjmp MAIN

BUTTON_PRESSED:
	reti

