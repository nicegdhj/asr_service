#!/bin/bash
export ASR_API_KEYS="hejia:hejia123"
export MAX_CONCURRENCY=8
export FUNASR_SERVER="wss://127.0.0.1:10095"
export LOG_LEVEL="INFO"  # 添加日志级别环境变量
uvicorn gateway_app.main:app --host 0.0.0.0 --port 22800 --reload --log-level info