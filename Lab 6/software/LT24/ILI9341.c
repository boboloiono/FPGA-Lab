/*
 * ILI9341.c
 *
 *  Created on: 2014-2-13
 *      Author: Administrator
 */

#include "terasic_includes.h"
#include "ILI9341.h"
#include "system.h"
#include "altera_avalon_pio_regs.h"
//#include "type.h"
#include "stdio.h"
#include <unistd.h>
/*
The chip-select CSX (active
low) is used to enable or disable ILI9341 chip.
The RESX (active low) is an external reset signal.
WRX is the parallel data write strobe, RDX is the parallel data read strobe and D[17:0] is parallel data bus.
ILI9341  latches  the  input  data  at  the  rising  edge  of  WRX  signal.
The  D/CX  is  the  signal  of  data/command selection.
When  D/CX=¡¯1¡¯,  D  [17:0]  bits  are  display  RAM  data  or  command¡¯s  parameters.
When  D/CX=¡¯0¡¯,  D [17:0] bits are commands.
*/
#define  LCD_WR_REG(value)  IOWR(LT24_CONTROLLER_0_BASE,0x00,value)
#define  LCD_WR_DATA(value)  IOWR(LT24_CONTROLLER_0_BASE,0x01,value)

#define  Set_LCD_RST  IOWR_ALTERA_AVALON_PIO_DATA(LCD_RESET_N_BASE,0x01)
#define  Clr_LCD_RST  IOWR_ALTERA_AVALON_PIO_DATA(LCD_RESET_N_BASE,0x00)


//void LCD_Init();
//void LCD_Clear(alt_u16 Color);
void LCD_Pattern_Horizon(void);
void LCD_Pattern_Vertical(void);
//void LCD_DrawPoint(alt_u16 x,alt_u16 y,alt_u16 color );
#define RED 0xf800
#define GREEN 0x07e0
#define BLUE 0x001f
#define BLACK  0x0000
#define WHITE 0xffff

void Delay_Ms(alt_u16 count_ms)
{
    while(count_ms--)
    {
        usleep(1000);
    }
}


void LCD_SetCursor(alt_u16 Xpos, alt_u16 Ypos)
{
	 LCD_WR_REG(0x002A);
		 LCD_WR_DATA(Xpos>>8);
		 LCD_WR_DATA(Xpos&0XFF);
	 LCD_WR_REG(0x002B);
		 LCD_WR_DATA(Ypos>>8);
		 LCD_WR_DATA(Ypos&0XFF);
	 LCD_WR_REG(0x002C);
}

void LCD_Clear(alt_u16 Color)
{
        alt_u32 index=0;
        LCD_SetCursor(0x00,0x0000);
        LCD_WR_REG(0x002C);
        for(index=0;index<76800;index++)
        {
        	LCD_WR_DATA(Color);
        }
}

void LCD_ClearRnd()
{
        alt_u32 index=0;
        LCD_SetCursor(0x00,0x0000);
        LCD_WR_REG(0x002C);
        for(index=0;index<76800;index++)
        {
        	LCD_WR_DATA(rand());
        }
}

void LCD_DrawImg240x320(alt_u16* img)
{
        alt_u32 index=0;
        LCD_SetCursor(0x00,0x0000);
        LCD_WR_REG(0x002C);
        for(index=0;index<76800;index++)
        {
        	LCD_WR_DATA(img[index]);
        }
}

void LCD_DrawPoint(alt_u16 x,alt_u16 y,alt_u16 color )
{
        LCD_SetCursor(x,y);
        LCD_WR_REG(0x002C);
        LCD_WR_DATA(color);
}
void LCD_Init()
{
	alt_u16 data1,data2;
	alt_u16 data3,data4;
	Set_LCD_RST;
	Delay_Ms(1);
	Clr_LCD_RST;
	Delay_Ms(10);       // Delay 10ms // This delay time is necessary
	Set_LCD_RST;
	Delay_Ms(120);       // Delay 120 ms
//	Clr_LCD_CS;



	LCD_WR_REG(0x0011); //Exit Sleep
	LCD_WR_REG(0x00CF);
		LCD_WR_DATA(0x0000);
		LCD_WR_DATA(0x0081);
		LCD_WR_DATA(0X00c0);

	LCD_WR_REG(0x00ED);
		LCD_WR_DATA(0x0064);
		LCD_WR_DATA(0x0003);
		LCD_WR_DATA(0X0012);
		LCD_WR_DATA(0X0081);

	LCD_WR_REG(0x00E8);
		LCD_WR_DATA(0x0085);
		LCD_WR_DATA(0x0001);
		LCD_WR_DATA(0x00798);

	LCD_WR_REG(0x00CB);
		LCD_WR_DATA(0x0039);
		LCD_WR_DATA(0x002C);
		LCD_WR_DATA(0x0000);
		LCD_WR_DATA(0x0034);
		LCD_WR_DATA(0x0002);

	LCD_WR_REG(0x00F7);
		LCD_WR_DATA(0x0020);

	LCD_WR_REG(0x00EA);
		LCD_WR_DATA(0x0000);
		LCD_WR_DATA(0x0000);

	LCD_WR_REG(0x00B1);
		LCD_WR_DATA(0x0000);
		LCD_WR_DATA(0x001b);

	LCD_WR_REG(0x00B6);
		LCD_WR_DATA(0x000A);
		LCD_WR_DATA(0x00A2);

	LCD_WR_REG(0x00C0);    //Power control
		LCD_WR_DATA(0x0005);   //VRH[5:0]

	LCD_WR_REG(0x00C1);    //Power control
		LCD_WR_DATA(0x0011);   //SAP[2:0];BT[3:0]

	LCD_WR_REG(0x00C5);    //VCM control
		LCD_WR_DATA(0x0045);       //3F
		LCD_WR_DATA(0x0045);       //3C

	 LCD_WR_REG(0x00C7);    //VCM control2
		 LCD_WR_DATA(0X00a2);

	LCD_WR_REG(0x0036);    // Memory Access Control
		LCD_WR_DATA(0x0008);//48

	LCD_WR_REG(0x00F2);    // 3Gamma Function Disable
		LCD_WR_DATA(0x0000);

	LCD_WR_REG(0x0026);    //Gamma curve selected
		LCD_WR_DATA(0x0001);

	LCD_WR_REG(0x00E0);    //Set Gamma
		LCD_WR_DATA(0x000F);
		LCD_WR_DATA(0x0026);
		LCD_WR_DATA(0x0024);
		LCD_WR_DATA(0x000b);
		LCD_WR_DATA(0x000E);
		LCD_WR_DATA(0x0008);
		LCD_WR_DATA(0x004b);
		LCD_WR_DATA(0X00a8);
		LCD_WR_DATA(0x003b);
		LCD_WR_DATA(0x000a);
		LCD_WR_DATA(0x0014);
		LCD_WR_DATA(0x0006);
		LCD_WR_DATA(0x0010);
		LCD_WR_DATA(0x0009);
		LCD_WR_DATA(0x0000);

	LCD_WR_REG(0X00E1);    //Set Gamma
		LCD_WR_DATA(0x0000);
		LCD_WR_DATA(0x001c);
		LCD_WR_DATA(0x0020);
		LCD_WR_DATA(0x0004);
		LCD_WR_DATA(0x0010);
		LCD_WR_DATA(0x0008);
		LCD_WR_DATA(0x0034);
		LCD_WR_DATA(0x0047);
		LCD_WR_DATA(0x0044);
		LCD_WR_DATA(0x0005);
		LCD_WR_DATA(0x000b);
		LCD_WR_DATA(0x0009);
		LCD_WR_DATA(0x002f);
		LCD_WR_DATA(0x0036);
		LCD_WR_DATA(0x000f);

	LCD_WR_REG(0x002A);
		LCD_WR_DATA(0x0000);
		LCD_WR_DATA(0x0000);
		LCD_WR_DATA(0x0000);
		LCD_WR_DATA(0x00ef);

	 LCD_WR_REG(0x002B);
		LCD_WR_DATA(0x0000);
		LCD_WR_DATA(0x0000);
		LCD_WR_DATA(0x0001);
		LCD_WR_DATA(0x003f);

	LCD_WR_REG(0x003A);
		LCD_WR_DATA(0x0055);

	LCD_WR_REG(0x00f6);
		LCD_WR_DATA(0x0001);
		LCD_WR_DATA(0x0030);
		LCD_WR_DATA(0x0000);

	LCD_WR_REG(0x0029); //display on

	LCD_WR_REG(0x002c);    // 0x2C

}


void LCD_Pattern_Horizon(void)
{
        alt_u32 index=0;
        alt_u16  data=0;
        LCD_SetCursor(0x00,0x0000);
        data=0x0000;
        for(index=0;index<240*80;index++)
        {
        	LCD_WR_DATA(data);
        }
        LCD_SetCursor(0x00,80);
        data=RED;
		for(index=0;index<240*80;index++)
		{
			LCD_WR_DATA(data);
		}
	    LCD_SetCursor(0x00,160);
		data=GREEN;
		for(index=0;index<240*80;index++)
		{
			LCD_WR_DATA(data);
		}
		LCD_SetCursor(0x00,240);
		data=BLUE;
		for(index=0;index<240*80;index++)
		{
			LCD_WR_DATA(data);
		}
}

void LCD_Pattern_Vertical(void)
{
        int i,j,m;
        alt_u16  data=0;
        alt_u16  color[4]={WHITE,BLUE,GREEN,RED};
        LCD_SetCursor(0x00,0x0000);
        for(m=0;m<320;m++)
        {
			for(i=0;i<4;i++)
			{
				data=color[i];
				for(j=0;j<60;j++)
				{
					LCD_WR_DATA(data);
				}
			}
        }
}

