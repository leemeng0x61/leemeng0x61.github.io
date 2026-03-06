---
title: awesome 脚本中加入天气
date: '2011-03-25'
description: wm awesome 中添加天气
categories: [technology]
tags: [awesome]
---

将这几天做的lua脚本和入到awesome脚本中。
目前缺点：可以获取天气信息，不过天气是文字形式的！

相关函数   

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

添加控件widget    

    weather = widget({type = "textbox" })
    vicious.register(weather, vicious.widgets.weather,
     function (widget, args)
        local http = require("socket.http")
        local url = "http://www.google.com/ig/api?weather=chengdu"
        local con, ret = http.request(url)
        if con == nil then
            return nil
        else
            local l =   get_weather(con)
            return '<span color="brown">WEATHER:</span><span  color="orange">'..l[2]..' '..l[4]..'°C</span>'
        end
     end
    , 3600,"ZUUU")

添加到盘pannel    

    mywibox_top[s].widgets = {
           {
               mylauncher,
               mytaglist[s],
               mypromptbox[s],
               layout = awful.widget.layout.horizontal.leftright
           },
           mylayoutbox[s],
           mytextclock,
           s == 1 and mysystray or nil,
                   spacer,
                   uptime,
                       weather,
                   spacer,
                   weathericon,
           mytasklist[s],
           layout = awful.widget.layout.horizontal.rightleft
       }
