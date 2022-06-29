; ---------------------------------------------------------------------------
; 32X program
; ---------------------------------------------------------------------------

	include	"_32X/SH-2 Definitions.i"

; ---------------------------------------------------------------------------
; Stack locations
; ---------------------------------------------------------------------------

MasterStack	EQU	SDRAM+$40000
SlaveStack	EQU	SDRAM+$3F000

; ---------------------------------------------------------------------------
; Master vector table
; ---------------------------------------------------------------------------

	org	SDRAM

	dc.l	MasterEntry			; Cold start entry
	dc.l	MasterStack			; Cold start stack pointer
	dc.l	MasterEntry			; Hot start entry
	dc.l	MasterStack			; Hot start stack pointer

	dc.l	MasterError			; Illegal instruction
	dc.l	0				; Reserved
	dc.l	MasterError			; Invalid slot instruction
	dc.l	$20100400			; Reserved
	dc.l	$20100420			; Reserved
	dc.l	MasterError			; CPU address error
	dc.l	MasterError			; DMA address error
	dc.l	MasterError			; NMI vector
	dc.l	MasterError			; User break vector
	
	dcb.l	19, 0				; Reserved
	
	dcb.l	32, MasterError			; Trap vectors
	
	dc.l	MasterIRQ			; IRQ1
	dc.l	MasterIRQ			; IRQ2/3
	dc.l	MasterIRQ			; IRQ4/5
	dc.l	MasterIRQ			; PWM interrupt
	dc.l	MasterIRQ			; Command interrupt
	dc.l	MasterIRQ			; H-BLANK interrupt
	dc.l	MasterIRQ			; V-BLANK interrupt
	dc.l	MasterIRQ			; Reset interrupt

; ---------------------------------------------------------------------------
; Master entry point
; ---------------------------------------------------------------------------

MasterEntry:
	mov.l	#MasterStack,r15		; Reset stack pointer
	
	mov.l	#SYSREG,r0			; Get system registers
	ldc	r0,gbr
	
	mov.l	#FRT,r1				; Set up free run timer
	mov	#0,r0
	mov.b	r0,@(TIER,r1)
	mov	#$FFFFFFE2,r0
	mov.b	r0,@(TOCR,r1)
	mov	#0,r0
	mov.b	r0,@(OCRH,r1)
	mov	#1,r0
	mov.b	r0,@(OCRL,r1)
	mov	#0,r0
	mov.b	r0,@(TCR,r1)
	mov	#1,r0
	mov.b	r0,@(TCSR,r1)
	mov	#0,r0
	mov.b	r0,@(FRCL,r1)
	mov.b	r0,@(FRCH,r1)
	
@WaitMD:
	mov.l	@(COMM0,gbr),r0			; Wait for the Genesis to be ready
	cmp/eq	#0,r0
	bf	@WaitMD

	bra	MasterInitEnd
	nop
	
; ---------------------------------------------------------------------------

MasterHotStart:
	mov.l	#MasterStack,r15		; Reset stack pointer
	
	mov.l	#SYSREG,r0			; Get system registers
	ldc	r0,gbr
	
; ---------------------------------------------------------------------------

MasterInitEnd:
	mov.l	#VDPREG,r14			; VDP registers
	
	mov	#$20,r0				; Enable interrupts
	ldc	r0,sr

	mov	#%10000000,r0			; Let us access the VDP
	mov.b	r0,@(ADAPTER,gbr)

; ---------------------------------------------------------------------------

MasterRestart:
	mov	#0,r0				; Reset frame counters
	mov.l	#frameCount,r1
	mov.l	r0,@r1
	mov.l	#packetFrames,r1
	mov.l	r0,@r1

; ---------------------------------------------------------------------------

MasterLoop:
@WaitVBlankOver:
	mov.b	@(VDPSTAT,r14),r0		; Wait for V-BLANK to be over
	tst	#$80,r0
	bf	@WaitVBlankOver

	mov.l	#frameCount,r1			; Get frame count
	mov.l	@r1,r0

	mov.l	#BitMasks,r1			; Get bit mask
	and	#$F,r0
	add	r0,r1
	mov.b	@r1,r2
	
	cmp/eq	#0,r0				; Is this the first frame in a packet?
	bf	@NoNewPacket			; If not, branch
	
; ---------------------------------------------------------------------------

	mov.l	#packetFrames,r1		; Get packet frames left
	mov.l	@r1,r0
	cmp/eq	#0,r0
	bf	@LoadFrame			; If there are some left, branch

	mov.l	#"BANK",r0			; Request next bank
	mov.l	r0,@(COMM0,gbr)

@WaitBank:
	mov.l	@(COMM0,gbr),r0
	cmp/eq	#0,r0
	bf	@WaitBank
	
	mov.l	#CARTRIDGE+$80000,r3		; Reset and set packet frames
	mov.w	@r3+,r0
	mov.l	#packetFrames,r1
	mov.l	r0,@r1
	mov.l	#cartPtr,r1
	mov.l	r3,@r1

; ---------------------------------------------------------------------------

@LoadFrame:
	mov.l	#cartPtr,r0			; Copy packet graphics
	mov.l	@r0,r1
	mov	#FRAMEBUF,r3
	mov.w	@r1+,r0
	
	cmp/eq	#-1,r0				; Is it time to restart the animation?
	bf	@Continue			; If not, branch
	
	mov.l	#"RSET",r0			; Reset
	mov.l	r0,@(COMM0,gbr)

@WaitReset:
	mov.l	@(COMM0,gbr),r0
	cmp/eq	#0,r0
	bf	@WaitReset
	
	mov	#1,r0				; Tell slave SH-2 to restart
	mov.w	r0,@(COMM8,gbr)
	mov.w	r0,@(COMMA,gbr)

@WaitSlave:
	mov.w	@(COMM8,gbr),r0
	cmp/eq	#0,r0
	bf	@WaitSlave

	bra	MasterRestart			; Loop
	nop

; ---------------------------------------------------------------------------

@Continue:
	shlr	r0				; Copy frame data
	
@Copy:
	mov.w	@r1+,r4
	mov.w	r4,@r3
	add	#2,r3
	dt	r0
	bf	@Copy
	
	mov.l	#cartPtr,r0			; Update cartridge pointer
	mov.l	r1,@r0

	bsr	MasterUpdatePal			; Update palette
	nop
	
	mov	#%00000011,r0			; Set bitmap mode
	mov.b	r0,@(BMPMODE,r14)
	
	mov.b	@(FRAMECTRL,r14),r0		; Swap frame buffer
	not	r0,r1
	mov	r1,r0
	mov.b	r0,@(FRAMECTRL,r14)
	
	mov.l	#packetFrames,r1		; Decrement packet frames left
	mov.l	@r1,r0
	dt	r0
	mov.l	r0,@r1
	
	bra	MasterLoop			; Loop
	nop

; ---------------------------------------------------------------------------

@NoNewPacket:
	bsr	MasterUpdatePal			; Update palette
	nop
	
	bra	MasterLoop			; Loop
	nop

; ---------------------------------------------------------------------------
; Update palette
; ---------------------------------------------------------------------------

MasterUpdatePal:
@WaitVBlank:
	mov.b	@(VDPSTAT,r14),r0		; Wait for V-BLANK
	tst	#$80,r0
	bt	@WaitVBlank
	
	mov.l	#PALETTE,r1			; Update palette according to frame
	mov	#256-1,r0
	
@SetPalLoop:
	mov.w	#$7FFF,r3
	tst	r2,r0
	bt	@SetColor
	mov.w	#$8000,r3

@SetColor:
	mov.w	r3,@r1
	add	#2,r1
	
	dt	r0
	cmp/eq	#-1,r0
	bf	@SetPalLoop
	
	mov.l	#frameCount,r1			; Increment frame count
	mov.l	@r1,r0
	add	#1,r0
	mov.l	r0,@r1

	rts
	nop

; ---------------------------------------------------------------------------
; Data
; ---------------------------------------------------------------------------

	lits
	algn	4
	
; Frame count
frameCount:
	dc.l	0
	
; Packet frames remaining
packetFrames:
	dc.l	0
	
; Cartridge data pointer
cartPtr:
	dc.l	0

; Bit masks
BitMasks:
	dc.b	$01, $01, $02, $02, $04, $04, $08, $08
	dc.b	$10, $10, $20, $20, $40, $40, $80, $80

; ---------------------------------------------------------------------------
; Master error handler
; ---------------------------------------------------------------------------

MasterError:
	bra	MasterError
	nop

; ---------------------------------------------------------------------------
; Master IRQ handler
; ---------------------------------------------------------------------------

MasterIRQ:
	mov.l	r0,@-r15			; Save registers
	mov.l	r1,@-r15
	mov.l	r2,@-r15
	mov.l	r3,@-r15
	mov.l	r14,@-r15
	stc.l	gbr,@-r15
	sts.l	pr,@-r15
	
	mov.l	#SYSREG,r0			; Get system registers
	ldc	r0,gbr
	
	stc	sr,r0				; Get IRQ level
	shlr2	r0
	shlr	r0
	and	#7<<2,r0
	xor	#7<<2,r0
	mov	r0,r2
	shlr	r0
	mov	r0,r3
	
	mov.l	#@IRQTable,r0			; Get IRQ handler
	add	r2,r0
	mov.l	@r0,r2
	
	mov.l	#$F0,r0				; Mask off IRQs
	ldc	r0,sr
	
	mov.l	#FRT,r1				; Toggle FRT bit for future IRQs
	mov.b	@(TOCR,r1),r0
	xor	#2,r0
	mov.b	r0,@(TOCR,r1)
	
	mov	r3,r0				; Check IRQ level
	mov	#5<<1,r1
	cmp/ge	r1,r0
	bt	@IRQDone			; If it's too low, branch
	
	mov.l	#VRESINTCLR+SYSREG,r1		; Clear IRQ
	add	r1,r0
	mov.w	r0,@r0
	nop
	nop
	nop
	
	jsr	@r2				; Handle IRQ
	nop

@IRQDone:
	lds.l	@r15+,pr			; Restore registers
	ldc.l	@r15+,gbr
	mov.l	@r15+,r14
	mov.l	@r15+,r3
	mov.l	@r15+,r2
	mov.l	@r15+,r1
	mov.l	@r15+,r0
	
	rte
	nop

	lits
	
; ---------------------------------------------------------------------------

@IRQTable:
	dc.l	MasterVRESInt			; VRES interrupt
	dc.l	MasterBlankInt			; V-BLANK interrupt
	dc.l	MasterBlankInt			; H-BLANK interrupt
	dc.l	MasterBlankInt			; CMD interrupt
	dc.l	MasterBlankInt			; PWM interrupt

; ---------------------------------------------------------------------------
; Master VRES interrupt
; ---------------------------------------------------------------------------

MasterVRESInt:
	mov.l	#MasterStack,r15		; Reset stack pointer

	mov.w	#$F0,r0				; Set return SR
	mov.w	r0,@-r15
	mov.l	#MasterHotStart,r0		; Set return address
	mov.l	r0,@-r15
	
	mov.l	#DMAOPER,r1			; Disable DMA
	mov	#0,r0
	mov.l	r0,@r1
	mov.l	#DMACTRL0,r1
	mov.l	r0,@r1
	mov.l	#$44E0,r0
	mov.l	r0,@r1

	rte
	nop
	
	lits

; ---------------------------------------------------------------------------
; Blank interrupt
; ---------------------------------------------------------------------------

MasterBlankInt:
	rts
	nop

; ---------------------------------------------------------------------------
; Slave vector table
; ---------------------------------------------------------------------------
	
	algn	$100
	dc.l	SlaveEntry			; Cold start entry
	dc.l	SlaveStack			; Cold start stack pointer
	dc.l	SlaveEntry			; Hot start entry
	dc.l	SlaveStack			; Hot start stack pointer

	dc.l	SlaveError			; Illegal instruction
	dc.l	0				; Reserved
	dc.l	SlaveError			; Invalid slot instruction
	dc.l	$20100400			; Reserved
	dc.l	$20100420			; Reserved
	dc.l	SlaveError			; CPU address error
	dc.l	SlaveError			; DMA address error
	dc.l	SlaveError			; NMI vector
	dc.l	SlaveError			; User break vector
	
	dcb.l	19, 0				; Reserved
	
	dcb.l	32, SlaveError			; Trap vectors
	
	dc.l	SlaveIRQ			; IRQ1
	dc.l	SlaveIRQ			; IRQ2/3
	dc.l	SlaveIRQ			; IRQ4/5
	dc.l	SlaveIRQ			; PWM interrupt
	dc.l	SlaveIRQ			; Command interrupt
	dc.l	SlaveIRQ			; H-BLANK interrupt
	dc.l	SlaveIRQ			; V-BLANK interrupt
	dc.l	SlaveIRQ			; Reset interrupt

; ---------------------------------------------------------------------------
; Slave entry point
; ---------------------------------------------------------------------------

SlaveEntry:
	mov.l	#SlaveStack,r15			; Reset stack pointer
	
	mov.l	#SYSREG,r0			; Get system registers
	ldc	r0,gbr
	
	mov.l	#FRT,r1				; Set up free run timer
	mov	#0,r0
	mov.b	r0,@(TIER,r1)
	mov	#$FFFFFFE2,r0
	mov.b	r0,@(TOCR,r1)
	mov	#0,r0
	mov.b	r0,@(OCRH,r1)
	mov	#1,r0
	mov.b	r0,@(OCRL,r1)
	mov	#0,r0
	mov.b	r0,@(TCR,r1)
	mov	#1,r0
	mov.b	r0,@(TCSR,r1)
	mov	#0,r0
	mov.b	r0,@(FRCL,r1)
	mov.b	r0,@(FRCH,r1)
	
@WaitMD:
	mov.l	@(COMM4,gbr),r0			; Wait for the Genesis to be ready
	cmp/eq	#0,r0
	bf	@WaitMD

	bra	SlaveInitEnd
	nop
	
; ---------------------------------------------------------------------------

SlaveHotStart:
	mov.l	#SlaveStack,r15			; Reset stack pointer
	
	mov.l	#SYSREG,r0			; Get system registers
	ldc	r0,gbr
	
; ---------------------------------------------------------------------------

SlaveInitEnd:
	mov	#1,r0				; Set PWM stop flag
	mov.w	r0,@(COMM8,gbr)
	
	mov	#$20,r0				; Enable interrupts
	ldc	r0,sr
	
	mov	#1,r0				; Enable PWM IRQ
	mov.b	r0,@(INTMASK,gbr)
	
	mov.w	r0,@(PWMINTCLR,gbr)		; Clear PWM IRQ
	mov.w	r0,@(PWMINTCLR,gbr)

	mov.w	#720,r0				; Set PWM cycle
	mov.w	r0,@(PWMCYCLE,gbr)
	
	mov.w	#$185,r0			; Set PWM control and timer
	mov.w	r0,@(PWMTIMER,gbr)
	
	mov	#1,r0				; Fill mono PWM FIFO
	mov.w	r0,@(PWMMONO,gbr)
	mov.w	r0,@(PWMMONO,gbr)
	mov.w	r0,@(PWMMONO,gbr)
	
; ---------------------------------------------------------------------------

SlaveRestart:
@WaitFIFO:
	mov.b	@(PWMMONO,gbr),r0		; Is the PWM FIFO empty?
	tst	#$40,r0
	bt	@WaitFIFO			; If not, branch
	
	mov.l	#PWMDataPtr,r1			; Reset PWM data pointer
	mov.l	#CARTRIDGE+$100000,r0
	mov.l	r0,@r1
	
	mov.l	#"SWAP",r0			; Tell Genesis to swap PWM banks
	mov.l	r0,@(COMM4,gbr)
	
@WaitSwap:
	mov.l	@(COMM4,gbr),r0
	cmp/eq	#0,r0
	bf	@WaitSwap
	
	mov	#0,r0				; Clear stop and restart flags
	mov.l	r0,@(COMM8,gbr)

; ---------------------------------------------------------------------------

SlaveLoop:
	mov.w	@(COMMA,gbr),r0			; Should we restart?
	cmp/eq	#0,r0
	bt	SlaveLoop			; If not, loop

	bra	SlaveRestart			; restart
	nop

	lits

; ---------------------------------------------------------------------------
; Slave error handler
; ---------------------------------------------------------------------------

SlaveError:
	bra	SlaveError
	nop

; ---------------------------------------------------------------------------
; Slave IRQ handler
; ---------------------------------------------------------------------------

SlaveIRQ:
	mov.l	r0,@-r15			; Save registers
	mov.l	r1,@-r15
	mov.l	r2,@-r15
	mov.l	r3,@-r15
	mov.l	r14,@-r15
	stc.l	gbr,@-r15
	sts.l	pr,@-r15
	
	mov.l	#SYSREG,r0			; Get system registers
	ldc	r0,gbr
	
	stc	sr,r0				; Get IRQ level
	shlr2	r0
	shlr	r0
	and	#7<<2,r0
	xor	#7<<2,r0
	mov	r0,r2
	shlr	r0
	mov	r0,r3
	
	mov.l	#@IRQTable,r0			; Get IRQ handler
	add	r2,r0
	mov.l	@r0,r2
	
	mov.l	#$F0,r0				; Mask off IRQs
	ldc	r0,sr
	
	mov.l	#FRT,r1				; Toggle FRT bit for future IRQs
	mov.b	@(TOCR,r1),r0
	xor	#2,r0
	mov.b	r0,@(TOCR,r1)
	
	mov	r3,r0				; Check IRQ level
	mov	#5<<1,r1
	cmp/ge	r1,r0
	bt	@IRQDone			; If it's too low, branch
	
	mov.l	#VRESINTCLR+SYSREG,r1		; Clear IRQ
	add	r1,r0
	mov.w	r0,@r0
	nop
	nop
	nop
	
	jsr	@r2				; Handle IRQ
	nop

@IRQDone:
	lds.l	@r15+,pr			; Restore registers
	ldc.l	@r15+,gbr
	mov.l	@r15+,r14
	mov.l	@r15+,r3
	mov.l	@r15+,r2
	mov.l	@r15+,r1
	mov.l	@r15+,r0
	
	rte
	nop

	lits
	
; ---------------------------------------------------------------------------

@IRQTable:
	dc.l	SlaveVRESInt			; VRES interrupt
	dc.l	SlaveBlankInt			; V-BLANK interrupt
	dc.l	SlaveBlankInt			; H-BLANK interrupt
	dc.l	SlaveBlankInt			; CMD interrupt
	dc.l	SlavePWMInt			; PWM interrupt

; ---------------------------------------------------------------------------
; Slave VRES interrupt
; ---------------------------------------------------------------------------

SlaveVRESInt:
	mov.l	#SlaveStack,r15			; Reset stack pointer

	mov.w	#$F0,r0				; Set return SR
	mov.w	r0,@-r15
	mov.l	#SlaveHotStart,r0		; Set return address
	mov.l	r0,@-r15
	
	mov.l	#DMAOPER,r1			; Disable DMA
	mov	#0,r0
	mov.l	r0,@r1
	mov.l	#DMACTRL0,r1
	mov.l	r0,@r1
	mov.l	#$44E0,r0
	mov.l	r0,@r1

	rte
	nop
	
	lits

; ---------------------------------------------------------------------------
; Blank interrupt
; ---------------------------------------------------------------------------

SlaveBlankInt:
	rts
	nop

; ---------------------------------------------------------------------------
; PWM interrupt
; ---------------------------------------------------------------------------

SlavePWMInt:
	mov.b	@(PWMMONO,gbr),r0		; Is the PWM FIFO full?
	tst	#$80,r0
	bf	@Exit				; If so, branch
	
@CopyData:
	mov.w	@(COMM8,gbr),r0			; Should we stop?
	cmp/eq	#0,r0
	bf	@Exit				; If so, loop
	
	mov.l	#PWMDataPtr,r2			; Read sample and advance
	mov.l	@r2,r1
	mov.b	@r1,r3
	extu.b	r3,r3
	shll	r3
	add	#1,r1
	
	mov.l	#CARTRIDGE+$178000,r0		; Check if about halfway through
	cmp/eq	r0,r1
	bt	@SwapBanks			; If so, branch
	mov.l	#CARTRIDGE+$1F8000,r0		; Check if near the end
	cmp/eq	r0,r1
	bt	@SwapBanks			; If so, branch
	mov.l	#CARTRIDGE+$200000,r0		; Check at the end
	cmp/ge	r0,r1
	bf	@SetSample			; If so, branch
	mov.l	#CARTRIDGE+$100000,r1		; Wrap back to the start
	bra	@SetSample
	nop
	
@SwapBanks:
	mov.l	#"SWAP",r0			; Tell Genesis to swap PWM banks
	mov.l	r0,@(COMM4,gbr)

@SetSample:
	mov.l	r1,@r2				; Update pointer
	mov	r3,r0				; Set sample
	mov.w	r0,@(PWMMONO,gbr)
	
	mov.b	@(PWMMONO,gbr),r0		; Is the PWM FIFO full?
	tst	#$80,r0
	bt	@CopyData			; If not, copy more data

@Exit:
	rts
	nop

; ---------------------------------------------------------------------------

	lits
	algn	4

PWMDataPtr:
	dc.l	0

; ---------------------------------------------------------------------------

	objend

; ---------------------------------------------------------------------------
