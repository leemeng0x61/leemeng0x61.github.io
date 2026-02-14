---
title: 写了一个类似prey功能的脚本
date: '2011-08-24'
description: 用perl实现prey的功能
categories: [technology]
tags: [code]
---
在网上年到prey(就是传说中的黑客找回已丢电脑那个工具)感觉还不错,就是要注册,使用次数还有限制,所以打算自己折腾一下! 

### lost 脚本放在/usr/bin 下,请自己加执行权限:

    chmod +x /usr/bin/lost
    
### 使用方法:

    lost -h

### 脚本源码lost:
    #!/bin/bash
    ####################################################################
    # Lost create by leaveboy@gmail.com
    # Discription: when your pc lost,it can help you to find it!
    # License: GPLv3
    ###################################################################)
    version=1.0
     
    scp_user='leaveboy'  #user
    scp_server='216.194.70.6' #an online server which pc could connect
    scp_path="/home/${scp_user}/" #lost file path
    email='leaveboy@gmail.com'  # address msg_file and image send to
    msg_file='/tmp/lostinfo'
     
    show_version(){
        echo "Prey ${version}"
    }
    show_usage(){
        echo "Prey ${version} "
        echo -e "\nUsage: `basename $0` [options]"
        echo -e "Options:"
        echo -e "  -v | --version\tShow Current Version."
        echo -e "  -h | --help\t\tShow this message.\n"
        echo -e "NOTICE"
        echo -e "  This script runs under linux system and For Run this script you should have follow software:\
            w3m scrot mutt ssh.\n"
        echo -e "ADD/DELETE CRONTAB"
        echo -e "  Run the follow command to add lost to crontab:"
        echo -e "  \$(sudo crontab -l | grep -v lost; echo \"*/20 * * * * /usr/bin/lost > /var/log/lost.log\") | sudo crontab -"
        echo -e "  Run the follow command to delete lost from crontab:"
        echo -e "  \$(sudo crontab -l | grep -v lost) | sudo crontab -\n"
        echo -e "ACTIVE/UNACTIVE"
        echo -e "  Touch a file named \"lost\"under the scp_path of the scp_server to actived."
        echo -e "  remove the file \"lost\" under the scp_path of the scp_server to unactived.\n"
    }
     
    until [ -z "$1" ]; do
        case "$1" in
            -v | --version )
                show_version && exit
                ;;
            -h | --help | * )
                show_usage && exit
        esac
        shift
    done
     
    send_mail(){
        F=`scrot '%F-%T_$wx$h_scrot.png' -e  'mv $f /tmp/ & echo $f'`
        #you can add any what you want in here
        `w3m http://www.ip138.com/ips8.asp  | grep '来自' > ${msg_file}`    #网络地址
        `uname -a >>  ${msg_file}`                                          #系统信息
        `uptime   >>  ${msg_file}`                                          #启动信息
        `ifconfig >>  ${msg_file}`                                          #网络信息
        `ps ux   >>  ${msg_file}`                                           #用户进程
        `more ${msg_file} | mutt -s "lost" ${email} -a /tmp/${F}`
    }
    #run condition you can change it and get some info from lost,of course,if it has!
    if [ -f "/tmp/lost" ]; then
        send_mail && exit
    else
        `scp ${scp_user}@${scp_server}:${scp_path}/lost /tmp/lost`
        if [ -f "/tmp/lost" ]; then
            send_mail && exit
        fi
    fi
