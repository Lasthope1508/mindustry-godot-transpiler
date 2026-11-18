# C07 — Reconciliation vòng 3: bỏ N2247 (Isabella A) + renumber N2252–N2260 + replay lên origin/main 7dfdec3

Ngày: 2026-11-18 ~04:15–08:30 +07. Người duyệt: Isabella (chọn phương án A "Bỏ N2247" lúc 06:57 +07, qua options widget).
Main thread thực hiện toàn bộ (AGENTS.md: không spawn agent cho slice chạm SSOT JSON chung).

Vòng 1 (17:00–18:45 +07, 2026-11-17) đã hòa giải divergence đầu tiên (origin/main 4ea979e, renumber N2229→N2247, N2230→N2248, N2231→N2249, bỏ N2246 trùng remote N2230, replay 15/15, gate xanh Ran 6077/failures 196). Vòng 2 (19:04–20:27 +07, 2026-11-17) hòa giải divergence thứ hai (origin/main ca3e9a3, renumber N2232→N2250, N2233→N2251, chia family giữa hai line, replay 15/15, gate xanh Ran 6085/failures 198) — xem report vòng 2 `docs/superpowers/reports/2026-11-17-c07-reconciliation-renumber-rebase.md`. Vòng 3 là divergence thứ ba trở đi, gom 9 lần remote push trong ~10 giờ.

## 1. Vì sao phải hòa giải lần 3

- Divergences #3–#11 (2026-11-17 ~20:14 đến 2026-11-18 ~06:15 +07): origin/main ca3e9a3 → ce10a30 → 91c5cb4 → 14d923f → aef7661 → 09a7380 → bccc5cf → bcfff70 → 723735c → **7dfdec3** — 9 lần, mỗi lần +5 commit, merge-base vẫn ca3e9a3. Remote thêm 9 slice (nhịp ~1 slice/giờ, line Windows/agent khác): N2234 RepairTurret senseObject legs, N2235 per-def ambientSoundVolume, N2236 bind block_id, N2237 per-def stat rows, N2238 RepairTower per-def stat rows, N2239 PointDefenseTurret target acquire, N2240 aim+reload+shoot, N2241 shouldConsume+coolant, N2242 live bullets wiring. Remote ledger 1692 slices, max N 2242.
- Đụng số (8 số): local N2234→N2252, N2235→N2253, N2236→N2254, N2237→N2255, N2238→N2256, N2239→N2257, N2240→N2258, N2241→N2259.
- **Đụng TÊN HÀM (không chỉ đụng số):** remote N2234 định nghĩa `source_repair_turret_sense_object_state(sensor, block_id)` (toàn bộ switch senseObject: type/firstItem/config/payloadType/default, trả `{"handled", "sense_object", "is_no_sensed"}`), TRÙNG TÊN với local N2247 `source_repair_turret_sense_object_state(frame, sensor, config_senseable, config_value)` (chỉ nhánh config, trả `{"handled", "sense_object_value", "sense_object_is_no_sensed"}`). Remote BAO TRÙM nhánh config của local (config → null cho repair turret). Hai hàm cùng tên không thể cùng sống trong một file GD.
- PointDefenseTurret là family MỚI, chưa có trong luật chia (VM: Turret/BurstDrill/Radar/Game; Windows: RepairTower/RepairTurret) — line Windows đã làm 4 slice liên tiếp N2239–N2242 (tính cả #13 sau gate thì 5 slice N2239–N2243). Quyết line nào giữ family này vẫn chờ Isabella — không chặn vòng 3.

## 2. Quyết định (Isabella duyệt 06:57 +07, phương án A — Bỏ N2247)

- **A — Bỏ N2247:** remote bao trùm nhánh config; tiền lệ vòng 1 bỏ N2246; gọn, không đổi tên gì; mất hàm config riêng + 2 return key `sense_object_value`/`sense_object_is_no_sensed` (chỉ hàm đó dùng, không driver nên không ảnh hưởng slice khác).
- **B (không chọn) — Giữ N2247, đổi tên hàm** thành `source_repair_turret_sense_object_config_state` (khớp hậu tố `_config` của register/test/proof); giữ công việc config-branch nhưng hai hàm chồng logic, replay nặng hơn.
- Renumber: 8 slice + ambient A N2241→**N2259** + ambient B N2242→**N2260** (B thuộc line Windows, chưa làm). Số N trống tiếp theo sau vòng 3: **N2261**. Backup branch của line vòng 2 (15 slice + split-rule, HEAD eb571dd): **`backup-reconciliation-round2-eb571dd`**.

## 3. Phương pháp replay vòng 3 (không rebase / cherry-pick)

Như vòng 1/vòng 2: copy + register + verify + commit, MỘT slice một lần, theo thứ tự replay N2248→N2245. Khác vòng 2 ở 5 điểm:

1. **Chuỗi DEFERRED import:** năm register từng import từ register của N2247 đã bị bỏ (`register_c07_repair_turret_sense_object_config`): N2248, N2249, N2250, N2251, N2256 — re-point import → `from register_c07_repair_turret_icons import DEFERRED as N2227_DEFERRED` (N2227 là register mà N2247 từng import từ; module có sẵn trong base), đổi alias ở cả import lẫn biểu thức DEFERRED, cập nhật comment block (ghi rõ chain bỏ qua N2247). An toàn vì mọi test liên quan chỉ assert `ledger[N]['deferred_exprs']` non-empty, không assert nội dung chính xác. Hệ quả: mỗi slice có sửa import tăng +3 ins so với commit vòng 2 (comment dài hơn) — khớp chính xác ở N2248/N2249/N2250; N2251 +2, N2256 +1 (comment ngắn hơn).
2. **Alias DEFERRED không bị word-boundary replace bắt** (ký tự `_` là word char): phải replace tường minh `N2236_DEFERRED`→`N2254_DEFERRED` (N2255), `N2238_DEFERRED`→`N2256_DEFERRED` (N2257, N2258), `N2240_DEFERRED`→`N2258_DEFERRED` (N2245).
3. **Tham chiếu N2247 lơ lửng** (precedent refs trong Turret/BurstDrill files): re-point sang tiền lệ còn sống — "N2188 / N2247 explicit-param precedent" → "N2188 explicit-param precedent", "same as N2148/N2247:" → "same as N2148/N2227:", "the N2247 per-def-param precedent" → "the N2188 per-def-param precedent", "same as N2173/N2247:" → "same as N2173/N2227:". Cẩn thận comment quấn dòng (phrase bị ngắt giữa hai dòng thì replace theo mảnh ngắn hơn).
4. **N2252 đặc biệt:** comment trong hàm jitter ghi "waits for N2234" — ở vòng 3 N2234 là remote senseObject nên SAI hẳn, đã sửa thành "waits for N2252" ngay trong commit N2252 (GD diff = +8 dòng pulse + 1 dòng sửa). Ghép tay GD: jitter 57 dòng + pulse 8 dòng (byte-identical), hàm remote range/buildRotation còn nguyên.
5. **Ambient C renumber:** số cũ N2243 đã bị remote lấy (divergence #13, N2243 PointDefenseTurret spawn team stamp) → ứng viên **N2264** (quyết chính thức khi B xong). Spec row N2259 ghi rõ "(B, N2260), no SoundControl mixer (C, N2264 — renumbered after remote took N2243, divergence #13)".

Bài học merge đã áp dụng: KHÔNG BAO GIỜ chạy hai slice register trong main trước khi commit slice đầu tiên (register là cumulative — sự cố f77d955 ngày 16:52). Số insertion trong commit message lấy từ `git diff --cached --stat`, không lấy số của worker.

## 4. Kết quả replay vòng 3 — 14/14 slice

| Slice | Commit vòng 3 (vòng 2) | --verify | Targeted 4/4 | Family | SSOT sau slice |
| --- | --- | --- | --- | --- | --- |
| N2248 Radar updateTile | b040e56 (af3c4f1) | 36/36 | 85 subtests, proof 10 keys | Radar 8/114 | 11563/1693/1624/3039 |
| N2249 Radar fogRadius() | 32bb63e (95055de) | 13/13 | 36 subtests, proof 9 keys | Radar 12/150 | 11564/1694/1625/3041 |
| N2250 Radar icons() | 710662c (796f6eb) | 12/12 | 24 subtests, proof 5 keys | Radar 16/174 | 11565/1695/1626/3043 |
| N2251 RepairTurret drawBeam jitter | e648a53 (d33d882) | 37/37 | 67 subtests, proof 11 keys | RepairTurret 92/1069 | 11571/1696/1627/3045 |
| N2252 RepairTurret drawBeam pulse | 153e9f0 (1e1adfa) | 21/21 | 46 subtests, proof 11 keys | RepairTurret 96/1115 | 11575/1697/1628/3047 |
| N2253 Turret shouldConsume | fcef043 (a7b4bb2) | 16/16 | 34 subtests, proof 8 keys | Turret 8/59 | 11576/1698/1629/3049 |
| N2254 Turret progress | f33217f (f4d4094) | 12/12 | 28 subtests, proof 8 keys | Turret 12/87 | 11577/1699/1630/3051 |
| N2255 Turret sense | c698723 (4e916fb) | 42/42 | 82 subtests, proof 12 keys | Turret 16/169 | 11580/1700/1631/3053 |
| N2256 BurstDrill updateTile | 5f17ac9 (53cbc1e) | 74/74 | 161 subtests, proof 11 keys | BurstDrill 8/186 | 11591/1701/1632/3055 |
| N2257 BurstDrill shouldConsume | 62502b8 (ade16de) | 24/24 | 60 subtests, proof 9 keys | BurstDrill 12/246 | 11592/1702/1633/3057 |
| N2258 BurstDrill liquid rows | ae71e71 (8ed7607) | 58/58 | 141 subtests, proof 12 keys | BurstDrill 16/387 | 11601/1703/1634/3059 |
| N2259 Game headless source (ambient A) | f84c402 (124939c) | 7/7 | 30 subtests, proof 6 keys | — (game) | 11602/1704/1635/3061 |
| N2244 Turret fogRadius | a5f722e (aa23262) | 21/21 | 44 subtests, proof 10 keys | Turret 20/213 | 11603/1705/1636/3063 |
| N2245 BurstDrill icons | caaba18 (bc4455f) | 13/13 | 28 subtests, proof 6 keys | BurstDrill 20/415 | 11604/1706/1637/3065 |

- Wiring-standard sau MỖI slice: 32 passed / 235 subtests (9 module).
- HEAD sau replay: **caaba18**. SSOT cuối: **11604 symbols / 1706 slices / 1637 contracts / 3065 schemas** (= base remote 7dfdec3 11557/1692/1623/3037 + 14 delta local; 1692 + 14 = 1706). SSOT từng slice đã kiểm chứng trực tiếp từ git (symbols/slices/contracts/schemas tại mỗi commit).
- Kiểm chứng cuối: remote N2234–N2242 nguyên vẹn trong ledger (`source_repair_turret_sense_object_state` là của remote, không phải local); N2247 VẮNG MẶT trong ledger (đã bỏ); N2250/N2251 đúng hàm đã renumber; DEFERRED chain của 5 register đã re-point sang N2227.
- N2247 không có hàng spec (đã bỏ); N2243/N2246 cũng không có hàng (không tồn tại trong line này).

## 5. Full gate (reconciliation vòng 3)

Gate vòng 3 GREEN (main thread, PID 7992, ~08:09–08:27, log `full-suite-reconciled-round3-gate.log`): **Ran 6117 in 1059.117s, failures=206, skipped=5, 0 errors** — đếm trực tiếp: 206 FAIL blocks, 0 ERROR blocks, cả 206 đều "AssertionError: unexpectedly None" (Godot-absent). Đúng như dự tính (vòng 2: Ran 6085, failures 198; 9 slice remote N2234–N2242 thêm 32 test, trong đó 8 failure Godot-absent, 24 test còn lại pass không cần Godot).

## 6. Docs đi kèm

- Spec: 14 dòng mới trong `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md` sau dòng N2242 (remote), theo thứ tự replay (N2248…N2245); Done 1692 → **1706**. N2247 không có hàng (đã bỏ).
- GOAL §5: 14 dòng nợ Windows proof mới sau block N2242 remote.
- Handoff: `docs/superpowers/handoffs/2026-11-18-c07-reconciliation-round3-renumber-rebase-handoff.md`.

## 7. Sự cố trong lúc replay vòng 3

- **VM RESTART #13 ~07:26 +07 và #14 ~09:12–09:14 +07**: tmpfs wipe — chỉ mất symlink Godot (javalang 0.13.0 + pytest 9.2.0 còn nguyên); main thread tạo lại symlink, Godot 4.6.2 OK. Repo nguyên vẹn. **Cron 09:15 báo đã tạo lại symlink + kiểm chứng Godot OK nhưng main thread kiểm chứng lúc 09:19 thấy symlink VẪN MẤT — tự tạo lại + verify OK; bài học: không tin claim sửa môi trường của cron, luôn tự kiểm chứng trước khi báo user.**
- **Các báo cáo cron 07:15/07:30/07:45/08:00 đến trễ** (kẹt `recovery.deliveries`) và đã bị trạng thái thật vượt qua — main thread suppress, báo cáo tay 07:17 + 08:09 là nguồn user đã nhận.
- **Divergence #12 (08:09 +07)**: origin/main 7dfdec3 → 1ddbb1b, chỉ 2 commit docs (Windows Godot evidence N2422/N2423/N2425) — không va chạm, không cần renumber, không chặn replay.
- **Divergence #13 (10:15 +07, SAU khi gate xong)**: origin/main 1ddbb1b → 1b08e5f, 6 commit (1 slice N2243 PointDefenseTurret spawn team stamp + 5 docs). N2243 vốn giữ cho ambient C → renumber → **N2264** (quyết chính thức khi B xong). Không chặn docs vòng 3 (docs chỉ ghi slice local; Done local 1692→1706; remote N2243 hòa giải ở vòng sau nếu cần).
- **Divergence #14 (10:45 +07, cron báo, main thread VERIFIED)**: origin/main 1b08e5f → **87588c6**, 2 commit docs (Windows Godot evidence N2426/N2427/N2428: fbf1541 + merge 87588c6) — không đụng code/spec/SSOT, remote ledger vẫn 1693 slice, max N 2243 — **không va chạm** với batch N2261–N2263. Local 14 ahead / 10 behind origin/main 87588c6.
- **MEMORY.md bị background job trim** nhiều lần — các mục vòng 3/#12/#13/restart do main thread thêm vẫn còn; chi tiết vòng 1/vòng 2 đã trim khỏi MEMORY.md nhưng còn trong checkpoint tóm tắt của main thread.

## 8. Push từ máy Windows (Isabella)

- Line hiện tại: 14 commit slice trên nền origin/main 7dfdec3 + 1 commit docs — KHÔNG fast-forward so với origin/main hiện tại (87588c6, đã có thêm #12/#13/#14: 2 docs + 6 commit + 2 docs). Khi push từ Windows sẽ cần merge với 10 commit remote mới (trong đó slice N2243 + docs) — **không đụng code slice local, nhưng sẽ cần hòa giải tay ở spec**: dòng Done (1692→1693 remote vs 1692→1706 local) + hàng N2243 remote vs 14 hàng vòng 3 local (cùng chèn sau hàng N2242). Đó là việc của vòng hòa giải sau, không chặn push lần này nếu merge cẩn thận.
- Từ máy Windows: `git fetch origin` → kiểm tra `git status` (tree clean) → merge với origin/main (KHÔNG force-push) → `git push origin main`.
- Sau khi push: cron `mindustry-15m-report` được phép spawn lại; batch tiếp theo đã spawn **N2261 Turret estimateDps + N2262 BurstDrill ore/dominant + N2263 Radar progress()** (3 worktree riêng từ caaba18, spawn 10:33–10:36 +07, đang chạy khi viết docs này — merge theo thứ tự N + gate sau khi 3 worker báo xong). Số N trống tiếp theo sau batch: **N2264** (giữ cho ambient C, chờ B = N2260 của line Windows).
- Hàng chờ (chỉ family của VM này): Turret updateTile warmup advance → findTarget (cuối); BurstDrill ore/dominant binding (đang làm N2262); Radar write/read persistence. Ambient C = N2264 (CHỜ ambient B = N2260 của line Windows xong). RepairTower/RepairTurret thuộc line Windows — VM này không làm nữa.
- Worktree cũ (n2230–n2246) đã merge hết — dọn khi rảnh, không chặn push.
- Quyết line nào giữ PointDefenseTurret vẫn chờ Isabella (Windows đã làm 5 slice liên tiếp N2239–N2243).
