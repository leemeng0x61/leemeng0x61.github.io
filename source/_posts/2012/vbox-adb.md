---
title: ubuntu virtualbox XP 使用adb受限问题
date: '2012-10-18'
description: vbox使用adb
categories: [technology]
tags: [android]
---
### 前提条件:
ubuntu 在vbox XP下使用`adb shell`

### 问题说明:
    C:\Documents and Settings\Administrator>adb devices
    List of devices attached
    MSM8225I370 device
    	
    C:\Documents and Settings\Administrator>adb shell
    error: protocol fault (status 72 6f 6f 74?!)

### 原因在于:
virtualbox XP 设置时,USB设备 启用USB2.0 EHCI控制器.如果启用了该选项就会导致`adb shell`无法启动,偶尔会导致 QTSP中无法烧写model侧img
