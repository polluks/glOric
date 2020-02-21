#include "lib.h"

#include "glConf.h"

/*
 // Point 3D Coordinates
extern signed int PointX;
extern signed int PointY;
extern signed int PointZ;

//unsigned char projOptions=0;
extern unsigned char projOptions;

 // Point 2D Projected Coordinates
extern signed int ResX;
extern signed int ResY;
*/

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

// void projectPoint(signed char x, signed char y , signed char z, signed char *ah, signed char *av) {
//     *ah = x;
//     *av = y;
// }

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

}
