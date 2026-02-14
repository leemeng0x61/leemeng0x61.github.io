---
title: 关于awesome设置时间格式的问题！
date: '2011-01-28'
description: Window Manager awesome 的时间显示
categories: [technology]
tags: [awesome]
---

### 支持版本
awesome 3.4.5 以上

### 背景

今天突然想修改下awesome的系统时间显示，google了下，基本都是手册上所说！

格式`%a %b %d, %H:%M `为awesome默认配置（ 在`/etc/xdg/awesome/rc.lua`中并没有这么书写而是
    
    mytextclock = awful.widget.textclock({ align = "right" }) 

后面的格式和时间刷新省略了，默认刷新是60秒），看到`%a %b %d, %H:%M`，让我想到了系统命令`date`的参数，之前曾经处理过类似的格式显示，所以这次直接`man date`，果然，其中的格式控制和上面完全吻合，猜想lua脚本中使用日期格式控制应该是调用系统命令date的格式控制。

### 具体代码
了解到之后就在rc.lua中修改
   
    mytextclock = awful.widget.textclock({ align = "right" },"%x %X",1)

正如预期结果一样，时间显示为（`01/26/11 17:13:48`）！看来lua语言还是调用底层的系统函数来实现日期时间的格式的。（lua也在偷懒）

