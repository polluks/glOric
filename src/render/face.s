#include "config.h"

#ifdef USE_ASM_GLDRAWFACES
_glDrawFaces:
.(

#ifdef USE_PROFILER
PROFILE_ENTER(ROUTINE_GLDRAWFACES);
#endif // USE_PROFILER

	// Save context
	lda reg0 : pha 

	ldy _nbFaces
	jmp glDrawFaces_nextFace
    // for (ii = 0; ii < nbFaces; ii++) {
glDrawFaces_loop:

    //     idxPt1 = facesPt1[ii] ;
	lda _facesPt1, y
	sta _idxPt1
    //     idxPt2 = facesPt2[ii] ;
	lda _facesPt2, y
	sta _idxPt2
    //     idxPt3 = facesPt3[ii] ;
	lda _facesPt3, y
	sta _idxPt3
    //     ch2disp = facesChar[ii];
	lda _facesChar, y
	sta _ch2disp

	sty reg0 

    //     retrieveFaceData();
	jsr _retrieveFaceData
    //     sortPoints();
	jsr _sortPoints
    //     guessIfFace2BeDrawn();
	jsr _guessIfFace2BeDrawn
    //     if (isFace2BeDrawn) {
	lda _isFace2BeDrawn
	beq glDrawFaces_afterFill
    //         fillFace();
		jsr _fillFace
    //     }
glDrawFaces_afterFill:
	ldy reg0

glDrawFaces_nextFace:
	dey 
	bpl glDrawFaces_loop
    // }

glDrawFaces_done:
	// Restore context
	pla : sta reg0

#ifdef USE_PROFILER
PROFILE_LEAVE(ROUTINE_GLDRAWFACES);
#endif // USE_PROFILER

.)
	rts
#endif //USE_ASM_GLDRAWFACES

#ifdef USE_ASM_RETRIEVEFACEDATA
_retrieveFaceData:
.(

	// save context
    ; pha
	; lda reg0:pha
	; lda tmp0:pha ; tmpH
	; lda tmp1:pha ; tmpV

	; lda _idxPt1 : sta tmp0 :

	; clc : lda #<(_points2dL) : adc tmp0 : sta tmp0 : lda #>(_points2dL) : adc tmp0+1 : sta tmp0+1 :
	; lda tmp0 : sta _d1 : lda tmp0+1 : sta _d1+1 :

	ldy _idxPt1
        // P1AH = points2aH[idxPt1];
	lda _points2aH,y : sta _P1AH 
        // P1AV = points2aV[idxPt1];
	lda _points2aV,y : sta _P1AV 
        // dmoy = points2dL[idxPt1]; //*((int*)(points2d + offPt1 + 2));
	lda _points2dL,y : sta _dmoy: lda _points2dH,y : sta _dmoy+1

	ldy _idxPt2
        // P2AH = points2aH[idxPt2];
	lda _points2aH,y : sta _P2AH 		
        // P2AV = points2aV[idxPt2];
	lda _points2aV,y : sta _P2AV 		
        // dmoy += points2dL[idxPt2]; //*((int*)(points2d + offPt2 + 2));
	clc: lda _points2dL,y : adc _dmoy: sta _dmoy : lda _points2dH,y : adc _dmoy+1 :sta _dmoy+1


    ldy _idxPt3
	    // P3AH = points2aH[idxPt3];
	lda _points2aH,y : sta _P3AH	
        // P3AV = points2aV[idxPt3];
	lda _points2aV,y : sta _P3AV 		
        // dmoy +=  points2dL[idxPt3]; //*((int*)(points2d + offPt3 + 2));
	clc: lda _points2dL,y : adc _dmoy: sta _dmoy : lda _points2dH,y : adc _dmoy+1 :sta _dmoy+1

	lda _dmoy+1
	
	beq moynottoobig		// FIXME :: it should be possible to deal with case *(dmoy+1) = 1
	lda #$FF
	sta _distface
	jmp retreiveFaceData_done

moynottoobig:
        // dmoy = dmoy / 3;
	lda _dmoy

	;Divide by 3 found on http://forums.nesdev.com/viewtopic.php?f=2&t=11336
	;18 bytes, 30 cycles
	sta  tmp0
	lsr
	adc  #21
	lsr
	adc  tmp0
	ror
	lsr
	adc  tmp0
	ror
	lsr
	adc  tmp0
	ror
	lsr

        // if (dmoy >= 256) {
        //     dmoy = 256;
        // }
        // distface = (unsigned char)(dmoy & 0x00FF);
	sta _distface


retreiveFaceData_done:	
	// restore context
	; pla: sta tmp1
	; pla: sta tmp0
	; pla: sta reg0
	;pla

	; jmp leave :
.)
	rts
#endif // USE_ASM_RETRIEVEFACEDATA


    ;; if (abs(P2AH) < abs(P1AH)) {
    ;;     tmpH = P1AH;
    ;;     tmpV = P1AV;
    ;;     P1AH = P2AH;
    ;;     P1AV = P2AV;
    ;;     P2AH = tmpH;
    ;;     P2AV = tmpV;
    ;; }
    ;; if (abs(P3AH) < abs(P1AH)) {
    ;;     tmpH = P1AH;
    ;;     tmpV = P1AV;
    ;;     P1AH = P3AH;
    ;;     P1AV = P3AV;
    ;;     P3AH = tmpH;
    ;;     P3AV = tmpV;
    ;; }
    ;; if (abs(P3AH) < abs(P2AH)) {
    ;;     tmpH = P2AH;
    ;;     tmpV = P2AV;
    ;;     P2AH = P3AH;
    ;;     P2AV = P3AV;
    ;;     P3AH = tmpH;
    ;;     P3AV = tmpV;
    ;; }

#ifdef USE_ASM_SORTPOINTS
_sortPoints:
.(
	; ldx #6 : lda #6 : jsr enter :

	// save context
    pha
	lda reg0:pha
	lda tmp0:pha ; tmpH
	lda tmp1:pha ; tmpV


    ;; if (abs(P2AH) < abs(P1AH)) {
.(
	lda _P1AH
	bpl positiv_02
	eor #$FF
	clc
	adc #1
positiv_02:
	sta reg0

	lda _P2AH
	bpl positiv_01
	eor #$FF
	clc
	adc #1
positiv_01:

	cmp reg0
	bcs sortPoints_step01
.)
    ;;     tmpH = P1AH;
    ;;     tmpV = P1AV;
    ;;     P1AH = P2AH;
    ;;     P1AV = P2AV;
    ;;     P2AH = tmpH;
    ;;     P2AV = tmpV;
	lda _P1AH : sta tmp0 :
	lda _P1AV : sta tmp1 :
	lda _P2AH : sta _P1AH :
	lda _P2AV : sta _P1AV :
	lda tmp0 : sta _P2AH :
	lda tmp1 : sta _P2AV :


    ;; }
sortPoints_step01:	
    ;; if (abs(P3AH) < abs(P1AH)) {
.(
	lda _P1AH
	bpl positiv_02
	eor #$FF
	clc
	adc #1
positiv_02:
	sta reg0

	lda _P3AH
	bpl positiv_01
	eor #$FF
	clc
	adc #1
positiv_01:

	cmp reg0
	bcs sortPoints_step02
.)
    ;;     tmpH = P1AH;
    ;;     tmpV = P1AV;
    ;;     P1AH = P3AH;
    ;;     P1AV = P3AV;
    ;;     P3AH = tmpH;
    ;;     P3AV = tmpV;
	lda _P1AH : sta tmp0 :
	lda _P1AV : sta tmp1 :
	lda _P3AH : sta _P1AH :
	lda _P3AV : sta _P1AV :
	lda tmp0 : sta _P3AH :
	lda tmp1 : sta _P3AV :
    ;; }
sortPoints_step02:	
    ;; if (abs(P3AH) < abs(P2AH)) {
.(
	lda _P2AH
	bpl positiv_02
	eor #$FF
	clc
	adc #1
positiv_02:
	sta reg0

	lda _P3AH
	bpl positiv_01
	eor #$FF
	clc
	adc #1
positiv_01:

	cmp reg0
	bcs sortPoints_done
.)
    ;;     tmpH = P2AH;
    ;;     tmpV = P2AV;
    ;;     P2AH = P3AH;
    ;;     P2AV = P3AV;
    ;;     P3AH = tmpH;
    ;;     P3AV = tmpV;
	lda _P2AH : sta tmp0 :
	lda _P2AV : sta tmp1 :
	lda _P3AH : sta _P2AH :
	lda _P3AV : sta _P2AV :
	lda tmp0 : sta _P3AH :
	lda tmp1 :sta _P3AV :

    ;; }

sortPoints_done:	

	// restore context
	pla: sta tmp1
	pla: sta tmp0
	pla: sta reg0
	pla


	; jmp leave :
.)
	rts
#endif // USE_ASM_SORTPOINTS

#ifdef USE_ASM_GUESSIFFACE2BEDRAWN
_guessIfFace2BeDrawn:
.(
	; ldx #10 : lda #8 : jsr enter :

	// save context
    pha
	lda reg0:pha
	lda reg1:pha
	lda tmp0:pha
	lda tmp1:pha

    // m1 = P1AH & ANGLE_MAX;
	lda _P1AH
	and #ASM_ANGLE_MAX
	sta _m1
    // m2 = P2AH & ANGLE_MAX;
	lda _P2AH
	and #ASM_ANGLE_MAX
	sta _m2
    // m3 = P3AH & ANGLE_MAX;
	lda _P3AH
	and #ASM_ANGLE_MAX
	sta _m3
    // v1 = P1AH & ANGLE_VIEW;
	lda _P1AH
	and #ASM_ANGLE_VIEW
	sta _v1
    // v2 = P2AH & ANGLE_VIEW;
	lda _P2AH
	and #ASM_ANGLE_VIEW
	sta _v2
    // v3 = P3AH & ANGLE_VIEW;
	lda _P3AH
	and #ASM_ANGLE_VIEW
	sta _v3

    // isFace2BeDrawn = 0;
	lda #0
	sta _isFace2BeDrawn
debug_ici:
    // if ((m1 == 0x00) || (m1 == ANGLE_MAX)) {
	lda _m1
	beq guessIfFace2BeDrawn_m1extrema
	cmp #ASM_ANGLE_MAX
	beq guessIfFace2BeDrawn_m1extrema
	jmp guessIfFace2BeDrawn_p1back
guessIfFace2BeDrawn_m1extrema:
    //     if ((v1 == 0x00) || (v1 == ANGLE_VIEW)) {
			lda _v1 
			beq guessIfFace2BeDrawn_p1view
			cmp #ASM_ANGLE_VIEW
			beq guessIfFace2BeDrawn_p1view
			jmp guessIfFace2BeDrawn_p1face
guessIfFace2BeDrawn_p1view:
    //         if (
    //             (
    //                 (P1AH & 0x80) != (P2AH & 0x80)) ||
    //             ((P1AH & 0x80) != (P3AH & 0x80))) {
					lda _P1AH 
					eor _P2AH
					and #$80
					bne guessIfFace2BeDrawn_midscreencrossed
					lda _P1AH 
					eor _P3AH
					and #$80
					bne guessIfFace2BeDrawn_midscreencrossed

					jmp guessIfFace2BeDrawn_p1face
guessIfFace2BeDrawn_midscreencrossed:
    //             if ((abs(P3AH) < 127 - abs(P1AH))) {
					.(		
						lda _P1AH
						bpl positiv_01
						eor #$FF
						clc
						adc #1
					positiv_01:
						sta reg0			; reg 0 <- abs(P1AH)

						lda _P3AH
						bpl positiv_02
						eor #$FF
						clc
						adc #1
					positiv_02:
						clc
						adc reg0			; a  <- abs(P3AH) + abs(P1AH)
						bpl guessIfFace2BeDrawn_found01 ; FIXME if sign bit is set <= 127 considtion rather than < 127

					.)
						jmp guessIfFace2BeDrawn_done
    //                 isFace2BeDrawn=1;
guessIfFace2BeDrawn_found01:
							lda #1
							sta _isFace2BeDrawn
							jmp guessIfFace2BeDrawn_done
    //             }
guessIfFace2BeDrawn_p1face:
    //         } else {
    //             isFace2BeDrawn=1;
					lda #1
					sta _isFace2BeDrawn
					jmp guessIfFace2BeDrawn_done
    //         }
guessIfFace2BeDrawn_p1front:	
    //     } else {
    //         // P1 FRONT
    //         if ((m2 == 0x00) || (m2 == ANGLE_MAX)) {
				lda _m2
				beq guessIfFace2BeDrawn_p2front
				cmp #ASM_ANGLE_MAX
				beq guessIfFace2BeDrawn_p2front
				jmp guessIfFace2BeDrawn_p2back
    //             // P2 FRONT
guessIfFace2BeDrawn_p2front:
    //             if ((m3 == 0x00) || (m3 == ANGLE_MAX)) {
					lda _m3
					beq guessIfFace2BeDrawn_p3front
					cmp #ASM_ANGLE_MAX
					beq guessIfFace2BeDrawn_p3front
					jmp guessIfFace2BeDrawn_p3back
guessIfFace2BeDrawn_p3front:
    //                 // P3 FRONT
    //                 // _4_
    //                 if (((P1AH & 0x80) != (P2AH & 0x80)) 
	//						|| ((P1AH & 0x80) != (P3AH & 0x80))) {
						lda _P1AH 
						eor _P2AH
						and #$80
						bne guessIfFace2BeDrawn_midscreencrossed_02
						lda _P1AH 
						eor _P3AH
						and #$80
						bne guessIfFace2BeDrawn_midscreencrossed_02

						jmp guessIfFace2BeDrawn_done
guessIfFace2BeDrawn_midscreencrossed_02:						
    //                     isFace2BeDrawn=1;
							lda #1
							sta _isFace2BeDrawn
							jmp guessIfFace2BeDrawn_done
    //                 } else {
    //                     // nothing to do
    //                 }
guessIfFace2BeDrawn_p3back:
    //             } else {
    //                 // P3 BACK
    //                 // _3_
    //                 if ((P1AH & 0x80) != (P2AH & 0x80)) {
						lda _P1AH 
						eor _P2AH
						and #$80
						beq guessIfFace2BeDrawn_midscreencrossed_03
				
    //                     if (abs(P2AH) < 127 - abs(P1AH)) {
						.(		
							lda _P1AH
							bpl positiv_01
							eor #$FF
							clc
							adc #1
						positiv_01:
							sta reg0			; reg 0 <- abs(P1AH)

							lda _P2AH
							bpl positiv_02
							eor #$FF
							clc
							adc #1
						positiv_02:
							clc
							adc reg0			; a  <- abs(P2AH) + abs(P1AH)
							bpl guessIfFace2BeDrawn_found02 ; FIXME if sign bit is set <= 127 considtion rather than < 127

						.)
							jmp guessIfFace2BeDrawn_midscreencrossed_04
guessIfFace2BeDrawn_found02:
    //                         isFace2BeDrawn=1;
								lda #1
								sta _isFace2BeDrawn
								jmp guessIfFace2BeDrawn_done
    //                     }
guessIfFace2BeDrawn_midscreencrossed_03:
    //                 } else {
    //                     if ((P1AH & 0x80) != (P3AH & 0x80)) {
							lda _P1AH 
							eor _P3AH
							and #$80
							beq guessIfFace2BeDrawn_midscreencrossed_04
    //                         if (abs(P3AH) < 127 - abs(P1AH)) {
							.(		
								lda _P1AH
								bpl positiv_01
								eor #$FF
								clc
								adc #1
							positiv_01:
								sta reg0			; reg 0 <- abs(P1AH)

								lda _P3AH
								bpl positiv_02
								eor #$FF
								clc
								adc #1
							positiv_02:
								clc
								adc reg0			; a  <- abs(P3AH) + abs(P1AH)
								bpl guessIfFace2BeDrawn_found03 ; FIXME if sign bit is set <= 127 considtion rather than < 127

							.)
								jmp guessIfFace2BeDrawn_midscreencrossed_04
guessIfFace2BeDrawn_found03:
    //                             isFace2BeDrawn=1;
									lda #1
									sta _isFace2BeDrawn
									jmp guessIfFace2BeDrawn_done
    //                         }
    //                     }
    //                 }
guessIfFace2BeDrawn_midscreencrossed_04:
    //                 if ((P1AH & 0x80) != (P3AH & 0x80)) {
						lda _P1AH 
						eor _P3AH
						and #$80
						bne guessIfFace2BeDrawn_tmp01
						jmp guessIfFace2BeDrawn_done
    //                     if (abs(P3AH) < 127 - abs(P1AH)) {
guessIfFace2BeDrawn_tmp01:
						.(		
							lda _P1AH
							bpl positiv_01
							eor #$FF
							clc
							adc #1
						positiv_01:
							sta reg0			; reg 0 <- abs(P1AH)

							lda _P3AH
							bpl positiv_02
							eor #$FF
							clc
							adc #1
						positiv_02:
							clc
							adc reg0			; a  <- abs(P3AH) + abs(P1AH)
							bpl guessIfFace2BeDrawn_found04 ; FIXME if sign bit is set <= 127 considtion rather than < 127

						.)		
							jmp guessIfFace2BeDrawn_done
guessIfFace2BeDrawn_found04:
    //                         isFace2BeDrawn=1;
								lda #1
								sta _isFace2BeDrawn
								jmp guessIfFace2BeDrawn_done
    //                     }
    //                 }
    //             }
guessIfFace2BeDrawn_p2back:
    //         } else {
    //             // P2 BACK
    //             if ((P1AH & 0x80) != (P2AH & 0x80)) {
					lda _P1AH 
					eor _P2AH
					and #$80
					beq guessIfFace2BeDrawn_midscreencrossed_05
    //                 if (abs(P2AH) < 127 - abs(P1AH)) {
					.(		
						lda _P1AH
						bpl positiv_01
						eor #$FF
						clc
						adc #1
					positiv_01:
						sta reg0			; reg 0 <- abs(P1AH)

						lda _P3AH
						bpl positiv_02
						eor #$FF
						clc
						adc #1
					positiv_02:
						clc
						adc reg0			; a  <- abs(P3AH) + abs(P1AH)
						bpl guessIfFace2BeDrawn_found05 ; FIXME if sign bit is set <= 127 considtion rather than < 127

					.)	
						jmp guessIfFace2BeDrawn_midscreencrossed_06
guessIfFace2BeDrawn_found05:
    //                     isFace2BeDrawn=1;
							lda #1
							sta _isFace2BeDrawn
							jmp guessIfFace2BeDrawn_done
    //                 }
guessIfFace2BeDrawn_midscreencrossed_05:
    //             } else {
    //                 if ((P1AH & 0x80) != (P3AH & 0x80)) {
						lda _P1AH 
						eor _P3AH
						and #$80
						beq guessIfFace2BeDrawn_midscreencrossed_06
    //                     if (abs(P3AH) < 127 - abs(P1AH)) {
						.(		
							lda _P1AH
							bpl positiv_01
							eor #$FF
							clc
							adc #1
						positiv_01:
							sta reg0			; reg 0 <- abs(P1AH)

							lda _P3AH
							bpl positiv_02
							eor #$FF
							clc
							adc #1
						positiv_02:
							clc
							adc reg0			; a  <- abs(P3AH) + abs(P1AH)
							bpl guessIfFace2BeDrawn_found06 ; FIXME if sign bit is set <= 127 considtion rather than < 127

						.)	
							jmp guessIfFace2BeDrawn_midscreencrossed_06
guessIfFace2BeDrawn_found06:
    //                         isFace2BeDrawn=1;
								lda #1
								sta _isFace2BeDrawn
								jmp guessIfFace2BeDrawn_done
    //                     }
    //                 }
    //             }
guessIfFace2BeDrawn_midscreencrossed_06:
    //             if ((P1AH & 0x80) != (P3AH & 0x80)) {
					lda _P1AH 
					eor _P3AH
					and #$80
					beq guessIfFace2BeDrawn_done
    //                 if (abs(P3AH) < 127 - abs(P1AH)) {
						.(		
							lda _P1AH
							bpl positiv_01
							eor #$FF
							clc
							adc #1
						positiv_01:
							sta reg0			; reg 0 <- abs(P1AH)

							lda _P3AH
							bpl positiv_02
							eor #$FF
							clc
							adc #1
						positiv_02:
							clc
							adc reg0			; a  <- abs(P3AH) + abs(P1AH)
							bmi guessIfFace2BeDrawn_done ; FIXME if sign bit is set <= 127 considtion rather than < 127

						.)
    //                     isFace2BeDrawn=1;
								lda #1
								sta _isFace2BeDrawn
								jmp guessIfFace2BeDrawn_done
    //                 }
    //             }
    //         }
    //     }
guessIfFace2BeDrawn_p1back:
    // } else {
    //     // P1 BACK
    //     // _1_ nothing to do
    // }

guessIfFace2BeDrawn_done:

	// restore context
	pla: sta tmp1
	pla: sta tmp0
	pla: sta reg1
	pla: sta reg0
	pla

	; jmp leave :

.)
    rts
#endif