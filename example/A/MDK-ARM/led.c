#include "led.h"

void Led_Init(void)
{
	HAL_GPIO_WritePin(LED_LAT_GPIO_Port,LED_LAT_Pin,GPIO_PIN_SET);
	HAL_GPIO_WritePin(LED_1_GPIO_Port,GPIO_PIN_All,GPIO_PIN_SET);
	HAL_GPIO_WritePin(LED_LAT_GPIO_Port,LED_LAT_Pin,GPIO_PIN_RESET);
}

void Led_ON(uint16_t led)
{
	HAL_GPIO_WritePin(LED_LAT_GPIO_Port,LED_LAT_Pin,GPIO_PIN_SET);
	HAL_GPIO_WritePin(LED_1_GPIO_Port,LED_1_Pin<<led,GPIO_PIN_RESET);
	HAL_GPIO_WritePin(LED_LAT_GPIO_Port,LED_LAT_Pin,GPIO_PIN_RESET);
}	

void Led_OFF(uint16_t led)
{
	HAL_GPIO_WritePin(LED_LAT_GPIO_Port,LED_LAT_Pin,GPIO_PIN_SET);
	HAL_GPIO_WritePin(LED_1_GPIO_Port,LED_1_Pin<<led,GPIO_PIN_SET);
	HAL_GPIO_WritePin(LED_LAT_GPIO_Port,LED_LAT_Pin,GPIO_PIN_RESET);
}	
void Led_Toggle(uint16_t led)
{
	HAL_GPIO_WritePin(LED_LAT_GPIO_Port,LED_LAT_Pin,GPIO_PIN_SET);
	HAL_GPIO_TogglePin(LED_1_GPIO_Port,LED_1_Pin<<led);
	HAL_GPIO_WritePin(LED_LAT_GPIO_Port,LED_LAT_Pin,GPIO_PIN_RESET);
}
