---
title: HuggingFace 模型下载
date: 2025-11-11 09:31:23
tags:
- huggingface
- model
- download
- docker
- vllm
---
使用 `huggingface-cli`、镜像站和 Docker 下载模型。

<!-- more -->

# huggingface-cli
```

# 使用 docker 环境
$ docker run --name huggingface --rm -it -v /data/:/data/ -v /root:/root python bash

# 使用代理下载
# export http_proxy=http://proxy.example.com:8080 https_proxy=http://proxy.example.com:8080

# 使用 modelscope 替换 huggingface-cli 命令
# modelscope download --local-dir /data/DeepSeek-V3/v1/ deepseek-ai/DeepSeek-V3

# 使用 hf-mirror.com 镜像下载
export HF_ENDPOINT=https://hf-mirror.com
# export HF_ENDPOINT=https://aifasthub.com
# 启用 rust 模块进行快速下载，会停用多线程下载，经过测试，速度会稍有提升
export HF_HUB_ENABLE_HF_TRANSFER=1

# 下载 model
huggingface-cli download --local-dir /data/DeepSeek-V3/v1/ deepseek-ai/DeepSeek-V3

# 下载指定目录
huggingface-cli download unsloth/DeepSeek-V3-GGUF --include "DeepSeek-V3-Q4_K_M*"
```

# modelexpress
> https://github.com/ai-dynamo/modelexpress
```
# ./modelexpress-server -h
High-performance gRPC server for model serving and management

Usage: modelexpress-server [OPTIONS]

Options:
  -c, --config <FILE>
          Configuration file path
  -p, --port <PORT>
          Server port [env: MODEL_EXPRESS_SERVER_PORT=8000]
      --host <HOST>
          Server host address [env: MODEL_EXPRESS_SERVER_HOST=]
  -l, --log-level <LOG_LEVEL>
          Log level [env: MODEL_EXPRESS_LOG_LEVEL=info] [possible values: trace, debug, info, warn, error]
      --log-format <LOG_FORMAT>
          Log format [env: MODEL_EXPRESS_LOG_FORMAT=] [possible values: json, pretty, compact]
  -d, --database-path <DATABASE_PATH>
          Database file path [env: MODEL_EXPRESS_DATABASE_PATH=/app/models.db]
      --cache-directory <CACHE_DIRECTORY>
          Cache directory path [env: MODEL_EXPRESS_CACHE_DIRECTORY=/app/cache]
      --cache-eviction-enabled <CACHE_EVICTION_ENABLED>
          Enable cache eviction [env: MODEL_EXPRESS_CACHE_EVICTION_ENABLED=] [possible values: true, false]
      --validate-config
          Validate configuration and exit
  -h, --help
          Print help
  -V, --version
          Print version

# ./model-express-cli --endpoint http://localhost:8000 -h
A CLI tool for interacting with ModelExpress server

Usage: model-express-cli [OPTIONS] <COMMAND>

Commands:
  health  Check server health and status
  model   Model management operations (download, list, clear, validate, etc.)
  api     Send general API requests
  help    Print this message or the help of the given subcommand(s)

Options:
  -e, --endpoint <ENDPOINT>  Server endpoint (can also be set via MODEL_EXPRESS_ENDPOINT env var) [env: MODEL_EXPRESS_ENDPOINT=] [default: http://localhost:8001]
  -t, --timeout <TIMEOUT>    Request timeout in seconds [default: 30]
  -f, --format <FORMAT>      Output format [default: human] [possible values: human, json, json-pretty]
  -v...                      Verbose mode (-v for info, -vv for debug, -vvv for trace)
  -q, --quiet                Quiet mode (suppress all output except errors)
      --cache-path <PATH>    Cache path override
  -h, --help                 Print help (see more with '--help')
  -V, --version              Print version


# ./model-express-cli --endpoint http://localhost:8000 help model
Model management operations (download, list, clear, validate, etc.)

Usage: model-express-cli model <COMMAND>

Commands:
  download   Download a model with various strategies (automatically cached)
  init       Initialize model storage configuration
  list       List downloaded models
  status     Show model storage status and usage
  clear      Clear specific model from storage
  clear-all  Clear all models from storage
  validate   Validate model integrity
  stats      Show model storage statistics
  help       Print this message or the help of the given subcommand(s)

Options:
  -h, --help  Print help
```