
#include "glConf.h"



.text

 // Camera Position
_CamPosX            .dsb 1
_CamPosY:           .dsb 1
_CamPosZ:           .dsb 1

 // Camera Orientation
_CamRotZ:           .dsb 1			// -128 -> -127 unit : 2PI/(2^8 - 1)
_CamRotX:           .dsb 1



//unsigned char nbCoords=0;
_nbCoords           .dsb 1
//unsigned char nbSegments=0;
_nbSegments         .dsb 1
//unsigned char nbParticules=0;
_nbParticules       .dsb 1;
//unsigned char nbFaces=0;
_nbFaces            .dsb 1;


//char points3d[NB_MAX_COORDS*SIZEOF_3DPOINT];
//.dsb 256-(*&255)
_points3d:
_points3dX          .dsb NB_MAX_COORDS
_points3dY          .dsb NB_MAX_COORDS
_points3dZ          .dsb NB_MAX_COORDS


//char segments[NB_MAX_SEGMENTS*SIZEOF_SEGMENT];
// .dsb 256-(*&255)
_segments:
_segmentsPt1        .dsb NB_MAX_SEGMENTS
_segmentsPt2        .dsb NB_MAX_SEGMENTS
_segmentsChar       .dsb NB_MAX_SEGMENTS

//char points2d [NB_MAX_COORDS*SIZEOF_2DPOINT];
//.dsb 256-(*&255)
//_points2d       .dsb NB_MAX_COORDS*SIZEOF_2DPOINT
_points2d:
_points2aH          .dsb NB_MAX_COORDS
_points2aV          .dsb NB_MAX_COORDS
_points2dH          .dsb NB_MAX_COORDS
_points2dL          .dsb NB_MAX_COORDS

//char particules[NB_MAX_SEGMENTS*SIZEOF_PARTICULE];
_particules:
_particulesPt       .dsb NB_MAX_PARTICULES
_particulesChar     .dsb NB_MAX_PARTICULES

_faces:
_facesPt1           .dsb NB_MAX_FACES
_facesPt2           .dsb NB_MAX_FACES
_facesPt3           .dsb NB_MAX_FACES
_facesChar          .dsb NB_MAX_FACES

; .text
/*
//  void doFastProjection(){
_doFastProjection:
.(
//  	unsigned char ii = 0;

//  	for (ii = nbPoints-1; ii< 0; ii--){

    ldx _nbPoints
    dex
    txa ; ii = nbPoints - 1
    asl
    asl ; ii * SIZEOF_3DPOINT (4)
    clc
    adc #$03
    tay

    ldx _nbPoints
    dex
    txa ; ii = nbPoints - 1
    asl
    asl ; ii * SIZEOF_2DPOINT (4)
    clc
    adc #$03
    tax

dofastprojloop:
//          Status = points3d[ii*SIZEOF_3DPOINT + 3]
        dey
//  		PointZ = points3d[ii*SIZEOF_3DPOINT + 2];
        lda (ptrpt3),y
        sta _PointZ
        dey
//  		PointY = points3d[ii*SIZEOF_3DPOINT + 1];
        lda (ptrpt3),y
        sta _PointY
        dey
//  		PointX = points3d[ii*SIZEOF_3DPOINT + 0];
        lda (ptrpt3),y
        sta _PointX
        dey

//  		project();
        jsr _project

        tya
        pha
        txa
        tay

#ifndef HRSDEMO
 //  		points2d[ii*SIZEOF_2DPOINT + 1] = ResY;

        lda _Norm+1
        sta (ptrpt2), y
        dey

        lda _Norm
        sta (ptrpt2), y
        dey

        lda _ResY
        sta (ptrpt2), y
//  		points2d[ii*SIZEOF_2DPOINT + 0] = ResX;
        dey
        lda _ResX
        sta (ptrpt2), y

#else
        lda _ResY+1
        sta (ptrpt2), y
        dey

        lda _ResY
        sta (ptrpt2), y
        dey

        lda _ResX+1
        sta (ptrpt2), y
//  		points2d[ii*SIZEOF_2DPOINT + 0] = ResX;
        dey
        lda _ResX
        sta (ptrpt2), y

#endif
        tya
        tax
        pla
        tay
//  	}
    dex
    txa
    cmp #$FF
    bne dofastprojloop   ;; FIXME : does not allows more than 127 points
dofastprojdone:
//  }
.)
    rts




// void glProject (char *tabpoint2D, char *tabpoint3D, unsigned char nbPoints, unsigned char options);
_glProject
.(
	ldx #6 : lda #4 : jsr enter :
	ldy #0 : lda (ap),y : sta reg0 : sta ptrpt2L : iny : lda (ap),y : sta reg0+1 : sta ptrpt2H :
	ldy #2 : lda (ap),y : sta reg0 : sta ptrpt3L : iny : lda (ap),y : sta reg0+1 : sta ptrpt3H :
	ldy #4 : lda (ap),y : sta tmp0 : sta _nbPoints ; iny : lda (ap),y : sta tmp0+1 :
	ldy #6 : lda (ap),y : sta tmp0 : sta _projOptions ; iny : lda (ap),y : sta tmp0+1 :

	jsr _doFastProjection
	jmp leave :
.)

*/
