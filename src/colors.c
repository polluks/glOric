
#include "config.h"

#ifdef USE_ZBUFFER
#include "render\zbuffer.h"
#endif

#ifdef USE_COLOR

#include "render\colors.h"

unsigned char tab_color [] = {INK_CYAN, INK_YELLOW, INK_MAGENTA, INK_BLUE, INK_GREEN, INK_RED, INK_CYAN, INK_YELLOW} ;

void spreadHiresAttributes(){
	int ii, jj;
	for (ii = 1; ii<LORES_SCREEN_HEIGHT-4 ; ii++){
#ifdef USE_ZBUFFER
		fbuffer[ii*LORES_SCREEN_WIDTH]=HIRES_50Hz;
#else
		poke (LORES_SCREEN_ADDRESS+(ii*LORES_SCREEN_WIDTH)+0,HIRES_50Hz);
#endif // USE_ZBUFFER
		// for (jj = 0; jj < 8; jj++) {
		// 	poke (HIRES_SCREEN_ADDRESS+((ii*8+jj)*LORES_SCREEN_WIDTH)+1, tab_color[jj]);
		// 	poke (HIRES_SCREEN_ADDRESS+((ii*8+jj)*LORES_SCREEN_WIDTH)+2, TEXT_50Hz);
		// }
	}
}
void prepare_colors() {
    int ii, jj;

	for (ii = 1; ii<LORES_SCREEN_HEIGHT-4 ; ii++){
		poke (LORES_SCREEN_ADDRESS+(ii*LORES_SCREEN_WIDTH)+0,HIRES_50Hz);
		for (jj = 0; jj < 8; jj++) {
			poke (HIRES_SCREEN_ADDRESS+((ii*8+jj)*LORES_SCREEN_WIDTH)+1, tab_color[jj]);
			poke (HIRES_SCREEN_ADDRESS+((ii*8+jj)*LORES_SCREEN_WIDTH)+2, TEXT_50Hz);
		}
	}
}
void initColors(){

    prepare_colors();

    change_char('c', 0x7F, 0x00, 0x00, 0x7F, 0x00, 0x00, 0x7F, 0x00);
	change_char('y', 0x00, 0x7F, 0x00, 0x00, 0x00, 0x00, 0x00, 0x7F);
	change_char('m', 0x00, 0x00, 0x7F, 0x00, 0x00, 0x7F, 0x00, 0x00);
	change_char('r', 0x00, 0x55, 0x7F, 0x00, 0x55, 0x7F, 0x00, 0x00);
	change_char('g', 0x55, 0xAA, 0x00, 0x00, 0x7F, 0x00, 0x55, 0xAA);
	change_char('b', 0xAA, 0x00, 0x00, 0x7F, 0x00, 0x00, 0x55, 0x00);

}


#endif