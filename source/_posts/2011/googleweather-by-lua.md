---
title: lua通过google的天气api获得天气
date: '2011-03-24'
description: google天气API
categories: [technology]
tags: [lua]
---
### lua获取天气
昨天写了一个lua的天气脚本，主要是获取[http://qq.ip138.com](http://qq.ip138.com)天气信息，基本功能都已实现，但是唯一不足之处，就是不能显示当前的天气及气温。所以今天在网上找了下这方面的资料，发现google天气API获得满足了这个需求，于是就有折腾了下。google API特点：当天气和气温是实时的，明后几天是温度区间。

上代码先

    #!/usr/bin/lua5.1
    local http = require("socket.http")
    ------------------------regex-------------------------
    function get_weather(con)
        local s = "<current_conditions>.*<\/forecast_conditions>"
        local i ,j = string.sub(con, string.find(con,s))
        local s = "\"[a-z0-9A-Z%s:%%]*\"" 
        local info
        for word in string.gmatch(i, s) do
                info = tostring(info).."\t"..tostring(word) 
        end
        local i, j = string.gsub(info, "\"","")
        local l = split(i,"\t")
        return l
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
        local url = "http://www.google.com/ig/api?weather=chengdu"
        local con, ret = http.request(url)
        if con == nil then
            print ("nil")
        else
            local l =   get_weather(con)
            print(l[2],l[3],l[4],l[5],l[6])
        end
    end
     
    main()
数组中包含了最近几天的天气信息，没有像昨天的那个脚本那样进行分类，这是一个遗憾，不过下标的位置是固定的，这也方便了取值！
