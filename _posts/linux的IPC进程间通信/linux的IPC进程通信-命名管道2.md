一、概述
进程之间通过管道来进行通讯是一种常用的方法，顾名思义，管道就是一端进（写）一端出（读）的FIFO队列，这个队列由内核管理，有一定大小（一般是4k），有文章上提到，如果需要修改该缓存区，需要重新编译内核（修改Linux/limits.h里PIPE_BUF的定义）。

需要明确的是，虽然管道在理论上是双向的，但实际应用时，为避免复杂，都单向来用，需要双向通讯时，采用两个管道进行。

具有亲缘关系的进程可以采用匿名管道，没有亲缘关系的进程采用命名管道，本文以命名管道为主进行讨论。

二、有关的管道函数
创建管道

int mkfifo(const char * pathname,mode_t mode);

打开管道

int open(const char *pathname,int oflag,... /* mode_t mode */);

读写

int read(int handle, void *buf, int nbyte)

int write(int handle, void *buf, int nbyte)

关闭

Close(int handle)

这些函数都比较简单，不做深入说明。

三、阻塞和非阻塞
同文件、网络等一样，通过在open方法中是否设置O_NONBLOCK标志，管道操作有两种运行方式：阻塞和非阻塞模式。

1.      阻塞模式
阻塞模式下，无论是读端或写端，如果对方没有打开，open都会阻塞，而write和read的行为见表1。该表总结的场景是读端和写端都已顺利打开，双方进程调用write或read发生的情况。

表1  阻塞模式下write和read行为

写端进程

读端进程

关闭

管道中还有数据

可继续读取

未关闭

管道中没有数据

不阻塞，返回0

未关闭

管道中没有数据

阻塞

管道写满，阻塞

 

写数据，收到信号SIGPIPE，导致进程异常终止

 

关闭

 2.非阻塞模式
无论是读端或写端，open不会阻塞。在双方都顺利打开后，即使没有数据，read不会阻塞，返回-1，errno置为11。write也不会阻塞。

四、测试代码
下面代码分读端和写端，属于两个进程，分别编译运行。写端写十次后退出，读端如果读到的数据是“exit"，退出。
写数据端

[cpp] view plain copy
#include <stdio.h>  
#include <unistd.h>  
#include <string.h>  
#include <fcntl.h>   
#include <errno.h>  
#define  FIFO_NAME  "mynamedpipe"  
int main()  
{  
  int  fifo_fd;  
  int  num;  
  char buf[1024];  
  strcpy(buf, "I am coming");  
  if(access(FIFO_NAME, F_OK)==  -1)  
  {  
    fifo_fd = mkfifo(FIFO_NAME, 0777);  
  }  
  printf("Trying to opening named pipe for writing.\n");  
  fifo_fd = open(FIFO_NAME, O_WRONLY);  
  printf("Opened named pipe for writing.\n");  
  
  int i;  
  for(i=0;i<10;i++)  
  {  
     fgets(buf, 100, stdin);  
     num = strlen(buf);  
     num=write(fifo_fd, buf, num);  
     if(num == -1)  
          printf("Error[%d] when writing data into named pipe",errno);   
    else  
          printf("Writed %d chars into named pipe:%s\n", num, buf);  
  }  
  close(fifo_fd);  
  return 0;  
}  


读数据端

[cpp] view plain copy
#include <stdio.h>  
#include <unistd.h>  
#include <fcntl.h>   
#include <errno.h>  
#define  FIFO_NAME  "mynamedpipe"  
int main()  
{  
  int  fifo_fd;  
  int  num;  
  char buf[100];  
  if(access(FIFO_NAME, F_OK)==  -1)  
  {  
    fifo_fd = mkfifo(FIFO_NAME, 0777);  
  }  
  printf("Trying to open named pipe for reading... \n");  
  fifo_fd = open(FIFO_NAME, O_RDONLY);  
  printf("Opened named pipe for reading. \n");  
  while(1)  
  {  
    num=read(fifo_fd,buf,10);  
    if(num == -1)  
    {  
       printf("Error[%d] when reading data into named pipe",errno);  
    }  
    else  
    {  
       buf[num] = '\0';  
       printf("Readed %d chars from pipe:%s\n", num, buf);  
       buf[4]= '\0';  
       if(strcasecmp(buf,"exit")==0) break;  
    }  
  }  
  close(fifo_fd);  
  return 0;  
}  
五、讨论
命名管道会真的在磁盘上创建一个管道文件，该文件的大小始终为0，例如，对上面的代码，会创建一个叫mynamedpipe的文件（个人感觉似乎无此必要，不知设计者是如何考虑的）。
命名管道有一个“异常现象”，如上面的表1所示，如果读端进程关闭了，写端进程“写数据”时，有可能使进程异常退出，不知设计者出于什么考虑，本人感觉此时write函数返回一个错误更为妥当，由调用者来处理这个错误。这个“异常”，使得使用命名管道时应慎重，要保证读端进程后于写端进程关闭管道，或者采取如下两个方法：一是屏蔽SIGPIPE信号或自己处理它，二是每次写完数据后，关闭管道，下次操作时，重新打开（此方法严格来讲并不可靠）。

本文转载自http://blog.csdn.net/guxch/article/details/6828452
仅供学习参考使用