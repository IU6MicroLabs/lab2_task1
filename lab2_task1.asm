; ===* Задание *===
; Написать программу, которая при нажатии кнопки SWi, подключённой к
; выводу порта Px, кратковременно включает светодиод LEDj на 40мс.
; =================

.include "m8515def.inc" ;файл определений для ATmega8515

.def temp = r16
.def led = r20

.equ TARGET_BUTTON = 3 ; Третья кнопка
.equ TARGET_LED = ~0b00000001 ; Будем включать первый светодиод


.org $000
	; Векторы прерываний
	rjmp INIT
	reti ; INT0
	reti ; INT1
	reti
	reti
	reti
	reti
	rjmp ON_TIMER ; T/C0 OVF

; Инициализация
INIT:
	; Cброс led.0 для включения LED0
	ldi led, 0xFE

	; Установка указателя стека на последнюю ячейку ОЗУ
	ldi temp, $5F
	out SPL, temp
	ldi temp, $02
	out SPH, temp

	; Инициализация порта PB на вывод
	ser temp
	out DDRB, temp

	; Погасить светодиоды
	out PORTB, temp

	; Инициализация нужного вывода порта PD на ввод и подтягивающего резистора
	ldi temp, (1 << TARGET_BUTTON)
	out DDRD, temp
	out PORTD, temp

	; Разрешение прерывания переполнения timer0
	ldi temp, (1 << TOIE0)
	out TIMSk, temp

	; Выключаем timer0
	clr temp
	out TCCR0, temp

	; Глобальное разрешение прерываний
	sei

; Главная подпрограмма
MAIN:
	; case TARGET_BUTTON
	sbis PIND, TARGET_BUTTON
	rcall ON_BUTTON_PRESSED

	; default
	rjmp MAIN

; Обработчик нажатия кнопки
ON_BUTTON_PRESSED:
	; Сбрасываем счётчик timer0
	clr temp
	out TCNT0, temp

	; Включаем timer0 без масштабирования
	ldi temp, (1 << CS00)
	out TCCR0, temp

	; Включаем лампочку
	ldi led, TARGET_LED
	out PORTB, led

	ret

; Обработчик переполнения счётчика таймера
ON_TIMER:
	; Выключаем лампочки
	ser led
	out PORTB, led

	; Выключаем timer0
	clr temp
	out TCCR0, temp

	reti

