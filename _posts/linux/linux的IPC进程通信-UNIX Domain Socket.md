# linux的IPC进程通信-UNIX Domain Socket

## 一、 概述

UNIX Domain Socket是在socket架构上发展起来的用于同一台主机的进程间通讯（IPC），它不需要经过网络协议栈，不需要打包拆包、计算校验和、维护序号和应答等，只是将应用层数据从一个进程拷贝到另一个进程。UNIX Domain Socket有SOCK_DGRAM或SOCK_STREAM两种工作模式，类似于UDP和TCP，但是面向消息的UNIX Domain Socket也是可靠的，消息既不会丢失也不会顺序错乱。

UNIX Domain Socket可用于两个没有亲缘关系的进程，是全双工的，是目前使用最广泛的IPC机制，比如X Window服务器和GUI程序之间就是通过UNIX Domain Socket通讯的。

## 二、工作流程

UNIX Domain socket与网络socket类似，可以与网络socket对比应用。

上述二者编程的不同如下：

address family为AF_UNIX
因为应用于IPC，所以UNIXDomain socket不需要IP和端口，取而代之的是文件路径来表示“网络地址”。这点体现在下面两个方面。
地址格式不同，UNIXDomain socket用结构体sockaddr_un表示，是一个socket类型的文件在文件系统中的路径，这个socket文件由bind()调用创建，如果调用bind()时该文件已存在，则bind()错误返回。
UNIX Domain Socket客户端一般要显式调用bind函数，而不象网络socket一样依赖系统自动分配的地址。客户端bind的socket文件名可以包含客户端的pid，这样服务器就可以区分不同的客户端。
UNIX Domain socket的工作流程简述如下（与网络socket相同）。

服务器端：创建socket—绑定文件（端口）—监听—接受客户端连接—接收/发送数据—…—关闭

客户端：创建socket—绑定文件（端口）—连接—发送/接收数据—…—关闭

## 三、阻塞和非阻塞（SOCK_STREAM方式）

读写操作有两种操作方式：阻塞和非阻塞。

**1.阻塞模式下**

阻塞模式下，发送数据方和接收数据方的表现情况如同命名管道，参见本人文章“Linux下的IPC－命名管道的使用（http://blog.csdn.NET/guxch/article/details/6828452）”

**2.非阻塞模式**

在send或recv函数的标志参数中设置MSG_DONTWAIT，则发送和接收都会返回。如果没有成功，则返回值为-1，errno为EAGAIN 或 EWOULDBLOCK。

## 四、测试代码
 服务器端
```
 #include <stdio.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <errno.h>
#include <stddef.h>
#include <string.h>

// the max connection number of the server
#define MAX_CONNECTION_NUMBER 5

/* * Create a server endpoint of a connection. * Returns fd if all OK, <0 on error. */
int unix_socket_listen(const char *servername)
{ 
  int fd;
  struct sockaddr_un un; 
  if ((fd = socket(AF_UNIX, SOCK_STREAM, 0)) < 0)
  {
     return(-1); 
  }
  int len, rval; 
  unlink(servername);               /* in case it already exists */ 
  memset(&un, 0, sizeof(un)); 
  un.sun_family = AF_UNIX; 
  strcpy(un.sun_path, servername); 
  len = offsetof(struct sockaddr_un, sun_path) + strlen(servername); 
  /* bind the name to the descriptor */ 
  if (bind(fd, (struct sockaddr *)&un, len) < 0)
  { 
    rval = -2; 
  } 
  else
  {
      if (listen(fd, MAX_CONNECTION_NUMBER) < 0)    
      { 
        rval =  -3; 
      }
      else
      {
        return fd;
      }
  }
  int err;
  err = errno;
  close(fd); 
  errno = err;
  return rval;  
}

int unix_socket_accept(int listenfd, uid_t *uidptr)
{ 
   int clifd, len, rval; 
   time_t staletime; 
   struct sockaddr_un un;
   struct stat statbuf; 
   len = sizeof(un); 
   if ((clifd = accept(listenfd, (struct sockaddr *)&un, &len)) < 0) 
   {
      return(-1);     
   }
 /* obtain the client's uid from its calling address */ 
   len -= offsetof(struct sockaddr_un, sun_path);  /* len of pathname */
   un.sun_path[len] = 0; /* null terminate */ 
   if (stat(un.sun_path, &statbuf) < 0) 
   {
      rval = -2;
   } 
   else
   {
       if (S_ISSOCK(statbuf.st_mode) ) 
       { 
          if (uidptr != NULL) *uidptr = statbuf.st_uid;    /* return uid of caller */ 
          unlink(un.sun_path);       /* we're done with pathname now */ 
          return clifd;      
       } 
       else
       {
          rval = -3;     /* not a socket */ 
       }
    }
   int err;
   err = errno; 
   close(clifd); 
   errno = err;
   return(rval);
 }
 
 void unix_socket_close(int fd)
 {
    close(fd);     
 }

int main(void)
{ 
  int listenfd,connfd; 
  listenfd = unix_socket_listen("foo.sock");
  if(listenfd<0)
  {
     printf("Error[%d] when listening...\n",errno);
     return 0;
  }
  printf("Finished listening...\n",errno);
  uid_t uid;
  connfd = unix_socket_accept(listenfd, &uid);
  unix_socket_close(listenfd);  
  if(connfd<0)
  {
     printf("Error[%d] when accepting...\n",errno);
     return 0;
  }  
   printf("Begin to recv/send...\n");  
  int i,n,size;
  char rvbuf[2048];
  for(i=0;i<2;i++)
  {
//===========接收==============
   size = recv(connfd, rvbuf, 804, 0);   
     if(size>=0)
     {
       // rvbuf[size]='\0';
        printf("Recieved Data[%d]:%c...%c\n",size,rvbuf[0],rvbuf[size-1]);
     }
     if(size==-1)
     {
         printf("Error[%d] when recieving Data:%s.\n",errno,strerror(errno));    
             break;     
     }
/*
 //===========发送==============
     memset(rvbuf, 'c', 2048);
         size = send(connfd, rvbuf, 2048, 0);
     if(size>=0)
     {
        printf("Data[%d] Sended.\n",size);
     }
     if(size==-1)
     {
         printf("Error[%d] when Sending Data.\n",errno);     
             break;     
     }
*/
 sleep(30);
  }
   unix_socket_close(connfd);
   printf("Server exited.\n");    
 }


```

客户端代码
```
#include <stdio.h>
#include <stddef.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <errno.h>
#include <string.h>

/* Create a client endpoint and connect to a server.   Returns fd if all OK, <0 on error. */
int unix_socket_conn(const char *servername)
{ 
  int fd; 
  if ((fd = socket(AF_UNIX, SOCK_STREAM, 0)) < 0)    /* create a UNIX domain stream socket */ 
  {
    return(-1);
  }
  int len, rval;
   struct sockaddr_un un;          
  memset(&un, 0, sizeof(un));            /* fill socket address structure with our address */
  un.sun_family = AF_UNIX; 
  sprintf(un.sun_path, "scktmp%05d", getpid()); 
  len = offsetof(struct sockaddr_un, sun_path) + strlen(un.sun_path);
  unlink(un.sun_path);               /* in case it already exists */ 
  if (bind(fd, (struct sockaddr *)&un, len) < 0)
  { 
     rval=  -2; 
  } 
  else
  {
    /* fill socket address structure with server's address */
      memset(&un, 0, sizeof(un)); 
      un.sun_family = AF_UNIX; 
      strcpy(un.sun_path, servername); 
      len = offsetof(struct sockaddr_un, sun_path) + strlen(servername); 
      if (connect(fd, (struct sockaddr *)&un, len) < 0) 
      {
          rval= -4; 
      } 
      else
      {
         return (fd);
      }
  }
  int err;
  err = errno;
  close(fd); 
  errno = err;
  return rval;    
}
 
 void unix_socket_close(int fd)
 {
    close(fd);     
 }


int main(void)
{ 
  srand((int)time(0));
  int connfd; 
  connfd = unix_socket_conn("foo.sock");
  if(connfd<0)
  {
     printf("Error[%d] when connecting...",errno);
     return 0;
  }
   printf("Begin to recv/send...\n");  
  int i,n,size;
  char rvbuf[4096];
  for(i=0;i<10;i++)
  {
/*
    //=========接收=====================
    size = recv(connfd, rvbuf, 800, 0);   //MSG_DONTWAIT
     if(size>=0)
     {
        printf("Recieved Data[%d]:%c...%c\n",size,rvbuf[0],rvbuf[size-1]);
     }
     if(size==-1)
     {
         printf("Error[%d] when recieving Data.\n",errno);   
             break;     
     }
         if(size < 800) break;
*/
    //=========发送======================
memset(rvbuf,'a',2048);
         rvbuf[2047]='b';
         size = send(connfd, rvbuf, 2048, 0);
     if(size>=0)
     {
        printf("Data[%d] Sended:%c.\n",size,rvbuf[0]);
     }
     if(size==-1)
     {
        printf("Error[%d] when Sending Data:%s.\n",errno,strerror(errno));   
            break;      
     }
         sleep(1);
  }
   unix_socket_close(connfd);
   printf("Client exited.\n");    
 }

```

执行结果
```
[root@cp01-mawmd-rd03 test]# gcc -o domain_socket_server domain_socket_server.c 
[root@cp01-mawmd-rd03 test]# gcc -o domain_socket_client domain_socket_client.c 

[root@cp01-mawmd-rd03 test]# ./domain_socket_server 
Finished listening...
Begin to recv/send...
Recieved Data[804]:a...a
Recieved Data[804]:a...a
Server exited.


[root@cp01-mawmd-rd03 test]# ./domain_socket_client 
Begin to recv/send...
Data[2048] Sended:a.
Data[2048] Sended:a.
Data[2048] Sended:a.
Data[2048] Sended:a.
Data[2048] Sended:a.
Data[2048] Sended:a.
Data[2048] Sended:a.
Data[2048] Sended:a.
Data[2048] Sended:a.
Data[2048] Sended:a.
Client exited.
```


五、 讨论

通过实际测试，发现UNIXDomain Socket与命名管道在表现上有很大的相似性，例如，UNIX Domain Socket也会在磁盘上创建一个socket类型文件；如果读端进程关闭了，写端进程“写数据”时，有可能使进程异常退出，等等。查阅有关文档，摘录如下：


    Send函数
    当调用该函数时，send先比较待发送数据的长度len和套接字s的发送缓冲的 长度，如果len大于s的发送缓冲区的长度，该函数返回SOCKET_ERROR；如果len小于或者等于s的发送缓冲区的长度，那么send先检查协议是否正在发送s的发送缓冲中的数据，如果是就等待协议把数据发送完，如果协议还没有开始发送s的发送缓冲中的数据或者s的发送缓冲中没有数据，那么 send就比较s的发送缓冲区的剩余空间和len，如果len大于剩余空间大小send就一直等待协议把s的发送缓冲中的数据发送完，如果len小于剩余空间大小send就仅仅把buf中的数据copy到剩余空间里（注意并不是send把s的发送缓冲中的数据传到连接的另一端的，而是协议传的，send仅仅是把buf中的数据copy到s的发送缓冲区的剩余空间里）。如果send函数copy数据成功，就返回实际copy的字节数，如果send在copy数据时出现错误，那么send就返回SOCKET_ERROR；如果send在等待协议传送数据时网络断开的话，那么send函数也返回SOCKET_ERROR。
    要注意send函数把buf中的数据成功copy到s的发送缓冲的剩余空间里后它就返回了，但是此时这些数据并不一定马上被传到连接的另一端。如果协议在后续的传送过程中出现网络错误的话，那么下一个Socket函数就会返回SOCKET_ERROR。（每一个除send外的Socket函数在执行的最开始总要先等待套接字的发送缓冲中的数据被协议传送完毕才能继续，如果在等待时出现网络错误，那么该Socket函数就返回 SOCKET_ERROR）
    注意：在Unix系统下，如果send在等待协议传送数据时网络断开的话，调用send的进程会接收到一个SIGPIPE信号，进程对该信号的默认处理是进程终止。

Recv函数与send类似，看样子系统在实现各种IPC时，有些地方是复用的。

本文转载自http://blog.csdn.net/guxch/article/details/7041052，稍加整理