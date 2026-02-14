#=============================================================================
#=============================================================================
#     FileName: Makefile
#         Desc: Auto Blog Makefile
#       Author: Lee Meng
#        Email: leemeng0x61@gmail.com
#     HomePage: https://leemeng0x61.github.io/
#      Version: 0.0.1
#   LastChange: 2013-01-26 23:32:52
#      History:
#=============================================================================
src = public

all:
	rm ${src} -fr
	@npx hexo deploy

.PHONE:install
install:
	rm ${src} -fr
	@npx hexo deploy

.PHONE:clean
clean:
	@rm  -fr ${src}

.PHONE:push
push:
	git add . && git commit -a -m "update" && git push

.PHONE:test
test:
	@npx hexo server
