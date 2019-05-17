/*
 * @brief Classic Rate Monotonic example with three tasks.
 */
#include "FreeRTOS.h"
#include "task.h"
#include "sapi.h"         /* <= sAPI header */

/* The linker does not include this code in liblpc.a because nothing in it
 * references it... */
#define CRP_NO_CRP          0xFFFFFFFF
__attribute__ ((used,section(".crp"))) const unsigned int CRP_WORD = CRP_NO_CRP;

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

static void vTask1(void *pvParameters) {
	bool_t LedState = ON;
	TickType_t xPeriod = 3000;
	TickType_t xNextWakeUp = 0;

	while (1) {
		gpioWrite( LED1,  LedState);
        LedState = (bool_t) !LedState;

        uartWriteString( UART_USB, "[T1] Hello!\r\n");

        vTaskDelayUntil(&xNextWakeUp, xPeriod);
	}
}

static void vTask2(void *pvParameters) {
    bool_t LedState = ON;
    TickType_t xPeriod = 4000;
    TickType_t xNextWakeUp = 0;

    while (1) {
        gpioWrite( LED2,  LedState);
        LedState = (bool_t) !LedState;

        uartWriteString( UART_USB, "[T2] ¡Hola!\r\n");

        vTaskDelayUntil(&xNextWakeUp, xPeriod);
    }
}

static void vTask3(void *pvParameters) {
    bool_t LedState = ON;
    TickType_t xPeriod = 6000;
    TickType_t xNextWakeUp = 0;

    while (1) {
        gpioWrite( LED3,  LedState);
        LedState = (bool_t) !LedState;

        uartWriteString( UART_USB, "[T3] Salut!\r\n");

        vTaskDelayUntil(&xNextWakeUp, xPeriod);
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

	xTaskCreate(vTask1, "vTask1", configMINIMAL_STACK_SIZE,
			NULL, (tskIDLE_PRIORITY + 3UL), (TaskHandle_t *) NULL);

	xTaskCreate(vTask2, "vTask2", configMINIMAL_STACK_SIZE,
			NULL, (tskIDLE_PRIORITY + 2UL), (TaskHandle_t *) NULL);

	xTaskCreate(vTask3, "vTask3", configMINIMAL_STACK_SIZE,
	        NULL, (tskIDLE_PRIORITY + 1UL), (TaskHandle_t *) NULL);

	/* Start the scheduler */
	vTaskStartScheduler();

	/* Should never arrive here */
	return 1;
}
