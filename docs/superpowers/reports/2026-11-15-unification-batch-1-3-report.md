# Unification batch 1–3 vào wave line — báo cáo (2026-11-15, coordinator lượt 5)

## Vấn đề

Wave line (từ N2197 → wave-2 → N2199 → waves items/liquids/payload/targets/
plans/turrets/advances-1..4) KHÔNG chứa batch 1–3: ledger ở `706e1cd9`
thiếu 9 slice (N2186, N2187, N2189–N2195), test file của chúng không tồn
tại trong cây, và docs commit batch `36c60f1d`/`4659d9a6`/`e7ecf7a5` +
N2197 docs `ab84d2cf` không phải ancestor của wave line. Nguyên nhân:
3 branch tích hợp batch là 3 line song song, mỗi line base thẳng trên
`de9ab89c`, chưa bao giờ được nối vào wave line (wave-2 cherry-pick
N2197 + N2188/N2198 trực tiếp). Phát hiện 18:21 15/11 bởi worker-N2241,
coordinator lượt 4 verify bằng merge-base + ls-tree + ledger; phương án
soạn 18:30 trong `STATUS.md` mục Line divergence. Unification này thực
hiện đúng phương án đó, coordinator-serial (chạm SSOT dùng chung +
checklist — không giao worker).

## Cách làm (branch `integration/unification-batch-1-3`, base `8a2c302e`)

Không `git merge` branch batch (kéo theo SSOT/spec/GOAL đã phân kỳ +
docs thời N2185), không rebase wave line, không đụng remote main
`63a277b6`, không đổi số N2186/N2187 (thuộc phase merge-to-main, cần
user chốt số mới). N2197 KHÔNG cần gộp (nội dung đã có trong wave line).

### B1 — cherry-pick 14 commit (8 nhóm slice+fix, hash bản integration-branch)

| Slice | Batch hash | Hash mới | Ghi chú |
|---|---|---|---|
| N2186 LaunchPad gate | `879fa13e` + fix `65a9f597` | `5726e0ee` + `68fa6aee` | driver conflict 6 hunk, merge tay (xem dưới); fix chỉ lấy 2 file proof+test — hunk driver bỏ vì dòng inline counter không còn tồn tại |
| N2187 ShockwaveTower gate | `b69ba59d` + fix `ffcf9ccb` | `20a08fbf` + `98defc46` | sạch |
| N2190 Radar | `6baeb7bc` | `bea4d312` | sạch |
| N2191 Accelerator | `fafe334f` + fix `ed17c642` | `01e599d9` + `a50addc1` | sạch |
| N2192 ImpactReactor | `52e3b178` + fix `a646945c` | `c1d8e762` + `e52e798e` | sạch |
| N2193 MendProjector | `d8dce467` | `5478286e` | sạch |
| N2194 OverdriveProjector | `2723e795` + fix `447c0bc3` | `ed52a099` + `f3595cba` | sạch |
| N2196 Conduit fix | `bca6dfe5` + fix `80dbf05e` | `a836ba0b` + `d6dd3066` | sạch; fix slice, không ledger entry |

Pre-flight verify: wave line chỉ chạm 3/10 driver file batch từ
`de9ab89c` (LaunchPad N2238, BeamDrill N2202, LightBlock N2241); 7
driver còn lại untouched; test/proof/register batch vắng mặt ở
`8a2c302e` (chỉ 2 match = file của N2238/N2241).

### B2 — merge tay 3 ca

**N2186 vs N2238 (LaunchPad driver, `5726e0ee`, 6 hunk).** HEAD chưa có
`source_launch_pad_should_consume_state` (grep rỗng); tick HEAD dùng
`var should_consume: bool = bool(frame.get("enabled", true))` (gate
deferred). Quyết định: (1) tick-frame comment + key `items`: lấy HEAD
(đã có `items`, comment đầy hơn). (2) power-status comment: gộp — đoạn
đầu N2186 (gate LIVE) + giới hạn (1),(2) N2186 + giới hạn (3) HEAD
(advance live N2238) + (4),(5) N2186. (3) Pure function: giữ CẢ HAI —
`source_launch_pad_update_tile_advance_state` (HEAD) trước, rồi
`source_launch_pad_should_consume_state` (N2186). (4) launchTime stamp
comment: lấy N2186 (bỏ câu stale "(The N2186 stamp, mirrored here
because N2186 is not in this base.)"). (5) hasConsumers comment: gộp —
HEAD "(the updateTile advance is live since N2238…)" + N2186 "N2186
wires the gate through the pure … function, ANDed with enabled".
(6) Counter advance: lấy HEAD (advance N2238 thay dòng inline N2186).
`git diff --check` sạch; key `items` xuất hiện đúng 1 lần. **Test N2186
bắt buộc sửa** (`ff725ce0`): assert dòng inline đã bỏ được thay bằng 3
assert trên driver đã gộp (gọi advance function, `launch_counter +=
edelta`, `game_source_delta`); proof expectation
counter_advances_by_edelta = 1.0/tick vẫn đúng (edelta = efficiency 1.0
× source_delta 1.0 × time_scale 1.0).

**N2195 vs N2202 (BeamDrill driver, `d7512292` + fix `3fdfc145`).**
Chỉ 1 hunk conflict — comment "Documented limits" (gộp: giới hạn (2)
gate-live N2202 + giới hạn (3) partial-advance N2195). Conflict
`_initial_frame` DỰ ĐOÁN KHÔNG XẢY RA: bản N2195 trả `{}` (rỗng), bản
N2202 trả `{"items": {}, "facing_amount": 0}` — giữ bản N2202 (union;
advance đọc warmup/boost_warmup/time qua `frame.get(..., 0.0)`, tick
ghi lại). Test gate N2202 vẫn pass (neighbours B4).

**N2189 vs N2241 (LightBlock, `00e6588b`, merge tay toàn bộ — KHÔNG
cherry-pick `8803e1e7` vì cả 5 file đều conflict theo thiết kế).**
N2189 là SUPERSET (smooth_time + light_radius_scale); N2241 chỉ
smooth_time + hiệu chỉnh cite. Driver: return rộng của N2189
`{"smooth_time": advanced, "light_radius_scale": minf(advanced, 2.0)}`
+ cite N2241 (smoothTime init 1f :69, updateTile :104-106 — cite
:104-107 của N2189 đã stale, sửa cả 2 chỗ trong driver — drawLight
:127-128). Proof gộp **8 key**, không mất coverage, không dư thừa:
`lerp_delta_step` (N2189) hấp thụ `lerps_toward_time_scale` (N2241,
cùng 1 step + thêm check radius); `live_tick_writes_advance_frame_keys`
(N2241) hấp thụ `tick_advances_live` (N2189, cùng 1 tick + thêm check
efficiency); giữ `power_status_row_unchanged` (N2189) và
`frame_defaults_to_java_initial` (N2241) mà shorthand "5+5−2" của
phương án đã bỏ sót. Register: từ N2189 (snapshot DEFERRED 242 entry,
trung thực với ledger entry thời batch) + cite N2241 + ghi chú
unification; KHÔNG động vào entry N2241 (đã có trong SSOT từ wave-4).
Test gộp assert CẢ HAI ledger entry (N2189: 2 symbol, N2241: 1 symbol),
cùng owner/proof/tests, deferred non-empty; driver assert `minf(` +
`frame.get("smooth_time", 1.0)`; Godot proof test assert 8 key.
TSCN giống hệt nhau (không sửa).

### B3 — SSOT gộp (`ed2e9251`): 11642/1691/1613/3017

Chạy lại 9 register (N2196 không có register). Đối chiếu với wave-4
(11616/1682/1605/3001), verify bằng JSON diff (không chỉ đọc tổng):

- symbols 11642 (+26 = batch +27, −1 overlap: LightBlock smooth_time
  đã có từ N2241; light_radius_scale mới). Diff: 26 added, 0 removed,
  0 changed.
- ledger 1691 (+9, không overlap — N2241 là số slice khác). Cả 9 slice
  có mặt; N2196 đúng là không có entry.
- contracts 1613 (+8 = batch +9, −1 overlap: contract owner LightBlock
  upsert thành union return_keys [smooth_time, light_radius_scale],
  source_slice N2241 → N2189). Diff: 8 added, 0 removed, 1 changed.
- schemas **3017** (+16 = batch +18, **−2 overlap**: CẢ HAI schema
  LightBlock — input VÀ result — đã có từ N2241. Phương án dự báo 3018
  (overlap −1); overlap đúng là −2 vì schema là 2 entry/owner). Diff:
  16 added, 0 removed, 2 changed (LightBlock input + result).

Không cherry-pick commit SSOT batch (`ca44caa0`/`68fc759c`/`76a87003`
— chạm 4 file SSOT wave line cũng đổi). DEFERRED gộp bằng diff 3 chiều
AST (base = master list ở `de9ab89c`, 242 entry): 270 − 12 resolved +
25 new = **283 entries** (`DEFERRED-after-unification.py`, bookkeeping
ngoài repo; 0 duplicate; 5 entry mới của N2193 đã có sẵn trên wave line
nên không cộng thêm; 4 entry batch resolve đã vắng khỏi wave line).

### B4 — targeted + neighbours (trước full gate)

- Targeted 10 module Ran 40, failures=10, 0 errors: 8 module mới 24
  PASS + 8 proof, module LightBlock gộp 3 PASS + 1 proof, conduit
  N2196 3 PASS + 1 proof. 10/10 failure là
  `AssertionError: unexpectedly None` (Godot-absent).
- Neighbours 11 module power/gate của 9 họ Ran 44, failures=11
  (11/11 Godot-absent), 0 errors, 33 PASS — gồm updateTile N2238 và
  gate N2202 (2 họ merge tay).

### B5 — full gate

full gate (PID 21602, launch ~19:10, done 19:29 +07) Ran 6054 in 1114.842s, failures=190, skipped=5, 0 errors — 190/190 Godot-absent (182 inherited + 8 new proof tests N2186/N2187/N2190/N2191/N2192/N2193/N2194/N2195)

### B6 — docs + push

Mang 9 report + 9 handoff batch nguyên văn bằng
`git checkout <tip> -- …` (hash bên trong vẫn đúng trên branch batch đã
push); KHÔNG cherry-pick commit docs batch (sửa spec/GOAL đã phân kỳ).
Commit docs unification này: 10 dòng spec (9 slice + N2196 fix — batch
3 có dòng spec N2196) + GOAL.md §4/§5 + cặp report/handoff này. Nợ
Godot: 58 → **66 proofs + 1 re-run (N2196)**. N2189 không cộng nợ mới
(gộp vào proof N2241 đã đếm, nay 8 key).

## Kết quả

- Wave line giờ chứa toàn bộ batch 1–3: ledger 1691 slice, symbols
  11642, contracts 1613, schemas 3017.
- Advances-5 được re-scope SAU unification (Mend heal scan build trên
  N2193 — N2193 giờ đã có trong ledger; scope cũ sai vì giả định N2193
  đã có trên line).
- Lưu ý còn tồn tại: N2197 không có dòng spec checklist riêng trên wave
  line (chỉ được nhắc trong dòng N2188/N2198/N2199) — khoảng trống có từ
  trước, không thuộc phạm vi unification.

## Hash map (batch → unification)

N2186 `879fa13e`→`5726e0ee`, fix `65a9f597`→`68fa6aee`; N2187
`b69ba59d`→`20a08fbf`, fix `ffcf9ccb`→`98defc46`; N2189 `8803e1e7`→
`00e6588b` (merge tay với N2241); N2190 `6baeb7bc`→`bea4d312`; N2191
`fafe334f`→`01e599d9`, fix `ed17c642`→`a50addc1`; N2192 `52e3b178`→
`c1d8e762`, fix `a646945c`→`e52e798e`; N2193 `d8dce467`→`5478286e`;
N2194 `2723e795`→`ed52a099`, fix `447c0bc3`→`f3595cba`; N2195
`c42968e1`→`d7512292`, fix `7fa5d6ad`→`3fdfc145`; N2196 `bca6dfe5`→
`a836ba0b`, fix `80dbf05e`→`d6dd3066`; N2186 test fix `ff725ce0`;
SSOT gộp `ed2e9251`.
