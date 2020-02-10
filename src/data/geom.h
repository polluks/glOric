#ifndef GEOM_H
#define GEOM_H

#ifdef HRSDEMO
#define CUBE_SIZE 4
#define NB_POINTS_CUBE 8
#define NB_SEGMENTS_CUBE 12
#define NB_FACES_CUBE 12
extern const char ptsCube[];
extern const char segCube[];
extern const char facCube[];
#endif

extern void addPlan(signed char X, signed char Y, unsigned char L, signed char orientation, char char2disp);


#endif