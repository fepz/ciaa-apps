/*
 * @brief FreeRTOS Blinky example
 *
 * @note
 * Copyright(C) NXP Semiconductors, 2013
 * All rights reserved.
 *
 * @par
 * Software that is described herein is for illustrative purposes only
 * which provides customers with programming information regarding the
 * LPC products.  This software is supplied "AS IS" without any warranties of
 * any kind, and NXP Semiconductors and its licensor disclaim any and
 * all warranties, express or implied, including all implied warranties of
 * merchantability, fitness for a particular purpose and non-infringement of
 * intellectual property rights.  NXP Semiconductors assumes no responsibility
 * or liability for the use of the software, conveys no license or rights under any
 * patent, copyright, mask work right, or any other intellectual property rights in
 * or to any products. NXP Semiconductors reserves the right to make changes
 * in the software without notification. NXP Semiconductors also makes no
 * representation or warranty that such application will be suitable for the
 * specified use without further testing or modification.
 *
 * @par
 * Permission to use, copy, modify, and distribute this software and its
 * documentation is hereby granted, under NXP Semiconductors' and its
 * licensor's relevant copyrights in the software, without fee, provided that it
 * is used in conjunction with NXP Semiconductors microcontrollers.  This
 * copyright, permission, and disclaimer notice must appear in all copies of
 * this code.
 */

//#include "board.h"
#include "FreeRTOS.h"
#include "task.h"
#include "sapi.h"         /* <= sAPI header */

/* The linker does not include this code in liblpc.a because nothing in it
 * references it... */
#define CRP_NO_CRP          0xFFFFFFFF
__attribute__ ((used,section(".crp"))) const unsigned int CRP_WORD = CRP_NO_CRP ;

/*****************************************************************************
 * Private types/enumerations/variables
 ****************************************************************************/

/*****************************************************************************
 * Public types/enumerations/variables
 ****************************************************************************/

/*****************************************************************************
 * Private functions
 ****************************************************************************/

/* Sets up system hardware */
static void prvSetupHardware(void)
{
	/* Inicializar la placa */
	boardConfig();

	/* Inicializar GPIOs */
	gpioConfig( 0, GPIO_ENABLE );

	/* Configuración de pines de salida para Leds de la CIAA-NXP */
	gpioConfig( LEDR, GPIO_OUTPUT );
	gpioConfig( LEDG, GPIO_OUTPUT );
	gpioConfig( LEDB, GPIO_OUTPUT );
	gpioConfig( LED1, GPIO_OUTPUT );
	gpioConfig( LED2, GPIO_OUTPUT );
	gpioConfig( LED3, GPIO_OUTPUT );

   /* Inicializar UART_USB a 115200 baudios */
   uartConfig( UART_USB, 115200 );
}

/* LED1 toggle thread */
static void vLEDTask1(void *pvParameters) {
	bool_t LedState = ON;

	while (1) {
		gpioWrite( LED1,  LedState);
		gpioWrite( LED3,  LedState);
        LedState = (bool_t) !LedState;

        vTaskDelay(500);
	}
}

/* LED1 toggle thread */
static void vLEDTask2(void *pvParameters) {
	bool_t LedState = ON;

	while (1) {
		gpioWrite( LED2,  LedState);
		gpioWrite( LEDB,  LedState);
        LedState = (bool_t) !LedState;

        uartWriteString( UART_USB, "Hola :)\r\n" );

		vTaskDelay(1000);
	}
}

/*****************************************************************************
 * Public functions
 ****************************************************************************/

/**
 * @brief	main routine for FreeRTOS blinky example
 * @return	Nothing, function should not exit
 */
int main(void)
{
	prvSetupHardware();

	/* LED1 toggle thread */
	xTaskCreate(vLEDTask1, "vTaskLed1", configMINIMAL_STACK_SIZE,
			NULL, (tskIDLE_PRIORITY + 1UL), (TaskHandle_t *) NULL);

	/* LED1 toggle thread */
	xTaskCreate(vLEDTask2, "vTaskLed2", configMINIMAL_STACK_SIZE,
			NULL, (tskIDLE_PRIORITY + 1UL), (TaskHandle_t *) NULL);

	/* Start the scheduler */
	vTaskStartScheduler();

	/* Should never arrive here */
	return 1;
}
