#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <linux/fb.h>
#include <linux/kd.h>

#define RGB565(r, g, b) ((((r) & 0xF8) << 8) | (((g) & 0xFC) << 3) | (((b) & 0xF8) >> 3))
void main(void)
{
    struct fb_fix_screeninfo fb_fix = {0};
    struct fb_var_screeninfo fb_var = {0};
    short *ptrfb = NULL;
    int    fdfb  = 0;
    int    fdcon = 0;
    int    i, j, k;

    // redirect stdout
    freopen("/dev/tty0", "w", stdout);
    system("clear");
    printf("hello world !\n");
    sleep(1);

    fdcon = open("/dev/tty0", O_RDWR);
    fdfb  = open("/dev/fb0" , O_RDWR);

    ioctl(fdcon, KDSETMODE, KD_TEXT);
    ioctl(fdcon, KDSETMODE, KD_GRAPHICS);
    ioctl(fdcon, KDSETMODE, KD_TEXT);
    ioctl(fdcon, KDSETMODE, KD_GRAPHICS);

    // enter graphics mode
    ioctl(fdcon, KDSETMODE, KD_GRAPHICS);

    ioctl(fdfb, FBIOGET_VSCREENINFO, &fb_var);
    ioctl(fdfb, FBIOGET_FSCREENINFO, &fb_fix);
    ptrfb = mmap(NULL, fb_fix.smem_len, PROT_READ|PROT_WRITE, MAP_SHARED, fdfb, 0);

    for (k=0; k<1000; k++) {
        for (i=0; i<320; i++)
        {
            for (j=0; j<240; j++)
            {
                *ptrfb++ = RGB565(i, j, k);
            }
        }
        ptrfb -= fb_fix.smem_len / 2;
    }

    munmap(ptrfb, fb_fix.smem_len);

    // exit graphics mode
    ioctl(fdcon, KDSETMODE, KD_TEXT);

    close(fdfb );
    close(fdcon);
}


