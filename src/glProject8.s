#include "glConf.h"

 // Point 3D Coordinates
_PointX:		.dsb 2
_PointY:		.dsb 2
_PointZ:		.dsb 2

//unsigned char projOptions=0;
_projOptions    .dsb 1

 // Point 2D Projected Coordinates
_ResX:			.dsb 2			// -128 -> 127
_ResY:			.dsb 2			// -128 -> 127

 // Intermediary Computation
_DeltaX:		.dsb 2
_DeltaY:		.dsb 2
_DeltaZ:		.dsb 2

_Norm:          .dsb 2

_AngleH:        .dsb 1
_AngleV:        .dsb 1

AnglePH         .dsb 1 ; horizontal angle of point from player pov
AnglePV         .dsb 1 ; vertical angle of point from player pov

HAngleOverflow  .dsb 1
VAngleOverflow  .dsb 1



_project_i8o8:
.(
	// save context
	pha

	lda #0
	sta HAngleOverflow
	sta VAngleOverflow

	// DeltaX = CamPosX - PointX
	// Divisor = DeltaX
	sec
	lda _PointX
	sbc _CamPosX
	sta _DeltaX
    sta _tx

	// DeltaY = CamPosY - PointY
	sec
	lda _PointY
	sbc _CamPosY
	sta _DeltaY
    sta _ty

	// AngleH = atan2 (DeltaY, DeltaX)
	jsr _atan2_8
	lda _res
	sta _AngleH

	// Norm = norm (DeltaX, DeltaY)
	jsr _norm_8

	// DeltaZ = CamPosZ - PointZ
	sec
	lda _PointZ
	sbc _CamPosZ
	sta _DeltaZ

	// AngleV = atan2 (DeltaZ, Norm)
	lda _DeltaZ
	sta _ty
	lda _Norm
	sta _tx
	jsr _atan2_8
	lda _res
	sta _AngleV

	// AnglePH = AngleH - CamRotZ
	sec
	lda _AngleH
	sbc _CamRotZ
	sta AnglePH
	bvc project_i8o8_noHAngleOverflow
	lda #$80
	sta HAngleOverflow

project_i8o8_noHAngleOverflow:
	// AnglePV = AngleV - CamRotX
	sec
	lda     _AngleV
	sbc     _CamRotX
	sta     AnglePV
	bvc     project_i8o8_noVAngleOverflow
	lda     #$80
	sta     VAngleOverflow

project_i8o8_noVAngleOverflow:
; #ifndef ANGLEONLY
; #ifdef TEXTDEMO
; 	// Quick Disgusting Hack:  X = (-AnglePH //2 ) + LE / 2
; 	lda AnglePH
; 	cmp #$80
; 	ror
;     ora HAngleOverflow

; 	eor #$FF
; 	sec
; 	adc #$00
; 	clc
;     adc #SCREEN_WIDTH/2
; 	sta _ResX

; 	lda AnglePV
; 	cmp #$80
; 	ror
;     ora VAngleOverflow

; 	eor #$FF
; 	sec
; 	adc #$00
; 	clc
;     adc #SCREEN_HEIGHT/2
; 	sta _ResY
; #else
; 	;; lda AnglePH
; 	;; eor #$FF
; 	;; sec
; 	;; adc #$00
; 	;; asl
; 	;; asl
; 	;; clc
;     ;; adc #120 ; 240/2 = WIDTH/2
; 	;; sta _ResX
; debugici:
; 	// Extend AnglePH on 16 bits
; 	lda #$00
; 	sta _ResX+1
; 	lda AnglePH
; 	sta _ResX
; 	bpl project_i8o8_angHpositiv
; 	lda #$FF
; 	sta _ResX+1
; project_i8o8_angHpositiv:
; 	// Invert AnglePH on 16 bits
; 	sec
; 	lda #$00
; 	sbc _ResX
; 	sta _ResX
; 	lda #$00
; 	sbc _ResX+1
; 	sta _ResX+1
; 	// Multiply by 4
; 	asl _ResX
; 	rol _ResX+1
; 	asl _ResX
; 	rol _ResX+1
; 	// Add offset of screen center
; 	clc
; 	lda _ResX
; 	adc #120
; 	sta _ResX
; 	lda _ResX+1
; 	adc #$00
; 	sta _ResX+1

; 	;; lda AnglePV
; 	;; eor #$FF
; 	;; sec
; 	;; adc #$00
; 	;; asl
; 	;; asl
; 	;; adc #100 ; = 200 /2 SCREEN_HEIGHT/2
; 	;; sta _ResY

; 	// Extend AnglePV on 16 bits
; 	lda #$00
; 	sta _ResY+1
; 	lda AnglePV
; 	sta _ResY
; 	bpl project_i8o8_angVpositiv
; 	lda #$FF
; 	sta _ResY+1
; project_i8o8_angVpositiv:
; 	// Invert AnglePV on 16 bits
; 	sec
; 	lda #$00
; 	sbc _ResY
; 	sta _ResY
; 	lda #$00
; 	sbc _ResY+1
; 	sta _ResY+1
; 	// Multiply by 4
; 	asl _ResY
; 	rol _ResY+1
; 	asl _ResY
; 	rol _ResY+1
; 	// Add offset of screen center
; 	clc
; 	lda _ResY
; 	adc #100
; 	sta _ResY
; 	lda _ResY+1
; 	adc #$00
; 	sta _ResY+1

; #endif
; #else
	lda AnglePH
	sta _ResX
	lda AnglePV
	sta _ResY
; #endif

project_i8o8_done:
	// restore context
	pla
.)
	rts


/*
_project16:
.(
	// save context
	pha

	lda #0
	sta HAngleOverflow
	sta VAngleOverflow

	// DeltaX = CamPosX - PointX
	// Divisor = DeltaX
	sec
	lda _PointX
	sbc _CamPosX
	sta _DeltaX
	lda _PointX+1
	sbc _CamPosX+1
	sta _DeltaX+1

	// DeltaY = CamPosY - PointY
	sec
	lda _PointY
	sbc _CamPosY
	sta _DeltaY
	lda _PointY+1
	sbc _CamPosY+1
	sta _DeltaY+1

	// AngleH = atan2 (DeltaY, DeltaX)
	lda _DeltaY
	sta _ty
	lda _DeltaX
	sta _tx
	jsr _fastatan2 ; _atan2_8
	lda _res
	sta _AngleH

	// Norm = norm (DeltaX, DeltaY)
	jsr _hyperfastnorm; fastnorm ; ultrafastnorm ; ;

	// DeltaZ = CamPosZ - PointZ
	sec
	lda _PointZ
	sbc _CamPosZ
	sta _DeltaZ
	lda _PointZ+1
	sbc _CamPosZ+1
	sta _DeltaZ+1

	// AngleV = atan2 (DeltaZ, Norm)
	lda _DeltaZ
	sta _ty
	lda _Norm
	sta _tx
	jsr _fastatan2 ; _atan2_8
	lda _res
	sta _AngleV

	// AnglePH = AngleH - CamRotZ
	sec
	lda _AngleH
	sbc _CamRotZ
	sta AnglePH
	bvc project_noHAngleOverflow
	lda #$80
	sta HAngleOverflow

project_noHAngleOverflow:
	// AnglePV = AngleV - CamRotX
	sec
	lda _AngleV
	sbc _CamRotX
	sta AnglePV
	bvc project_noVAngleOverflow
	lda #$80
	sta VAngleOverflow

project_noVAngleOverflow:
#ifndef ANGLEONLY
#ifdef TEXTDEMO
	// Quick Disgusting Hack:  X = (-AnglePH //2 ) + LE / 2
	lda AnglePH
	cmp #$80
	ror
    ora HAngleOverflow

	eor #$FF
	sec
	adc #$00
	clc
    adc #SCREEN_WIDTH/2
	sta _ResX

	lda AnglePV
	cmp #$80
	ror
    ora VAngleOverflow

	eor #$FF
	sec
	adc #$00
	clc
    adc #SCREEN_HEIGHT/2
	sta _ResY
#else
	;; lda AnglePH
	;; eor #$FF
	;; sec
	;; adc #$00
	;; asl
	;; asl
	;; clc
    ;; adc #120 ; 240/2 = WIDTH/2
	;; sta _ResX
debugici:
	// Extend AnglePH on 16 bits
	lda #$00
	sta _ResX+1
	lda AnglePH
	sta _ResX
	bpl angHpositiv
	lda #$FF
	sta _ResX+1
angHpositiv:
	// Invert AnglePH on 16 bits
	sec
	lda #$00
	sbc _ResX
	sta _ResX
	lda #$00
	sbc _ResX+1
	sta _ResX+1
	// Multiply by 4
	asl _ResX
	rol _ResX+1
	asl _ResX
	rol _ResX+1
	// Add offset of screen center
	clc
	lda _ResX
	adc #120
	sta _ResX
	lda _ResX+1
	adc #$00
	sta _ResX+1

	;; lda AnglePV
	;; eor #$FF
	;; sec
	;; adc #$00
	;; asl
	;; asl
	;; adc #100 ; = 200 /2 SCREEN_HEIGHT/2
	;; sta _ResY

	// Extend AnglePV on 16 bits
	lda #$00
	sta _ResY+1
	lda AnglePV
	sta _ResY
	bpl angVpositiv
	lda #$FF
	sta _ResY+1
angVpositiv:
	// Invert AnglePV on 16 bits
	sec
	lda #$00
	sbc _ResY
	sta _ResY
	lda #$00
	sbc _ResY+1
	sta _ResY+1
	// Multiply by 4
	asl _ResY
	rol _ResY+1
	asl _ResY
	rol _ResY+1
	// Add offset of screen center
	clc
	lda _ResY
	adc #100
	sta _ResY
	lda _ResY+1
	adc #$00
	sta _ResY+1

#endif
#else
	lda AnglePH
	sta _ResX
	lda AnglePV
	sta _ResY
#endif

prodone:
	// restore context
	pla
.)
	rts
*/


.zero
octant			.dsb 1          ;

.text

_tx				.dsb 1
_ty				.dsb 1
_res			.dsb 1

;https://codebase64.org/doku.php?id=base:8bit_atan2_8-bit_angle
_atan2_8:
.(

    lda _tx
    clc
    bpl Xpositiv
    eor #$ff
    sec
Xpositiv:
    tax
    rol octant

    lda _ty
    clc
    bpl Ypositiv
    eor #$ff
    sec
Ypositiv:
    tay
    rol octant

    sec
    lda log2_tab,x
    sbc log2_tab,y
    bcc *+4
    eor #$ff
    tax

    lda octant
    rol
    and #$07
    tay

    lda atan_tab, x
    eor octant_adjust,y
    sta _res
.)
    rts


.zero

absX            .dsb 1
absY            .dsb 1
tmpufnX         .dsb 1
tmpufnY         .dsb 1

.text
_norm_8:
.(

//  IF DX == 0 THEN
    lda _DeltaX
	bne norm_8_dxNotNull
//    IF DY > 0 THEN
		lda _DeltaY
		bmi norm_8_dyNegativ_01
//      RETURN DY
		sta _Norm
		jmp norm_8_done
norm_8_dyNegativ_01
//    ELSE
//      RETURN -DY
		eor #$FF
		sec
		adc #$00
		sta _Norm
		jmp norm_8_done
norm_8_dxNotNull
//  ELSE IF DX > 0 THEN
	bmi norm_8_dxNegativ_01
//    AX = DX
		sta absX
		jmp norm_8_computeAbsY
norm_8_dxNegativ_01
//  ELSE (DX < 0)
//    AX = -DX
		eor #$FF
		sec
		adc #$00
		sta absX
//  ENDIF
norm_8_computeAbsY
//  IF DY == 0 THEN
	lda _DeltaY
	bne norm_8_dyNotNull
//    RETURN AX
		lda absX
		sta _Norm
		jmp norm_8_done
norm_8_dyNotNull
//  ELSE IF DY > 0 THEN
	bmi norm_8_dyNegativ_02
//    AY = DY
		sta absY
		jmp norm_8_sortAbsVal
norm_8_dyNegativ_02
//  ELSE (DY < 0)
		eor #$FF
		sec
		adc #$00
		sta absY
//    AY = -DY
//  ENDIF
norm_8_sortAbsVal
//  IF AX > AY THEN
	cmp absX
	bcs norm_8_ayOverOrEqualAx
//    TY = AY
		tay
		sta tmpufnY
//    TX = AX
		lda absX
		tax
		sta tmpufnX
		jmp norm_8_approxim
norm_8_ayOverOrEqualAx
//  ELSE
//    TX = AY
		tax
		sta tmpufnX
//    TY = AX
		lda absX
		tay
		sta tmpufnY
//  END
norm_8_approxim
//  IF TY > TX/2 THEN
	lda tmpufnX
	lsr
	cmp tmpufnY
	bcc norm_8_tyLowerOrEqualTxDiv2
	beq norm_8_tyLowerOrEqualTxDiv2
//    RETURN TAB_A[TX] + TAB_B[TY]
		lda tabmult_A,X
		clc
		adc tabmult_B,Y
		sta _Norm
		lda #$00
		adc #$00 ; propagate carry
		sta _Norm+1
		jmp norm_8_done
norm_8_tyLowerOrEqualTxDiv2
//  ELSE (TX/2 <= TY)
//    RETURN TAB_C[TX] + TAB_D[TY]
		lda tabmult_C,X
		clc
		adc tabmult_D,Y
		sta _Norm
		lda #$00
		adc #$00 ; propagate carry
		sta _Norm+1
//  END IF

norm_8_done:
.)
  rts

;;void projectPoint(
;;	signed char x, 
;;	signed char y , 
;;	signed char z, 
;;	unsigned char options, 
;;	signed char *ah, 
;;	signed char *av,
;;	unsigned int *dist,
;;)

_projectPoint
	ldx #6 : lda #0 : jsr enter :

	ldy #0 : lda (ap),y : sta _PointX 
	ldy #2 : lda (ap),y : sta _PointY 
	ldy #4 : lda (ap),y : sta _PointZ 
	ldy #6: lda (ap),y : sta _projOptions 

	jsr _project_i8o8

	ldy #8 : lda (ap),y : sta tmp0 : iny : lda (ap),y : sta tmp0+1 :
	ldy #0 : lda _ResX : sta (tmp0),y :
	ldy #10 : lda (ap),y : sta tmp0 : iny : lda (ap),y : sta tmp0+1 :
	ldy #0 : lda _ResY : sta (tmp0),y :
	ldy #12 : lda (ap),y : sta tmp0 : iny : lda (ap),y : sta tmp0+1 :
	ldy #0 : lda _Norm : sta (tmp0),y : iny : lda #0 : sta (tmp0),y :

	jmp leave :


tabmult_A
	.byt 0, 1, 2, 3, 4, 5, 6, 7,
	.byt 8, 9, 10, 11, 12, 13, 14, 15,
	.byt 16, 17, 18, 19, 20, 21, 22, 23,
	.byt 24, 25, 26, 27, 28, 29, 30, 31,
	.byt 32, 33, 34, 35, 36, 37, 38, 39,
	.byt 40, 41, 42, 43, 44, 45, 46, 47,
	.byt 48, 49, 50, 51, 52, 53, 54, 55,
	.byt 56, 57, 58, 59, 60, 61, 62, 63,
	.byt 64, 65, 66, 67, 68, 69, 70, 71,
	.byt 72, 73, 74, 75, 76, 77, 78, 79,
	.byt 80, 81, 82, 83, 84, 85, 86, 87,
	.byt 88, 89, 90, 90, 91, 92, 93, 94,
	.byt 95, 96, 97, 98, 99, 100, 101, 102,
	.byt 103, 104, 105, 106, 107, 108, 109, 110,
	.byt 111, 112, 113, 114, 115, 116, 117, 118,
	.byt 119, 119, 120, 121, 122, 123, 124, 125
tabmult_B
	.byt 0, 0, 0, 0, 0, 1, 1, 1,
	.byt 1, 1, 1, 1, 2, 2, 2, 2,
	.byt 2, 3, 3, 3, 3, 3, 4, 4,
	.byt 4, 4, 4, 5, 5, 5, 6, 6,
	.byt 6, 6, 7, 7, 7, 7, 8, 8,
	.byt 8, 9, 9, 9, 10, 10, 10, 11,
	.byt 11, 11, 12, 12, 13, 13, 13, 14,
	.byt 14, 15, 15, 15, 16, 16, 17, 17,
	.byt 18, 18, 18, 19, 19, 20, 20, 21,
	.byt 21, 22, 22, 23, 23, 24, 24, 25,
	.byt 25, 26, 26, 27, 27, 28, 29, 29,
	.byt 30, 30, 31, 31, 32, 33, 33, 34,
	.byt 34, 35, 36, 36, 37, 38, 38, 39,
	.byt 39, 40, 41, 41, 42, 43, 44, 44,
	.byt 45, 46, 46, 47, 48, 48, 49, 50,
	.byt 51, 51, 52, 53, 54, 54, 55, 56
tabmult_C
	.byt 0, 0, 2, 3, 4, 5, 5, 6,
	.byt 7, 8, 8, 9, 10, 11, 12, 13,
	.byt 14, 14, 15, 16, 17, 18, 19, 19,
	.byt 20, 21, 22, 23, 24, 24, 25, 26,
	.byt 27, 28, 29, 30, 30, 31, 32, 33,
	.byt 34, 35, 35, 36, 37, 38, 39, 40,
	.byt 40, 41, 42, 43, 44, 44, 45, 46,
	.byt 47, 48, 49, 49, 50, 51, 52, 53,
	.byt 54, 54, 55, 56, 57, 58, 59, 59,
	.byt 60, 61, 62, 63, 63, 64, 65, 66,
	.byt 67, 68, 68, 69, 70, 71, 72, 72,
	.byt 73, 74, 75, 76, 76, 77, 78, 79,
	.byt 80, 80, 81, 82, 83, 84, 85, 85,
	.byt 86, 87, 88, 89, 89, 90, 91, 92,
	.byt 93, 93, 94, 95, 96, 97, 97, 98,
	.byt 99, 100, 101, 101, 102, 103, 104, 105
tabmult_D
	.byt 0, 1, 1, 1, 2, 2, 3, 4,
	.byt 4, 5, 5, 6, 7, 7, 8, 8,
	.byt 9, 9, 10, 10, 11, 11, 12, 13,
	.byt 13, 14, 14, 15, 15, 16, 17, 17,
	.byt 18, 18, 19, 19, 20, 20, 21, 22,
	.byt 22, 23, 23, 24, 24, 25, 26, 26,
	.byt 27, 27, 28, 28, 29, 30, 30, 31,
	.byt 31, 32, 33, 33, 34, 34, 35, 35,
	.byt 36, 37, 37, 38, 38, 39, 40, 40,
	.byt 41, 41, 42, 43, 43, 44, 44, 45,
	.byt 46, 46, 47, 47, 48, 49, 49, 50,
	.byt 50, 51, 52, 52, 53, 53, 54, 55,
	.byt 55, 56, 56, 57, 58, 58, 59, 59,
	.byt 60, 61, 61, 62, 63, 63, 64, 64,
	.byt 65, 66, 66, 67, 68, 68, 69, 69,
	.byt 70, 71, 71, 72, 73, 73, 74, 74


octant_adjust:
    .byt %00111111		;; x+,y+,|x|>|y|
    .byt %00000000		;; x+,y+,|x|<|y|
    .byt %11000000		;; x+,y-,|x|>|y|
    .byt %11111111		;; x+,y-,|x|<|y|
    .byt %01000000		;; x-,y+,|x|>|y|
    .byt %01111111		;; x-,y+,|x|<|y|
    .byt %10111111		;; x-,y-,|x|>|y|
    .byt %10000000		;; x-,y-,|x|<|y|


;;;;;;;; atan(2^(x/32))*128/pi ;;;;;;;;
atan_tab:
    .byt $00,$00,$00,$00,$00,$00,$00,$00
    .byt $00,$00,$00,$00,$00,$00,$00,$00
    .byt $00,$00,$00,$00,$00,$00,$00,$00
    .byt $00,$00,$00,$00,$00,$00,$00,$00
    .byt $00,$00,$00,$00,$00,$00,$00,$00
    .byt $00,$00,$00,$00,$00,$00,$00,$00
    .byt $00,$00,$00,$00,$00,$00,$00,$00
    .byt $00,$00,$00,$00,$00,$00,$00,$00
    .byt $00,$00,$00,$00,$00,$00,$00,$00
    .byt $00,$00,$00,$00,$00,$00,$00,$00
    .byt $00,$00,$00,$00,$00,$01,$01,$01
    .byt $01,$01,$01,$01,$01,$01,$01,$01
    .byt $01,$01,$01,$01,$01,$01,$01,$01
    .byt $01,$01,$01,$01,$01,$01,$01,$01
    .byt $01,$01,$01,$01,$01,$02,$02,$02
    .byt $02,$02,$02,$02,$02,$02,$02,$02
    .byt $02,$02,$02,$02,$02,$02,$02,$02
    .byt $03,$03,$03,$03,$03,$03,$03,$03
    .byt $03,$03,$03,$03,$03,$04,$04,$04
    .byt $04,$04,$04,$04,$04,$04,$04,$04
    .byt $05,$05,$05,$05,$05,$05,$05,$05
    .byt $06,$06,$06,$06,$06,$06,$06,$06
    .byt $07,$07,$07,$07,$07,$07,$08,$08
    .byt $08,$08,$08,$08,$09,$09,$09,$09
    .byt $09,$0a,$0a,$0a,$0a,$0b,$0b,$0b
    .byt $0b,$0c,$0c,$0c,$0c,$0d,$0d,$0d
    .byt $0d,$0e,$0e,$0e,$0e,$0f,$0f,$0f
    .byt $10,$10,$10,$11,$11,$11,$12,$12
    .byt $12,$13,$13,$13,$14,$14,$15,$15
    .byt $15,$16,$16,$17,$17,$17,$18,$18
    .byt $19,$19,$19,$1a,$1a,$1b,$1b,$1c
    .byt $1c,$1c,$1d,$1d,$1e,$1e,$1f,$1f


;;;;;;;; log2(x)*32 ;;;;;;;;
log2_tab:
    .byt $00,$00,$20,$32,$40,$4a,$52,$59
    .byt $60,$65,$6a,$6e,$72,$76,$79,$7d
    .byt $80,$82,$85,$87,$8a,$8c,$8e,$90
    .byt $92,$94,$96,$98,$99,$9b,$9d,$9e
    .byt $a0,$a1,$a2,$a4,$a5,$a6,$a7,$a9
    .byt $aa,$ab,$ac,$ad,$ae,$af,$b0,$b1
    .byt $b2,$b3,$b4,$b5,$b6,$b7,$b8,$b9
    .byt $b9,$ba,$bb,$bc,$bd,$bd,$be,$bf
    .byt $c0,$c0,$c1,$c2,$c2,$c3,$c4,$c4
    .byt $c5,$c6,$c6,$c7,$c7,$c8,$c9,$c9
    .byt $ca,$ca,$cb,$cc,$cc,$cd,$cd,$ce
    .byt $ce,$cf,$cf,$d0,$d0,$d1,$d1,$d2
    .byt $d2,$d3,$d3,$d4,$d4,$d5,$d5,$d5
    .byt $d6,$d6,$d7,$d7,$d8,$d8,$d9,$d9
    .byt $d9,$da,$da,$db,$db,$db,$dc,$dc
    .byt $dd,$dd,$dd,$de,$de,$de,$df,$df
    .byt $df,$e0,$e0,$e1,$e1,$e1,$e2,$e2
    .byt $e2,$e3,$e3,$e3,$e4,$e4,$e4,$e5
    .byt $e5,$e5,$e6,$e6,$e6,$e7,$e7,$e7
    .byt $e7,$e8,$e8,$e8,$e9,$e9,$e9,$ea
    .byt $ea,$ea,$ea,$eb,$eb,$eb,$ec,$ec
    .byt $ec,$ec,$ed,$ed,$ed,$ed,$ee,$ee
    .byt $ee,$ee,$ef,$ef,$ef,$ef,$f0,$f0
    .byt $f0,$f1,$f1,$f1,$f1,$f1,$f2,$f2
    .byt $f2,$f2,$f3,$f3,$f3,$f3,$f4,$f4
    .byt $f4,$f4,$f5,$f5,$f5,$f5,$f5,$f6
    .byt $f6,$f6,$f6,$f7,$f7,$f7,$f7,$f7
    .byt $f8,$f8,$f8,$f8,$f9,$f9,$f9,$f9
    .byt $f9,$fa,$fa,$fa,$fa,$fa,$fb,$fb
    .byt $fb,$fb,$fb,$fc,$fc,$fc,$fc,$fc
    .byt $fd,$fd,$fd,$fd,$fd,$fd,$fe,$fe
    .byt $fe,$fe,$fe,$ff,$ff,$ff,$ff,$ff