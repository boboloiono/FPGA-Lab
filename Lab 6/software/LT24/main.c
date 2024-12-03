// ============================================================================
// Copyright (c) 2014 by Terasic Technologies Inc.
// ============================================================================
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development
//   Kits made by Terasic.  Other use of this code, including the selling
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use
//   or functionality of this code.
//
// ============================================================================
//
//  Terasic Technologies Inc
//  9F., No.176, Sec.2, Gongdao 5th Rd, East Dist, Hsinchu City, 30070. Taiwan
//
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// ============================================================================

#include "terasic_includes.h"
#include "ILI9341.h"
#include "system.h"
#include "staticimg.h"
#include "ids_lounge.h"
#include "gif.h"

int main()
{
   // init buttons
   bool b0 = ((IORD(KEY_BASE, 0x00) & 0x01) == 0x00)?TRUE:FALSE;
   bool b0_prev = b0;
   bool b1 = ((IORD(KEY_BASE, 0x00) & 0x02) == 0x00)?TRUE:FALSE;
   bool b1_prev = b1;

   printf("LT24 Demo!\n");

   // test custom block: call custom block for pixel clusters of 16 pixels
   alt_u16* img_cpy = calloc(78000,sizeof(alt_u16)); // NOTE: image is 76800 items large! Size is chosen due to end of image bug
   alt_u16* gif_frame_cpy = calloc(78000,sizeof(alt_u16)); //malloc(76800*sizeof(alt_u16));
   printf("%x\n", img_cpy);
   printf("%x\n", (img_cpy - 0x01000000));

   for (int i=0;i<318;i++) {
	   ALT_CI_NEW_COMPONENT_0(staticimg+240*i,img_cpy+240*i);
   }

   // init LCD
   LCD_Init();
   LCD_Clear(0XFF00);
   LCD_ClearRnd();

   bool state_filter = FALSE;
   bool state_video = FALSE;
   int count=0;
   while (1) {

	  // button check for switching between images
      b0_prev = b0;
      b0 = ((IORD(KEY_BASE, 0x00) & 0x01) == 0x00)?TRUE:FALSE;
      if (b0 && (b0_prev == FALSE)) {
         state_filter = !state_filter;
         count = 0;
      }

      b1_prev = b1;
	  b1 = ((IORD(KEY_BASE, 0x00) & 0x02) == 0x00)?TRUE:FALSE;
	  if (b1 && (b1_prev == FALSE)) {
	    state_video = !state_video;
	   	count = 0;
	  }

      // display images
      if (state_filter) {
    	 if (!state_video) {
    		 LCD_DrawImg240x320(staticimg);
    	 } else {
			 LCD_DrawImg240x320(gif[count]);
			 count = count + 1;
			 if (count > 29)
				 count = 0;
    	 }
      }
      else {
    	 if (!state_video) {
    		 LCD_DrawImg240x320(img_cpy);
    	 } else {
		    for (int i=0;i<318;i++) {
			   ALT_CI_NEW_COMPONENT_0(gif[count]+240*i,gif_frame_cpy+240*i);
		    }
		    LCD_DrawImg240x320(gif_frame_cpy);
		    count = count + 1;
		    if (count > 29)
			   count = 0;
    	 }
      }
   }

}
