import datetime
from collections import defaultdict
from .logging_conf import logger

usage_counter = defaultdict(lambda: defaultdict(int))
latency_sum = defaultdict(lambda: defaultdict(float))


def log_usage(user: str, filename: str, elapsed: float, result: str):
    today = datetime.date.today().isoformat()
    usage_counter[user][today] += 1
    latency_sum[user][today] += elapsed
    logger.info(
        f"[usage] user={user}, file={filename}, elapsed={elapsed:.3f}s, "
        f"result_preview={result[:50]}..., total_today={usage_counter[user][today]}"
    )


def get_summary(user: str):
    today = datetime.date.today().isoformat()
    count = usage_counter[user][today]
    total_latency = latency_sum[user][today]
    avg_latency = round(total_latency / count, 3) if count > 0 else 0.0
    return {"user": user, "date": today, "count": count, "avg_latency": avg_latency}
