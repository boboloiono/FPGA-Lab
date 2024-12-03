/*
 * ILI9341.h
 *
 *  Created on: 2014-2-13
 *      Author: Administrator
 */

#ifndef ILI9341_H_
#define ILI9341_H_

//#include "system.h"
//#include "type.h"
//#include "altera_avalon_pio_regs.h"
#include "terasic_includes.h"

void LCD_Init();
void LCD_Clear(alt_u16 Color);
void LCD_ClearRnd();
void LCD_DrawImg240x320(alt_u16* img);
void LCD_DrawPoint(alt_u16 x,alt_u16 y,alt_u16 color );

#endif /* ILI9341_H_ */
