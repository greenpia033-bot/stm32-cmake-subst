#ifndef __LED_H__
#define __LED_H__

#include "main.h"

void Led_Init(void);
void Led_ON(uint16_t led);
void Led_OFF(uint16_t led);
void Led_Toggle(uint16_t led);

#endif
