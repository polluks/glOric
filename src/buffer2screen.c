#ifdef USE_C_BUFFER2SCREEN
void buffer2screen(char destAdr[]) {
    memcpy(destAdr, fbuffer, SCREEN_HEIGHT* SCREEN_WIDTH);
}
#endif
