# 个人博客

基于 Hexo 的个人博客，使用 NexT 主题。

## 快速开始

### 安装依赖

```bash
npm install
```

### 本地预览

```bash
make test
# 或
npx hexo server
```

### 生成静态文件

```bash
make
# 或
npx hexo clean && npx hexo generate
```

### 发布部署

```bash
npx hexo deploy
```

## 目录结构

- `source/_posts/` - 博客文章
- `source/assets/media/` - 文章图片资源
- `themes/next/` - NexT 主题
- `scaffolds/` - 文章模板

## 写作规范

- 文章文件名使用英文命名
- 图片存放在 `source/assets/media/年份/` 目录下
- Front Matter 必须包含：title, date, categories, tags
