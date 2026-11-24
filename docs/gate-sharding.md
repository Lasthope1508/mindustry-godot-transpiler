# Full gate theo shard — bài học cho các slice lớn trên VM hay restart

> Đọc file này TRƯỚC khi chạy full gate cho bất kỳ slice nào trên VM này.
> Ghi lại 2026-11-24 sau khi gate nguyên khối của N2456 chết 3 lần liên tiếp.

## Vấn đề

Full gate (`python3 -m unittest discover -s tools/mindustry_godot_transpiler/tests`,
7013 test) chạy ~2 giờ. VM này **restart mỗi ~1,5–2 giờ** và mỗi lần restart giết
mọi process đang chạy, đồng thời xóa các cài đặt ngoài `~` (symlink godot ở
`/usr/local/bin`, package pip như javalang/pytest, đôi khi git config).

Bằng chứng với N2456 Team.get(int) — slice đã xong và xanh targeted + wiring từ
05:37, nhưng không commit được vì gate không chạy trọn nổi một lần:

| Attempt | Launch | Chết | Tiến độ lúc chết |
|---|---|---|---|
| 1 (PID 3917) | 05:38 | ~07:08, VM restart | ~35% |
| 2 (PID 1941) | 07:17 | ~08:54, VM restart | 90,3% (6333 pass, 1 F, 0 E) |
| 3 (PID 2297) | 09:01 | ~10:49, VM restart | ~95,6% (6697 pass, 1 F, 0 E) |

Kết quả: hơn 5 giờ không có commit nào cho một slice đã xong. **Đừng lặp lại.**

## Nguyên tắc cho slice lớn / việc dài

- Mọi công việc chạy dài hơn ~1 giờ trên VM này phải **chia nhỏ có checkpoint**:
  mỗi phần tự ghi kết quả ra file riêng, phần đã xong không bao giờ phải chạy lại.
- Không để một process dài duy nhất giữ commit làm con tin. Gate là điều kiện
  commit, nhưng gate phải được tổ chức để sống sót qua restart, không phải cầu
  may VM không restart.
- Sau mỗi VM restart: dựng lại môi trường TRƯỚC khi tin bất kỳ kết quả nào
  (godot đúng build `4.6.2.stable.official.71f334935`, javalang, pytest,
  git identity repo-local), rồi chạy lại targeted của slice để xác nhận slice
  còn nguyên vẹn.

## Giải pháp: gate theo shard

Chia suite theo module (thứ tự discover giữ nguyên) thành 5 shard, mỗi shard
là một process riêng với log riêng; một driver chạy chúng tuần tự và **bỏ qua
shard nào đã có log hoàn chỉnh** (có dòng `Ran N tests`). Restart chỉ giết shard
đang chạy dở — tối đa mất ~35 phút thay vì ~2 giờ.

Phân bổ hiện tại (census bằng TestLoader, 547 module):

| Shard | Số test | Ghi chú |
|---|---|---|
| A1 | 698 | Đầu suite: các proof Godot c05/c06/c07 — chậm nhất (~3 giây/test) |
| A2 | 512 | Tiếp phần proof c07 (gồm `test_c07_team_get`) |
| B | 1262 | Phần còn lại của c07 + các binding |
| C | 2360 | Gồm module khổng lồ `test_playable` (2330) — nhanh |
| D | 2185 | Gồm `test_source_parity` (912) + `test_source_symbols` (1104) — nhanh |

Tốc độ không đều theo số test: ~1650 test đầu mất ~80 phút (proof Godot),
phần còn lại ~5400 test chỉ ~30 phút. Vì vậy A1/A2 phải nhỏ; C/D lớn vẫn an toàn.

### Điều kiện đạt (không hạ chuẩn so với gate nguyên khối)

Cộng dồn cả 5 shard phải thỏa:

- Tổng failures **đúng 2 failure có sẵn** (baseline, đã đối chứng trên HEAD sạch):
  `test_reference_graph_and_actual_c05_gate` và
  `test_reference_graph_and_actual_unit_factory_consumer_binding`.
- Tổng errors **= 0**.
- Tổng `Ran N` khớp full suite. Lưu ý: census bằng TestLoader đếm 7017 trong
  khi discover báo `Ran 7013` — chênh 4 test; khi tổng kết shard phải đối
  chiếu con số này và giải thích được trước khi commit.

### Cách chạy

Hai script dưới đây sống tại thư mục làm việc của line
(`~/workspace/mindustry-godot-transpiler-work/gate_shards.py` và
`run_gate_shards.sh`, ngoài repo). Nếu mất, tạo lại từ mã nguồn trong file này.

```bash
cd ~/workspace/mindustry-godot-transpiler-work
python3 gate_shards.py gen            # sinh shards.json từ census
nohup ./run_gate_shards.sh n2456 &    # chạy 5 shard cho slice n2456
# log: logs/gate-shards-n2456/shard-<name>.log + status.txt
```

Gate vẫn **chỉ launch từ main thread** (GOAL.md §7) — shard không đổi quy tắc
này, chỉ đổi cách tổ chức process. Không bắt đầu slice kế tiếp khi gate chưa
xong (chung SSOT JSON).

### gate_shards.py

```python
#!/usr/bin/env python3
"""Sharded full-gate runner. See docs/gate-sharding.md in the repo."""
import json
import os
import sys
import unittest

REPO = os.path.expanduser("~/workspace/mindustry-godot-transpiler-work/repo")
TESTS_DIR = os.path.join(REPO, "tools", "mindustry_godot_transpiler", "tests")
HERE = os.path.dirname(os.path.abspath(__file__))
SHARDS_JSON = os.path.join(HERE, "shards.json")

BOUNDARIES = [
    ("A1", 700),
    ("A2", 1210),
    ("B", 2472),
    ("C", 4832),
    ("D", 10**9),
]


def census():
    loader = unittest.TestLoader()
    suite = loader.discover(TESTS_DIR)
    counts = {}

    def walk(s):
        for t in s:
            if isinstance(t, unittest.TestSuite):
                walk(t)
            else:
                counts[t.__class__.__module__] = counts.get(t.__class__.__module__, 0) + 1

    walk(suite)
    return counts


def gen():
    counts = census()
    shards = {}
    cur_name, cur_limit = BOUNDARIES[0]
    idx = 0
    cur = []
    cum = 0
    for mod, c in counts.items():
        if cum + c > cur_limit and cur:
            shards[cur_name] = cur
            idx += 1
            cur_name, cur_limit = BOUNDARIES[idx]
            cur = []
        cur.append(mod)
        cum += c
    if cur:
        shards[cur_name] = cur
    with open(SHARDS_JSON, "w") as f:
        json.dump({"counts": counts, "shards": shards}, f, indent=1)
    total = sum(counts.values())
    for name, mods in shards.items():
        n = sum(counts[m] for m in mods)
        print(f"shard {name}: {len(mods)} modules, {n} tests")
    print(f"total: {total} tests, {len(counts)} modules")


def run_shard(name):
    with open(SHARDS_JSON) as f:
        data = json.load(f)
    mods = data["shards"][name]
    os.chdir(REPO)
    if TESTS_DIR not in sys.path:
        sys.path.insert(0, TESTS_DIR)
    loader = unittest.TestLoader()
    suite = unittest.TestSuite()
    for m in mods:
        suite.addTests(loader.loadTestsFromName(m))
    runner = unittest.TextTestRunner(verbosity=1)
    result = runner.run(suite)
    sys.exit(0 if result.wasSuccessful() else 1)


if __name__ == "__main__":
    if len(sys.argv) >= 2 and sys.argv[1] == "gen":
        gen()
    elif len(sys.argv) >= 2:
        run_shard(sys.argv[1])
    else:
        sys.exit(2)
```

### run_gate_shards.sh

```bash
#!/bin/bash
# Run gate shards sequentially for slice $1 (e.g. n2456). Re-runnable:
# shards whose log already ends with a "Ran N tests" summary are skipped.
set -u
SLICE="${1:?usage: run_gate_shards.sh <slice-label>}"
BASE=~/workspace/mindustry-godot-transpiler-work
OUT="$BASE/logs/gate-shards-$SLICE"
mkdir -p "$OUT"
cd "$BASE"
for shard in A1 A2 B C D; do
  LOG="$OUT/shard-$shard.log"
  if [ -f "$LOG" ] && grep -q "^Ran [0-9]* tests" "$LOG"; then
    echo "$(date +%H:%M:%S) shard $shard: already complete, skipped" >> "$OUT/status.txt"
    continue
  fi
  echo "$(date +%H:%M:%S) shard $shard: starting" >> "$OUT/status.txt"
  python3 gate_shards.py "$shard" > "$LOG" 2>&1
  rc=$?
  echo "$(date +%H:%M:%S) shard $shard: exit $rc" >> "$OUT/status.txt"
done
echo "$(date +%H:%M:%S) ALL SHARDS DONE" >> "$OUT/status.txt"
```
