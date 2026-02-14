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
	@npx hexo clean
	@npx hexo generate
	@npx hexo deploy

.PHONY:install
install:
	@npx hexo clean
	@npx hexo generate
	@npx hexo deploy

.PHONY:clean
clean:
	@npx hexo clean

.PHONY:push
push:
	git add . && git commit -a -m "update" && git push

.PHONY:test
test:
	@npx hexo server

.PHONY:deploy
deploy:
	@npx hexo clean
	@npx hexo generate
	@npx hexo deploy
	git add . && git commit -a -m "update" && git push
