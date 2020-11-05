#include<iostream>
#include<windows.h>
#include<malloc.h>
#include<stdlib.h>
#include<stdio.h>
#include<string.h>
#include<wingdi.h>
#include<math.h>
#pragma comment(lib, "gdi32.lib")
#include <conio.h>
#include <stdio.h>
#include <fcntl.h>
//#include <unistd.h>
#include<io.h>
#include<process.h>
#include <sys/types.h>    
#include <sys/stat.h>    
#include <fcntl.h>
//#include <graphics.h> // 就是需要引用这个图形库 
#include <conio.h> 

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

using namespace std;

typedef  unsigned char  U8;
typedef  unsigned short U16;
typedef  unsigned int   U32;

#pragma  pack(1)
typedef struct     //这个结构体就是对上面那个图做一个封装。
{
    //bmp header
    U8  Signatue[2];   // B  M
    U32 FileSize;     //文件大小
    U16 Reserv1;
    U16 Reserv2;
    U32 FileOffset;   //文件头偏移量

    //DIB header
    U32 DIBHeaderSize; //DIB头大小
    U32 ImageWidth;  //文件宽度
    U32 ImageHight;  //文件高度
    U16 Planes;
    U16 BPP;  //每个相素点的位数
    U32 Compression;
    U32 ImageSize;  //图文件大小
    U32 XPPM;
    U32 YPPM;
    U32 CCT;
    U32 ICC;
} bmp_header;

#pragma  pack()

#pragma pack(1)
typedef struct{
    
    bmp_header* header_p;
    char*buffer_p;
    
}h_b;
#pragma pack()


void print_bmp_header(bmp_header* header_original)
{
    //以下是bmp图的相关数据

    printf(" Signatue[0]      : %c  \n ", header_original->Signatue[0]);
    printf(" Signatue[1]      : %c  \n ", header_original->Signatue[1]);
    printf(" FileSize         : %d  \n ", header_original->FileSize);
    printf(" Reserv1          : %d  \n ", header_original->Reserv1);
    printf(" Reserv2          : %d  \n ", header_original->Reserv2);
    printf(" FileOffset       : %d  \n ", header_original->FileOffset);
    printf(" DIBheader_originalSize    : %d  \n ", header_original->DIBHeaderSize);
    printf(" ImageWidth       : %d  \n ", header_original->ImageWidth);
    printf(" ImageHight       : %d  \n ", header_original->ImageHight);
    printf(" Planes           : %d  \n ", header_original->Planes);
    printf(" BPP              : %d  \n ", header_original->BPP);
    printf(" Compression      : %d  \n ", header_original->Compression);
    printf(" ImageSize        : %d  \n ", header_original->ImageSize);//以字节记 
    printf(" XPPM             : %d  \n ", header_original->XPPM);
    printf(" YPPM             : %d  \n ", header_original->YPPM);
    printf(" CCT              : %d  \n ", header_original->CCT);
    printf(" ICC              : %d  \n ", header_original->ICC);

}
//header_sb = change_header(width_sb,hight_sb,&header_original)；
bmp_header change_header(int width_sb, int hight_sb, bmp_header* header_original_p) {
    bmp_header new_header;
    new_header = *header_original_p;
    new_header.ImageWidth = width_sb;
    new_header.ImageHight = hight_sb;
    new_header.ImageSize = width_sb * hight_sb * 3;
    new_header.FileSize = new_header.ImageSize + sizeof(bmp_header);
    return new_header;
}

//biger_image(&header_original,&header_sb, image_sb,&buffer,&buffer_b);

void sb_change_pixl_value(bmp_header* header_original_p, bmp_header* header_sb_p, float image_sb, char* buffer_p, char* buffer_sb_p) {
    int w_r;
    int h_r;

  
    for (int j = 0; j < header_sb_p->ImageHight;j++) {

        for (int i = 0;i < header_sb_p->ImageWidth;i++) {
            h_r = (int)(j / image_sb + 0.5);
            w_r = (int)(i / image_sb + 0.5);


            buffer_sb_p[(j * header_sb_p->ImageWidth + i) * 3] = buffer_p[(h_r * header_original_p->ImageWidth + w_r) * 3];
            buffer_sb_p[(j * header_sb_p->ImageWidth + i) * 3 + 1] = buffer_p[(h_r * header_original_p->ImageWidth + w_r) * 3 + 1];
            buffer_sb_p[(j * header_sb_p->ImageWidth + i) * 3 + 2] = buffer_p[(h_r * header_original_p->ImageWidth + w_r) * 3 + 2];

           

        }
    }

    //fclose(f_save);

}




void imshow(bmp_header* header_p, char* buffer_p) {
    HWND wnd;                                 //窗口句柄
    HDC dc;                                   //绘图设备环境句柄
    wnd = GetForegroundWindow();               //获取窗口句柄
    dc = GetDC(wnd);                           //获取绘图设备
    char b, g, r;
    int pix;
    for (int j = 0;j < header_p->ImageWidth;j++) {

        for (int i = 0;i < header_p->ImageHight;i++) {
            b = *buffer_p++;
            g = *buffer_p++;
            r = *buffer_p++;

            pix = RGB(r, g, b);
            SetPixel(dc, 100 + i, 100 + header_p->ImageHight - j, pix);
        }
    }

}


void  im_sb(float sb_rate,bmp_header*header_original_p,char*buffer_p,h_b*h_b_p){
    int width_sb;
    int hight_sb;
    bmp_header header_original;
    header_original = *header_original_p;
    //calculate the width and hight of the image of magnifing or shrinking;
    width_sb = (int)(header_original.ImageWidth * sb_rate) + (4 - ((int)(header_original.ImageWidth * sb_rate) % 4));
    hight_sb = (int)(header_original.ImageHight * sb_rate) + (4 - ((int)(header_original.ImageHight * sb_rate) % 4));
    //distribute dynamic memory space for the header file of the image of magnifing or shrinking;
    
    bmp_header*header_sb_p = (bmp_header*)malloc(sizeof(bmp_header));//point the memory of new image ;
    *header_sb_p = change_header(width_sb, hight_sb, header_original_p);
    
    char* buffer_sb_p = (char*)malloc(width_sb * hight_sb * 3);//point the memory of new image;
    sb_change_pixl_value(header_original_p, header_sb_p, sb_rate, buffer_p, buffer_sb_p);//changing the value of the memory storige of header_sb_p;
    
    h_b_p->header_p = header_sb_p;
    h_b_p->buffer_p = buffer_sb_p;
    
    
}


int  file_save(bmp_header*header_p,char*buffer_p){
    
    FILE* fp_save;
    if (!(fp_save = fopen("sb.bmp", "wb")))
        return -1;
    fwrite(header_p, sizeof(unsigned char), sizeof(bmp_header), fp_save);
    fwrite(buffer_p, sizeof(unsigned char), (size_t)header_p->ImageSize, fp_save);
    fclose(fp_save);
    return 0;
}


//im_rotate(angle,&header_original,buffer_p,&header_buffer);
void im_rotate(float angle,bmp_header*header_original_p,char*buffer_p,h_b*header_buffer_p){
	angle_pi = angle*pi/180
    
    
    w = header_original_p->ImageWidth;
    h = header_original_p->ImageHight;
    //width and hight of image after rotating;
    w1 =(int)( -0.5*w) ;
    w2 =(int)( 1.5*w);
    h1 = (int)(-0.5*h);
    h2 = (int)(1.5*h);
    
    char* buffer_rotate_p = (char*)malloc( 2*w*2*h*3 );
    bmp_header* header_rotate_p = (bmp_header*)malloc(sizeof(bmp_header)));
    
    header_buffer_p->header_p = header_rotate_p;
    header_buffer_p->buffer_p = buffer_rotate_p;
    
    *header_rotate_p = change_header(int w*2, int h*2, bmp_header* header_original_p)
    
    a11 = cos(angle_pi);
    a12 = -sin(angle_pi);
    a21 = sin(angle_pi);
    a22 = cos(angle_pi);
    //the inverse of rotating matrix;
    b11 = cos(angle_pi);
    b12 = sin(angle_pi);
    b21 = -sin(angle_pi);
    b22 = cos(angle_pi);
    
    for(int j = h1;j < h2;j++){
        for(int i = w1;i < w2;i++){
            //claculate the position after inverse mapping;
            x = cos(angle_pi)*(i-w) + sin(angle_pi)*(j-h) + w;
            y = -sin(angle_pi)*(i-w) + cos(angle_pi)*(j-h) + h;
            //round off
            x_r = (int)(x + 0.5);
            y_r = (int)(y + 0.5);
            
            i1 = i+0.5*w;
            j1 = j+0.5*h;
            
            if(x_r >= 0 && x_r < w && y_r >= 0 && y_r <h){
                
                
                buffer_rotate_p[ (j1*2*w+i2)*3 ] = buffer_p[ (y_r*w+x_r)*3 ];
                buffer_rotate_p[ (j1*2*w+i2)*3+1 ] = buffer_p[ (y_r*w+x_r)*3+1 ];
                buffer_rotate_p[ (j1*2*w+i2)*3+2 ] = buffer_p[ (y_r*w+x_r)*3+2 ];
                
            }
            else{
                buffer_rotate_p[ (j1*2*w+i2)*3 ] = 200;
                buffer_rotate_p[ (j1*2*w+i2)*3+1 ] = 200;
                buffer_rotate_p[ (j1*2*w+i2)*3+2 ] = 0;
        }
    }
    
    
	
}


int main()
{
    char filename[30];//定义读取图像的名字；
    cout << "输入打开文件的名称：";
    cin >> filename;
    int  op;
    bmp_header header_original;//定义源文件的图像头 
    
    FILE* fp = NULL;
    if (!(fp = fopen(filename, "rb"))) {
        printf("打开文件失败");
        return -1;
    }
    fread(&header_original, sizeof(unsigned char), sizeof(header_original), fp);//read the header file to the header_original;
    cout<<"print the message of original image";
	print_bmp_header(&header_original);//print the header information of the original image ;
    
    char* buffer_p = (char*)malloc(header_original.ImageSize);//为原图像像素数据分配存储空间。
     
    fread(buffer_p, sizeof(unsigned char), (size_t)(header_original.ImageSize), fp);//put the image byte in the dynamic 
                                                                                        //array that buffer_p points;
    fclose(fp);       
    
    cout << "input the number of operation on the image (magnify(0),shrink(1),rotate(2)):";
    cin >> op;//getint the operation from the window.
    
    
    
    if(op == 0 || op == 1){
        
        float sb_rate;//the rate of magnify or shrink;
        cout<<"please input the rate of the magnify or shrink:";
        cin>>sb_rate;  
        
        
        bmp_header*header_sb_p;//the bmp header of magnifing of shrinking image;
        char*buffer_sb_p;//the image byte of magnifing or shrinking image;
        h_b  header_buffer;
        
        
        im_sb(sb_rate,&header_original,buffer_p,&header_buffer);//magnify or shrink the image calling im_sb;
        
        header_sb_p = header_buffer.header_p;
        buffer_sb_p = header_buffer.buffer_p;
        //writing the image of magnifing or shrinking to the file named sb_image;
        file_save(header_sb_p,buffer_sb_p);
        
        //print the image of shrinking or magnifing;
        imshow(header_sb_p, buffer_sb_p);
        print_bmp_header(header_sb_p);
        
        free(header_sb_p);
        free(buffer_sb_p);
    }
    
    else if(op == 2){
        float angle;
        cout<<"please input the angle of rotation:";
        cin>>angle;
        
        bmp_header*header_rotate_p;//point the rotating image's header memory;
		char*buffer_rotate_p;//point the rotating image's pixl memory;
		h_b header_buffer;//store the header_p and buffer_p;
		
		im_rotate(angle,&header_original,buffer_p,&header_buffer);
		
        header_rotate_p = header_buffer.header_p;//point the header memory of the rotating image;
        buffer_rotate_p = header_buffer.buffer_p;//point the buffer memory of the rotating image;
		
        file_save(header_sb_p,buffer_sb_p);
        imshow(header_rotate_p, buffer_rotate_p);
        print_bmp_header(header_rotate_p);
        
        free(header_rotate_p);
        free(buffer_rotate_p);
    }
    
    else 
        printf("the input is not legal");



    
    
    
    




    


    cout << "输出0结束程序";
    int stop;
    cin >> stop;


    free(buffer_p);


    

    return 0;
}


