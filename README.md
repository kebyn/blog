# 觅回首

基于 Hexo 8 和 NexT 主题的个人技术博客，站点地址：<https://kebyn.cc>。

## 环境要求

- Node.js >= 20.19.0
- npm（仓库只保留 `package-lock.json`）

## 本地开发

```bash
npm ci
npm run server
```

默认监听 `http://localhost:4000`。

## Makefile

- `make run`：启动 Node LTS 容器，把当前目录挂载到 `/data`。
- `make backup`：把工作区完整打包到 `~/hexo.tar`。

## 构建

```bash
npm run build
```

产物写入 `public/`。`public/` 是独立的部署仓库（`.git` 在其中），不要在本目录执行 `hexo clean`，它会连同部署历史一起删除。

需要全量重建时，复制源码到临时目录后构建，再同步产物：

```bash
mkdir -p /tmp/blog-build
tar -cf - --exclude=public --exclude=node_modules --exclude=.git \
  --exclude=.npm --exclude=db.json -C /data . | tar -xf - -C /tmp/blog-build
cd /tmp/blog-build
npm ci
npx hexo generate

# 同步回部署目录，保留 public/.git
find /data/public -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
cp -a /tmp/blog-build/public/. /data/public/
```

## 备份与恢复

```bash
make backup
# 等价于
tar -cvf ~/hexo.tar -C /data .
```

恢复前先停止 Hexo server，恢复会覆盖 `/data` 现有文件：

```bash
tar -xvf ~/hexo.tar -C /data
```

`hexo.tar` 是完整快照，包含 `public/.git`、`node_modules`、`.npm` 等本地产物。只备份源码时：

```bash
tar -cvf ~/hexo-source.tar \
  --exclude=node_modules --exclude=public --exclude=.npm --exclude=db.json \
  -C /data .
```

## 部署

```bash
cd public
git add -A
git commit -m "chore(site): rebuild with Hexo 8.1.2"
git push origin main
```

## 目录

- `source/_posts/`：文章 Markdown
- `_config.yml`：Hexo 站点配置
- `_config.next.yml`：NexT 主题覆盖配置
- `scaffolds/`：新建文章模板
- `public/`：生成产物与部署仓库（已被外层 `.gitignore` 忽略）
