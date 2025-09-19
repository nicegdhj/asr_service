# 🎤 ASR Gateway

ASR Gateway 是一个 **HTTP → FunASR WebSocket** 的中间层，  
它将 FunASR 的 WebSocket 服务封装为标准 HTTP 接口，支持 **MP3 / WAV** 文件上传。

---

## ✨ 功能特性

- 🎯 **多用户多 Key 鉴权**（Header: `X-API-Key`）  
- 📊 **调用统计**：次数 + 平均时延  
- 🔁 **日志统一管理**：控制台 + 文件，支持轮转  
- 📖 **自定义 Swagger UI**：接口文档可视化  
- 🛡 **并发控制**：防止服务过载  

---

## 📂 工程目录
```text
asr_gateway/
├── app/
│   ├── init.py
│   ├── main.py          # 入口
│   ├── config.py        # 配置（环境变量、常量）
│   ├── logging_conf.py  # 日志配置
│   ├── auth.py          # 鉴权逻辑
│   ├── asr_client.py    # 调用 FunASR WebSocket 的客户端
│   ├── usage.py         # 调用统计（计数、时延、汇总）
│   └── routes/
│       ├── init.py
│       ├── health.py    # 健康检查、版本信息
│       ├── asr.py       # 语音识别接口
│       └── summary.py   # 调用统计接口
├── logs/                # 日志目录
├── requirements.txt     # Python 依赖
└── run.sh               # 启动脚本
```

## 🚀 本地运行

1. 安装依赖：
    ```bash
    pip install -r requirements.txt
    ```

2. 启动服务：
    ```bash
    export ASR_API_KEYS="username1:password1,username2:password2"
    export MAX_CONCURRENCY=8
    uvicorn app.main:app --host 0.0.0.0 --port 22800 --reload
    ```

3.	访问接口:
        ```bash
        curl -X POST "http://127.0.0.1:22800/asr" \
          -H "X-API-Key: alicekey123" \
          -F "file=@/path/to/test.mp3"
        ```

• wagger UI: http://127.0.0.1:22800/docs 

   
   