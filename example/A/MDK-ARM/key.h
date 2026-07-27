#ifndef __KEY_H__
#define __KEY_H__

#include "main.h"

#define DEBOUNCE_MS 10
#define LONGPRESSED_MS 500
#define REPEAT_MS 100

typedef enum{
	KEY_EVENT_NON,
	KEY_EVENT_1,
	KEY_EVENT_2,
	KEY_EVENT_3,
	KEY_EVENT_4
}KeyEvent;

typedef struct{
	GPIO_TypeDef* gpio;
	uint16_t pin;
	KeyEvent event;
	uint8_t state;
	int tick;
}KeyObj;

KeyEvent Key_Scan(void);

#endif
