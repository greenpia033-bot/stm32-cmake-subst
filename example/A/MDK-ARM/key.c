#include "key.h"

static KeyObj key_list[]={
	{KEY_1_GPIO_Port,KEY_1_Pin,KEY_EVENT_1,0,DEBOUNCE_MS},
	{KEY_2_GPIO_Port,KEY_2_Pin,KEY_EVENT_2,0,DEBOUNCE_MS},
	{KEY_3_GPIO_Port,KEY_3_Pin,KEY_EVENT_3,0,DEBOUNCE_MS},
	{KEY_4_GPIO_Port,KEY_4_Pin,KEY_EVENT_4,0,DEBOUNCE_MS}
};

static const uint16_t key_num = sizeof(key_list)/sizeof(KeyObj);

uint16_t last_time = 0;
uint16_t current_time = 0;

KeyEvent Key_Scan(void)
{
	uint16_t i = 0;
	KeyEvent result = KEY_EVENT_NON;
	
	last_time = current_time;
	current_time = HAL_GetTick();
	uint16_t wait_time = current_time - last_time;
		
	
	for(i = 0;i < key_num;i++)
	{
		KeyObj* k = &key_list[i];
		uint16_t isPressed = (HAL_GPIO_ReadPin(k->gpio,k->pin)==GPIO_PIN_RESET);
		
		switch(k->state)
		{
			case 0:
				if(isPressed)
				{
					k->state=1;
					k->tick=DEBOUNCE_MS;
				}
				break;
			case 1:
				if(!isPressed)
				{
					k->state=0;
				}
				else{
					if(k->tick>wait_time)
					{
						k->tick -= wait_time;
					}
					else{
						k->state=2;
						result=k->event;
					}
				}
				break;
			case 2:
				if(!isPressed)
				{
					k->state=0;
				}
				else{
					result=k->event;
				}
				break;
			default:
				break;
		}
	}
	
	return result;
}
