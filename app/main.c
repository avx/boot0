#include "stm32f4xx.h"

#include "Precomp.h"
#include "Alloc.h"
#include "LzmaDec.h"

#include "main.h"

/* stage2 lzma image */
#include "stage2_img.h"

void SystemClockInit(void)
{
    /* Select regulator voltage output Scale 1 mode */
    RCC->APB1ENR |= RCC_APB1ENR_PWREN;
    PWR->CR |= PWR_CR_VOS;

    /* HCLK = SYSCLK / 1*/
    RCC->CFGR |= RCC_CFGR_HPRE_DIV1;

    /* PCLK2 = HCLK / 2? */
    RCC->CFGR |= RCC_CFGR_PPRE2_DIV1;

    /* PCLK1 = HCLK / 4? */
    RCC->CFGR |= RCC_CFGR_PPRE1_DIV2;

    /* Configure the main PLL */
    RCC->PLLCFGR = PLL_M | (PLL_N << 6) | (((PLL_P >> 1) -1) << 16) | (PLL_Q << 24);

    /* Enable the main PLL */
    RCC->CR |= RCC_CR_PLLON;

    /* Wait till the main PLL is ready */
    while((RCC->CR & RCC_CR_PLLRDY) == 0);

    /* Configure Flash prefetch, Instruction cache, Data cache and wait state */
    FLASH->ACR = FLASH_ACR_PRFTEN | FLASH_ACR_ICEN | FLASH_ACR_DCEN | FLASH_ACR_LATENCY_2WS;

    /* Select the main PLL as system clock source */
    RCC->CFGR &= (uint32_t)((uint32_t)~(RCC_CFGR_SW));
    RCC->CFGR |= RCC_CFGR_SW_PLL;

    /* Wait till the main PLL is used as system clock source */
//    while ((RCC->CFGR & (uint32_t)RCC_CFGR_SWS ) != RCC_CFGR_SWS_PLL);
}

__attribute__ ((noreturn)) void main()
{
    char *inBuffer  = (char *)STAGE2_LZMA_IMAGE;
    size_t inSize = STAGE2_LZMA_IMAGE_LEN;
    ELzmaStatus status;
    size_t outSize;
    char *p;

    SystemClockInit();

    outSize = MIN(((size_t)((unsigned char)inBuffer[LZMA_PROPS_SIZE]) + \
                  ((size_t)((unsigned char)inBuffer[LZMA_PROPS_SIZE+1])<<8) + \
                  ((size_t)((unsigned char)inBuffer[LZMA_PROPS_SIZE+2])<<24)), \
                  APP_MAXIMUM_SIZE);

    inSize -= (LZMA_PROPS_SIZE+8);
    inBuffer += (LZMA_PROPS_SIZE+8);

    /* Decompress stage2 into memory */
    LzmaDecode((void *)APP_START_ADDRESS, \
                &outSize,                 \
                inBuffer,                 \
                &inSize,                  \
                inBuffer,                 \
                LZMA_PROPS_SIZE,          \
                LZMA_FINISH_END,          \
                &status,                  \
                (ISzAlloc *)&g_Alloc);

    SCB->VTOR = APP_START_ADDRESS;

    __set_MSP(*(volatile uint32_t *)APP_START_ADDRESS);

    (*(void (**)())(APP_START_ADDRESS + 4))();

loop:
    goto loop;
}
