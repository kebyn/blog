---
title: vLLM Sleep Mode
date: 2025-11-10 15:45:14
tags:
- vLLM
- features
- sleep_mode
---
> https://docs.vllm.ai/en/latest/features/sleep_mode/

可以在不停止vLLM服务的情况下，通过接口睡眠、唤醒来切换不同的模型

<!-- more -->

### 需要手动指定--gpu-memory-utilization，否则多vLLM显存会冲突

```
docker run --rm -it \
  --name Qwen3-4B \
  --runtime=nvidia \
  --entrypoint='' \
  -e VLLM_NO_USAGE_STATS=1 \
  -e VLLM_USE_V1=1 \
  -e VLLM_SERVER_DEV_MODE=1 \
  --cap-add=sys_nice --ipc=host --network host \
  -v /data/cache:/data/cache \
  docker.io/vllm/vllm-openai:v0.11.0 \
  vllm serve Qwen/Qwen3-4B --disable-log-requests --no-enable-prefix-caching --port=8000 --tensor-parallel-size=1 --max-model-len=2048 --gpu-memory-utilization=0.5 --enable-sleep-mode
```