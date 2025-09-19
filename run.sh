#!/bin/bash
export ASR_API_KEYS="hejia:hejia123"
export MAX_CONCURRENCY=8

uvicorn app.main:app --host 0.0.0.0 --port 22800 --reload