# 🎤 ASR Gateway - 工业级语音识别网关

ASR Gateway 是一个**微服务架构**的语音识别系统，将 FunASR 的 WebSocket 服务封装为标准 HTTP 接口，支持 **MP3/WAV** 文件上传，具备完整的开发、测试、打包、部署流程。

---

## 🏗️ 系统架构

```
┌─────────────────────────────────────────────────────────────┐
│                    ASR Gateway 微服务架构                     │
├─────────────────────────────────────────────────────────────┤
│  Nginx (负载均衡)     │  Gateway (业务逻辑)   │  FunASR (核心服务) │
│  - 反向代理          │  - HTTP API 接口      │  - 语音识别引擎     │
│  - 负载均衡          │  - 认证鉴权          │  - WebSocket 服务   │
│  - SSL 终止          │  - 调用统计          │  - 模型推理        │
│  - 健康检查          │  - 日志管理          │  - 多语言支持      │
└─────────────────────────────────────────────────────────────┘
```

---

## 📂 项目结构

```text
ASR/
├── 📦 deploy_package/           # 离线部署包
│   ├── deploy.sh               # 一键部署脚本
│   ├── docker-compose.yml      # 生产环境配置
│   ├── images/                 # Docker 镜像文件
│   │   ├── funasr.tar         # FunASR 服务镜像
│   │   ├── asr-gateway.tar    # Gateway 服务镜像
│   │   └── nginx.tar          # Nginx 镜像
│   └── models/                 # 模型文件包
│       └── models.tar.gz      # 压缩的模型文件
│
├── 🤖 funasr_resources/        # FunASR 资源目录
│   └── models/                 # 语音识别模型
│       ├── damo/               # 达摩院模型
│       │   ├── SenseVoiceSmall-onnx/          # 主识别模型
│       │   ├── speech_fsmn_vad_zh-cn-16k-common-onnx/  # VAD 模型
│       │   ├── speech_ngram_lm_zh-cn-ai-wesp-fst/      # 语言模型
│       │   └── speech_paraformer-large-vad-punc_asr_nat-zh-cn-16k-common-vocab8404-onnx/
│       └── thuduj12/           # 清华大学模型
│           └── fst_itn_zh/     # 逆文本标准化模型
│
├── 🌐 gateway_app/             # Gateway 应用代码
│   ├── main.py                 # FastAPI 应用入口
│   ├── config.py               # 配置管理
│   ├── logging_conf.py         # 日志配置
│   ├── auth.py                 # API 认证
│   ├── asr_client.py           # FunASR WebSocket 客户端
│   ├── usage.py                # 调用统计
│   ├── routes/                 # API 路由
│   │   └── asr_service.py     # ASR 服务接口
│   └── Dockerfile              # Gateway 容器镜像
│
├── 🏗️ infra/                   # 基础设施配置
│   ├── docker-compose.yml      # 开发环境编排
│   ├── nginx/                  # Nginx 配置
│   │   └── nginx.conf         # 负载均衡配置
│   └── logs/                   # 容器日志目录
│
├── 🔧 scripts/                 # 运维脚本
│   ├── check.sh               # 健康检查
│   ├── restart.sh             # 服务重启
│   └── stop.sh                # 服务停止
│
├── 📊 logs/                    # 应用日志
│   └── asr_gateway.log        # Gateway 运行日志
│
├── 🚀 run_gateway.sh           # 本地开发启动脚本
├── 📦 package.sh               # 一键打包脚本
└── 📋 requirements.txt         # Python 依赖
```

---

## 🎯 各组件作用

### 🐳 **deploy_package** - 离线部署包
- **目的**：支持网络隔离环境的离线部署
- **内容**：包含所有 Docker 镜像、模型文件、配置文件
- **使用场景**：生产环境、内网部署、无网络环境

### 🤖 **funasr_resources** - FunASR 资源
- **目的**：存储语音识别模型文件
- **内容**：ASR 模型、VAD 模型、语言模型、ITN 模型
- **挂载方式**：通过 Docker 卷挂载到 FunASR 容器

### 🌐 **gateway_app** - 网关应用
- **目的**：HTTP API 网关，业务逻辑层
- **功能**：
  - 文件上传接收
  - API 认证鉴权
  - 调用 FunASR WebSocket
  - 调用统计和日志
  - 错误处理和响应格式化

### 🏗️ **infra** - 基础设施
- **目的**：容器编排和基础设施配置
- **内容**：
  - Docker Compose 配置
  - Nginx 负载均衡配置
  - 容器日志管理

### 🔧 **scripts** - 运维脚本
- **目的**：自动化运维操作
- **功能**：健康检查、服务重启、状态监控

---

## 🚀 快速开始

### 1️⃣ 本地开发测试

```bash
# 启动 FunASR 服务
cd infra
docker-compose up -d funasr

# 启动 Gateway 开发服务（支持热重载）
./run_gateway.sh
```

### 2️⃣ 完整环境部署

```bash
# 启动完整服务栈
cd infra
docker-compose --profile dev up -d

# 健康检查
curl http://127.0.0.1:8080/healthz
```

### 3️⃣ 离线部署

```bash
# 1. 本地打包
./package.sh

# 2. 传输到目标机器
scp -r deploy_package/ user@target-server:/path/to/deploy/

# 3. 目标机器部署
cd /path/to/deploy/deploy_package
./deploy.sh
```

---

## 🧪 测试用例

### 📋 API 接口测试

#### 1. 健康检查
```bash
curl http://127.0.0.1:8080/healthz
# 期望返回: {"status": "ok"}
```

#### 2. 语音识别测试
```bash
curl -X POST "http://127.0.0.1:8080/asr" \
  -H "X-API-Key: hejia123" \
  -F "file=@/path/to/test.wav"

# 期望返回:
# {
#   "code": 0,
#   "message": "success",
#   "data": {
#     "user": "hejia",
#     "filename": "test.wav",
#     "elapsed": 2.039,
#     "result": "识别结果文本"
#   }
# }
```

#### 3. 调用统计
```bash
curl -H "X-API-Key: hejia123" http://127.0.0.1:8080/summary

# 期望返回:
# {
#   "user": "hejia",
#   "date": "2024-01-01",
#   "count": 5,
#   "avg_latency": 1.8
# }
```

### 🔍 性能测试

```bash
# 运行性能测试（需要先安装 bc 工具）
./scripts/benchmark.sh 5 20  # 5个并发，总共20个请求
```

### 🏥 健康检查

```bash
# 检查系统状态
./scripts/check.sh

# 持续监控
./scripts/monitor.sh 30  # 每30秒检查一次
```

---

## ⚙️ 配置说明

### 🔑 API 认证配置

```bash
# 设置 API Keys（支持多用户）
export ASR_API_KEYS="user1:key1,user2:key2,admin:admin123"

# 请求时使用
curl -H "X-API-Key: key1" ...
```

### 🎛️ 服务配置

```bash
# FunASR 服务器地址
export FUNASR_SERVER="wss://127.0.0.1:10095"

# 最大并发数
export MAX_CONCURRENCY=8

# 日志级别
export LOG_LEVEL="INFO"
```

### 🐳 Docker 配置

```yaml
# infra/docker-compose.yml
services:
  funasr:
    image: registry.cn-hangzhou.aliyuncs.com/funasr_repo/funasr:funasr-runtime-sdk-cpu-0.4.7
    ports:
      - "10095:10095"
    volumes:
      - ../funasr_resources/models:/workspace/models

  asr_gateway_dev:
    profiles: ["dev"]
    ports:
      - "22800:22800"
    environment:
      - FUNASR_SERVER=wss://funasr:10095

  nginx_dev:
    profiles: ["dev"]
    ports:
      - "8080:80"
```

---

## 📊 监控和运维

### 📈 日志查看

```bash
# Gateway 日志
tail -f logs/asr_gateway.log

# 容器日志
docker logs -f asr_gateway_dev
docker logs -f funasr

# Nginx 日志
tail -f infra/logs/access.log
```

### 🔄 服务管理

```bash
# 重启服务
./scripts/restart.sh

# 停止服务
./scripts/stop.sh

# 检查状态
./scripts/check.sh
```

### 📦 打包部署

```bash
# 本地打包
./package.sh

# 查看打包结果
ls -lh deploy_package/
```

---

## 🌟 特性亮点

### ✨ **开发友好**
- 🔥 **热重载**：本地开发支持代码实时更新
- 🐛 **调试模式**：详细的错误日志和堆栈信息
- 📖 **API 文档**：自动生成的 Swagger UI

### 🏭 **生产就绪**
- 🐳 **容器化**：完整的 Docker 部署方案
- 📦 **离线部署**：支持网络隔离环境
- 🔄 **高可用**：Nginx 负载均衡，多实例部署
- 📊 **监控完善**：健康检查、性能监控、日志聚合

### 🔒 **安全可靠**
- 🔐 **API 认证**：多用户 Key 认证机制
- 🛡️ **并发控制**：防止服务过载
- 📝 **审计日志**：完整的调用记录和统计

### ⚡ **高性能**
- 🚀 **异步处理**：FastAPI 异步框架
- 🔄 **连接池**：WebSocket 连接复用
- 📊 **性能监控**：响应时间统计和优化

---

## 🤝 贡献指南

1. **开发环境设置**：使用 `run_gateway.sh` 启动开发环境
2. **代码规范**：遵循 Python PEP 8 规范
3. **测试覆盖**：确保新功能有对应的测试用例
4. **文档更新**：及时更新 README 和 API 文档

---

## 📄 许可证

本项目采用 MIT 许可证，详见 LICENSE 文件。

---

## 📞 支持

如有问题或建议，请通过以下方式联系：

- 🐛 **问题反馈**：GitHub Issues
- 📧 **邮件联系**：your-email@example.com
- 💬 **技术交流**：加入我们的技术交流群

---

**🎉 感谢使用 ASR Gateway！让语音识别变得简单高效。**