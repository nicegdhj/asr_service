#!/bin/bash
set -e

# 性能测试脚本
echo "⚡ ASR 系统性能测试"

# 配置
API_URL="http://127.0.0.1:8080/asr"
API_KEY="hejia123"
TEST_FILE="/Users/jia/Desktop/test.wav"
CONCURRENT_REQUESTS=${1:-5}
TOTAL_REQUESTS=${2:-20}

# 检查测试文件
if [ ! -f "$TEST_FILE" ]; then
    echo "❌ 测试文件不存在: $TEST_FILE"
    exit 1
fi

echo "📊 测试配置:"
echo "  - 并发数: $CONCURRENT_REQUESTS"
echo "  - 总请求数: $TOTAL_REQUESTS"
echo "  - 测试文件: $TEST_FILE"
echo ""

# 创建临时目录存储结果
RESULT_DIR="./benchmark_results_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$RESULT_DIR"

# 使用 curl 进行并发测试
echo "🚀 开始性能测试..."
for i in $(seq 1 $TOTAL_REQUESTS); do
    (
        start_time=$(date +%s.%N)
        response=$(curl -s -w "%{http_code},%{time_total}" \
            -X POST "$API_URL" \
            -H "X-API-Key:$API_KEY" \
            -F "file=@$TEST_FILE")
        end_time=$(date +%s.%N)
        
        http_code=$(echo "$response" | cut -d',' -f1)
        curl_time=$(echo "$response" | cut -d',' -f2)
        duration=$(echo "$end_time - $start_time" | bc)
        
        echo "$i,$http_code,$curl_time,$duration" >> "$RESULT_DIR/requests.csv"
        
        if [ "$http_code" = "200" ]; then
            echo "✅ 请求 $i: 成功 (${curl_time}s)"
        else
            echo "❌ 请求 $i: 失败 (HTTP $http_code)"
        fi
    ) &
    
    # 控制并发数
    if (( i % CONCURRENT_REQUESTS == 0 )); then
        wait
    fi
done

wait

# 分析结果
echo ""
echo "📈 测试结果分析:"
if [ -f "$RESULT_DIR/requests.csv" ]; then
    total=$(wc -l < "$RESULT_DIR/requests.csv")
    success=$(grep ",200," "$RESULT_DIR/requests.csv" | wc -l)
    failed=$((total - success))
    
    echo "  - 总请求数: $total"
    echo "  - 成功数: $success"
    echo "  - 失败数: $failed"
    echo "  - 成功率: $(echo "scale=2; $success * 100 / $total" | bc)%"
    
    # 计算平均响应时间
    avg_time=$(awk -F',' 'NR>0 && $2==200 {sum+=$3; count++} END {if(count>0) print sum/count; else print 0}' "$RESULT_DIR/requests.csv")
    echo "  - 平均响应时间: ${avg_time}s"
    
    # 保存详细报告
    echo "📄 详细报告已保存到: $RESULT_DIR/"
    echo "请求ID,HTTP状态码,响应时间,总耗时" > "$RESULT_DIR/report.csv"
    cat "$RESULT_DIR/requests.csv" >> "$RESULT_DIR/report.csv"
fi

echo "✅ 性能测试完成"
