# Lee Meng's Blog

基于 Hexo 7.3.0 的个人博客，使用 NexT 主题。记录技术与生活的点滴。

## 技术栈

- **框架**: Hexo 7.3.0
- **主题**: NexT
- **部署**: GitHub Pages (gh-pages 分支)
- **插件**:
  - hexo-deployer-git - Git 部署
  - hexo-generator-feed - RSS/Atom 订阅
  - hexo-generator-searchdb - 站内搜索
  - hexo-generator-sitemap - 站点地图
  - hexo-word-counter - 字数统计

## 快速开始

### 安装依赖

```bash
npm install
```

### 本地预览

```bash
npx hexo server
# 访问 http://localhost:4000
```

### 生成静态文件

```bash
npx hexo clean && npx hexo generate
```

### 一键部署

使用部署脚本：

```bash
bash deploy.sh
```

或手动部署：

```bash
npx hexo deploy
git add . && git commit -m "update" && git push
```

## 目录结构

```
.
├── source/                 # 源文件目录
│   ├── _posts/            # 博客文章 (按年份分类)
│   │   ├── 2006/          # 早期生活记录
│   │   ├── 2011-2013/     # 技术文章 (Linux, Android 等)
│   │   └── 2026/          # 近期生活随笔
│   ├── images/            # 图片资源 (按年份/日期分类)
│   └── about/             # 关于页面
├── themes/next/           # NexT 主题
├── scaffolds/             # 文章模板
├── public/                # 生成的静态文件
├── _config.yml            # Hexo 配置
└── deploy.sh              # 部署脚本
```

## 博客内容

### 技术文章 (2011-2013)

- Linux 系统配置 (Awesome WM, irssi, mutt)
- Android 开发 (截图工具, adb 配置)
- 编程实践 (Perl, Lua, 正则表达式)
- 系统工具 (内存检测, 文件操作)

### 生活随笔 (2006-2026)

- 旅行记录 (珠海, 澳门, 重庆)
- 摄影作品 (城市夜景, 自然生态)
- 情感记录 (家庭, 友情, 回忆)
- 文化思考 (代际对话, 城市哲学)

## 写作规范

### 新建文章

```bash
npx hexo new "文章标题"
```

### Front Matter 规范

```yaml
---
title: 文章标题
date: YYYY-MM-DD
description: 文章描述
categories: [life/technology]
tags: [标签1, 标签2]
---
```

### 图片管理

- 图片存放路径: `source/images/YYYY/MM/DD/`
- 引用格式: `![描述](/images/YYYY/文件名.jpg)`
- 支持格式: jpg, png, gif

## 站点信息

- **作者**: Leemeng0x61
- **网站**: https://leemeng0x61.github.io/
- **座右铭**: A man's dreams are index to his greatness
- **时区**: Asia/Shanghai
- **语言**: 中文

## 部署说明

博客使用双仓库管理：

1. **源码仓库** (当前): 存储 Hexo 源文件和配置
2. **发布仓库**: leemeng0x61.github.io (gh-pages 分支)

部署流程：
1. 本地编写文章
2. 执行 `bash deploy.sh` 自动构建并部署
3. 同时提交源码到源码仓库

## 开发历史

- **2006-2008**: 博客初创，记录大学生活
- **2011-2013**: 技术沉淀期，Linux/Android 开发
- **2026**: 重启博客，生活感悟与摄影创作

## License

本博客内容采用个人版权，未经许可请勿转载。
