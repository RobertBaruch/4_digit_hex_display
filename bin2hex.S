/*
 * bin2hex for ATtiny84.
 *
 * Acts as a 4-bit binary to 7-segment converter,
 * displaying hexadecimal digits as 0123456789AbCdEF.
 *
 * Autodetects common cathode vs common anode by reading
 * the 'a' pin. Connect a 100k resistor between pin 'a' and
 * ground. As long as the forward voltage of the LED
 * is less than around 2.2 volts at nearly zero current,
 * this pin will read as high for common anode and low for
 * common cathode.
 *
 * The /RESET pin can function as /BLANK, since that is
 * the only way, when powered up, that the processor will
 * disable all of its pins.
 *
 * The program reads D3 - D0, and outputs the 7-segment
 * decode to a - g.
 *
 * Finally, remember to add resistors in series between pins
 * a - g and the LEDs. The internal resistance of pins a - g
 * is around 28 ohms, and you do not want to be sticking that
 * to an LED unless you want it to glow really bright for a
 * short while and then never light up again.
 *
 * To determine the correct resistance, decide, based on the
 * LED datasheet, what current in mA you want. Determine,
 * using the datasheet, what the forward voltage of the LED
 * will be at that current. Let the current be I (in mA) and
 * the forward voltage be Vf (in V). Then your resistance is:
 *
 *  R (in kiloohms) = (5 - Vf) / I.
 *
 * Example: I want 2mA, and Vf = 1.8V at that current.
 * Therefore, I need a 1.6k resistor. I will choose 1.5k
 * since that is close enough.
 *
 * Note that I treat the 28 ohm internal resistance of the
 * processor as negligable.
 *
 * Pinout:
 *
 *           VCC 1 o:: 14 GND
 *       e [PB0] 2 ::: 13 [PA0] a
 *       f [PB1] 3 ::: 12 [PA1] b
 *  /RESET [PB3] 4 ::: 11 [PA2] c
 *       g [PB2] 5 ::: 10 [PA3] d
 *      D3 [PA7] 6 :::  9 [PA4] D0
 *      D2 [PA6] 7 :::  8 [PA5] D1
 *
 */
#include <avr/io.h>

// Get the AVR tools for Windows at 
//   https://sourceforge.net/projects/winavr
// Or, install the AVR tools for Linux by using
//   sudo apt-get install gcc-avr binutils-avr gdb-avr avr-libc avrdude
//   or see http://avr-eclipse.sourceforge.net/wiki/index.php/The_AVR_GCC_Toolchain
//
// To compile:
//   avr-gcc -c -mmcu=attiny84 -o bin2hex.o bin2hex.S
//   avr-ld -e init -o bin2hex.elf bin2hex.o
//   avr-objcopy -j .text -O ihex bin2hex.elf bin2hex.hex
//
// To program:
//   Get a device programmer.


.section .text

.org 0
.global init

init:
	rjmp main

.org 0x0020
.global main

main:
	cli

	// Disable watchdog timer

	wdr
	ldi r16, 0x00
	out _SFR_IO_ADDR(MCUSR), r16
	in r17, _SFR_IO_ADDR(WDTCSR)
	ori r17, _BV(WDCE) | _BV(WDE)
	out _SFR_IO_ADDR(WDTCSR), r17
	out _SFR_IO_ADDR(WDTCSR), r16

	// Disable input pullups

	ldi r16, _BV(PUD)
	out _SFR_IO_ADDR(MCUCR), r16

	// Pin directions are all
	// inputs on reset.

	// r20 is the LED type:
	//  0x00 = common cathode
	//  0xFF = common anode

	ldi r20, 0x00

	// Read PA0 to determine connected LED type.
	// Will read as xxxxxxx1 for common
	// anode, xxxxxxx0 for common cathode.

	in r16, _SFR_IO_ADDR(PINA)
	andi r16, 0x01
	sub r20, r16 // 0x00 - {0x00/0x01} = 0x00/0xFF

	// Set pin directions:
	//   PA3 - PA0, PB3 - PB0 are outputs
	//   PA7 - PA4 are inputs

	ldi r16, 0x0F
	out _SFR_IO_ADDR(DDRA), r16
	out _SFR_IO_ADDR(DDRB), r16

    // We store the segment data table at 0x0100.

	ldi ZH, 0x01
loop:
	in ZL, _SFR_IO_ADDR(PINA)
	swap ZL
	and ZL, r16
    lpm r0, Z
    eor r0, r20 // inverts for common anode
    mov r1, r0
    swap r1
    and r0, r16
    and r1, r16
    out _SFR_IO_ADDR(PORTA), r0
    out _SFR_IO_ADDR(PORTB), r1
	rjmp loop

// The 7-segment data table.
// From msb to lsb: xgfedcba
//
// Segments in 7-segment displays start from the
// top, go clockwise, and end with g in the middle:
//
//    a
//   ---
// f|   |b
//   -g-
// e|   |c
//   ---
//    d
//  

.org 0x0100

//       gfedcba
.byte 0b00111111
.byte 0b00000110
.byte 0b01011011
.byte 0b01001111

.byte 0b01100110
.byte 0b01101101
.byte 0b01111101
.byte 0b00000111

.byte 0b01111111
.byte 0b01101111
.byte 0b01110111
.byte 0b01111100

.byte 0b00111001
.byte 0b01011110
.byte 0b01111001
.byte 0b01110001

.end
