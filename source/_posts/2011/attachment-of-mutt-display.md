---
title: 关于mutt发送中文附件，foxmail，outlook接受不到的问题
date: '2011-04-15'
description: mutt中文附件名patch
categories: [technology]
tags: [mutt]
---

经常在linux下工作，所有日常事务也是在linux处理，邮件处理自然也不例外，我这里环境是arch+mutt。带英文附件名的邮件使用mutt发送没有一点问题，中文附件名的邮件就悲剧了，附件在foxmail中不被识别，在outlook和DreamMail里是被篡改的名字类似“xxxxxx.MSWORD",当然你强制用word打开还是没有问题的，但是始终是不爽！所以今天折腾了半天这个问题！    
google了n多帖子，都基本是说设置

    set rfc2047_parameters=yes
    
但是经过测试，这个只能使本地接收到的附件显示为中文附件名！要使自己发送的中文附件名在win下的客户端显示正常，这个不得行！   

又google了n多帖子，就出现了最终的解决方法：

    set create_rfc2047_parameters=yes
    
该设置需要在mutt源码中打patch，named patch-1.5.10.tt.create_rfc2047_params.1 [点击下载](http://www.emaillab.org/mutt/1.5.10/patch-1.5.10.tt.create_rfc2047_params.1.gz)    
再到mutt主页上下在最近的mutt包 named mutt-1.5.21.tar.gz[猛击下载](ftp://ftp.mutt.org/mutt/devel/mutt-1.5.21.tar.gz)    
解压mutt-1.5.21.tar.gz和patch，解压出的patch放到mutt-1.5.21目录下，在该目录执行

    patch -Np1 -i patch-1.5.10.tt.create_rfc2047_params.1

接着再执行

    ./configure &make &sudo make install
    
接个就用吧！mutt发送中文附件邮件，在foxmail中显示就ok了！

**PS：这里要说一点，在ubuntu下，发送中文附件是没问题，但是用mutt中中文是乱码！这个可能与系统设置有关系，暂时没有处理！**
