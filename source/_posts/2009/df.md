---
title: statfs获得硬盘使用情况 模拟linux命令 df （2011.3.24修正）
date: '2009-10-10'
description: statfs获得硬盘使用情况
categories: [technology]
tags: [code]
---

###  statfs:

###  结构：

    #include <sys/vfs.h>    /* 或者 <sys/statfs.h> */

    int statfs(const char *path, struct statfs *buf);
    int fstatfs(int fd, struct statfs *buf);

 

###  参数：  
    `path`: 位于需要查询信息的文件系统的文件路径名。    
    `fd`： 位于需要查询信息的文件系统的文件描述词。
    `buf`：以下结构体的指针变量，用于储存文件系统相关的信息

    struct statfs {
       long    f_type;     /* 文件系统类型  */
       long    f_bsize;    /* 经过优化的传输块大小  */
       long    f_blocks;   /* 文件系统数据块总数 */
       long    f_bfree;    /* 可用块数 */
       long    f_bavail;   /* 非超级用户可获取的块数 */
       long    f_files;    /* 文件结点总数 */
       long    f_ffree;    /* 可用文件结点数 */
       fsid_t  f_fsid;     /* 文件系统标识 */
       long    f_namelen;  /* 文件名的最大长度 */
    };

`statfs`结构中可用空间块数有两种`f_bfree`和 `f_bavail`，前者是硬盘所有剩余空间，后者为非`root`用户剩余空间，`ext3`文件系统给`root`用户分有5%的独享空间，所以这里是不同的地方。这里要强调的是每块的大小一般是4K。因此，要实现与df结果一致的就得在获得块数上乘以4，这样已用、可用、总块数就可以实现。如果还要实现百分比一致，那么要注意的是，`df`命令获得是整数百分比，没有小数，这里使用的进一法，而不是四舍五入法。所以在程序里直接+1取整。

下面是实现的一个例子：（home目录为一个独立分区）
    #include <stdio.h>
    #include <sys/vfs.h>

    int main()
    {
        struct statfs sfs;
        int i = statfs("/home", &sfs);
        int percent = (sfs.f_blocks - sfs.f_bfree ) * 100 / (sfs.f_blocks - sfs.f_bfree + sfs.f_bavail) + 1;
        printf("/dev/sda11            %ld    %ld  %ld   %d%% /home\n",
                               4*sfs. f_blocks, 4*(sfs.f_blocks - sfs.f_bfree),      4*sfs.f_bavail, percent);
        system("df /home ");
        return 0;

    }

执行结果:

    leave@LEAVE:~/test$ gcc -o df df.c
    leave@LEAVE:~/test$ ./df
    /dev/sda11            42773008    540356  40059864   2% /home
    文件系统           1K-块        已用     可用 已用% 挂载点
    /dev/sda11            42773008    540356  40059864   2% /home
    leave@LEAVE:~/test$

-----------------------------------------`busybox` 中使用的挂载分区获取使用率-----------------------------

    #include <stdio.h>
    #include <sys/vfs.h>

    #include <string.h>


    extern int get_free_rate(char *path)
    {
     struct statfs str_diskatr;
     long blocks_percent_used=0;
     long blocks_used=0;
     memset( &str_diskatr, 0x00, sizeof(str_diskatr) );

     if ( 0x00 == statfs( path, &str_diskatr ) )
     {
      if ( (str_diskatr.f_blocks != 0x00) ){
       blocks_used = str_diskatr.f_blocks - str_diskatr.f_bfree;
       blocks_percent_used = (((long long) blocks_used) * 100
         + (blocks_used + str_diskatr.f_bavail)/2
         ) / (blocks_used + str_diskatr.f_bavail);
       return blocks_percent_used;
      }
      else
       return -1;
     }
     else if(-1 == statfs( path, &str_diskatr ))
     {
      if(errno == ENOENT)
      {
       return 0;
      }
     }
     else
     {return -1;}

     return -1;
    }

上面程序裁剪自`busybox`，使用

    #define IDEDIR  "/mnt/ide/"   //挂载目录

    （int ）ide_useage = get_free_rate(IDEDIR);


----------------------------------计算文件夹占用空间大小-----------------------------------------------
 
    #include <stdio.h>
    #include <errno.h>
    #include <unistd.h>
    #include <sys/types.h>
    #include <sys/stat.h>

    static unsigned int total = 0;

    int sum(const char *fpath, const struct stat *sb, int typeflag)
    {

        total += sb->st_size;
        return 0;

    }


    int main(int argc, char **argv)
    {

        if (!argv[1] || access(argv[1], R_OK)) {

            return 1;

        }

        if (ftw(argv[1], &sum, 1)) {

            perror("ftw");

            return 2;

        }

        printf("%s: %u\n", argv[1], total);

        return 0;

    }

执行结果:

    lm@LM:/home/lm/tmpfs/c_c++> gcc -o du  du.c            11-03-24 10:06
    lm@LM:/home/lm/tmpfs/c_c++> ./du /home/lm/音乐         11-03-24 10:22
    /home/lm/音乐: 726629477
    lm@LM:/home/lm/tmpfs/c_c++>                            11-03-24 10:22


* （2010.6.29修正 添加busybox中的系统算法）
* （2011.3.24修正 添加获取文件夹的大小）
