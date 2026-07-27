/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.h
  * @brief          : Header for main.c file.
  *                   This file contains the common defines of the application.
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2026 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __MAIN_H
#define __MAIN_H

#ifdef __cplusplus
extern "C" {
#endif

/* Includes ------------------------------------------------------------------*/
#include "stm32g4xx_hal.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */

/* USER CODE END Includes */

/* Exported types ------------------------------------------------------------*/
/* USER CODE BEGIN ET */

/* USER CODE END ET */

/* Exported constants --------------------------------------------------------*/
/* USER CODE BEGIN EC */

/* USER CODE END EC */

/* Exported macro ------------------------------------------------------------*/
/* USER CODE BEGIN EM */

/* USER CODE END EM */

/* Exported functions prototypes ---------------------------------------------*/
void Error_Handler(void);

/* USER CODE BEGIN EFP */

/* USER CODE END EFP */

/* Private defines -----------------------------------------------------------*/
#define LED_8_Pin GPIO_PIN_15
#define LED_8_GPIO_Port GPIOC
#define KEY_4_Pin GPIO_PIN_0
#define KEY_4_GPIO_Port GPIOA
#define KEY_1_Pin GPIO_PIN_0
#define KEY_1_GPIO_Port GPIOB
#define KEY_2_Pin GPIO_PIN_1
#define KEY_2_GPIO_Port GPIOB
#define KEY_3_Pin GPIO_PIN_2
#define KEY_3_GPIO_Port GPIOB
#define LED_1_Pin GPIO_PIN_8
#define LED_1_GPIO_Port GPIOC
#define LED_2_Pin GPIO_PIN_9
#define LED_2_GPIO_Port GPIOC
#define LED_3_Pin GPIO_PIN_10
#define LED_3_GPIO_Port GPIOC
#define LED_LAT_Pin GPIO_PIN_2
#define LED_LAT_GPIO_Port GPIOD

/* USER CODE BEGIN Private defines */
/* Keil MDK -> GCC compatibility: __nop() is a Keil intrinsic, CMSIS uses __NOP() */
#define __nop()  __NOP()
/* USER CODE END Private defines */

#ifdef __cplusplus
}
#endif

#endif /* __MAIN_H */
