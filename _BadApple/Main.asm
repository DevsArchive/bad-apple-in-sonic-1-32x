; ---------------------------------------------------------------------------
; Bad Apple
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
; Initialize
; ---------------------------------------------------------------------------

BadAppleInit:
	lea	SetMapperBank(pc),a0		; Load mapper bank set function
	lea	_SetMapperBank.w,a1
	move.w	#(SetMapperBankEnd-SetMapperBank)/2-1,d0

@Load:
	move.w	(a0)+,(a1)+
	dbf	d0,@Load
	rts

; ---------------------------------------------------------------------------
; Update
; ---------------------------------------------------------------------------

BadAppleUpdate:
	cmpi.l	#"RSET",MARSSYSREG+MARSCOMM0	; Is it time to reset?
	beq.s	@Reset				; If not, branch
	cmpi.l	#"BANK",MARSSYSREG+MARSCOMM0	; Is it time to switch to the next bank?
	bne.s	@CheckPCM			; If not, branch
	
	move.b	_MapAnimBankID.w,d0		; Set animation bank
	moveq	#0,d1
	jsr	_SetMapperBank.w
	addq.b	#1,_MapAnimBankID.w
	
	move.l	#0,MARSSYSREG+MARSCOMM0		; We are done here
	
@CheckPCM:
	cmpi.l	#"SWAP",MARSSYSREG+MARSCOMM4	; Is it time to swap PWM banks?
	bne.s	@End				; If not, branch
	
	move.b	_MapPWMBankID.w,d0		; Set PCM bank
	moveq	#2,d1
	add.b	_MapPWMBankCur.w,d1
	jsr	_SetMapperBank.w
	addq.b	#1,_MapPWMBankID.w
	
	cmpi.b	#BadApplePWMEnd,_MapAnimBankID.w; Are we at the end?
	bcs.s	@SwapPWM			; If not, branch
	move.w	#1,MARSSYSREG+MARSCOMM8		; If so, tell the slave SH-2 to stop
	
@SwapPWM:
	eori.b	#2,_MapPWMBankCur.w
	
	move.l	#0,MARSSYSREG+MARSCOMM4		; We are done here
	
@End:
	rts

@Reset:
	move.b	#1,_MapAnimBankID.w		; Reset bank IDs
	move.b	#BadApplePWM,_MapPWMBankID.w
	clr.b	_MapPWMBankCur.w
	
	moveq	#0,d0				; We are done here
	move.l	d0,MARSSYSREG+MARSCOMM0
	move.l	d0,MARSSYSREG+MARSCOMM4
	rts

; ---------------------------------------------------------------------------
; Set mapper bank
; ---------------------------------------------------------------------------
; PARAMETERS:
;	d0.b - ROM bank ID
;	d1.w - ROM bank section
; ---------------------------------------------------------------------------

SetMapperBank:
	obj	$FFFF9000

_SetMapperBank:
	move.b	#1,MARSSYSREG+MARSRV		; Set RV flag
	lea	$A130F3,a0			; Set bank
	move.b	d0,(a0,d1.w)
	move.b	#0,MARSSYSREG+MARSRV		; Clear RV flag
	rts

_MapAnimBankID:
	dc.b	1				; Animation bank ID
_MapPWMBankID:
	dc.b	BadApplePWM			; PWM bank ID
_MapPWMBankCur:
	dc.b	0				; Current PWM bank
	even

	objend
SetMapperBankEnd:

; ---------------------------------------------------------------------------
