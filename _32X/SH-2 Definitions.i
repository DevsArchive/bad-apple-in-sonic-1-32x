; ---------------------------------------------------------------------------
; 32X SH-2 definitions
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
; Align
; ---------------------------------------------------------------------------

algn macro
	if narg=1
		dcb.b	((\1)-((*)%(\1)))%(\1),0
	else
		dcb.b	((\1)-((*)%(\1)))%(\1),\2
	endif
	endm

; ---------------------------------------------------------------------------
; Addresses
; ---------------------------------------------------------------------------

; Cache through
TH		EQU	$20000000

; Boot ROM
BOOTROM		EQU	$00000000

; System registers
SYSREG		EQU	TH+$00004000
ADAPTER		EQU	$00			; Adapter control
INTMASK		EQU	$01			; Interrupt mask
STANDBY		EQU	$03			; CMD interrupt request
HCOUNT		EQU	$05			; H-BLANK counter
DREQCTRL	EQU	$06			; DREQ control
DREQSRC		EQU	$08			; DREQ source
DREQDEST	EQU	$0C			; DREQ destination
DREQLEN		EQU	$10			; DREQ length
DREQFIFO	EQU	$12			; DREQ FIFO
VRESINTCLR	EQU	$14			; VRES interrupt clear
VINTCLR		EQU	$16			; V-BLANK interrupt clear
HINTCLR		EQU	$18			; H-BLANK interrupt clear
CMDINTCLR	EQU	$1A			; CMD interrupt clear
PWMINTCLR	EQU	$1C			; PWM interrupt clear
COMM0		EQU	$20			; Communication register 0
COMM1		EQU	$21			; Communication register 1
COMM2		EQU	$22			; Communication register 2
COMM3		EQU	$23			; Communication register 3
COMM4		EQU	$24			; Communication register 4
COMM5		EQU	$25			; Communication register 5
COMM6		EQU	$26			; Communication register 6
COMM7		EQU	$27			; Communication register 7
COMM8		EQU	$28			; Communication register 8
COMM9		EQU	$29			; Communication register 9
COMMA		EQU	$2A			; Communication register 10
COMMB		EQU	$2B			; Communication register 11
COMMC		EQU	$2C			; Communication register 12
COMMD		EQU	$2D			; Communication register 13
COMME		EQU	$2E			; Communication register 14
COMMF		EQU	$2F			; Communication register 15
PWMTIMER	EQU	$30			; PWM timer control
PWMCTRL		EQU	$31			; PWM control
PWMCYCLE	EQU	$32			; PWM cycle
PWMLEFT		EQU	$34			; PWM left width
PWMRIGHT	EQU	$36			; PWM right width
PWMMONO		EQU	$38			; PWM mono width

; VDP registers
VDPREG		EQU	TH+$00004100
TVMODE		EQU	$00			; TV mode
BMPMODE		EQU	$01			; Bitmap mode
SHIFT		EQU	$02			; Shift control
FILLLEN		EQU	$04			; Fill length
FILLSTART	EQU	$06			; Fill start
FILLDATA	EQU	$08			; Fill data
VDPSTAT		EQU	$0A			; VDP status
FRAMECTRL	EQU	$0B			; Frame buffer control

; Palette
PALETTE		EQU	TH+$00004200

; Cartridge
CARTRIDGE	EQU	$02000000

; Frame buffer
FRAMEBUF	EQU	TH+$04000000		; Frame buffer
OVERWRITE	EQU	TH+$04020000

; SDRAM
SDRAM		EQU	$06000000

; Peripheral
SERIAL		EQU	$FFFFFE00		; Serial control
FRT		EQU	$FFFFFE10		; Free run timer
TIER		EQU	$00			; Timer interrupt enable
TCSR		EQU	$01			; Timer control/status
FRCH		EQU	$02			; Free running counter (high)
FRCL		EQU	$03			; Free running counter (low)
OCRH		EQU	$04			; Output compare register (high)
OCRL		EQU	$05			; Output compare register (low)
TCR		EQU	$06			; Timer control
TOCR		EQU	$07			; Timer output compare control
DMAREQACK0	EQU	$FFFFFE71		; DMA request/acknowledge select control 0
DMAREQACK1	EQU	$FFFFFE72		; DMA request/acknowledge select control 1
CCR		EQU	$FFFFFE92		; Cache register
JR		EQU	$FFFFFF00		; Dividend
HRL32		EQU	$FFFFFF04		; Dividend
HRH		EQU	$FFFFFF10		; Quotient (high)
HRL		EQU	$FFFFFF14		; Quotient (low)
DMAREG		EQU	$FFFFFF80		; DMA registers
DMASRC0		EQU	$FFFFFF80		; DMA source 0 (DREQ)
DMADEST0	EQU	$FFFFFF84		; DMA destination 0 (DREQ)
DMACOUNT0	EQU	$FFFFFF88		; DMA count 0 (DREQ)
DMACTRL0	EQU	$FFFFFF8C		; DMA channel control 0 (DREQ)
DMASRC1		EQU	$FFFFFF90		; DMA source 1 (PWM)
DMADEST1	EQU	$FFFFFF94		; DMA destination 1 (PWM)
DMACOUNT1	EQU	$FFFFFF98		; DMA count 1 (PWM)
DMACTRL1	EQU	$FFFFFF9C		; DMA channel control 1 (PWM)
DMAVECN0	EQU	$FFFFFFA0		; DMA vector number N0
DMAVECE0	EQU	$FFFFFFA4		; DMA vector number E0
DMAVECN1	EQU	$FFFFFFA8		; DMA vector number N1
DMAVECE1	EQU	$FFFFFFAC		; DMA vector number E1
DMAOPER		EQU	$FFFFFFB0		; DMA operation control

; ---------------------------------------------------------------------------
