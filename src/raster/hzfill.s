#include "config.h"
#ifdef USE_PROFILER
#include "profile.h"
#endif

.zero

lineIndex   .dsb 1
departX     .dsb 1
finX        .dsb 1
hLineLength .dsb 1

.text




// void hzfill() {
_hzfill:
.(
	// save context
    pha:txa:pha:tya:pha

	lda tmp0: pha
	lda tmp0+1: pha
	lda tmp1: pha
	lda tmp1+1: pha

	clv

	// lineIndex = A1Y
	lda _A1Y				; Access Y coordinate
    sta lineIndex ; A1Y

	// if  (A1X > A2X)
	lda _A1Right ;
	beq hzfill_A2xOverOrEqualA1x

;; #ifdef USE_COLOR
;; //		dx = max(2, A2X)
;; #else
;; //      dx = max(0, A2X);
;; #endif


		lda _A2XSatur
		beq hzfill_A2XDontSatur_01 
#ifdef USE_COLOR		
		lda #COLUMN_OF_COLOR_ATTRIBUTE
#else
		lda #0
#endif
		jmp hzfill_A2xPositiv
hzfill_A2XDontSatur_01:
		lda _A2X		

hzfill_A2xPositiv:
		sta departX ; dx


//         fx = min(A1X, SCREEN_WIDTH - 1);

		lda _A1XSatur
		beq hzfill_A1XDontSatur
			lda #SCREEN_WIDTH - 1
			sta finX
			jmp hzfill_computeNbPoints
hzfill_A1XDontSatur:
			lda _A1X
			sta finX
			jmp hzfill_computeNbPoints



hzfill_A2xOverOrEqualA1x:
//     } else {

;; #ifdef USE_COLOR
;; //		dx = max(2, A1X);
;; #else
;; //      dx = max(0, A1X);
;; #endif

		lda _A1XSatur
		beq hzfill_A1XDontSatur_02
#ifdef USE_COLOR		
		lda #COLUMN_OF_COLOR_ATTRIBUTE
#else
		lda #0
#endif
		jmp hzfill_A1xPositiv
hzfill_A1XDontSatur_02:
		lda _A1X

hzfill_A1xPositiv:
		sta departX


;; //         fx = min(A2X, SCREEN_WIDTH - 1);
		lda _A2XSatur
		beq hzfill_A2XDontSatur_02		
			lda #SCREEN_WIDTH - 1
			sta finX
		jmp hzfill_computeNbPoints
hzfill_A2XDontSatur_02:
		lda _A2X	
		sta finX	



hzfill_computeNbPoints:

//     if ((nbpoints = fx - dx)) < 0) return;
	sec
	lda finX
	sbc departX
    beq hzfill_done
	bmi hzfill_done
	sta hLineLength


// #ifdef USE_ZBUFFER

    ldx lineIndex ; A1Y

    // ptrZbuf = zbuffer + py * SCREEN_WIDTH + dx;
 	lda ZBufferAdressLow,x	; Get the LOW part of the zbuffer adress
	clc						
	adc departX				; Add dx coordinate
	sta tmp1                ; ptrZbuf
	lda ZBufferAdressHigh,x	; Get the HIGH part of the zbuffer adress
	adc #0					; 
	sta tmp1+1				; ptrZbuf+ 1			

    // ptrFbuf = fbuffer + py * SCREEN_WIDTH + dx;
    lda FBufferAdressLow,x	; Get the LOW part of the fbuffer adress
    clc						; 
    adc departX				; Add dx coordinate
    sta tmp0                ; ptrFbuf
    lda FBufferAdressHigh,x	; Get the HIGH part of the fbuffer adress
    adc #0					; 
    sta tmp0+1	            ; ptrFbuf+ 1			



    // while (nbp > 0) {
    ldy hLineLength
_hzline_loop: 

    //     if (dist < ptrZbuf[nbp]) {
		lda (tmp1), y
		cmp _distface
		bcc hzline_distOver
    //         ptrFbuf[nbp] = char2disp;
			lda _ch2disp
			sta (tmp0), y
    //         ptrZbuf[nbp] = dist;
			lda _distface
			sta (tmp1), y
   //     }
hzline_distOver:
    //     nbp--;
    dey
    bne _hzline_loop
    // }





// #else
//     // TODO : draw a line whit no z-buffer
// #endif


hzfill_done:
	// restore context

	pla: sta tmp1+1
	pla: sta tmp1
 	pla: sta tmp0+1
	pla: sta tmp0
 
	pla:tay:pla:tax:pla
// }

.)
	rts
