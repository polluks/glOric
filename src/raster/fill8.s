#include "config.h"

.zero

_A1X .byt 0
_A1Y .byt 0
_A1destX .byt 0
_A1destY .byt 0
_A1dX .byt 0
_A1dY .byt 0
_A1err .byt 0
_A1sX .byt 0
_A1sY .byt 0
_A1arrived .byt 0

_A2X .byt 0
_A2Y .byt 0
_A2destX .byt 0
_A2destY .byt 0
_A2dX .byt 0
_A2dY .byt 0
_A2err .byt 0
_A2sX .byt 0
_A2sY .byt 0
_A2arrived .byt 0

.text


_P1X .byt 0
_P1Y .byt 0
_P2X .byt 0
_P2Y .byt 0
_P3X .byt 0
_P3Y .byt 0

_P1AH .byt 0
_P1AV .byt 0
_P2AH .byt 0
_P2AV .byt 0
_P3AH .byt 0
_P3AV .byt 0


_pDepX  .byt 0
_pDepY  .byt 0
_pArr1X .byt 0
_pArr1Y .byt 0
_pArr2X .byt 0
_pArr2Y .byt 0

_distface .byt 0
_distseg .byt 0
_distpoint .byt 0
_ch2disp .byt 0

/*
void A1stepY(){
	signed char  nxtY, e2;
	nxtY = A1Y+A1sY;
	printf ("nxtY = %d\n", nxtY);
	e2 = (A1err < 0) ? (
			((A1err & 0x40) == 0)?(
				0x80
			):(
				A1err << 1
			)
		):(
			((A1err & 0x40) != 0)?(
				0x7F
			):(
				A1err << 1
			)
		);
	printf ("e2 = %d\n", e2);
	while ((A1arrived == 0) && ((e2>A1dX) || (A1Y!=nxtY))){
		if (e2 >= A1dY){
			A1err += A1dY;
			printf ("A1err = %d\n", A1err);
			A1X += A1sX;
			printf ("A1X = %d\n", A1X);
		}
		if (e2 <= A1dX){
			A1err += A1dX;
			printf ("A1err = %d\n", A1err);
			A1Y += A1sY;
			printf ("A1Y = %d\n", A1Y);
		}
		A1arrived=((A1X == A1destX) && ( A1Y == A1destY))?1:0;
		e2 = (A1err < 0) ? (
				((A1err & 0x40) == 0)?(
					0x80
				):(
					A1err << 1
				)
			):(
				((A1err & 0x40) != 0)?(
					0x7F
				):(
					A1err << 1
				)
			);
		printf ("e2 = %d\n", e2);

		}
}
*/

#ifdef USE_ASM_BRESFILL
_A1stepY
.(
	// save context
    pha
	lda reg0: pha: lda reg1 : pha 

	;; nxtY = A1Y+A1sY;
	clc
	lda _A1Y
	adc _A1sY
	sta reg1
	
	;; e2 = A1err << 1; // 2*A1err;
	lda _A1err
	bpl A1stepY_errpositiv_01
	asl
	bmi A1stepY_errdone_01
	lda #$80
	jmp A1stepY_errdone_01
	
A1stepY_errpositiv_01:	
	asl
	bpl A1stepY_errdone_01
	lda #$7F
A1stepY_errdone_01:	
	sta reg0
	
	;; while ((A1arrived == 0) && ((e2>A1dX) || (A1Y!=nxtY))){
A1stepY_loop:
	lda _A1arrived ;; (A1arrived == 0)
	beq A1stepY_notarrived
	jmp A1stepYdone

A1stepY_notarrived:	
	lda _A1dX 		;; (e2>A1dX)
    sec
	sbc reg0
    bvc *+4
    eor #$80
	bmi A1stepY_doloop

	lda reg1 		;; (A1Y!=nxtY)
	cmp _A1Y
	bne A1stepY_doloop
	
	jmp A1stepYdone
A1stepY_doloop:
	
		;; if (e2 >= A1dY){
		lda reg0 ; e2
        sec
        sbc _A1dY
        bvc *+4
        eor #$80
		bmi A1stepY_A1Xdone
		;; 	A1err += A1dY;
			clc
			lda _A1err
			adc _A1dY
			bvc debug_moi_la
erroverflow:
			jmp A1stepYdone
debug_moi_la:
			sta _A1err
		;; 	A1X += A1sX;
			clc
			lda _A1X
			adc _A1sX
			sta _A1X
		;; }
A1stepY_A1Xdone:
		;; if (e2 <= A1dX){
		lda _A1dX
        sec
		sbc reg0
        bvc *+4
        eor #$80
		bmi A1stepY_A1Ydone
		;; 	A1err += A1dX;
			clc
			lda _A1err
			adc _A1dX
			sta _A1err
		;; 	A1Y += A1sY; // Optim:  substraction by dec _A1Y
			dec _A1Y
			;clc
			;lda _A1Y
			;adc _A1sY
			;sta _A1Y
			
		;; }
A1stepY_A1Ydone:
		;; A1arrived=((A1X == A1destX) && ( A1Y == A1destY))?1:0;
		lda #0
		sta _A1arrived
		
		lda _A1X
		cmp _A1destX
		bne A1stepY_computeE2
		
		lda _A1Y
		cmp _A1destY
		bne A1stepY_computeE2
	
		lda #1
		sta _A1arrived
A1stepY_computeE2:
		;; e2 = A1err << 1; // 2*A1err;
		lda _A1err
		bpl A1stepY_errpositiv_02
		asl
		bmi A1stepY_errdone_02
		lda #$80
		jmp A1stepY_errdone_02
		
A1stepY_errpositiv_02:	
		asl
		bpl A1stepY_errdone_02
		lda #$7F
A1stepY_errdone_02:	
		sta reg0
	
	jmp A1stepY_loop
A1stepYdone:	

	// restore context
	pla: sta reg1: pla: sta reg0
	pla

.)
	rts
#endif


/*
void A2stepY(){
	signed char  nxtY, e2;
	nxtY = A2Y+A2sY	;
	e2 = (A2err < 0) ? (
			((A2err & 0x40) == 0)?(
				0x80
			):(
				A2err << 1
			)
		):(
			((A2err & 0x40) != 0)?(
				0x7F
			):(
				A2err << 1
			)
		);
	while ((A2arrived == 0) && ((e2>A2dX) || (A2Y!=nxtY))){
		if (e2 >= A2dY){
			A2err += A2dY;
			A2X += A2sX;
		}
		if (e2 <= A2dX){
			A2err += A2dX;
			A2Y += A2sY;
		}
		A2arrived=((A2X == A2destX) && ( A2Y == A2destY))?1:0;
		e2 = (A2err < 0) ? (
				((A2err & 0x40) == 0)?(
					0x80
				):(
					A2err << 1
				)
			):(
				((A2err & 0x40) != 0)?(
					0x7F
				):(
					A2err << 1
				)
			);
	}
}
*/
	
#ifdef USE_ASM_BRESFILL
_A2stepY
.(
	// save context
    pha
	lda reg0: pha: lda reg1 : pha 

	;; nxtY = A2Y+A2sY;
	clc
	lda _A2Y
	adc _A2sY
	sta reg1
	
	;; e2 = A2err << 1; // 2*A2err;
	lda _A2err
	bpl A2stepY_errpositiv_01
	asl
	bmi A2stepY_errdone_01
	lda #$80
	jmp A2stepY_errdone_01
	
A2stepY_errpositiv_01:	
	asl
	bpl A2stepY_errdone_01
	lda #$7F
A2stepY_errdone_01:	
	sta reg0
	
	;; while ((A2arrived == 0) && ((e2>A2dX) || (A2Y!=nxtY))){
A2stepY_loop:
	lda _A2arrived ;; (A2arrived == 0)
	beq A2stepY_notarrived
	jmp A2stepYdone

A2stepY_notarrived:	
	lda _A2dX 		;; (e2>A2dX)
    sec
    sbc reg0
    bvc *+4
    eor #$80
	bmi A2stepY_doloop

	lda reg1 		;; (A2Y!=nxtY)
	cmp _A2Y
	bne A2stepY_doloop
	
	jmp A2stepYdone
A2stepY_doloop:
	
		;; if (e2 >= A2dY){
		lda reg0 ; e2
        sec
        sbc _A2dY
        bvc *+4
        eor #$80
		bmi A2stepY_A2Xdone
		;; 	A2err += A2dY;
			clc
			lda _A2err
			adc _A2dY
			sta _A2err
		;; 	A2X += A2sX;
			clc
			lda _A2X
			adc _A2sX
			sta _A2X
		;; }
A2stepY_A2Xdone:
		;; if (e2 <= A2dX){
		lda _A2dX
        sec
        sbc reg0
        bvc *+4
        eor #$80
		bmi A2stepY_A2Ydone
		;; 	A2err += A2dX;
			clc
			lda _A2err
			adc _A2dX
			sta _A2err
		;; 	A2Y += A2sY; // // Optim:  substraction dec _A2Y
			dec _A2Y
			;clc
			;lda _A2Y
			;adc _A2sY
			;sta _A2Y
			
		;; }
A2stepY_A2Ydone:
		;; A2arrived=((A2X == A2destX) && ( A2Y == A2destY))?1:0;
		lda #0
		sta _A2arrived
		
		lda _A2X
		cmp _A2destX
		bne A2stepY_computeE2
		
		lda _A2Y
		cmp _A2destY
		bne A2stepY_computeE2
	
		lda #1
		sta _A2arrived
A2stepY_computeE2:
		;; e2 = A2err << 1; // 2*A2err;
		lda _A2err
		bpl A2stepY_errpositiv_02
		asl
		bmi A2stepY_errdone_02
		lda #$80
		jmp A2stepY_errdone_02
		
A2stepY_errpositiv_02:	
		asl
		bpl A2stepY_errdone_02
		lda #$7F
A2stepY_errdone_02:	
		sta reg0
	
	jmp A2stepY_loop
A2stepYdone:	

	// restore context
	pla: sta reg1: pla: sta reg0
	pla

.)
	rts
#endif //  USE_ASM_BRESFILL

#ifdef USE_ASM_HFILL


// void hfill() {
_hfill:
.(

	// save context
    pha:txa:pha:tya:pha
	lda reg0: pha ;; p1x 
    lda reg1: pha ;; p2x
	lda reg2: pha ;; pY
    lda reg3: pha ;; dist
    lda reg4: pha ;; char2disp
	lda tmp0: pha ;; dx
	lda tmp1: pha ;; fx
	lda tmp2: pha ;; nbpoints
	lda tmp3: pha: lda tmp3+1: pha  ;; save stack pointer

//     signed char dx, fx;
//     signed char nbpoints;

//     //printf ("p1x=%d p2x=%d py=%d dist= %d, char2disp= %d\n", p1x, p2x, dist,  dist, char2disp);get();

//     if ((A1Y <= 0) || (A1Y >= SCREEN_HEIGHT)) return;
	lda _A1Y				; Access Y coordinate
    bpl *+5
    jmp hfill_done
#ifdef USE_COLOR
    cmp #SCREEN_HEIGHT-NB_LESS_LINES_4_COLOR
#else
    cmp #SCREEN_HEIGHT
#endif
    bcc *+5
	jmp hfill_done
    sta reg2 ; A1Y

//     if (A1X > A2X) {
	lda _A1X				
	sta reg0
	sec
	sbc _A2X				; signed cmp to p2x
	bvc *+4
	eor #$80
	bmi hfill_A2xOverOrEqualA1x
#ifdef USE_COLOR
//		dx = max(2, A2X);
		lda _A2X
		sec
		sbc #COLUMN_OF_COLOR_ATTRIBUTE
		bvc *+4
		eor #$80
		bmi hfill_A2xLowerThan3
		lda _A2X
		jmp hfill_A2xPositiv
hfill_A2xLowerThan3:
		lda #COLUMN_OF_COLOR_ATTRIBUTE
#else
//      dx = max(0, A2X);
		lda _A2X
		bpl hfill_A2xPositiv
		lda #0
#endif
hfill_A2xPositiv:
		sta tmp0 ; dx
//         fx = min(A1X, SCREEN_WIDTH - 1);
		lda _A1X
		sta tmp1
		sec
		sbc #SCREEN_WIDTH - 1
		bvc *+4
		eor #$80
		bmi hfill_A1xOverScreenWidth
		lda #SCREEN_WIDTH - 1
		sta tmp1
hfill_A1xOverScreenWidth:
		jmp hfill_computeNbPoints
hfill_A2xOverOrEqualA1x:
//     } else {
#ifdef USE_COLOR
//		dx = max(2, A1X);
		lda _A1X
		sec
		sbc #COLUMN_OF_COLOR_ATTRIBUTE
		bvc *+4
		eor #$80
		bmi hfill_A1xLowerThan3
		lda _A1X
		jmp hfill_A1xPositiv
hfill_A1xLowerThan3:
		lda #COLUMN_OF_COLOR_ATTRIBUTE
#else
//      dx = max(0, A1X);
		lda _A1X
		bpl hfill_A1xPositiv
		lda #0
#endif
hfill_A1xPositiv:
		sta tmp0
//         fx = min(A2X, SCREEN_WIDTH - 1);
		lda _A2X ; p2x
		sta tmp1
		sec
		sbc #SCREEN_WIDTH - 1
		bvc *+4
		eor $80
		bmi hfill_A2xOverScreenWidth
		lda #SCREEN_WIDTH - 1
		sta tmp1
hfill_A2xOverScreenWidth:
//     }
hfill_computeNbPoints:
//     nbpoints = fx - dx;
//     if (nbpoints < 0) return;
	sec
	lda tmp1
	sbc tmp0
	bmi hfill_done
	sta tmp2

//     // printf ("dx=%d py=%d nbpoints=%d dist= %d, char2disp= %d\n", dx, py, nbpoints,  dist, char2disp);get();

// #ifdef USE_ZBUFFER
//     zline(dx, A1Y, nbpoints, distface, ch2disp);
	clc
	lda sp
	sta tmp3
	adc #10
	sta sp
	lda sp+1
	sta tmp3+1
	adc #0
	sta sp+1
	lda tmp0 : ldy #0 : sta (sp),y ;; dx
	lda reg2 : ldy #2 : sta (sp),y ;; py
	lda tmp2 : ldy #4 : sta (sp),y ;; nbpoints
	lda _distface : ldy #6 : sta (sp),y ;; dist
	lda _ch2disp : ldy #8 : sta (sp),y ;; char2disp
	ldy #10 : jsr _zline
	lda tmp3
	sta sp
	lda tmp3+1
	sta sp+1
// #else
//     // TODO : draw a line whit no z-buffer
// #endif
hfill_done:
	// restore context
	pla: sta tmp3+1
	pla: sta tmp3
	pla: sta tmp2
	pla: sta tmp1
	pla: sta tmp0
    pla: sta reg4
	pla: sta reg3
    pla: sta reg2
	pla: sta reg1
    pla: sta reg0
	pla:tay:pla:tax:pla
// }

.)
	rts

#endif // USE_ASM_HFILL

#ifdef USE_ASM_BRESFILL


// void angle2screen() {
_angle2screen:
.(

	// save context
    pha

//     P1X = (SCREEN_WIDTH - P1AH) >> 1;
	sec
	lda #SCREEN_WIDTH
	sbc _P1AH
	cmp #$80
	ror
	sta _P1X
//     P1Y = (SCREEN_HEIGHT - P1AV) >> 1;
	sec
	lda #SCREEN_HEIGHT
	sbc _P1AV
	cmp #$80
	ror
	sta _P1Y
//     P2X = (SCREEN_WIDTH - P2AH) >> 1;
	sec
	lda #SCREEN_WIDTH
	sbc _P2AH
	cmp #$80
	ror
	sta _P2X
//     P2Y = (SCREEN_HEIGHT - P2AV) >> 1;
	sec
	lda #SCREEN_HEIGHT
	sbc _P2AV
	cmp #$80
	ror
	sta _P2Y
//     P3X = (SCREEN_WIDTH - P3AH) >> 1;
	sec
	lda #SCREEN_WIDTH
	sbc _P3AH
	cmp #$80
	ror
	sta _P3X
//     P3Y = (SCREEN_HEIGHT - P3AV) >> 1;
	sec
	lda #SCREEN_HEIGHT
	sbc _P3AV
	cmp #$80
	ror
	sta _P3Y

	// restore context
	pla
// }
.)
	rts

#endif

#ifdef USE_ASM_BRESFILL

;; void prepare_bresrun() {

    ; if (P1Y <= P2Y) {
    ;     if (P2Y <= P3Y) {
    ;         pDepX  = P3X;
    ;         pDepY  = P3Y;
    ;         pArr1X = P2X;
    ;         pArr1Y = P2Y;
    ;         pArr2X = P1X;
    ;         pArr2Y = P1Y;
    ;     } else {
    ;         pDepX = P2X;
    ;         pDepY = P2Y;
    ;         if (P1Y <= P3Y) {
    ;             pArr1X = P3X;
    ;             pArr1Y = P3Y;
    ;             pArr2X = P1X;
    ;             pArr2Y = P1Y;
    ;         } else {
    ;             pArr1X = P1X;
    ;             pArr1Y = P1Y;
    ;             pArr2X = P3X;
    ;             pArr2Y = P3Y;
    ;         }
    ;     }
    ; } else {
    ;     if (P1Y <= P3Y) {
    ;         pDepX  = P3X;
    ;         pDepY  = P3Y;
    ;         pArr1X = P1X;
    ;         pArr1Y = P1Y;
    ;         pArr2X = P2X;
    ;         pArr2Y = P2Y;
    ;     } else {
    ;         pDepX = P1X;
    ;         pDepY = P1Y;
    ;         if (P2Y <= P3Y) {
    ;             pArr1X = P3X;
    ;             pArr1Y = P3Y;
    ;             pArr2X = P2X;
    ;             pArr2Y = P2Y;
    ;         } else {
    ;             pArr1X = P2X;
    ;             pArr1Y = P2Y;
    ;             pArr2X = P3X;
    ;             pArr2Y = P3Y;
    ;         }
    ;     }
    ; }

;;}

_prepare_bresrun:
.(
	lda _P1Y : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _P2Y : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	lda tmp1 : cmp tmp0 : lda tmp1+1 : sbc tmp0+1 : .( : bvc *+4 : eor #$80 : bpl skip : jmp prepare_bresrun_Lbresfill129 :skip : .) : : :
	lda _P2Y : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _P3Y : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	lda tmp1 : cmp tmp0 : lda tmp1+1 : sbc tmp0+1 : .( : bvc *+4 : eor #$80 : bpl skip : jmp prepare_bresrun_Lbresfill131 :skip : .) : : :
	lda _P3X : sta _pDepX :
	lda _P3Y : sta _pDepY :
	lda _P2X : sta _pArr1X :
	lda _P2Y : sta _pArr1Y :
	lda _P1X : sta _pArr2X :
	lda _P1Y : sta _pArr2Y :
	jmp prepare_bresrun_Lbresfill130 :
prepare_bresrun_Lbresfill131
	lda _P2X : sta _pDepX :
	lda _P2Y : sta _pDepY :
	lda _P1Y : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _P3Y : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	lda tmp1 : cmp tmp0 : lda tmp1+1 : sbc tmp0+1 : .( : bvc *+4 : eor #$80 : bpl skip : jmp prepare_bresrun_Lbresfill133 :skip : .) : : :
	lda _P3X : sta _pArr1X :
	lda _P3Y : sta _pArr1Y :
	lda _P1X : sta _pArr2X :
	lda _P1Y : sta _pArr2Y :
	jmp prepare_bresrun_Lbresfill130 :
prepare_bresrun_Lbresfill133
	lda _P1X : sta _pArr1X :
	lda _P1Y : sta _pArr1Y :
	lda _P3X : sta _pArr2X :
	lda _P3Y : sta _pArr2Y :
	jmp prepare_bresrun_Lbresfill130 :
prepare_bresrun_Lbresfill129
	lda _P1Y : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _P3Y : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	lda tmp1 : cmp tmp0 : lda tmp1+1 : sbc tmp0+1 : .( : bvc *+4 : eor #$80 : bpl skip : jmp prepare_bresrun_Lbresfill135 :skip : .) : : :
	lda _P3X : sta _pDepX :
	lda _P3Y : sta _pDepY :
	lda _P1X : sta _pArr1X :
	lda _P1Y : sta _pArr1Y :
	lda _P2X : sta _pArr2X :
	lda _P2Y : sta _pArr2Y :
	jmp prepare_bresrun_Lbresfill136 :
prepare_bresrun_Lbresfill135
	lda _P1X : sta _pDepX :
	lda _P1Y : sta _pDepY :
	lda _P2Y : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _P3Y : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	lda tmp1 : cmp tmp0 : lda tmp1+1 : sbc tmp0+1 : .( : bvc *+4 : eor #$80 : bpl skip : jmp prepare_bresrun_Lbresfill137 :skip : .) : : :
	lda _P3X : sta _pArr1X :
	lda _P3Y : sta _pArr1Y :
	lda _P2X : sta _pArr2X :
	lda _P2Y : sta _pArr2Y :
	jmp prepare_bresrun_Lbresfill138 :
prepare_bresrun_Lbresfill137
	lda _P2X : sta _pArr1X :
	lda _P2Y : sta _pArr1Y :
	lda _P3X : sta _pArr2X :
	lda _P3Y : sta _pArr2Y :
prepare_bresrun_Lbresfill138
prepare_bresrun_Lbresfill136
prepare_bresrun_Lbresfill130
.)
	rts :
#endif



#ifdef USE_ASM_FILL8
_fill8:
.(
	ldx #6 : lda #7 : jsr enter :
	ldy #0 : jsr _prepare_bresrun :
	lda _pDepY : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _pArr1Y : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	lda tmp0 : eor tmp1 : sta tmp : lda tmp0+1 : eor tmp1+1 : ora tmp : bne *+5 : jmp fill8_Lbresfill129 :
	lda _pDepX : sta tmp0 :
	lda tmp0 : sta _A1X :
	lda tmp0 : sta _A2X :
	lda _pDepY : sta tmp0 :
	lda tmp0 : sta _A1Y :
	lda tmp0 : sta _A2Y :
	lda _pArr1X : sta tmp0 :
	lda tmp0 : sta _A1destX :
	lda _pArr1Y : sta tmp0 :
	lda tmp0 : sta _A1destY :
	lda _A1destX : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A1X : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	sec : lda tmp0 : sbc tmp1 : sta tmp0 : lda tmp0+1 : sbc tmp1+1 : sta tmp0+1 :
	lda tmp0 : cmp #<(0) : lda tmp0+1 : sbc #>(0) : bvc *+4 : eor #$80 : bmi *+5 : jmp fill8_Lbresfill132 : :
	lda _A1destX : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A1X : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	sec : lda tmp0 : sbc tmp1 : sta tmp0 : lda tmp0+1 : sbc tmp1+1 : sta tmp0+1 :
	lda #0 : sec : sbc tmp0 : sta tmp0 : lda #0 : sbc tmp0+1 : sta tmp0+1 :
	lda tmp0 : sta reg0 : lda tmp0+1 : sta reg0+1 :
	jmp fill8_Lbresfill133 :
fill8_Lbresfill132
	lda _A1destX : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A1X : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	sec : lda tmp0 : sbc tmp1 : sta tmp0 : lda tmp0+1 : sbc tmp1+1 : sta tmp0+1 :
	lda tmp0 : sta reg0 : lda tmp0+1 : sta reg0+1 :
fill8_Lbresfill133
	lda reg0 : sta tmp0 : lda reg0+1 : sta tmp0+1 :
	lda tmp0 : sta _A1dX :
	lda _A1destY : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A1Y : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	sec : lda tmp0 : sbc tmp1 : sta tmp0 : lda tmp0+1 : sbc tmp1+1 : sta tmp0+1 :
	lda tmp0 : cmp #<(0) : lda tmp0+1 : sbc #>(0) : bvc *+4 : eor #$80 : bmi *+5 : jmp fill8_Lbresfill134 : :
	lda _A1destY : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A1Y : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	sec : lda tmp0 : sbc tmp1 : sta tmp0 : lda tmp0+1 : sbc tmp1+1 : sta tmp0+1 :
	lda #0 : sec : sbc tmp0 : sta tmp0 : lda #0 : sbc tmp0+1 : sta tmp0+1 :
	lda tmp0 : sta reg0 : lda tmp0+1 : sta reg0+1 :
	jmp fill8_Lbresfill135 :
fill8_Lbresfill134
	lda _A1destY : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A1Y : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	sec : lda tmp0 : sbc tmp1 : sta tmp0 : lda tmp0+1 : sbc tmp1+1 : sta tmp0+1 :
	lda tmp0 : sta reg0 : lda tmp0+1 : sta reg0+1 :
fill8_Lbresfill135
	lda reg0 : sta tmp0 : lda reg0+1 : sta tmp0+1 :
	lda #0 : sec : sbc tmp0 : sta tmp0 : lda #0 : sbc tmp0+1 : sta tmp0+1 :
	lda tmp0 : sta _A1dY :
	lda _A1dX : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A1dY : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	clc : lda tmp0 : adc tmp1 : sta tmp0 : lda tmp0+1 : adc tmp1+1 : sta tmp0+1 :
	lda tmp0 : sta _A1err :
	lda _A1err : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda #<(64) : cmp tmp0 : lda #>(64) : sbc tmp0+1 : .( : bvc *+4 : eor #$80 : bpl skip : jmp fill8_Lbresfill138 :skip : .) : : :
	lda tmp0 : cmp #<(-63) : lda tmp0+1 : sbc #>(-63) : bvc *+4 : eor #$80 : bmi *+5 : jmp fill8_Lbresfill136 : :
fill8_Lbresfill138
	jmp leave :
fill8_Lbresfill136
	lda _A1X : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A1destX : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	lda tmp0 : cmp tmp1 : lda tmp0+1 : sbc tmp1+1 : bvc *+4 : eor #$80 : bmi *+5 : jmp fill8_Lbresfill140 : :
	lda #<(1) : sta reg1 : lda #>(1) : sta reg1+1 :
	jmp fill8_Lbresfill141 :
fill8_Lbresfill140
	lda #<(-1) : sta reg1 : lda #>(-1) : sta reg1+1 :
fill8_Lbresfill141
	lda reg1 : sta tmp0 : lda reg1+1 : sta tmp0+1 :
	lda tmp0 : sta _A1sX :
	lda _A1Y : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A1destY : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	lda tmp0 : cmp tmp1 : lda tmp0+1 : sbc tmp1+1 : bvc *+4 : eor #$80 : bmi *+5 : jmp fill8_Lbresfill142 : :
	lda #<(1) : sta reg1 : lda #>(1) : sta reg1+1 :
	jmp fill8_Lbresfill143 :
fill8_Lbresfill142
	lda #<(-1) : sta reg1 : lda #>(-1) : sta reg1+1 :
fill8_Lbresfill143
	lda reg1 : sta tmp0 : lda reg1+1 : sta tmp0+1 :
	lda tmp0 : sta _A1sY :
	lda _A1X : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A1destX : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	lda tmp0 : eor tmp1 : sta tmp : lda tmp0+1 : eor tmp1+1 : ora tmp : beq *+5 : jmp fill8_Lbresfill144 :
	lda _A1Y : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A1destY : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	lda tmp0 : eor tmp1 : sta tmp : lda tmp0+1 : eor tmp1+1 : ora tmp : beq *+5 : jmp fill8_Lbresfill144 :
	lda #<(1) : sta reg1 : lda #>(1) : sta reg1+1 :
	jmp fill8_Lbresfill145 :
fill8_Lbresfill144
	lda #<(0) : sta reg1 : lda #>(0) : sta reg1+1 :
fill8_Lbresfill145
	lda reg1 : sta tmp0 : lda reg1+1 : sta tmp0+1 :
	lda tmp0 : sta _A1arrived :
	lda _pArr2X : sta tmp0 :
	lda tmp0 : sta _A2destX :
	lda _pArr2Y : sta tmp0 :
	lda tmp0 : sta _A2destY :
	lda _A2destX : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A2X : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	sec : lda tmp0 : sbc tmp1 : sta tmp0 : lda tmp0+1 : sbc tmp1+1 : sta tmp0+1 :
	lda tmp0 : cmp #<(0) : lda tmp0+1 : sbc #>(0) : bvc *+4 : eor #$80 : bmi *+5 : jmp fill8_Lbresfill146 : :
	lda _A2destX : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A2X : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	sec : lda tmp0 : sbc tmp1 : sta tmp0 : lda tmp0+1 : sbc tmp1+1 : sta tmp0+1 :
	lda #0 : sec : sbc tmp0 : sta tmp0 : lda #0 : sbc tmp0+1 : sta tmp0+1 :
	lda tmp0 : sta reg1 : lda tmp0+1 : sta reg1+1 :
	jmp fill8_Lbresfill147 :
fill8_Lbresfill146
	lda _A2destX : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A2X : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	sec : lda tmp0 : sbc tmp1 : sta tmp0 : lda tmp0+1 : sbc tmp1+1 : sta tmp0+1 :
	lda tmp0 : sta reg1 : lda tmp0+1 : sta reg1+1 :
fill8_Lbresfill147
	lda reg1 : sta tmp0 : lda reg1+1 : sta tmp0+1 :
	lda tmp0 : sta _A2dX :
	lda _A2destY : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A2Y : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	sec : lda tmp0 : sbc tmp1 : sta tmp0 : lda tmp0+1 : sbc tmp1+1 : sta tmp0+1 :
	lda tmp0 : cmp #<(0) : lda tmp0+1 : sbc #>(0) : bvc *+4 : eor #$80 : bmi *+5 : jmp fill8_Lbresfill148 : :
	lda _A2destY : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A2Y : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	sec : lda tmp0 : sbc tmp1 : sta tmp0 : lda tmp0+1 : sbc tmp1+1 : sta tmp0+1 :
	lda #0 : sec : sbc tmp0 : sta tmp0 : lda #0 : sbc tmp0+1 : sta tmp0+1 :
	lda tmp0 : sta reg1 : lda tmp0+1 : sta reg1+1 :
	jmp fill8_Lbresfill149 :
fill8_Lbresfill148
	lda _A2destY : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A2Y : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	sec : lda tmp0 : sbc tmp1 : sta tmp0 : lda tmp0+1 : sbc tmp1+1 : sta tmp0+1 :
	lda tmp0 : sta reg1 : lda tmp0+1 : sta reg1+1 :
fill8_Lbresfill149
	lda reg1 : sta tmp0 : lda reg1+1 : sta tmp0+1 :
	lda #0 : sec : sbc tmp0 : sta tmp0 : lda #0 : sbc tmp0+1 : sta tmp0+1 :
	lda tmp0 : sta _A2dY :
	lda _A2dX : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A2dY : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	clc : lda tmp0 : adc tmp1 : sta tmp0 : lda tmp0+1 : adc tmp1+1 : sta tmp0+1 :
	lda tmp0 : sta _A2err :
	lda _A2err : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda #<(64) : cmp tmp0 : lda #>(64) : sbc tmp0+1 : .( : bvc *+4 : eor #$80 : bpl skip : jmp fill8_Lbresfill152 :skip : .) : : :
	lda tmp0 : cmp #<(-63) : lda tmp0+1 : sbc #>(-63) : bvc *+4 : eor #$80 : bmi *+5 : jmp fill8_Lbresfill150 : :
fill8_Lbresfill152
	jmp leave :
fill8_Lbresfill150
	lda _A2X : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A2destX : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	lda tmp0 : cmp tmp1 : lda tmp0+1 : sbc tmp1+1 : bvc *+4 : eor #$80 : bmi *+5 : jmp fill8_Lbresfill154 : :
	lda #<(1) : sta reg2 : lda #>(1) : sta reg2+1 :
	jmp fill8_Lbresfill155 :
fill8_Lbresfill154
	lda #<(-1) : sta reg2 : lda #>(-1) : sta reg2+1 :
fill8_Lbresfill155
	lda reg2 : sta tmp0 : lda reg2+1 : sta tmp0+1 :
	lda tmp0 : sta _A2sX :
	lda _A2Y : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A2destY : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	lda tmp0 : cmp tmp1 : lda tmp0+1 : sbc tmp1+1 : bvc *+4 : eor #$80 : bmi *+5 : jmp fill8_Lbresfill156 : :
	lda #<(1) : sta reg2 : lda #>(1) : sta reg2+1 :
	jmp fill8_Lbresfill157 :
fill8_Lbresfill156
	lda #<(-1) : sta reg2 : lda #>(-1) : sta reg2+1 :
fill8_Lbresfill157
	lda reg2 : sta tmp0 : lda reg2+1 : sta tmp0+1 :
	lda tmp0 : sta _A2sY :
	lda _A2X : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A2destX : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	lda tmp0 : eor tmp1 : sta tmp : lda tmp0+1 : eor tmp1+1 : ora tmp : beq *+5 : jmp fill8_Lbresfill158 :
	lda _A2Y : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A2destY : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	lda tmp0 : eor tmp1 : sta tmp : lda tmp0+1 : eor tmp1+1 : ora tmp : beq *+5 : jmp fill8_Lbresfill158 :
	lda #<(1) : sta reg2 : lda #>(1) : sta reg2+1 :
	jmp fill8_Lbresfill159 :
fill8_Lbresfill158
	lda #<(0) : sta reg2 : lda #>(0) : sta reg2+1 :
fill8_Lbresfill159
	lda reg2 : sta tmp0 : lda reg2+1 : sta tmp0+1 :
	lda tmp0 : sta _A2arrived :
	ldy #0 : jsr _hfill :
	jmp fill8_Lbresfill161 :
fill8_Lbresfill160
	ldy #0 : jsr _A1stepY :
	ldy #0 : jsr _A2stepY :
	ldy #0 : jsr _hfill :
fill8_Lbresfill161
	lda _A1arrived : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda tmp0 : ora tmp0+1 : bne *+5 : jmp fill8_Lbresfill160 :
	lda _pArr1X : sta tmp0 :
	lda tmp0 : sta _A1X :
	lda _pArr1Y : sta tmp0 :
	lda tmp0 : sta _A1Y :
	lda _pArr2X : sta tmp0 :
	lda tmp0 : sta _A1destX :
	lda _pArr2Y : sta tmp0 :
	lda tmp0 : sta _A1destY :
	lda _A1destX : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A1X : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	sec : lda tmp0 : sbc tmp1 : sta tmp0 : lda tmp0+1 : sbc tmp1+1 : sta tmp0+1 :
	lda tmp0 : cmp #<(0) : lda tmp0+1 : sbc #>(0) : bvc *+4 : eor #$80 : bmi *+5 : jmp fill8_Lbresfill164 : :
	lda _A1destX : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A1X : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	sec : lda tmp0 : sbc tmp1 : sta tmp0 : lda tmp0+1 : sbc tmp1+1 : sta tmp0+1 :
	lda #0 : sec : sbc tmp0 : sta tmp0 : lda #0 : sbc tmp0+1 : sta tmp0+1 :
	lda tmp0 : sta reg3 : lda tmp0+1 : sta reg3+1 :
	jmp fill8_Lbresfill165 :
fill8_Lbresfill164
	lda _A1destX : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A1X : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	sec : lda tmp0 : sbc tmp1 : sta tmp0 : lda tmp0+1 : sbc tmp1+1 : sta tmp0+1 :
	lda tmp0 : sta reg3 : lda tmp0+1 : sta reg3+1 :
fill8_Lbresfill165
	lda reg3 : sta tmp0 : lda reg3+1 : sta tmp0+1 :
	lda tmp0 : sta _A1dX :
	lda _A1destY : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A1Y : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	sec : lda tmp0 : sbc tmp1 : sta tmp0 : lda tmp0+1 : sbc tmp1+1 : sta tmp0+1 :
	lda tmp0 : cmp #<(0) : lda tmp0+1 : sbc #>(0) : bvc *+4 : eor #$80 : bmi *+5 : jmp fill8_Lbresfill166 : :
	lda _A1destY : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A1Y : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	sec : lda tmp0 : sbc tmp1 : sta tmp0 : lda tmp0+1 : sbc tmp1+1 : sta tmp0+1 :
	lda #0 : sec : sbc tmp0 : sta tmp0 : lda #0 : sbc tmp0+1 : sta tmp0+1 :
	lda tmp0 : sta reg3 : lda tmp0+1 : sta reg3+1 :
	jmp fill8_Lbresfill167 :
fill8_Lbresfill166
	lda _A1destY : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A1Y : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	sec : lda tmp0 : sbc tmp1 : sta tmp0 : lda tmp0+1 : sbc tmp1+1 : sta tmp0+1 :
	lda tmp0 : sta reg3 : lda tmp0+1 : sta reg3+1 :
fill8_Lbresfill167
	lda reg3 : sta tmp0 : lda reg3+1 : sta tmp0+1 :
	lda #0 : sec : sbc tmp0 : sta tmp0 : lda #0 : sbc tmp0+1 : sta tmp0+1 :
	lda tmp0 : sta _A1dY :
	lda _A1dX : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A1dY : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	clc : lda tmp0 : adc tmp1 : sta tmp0 : lda tmp0+1 : adc tmp1+1 : sta tmp0+1 :
	lda tmp0 : sta _A1err :
	lda _A1X : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A1destX : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	lda tmp0 : cmp tmp1 : lda tmp0+1 : sbc tmp1+1 : bvc *+4 : eor #$80 : bmi *+5 : jmp fill8_Lbresfill168 : :
	lda #<(1) : sta reg3 : lda #>(1) : sta reg3+1 :
	jmp fill8_Lbresfill169 :
fill8_Lbresfill168
	lda #<(-1) : sta reg3 : lda #>(-1) : sta reg3+1 :
fill8_Lbresfill169
	lda reg3 : sta tmp0 : lda reg3+1 : sta tmp0+1 :
	lda tmp0 : sta _A1sX :
	lda _A1Y : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A1destY : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	lda tmp0 : cmp tmp1 : lda tmp0+1 : sbc tmp1+1 : bvc *+4 : eor #$80 : bmi *+5 : jmp fill8_Lbresfill170 : :
	lda #<(1) : sta reg3 : lda #>(1) : sta reg3+1 :
	jmp fill8_Lbresfill171 :
fill8_Lbresfill170
	lda #<(-1) : sta reg3 : lda #>(-1) : sta reg3+1 :
fill8_Lbresfill171
	lda reg3 : sta tmp0 : lda reg3+1 : sta tmp0+1 :
	lda tmp0 : sta _A1sY :
	lda _A1X : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A1destX : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	lda tmp0 : eor tmp1 : sta tmp : lda tmp0+1 : eor tmp1+1 : ora tmp : beq *+5 : jmp fill8_Lbresfill172 :
	lda _A1Y : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A1destY : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	lda tmp0 : eor tmp1 : sta tmp : lda tmp0+1 : eor tmp1+1 : ora tmp : beq *+5 : jmp fill8_Lbresfill172 :
	lda #<(1) : sta reg3 : lda #>(1) : sta reg3+1 :
	jmp fill8_Lbresfill173 :
fill8_Lbresfill172
	lda #<(0) : sta reg3 : lda #>(0) : sta reg3+1 :
fill8_Lbresfill173
	lda reg3 : sta tmp0 : lda reg3+1 : sta tmp0+1 :
	lda tmp0 : sta _A1arrived :
	jmp fill8_Lbresfill175 :
fill8_Lbresfill174
	ldy #0 : jsr _A1stepY :
	ldy #0 : jsr _A2stepY :
	ldy #0 : jsr _hfill :
fill8_Lbresfill175
	lda _A1arrived : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda tmp0 : ora tmp0+1 : beq *+5 : jmp fill8_Lbresfill177 :
	lda _A2arrived : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda tmp0 : ora tmp0+1 : bne *+5 : jmp fill8_Lbresfill174 :
fill8_Lbresfill177
	jmp fill8_Lbresfill130 :
fill8_Lbresfill129
	lda _pDepX : sta tmp0 :
	lda tmp0 : sta _A1X :
	lda _pDepY : sta tmp0 :
	lda tmp0 : sta _A1Y :
	lda _pArr2X : sta tmp0 :
	lda tmp0 : sta _A1destX :
	lda _pArr2Y : sta tmp0 :
	lda tmp0 : sta _A1destY :
	lda _A1destX : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A1X : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	sec : lda tmp0 : sbc tmp1 : sta tmp0 : lda tmp0+1 : sbc tmp1+1 : sta tmp0+1 :
	lda tmp0 : cmp #<(0) : lda tmp0+1 : sbc #>(0) : bvc *+4 : eor #$80 : bmi *+5 : jmp fill8_Lbresfill179 : :
	lda _A1destX : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A1X : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	sec : lda tmp0 : sbc tmp1 : sta tmp0 : lda tmp0+1 : sbc tmp1+1 : sta tmp0+1 :
	lda #0 : sec : sbc tmp0 : sta tmp0 : lda #0 : sbc tmp0+1 : sta tmp0+1 :
	lda tmp0 : sta reg4 : lda tmp0+1 : sta reg4+1 :
	jmp fill8_Lbresfill180 :
fill8_Lbresfill179
	lda _A1destX : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A1X : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	sec : lda tmp0 : sbc tmp1 : sta tmp0 : lda tmp0+1 : sbc tmp1+1 : sta tmp0+1 :
	lda tmp0 : sta reg4 : lda tmp0+1 : sta reg4+1 :
fill8_Lbresfill180
	lda reg4 : sta tmp0 : lda reg4+1 : sta tmp0+1 :
	lda tmp0 : sta _A1dX :
	lda _A1destY : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A1Y : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	sec : lda tmp0 : sbc tmp1 : sta tmp0 : lda tmp0+1 : sbc tmp1+1 : sta tmp0+1 :
	lda tmp0 : cmp #<(0) : lda tmp0+1 : sbc #>(0) : bvc *+4 : eor #$80 : bmi *+5 : jmp fill8_Lbresfill181 : :
	lda _A1destY : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A1Y : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	sec : lda tmp0 : sbc tmp1 : sta tmp0 : lda tmp0+1 : sbc tmp1+1 : sta tmp0+1 :
	lda #0 : sec : sbc tmp0 : sta tmp0 : lda #0 : sbc tmp0+1 : sta tmp0+1 :
	lda tmp0 : sta reg4 : lda tmp0+1 : sta reg4+1 :
	jmp fill8_Lbresfill182 :
fill8_Lbresfill181
	lda _A1destY : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A1Y : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	sec : lda tmp0 : sbc tmp1 : sta tmp0 : lda tmp0+1 : sbc tmp1+1 : sta tmp0+1 :
	lda tmp0 : sta reg4 : lda tmp0+1 : sta reg4+1 :
fill8_Lbresfill182
	lda reg4 : sta tmp0 : lda reg4+1 : sta tmp0+1 :
	lda #0 : sec : sbc tmp0 : sta tmp0 : lda #0 : sbc tmp0+1 : sta tmp0+1 :
	lda tmp0 : sta _A1dY :
	lda _A1dX : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A1dY : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	clc : lda tmp0 : adc tmp1 : sta tmp0 : lda tmp0+1 : adc tmp1+1 : sta tmp0+1 :
	lda tmp0 : sta _A1err :
	lda _A1err : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda #<(64) : cmp tmp0 : lda #>(64) : sbc tmp0+1 : .( : bvc *+4 : eor #$80 : bpl skip : jmp fill8_Lbresfill185 :skip : .) : : :
	lda tmp0 : cmp #<(-63) : lda tmp0+1 : sbc #>(-63) : bvc *+4 : eor #$80 : bmi *+5 : jmp fill8_Lbresfill183 : :
fill8_Lbresfill185
	jmp leave :
fill8_Lbresfill183
	lda _A1X : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A1destX : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	lda tmp0 : cmp tmp1 : lda tmp0+1 : sbc tmp1+1 : bvc *+4 : eor #$80 : bmi *+5 : jmp fill8_Lbresfill187 : :
	lda #<(1) : sta reg5 : lda #>(1) : sta reg5+1 :
	jmp fill8_Lbresfill188 :
fill8_Lbresfill187
	lda #<(-1) : sta reg5 : lda #>(-1) : sta reg5+1 :
fill8_Lbresfill188
	lda reg5 : sta tmp0 : lda reg5+1 : sta tmp0+1 :
	lda tmp0 : sta _A1sX :
	lda _A1Y : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A1destY : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	lda tmp0 : cmp tmp1 : lda tmp0+1 : sbc tmp1+1 : bvc *+4 : eor #$80 : bmi *+5 : jmp fill8_Lbresfill189 : :
	lda #<(1) : sta reg5 : lda #>(1) : sta reg5+1 :
	jmp fill8_Lbresfill190 :
fill8_Lbresfill189
	lda #<(-1) : sta reg5 : lda #>(-1) : sta reg5+1 :
fill8_Lbresfill190
	lda reg5 : sta tmp0 : lda reg5+1 : sta tmp0+1 :
	lda tmp0 : sta _A1sY :
	lda _A1X : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A1destX : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	lda tmp0 : eor tmp1 : sta tmp : lda tmp0+1 : eor tmp1+1 : ora tmp : beq *+5 : jmp fill8_Lbresfill191 :
	lda _A1Y : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A1destY : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	lda tmp0 : eor tmp1 : sta tmp : lda tmp0+1 : eor tmp1+1 : ora tmp : beq *+5 : jmp fill8_Lbresfill191 :
	lda #<(1) : sta reg5 : lda #>(1) : sta reg5+1 :
	jmp fill8_Lbresfill192 :
fill8_Lbresfill191
	lda #<(0) : sta reg5 : lda #>(0) : sta reg5+1 :
fill8_Lbresfill192
	lda reg5 : sta tmp0 : lda reg5+1 : sta tmp0+1 :
	lda tmp0 : sta _A1arrived :
	lda _pArr1X : sta tmp0 :
	lda tmp0 : sta _A2X :
	lda _pArr1Y : sta tmp0 :
	lda tmp0 : sta _A2Y :
	lda _pArr2X : sta tmp0 :
	lda tmp0 : sta _A2destX :
	lda _pArr2Y : sta tmp0 :
	lda tmp0 : sta _A2destY :
	lda _A2destX : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A2X : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	sec : lda tmp0 : sbc tmp1 : sta tmp0 : lda tmp0+1 : sbc tmp1+1 : sta tmp0+1 :
	lda tmp0 : cmp #<(0) : lda tmp0+1 : sbc #>(0) : bvc *+4 : eor #$80 : bmi *+5 : jmp fill8_Lbresfill193 : :
	lda _A2destX : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A2X : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	sec : lda tmp0 : sbc tmp1 : sta tmp0 : lda tmp0+1 : sbc tmp1+1 : sta tmp0+1 :
	lda #0 : sec : sbc tmp0 : sta tmp0 : lda #0 : sbc tmp0+1 : sta tmp0+1 :
	lda tmp0 : sta reg5 : lda tmp0+1 : sta reg5+1 :
	jmp fill8_Lbresfill194 :
fill8_Lbresfill193
	lda _A2destX : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A2X : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	sec : lda tmp0 : sbc tmp1 : sta tmp0 : lda tmp0+1 : sbc tmp1+1 : sta tmp0+1 :
	lda tmp0 : sta reg5 : lda tmp0+1 : sta reg5+1 :
fill8_Lbresfill194
	lda reg5 : sta tmp0 : lda reg5+1 : sta tmp0+1 :
	lda tmp0 : sta _A2dX :
	lda _A2destY : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A2Y : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	sec : lda tmp0 : sbc tmp1 : sta tmp0 : lda tmp0+1 : sbc tmp1+1 : sta tmp0+1 :
	lda tmp0 : cmp #<(0) : lda tmp0+1 : sbc #>(0) : bvc *+4 : eor #$80 : bmi *+5 : jmp fill8_Lbresfill195 : :
	lda _A2destY : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A2Y : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	sec : lda tmp0 : sbc tmp1 : sta tmp0 : lda tmp0+1 : sbc tmp1+1 : sta tmp0+1 :
	lda #0 : sec : sbc tmp0 : sta tmp0 : lda #0 : sbc tmp0+1 : sta tmp0+1 :
	lda tmp0 : sta reg5 : lda tmp0+1 : sta reg5+1 :
	jmp fill8_Lbresfill196 :
fill8_Lbresfill195
	lda _A2destY : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A2Y : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	sec : lda tmp0 : sbc tmp1 : sta tmp0 : lda tmp0+1 : sbc tmp1+1 : sta tmp0+1 :
	lda tmp0 : sta reg5 : lda tmp0+1 : sta reg5+1 :
fill8_Lbresfill196
	lda reg5 : sta tmp0 : lda reg5+1 : sta tmp0+1 :
	lda #0 : sec : sbc tmp0 : sta tmp0 : lda #0 : sbc tmp0+1 : sta tmp0+1 :
	lda tmp0 : sta _A2dY :
	lda _A2dX : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A2dY : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	clc : lda tmp0 : adc tmp1 : sta tmp0 : lda tmp0+1 : adc tmp1+1 : sta tmp0+1 :
	lda tmp0 : sta _A2err :
	lda _A2err : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda #<(64) : cmp tmp0 : lda #>(64) : sbc tmp0+1 : .( : bvc *+4 : eor #$80 : bpl skip : jmp fill8_Lbresfill199 :skip : .) : : :
	lda tmp0 : cmp #<(-63) : lda tmp0+1 : sbc #>(-63) : bvc *+4 : eor #$80 : bmi *+5 : jmp fill8_Lbresfill197 : :
fill8_Lbresfill199
	jmp leave :
fill8_Lbresfill197
	lda _A2X : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A2destX : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	lda tmp0 : cmp tmp1 : lda tmp0+1 : sbc tmp1+1 : bvc *+4 : eor #$80 : bmi *+5 : jmp fill8_Lbresfill201 : :
	lda #<(1) : sta reg6 : lda #>(1) : sta reg6+1 :
	jmp fill8_Lbresfill202 :
fill8_Lbresfill201
	lda #<(-1) : sta reg6 : lda #>(-1) : sta reg6+1 :
fill8_Lbresfill202
	lda reg6 : sta tmp0 : lda reg6+1 : sta tmp0+1 :
	lda tmp0 : sta _A2sX :
	lda _A2Y : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A2destY : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	lda tmp0 : cmp tmp1 : lda tmp0+1 : sbc tmp1+1 : bvc *+4 : eor #$80 : bmi *+5 : jmp fill8_Lbresfill203 : :
	lda #<(1) : sta reg6 : lda #>(1) : sta reg6+1 :
	jmp fill8_Lbresfill204 :
fill8_Lbresfill203
	lda #<(-1) : sta reg6 : lda #>(-1) : sta reg6+1 :
fill8_Lbresfill204
	lda reg6 : sta tmp0 : lda reg6+1 : sta tmp0+1 :
	lda tmp0 : sta _A2sY :
	lda _A2X : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A2destX : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	lda tmp0 : eor tmp1 : sta tmp : lda tmp0+1 : eor tmp1+1 : ora tmp : beq *+5 : jmp fill8_Lbresfill205 :
	lda _A2Y : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda _A2destY : sta tmp1 :
	lda #0 : ldx tmp1 : stx tmp1 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp1+1 :
	lda tmp0 : eor tmp1 : sta tmp : lda tmp0+1 : eor tmp1+1 : ora tmp : beq *+5 : jmp fill8_Lbresfill205 :
	lda #<(1) : sta reg6 : lda #>(1) : sta reg6+1 :
	jmp fill8_Lbresfill206 :
fill8_Lbresfill205
	lda #<(0) : sta reg6 : lda #>(0) : sta reg6+1 :
fill8_Lbresfill206
	lda reg6 : sta tmp0 : lda reg6+1 : sta tmp0+1 :
	lda tmp0 : sta _A2arrived :
	ldy #0 : jsr _hfill :
	jmp fill8_Lbresfill208 :
fill8_Lbresfill207
	ldy #0 : jsr _A1stepY :
	ldy #0 : jsr _A2stepY :
	ldy #0 : jsr _hfill :
fill8_Lbresfill208
	lda _A1arrived : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda tmp0 : ora tmp0+1 : beq *+5 : jmp fill8_Lbresfill210 :
	lda _A2arrived : sta tmp0 :
	lda #0 : ldx tmp0 : stx tmp0 : .( : bpl skip : lda #$FF :skip : .)  : sta tmp0+1 :
	lda tmp0 : ora tmp0+1 : bne *+5 : jmp fill8_Lbresfill207 :
fill8_Lbresfill210
fill8_Lbresfill130
	jmp leave :

.)
	; rts
#endif USE_ASM_FILL8