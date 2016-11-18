#ifndef MAIN_H
#define MAIN_H

#ifndef NULL
#define NULL (void *)0
#endif

#define APP_START_ADDRESS               0x20008000

#define APP_MAXIMUM_SIZE                0x10000

#define MIN(a,b)                        ((a)<(b)?(a):(b))

/*
   Clocking:
   SYSCLK = HSI / PLL_M * PLL_N / PLL_P == 84 Mhz
*/
#define PLL_M           16      // 16
#define PLL_N           336     // 336
#define PLL_P           4       // 4
#define PLL_Q           7       // 7

//typedef unsigned int size_t;

//typedef void (*app_call_t)(void);

//void memcpy (void * dest, void * src, size_t size);

#endif /* MAIN_H */
