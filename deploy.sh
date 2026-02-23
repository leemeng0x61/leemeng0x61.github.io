#!/bin/bash
#=============================================================================
#     FileName: deploy.sh
#         Desc: Auto Blog deploy
#       Author: Lee Meng
#        Email: leemeng0x61@gmail.com
#     HomePage: https://leemeng0x61.github.io/
#      Version: 0.0.1
#   LastChange: 2013-01-26 23:32:52
#      History:
#=============================================================================
npx hexo clean
npx hexo generate
npx hexo deploy
git add . && git commit -a -m "update" && git push