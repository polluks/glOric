#include "lib.h"

#include "glConf.h"
#include "util/util.h"

char geomTriangle []= {
/* Nb Coords = */ 3,
/* Nb Faces = */ 1,
/* Nb Segments = */ 3,
/* Nb Particules = */ 0,
// Coord List : X, Y, Z, unused
-1, 0, 0, 0, 
 1, 0, 0, 0,
 0, 0, 2, 0,
// Face List : idxPoint1, idxPoint2, idxPoint3, character 
 0, 1, 2, '.',
// Segment List : idxPoint1, idxPoint2, idxPoint3, character 
0, 2, '/', 0,
1, 2, '/', 0,
0, 1, '-', 0,
// Particule List : idxPoint1, character 
};

 // Camera Position
extern signed char CamPosX;
extern signed char CamPosY;
extern signed char CamPosZ;

 // Camera Orientation
extern signed char CamRotZ;
extern signed char CamRotX;


extern signed char points3dX[];
extern signed char points3dY[];
extern signed char points3dZ[];

extern signed char points2aH[];
extern signed char points2aV[];
extern signed char points2dH[];
extern signed char points2dL[];

extern unsigned char nbCoords;
extern unsigned char nbSegments;
extern unsigned char nbParticules;
extern unsigned char nbFaces;

extern unsigned char segmentsPt1[];
extern unsigned char segmentsPt2[];
extern unsigned char segmentsChar[];

extern unsigned char particulesPt[];
extern unsigned char particulesChar[];

extern unsigned char facesPt1[];
extern unsigned char facesPt2[];
extern unsigned char facesPt3[];
extern unsigned char facesChar[];

extern signed char A1X;
extern signed char A1Y;
extern signed char A1destX;
extern signed char A1destY;
extern signed char A1dX;
extern signed char A1dY;
extern signed char A1err;
extern signed char A1sX;
extern signed char A1sY;
extern char        A1arrived;

extern signed char A2X;
extern signed char A2Y;
extern signed char A2destX;
extern signed char A2destY;
extern signed char A2dX;
extern signed char A2dY;
extern signed char A2err;
extern signed char A2sX;
extern signed char A2sY;
extern char        A2arrived;

extern unsigned char distface;
extern unsigned char distseg;
extern char          ch2disp;
extern    signed char   P1X, P1Y, P2X, P2Y, P3X, P3Y;
extern     signed char   P1AH, P1AV, P2AH, P2AV, P3AH, P3AV;

#define SIZEOF_3DPOINT 4
#define SIZEOF_SEGMENT 4
#define SIZEOF_PARTICULE 2
#define SIZEOF_2DPOINT 4
#define SIZEOF_FACE 4

void addGeom(
    signed char   X,
    signed char   Y,
    signed char   Z,
    unsigned char sizeX,
    unsigned char sizeY,
    unsigned char sizeZ,
    unsigned char orientation,
    char          geom[]) {

    int kk;

    for (kk=0; kk< geom[0]; kk++){
        points3dX[nbCoords] = X + ((orientation == 0) ? sizeX * geom[4+kk*SIZEOF_3DPOINT+0]: sizeY * geom[4+kk*SIZEOF_3DPOINT+1]);// X + ii;
        points3dY[nbCoords] = Y + ((orientation == 0) ? sizeY * geom[4+kk*SIZEOF_3DPOINT+1]: sizeX * geom[4+kk*SIZEOF_3DPOINT+0]);// Y + jj;
        points3dZ[nbCoords] = Z + geom[4+kk*SIZEOF_3DPOINT+2]*sizeZ;// ;
        nbCoords++;
    }
    for (kk=0; kk< geom[1]; kk++){
        facesPt1[nbFaces] = nbCoords - (geom[0]-geom[4+geom[0]*SIZEOF_3DPOINT+kk*SIZEOF_FACE+0]);  // Index Point 1
        facesPt2[nbFaces] = nbCoords - (geom[0]-geom[4+geom[0]*SIZEOF_3DPOINT+kk*SIZEOF_FACE+1]);  // Index Point 2
        facesPt3[nbFaces] = nbCoords - (geom[0]-geom[4+geom[0]*SIZEOF_3DPOINT+kk*SIZEOF_FACE+2]);  // Index Point 3
        facesChar[nbFaces] = geom[4+geom[0]*SIZEOF_3DPOINT+kk*SIZEOF_FACE+3];  // Character
        nbFaces++;
    }
    for (kk=0; kk< geom[2]; kk++){
        segmentsPt1[nbSegments] = nbCoords - (geom[0]-geom[4+geom[0]*SIZEOF_3DPOINT+geom[1]*SIZEOF_FACE+kk*SIZEOF_SEGMENT + 0]);  // Index Point 1
        segmentsPt2[nbSegments] = nbCoords - (geom[0]-geom[4+geom[0]*SIZEOF_3DPOINT+geom[1]*SIZEOF_FACE+kk*SIZEOF_SEGMENT + 1]);  // Index Point 2
        segmentsChar[nbSegments] = geom[4+geom[0]*SIZEOF_3DPOINT+geom[1]*SIZEOF_FACE+kk*SIZEOF_SEGMENT + 2]; // Character
        nbSegments++;
    }
    for (kk=0; kk< geom[3]; kk++){
        particulesPt[nbParticules] = nbCoords - (geom[0]-geom[4 + geom[0]*SIZEOF_3DPOINT + geom[1]*SIZEOF_FACE + geom[2]*SIZEOF_SEGMENT + kk*SIZEOF_PARTICULE + 0]);  // Index Point
        particulesChar[nbParticules] = geom[4 + geom[0]*SIZEOF_3DPOINT + geom[1]*SIZEOF_FACE + geom[2]*SIZEOF_SEGMENT + kk*SIZEOF_PARTICULE + 1]; // Character
        nbParticules++;
    }
}

void glProjectArrays(){
    unsigned char ii;
    signed char x, y, z;
    signed char ah, av;
    unsigned int dist ;
    unsigned char options=0;

    for (ii = 0; ii < nbCoords; ii++){
        x = points3dX[ii];
        y = points3dY[ii];
        z = points3dZ[ii];

        projectPoint(x, y, z, options, &ah, &av, &dist);

        points2aH[ii] = ah;
        points2aV[ii] = av;
        points2dH[ii] = (signed char)((dist & 0xFF00)>>8) && 0x00FF;
        points2dL[ii] = (signed char) (dist & 0x00FF);

    }
}
#define DOLLAR 36

void lrDrawLine() {

    signed char e2;
    char        ch2dsp;

    A1X     = P1X;
    A1Y     = P1Y;
    A1destX = P2X;
    A1destY = P2Y;
    A1dX    = abs(P2X - P1X);
    A1dY    = -abs(P2Y - P1Y);
    A1sX    = P1X < P2X ? 1 : -1;
    A1sY    = P1Y < P2Y ? 1 : -1;
    A1err   = A1dX + A1dY;

    if ((A1err > 64) || (A1err < -63))
        return;

    if ((ch2disp == '/') && (A1sX == -1)) {
        ch2dsp = DOLLAR;
    } else {
        ch2dsp = ch2disp;
    }

    while (1) {  // loop
        //printf ("plot [%d, %d] %d %d\n", _A1X, _A1Y, distseg, ch2disp);get ();          
#ifdef USE_ZBUFFER
        zplot(A1X, A1Y, distseg, ch2dsp);
#else
        // TODO : plot a point with no z-buffer
#endif
        if ((A1X == A1destX) && (A1Y == A1destY))
            break;
        //e2 = 2*err;
        e2 = (A1err < 0) ? (
                ((A1err & 0x40) == 0) ? (
                                                0x80)
                                        : (
                                            A1err << 1))
            : (
                ((A1err & 0x40) != 0) ? (
                                                0x7F)
                                        : (
                                                A1err << 1));
        if (e2 >= A1dY) {
            A1err += A1dY;  // e_xy+e_x > 0
            A1X += A1sX;
        }
        if (e2 <= A1dX) {  // e_xy+e_y < 0
            A1err += A1dX;
            A1Y += A1sY;
        }
    }
}

void glDrawSegments() {
    unsigned char ii = 0;
    unsigned char jj = 0;
    unsigned char idxPt1, idxPt2;
    unsigned char offPt1, offPt2;
    int           dmoy;


    for (ii = 0; ii < nbSegments; ii++) {

        idxPt1    = segmentsPt1[ii];
        idxPt2    = segmentsPt2[ii];
        ch2disp = segmentsChar[ii];

        // dmoy = (d1+d2)/2;

        dmoy = points2dL[idxPt1];
        dmoy += points2dL[idxPt2];
        dmoy = dmoy >> 1;
        

        //if (dmoy >= 256) {
        if ((dmoy & 0xFF00) != 0)
            continue;
        distseg = (unsigned char)((dmoy)&0x00FF);
        distseg--;  // FIXME

        P1AH = points2aH[idxPt1];
        P1AV = points2aV[idxPt1];

        P2AH = points2aH[idxPt2];
        P2AV = points2aV[idxPt2];

        P1X = (SCREEN_WIDTH - P1AH) >> 1;
        P1Y = (SCREEN_HEIGHT - P1AV) >> 1;
        P2X = (SCREEN_WIDTH - P2AH) >> 1;
        P2Y = (SCREEN_HEIGHT - P2AV) >> 1;

        // printf ("dl ([%d, %d] , [%d, %d] => %d c=%d\n", P1X, P1Y, P2X, P2Y, distseg, char2disp); get();
        lrDrawLine();

    }
}

void main() {

    signed char ah, av;
    unsigned int dist;
    unsigned char options=0;
    unsigned char ii=0;

    CamPosX = 0;
    CamPosY = 0;
    CamPosZ = 0;

    CamRotZ = 0;
    CamRotX = 0;

    get();
/*
    projectPoint(2, 0, 0, options, &ah, &av, &dist);
    printf ("%d %d %d\n", ah, av, dist);

    projectPoint(0, 2, 0, options, &ah, &av, &dist);
    printf ("%d %d %d\n", ah, av, dist);

    projectPoint(2, 2, 0, options, &ah, &av, &dist);
    printf ("%d %d %d\n", ah, av, dist);

    projectPoint(4, 4, 0, options, &ah, &av, &dist);
    printf ("%d %d %d\n", ah, av, dist);

    projectPoint(8, 8, 0, options, &ah, &av, &dist);
    printf ("%d %d %d\n", ah, av, dist);
*/

/*
    points3dX[nbCoords] = 2;
    points3dY[nbCoords] = 0;
    points3dZ[nbCoords] = 0;
    nbCoords++;

    points3dX[nbCoords] = 0;
    points3dY[nbCoords] = 2;
    points3dZ[nbCoords] = 0;
    nbCoords++;

    points3dX[nbCoords] = 2;
    points3dY[nbCoords] = 2;
    points3dZ[nbCoords] = 0;
    nbCoords++;

    points3dX[nbCoords] = 4;
    points3dY[nbCoords] = 4;
    points3dZ[nbCoords] = 0;
    nbCoords++;

    points3dX[nbCoords] = 8;
    points3dY[nbCoords] = 8;
    points3dZ[nbCoords] = 0;
    nbCoords++;


    glProjectArrays();


    for (ii=0; ii < nbCoords; ii++) {
        printf ("%d %d %d => %d %d %d\n", points3dX[ii], points3dY[ii], points3dZ[ii], points2aH[ii], points2aV[ii], points2dL[ii]);
    }
*/
    initScreenBuffers();
    addGeom(3, 0, 0, // X, Y,Z,
    1, 1, 1, //sizeX,sizeY,sizeZ,
    1, //orientation
    geomTriangle);
    glProjectArrays();
    for (ii=0; ii < nbCoords; ii++) {
        printf ("%d %d %d => %d %d %d\n", points3dX[ii], points3dY[ii], points3dZ[ii], points2aH[ii], points2aV[ii], points2dL[ii]);
    }
    get ();
    glDrawSegments();
    buffer2screen((void*)ADR_BASE_LORES_SCREEN);
}
