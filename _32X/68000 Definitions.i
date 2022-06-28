; ---------------------------------------------------------------------------
; 32X 68000 definitions
; ---------------------------------------------------------------------------

; ROM
MARSBANK0	EQU	$880000			; Fixed bank
MARSBANK	EQU	$900000			; Switchable bank

; System registers
MARSSYSREG	EQU	$A15100			; System registers
MARSFM		EQU	$00			; Super VDP access control
MARSADAPTER	EQU	$01			; Adapter control
MARSSTANDBY	EQU	$03			; CMD interrupt request
MARSBANKID	EQU	$05			; ROM bank
MARSDREQCTRL	EQU	$07			; DREQ control
MARSRV		EQU	$07			; ROM to VRAM DMA flag
MARSDREQSRC	EQU	$08			; DREQ source
MARSDREQDEST	EQU	$0C			; DREQ destination
MARSDREQLEN	EQU	$10			; DREQ length
MARSDREQFIFO	EQU	$12			; DREQ FIFO
MARSCOMM0	EQU	$20			; Communication register 0
MARSCOMM1	EQU	$21			; Communication register 1
MARSCOMM2	EQU	$22			; Communication register 2
MARSCOMM3	EQU	$23			; Communication register 3
MARSCOMM4	EQU	$24			; Communication register 4
MARSCOMM5	EQU	$25			; Communication register 5
MARSCOMM6	EQU	$26			; Communication register 6
MARSCOMM7	EQU	$27			; Communication register 7
MARSCOMM8	EQU	$28			; Communication register 8
MARSCOMM9	EQU	$29			; Communication register 9
MARSCOMMA	EQU	$2A			; Communication register 10
MARSCOMMB	EQU	$2B			; Communication register 11
MARSCOMMC	EQU	$2C			; Communication register 12
MARSCOMMD	EQU	$2D			; Communication register 13
MARSCOMME	EQU	$2E			; Communication register 14
MARSCOMMF	EQU	$2F			; Communication register 15

; ---------------------------------------------------------------------------
