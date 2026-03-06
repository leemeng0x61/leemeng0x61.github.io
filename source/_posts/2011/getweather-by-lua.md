---
title: lua 获得天气信息
date: '2011-03-23'
description: lua demo 程序
categories: [technology]
tags: [lua]
---

其实开始是想做在awesome statbar显示天气的（字体图标的那种），现在终端获得天气已经写好！

明天再着手搞字体的转换问题!

    #!/usr/bin/lua5.1
    local http = require("socket.http")
    ------------------------split-------------------------
    function get_weather(con)
        local s = "<b>.*<br\/><br\/>"
        local i ,j = string.sub(con, string.find(con,s))
        local i, n = string.gsub(i, "<br\/><br\/><b>","\n")
        local i, j = string.gsub(i, "<br\/>","\t")
        local i, j = string.gsub(i, "<\/b>","")
        local i, j = string.gsub(i, "<b>","")
        local i, j = string.gsub(i, "℃","°C")
        local i, j = string.gsub(i, "～","-")
        --  print(i,n+1)--所有天气
        local list_n = split(i, "\n")
        local list_t = split(list_n[1],"\t")
        return list_t
    end
     
    ------------------------split-------------------------
    function split(string, spt)
        local find_index = 1
        local spt_index = 1
        local spt_arr = {}
        while true do
            local find_end = string.find(string, spt, find_index)
            if not find_end then
                spt_arr[spt_index] = string.sub(string, find_index, string.len(string))
                break
            end
            spt_arr[spt_index] = string.sub(string, find_index, find_end - 1)
            find_index = find_end + string.len(spt)
            spt_index = spt_index + 1
        end
        return spt_arr
    end
     
    ------------------------main-------------------------
    function main()
        local url = "http://qq.ip138.com/weather/sichuan/chengdu.wml"
        local con, ret = http.request(url)
        if con == nil then
            print ("nil")
        else
        --  print (con)
            local list_t =  get_weather(con)
            print ('今天天气:',list_t[1],list_t[2],list_t[3],list_t[4])
        end
    end
     
    main()
