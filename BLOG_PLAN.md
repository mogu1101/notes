# Next.js 个人博客启动方案

## 目标
搭建一个可长期扩展的个人博客，支持：
- 技术文档
- 兴趣爱好与生活记录
- 图文内容
- 音频/视频
- 游戏内容（嵌入或独立页面）

## 技术选型
- 框架：Next.js（App Router）
- 内容：MDX
- 样式：Tailwind CSS
- 部署：Vercel（首选）
- 可选能力：
  - 评论：Giscus
  - 数据：PostgreSQL + Prisma
  - 认证：Auth.js 或 Clerk
  - 搜索：Pagefind / Algolia

## 仓库重构建议
在当前仓库新增以下结构：

```text
notes/
  content/
    docs/
    blog/
    life/
    hobbies/
  site/
    app/
    components/
    lib/
    public/
  assets/
```

说明：
- `content/` 用于存放文章（md/mdx）。
- `site/` 是 Next.js 项目。
- `assets/` 放音频、视频封面、游戏静态资源等。

## 初始化步骤（可直接执行）
在仓库根目录执行：

```bash
# 1) 创建 Next.js 项目到 site/
npx create-next-app@latest site --ts --eslint --tailwind --app --src-dir --import-alias "@/*"

# 2) 安装 MDX 与内容工具
cd site
npm i @next/mdx @mdx-js/loader @mdx-js/react gray-matter reading-time remark-gfm rehype-slug rehype-autolink-headings

# 3) 可选：媒体与交互
npm i next-video
```

## 内容模型建议
每篇文章 frontmatter 示例：

```yaml
title: "文章标题"
date: "2026-05-02"
summary: "一句话摘要"
category: "ios"
tags: ["swift", "runtime"]
cover: "/covers/xxx.jpg"
audio: "https://.../podcast.mp3"
video: "https://www.youtube.com/watch?v=..."
game: "https://..."
draft: false
```

## 首批页面清单
- `/` 首页（最新内容 + 分类入口）
- `/docs` 技术文档索引
- `/blog` 博客流
- `/life` 生活记录
- `/hobbies` 兴趣内容
- `/media` 音视频聚合
- `/games` 游戏入口页
- `/about` 关于

## 三阶段实施
1. **阶段一（本周）**：完成脚手架与基础页面。
2. **阶段二（下周）**：迁移现有 markdown 内容，统一 frontmatter。
3. **阶段三（后续）**：接入评论、搜索、订阅与统计。

## 迁移建议
- 先迁移高质量、可公开的文章。
- 对图片与附件路径做统一（建议放到 `site/public/`）。
- 对旧文档增加 `summary/tags/date`，提升检索与列表体验。

## 验收标准
- 能在本地 `npm run dev` 正常访问。
- 至少 10 篇文章可正常渲染。
- 音频/视频/游戏链接页面可展示。
- GitHub push 后可自动部署。
