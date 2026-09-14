import argparse
import concurrent.futures
import statistics
import time
import urllib.request

parser = argparse.ArgumentParser()
parser.add_argument("--url", default="http://localhost:8000/api/v1/ready")
parser.add_argument("--requests", type=int, default=100)
parser.add_argument("--concurrency", type=int, default=10)
parser.add_argument("--max-p95-ms", type=float, default=500)
args = parser.parse_args()


def call() -> tuple[int, float]:
    started = time.perf_counter()
    try:
        with urllib.request.urlopen(args.url, timeout=5) as response:
            return response.status, (time.perf_counter() - started) * 1000
    except Exception:
        return 0, (time.perf_counter() - started) * 1000


with concurrent.futures.ThreadPoolExecutor(max_workers=args.concurrency) as pool:
    results = list(pool.map(lambda _: call(), range(args.requests)))
latencies = sorted(item[1] for item in results)
p95 = latencies[max(0, int(len(latencies) * 0.95) - 1)]
success = sum(item[0] == 200 for item in results) / len(results)
print({"success_rate": success, "p50_ms": statistics.median(latencies), "p95_ms": p95})
raise SystemExit(0 if success >= 0.99 and p95 <= args.max_p95_ms else 1)
