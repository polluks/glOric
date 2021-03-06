#include "config.h"
#include "profile.h"

#ifdef PROFBENCH

#include "glOric.h"
#include "data\geom.h"
#include "util\keyboard.h"
#include "data\traj.h"


void profbench() {
    int ii;
    unsigned char state, kk;
    change_char(36, 0x80, 0x40, 020, 0x10, 0x08, 0x04, 0x02, 0x01);

    nbPoints        = 0;
    nbSegments   = 0;
    nbFaces      = 0;
    nbParticules = 0;

    addGeom(0, 0, 0, 12, 8, 4, 0, geomHouse);
    addGeom(24, 12, 0, 9, 9, 9, 0, geomPine);
    addGeom(24, -24, 0, 6, 6, 12, 0, geomTower);
    
    // printf ("%d Points, %d Particules, %d Segments, %d Faces\n", nbPoints, nbParticules, nbSegments, nbFaces); get();

    text();

    initColors();


    CamPosX = 74;
    CamPosY = 0;
    CamPosZ = 6;

    CamRotZ = -128;
    CamRotX = 0;



    kernelInit();

    ProfilerInitialize();

    ii = 74; 
    state = 0;

    while (state != 5) {

        ProfilerNextFrame();

        PROFILE_ENTER(ROUTINE_GLOBAL);
        switch (state) {
            case 0:
                if (ii > 0) {
                    CamPosX -- ; 
                    ii--;
                } else {
                    ii = 32; 
                    state = 1;
                }
            break;
            case 1:
                if (ii > 0) {
                    CamRotZ += 4 ; 
                    ii--;
                } else {
                    ii = 24; 
                    state = 2;
                }
            break;
            case 2:
                if (ii > 0) {
                    CamPosX ++ ; 
                    ii--;
                } else {
                    ii = 32; 
                    state = 3;
                }
            break;
            case 3:
                if (ii > 0) {
                    CamRotZ += 4 ; 
                    ii--;
                } else {
                    ii = 64; 
                    state = 4;
                    kk=0;
                }
            break;
            case 4:
                if (ii > 0) {
                    CamPosX = traj[kk++];
                    CamPosY = traj[kk++];
                    CamRotZ = traj[kk++];
                    kk       = kk % (NB_POINTS_TRAJ * SIZE_POINTS_TRAJ);
                    ii--;
                } else {
                    ii = 64; 
                    state = 5;
                }
            break;
        }
         PROFILE_ENTER(ROUTINE_KEYEVENT);
        keyEvent();
        PROFILE_LEAVE(ROUTINE_KEYEVENT);

        PROFILE_ENTER(ROUTINE_GLPROJECTARRAYS);
        glProjectArrays();
        PROFILE_LEAVE(ROUTINE_GLPROJECTARRAYS);


        PROFILE_ENTER(ROUTINE_INITSCREENBUFFERS);
        initScreenBuffers();
        PROFILE_LEAVE(ROUTINE_INITSCREENBUFFERS);

        glDrawFaces();
        glDrawSegments();
        glDrawParticules();

        PROFILE_ENTER(ROUTINE_BUFFER2SCREEN);
        buffer2screen((void*)ADR_BASE_LORES_SCREEN);
        PROFILE_LEAVE(ROUTINE_BUFFER2SCREEN);

        PROFILE_LEAVE(ROUTINE_GLOBAL);

        ProfilerDisplay();

    }
    
    ProfilerTerminate();
    cls();
    kernelExit();
}
void move(char key) {
    switch (key) {
        case 8:  // gauche => tourne gauche
            CamRotZ += 4;
            break;
        case 9:  // droite => tourne droite
            CamRotZ -= 4;
            break;
        case 10:  // bas => recule
            backward();
            break;
        case 11:  // haut => avance
            forward();
            break;
        case 80:  // P
            CamPosZ += 1;
            break;
        case 59:  // ;
            CamPosZ -= 1;
            break;
        case 81:  // Q
            CamRotX += 2;
            break;
        case 65:  // A
            CamRotX -= 2;
            break;
        case 90:  // Z
            shiftLeft();
            break;
        case 88:  // X
            shiftRight();
            break;
        }
}

#endif // PROFBENCH