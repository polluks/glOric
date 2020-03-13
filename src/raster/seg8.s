#include "config.h"
#ifdef USE_PROFILER
#include "profile.h"
#endif // USE_PROFILER

#ifdef USE_ASM_GLDRAWSEGMENTS
//void glDrawSegments() {
_glDrawSegments:
.(
#ifdef USE_PROFILER
PROFILE_ENTER(ROUTINE_GLDRAWSEGMENTS);
#endif // USE_PROFILER

    // Save context
    lda reg0 : pha 

    ldy _nbSegments
    jmp glDrawSegments_nextSegment
//     for (ii = 0; ii < nbSegments; ii++) {

glDrawSegments_loop:

        jsr loadSegmentInfo

        jsr prepareLineDrawing

        jsr _lrDrawLine

    ldy reg0

glDrawSegments_nextSegment:
    dey 
    bmi glDrawSegments_done
    jmp glDrawSegments_loop
    // }

glDrawSegments_done:
	// Restore context
	pla : sta reg0

#ifdef USE_PROFILER
PROFILE_LEAVE(ROUTINE_GLDRAWSEGMENTS);
#endif // USE_PROFILER
.)
    rts
#endif // USE_ASM_GLDRAWSEGMENTS



loadSegmentInfo:
.(


//         idxPt1    = segmentsPt1[ii];
        lda _segmentsPt1,y : sta _idxPt1
//         idxPt2    = segmentsPt2[ii];
        lda _segmentsPt2,y : sta _idxPt2
//         ch2disp = segmentsChar[ii];
        lda _segmentsChar,y : sta _ch2disp

//         // dmoy = (d1+d2)/2;
        sty reg0
        ldy _idxPt1
#ifdef ANGLEONLY
//         P1AH = points2aH[idxPt1];
        lda _points2aH, y : sta _P1AH
//         P1AV = points2aV[idxPt1];
        lda _points2aV, y : sta _P1AV
#else 
//         P1X = points2aH[idxPt1];
        lda _points2aH, y : sta _P1X
//         P1Y = points2aV[idxPt1];
        lda _points2aV, y : sta _P1Y
#endif
//         dmoy = points2dL[idxPt1];
        lda _points2dL,y : sta _dmoy: lda _points2dH,y : sta _dmoy+1

        ldy _idxPt2
#ifdef ANGLEONLY
//         P2AH = points2aH[idxPt2];
        lda _points2aH, y : sta _P2AH
//         P2AV = points2aV[idxPt2];
        lda _points2aV, y : sta _P2AV
#else 
//         P2X = points2aH[idxPt2];
        lda _points2aH, y : sta _P2X
//         P2Y = points2aV[idxPt2];
        lda _points2aV, y : sta _P2Y
#endif        
//         dmoy += points2dL[idxPt2];
        clc: lda _points2dL,y : adc _dmoy: sta _dmoy : lda _points2dH,y : adc _dmoy+1 :sta _dmoy+1

.)
        rts

prepareLineDrawing:
.(
//         dmoy = dmoy >> 1;
//         //if (dmoy >= 256) {
//         if ((dmoy & 0xFF00) != 0)
//             continue;
        lda _dmoy+1
        
        beq prepareLineDrawing_moynottoobig		// FIXME :: it should be possible to deal with case *(dmoy+1) = 1
        lda #$FF
        sta _distseg
        bne prepareLineDrawing_drawline
prepareLineDrawing_moynottoobig:
        lda _dmoy
        lsr
        sta _distseg
//         distseg = (unsigned char)((dmoy)&0x00FF);
//         distseg--;  // FIXME

prepareLineDrawing_drawline:
        dec _distseg

#ifdef ANGLEONLY
//         P1X = (SCREEN_WIDTH - P1AH) >> 1;
        sec
        lda #SCREEN_WIDTH
        sbc _P1AH
        cmp #$80
        ror
        sta _P1X

//         P1Y = (SCREEN_HEIGHT - P1AV) >> 1;
        sec
        lda #SCREEN_HEIGHT
        sbc _P1AV
        cmp #$80
        ror
        sta _P1Y

//         P2X = (SCREEN_WIDTH - P2AH) >> 1;
        sec
        lda #SCREEN_WIDTH
        sbc _P2AH
        cmp #$80
        ror
        sta _P2X
//         P2Y = (SCREEN_HEIGHT - P2AV) >> 1;
        sec
        lda #SCREEN_HEIGHT
        sbc _P2AV
        cmp #$80
        ror
        sta _P2Y
#endif
.)
        rts




#ifdef USE_ASM_GLDRAWSEGMENTS

#ifdef INDIRECT_DRAWSEGMENTS

//void glDrawSegmentsArray(char points2d[], unsigned char segments[], unsigned char nbSegments);
.zero
ptrSegmentsPt1  .dsb 2
ptrSegmentsPt2  .dsb 2
ptrSegmentsChar .dsb 2
.text



//void glDrawSegmentsArray(char points2d[], unsigned char segments[], unsigned char nbSegments);

_glDrawSegmentsArray
.(
	;ldx #6 : lda #4 : jsr enter :

	ldy #0 : lda (sp),y : sta ptrPoints2aH : 
    iny : lda (sp),y : sta ptrPoints2aH+1 : 

	ldy #2 : lda (sp),y : sta ptrSegmentsPt1 :
    iny : lda (sp),y : sta ptrSegmentsPt1+1 :

	ldy #4 : lda (sp),y : sta _nbSegments :


;; ptrSegmentsPt2 = ptrSegmentsPt1 + NB_MAX_SEGMENTS
;; ptrSegmentsChar= ptrSegmentsPt2 + NB_MAX_SEGMENTS

    clc
    lda ptrSegmentsPt1
    adc #NB_MAX_SEGMENTS
    sta ptrSegmentsPt2
    lda ptrSegmentsPt1+1
    adc #0
    sta ptrSegmentsPt2+1

    clc
    lda ptrSegmentsPt2
    adc #NB_MAX_SEGMENTS
    sta ptrSegmentsChar
    lda ptrSegmentsPt2+1
    adc #0
    sta ptrSegmentsChar+1

    ;; ptrPoints2aV = ptrPoints2aH + NB_MAX_POINTS
    ;; ptrPoints2dH = ptrPoints2aV + NB_MAX_POINTS
    ;; ptrPoints2dL = ptrPoints2dH + NB_MAX_POINTS

    clc
    lda ptrPoints2aH
    adc #NB_MAX_POINTS
    sta ptrPoints2aV
    lda ptrPoints2aH+1
    adc #0
    sta ptrPoints2aV+1
    
    clc
    lda ptrPoints2aV
    adc #NB_MAX_POINTS
    sta ptrPoints2dH
    lda ptrPoints2aV+1
    adc #0
    sta ptrPoints2dH+1
    
    clc
    lda ptrPoints2dH
    adc #NB_MAX_POINTS
    sta ptrPoints2dL
    lda ptrPoints2dH+1
    adc #0
    sta ptrPoints2dL+1

	jsr _glIndirectDrawSegments

	;jmp leave :
.)
	rts


#else // Not INDIRECT_DRAWSEGMENTS

#endif

#ifdef INDIRECT_DRAWSEGMENTS

loadIndirectSegmentInfo:
.(
//         idxPt1    = segmentsPt1[ii];
        lda (ptrSegmentsPt1),y : sta _idxPt1
//         idxPt2    = segmentsPt2[ii];
        lda (ptrSegmentsPt2),y : sta _idxPt2
//         ch2disp = segmentsChar[ii];
        lda (ptrSegmentsChar),y : sta _ch2disp

//         // dmoy = (d1+d2)/2;
        sty reg0
        ldy _idxPt1
#ifdef ANGLEONLY
//         P1AH = points2aH[idxPt1];
        lda (ptrPoints2aH), y : sta _P1AH
//         P1AV = points2aV[idxPt1];
        lda (ptrPoints2aV), y : sta _P1AV
#else 
//         P1X = points2aH[idxPt1];
        lda (ptrPoints2aH), y : sta _P1X
//         P1Y = points2aV[idxPt1];
        lda (ptrPoints2aV), y : sta _P1Y
#endif
//         dmoy = points2dL[idxPt1];
        lda (ptrPoints2dL),y : sta _dmoy: lda (ptrPoints2dH),y : sta _dmoy+1

        ldy _idxPt2
#ifdef ANGLEONLY
//         P2AH = points2aH[idxPt2];
        lda (ptrPoints2aH), y : sta _P2AH
//         P2AV = points2aV[idxPt2];
        lda (ptrPoints2aV), y : sta _P2AV
#else 
//         P2X = points2aH[idxPt2];
        lda (ptrPoints2aH), y : sta _P2X
//         P2Y = points2aV[idxPt2];
        lda (ptrPoints2aV), y : sta _P2Y
#endif        
//         dmoy += points2dL[idxPt2];
        clc: lda (ptrPoints2dL),y : adc _dmoy: sta _dmoy : lda (ptrPoints2dH),y : adc _dmoy+1 :sta _dmoy+1

.)
        rts

_glIndirectDrawSegments:
.(
#ifdef USE_PROFILER
PROFILE_ENTER(ROUTINE_GLDRAWSEGMENTS);
#endif // USE_PROFILER

    // Save context
    lda reg0 : pha 

    ldy _nbSegments
    jmp glIndirectDrawSegments_nextSegment

//     for (ii = 0; ii < nbSegments; ii++) {
glIndirectDrawSegments_loop:

        jsr loadIndirectSegmentInfo

        jsr prepareLineDrawing

        jsr _lrDrawLine

    ldy reg0

glIndirectDrawSegments_nextSegment:
    dey 
    bmi glIndirectDrawSegments_done
    jmp glIndirectDrawSegments_loop
    // }

glIndirectDrawSegments_done:
	// Restore context
	pla : sta reg0

#ifdef USE_PROFILER
PROFILE_LEAVE(ROUTINE_GLDRAWSEGMENTS);
#endif // USE_PROFILER
.)
    rts



#endif INDIRECT_DRAWSEGMENTS

#endif // USE_ASM_GLDRAWSEGMENTS

