---
title: 在AWESOME上加入天气使用googleAPI字体weather.ttf
date: '2011-03-26'
description: 用weather.ttf给awesome润色
categories: [technology]
tags: [awesome]
---
### awesome rc.lua
这个脚本加入了词霸的屏幕取词，绑定PrtSc键抓图，还有天气显示！解决了前两天一直琢磨的字体天气问题！   
上张现在桌面图：

![awesome desktop screenshot](http://leaveboy.is-programmer.com/user_files/leaveboy/Image/PrtSc/fullsc.png "screenshot")

awesome 的配置文件 rc.lua

    -- Standard awesome library
    require("awful")
    require("awful.autofocus")
    require("awful.rules")
    -- Theme handling library
    require("beautiful")
    require("vicious")
    -- Notification library
    require("naughty")
     
    -- Load Debian menu entries
    require("debian.menu")
     
    -- --- Variable definitions
    -- Themes define colours, icons, and wallpapers
    beautiful.init("/usr/share/awesome/themes/default/theme.lua")
     
    -- This is used later as the default terminal and editor to run.
    terminal = "x-terminal-emulator"
    editor = os.getenv("EDITOR") or "editor"
    editor_cmd = terminal .. " -e " .. editor
     
    -- Default modkey.
    -- Usually, Mod4 is the key with a logo between Control and Alt.
    -- If you do not like this or do not have such a key,
    -- I suggest you to remap Mod4 to another key using xmodmap or other tools.
    -- However, you can use another modifier like Mod1, but it may interact with others.
    modkey = "Mod4"
     
    -- Table of layouts to cover with awful.layout.inc, order matters.
    layouts =
    {
        awful.layout.suit.floating,
        awful.layout.suit.tile,
        awful.layout.suit.tile.left,
        awful.layout.suit.tile.bottom,
        awful.layout.suit.tile.top,
        awful.layout.suit.fair,
        awful.layout.suit.fair.horizontal,
        awful.layout.suit.spiral,
        awful.layout.suit.spiral.dwindle,
        awful.layout.suit.max,
        awful.layout.suit.max.fullscreen,
        awful.layout.suit.magnifier
    }
    -- ___
     
    -- --- Tags
    -- Define a tag table which hold all screen tags.
    tags = {}
    for s = 1, screen.count() do
        -- Each screen has its own tag table.
        tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
    end
    -- ___
     
    -- --- Menu
    -- Create a laucher widget and a main menu
    myawesomemenu = {
       { "manual", terminal .. " -e man awesome" },
       { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
       { "restart", awesome.restart },
       { "quit", awesome.quit }
    }
     
    mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                        { "Debian", debian.menu.Debian_menu.Debian },
                                        { "open terminal", terminal }
                                      }
                            })
     
    mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                         menu = mymainmenu })
    -- ___
     
    -- --- Wibox
    -- Create a textclock widget
    mytextclock = awful.widget.textclock({ align = "right" },"%x %R",61)
    -------------------------------------leave--------------------------
    --Spacer
    spacer    = widget({ type = "textbox" })
    separator = widget({ type = "textbox" })
    spacer.text     = " "
    separator.text  = "|"
    --Cpu text
    cpu = widget({ type = "textbox" })
    vicious.register(cpu, vicious.widgets.cpu, ' <span color="brown">CPU1:</span> <span color="orange">$2%</span> <span color="brown">CPU2:</span> <span color="orange">$3%</span>', 1)
    --Cpu wigth
    cpu_g1 = awful.widget.graph()
    cpu_g1:set_width(50)
    cpu_g1:set_background_color("#333333")
    cpu_g1:set_color("#AEC6D8")
    cpu_g1:set_border_color("#0a0a0a")
    vicious.register(cpu_g1, vicious.widgets.cpu, "$2", 1)
      
    cpu_g2 = awful.widget.graph()
    cpu_g2:set_width(50)
    cpu_g2:set_background_color("#333333")
    cpu_g2:set_color("#AEC6D8")
    cpu_g2:set_border_color("#0a0a0a")
    vicious.register(cpu_g2, vicious.widgets.cpu, "$3", 1)
    --MPD
    mpd = widget({ type = "textbox" })
    vicious.register(mpd, vicious.widgets.mpd,
        function (widget, args)
                local ret_str = ' <span color="brown">NOW Playing:</span>'
            if args["{state}"] == "Stop" then
                return ret_str .. ' <span color="orange"> - </span>'
            else
                return ret_str .. ' <span color="orange">'.. args["{Artist}"]..' - '.. args["{Title}"]..'</span>'
            end
        end, 3)
    --Weather
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
    weathericon = widget({ type = "imagebox" })
    weathericon.image = image(beautiful.widget_cloud)
    weather = widget({type = "textbox" })
    vicious.register(weather, vicious.widgets.weather,
     function (widget, args)
        local http = require("socket.http")
        local night = {["e"]='o',["f"]='p',["v"]='v',["j"]='t',["k"]='u',["h"]='r',["g"]='q',["c"]='m',["b"]='l',["d"]='n',["a"]='a',["N"]='N',["w"]='w'}
        local weather = {["Sandstorm"]='e',["Duststorm"]='e',["Sand"]='e',["Dust"]='e',["Fog"]='e',["Mist"]='e',["Smoke"]='e',["Haze"]='e',["Overcast"]='e',--'e o' 9th 阴霾
        ["Thunderstorms"]='f',["Thundershowers"]='f',["Storm"]='f',["Lightning"]='f',--'f p' 13th 闪电
        ["Hail"]='v',--'v' 14th 冰雹
        ["Blowing Snow"]='j',["Blizzard"]='j',["Snowdrift"]='j',["Snowstorm"]='j',["Snow"]='j',["Heavy Snow"]='j',["Snowfall"]='j', --'j t' 21th 大雪
        ["Snow Showers"]='k',["Flurries"]='k',["Light Snow"]='k',["Sleet"]='k',--'k u' 25th 小雪
        ["Showers"]='h',["Heavy Showers"]='h',["Rainshower"]='h',["Rain"]='h',--'h r' 29th 大雨
        ["Occasional Showers"]='g',["Scattered Showers"]='g',["Isolated Showers"]='g',["Light Showers"]='g',["Freezing Rain"]='g',["Drizzle"]='g',["Light Rain"]='g',--'g q' 36th 小雨
        ["Sunny Interval"]='c',["No Rain"]='c',["Clearing"]='c',--'c m' 39th 多云见晴
        ["Sunny Period"]='b',["Partly Cloudy"]='b',["Partly Bright"]='b',["Mild"]='b',--'b l' 43th 晴见多云
        ["Cloudy"]='d',["Mostly Cloudy"]='d',--'d, n' 45th 多云
        ["Bright"]='a',["Sunny"]='a',["Fair"]='a', --'a' 48th 白天晴天
        ["Fine"]='N',["Clear"]='N',--'N' 50th 晚间晴天
        ["Windy"]='w',["Squall"]='w',["Stormy"]='w',["Chill"]='w',["Gale"]='w'--'w' 55th 风
    }
        local url = "http://www.google.com/ig/api?weather=chengdu"
        local con, ret = http.request(url)
        if con == nil then
            return nil
        else
            local l =   get_weather(con)
            local font_weather = weather[l[2]]
    --[[        if os.date("%H",os.time())>"17" then
                font_weather = night[font_weather]
            end
            --]]
            local temp_c = 'y'
            if l[4] > "28" then
                temp_c = 'z'
            elseif l[4] < "15" then
                temp_c = 'x'
            end
            return '<span font="Weather regular 16" color="#FFFF00">'..font_weather..'</span><span color="orange"> '..l[4]..'°C</span>'
        end
     end
     
    --"${sky} ${tempc} °C"
    , 1800,"ZUUU")
     
    --UPTIME
    uptime = widget({ type = "textbox" })
    vicious.register(uptime, vicious.widgets.uptime,' <span color="brown">UPTIME:</span> <span color="orange">$2:$3</span>', 61)
    --MEM
    mem = widget({ type = "textbox" })
    vicious.register(mem, vicious.widgets.mem, ' <span color="brown">MEM:</span> <span color="orange">$1% $2MB</span> <span color="brown">SWAP:</span> <span color="orange">$5% $6MB</span>', 1)
    --FS
    fs = widget({ type = "textbox" })
    vicious.register(fs, vicious.widgets.fs, ' <span color="brown">FS:</span> <span color="orange">${/ used_gb}GB ${/ used_p}%</span>', 5)
    --DIO
    dio = widget({ type = "textbox" })
    vicious.register(dio, vicious.widgets.dio, ' <span color="brown">IO:</span> <span color="orange">R:${read_kb}KB W:${write_kb}KB</span>', 1, "sda")
    --NET
    net = widget({ type = "textbox" })
    vicious.register(net, vicious.widgets.net, ' <span color="brown">NET:</span> <span color="orange">${eth0 down_kb}KB/${eth0 up_kb}KB</span>', 1)
    -------------------------------------leave--------------------------
    -- Create a systray
    mysystray = widget({ type = "systray" })
     
    -- Create a wibox for each screen and add it
    mywibox_top = {}
    mywibox_bottom = {}
    mypromptbox = {}
    mylayoutbox = {}
    mytaglist = {}
    mytaglist.buttons = awful.util.table.join(
                        awful.button({ }, 1, awful.tag.viewonly),
                        awful.button({ modkey }, 1, awful.client.movetotag),
                        awful.button({ }, 3, awful.tag.viewtoggle),
                        awful.button({ modkey }, 3, awful.client.toggletag),
                        awful.button({ }, 4, awful.tag.viewnext),
                        awful.button({ }, 5, awful.tag.viewprev)
                        )
    mytasklist = {}
    mytasklist.buttons = awful.util.table.join(
                         awful.button({ }, 1, function (c)
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  client.focus = c
                                                  c:raise()
                                              end),
                         awful.button({ }, 3, function ()
                                                  if instance then
                                                      instance:hide()
                                                      instance = nil
                                                  else
                                                      instance = awful.menu.clients({ width=250 })
                                                  end
                                              end),
                         awful.button({ }, 4, function ()
                                                  awful.client.focus.byidx(1)
                                                  if client.focus then client.focus:raise() end
                                              end),
                         awful.button({ }, 5, function ()
                                                  awful.client.focus.byidx(-1)
                                                  if client.focus then client.focus:raise() end
                                              end))
     
    for s = 1, screen.count() do
        -- Create a promptbox for each screen
        mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
        -- Create an imagebox widget which will contains an icon indicating which layout we're using.
        -- We need one layoutbox per screen.
        mylayoutbox[s] = awful.widget.layoutbox(s)
        mylayoutbox[s]:buttons(awful.util.table.join(
                               awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                               awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                               awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                               awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
        -- Create a taglist widget
        mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)
     
        -- Create a tasklist widget
        mytasklist[s] = awful.widget.tasklist(function(c)
                                                  return awful.widget.tasklist.label.currenttags(c, s)
                                              end, mytasklist.buttons)
     
        -- Create the wibox
        mywibox_top[s] = awful.wibox({ position = "top", screen = s })
        mywibox_bottom[s] = awful.wibox({ position = "bottom", screen = s })
        -- Add widgets to the wibox - order matters
            -- top
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
            --bottom
        mywibox_bottom[s].widgets = {
                {
                    fs,
                    separator,
                    mem,
                    separator,
                    dio,
                    separator,
                    net,
                    separator,
                    mpd,
                    layout = awful.widget.layout.horizontal.leftright
                },
                    cpu_g1.widget,
                    spacer,
                    cpu_g2.widget,
                    spacer,
            layout = awful.widget.layout.horizontal.rightleft
        }
    end
    -- ___
     
    -- --- Mouse bindings
    root.buttons(awful.util.table.join(
        awful.button({ }, 3, function () mymainmenu:toggle() end),
        awful.button({ }, 4, awful.tag.viewnext),
        awful.button({ }, 5, awful.tag.viewprev)
    ))
    -- ___
     
    -- --- Key bindings
    globalkeys = awful.util.table.join(
        awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
        awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
        awful.key({ modkey,           }, "Escape", awful.tag.history.restore),
     
        awful.key({ modkey,           }, "j",
            function ()
                awful.client.focus.byidx( 1)
                if client.focus then client.focus:raise() end
            end),
        awful.key({ modkey,           }, "k",
            function ()
                awful.client.focus.byidx(-1)
                if client.focus then client.focus:raise() end
            end),
        awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),
            -- Unminimize clients
            awful.key({ modkey, "Control" }, "m",
            function ()
                local allclients = client.get(mouse.screen)
                for _, c in ipairs(allclients) do
                    if c.minimized and c:tags()[mouse.screen] == awful.tag.selected(mouse.screen) then
                        c.minimized = false
                        client.focus = c
                        c:raise()
                        return
                    end
                end
            end),
        -- Layout manipulation
        awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
        awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
        awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
        awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
        awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
            -- 截图 ---3
            awful.key({ }, "Print", function ()
                -- 截图：全屏
                awful.util.spawn("zsh -c 'cd ~/tmpfs&&scrot fullsc.png'")
                os.execute("sleep .5")
                naughty.notify({title="截图", text="全屏截图已保存。"})
            end),
            awful.key({ "Shift", }, "Print", function ()
                -- 截图：当前窗口
                awful.util.spawn("zsh -c 'cd ~/tmpfs&&scrot -u'")
                os.execute("sleep .5")
                naughty.notify({title="截图", text="当前窗口截图已保存。"})
            end),
     
            -- ---3 sdcv
            awful.key({ modkey }, "d", function ()
                local f = io.popen("xsel -p")
                local new_word = f:read("*a")
                f:close()
     
                if frame ~= nil then
                    naughty.destroy(frame)
                    frame = nil
                    if old_word == new_word then
                        return
                    end
                end
                old_word = new_word
     
                local fc = ""
                local f = io.popen("sdcv -n --utf8-output -u 'stardict1.3英汉辞典' "..new_word)
                for line in f:lines() do
                    fc = fc .. line .. '\n'
                end
                f:close()
                frame = naughty.notify({ text = fc, timeout = 5, width = 320 })
            end),
        awful.key({ modkey,           }, "Tab",
            function ()
                awful.client.focus.history.previous()
                if client.focus then
                    client.focus:raise()
                end
            end),
     
        -- Standard program
        awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
        awful.key({ modkey, "Control" }, "r", awesome.restart),
        awful.key({ modkey, "Shift"   }, "q", awesome.quit),
     
        awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
        awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
        awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
        awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
        awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
        awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
        awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
        awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),
     
        -- Prompt
        awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),
     
        awful.key({ modkey }, "x",
                  function ()
                      awful.prompt.run({ prompt = "Run Lua code: " },
                      mypromptbox[mouse.screen].widget,
                      awful.util.eval, nil,
                      awful.util.getdir("cache") .. "/history_eval")
                  end)
    )
     
    clientkeys = awful.util.table.join(
        awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
        awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
        awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
        awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
        awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
        awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
        awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
        awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
        awful.key({ modkey,           }, "m",
            function (c)
                c.maximized_horizontal = not c.maximized_horizontal
                c.maximized_vertical   = not c.maximized_vertical
            end)
    )
     
    -- Compute the maximum number of digit we need, limited to 9
    keynumber = 0
    for s = 1, screen.count() do
       keynumber = math.min(9, math.max(#tags[s], keynumber));
    end
     
    -- Bind all key numbers to tags.
    -- Be careful: we use keycodes to make it works on any keyboard layout.
    -- This should map on the top row of your keyboard, usually 1 to 9.
    for i = 1, keynumber do
        globalkeys = awful.util.table.join(globalkeys,
            awful.key({ modkey }, "#" .. i + 9,
                      function ()
                            local screen = mouse.screen
                            if tags[screen][i] then
                                awful.tag.viewonly(tags[screen][i])
                            end
                      end),
            awful.key({ modkey, "Control" }, "#" .. i + 9,
                      function ()
                          local screen = mouse.screen
                          if tags[screen][i] then
                              awful.tag.viewtoggle(tags[screen][i])
                          end
                      end),
            awful.key({ modkey, "Shift" }, "#" .. i + 9,
                      function ()
                          if client.focus and tags[client.focus.screen][i] then
                              awful.client.movetotag(tags[client.focus.screen][i])
                          end
                      end),
            awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                      function ()
                          if client.focus and tags[client.focus.screen][i] then
                              awful.client.toggletag(tags[client.focus.screen][i])
                          end
                      end))
    end
     
    clientbuttons = awful.util.table.join(
        awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
        awful.button({ modkey }, 1, awful.mouse.client.move),
        awful.button({ modkey }, 3, awful.mouse.client.resize))
     
    -- Set keys
    root.keys(globalkeys)
    -- ___
     
    -- --- Rules
    awful.rules.rules = {
        -- All clients will match this rule.
        { rule = { },
          properties = { border_width = beautiful.border_width,
                         border_color = beautiful.border_normal,
                         focus = true,
                         keys = clientkeys,
                         buttons = clientbuttons } },
        { rule = { class = "MPlayer" },
          properties = { floating = true } },
        { rule = { class = "pinentry" },
          properties = { floating = true } },
        { rule = { class = "gimp" },
          properties = { floating = true } },
        -- Set Firefox to always map on tags number 2 of screen 1.
        -- { rule = { class = "Firefox" },
        --   properties = { tag = tags[1][2] } },
    }
    -- ___
     
    -- --- Signals
    -- Signal function to execute when a new client appears.
    client.add_signal("manage", function (c, startup)
        -- Add a titlebar
        -- awful.titlebar.add(c, { modkey = modkey })
     
        -- Enable sloppy focus
        c:add_signal("mouse::enter", function(c)
            if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
                and awful.client.focus.filter(c) then
                client.focus = c
            end
        end)
     
        if not startup then
            -- Set the windows at the slave,
            -- i.e. put it at the end of others instead of setting it master.
            -- awful.client.setslave(c)
     
            -- Put windows in a smart way, only if they does not set an initial position.
            if not c.size_hints.user_position and not c.size_hints.program_position then
                awful.placement.no_overlap(c)
                awful.placement.no_offscreen(c)
            end
        end
    end)
     
    client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
    client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
    -- ___
    floatapps =
    {
        ["MPlayer"] = true,
        ["gimp"] = true,
        ["smplayer"] = true,
        ["mocp"] = true,
        ["Codeblocks"] = true,
        ["Dialog"] = true,
        ["Download"] = true,
        ["empathy"] = true,
    }
     
    -- 把指定的程序自动移动到某个特定的屏幕的某个tag上面
    apptags =
    {
        ["smplayer"] = { screen = 1, tag = 7 },
        ["amarokapp"] = { screen = 1, tag = 8 },
        ["VirtualBox"] = { screen = 1, tag = 9 },
        ["Firefox"] = { screen = 1, tag = 1},
        ["Thunderbird-bin"] = { screen = 1, tag = 7 },
        ["Linux-fetion"] = { screen = 1, tag = 6 },
    }
