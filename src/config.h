
#ifndef CONFIG_H
#define CONFIG_H

// Choose amongst TEXTDEMO, LRSDEMO, HRSDEMO, COLORDEMO, RTDEMO, PROFBENCH
#define PROFBENCH

/*
 *  SCREEN DIMENSION
 */

#ifdef TEXTDEMO
#define SCREEN_WIDTH 40
#define SCREEN_HEIGHT 26
#define USE_REWORKED_BUFFERS
#define SAVE_ZERO_PAGE
#endif

#ifdef HRSDEMO
#define USE_HIRES_RASTER
#define SCREEN_WIDTH 240
#define SCREEN_HEIGHT 200
#define SAVE_ZERO_PAGE
#endif

#ifdef LRSDEMO
#define ANGLEONLY
#define USE_ZBUFFER
#define USE_COLLISION_DETECTION
#define USE_REWORKED_BUFFERS
#define SCREEN_WIDTH 40
#define SCREEN_HEIGHT 26
#endif



#ifdef COLORDEMO
#define ANGLEONLY
#define USE_ZBUFFER
#define USE_COLOR
#define USE_COLLISION_DETECTION
#define USE_REWORKED_BUFFERS
#define USE_HORIZON
#define SCREEN_WIDTH 40
#define SCREEN_HEIGHT 26
#endif


#ifdef RTDEMO
#define ANGLEONLY
#define USE_ZBUFFER
#define USE_RT_KEYBOARD
#define USE_COLLISION_DETECTION
#define USE_COLOR
#define USE_REWORKED_BUFFERS
#define SCREEN_WIDTH 40
#define SCREEN_HEIGHT 26
#endif // RTDEMO

#ifdef PROFBENCH
#define ANGLEONLY
#define USE_ZBUFFER
#define USE_RT_KEYBOARD
#undef USE_COLLISION_DETECTION
#define USE_COLOR
#define USE_REWORKED_BUFFERS
#define USE_PROFILER
#define SCREEN_WIDTH 40
#define SCREEN_HEIGHT 26
#endif // PROFBENCH


/*
 *  BUFFERS DIMENSION
 */

#define NB_MAX_POINTS 64
#define NB_MAX_SEGMENTS 64
#define NB_MAX_FACES 64
#define NB_MAX_PARTICULES 64
/*
 *  SCREEN MEMORY //BB80
 */
#define ADR_BASE_LORES_SCREEN 48040  

/*
 *  ELEMENTS SIZE
 */

#define SIZEOF_3DPOINT 4
#define SIZEOF_SEGMENT 4
#define SIZEOF_PARTICULE 2
#define SIZEOF_2DPOINT 4
#define SIZEOF_FACE 4

#define COLUMN_OF_COLOR_ATTRIBUTE 2
#define NB_LESS_LINES_4_COLOR 4



#ifdef TARGET_ORIX
#undef USE_ASM_HFILL
#define USE_C_HFILL
#define USE_C_INITFRAMEBUFFER
#undef USE_ASM_INITFRAMEBUFFER
#define USE_C_ZPLOT
#undef  USE_ASM_ZPLOT
#define USE_C_ZLINE
#undef USE_ASM_ZLINE
#define USE_C_BRESFILL
#undef USE_ASM_BRESFILL
#define USE_C_ZBUFFER
#undef USE_ASM_ZBUFFER
#undef USE_ASM_BUFFER2SCREEN
#define USE_C_ARRAYSPROJECT
#undef  USE_ASM_ARRAYSPROJECT
#define USE_C_DRAWLINE
#undef USE_ASM_DRAWLINE
#define USE_C_PLOT
#undef USE_ASM_PLOT
#define USE_C_GUESSIFFACE2BEDRAWN
#undef USE_ASM_GUESSIFFACE2BEDRAWN
#define USE_C_SORTPOINTS
#undef USE_ASM_SORTPOINTS
#define USE_C_ANGLE2SCREEN
#undef USE_ASM_ANGLE2SCREEN
#define USE_C_FILL8
#undef USE_ASM_FILL8
#define USE_C_RETRIEVEFACEDATA
#undef USE_ASM_RETRIEVEFACEDATA
#define USE_C_GLDRAWFACES
#undef USE_ASM_GLDRAWFACES
#define USE_C_GLDRAWSEGMENTS
#undef USE_ASM_GLDRAWSEGMENTS
#define USE_C_ISA1RIGHT1
#undef USE_ASM_ISA1RIGHT1
#define USE_C_ISA1RIGHT3
#undef USE_ASM_ISA1RIGHT3
#else
#ifdef ALL_C
#define USE_C_HFILL
#undef USE_ASM_HFILL
#define USE_C_INITFRAMEBUFFER
#undef USE_ASM_INITFRAMEBUFFER
#define USE_C_ZPLOT
#undef  USE_ASM_ZPLOT
#define USE_C_ZLINE
#undef USE_ASM_ZLINE
#define USE_C_BRESFILL
#undef USE_ASM_BRESFILL
#define USE_C_ZBUFFER
#undef USE_ASM_ZBUFFER
#define USE_C_BUFFER2SCREEN
#undef USE_ASM_BUFFER2SCREEN
#define USE_C_ARRAYSPROJECT
#undef  USE_ASM_ARRAYSPROJECT
#define USE_C_DRAWLINE
#undef USE_ASM_DRAWLINE
#define USE_C_PLOT
#undef USE_ASM_PLOT
#define USE_C_GUESSIFFACE2BEDRAWN
#undef USE_ASM_GUESSIFFACE2BEDRAWN
#define USE_C_SORTPOINTS
#undef USE_ASM_SORTPOINTS
#define USE_C_ANGLE2SCREEN
#undef USE_ASM_ANGLE2SCREEN
#define USE_C_FILL8
#undef USE_ASM_FILL8
#define USE_C_RETRIEVEFACEDATA
#undef USE_ASM_RETRIEVEFACEDATA
#define USE_C_GLDRAWFACES
#undef USE_ASM_GLDRAWFACES
#define USE_C_GLDRAWSEGMENTS
#undef USE_ASM_GLDRAWSEGMENTS
#define USE_C_ISA1RIGHT1
#undef USE_ASM_ISA1RIGHT1
#define USE_C_ISA1RIGHT3
#undef USE_ASM_ISA1RIGHT3

#else 
#ifdef ALL_ASM
#undef USE_C_HFILL
#define USE_ASM_HFILL
#undef USE_C_INITFRAMEBUFFER
#define USE_ASM_INITFRAMEBUFFER
#undef USE_C_ZPLOT
#define  USE_ASM_ZPLOT
#undef USE_C_ZLINE
#define USE_ASM_ZLINE
#undef USE_C_BRESFILL
#define USE_ASM_BRESFILL
#undef USE_C_ZBUFFER
#define USE_ASM_ZBUFFER
#undef USE_C_BUFFER2SCREEN
#define USE_ASM_BUFFER2SCREEN
#undef USE_C_ARRAYSPROJECT
#define  USE_ASM_ARRAYSPROJECT
#undef USE_C_DRAWLINE
#define USE_ASM_DRAWLINE
#undef USE_C_PLOT
#define USE_ASM_PLOT
#undef USE_C_GUESSIFFACE2BEDRAWN
#define USE_ASM_GUESSIFFACE2BEDRAWN
#undef USE_C_SORTPOINTS
#define USE_ASM_SORTPOINTS
#undef USE_C_ANGLE2SCREEN
#define USE_ASM_ANGLE2SCREEN
#undef USE_C_FILL8
#define USE_ASM_FILL8
#undef USE_C_RETRIEVEFACEDATA
#define USE_ASM_RETRIEVEFACEDATA
#undef USE_C_GLDRAWFACES
#define USE_ASM_GLDRAWFACES
#undef USE_C_GLDRAWSEGMENTS
#define USE_ASM_GLDRAWSEGMENTS
#undef USE_C_ISA1RIGHT1
#define USE_ASM_ISA1RIGHT1
#undef USE_C_ISA1RIGHT3
#define USE_ASM_ISA1RIGHT3

#else

#undef USE_C_HFILL
#define USE_ASM_HFILL
#undef USE_C_INITFRAMEBUFFER
#define USE_ASM_INITFRAMEBUFFER
#undef USE_C_ZPLOT
#define  USE_ASM_ZPLOT
#undef USE_C_ZLINE
#define USE_ASM_ZLINE
#undef USE_C_BRESFILL
#define USE_ASM_BRESFILL
#undef USE_C_ZBUFFER
#define USE_ASM_ZBUFFER
#undef USE_C_BUFFER2SCREEN
#define USE_ASM_BUFFER2SCREEN
#undef USE_C_ARRAYSPROJECT
#define  USE_ASM_ARRAYSPROJECT
#undef USE_C_DRAWLINE
#define USE_ASM_DRAWLINE
#undef USE_C_PLOT
#define USE_ASM_PLOT
#undef USE_C_GUESSIFFACE2BEDRAWN
#define USE_ASM_GUESSIFFACE2BEDRAWN
#undef USE_C_SORTPOINTS
#define USE_ASM_SORTPOINTS
#undef USE_C_ANGLE2SCREEN
#define USE_ASM_ANGLE2SCREEN
#undef USE_C_FILL8
#define USE_ASM_FILL8
#undef USE_C_RETRIEVEFACEDATA
#define USE_ASM_RETRIEVEFACEDATA
#undef USE_C_GLDRAWFACES
#define USE_ASM_GLDRAWFACES
#undef USE_C_GLDRAWSEGMENTS
#define USE_ASM_GLDRAWSEGMENTS
#undef USE_C_ISA1RIGHT1
#define USE_ASM_ISA1RIGHT1
#undef USE_C_ISA1RIGHT3
#define USE_ASM_ISA1RIGHT3


#endif // ALL_ASM
#endif // ALL_C
#endif

#define USE_C_GLDRAWPARTICULES
#undef USE_ASM_GLDRAWPARTICULES


#define USE_C_BRESTYPE1
#undef USE_ASM_BRESTYPE1
#define USE_C_BRESTYPE2
#undef USE_ASM_BRESTYPE2
#define USE_C_BRESTYPE3
#undef USE_ASM_BRESTYPE3

#undef USE_C_REACHSCREEN
#define USE_ASM_REACHSCREEN
#undef USE_C_FILLFACE
#define USE_ASM_FILLFACE

#undef USE_C_AGENTSTEP
#define USE_ASM_AGENTSTEP

#undef USE_SATURATION



#undef USE_16BITS_PROJECTION
#define USE_8BITS_PROJECTION

/*
 * VISIBILITY LIMITS
 */
#define ANGLE_MAX 0xC0
#define ANGLE_VIEW 0xE0
#define ASM_ANGLE_MAX $C0
#define ASM_ANGLE_VIEW $E0



/*
 * ASCII TABLE
 */
#define DOLLAR 36

/*
 * KEYBOARD TABLE
 */

#define KEY_UP			1
#define KEY_LEFT		2
#define KEY_DOWN		3
#define KEY_RIGHT		4

#define KEY_LCTRL		5
#define KET_RCTRL		6
#define KEY_LSHIFT		7
#define KEY_RSHIFT		8
#define KEY_FUNCT		9


// This keys do have ASCII values, let s use them 

#define KEY_RETURN		$0d
#define KEY_ESC			$1b
#define KEY_DEL			$7f

#undef USE_MULTI40
#undef USE_RANDOM

#endif
