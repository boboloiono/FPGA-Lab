#ifndef _ALT_VIDEO_DISPLAY_H_
#define _ALT_VIDEO_DISPLAY_H_


#define SCREEN_WIDTH	240
#define SCREEN_HEIGHT	320

typedef struct{

    
    // for altera vip library
    int color_depth;
    int width;
    int height;
    int bytes_per_pixel;
    int interlace;
}alt_video_display;


//#define alt_video_display VIP_FRAME_READER

//VIP_FRAME_READER* VIPFR_Init(alt_u32 VipBase, void* Frame0_Base, void* Frame1_Base, alt_u32 Frame_Width, alt_u32 Frame_Height);
//void VIPFR_UnInit(VIP_FRAME_READER* p);
//void VIPFR_Go(VIP_FRAME_READER* p, bool bGo);
//void* VIPFR_GetDrawFrame(VIP_FRAME_READER* p);
//void VIPFR_ActiveDrawFrame(VIP_FRAME_READER* p);
//void VIPFR_ReserveBackground(VIP_FRAME_READER* p);
//void VIPFR_SetFrameSize(VIP_FRAME_READER* p, int width, int height);
// 




#endif /*_ALT_VIDEO_DISPLAY_H_*/
