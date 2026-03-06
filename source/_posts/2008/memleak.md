---
title: 使用 memleak 检查和调试内存泄漏
date: '2008-11-26'
description: 嵌入式程序调试利器
categories: [technology]
tags: [code]
---

###  memleak

###  使用范围：
小型的嵌入式应用中经常会出现许多内存问题，很多情况下难以定位问题出现在哪里。
我在 [sourceforge](http://sourceforge.net/)上找了些检测 C 内存泄漏的工具，感觉比较易用的是 [memleak](http://sourceforge.net/projects/memleak/)，下面就来简要介绍一下它的使用。

###  用法：
下载得到的 `memleak` 压缩包大小不到 15 kB，解压后只有两个文件：`memleak.c` 和 `memleak.h`。在使用过程中只需要包含头文件 `memleak.h` 就可以使用 `memleak` 提供的几个易用而有效的内存检测函数了。

`memleak` 的原理是利用 `C` 语言的宏调用来替代原有的函数调用，比如我们在代码中调用 `malloc(s)`，实际是调用了：`dbg_malloc(s)`，这个宏定义在 `memleak.h` 中给出：
    #define malloc(s) (FILE_LINE, dbg_malloc(s))

`memleak` 维护了一个链表，在这个链表中保存着程序中对内存函数调用的记录，这些函数包括：`malloc`、`calloc`、`realloc`、`free`。每次调用这些函数时，就会更新这个链表。   
有 了这个表，我们就可以在适当的位置调用 `memleak` 提供的函数，显示一些重要的信息，包括 `malloc`、`calloc`、`realloc`、`free`调用的次数，申请及分配的内存数，调用的文件和位置等等，信息非常详细。有了这些功能，我们就很容 易定位内存使用的错误源。

由于 `memleak` 在某些交叉编译器下不能正常编译通过，这里我将 `memleak.c` 中的结构体 `struct head` 修改如下：

    struct head
    {
        struct head *addr;
        size_t size;
        char *file;
        unsigned line;
        /* two addresses took the same space as an address and an integer on many archs => usable */
        union lf {
            struct { struct head*prev, *next; } list;
            struct { char *file; unsigned line; } free;
        } u;
    };

`memleak.c` 文件中其它调用到 `head` 中共用体 `u` 的地方也要做相应的修改。
修改后的文件可以点击这里下载。    

 

`memleak` 提供了以下几个函数接口：

    extern void dbg_init(int history_length);
    extern int dbg_check_addr(char *msg, void *ptr, int opt);
    extern void dbg_mem_stat(void);
    extern void dbg_zero_stat(void);
    extern void dbg_abort(char *msg);
    extern void dbg_heap_dump(char *keyword);
    extern void dbg_history_dump(char *keyword);
    extern void dbg_catch_sigsegv(void);

详细的介绍请查看 `memleak.c` 头部的注释或查看源代码理解。

 

下面举个简单的例子：

    #include "memleak.h"
    int main(void)
    {
        char * s, * t;
        dbg_init(10);
        s = (char *)malloc(100);    // 申请 100 bytes
        t = (char *)malloc(11);     // 再申请 11 bytes
        free(s);                    // 释放 100 bytes
        s = (char *)malloc(80);     // 重新申请 80 bytes
        dbg_heap_dump("");          // 显示调用栈
        dbg_mem_stat();             // 显示调用统计
        free(t);                    // 释放 11 bytes
        free(s);                    // 释放 80 bytes
        dbg_mem_stat();             // 再次显示调用统计
        return 0;
    }

编辑后保存为 `test.c`，与 `memleak.c` 和 `memleak.h` 放于同一目录下。
然后编写一 `Makefile`：

    CC = gcc
    EXEC = test
    CSRC = test.c memleak.c
    OBJS = $(patsubst %.c,%.o, $(CSRC))
    all: $(EXEC)
    $(EXEC): $(OBJS)
    $(CC) $(OBJS) $(LDFLAGS) $(LDLIBS) -o $@
    $(OBJS): %.o : %.c
    $(CC) $(CFLAGS) -c $< -o $@
    clean:
    -rm -f $(EXEC) *.elf *.gdb *.o

也保存于同一目录，在该目录下 make 编译，执行 ./test 后输出如下：

    \***** test.c:14: heap dump start
    (alloc: test.c:11 size: 11)
    (alloc: test.c:13 size: 80)
    \***** test.c:14: heap dump end
    test.c:15: m: 3, c: 0, r: 0, f: 1, mem: 91
    test.c:18: m: 3, c: 0, r: 0, f: 3, mem: 0

怎么样，很简单吧？

 

`memleak` 中还有一个函数 `dbg_catch_sigsegv(void)`，可以绑定系统出现 `SIGSEGV` 信号时的处理函数，我们可以通过修改 `memleak.c` 中的 `sigsegv_handler`，自定义这个 `SIGSEGV` 信号处理函数。不知道 `uClinux` 下的 `SIGSEGV` 信号是否也存在，有的话调试一些内存问题就更容易了。

最后从网上摘来一段 `SIGSEGV` 的介绍：

    SIGSEGV --- Segment Fault. The possible cases of your encountering this error are:
    1.buffer overflow --- usually caused by a pointer reference out of range.
    2.stack overflow --- please keep in mind that the default stack size is 8192K.
    3.illegal file access --- file operations are forbidden on our judge system.
