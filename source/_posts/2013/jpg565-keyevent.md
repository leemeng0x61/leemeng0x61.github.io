---
title: Android keyevent抓图，使用jpeg565对数据压缩 
date: '2013-03-07'
description: 前端时间为了做一个测试工具,做了一个快捷抓图功能
tags: [Android,jpeglib]
categories: [technology]
---

###  实现功能
使用poll池方法监测`event3`，`event5`和对从`FB_DEVICE`获得的图像数据进行jpeg压缩，压缩图像由之前的2700k缩小为89k，压缩比显而易见（30倍）。

###  效果图
![Android ScreenShot](/assets/media/2013/android.jpg "Android ScreenShot") 

###  抓图实现

从`FB_DEVICE "/dev/graphics/fb0"`获得图像的原始数据，色彩数据分为头和rgba数据，在函数jpg_screen_capture里case 16：中我对原始数据进行了处理，将rgba8888的数据转换为rgb565的数据，最后用generateJPEG对数据进行jpeg compress，具体的可以见capture_jpg.c代码
 * 这里要注意的一点是在读取fb_var.xres值必须为2^5=16的倍数，不够的要补足，也就是如下代码：

    if((fb_var.xres&0x1F)==0)
      fb->w = fb_var.xres;
    else
      fb->w =((fb_var.xres>>5)+1)<<5;
      
这样可以避免在抓图时出现像素移位，该问题在fb0的图像像素宽不是16的倍数时出现。

capture_jpg.c

    /*=============================================================================
    #     FileName: capture_jpg.c
    #         Desc: capture jgp screenshoot 
    #       Author: Lee Meng
    #        Email: leaveboy@gmail.com
    #     HomePage: http://leaveboy.is-programmer.com/
    #      Version: 0.0.1
    #   LastChange: 2013-01-15 09:33:23
    #      History:
    =============================================================================*/
    #include <string.h>  
    #include <stdlib.h>
    
    #include <math.h>  
    #include <stdio.h>  
    #include <unistd.h>
    #include <stdio.h>
    #include <fcntl.h>
    #include <linux/fb.h>
    #include <sys/mman.h>
    #include <stdlib.h>
    #include <errno.h>
    #include <string.h>
    
    typedef uint8_t BYTE;  
    #define true 1  
    #define false 0  
    
    
    #include <jpeglib.h>
    
    #define FB_DEVICE "/dev/graphics/fb0"
    static int g_fd;
    
    typedef struct
    {
    	int w;    /* width */
    	int h;    /* high */
    	int bpp;  /* bits per pixel */
    	unsigned char *fbmem;
    }screen;
    
    
    static int init_fb(screen *fb)
    {
    	if ((g_fd = open(FB_DEVICE, O_RDWR)) < 0)
    	{ 
    		fprintf(stderr, "Open %s failed:%s\n", FB_DEVICE, strerror(errno));
    		return -1; 
    	}   
    
    	struct fb_var_screeninfo fb_var;
    	struct fb_fix_screeninfo fb_fix;
    
    	if (ioctl(g_fd, FBIOGET_VSCREENINFO, &fb_var) < 0)
    	{ 
    		fprintf(stderr, "fb ioctl failed:%s\n", strerror(errno));
    		return -1; 
    	}   
    	/*
    		 if (ioctl(g_fd, FBIOGET_FSCREENINFO, &fb_fix) < 0)
    		 { 
    		 fprintf(stderr, "fb ioctl failed:%s\n", strerror(errno));
    		 return -1; 
    		 }   
    		 */
    	//fb->w   = fb_var.xres;
    	if((fb_var.xres&0x1F)==0)
    		fb->w = fb_var.xres;
    	else
    		fb->w =((fb_var.xres>>5)+1)<<5;
    	fb->h   = fb_var.yres;
    	fb->bpp = fb_var.bits_per_pixel;
    	//	printf("capture_log %d, %d, %d, %d\n", fb_var.xres_virtual, fb_var.yres_virtual, fb_var.xoffset, fb_var.yoffset);
    	//	printf("capture_log %d\n", fb_fix.line_length);
    #if 1
    	printf("width:%d\thigh:%d\tbpp:%d\n",fb->w, fb->h, fb->bpp);
    #endif
    	fb->fbmem = mmap(0, fb->w * fb->h * fb->bpp /8,PROT_READ | PROT_WRITE, MAP_SHARED, g_fd, 0);
    	if (fb->fbmem == MAP_FAILED)
    	{
    		fprintf(stderr, "fb mmap failed:%s\n", strerror(errno));
    		return -1;
    	}
    
    	close(g_fd);
    	return 0;
    }
    
    int term_fb(screen *fb)
    {
    	munmap(fb->fbmem, fb->w * fb->h * fb->bpp / 8);
    	return 0;
    }
    
    
    static int generateJPEG(BYTE* data,int w, int h, const char* outfilename)  
    {  
    	int nComponent = 3;  
    
    	struct jpeg_compress_struct jcs;  
    
    	struct jpeg_error_mgr jem;  
    
    	jcs.err = jpeg_std_error(&jem);   
    	jpeg_create_compress(&jcs);  
    
    	FILE* f=fopen(outfilename,"wb");  
    	if (f==NULL)   
    	{  
    		free(data);  
    		return 0;  
    	}  
    	jpeg_stdio_dest(&jcs, f);  
    	jcs.image_width = w;   
    	jcs.image_height = h;  
    	jcs.input_components = nComponent;  
    	if (nComponent==1)  
    		jcs.in_color_space = JCS_GRAYSCALE; 
    	else   
    		jcs.in_color_space = JCS_RGB;  
    
    	jpeg_set_defaults(&jcs);      
    	jpeg_set_quality (&jcs, 80, true);  
    
    	jpeg_start_compress(&jcs, TRUE);  
    
    	JSAMPROW row_pointer[1];
    	int row_stride;   
    
    	row_stride = jcs.image_width*nComponent;   
    
    
    	while (jcs.next_scanline < jcs.image_height) {  
    		row_pointer[0] = & data[jcs.next_scanline*row_stride];
    
    		jpeg_write_scanlines(&jcs, row_pointer, 1);  
    	}  
    
    	jpeg_finish_compress(&jcs);  
    	jpeg_destroy_compress(&jcs);  
    	fclose(f);  
    
    	return 1;  
    }  
    
    
    
    //int main(void)
    extern int jpg_screen_capture(char * file_name)
    {  
    	int i = 0, j = 0;
    	int w = 0, h = 0;
    	int ret = 0;
    	unsigned char *p;
    	screen fb_screen;
    
    	init_fb(&fb_screen);
    
    	w = fb_screen.w;
    	h = fb_screen.h;
    
    	p = (unsigned char *)malloc(w * h * 3);
    
    	printf("0x%x %x %x %x\n", *fb_screen.fbmem, *(fb_screen.fbmem + 1), \
    			*(fb_screen.fbmem + 2), *(fb_screen.fbmem + 3));
    
    	short *cursor = (short*)fb_screen.fbmem;
    	switch(fb_screen.bpp)
    	{
    		case 32:
    			for(i = 0; i < h; i++)
    			{
    				for(j = 0; j < w; j++)
    				{
    					*(p + (i * w + j) * 3 + 0) = *(fb_screen.fbmem + (i * w + j) * 4 + 0);
    					*(p + (i * w + j) * 3 + 1) = *(fb_screen.fbmem + (i * w + j) * 4 + 1);
    					*(p + (i * w + j) * 3 + 2) = *(fb_screen.fbmem + (i * w + j) * 4 + 2);
    				}
    			}
    			break;
    
    		case 16:
    			while(i<w*h)
    			{
    				short pixel = *cursor;     
    				int r = (pixel & 0xF800) << 8; 
    				int g = (pixel & 0x7E0) << 5;  
    				int b = (pixel & 0x1F) << 3;
    				int color = 0xFF000000 | r | g | b;
    
    				*(p + 3 * i + 0) = (unsigned char)(color>>16 &0xFF);
    				*(p + 3 * i + 1) = (unsigned char)(color>>8  &0xFF);
    				*(p + 3 * i + 2) = (unsigned char)(color>>0  &0xFF);
    				i++;
    				cursor++;
    			}
    			break;
    
    		default:
    			printf("not support bpp %d\n",fb_screen.bpp);
    			return -1;
    			break;
    	}
    
    	//	ret = generateJPEG(p, fb_screen.w, fb_screen.h, "/data/test/test.jpg");  
    	ret = generateJPEG(p, fb_screen.w, fb_screen.h, file_name);  
    
    	term_fb(&fb_screen);	
    	free(p);
    	return ret;
    }

###  监听keyevent事件
    
这里为了避免单按键对使用造成影响，需同时监听两个keyevent 分别为`event3` 和 `event5`，对这两个事件的监听采用了无阻塞方式，在poll池中对两个event进行检测，通过`event.code` 和 `event.value` 区别按键（那个按键）动作（按下/松开）,最后通过`fork_sound()`


    /*=============================================================================
    #     FileName: getevent.c
    #         Desc: get events of powerkey and volume + 
    #       Author: Lee Meng
    #        Email: leaveboy@gmail.com
    #     HomePage: http://leaveboy.is-programmer.com/
    #      Version: 0.0.1
    #   LastChange: 2013-01-15 09:32:53
    #      History:
    =============================================================================*/
    #include <stdio.h>
    #include <stdlib.h>
    #include <fcntl.h>
    #include <unistd.h>
    #include <string.h>
    #include <time.h>
    #include <errno.h>
    #include <sys/poll.h>
    #include <linux/input.h>
    
    #define TIME_DELAY   6000 
    #define IN_FILES  2
    #define SAVE_PATH "/data/logs"
    #define SOUND_PATH "system/media/audio/alarms/Alarm_Buzzer.ogg"
    
    struct timeval tv,tv_event3={0L, 0L},tv_event5={0L, 0L};
    static unsigned char  event3_down = 0x00;//
    static unsigned char  event5_down = 0x00;
    struct input_event event;
    
    static void  fork_sound(void)
    {
      pid_t pid = fork();
      if (pid == 0) {
        execl("/system/bin/stagefright", "stagefright", "-o", "-a", SOUND_PATH, NULL);
        /*execl("/system/bin/busybox", "busybox", "tar", "cvf", "/mnt/sdcard/logs.tar",SAVE_PATH, NULL);*/
        //execl("/system/bin/busybox", "busybox", "bzip", "-9", "/mnt/sdcard/logs.tar",NULL);
      }
    }
    /*int main(void) {*/
    extern int event_capture_jpg(void) {
      int pollres;
      struct pollfd  fds[2];
      struct tm *p;
      time_t now;
      char capture_name[128];
    
      int i, real_read;
      printf("sizeof(struct input_event) = %d\n", sizeof(struct input_event));
      fds[0].fd  = open("/dev/input/event3", O_RDONLY|O_NONBLOCK);//volume button
      fds[1].fd  = open("/dev/input/event5", O_RDONLY|O_NONBLOCK);//power button
    
      for (i = 0; i<IN_FILES; i++){
        if ( fds[i].fd < 0 ) return -1;
        fds[i].events = POLLIN;
      }
      while(1){
        pollres = poll(fds,IN_FILES,TIME_DELAY);
        for (i = 0; i< IN_FILES; i++){
          if (fds[i].revents){
            real_read = read(fds[i].fd, &event, sizeof(event));
            if(real_read < (int)sizeof(event)) {
              fprintf(stderr, "could not get event\n");
              break;
            }
            time(&now);
            p = localtime(&now);
            sprintf(capture_name,"%s/%d-%d-%d_%d-%d-%d.jpg",
                SAVE_PATH,
                1900+p->tm_year, 1+p->tm_mon, p->tm_mday, 
                p->tm_hour, p->tm_min, p->tm_sec);
            printf("%d %u %u %u\n", i, event.type, event.code, event.value);
    
            if (i == 0x01 && event.type == 0x01 && event.code == 0x6B && event.value == 0x00)
              event5_down = 0x00;
    
            if (i == 0x00 && event.type == 0x01 && event.code == 0x73 && event.value == 0x00)
              event3_down = 0x00;
    
            if (i == 0x01 && event.type == 0x01 && event.code == 0x6B && event.value == 0x01)
            {
              event5_down = 0x01;
              if(event3_down&event5_down)
              {
                jpg_screen_capture(capture_name);
                fork_sound();
                printf("Lee Meng capture jpg:%s\n",capture_name);
              }
            }
    
            if (i == 0x00 && event.type == 0x01 && event.code == 0x73 && event.value == 0x01)
            {
              event3_down = 0x01;
              if(event3_down&event5_down)
              {
                printf("Lee Meng capture jpg:%s\n",capture_name);
                jpg_screen_capture(capture_name);
                fork_sound();
              }
            }
    
          } 
        }
        //no sleep
      }
    
      for(i=0;i<2;i++){
        if(fds[i].fd > 0){
          close(fds[i].fd);
          fds[i].fd = -1;
        }	
      }
      return 0;
    }
    
### main函数及Android.mk
     
main.c

    #include <stdio.h>
    
    
    int main(void)
    {
      while(1)
      event_capture_jpg();
    }

Android.mk

    LOCAL_PATH := $(my-dir)
    
    commonSources  :=
    
    commonIncludes := $(TARGET_OUT_HEADERS)/common/inc
    
    commonSharedLibraries :=  liboncrpc
    commonSharedLibraries +=  libnv
    commonSharedLibraries +=  libcutils libxml2 libicuuc
    commonSharedLibraries +=  libutils
    commonSharedLibraries +=  libjpeg libc
    
    
    include $(CLEAR_VARS)
    LOCAL_MODULE := qlogd
    LOCAL_CFLAGS := $(commonCflags)
    
    LOCAL_C_INCLUDES := $(call include-path-for, system-core)/cutils
    LOCAL_C_INCLUDES += $(commonIncludes)
    LOCAL_C_INCLUDES += $(LOCAL_PATH)
    LOCAL_C_INCLUDES += external/jpeg
    LOCAL_SRC_FILES := main.c getevent.c capture_jpg.c
    LOCAL_MODULE_TAGS := optional eng
    LOCAL_SHARED_LIBRARIES += $(commonSharedLibraries) 
    LOCAL_MODULE_PATH := $(TARGET_OUT_OPTIONAL_EXECUTABLES)
    include $(BUILD_EXECUTABLE)
    
这四个文件放到Android工程下面`vendor/qlogd`目录下，`mmm`编译之后就可以在`/system/xbin/`找到`qlogd`，将qlogd push到手机上相应的目录/system/xbin/，添加可以执行权限

> chmod 777 qlogd

然后运行

> /system/xbin/qlogd&

按下`power`键和`音量-`键,就可以听到Bi Bi Bi的提示音了。
