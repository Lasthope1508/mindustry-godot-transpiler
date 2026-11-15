# Mục tiêu sau cùng — Mindustry Java → Godot GDScript

Tài liệu này là la bàn cho mọi agent làm việc trên repo này. Đọc nó trước khi
làm bất cứ slice nào. Nếu một quyết định đi ngược tài liệu này, dừng lại và
hỏi user.

## 1. Mục tiêu sau cùng

Port **toàn bộ hành vi Java của Mindustry sang GDScript/Godot một cách chính
xác (faithful)**, chơi được, kiểm chứng được, và phát hành được. Nghĩa là đi
hết **C01–C12** trong
`docs/superpowers/handoffs/2026-11-02-mindustry-completion-backlog.md`, kết
thúc ở **C12: clean-checkout regeneration + release candidate**.

Đích đến không phải "nhiều slice xong" mà là: game chạy đúng như Java gốc,
gate đầy đủ xanh, checkout sạch regenerate được, và có bản release.

## 2. Không phải mục tiêu (đã chốt với user, 2026-11-13)

**Không** biến repo này thành thư viện component generic để tách ra làm nhiều
game khác. Đó là một hướng khác, cần thiết kế lại từ đầu (interface ổn định
có version, cắt coupling với game object/frame system, trừu tượng hóa
semantics riêng của Mindustry thành mô hình chung). Chỉ xem xét hướng đó
**sau khi** port xong và nghiệm thu xong. Trong lúc port, không hy sinh
fidelity để lấy reusability.

## 3. Kế hoạch — C01–C12 (backlog)

| Chương | Nội dung | Trạng thái (2026-11-13) |
| --- | --- | --- |
| C01 | Ore selection / proximity (Drill) | Đường chính chạy được; complete lifecycle còn mở |
| C02 | Output / dump / transport theo Building | Primary có đường composition cũ; secondary còn local fallback |
| C03 | Power consumer và Drill dùng điện | Có state power riêng; đang nối consumer thật vào live path (C07 tiếp nối) |
| C04 | Liquid supply / flow / capacity / persistence | Kho và remove thật đã có; flow null |
| C05 | Consumer initialization, rules và reload | Direct single-liquid subset đã nối; mixed/inherited/dynamic chưa đóng |
| C06 | Vòng factory → core → defense chạy hoàn chỉnh | **ĐÓNG** (N2139) |
| C07 | Units, waves, world và campaign | **ĐANG LÀM** — power.status live read, family by family |
| C08 | Generated semantics / unsupported ledger | Chưa bắt đầu (5.390 hàm null-body chưa phân loại — xem §7) |
| C09 | Facade / bridge và SSOT quality | Chưa bắt đầu |
| C10 | Save / load / network | Chưa bắt đầu |
| C11 | Presentation, ổn định và hiệu năng | Chưa bắt đầu (có playable shell) |
| C12 | Clean reproducibility và release | Chưa bắt đầu |

Thứ tự làm việc: theo backlog và mục "Next" trong handoff mới nhất
(`docs/superpowers/handoffs/`). Khi trống task, tự làm slice tiếp theo, không
đợi user giao.

## 4. Tiến độ hiện tại (2026-11-16 01:47 +07)

- Main trên fork ở `de9ab89c` (N2185 LightBlock power.status DONE + PUSHED).
- **Batch 1 {N2186, N2187, N2189} DONE** trên branch tích hợp
  `integration/batch-n2186-n2187-n2189` (không push, không merge vào main):
  N2186 LaunchPad shouldConsume gate + N2187 ShockwaveTower shouldConsume gate
  + N2189 LightBlock updateTile advance; neighbours 155/208 (53 Godot-absent,
  0 lỗi khác), full gate Ran 5849 in 1131.248s, failures=139, skipped=5,
  0 errors — 139/139 Godot-absent. SSOT gộp 11386/1639/1560/2911.
- **Batch 2 {N2190 Radar, N2191 Accelerator, N2192 ImpactReactor} updateTile
  DONE** trên branch tích hợp `integration/batch-n2190-n2191-n2192` (không
  push, không merge vào main): neighbours 155/208 (53 Godot-absent, 0 lỗi
  khác), full gate Ran 5849 in 1041.246s, failures=139, skipped=5,
  0 errors — 139/139 Godot-absent. SSOT gộp 11390/1639/1560/2911.
- **Batch 3 {N2193 MendProjector, N2194 OverdriveProjector, N2195 BeamDrill}
  updateTile + N2196 conduit Time.delta fix DONE** trên branch tích hợp
  `integration/batch-n2193-n2194-n2195-n2196` (không push, không merge vào
  main): neighbours 161/216 (55 Godot-absent, 0 lỗi khác), full gate
  Ran 5850 in 1044.287s, failures=139, skipped=5, 0 errors — 139/139 Godot-absent (136 inherited + 3 new proof tests N2193/N2194/N2195; Ran 5850, not 5849, because N2196 added 1 passing test). SSOT gộp 11391/1639/1560/2911 (N2196 là fix, không SSOT).
- **N2197 ItemBridge link frame state (infra) DONE** trên branch tích hợp
  `integration/n2197-item-bridge-link` (không push, không merge vào main):
  frame keys `link`/`had_valid_link` + pure configure + pure linkValid +
  driver recompute sau consumption fold; neighbours 38/52 (14 Godot-absent,
  0 lỗi khác), full gate Ran 5841 in 945.797s, failures=137, skipped=5,
  0 errors — 137/137 Godot-absent. SSOT 11382/1637/1558/2907. N2197 mở khóa N2188.
- **Wave 2 {N2188 ItemBridge shouldConsume gate, N2198 LiquidBridge
  shouldConsume gate} DONE** trên branch tích hợp
  `integration/wave2-n2188-n2198` (không push, không merge vào main):
  neighbours 44/60 (16 Godot-absent, 0 lỗi khác), full gate
  Ran 5849 in 1003.342s, failures=139, skipped=5, 0 errors — 139/139 Godot-absent (136 inherited + 3 new proof tests N2197/N2188/N2198). SSOT gộp 11386/1639/1560/2911.
- **N2199 ItemBridge placement auto-link (playerPlaced + findLink + lastBuild)
  DONE** trên branch `slice/N2199-item-bridge-auto-link` (coordinator làm tuần
  tự — chạm shared placement flow; không merge vào main; branch push ngay sau
  docs commit theo push-as-you-go): pure findLink + pure playerPlaced + game
  lastBuild store + placement drivers (item + liquid twin) + PortGame dispatch
  (qua SourceSelectedBuildState predicates) + hook ở player path; neighbours
  bridge family + hydration 38 tests (7 Godot-absent, 1 skipped, 0 lỗi khác)
  + playable/reports 2338 OK; full gate run 3 Ran 5853 in 989.761s,
  failures=140, skipped=5, 0 errors — 140/140 Godot-absent (136 inherited +
  4 proof N2197/N2188/N2198/N2199). SSOT 11396/1640/1563/2917, audit 1336,
  legacy 0. (Gate run 1 fail 9 validator — fix bằng rename dispatch; run 2
  fail 105 registration do lỗi sort_keys của coordinator — fix bằng checkout +
  chạy lại register.)
- **Wave items {N2200 Separator, N2201 WallCrafter, N2202 BeamDrill, N2203
  BurstDrill, N2204 base Drill} shouldConsume gates DONE** trên branch tích
  hợp `integration/wave-items-n2200-n2204` (không merge vào main; 5 slice
  branch push 13:21 + integration branch push ngay sau docs commit theo
  push-as-you-go): neighbours họ production 64 tests (16 Godot-absent,
  0 lỗi khác) + targeted 5 module 20 tests (15 PASS + 5 proof Godot-absent),
  full gate Ran 5873 in 985.433s, failures=145, skipped=5,
  0 errors — 145/145 Godot-absent (140 inherited + 5 new proof tests N2200–N2204).
  SSOT gộp 11407/1645/1568/2927, audit 1336, legacy 0. Coordinator fix
  `481315f8` ở tích hợp: seed facing_amount=1 trong proof N2155 (nếu không
  key efficiency_folds_power_min sẽ fail trên Godot vì gate N2202 đóng khi
  facing_amount mặc định 0).
- **Wave liquids {N2205 Pump, N2206 SolidPump, N2207 Fracker} shouldConsume
  gates DONE** trên branch tích hợp `integration/wave-liquids-n2205-n2207`
  (không merge vào main; 3 slice branch push 13:50–13:55 + integration
  branch push ngay sau docs commit theo push-as-you-go): neighbours họ
  pump 20 tests (15 PASS + 5 proof Godot-absent, 0 lỗi khác) + targeted
  3 module 12 tests (9 PASS + 3 proof Godot-absent), full gate Ran 5885
  in 1005.870s, failures=148, skipped=5, 0 errors — 148/148 Godot-absent
  (145 inherited + 3 new proof tests N2205–N2207). SSOT gộp
  11413/1648/1571/2933, audit 1336, legacy 0. Không cần fix ở tích hợp
  (3 cherry-picks sạch); lưu ý: lần chạy targeted đầu báo 9
  FileNotFoundError do worktree tích hợp thiếu bản copy mindustry-upstream
  — đã copy từ worktree tích hợp wave-items (bố cục giống worktree slice).
- **Wave payload {N2208 PayloadLoader, N2209 PayloadUnloader, N2210
  PayloadDeconstructor, N2211 UnitCargoLoader} shouldConsume gates DONE**
  trên branch tích hợp `integration/wave-payload-n2208-n2211` (không merge
  vào main; 4 slice branch push 14:17–14:19 + integration branch push ngay
  sau docs commit theo push-as-you-go): neighbours họ payload 20 tests
  (15 PASS + 5 proof Godot-absent, 0 lỗi khác) + targeted 4 module 16 tests
  (12 PASS + 4 proof Godot-absent), full gate Ran 5901 in 1003.626s,
  failures=152, skipped=5, 0 errors — 152/152 Godot-absent (148 inherited
  + 4 new proof tests N2208–N2211). SSOT gộp 11421/1652/1575/2941, audit
  1336, legacy 0. Coordinator fix `53ed2029` ở tích hợp: seed payload /
  deconstructing fixture vào proof N2162/N2163/N2166 (nếu không key
  efficiency_folds_power_min sẽ fail trên Godot vì gate đóng khi frame
  trống); proof N2165 không cần fix vì gate ĐẢO. Lưu ý scoping: DEFERRED
  gộp 257 = 251 + 6 entry PayloadLoader khôi phục từ register N2162 (bị mất
  khi base N2199 build từ snapshot pre-N2162).
- **Wave targets {N2212 RepairTurret, N2213 RepairTower, N2214
  RegenProjector} shouldConsume gates DONE**
  trên branch tích hợp `integration/wave-targets-n2212-n2214` (không merge
  vào main; 3 slice branch push 14:45–14:46 + integration branch push ngay
  sau docs commit theo push-as-you-go): neighbours họ repair/regen 16 tests
  (12 PASS + 4 proof Godot-absent, 0 lỗi khác) + targeted 3 module 12 tests
  (9 PASS + 3 proof Godot-absent), full gate Ran 5913 in 1040.657s,
  failures=155, skipped=5, 0 errors — 155/155 Godot-absent (152 inherited
  + 3 new proof tests N2212–N2214). SSOT gộp 11427/1655/1578/2947, audit
  1336, legacy 0. Coordinator fix `5779a6c4` ở tích hợp: seed target /
  targets / any_targets fixture vào proof N2174/N2176/N2160 (nếu không key
  efficiency_folds_power_min sẽ fail trên Godot vì gate đóng khi frame
  trống). N2214 sửa cite gate sai của driver N2160 (206-208 → 181-183,
  đã verify bằng grep); driver N2160 còn nhiều cite pin-drift khác — cần
  cite-cleanup slice riêng.
- **Wave plans {N2215 BuildTurret, N2216 BlockProducer/Constructor}
  shouldConsume gates DONE**
  trên branch tích hợp `integration/wave-plans-n2215-n2216` (không merge
  vào main; 2 slice branch push 15:11 + integration branch push ngay
  sau docs commit theo push-as-you-go): neighbours họ build/constructor
  8 tests (6 PASS + 2 proof Godot-absent, 0 lỗi khác) + targeted 2 module
  8 tests (6 PASS + 2 proof Godot-absent), full gate run 2 Ran 5921 in
  959.898s, failures=157, skipped=5, 0 errors — 157/157 Godot-absent
  (155 inherited + 2 new proof tests N2215–N2216; run 1 PID 19171 bị
  giết bởi VM restart lần 3 ~15:22, run 2 PID 1756 chạy lại từ đầu).
  SSOT gộp 11431/1657/1580/2951, audit 1336, legacy 0. Coordinator fix
  `c36f1cb7` ở tích hợp: seed plans / recipe fixture vào proof
  N2184/N2161 (nếu không key efficiency_folds_power_min sẽ fail trên
  Godot vì gate đóng khi frame trống). N2216 sửa cite scope sai (recipe
  field :59 không phải :61, config :32–37, configClear :31/:38 — đã
  verify bằng grep).
- **Wave turrets {N2217 PointDefenseTurret, N2218 TractorBeamTurret}
  shouldConsume gates DONE**
  trên branch tích hợp `integration/wave-turrets-n2217-n2218` (không merge
  vào main; 2 slice branch push 15:45–15:46 + integration branch push ngay
  sau docs commit theo push-as-you-go): neighbours họ turret
  8 tests (6 PASS + 2 proof Godot-absent, 0 lỗi khác) + targeted 2 module
  8 tests (6 PASS + 2 proof Godot-absent), full gate Ran 5929 in
  1007.260s, failures=159, skipped=5, 0 errors — 159/159 Godot-absent
  (157 inherited + 2 new proof tests N2217–N2218).
  SSOT gộp 11435/1659/1582/2955, audit 1336, legacy 0. Coordinator fix
  `4a186c78` ở tích hợp: seed target fixture vào proof
  N2151/N2152 (nếu không key efficiency_folds_power_min sẽ fail trên
  Godot vì gate đóng khi frame trống). Cả 2 gate đều `super.shouldConsume()
  && target != null` (super = BuildingComp default `enabled`; chain
  qua BaseTurret — Turret.java:364 KHÔNG nằm trong chain, đã verify bằng
  grep); target là Bullet (N2217, def segment 8f) vs Unit (N2218, def
  parallax 3.3f). N2218 sửa wording "bullet-target" cẩu thả của driver
  N2152. DEFERRED gộp sau wave: 258 entries (257 − 1 entry gộp turret
  + 2 entry live-fill rộng).
- **Wave advances-1 {N2219 BurstDrill, N2220 SolidPump, N2221 Pump, N2222
  Separator, N2223 WallCrafter} updateTile advances DONE**
  trên branch tích hợp `integration/wave-advances-1-n2219-n2223` (không
  merge vào main; 5 slice branch push 16:17–16:22 + integration branch
  push ngay sau docs commit theo push-as-you-go): neighbours 5 families
  power+gate 40 tests (30 PASS + 10 proof Godot-absent, 0 lỗi khác) +
  targeted 5 module 20 tests (15 PASS + 5 proof Godot-absent), full gate
  Ran 5949 in 1023.981s, failures=164, skipped=5, 0 errors — 164/164
  Godot-absent (159 inherited + 5 new proof tests N2219–N2223).
  SSOT gộp 11470/1664/1587/2965, audit 1336, legacy 0. KHÔNG cần
  coordinator fix — advance không vỡ proof cũ (khác các wave gate: không
  có gate mới đóng trên frame trống). N2222 port Arc Rand faithfully
  (xorshift128+, khớp 1030/1030 case) + phát hiện
  `SourceMathState.random_seed_int` KHÔNG faithful với Arc; N2223 phát
  hiện hasLiquidBooster = false cho cả 2 def (hydrogen không có
  `.boost()`), mâu thuẫn comment N2170/N2201. DEFERRED gộp sau wave:
  258 entries (258 − 1 stale "Pump warmup/totalProgress" + 1 net N2222;
  N2220 remove thêm entry "frame liquids intake" vì advance CHÍNH LÀ
  intake).
- **Wave advances-2 {N2224 Fracker, N2225 ItemBridge transport, N2226
  RepairTurret, N2227 RepairTower, N2228 RegenProjector} updateTile
  advances DONE**
  trên branch tích hợp `integration/wave-advances-2-n2224-n2228` (không
  merge vào main; 5 slice branch push 16:56–17:00 + integration branch
  push ngay sau docs commit theo push-as-you-go): neighbours 12 module
  power+gate+link 48 tests (36 PASS + 12 proof Godot-absent, 0 lỗi
  khác) + targeted 5 module 20 tests (15 PASS + 5 proof Godot-absent),
  full gate Ran 5969 in 1029.991s, failures=169, skipped=5, 0 errors —
  169/169 Godot-absent (164 inherited + 5 new proof tests N2224–N2228).
  SSOT gộp 11507/1669/1592/2975, audit 1336, legacy 0. Coordinator fix
  f240da22: đổi frame key N2228 `suppressed` → `heal_suppressed` (N2215
  precedent + AGENTS.md normalize; N2227 dùng `heal_suppressed`).
  KHÔNG cần fix proof cũ — advance không vỡ proof cũ (như advances-1).
  N2225 chứng minh checkAccept rút gọn (linked luôn true khi hadValidLink
  đúng); N2226 port Units.closest faithfully (chỉ timer cadence defer);
  N2228 phát hiện mendMap là static-shared nên flush defer cả application
  + cadence, port track per-building mend_map. DEFERRED gộp sau wave:
  260 entries (258 − 8 resolved + 10 new).
- **Wave advances-3 {N2229 PointDefenseTurret, N2230 TractorBeamTurret,
  N2231 PayloadLoader, N2232 PayloadUnloader, N2233 PayloadDeconstructor,
  N2234 UnitCargoLoader} updateTile advances DONE**
  trên branch tích hợp `integration/wave-advances-3-n2229-n2234` (không
  merge vào main; 6 slice branch push 17:40–17:43 + integration branch
  push ngay sau docs commit theo push-as-you-go): neighbours 12 module
  power+gate 48 tests (36 PASS + 12 proof Godot-absent, 0 lỗi khác) +
  targeted 6 module 24 tests (18 PASS + 6 proof Godot-absent),
  full gate Ran 5993 in 1036.683s, failures=175, skipped=5, 0 errors —
  175/175 Godot-absent (169 inherited + 6 new proof tests N2229–N2234).
  SSOT gộp 11568/1675/1598/2987, audit 1336, legacy 0. KHÔNG cần
  coordinator fix — advance không vỡ proof cũ (như advances-1/2);
  N2231 + N2232 REUSE thành công helper moveOut của BlockProducer;
  N2231 hiệu chỉnh scope: PayloadLoader CÓ rotate (PayloadLoader.java:45)
  + default acceptItem là consumesItem-based (BuildingComp.java:864-866);
  N2230 phát hiện eff ordering trap (eff tính TRƯỚC coolant branch) +
  coolantMultiplier không có reset riêng + 17 file
  `SourceTractorBeamTurretBuildUpdateTile*State.gd` là DEAD với live
  gameplay (không sửa, không xóa khi chưa có ý user); N2233 phát hiện
  UnitPayload buildTime = `unit.type.getBuildTime()`; N2234 phát hiện
  manifold KHÔNG set useUnitCap = false. DEFERRED gộp sau wave:
  265 entries (260 − 14 resolved + 19 new).
- **Wave advances-4 {N2235 ForceProjector, N2236 BaseShield,
  N2237 MassDriver, N2238 LaunchPad, N2239 StackConveyor,
  N2240 StackRouter, N2241 LightBlock} updateTile advances DONE**
  trên branch tích hợp `integration/wave-advances-4-n2235-n2241` (không
  merge vào main; 7 slice branch push 18:21–18:28 + integration branch
  push ngay sau docs commit theo push-as-you-go): neighbours 7 module
  power 28 tests (21 PASS + 7 proof Godot-absent, 0 lỗi khác) +
  targeted 7 module 28 tests (21 PASS + 7 proof Godot-absent),
  full gate Ran 6021 in 1071.101s, failures=182, skipped=5,
  0 errors — 182/182 Godot-absent (175 inherited + 7 new proof tests
  N2235–N2241).
  SSOT gộp 11616/1682/1605/3001, audit 1336, legacy 0. KHÔNG cần
  coordinator fix — advance không vỡ proof cũ (như advances-1/2/3);
  N2235 hiệu chỉnh scope: `broken` mặc định TRUE (ForceProjector.java:167)
  + coolantConsumer KHÔNG null (:84-86); N2236 phát hiện scope BỎ SÓT
  nhánh instakill (BaseShield.java:43-45) + `broken` không bao giờ set
  live; N2237 hiệu chỉnh scope: Angles.near là STRICT `<` + shooterValid
  không check team + config handlers :58-59; N2238 phát hiện consume()
  là no-op cả items lẫn liquids + cờ unification với N2186 (test N2186
  assert dòng inline counter-advance phải sửa lúc unification);
  N2239 hiệu chỉnh moveForward ở BuildingComp.java:1129-1137;
  N2240 hiệu chỉnh enabled gate là EXACT (noUpdateDisabled=true) +
  eff khác StackConveyor (disabled 0f, không phải 1f); N2241 hiệu
  chỉnh smoothTime init 1f + updateTile :104-106 + N2189 đã làm
  advance này trên batch line (line divergence — phương án gộp đã
  soạn trong STATUS.md, ĐÃ THỰC HIỆN ở unification bên dưới). DEFERRED gộp sau wave:
  270 entries (265 − 8 resolved + 13 new).
- **Unification batch 1–3 {N2186 LaunchPad gate, N2187 ShockwaveTower gate,
  N2189 LightBlock updateTile, N2190 Radar, N2191 Accelerator, N2192
  ImpactReactor, N2193 MendProjector, N2194 OverdriveProjector, N2195
  BeamDrill, N2196 conduit Time.delta fix} DONE** trên branch tích hợp
  `integration/unification-batch-1-3` (không merge vào main; branch push
  ngay sau docs commit theo push-as-you-go): batch 1/2/3 là 3 line song
  song base trên `de9ab89c`, KHÔNG có trong wave line (phát hiện 18:21
  15/11 — ledger wave line thiếu 9 slice); unification cherry-pick 14
  commit slice+fix + merge tay 3 ca (N2186/N2238 LaunchPad driver 6 hunk
  + test fix `ff725ce0`; N2195/N2202 BeamDrill 1 hunk comment;
  N2189/N2241 LightBlock merge tay toàn bộ, proof gộp 8 key) + chạy lại
  9 register. Targeted 10 module Ran 40 (30 PASS + 10 proof
  Godot-absent, 0 lỗi khác) + neighbours 11 module Ran 44 (33 PASS +
  11 proof Godot-absent, 0 lỗi khác); full gate (PID 21602, launch
  ~19:10, done 19:29 +07) Ran 6054 in 1114.842s, failures=190,
  skipped=5, 0 errors — 190/190 Godot-absent (182 inherited + 8 new
  proof tests N2186/N2187/N2190/N2191/N2192/N2193/N2194/N2195).
  SSOT gộp 11642/1691/1613/3017, audit 1336, legacy 0 (schemas 3017,
  không phải 3018 như phương án dự báo — overlap LightBlock là −2 vì
  input + result là 2 entry; đã verify bằng JSON diff). DEFERRED gộp
  sau unification: 283 entries (270 − 12 resolved + 25 new, diff 3
  chiều AST với base `de9ab89c`). Nợ Godot: 58 → 66 proofs + 1 re-run
  (N2196); N2189 gộp vào proof N2241 đã đếm (nay 8 key). 9 report +
  9 handoff batch mang nguyên văn vào branch này.
- **Wave advances-5 {N2242 MendProjector heal scan, N2243 BuildTurret
  sync/warmup, N2244 BuildTurret plan logic, N2245 PayloadMassDriver
  frame/state, N2246 PMD branches, N2247 ShockwaveTower fire, N2248
  UnitAssemblerModule link/handoff} updateTile advances DONE** trên branch
  tích hợp `integration/wave-advances-5-n2242-n2248` (không merge vào
  main; branch push ngay sau docs commit theo push-as-you-go): 7/7 slice
  xong + đã push (N2242 b0bc1971, N2243 aaaf97ff, N2244 f0077463, N2245
  d995b023, N2246 107c2ad6, N2247 a46b276b, N2248 0ecf1534), mỗi slice
  targeted 3/4 PASS + proof Godot-absent; tích hợp cherry-pick 7 slice
  (N2242 ac09e99f, N2243 f1ed1729, N2244 340cec5d merge tay driver
  BuildTurret 6 hunk, N2245 5573dcd3, N2246 39b16e35 merge tay driver PMD
  13 hunk, N2247 66626216, N2248 2c3ded1b). Merge PMD: pay_vector N2245
  dict vs N2246 Vector2 → frame chuẩn dict, convert ở boundary wiring
  (2 helper mới); dedupe _to_short/_point2_*; sửa cite N2246 :342 →
  :332 (updateTile kết thúc :332, verify Java). Targeted 7 module Ran
  28 (21 PASS + 7 proof Godot-absent, 0 lỗi khác) + neighbours 8 module
  Ran 32 (24 PASS + 8 proof Godot-absent, 0 lỗi khác); full gate (PID 29915, launch 20:00, done 20:19 +07) Ran 6082 in 1118.145s, failures=197, skipped=5, 0 errors — 197/197 Godot-absent (190 inherited + 7 new proof tests N2242–N2248).
  SSOT gộp 11706/1698/1620/3031 (+64/+7/+7/+14 vs unification 00f5feb3),
  audit 1336, legacy 0. DEFERRED gộp sau wave: 294 entries (283 − 11
  resolved + 22 new, diff 3 chiều với base unification). Nợ Godot: 66 →
  73 proofs + 1 re-run (N2196).
- **Wave second-consumers-1 {N2249 UnitCargoLoader nitrogen, N2250 RepairTower ozone, N2251 BuildTurret nitrogen, N2252 Separator slag, N2253 LaunchPad oil, N2254 ImpactReactor cryofluid, N2255 Fracker water} required ConsumeLiquid rows — HOÀN TẤT + ĐÃ PUSH** (branch `integration/wave-second-consumers-1-n2249-n2255`, base c2d27fb0; 7/7 slice xong + đã push: N2249 8d98e988, N2250 c9364955, N2251 eec92c53, N2252 b3922a5f, N2253 ecebb9c5, N2254 2abb4c60, N2255 1fed72fc; mỗi slice +2/+1/+1/+2, targeted 3/4 PASS + proof Godot-absent; SSOT gộp 11720/1705/1627/3045; DEFERRED gộp 293; fix cites 81b0dbe4 — ConsumeLiquid efficiency :42-47 / update :37-39, Fracker guard :141-142; second-pass removal trực tiếp ở cả 7 slice — machinery chỉ record actor, không gọi update; full gate Ran 6110 in 1143.879s, failures=204, skipped=5, 0 errors — 204/204 Godot-absent (197 inherited + 7 new proof tests N2249–N2255)). Nợ Godot: 73 → 80 proofs + 1 re-run (N2196). **Đối chiếu lại 21:2x 15/11 (coordinator lượt 6, đếm trực tiếp từ §5): thực tế 68 proofs + 1 re-run + 30 Windows-track — số "80" đếm thừa 12 (+8 unification đếm trùng batch 1–3, +1 N2189 gộp vào proof N2241, +3 không truy vết được từ thời N2199).**
- **Wave second-consumers-2 {N2256 BeamDrill liquid rows, N2257 BurstDrill liquid rows, N2258 ForceProjector coolant, N2259 RepairTurret coolant} booster liquids + coolant — HOÀN TẤT + ĐÃ PUSH** (branch `integration/wave-second-consumers-2-n2256-n2259`, base 73185810; 4/4 slice xong + đã push: N2256 6e654a14, N2257 c6c564fb, N2258 4c0f4b77, N2259 ae2cd4cc; mỗi slice targeted 3/4 PASS + proof Godot-absent; SSOT gộp 11732/1709/1631/3053; DEFERRED gộp 293; fix cites 33893e22 — Fracker guard :221 (không phải :141), optional-pass for-loop BuildingComp.java:1980, N2195 advance docstring stale; booster = `optional(true, true)` (Consume.java:33-35), một pure row function phục vụ cả required + booster row (route theo catalog `optional` flag); coolant filter ConsumeCoolant.java:12, chỉ water + cryofluid qua filter; ForceProjector consume tay trong updateTile (:227-231, `update(false)`), RepairTurret multiplier qua frame key `coolant_multiplier`; N2235 contract giữ nguyên 10 return_keys — 2 key mới của advance đăng ký symbols-only, validator chỉ check contract ⊆ schema; full gate Ran 6126 in 1081.029s, failures=208, skipped=5, 0 errors — 208/208 Godot-absent (204 inherited + 4 new proof tests N2256–N2259)). **Khôi phục docs N2197** (report + handoff + spec line + entry §5 — docs commit gốc `ab84d2cf` không nằm trên line này nên đã thiếu từ unification). Nợ Godot: 68 → 72 proofs + 1 re-run (N2196) + 30 Windows-track (N2156–N2185, đã GREEN Linux).
- **Wave booster items {N2260 RegenProjector second consumers, N2261 ForceProjector booster item, N2262 OverdriveProjector booster items, N2263 MendProjector booster items, N2264 WallCrafter second consumers} ConsumeItems booster/required rows — HOÀN TẤT + ĐÃ PUSH** (branch `integration/wave-booster-items-n2260-n2264`, base 22164673; 5/5 slice xong + đã push: N2260 752a8b27, N2261 073ecde1, N2262 a867f416, N2263 ac718a0a, N2264 041c31e7; mỗi slice targeted 3/4 PASS + proof Godot-absent; SSOT gộp 11749/1714/1638/3067; DEFERRED gộp 289; không cần fix cites ở tích hợp; ConsumeItems.efficiency BINARY 1/0 (ConsumeItems.java:51-53), `items.has(ItemStack[], float)` ItemModule.java:153-158 check :154, booster = `optional(true, true)` → optional pass (BuildingComp.java:1980-1981), required fold pass đầu; một pure row function phục vụ cả required + booster row ở N2262 (route theo catalog `optional` flag); N2260/N2264 hai pure functions (liquid + item) nên 2 contracts + 4 schemas mỗi slice; ForceProjector live inputs qua frame-stamp + advance frame-fallback (N2235 test pin call string); WallCrafter item row tính NGOÀI consumption guard để `item_valid` sống khi machinery skip; Overdrive removal theo `use_ready` (kế thừa disabled-gap deviation); DEFERRED resolve theo entry TEXT — số trong scope doc là số dòng file, không phải số entry; full gate run 2 Ran 6146 in 1091.013s, failures=213, skipped=5, 0 errors — 213/213 Godot-absent (208 inherited + 5 new proof tests N2260–N2264); run 1 bị VM restart lần 5 ~22:27 giết sau ~17.8 phút). Nợ Godot: 72 → 77 proofs + 1 re-run (N2196) + 30 Windows-track (N2156–N2185, đã GREEN Linux).
- **Wave dynamic/special {N2265 BlockProducer ConsumeItemDynamic, N2266 ImpactReactor blast-compound row + timer, N2267 Accelerator item rows, N2268 Fracker sand row, N2269 MendProjector booster timer} dynamic/special item rows + timer-gated consume — HOÀN TẤT + ĐÃ PUSH** (branch `integration/wave-dynamic-special-n2265-n2269`, base e07aac89; 5/5 slice xong + đã push: N2265 81a94e9a, N2266 a0ddd235, N2267 cbdce69a, N2268 47f89c86, N2269 1791376a; mỗi slice targeted 3/4 PASS + proof Godot-absent; SSOT gộp 11773/1719/1648/3088 (+24/+5/+10/+21); DEFERRED gộp 290 (289 − 6 resolve + 7 mới); fix cross-proof e5412ae9 — seed items vào 10 proof cũ (required row mới fold 0.0 trên frame trống: Accelerator full 4 stacks, Constructor copper 1, Fracker sand 1, ImpactReactor blast-compound 1) + fix cite stale N2254 (:141-142 → :221); fix cite d303492e — TimerComp.timer :10-13 (không phải :11-14); ConsumeItems.efficiency BINARY 1/0 (ConsumeItems.java:51-53), ConsumeItemDynamic.efficiency :60-62 / trigger :53-57, dynamic func BlockProducer.java:39-55; frame-local Interval-equivalent mới cho N2266/N2269 (frame key `timer_use_elapsed`, accumulate vô điều kiện mỗi tick, reset 0 khi fire — deviation first-fire đã ghi rõ: Java fire gần như ngay sau placement, frame clock trì hoãn 1 interval); N2265 stacks function KHÔNG có API contract (trả Array — case đầu tiên, `has_contract=False`); N2267 4 pure functions (accept tách khỏi max-accepted) nên +10/+1/+4/+7; N2266 resolve 2 DEFERRED entries (item row + consume-timer rows); catalog CÓ consumeItem cho fracker (SCOPE ghi sai); N2265 register build trên base DEFERRED stale 291 — merged file chỉ dùng delta thật −1/+2; full gate Ran 6166 in 1159.193s, failures=218, skipped=5, 0 errors — 218/218 Godot-absent (213 inherited + 5 new proof tests N2265–N2269)). Nợ Godot: 77 → 82 proofs + 1 re-run (N2196) + 30 Windows-track (N2156–N2185, đã GREEN Linux).
- **Wave power-launch-build {N2270 PayloadLoader dynamic power, N2271 Accelerator launch, N2272 BuildTurret updateBuildLogic, N2273 WallCrafter timer consume} dynamic power + launch + build logic + timer consume — HOÀN TẤT + ĐÃ PUSH** (branch `integration/wave-power-launch-build-n2270-n2273`, base 3bca6665; 4/4 slice xong + đã push: N2270 5a11de4e, N2271 69d07e3f, N2272 48ec98f0, N2273 550bfeb5; mỗi slice targeted 3/4 PASS + proof Godot-absent; SSOT gộp 11795/1723/1654/3100 (+22/+4/+6/+12); DEFERRED gộp 290 (290 − 5 resolve/removed + 5 mới); fix Unloader ad3c3e29 — PayloadUnloader KHÔNG có dynamic consumer (loadPowerDynamic=false, PayloadUnloader.java:18; DEFERRED entry + docstring limit (1) SAI, đã sửa; Unloader chỉ consumePower(2f) static, Blocks.java:6695, live N2209); fix date 32ee85bc (lượt 9 ghi sai giờ 00:40–00:47 16/11, giờ thật 23:40–23:47 15/11 — shell mặc định UTC); N2270: ConsumePowerDynamic KHÔNG có getUsage — graph query requestedPower(Building) :24; frame key power_usage stamp mỗi tick ở fold, TRƯỚC advance, NGOÀI enabled guard; graph wiring deferred; N2271: 2 pure (canLaunch 4 điều kiện + launch transition), trigger launch_requested one-shot, clear cả pass lẫn fail, DISCARD resources, KHÔNG đụng launching; useBatteries port new_stored = max(0, stored − min(stored, requirement)); per-battery scaling deferred; battery_stored là frame INPUT (no live fill); float32 vs float64 epsilon 1e-5 trên 1e6; N2272: 2 pure (build counter + validate-and-select), wiring UNGATED on enabled (N2244 precedent), dst2 dùng block.offset (không phải tile.x*8+4), within `<=` vs fallback `<`, 1-plan case, unit.updateBuildLogic() ở BuildTurret.java:225 (comment N2243 ghi :231 sai); N2273: duration 80f cho large-cliff-crusher (60f/0.75f, Blocks.java:3032), 120f chỉ là class default; frame-local Interval-equivalent (timer_use_elapsed), first-fire deviation; full gate Ran 6182 in 1189.124s, failures=222, skipped=5, 0 errors — 222/222 Godot-absent (218 inherited + 4 new proof tests N2270–N2273)). Nợ Godot: 82 → 86 proofs + 1 re-run (N2196) + 30 Windows-track (N2156–N2185, đã GREEN Linux).
- **Wave advances-6 {N2274 BlockProducer updateTile, N2275 LiquidBridge updateTransport, N2276 PayloadDeconstructor dump, N2277 RegenProjector targets fill, N2278 PayloadLoader live fill, N2279 PayloadUnloader live fill, N2280 RepairTurret timer-target} advances + live fills — HOÀN TẤT + ĐÃ PUSH** (branch `integration/wave-advances-6-n2274-n2280`, base 253151ad; 7/7 slice xong + đã push: N2274 f5d6d862, N2275 1ba2f18e, N2276 75ce778a, N2277 053860ff, N2278 46b659ad, N2279 654039d9, N2280 a91baae0; mỗi slice targeted 3/4 PASS + proof Godot-absent; SSOT gộp 11828/1730/1663/3118 (+33/+7/+9/+18); DEFERRED gộp 298 (290 − 9 resolve/removed + 17 mới); fix cites d0ea2b64 — acceptPayload PayloadLoader.java:90-101 (không phải :102-115), handlePayload override :104-107 (không phải :102-105 hay :118-121), 2 accept/handle entries → acceptPayload-only trong cả 7 register; fix test prefix 11cb9158 — fix cites của coordinator làm fail registration test N2279 (assert prefix cũ), đã sửa test theo entry mới; N2274: updateTile BlockProducer.java:107-128 (không phải :109-131), catalog KHÔNG có buildSpeed/buildTime (buildTime theo công thức Block.init), heat lerp dùng RAW Time.delta; N2275: brief bỏ sót ItemBridge acceptLiquid OVERRIDE (:434-439) — đã port, moveLiquid BuildingComp.java:938–978; N2276: dump block PayloadDeconstructor.java:111-115, dump chạy TRƯỚC advance (brief mâu thuẫn — Java thắng), reuse dump_item_state (game_put_item_state không biểu diễn được dump(null)); N2277: range 28 ở Blocks.java:2012 (không phải :2011), indexer là BlockIndexer.java, Java query hitbox-intersect (port dùng center-in-rect, deviation đã ghi); N2278/N2279: KHÔNG có large-payload-loader, divergence incoming GIỮ NGUYÊN CẢ HAI (N2278 drop input cả khi không apply, N2279 giữ để retry — Java: pusher check acceptPayload trước nên push tới building đã có payload không xảy ra); N2280: brief/SCOPE SAI công thức ngưỡng — Java truyền literal 20 (RepairTurret.java:214, KHÔNG chia timeScale), worker implement theo brief (20f/time_scale) + ghi deviation, coordinator ACCEPT as-is (Java-exact ở time_scale=1f), follow-up literal-20 qua DEFERRED; N2277 build register trên ledger N2273 (291) thay vì merged file 290 — merge LOẠI toàn bộ snapshot cũ, chỉ lấy delta thật; full gate run 2 Ran 6210 in 2126.929s, failures=229, skipped=5, 0 errors — 229/229 Godot-absent (222 inherited + 7 new proof tests N2274–N2280); run 1 (PID 2132) invalid: Ran 5527, failures=231, errors=15 — toàn javalang-import do VM restart lần 6 ~00:27 xóa javalang (đã cài lại 0.13.0 01:00); gate chậm (2127s vs ~1189s wave trước) do cold cache sau restart + cụm test_source_ssot_* ~70 test mỗi test ~25s). Nợ Godot: 86 → 93 proofs + 1 re-run (N2196) + 30 Windows-track (N2156–N2185, đã GREEN Linux).
- **Wave advances-7 {N2281 Separator timerDump, N2282 BurstDrill timerDump, N2283 WallCrafter timerDump, N2284 Fracker dumpLiquid, N2285 Pump dumpLiquid, N2286 SolidPump dumpLiquid, N2287 LiquidBridge doDump} dumps — HOÀN TẤT + ĐÃ PUSH** (branch `integration/wave-advances-7-n2281-n2287`, base d6e4f9fd; 7/7 slice xong + đã push: N2281 15905aad, N2282 eafd3fb5, N2283 ca592ed9, N2284 2365f112, N2285 321785c5, N2286 3bfdf49f, N2287 fc48fa18; mỗi slice targeted 3/4 PASS + proof Godot-absent; SSOT gộp 11855/1737/1670/3132 (+27/+7/+7/+14, ĐÚNG kỳ vọng); DEFERRED gộp 313 (298 − 7 resolve/removed + 22 mới, merge theo entry TEXT, cả 7 register build đúng base 298); KHÔNG cần fix ở tích hợp (worker đã dùng cites đúng); N2281: timer 5f/time_scale CÓ chia timeScale (khác N2280 literal-20), flag proof N2222 có thể stale sau N2252 (assert efficiency 0.5 không seed slag); N2282: brief SAI case null — Java return sớm :77-79 trước timer :83, dump(null) chỉ khi dominant TỒN TẠI mà store thiếu; items.has = count > 0; KHÔNG có def "burst-drill"; N2283: output là SAND không phải graphite (WallCrafter.java:43), cite hasItems :56 không phải :58; N2284: Fracker dump else-branch :42 không phải :43, MỘT call site sau advance bao cả 2 nhánh; N2285: tên pure brief bị trùng N2090 (đổi source_mechanical_pump_dump_liquid_state), defs rotary + impulse (mechanical-pump KHÔNG consumePower); N2286: PHÁT HIỆN cursor full-cycle invariant (dumpLiquid scan N neighbour = N lần incrementDump = đúng 1 vòng, cursor_after luôn bằng input — N2284/N2285/N2287 xác nhận độc lập), chỉ water-extractor là SolidPump; N2287: scaling 1f (không phải 2f), chỉ nhánh unlinked, base ItemBridge doDump = dumpAccumulate là slice khác; cites dumpLiquid thống nhất cả 4 worker liquid: impl :886–908, unlock :891, canDumpLiquid :910–912, transferLiquid :914–921 (brief/SCOPE đều sai vài dòng); full gate run 2 Ran 6238 in 1158.186s, failures=236, skipped=5, 0 errors — 236/236 Godot-absent (229 inherited + 7 new proof tests N2281–N2287); run 1 (PID 12422) killed by VM restart #7 ~02:28–02:29, no footer (javalang reinstalled 0.13.0 02:29)). Nợ Godot: 93 → 100 proofs + 1 re-run (N2196) + 30 Windows-track (N2156–N2185, đã GREEN Linux).
- **Wave advances-8 {N2288 ItemBridge doDump, N2289 BeamDrill dump timer, N2290 RepairTurret literal-20 fix, N2291 PayloadDeconstructor deconstructing fill, N2292 SolidPump fraction fill, N2293 PayloadUnloader dump rows, N2294 MassDriver dumpAccumulate} dumps còn lại + fill + fix — HOÀN TẤT + ĐÃ PUSH** (branch `integration/wave-advances-8-n2288-n2294`, base 2fcdc554; 7/7 slice xong + đã push: N2288 dca7c8d6, N2289 56cbb21e, N2290 e65bd685, N2291 847ac589, N2292 bddb98ef, N2293 a4c75553, N2294 b9d17508; 6 slice targeted 3/4 PASS + proof Godot-absent; N2290 fix slice targeted 3/4 (test N2280 đã sửa) + proof Godot-absent; SSOT gộp 11888/1743/1677/3146 (+33/+6/+7/+14 — slices +6 vì N2290 không có ledger entry; symbols +33 vượt scope +31 do N2291 thực +10 thay vì +8); DEFERRED gộp 321 (313 − 8 resolve/removed + 16 mới, merge theo entry TEXT); KHÔNG cần fix ở tích hợp; N2288: pure 5 keys (thêm dump_attempts), gọi static dump_accumulate_state trực tiếp (PortBridge là instance method), KHÔNG gate items.total() > 0 quanh accumulator; N2289: flag proof N2195 stale từ N2256 (multiplier 1.75 → 1.0, cần fix slice kiểu N2290); N2290: fix 1 dòng (:245 threshold = duration, bỏ / time_scale), GIỮ param time_scale (guard INF vẫn đọc); brief SAI 2 điểm — source_delta là UNSCALED Time.delta, elapsed VẪN accumulate ở time_scale 0 (no-fire nhờ guard INF); register N2290 build trên snapshot N2280-era (291) — merge LOẠI 39 remove + 17 re-add stale (N2277 repeat); N2291: 2 pure, frame GIỮ Vector2 pay_vector (proof N2233 pin), pure nói dict, convert ở boundary; move-in dùng SCALED delta; intake drop push cả 2 trường hợp (N2278); comment cũ cite PayloadBlock fields :94/:95/:96 sai — thực tế :92/:94/:95 (đã fix ở N2307); N2292: water-extractor attribute = Attribute.water, size 2, floating/placeableLiquid default false; trigger recompute mỗi enabled tick; N2293: dump statements :105–108 (brief :104–110), dump vô điều kiện THẬT (ngoài mọi gate), liquids.current() không bao giờ null; N2294: advance N2237 trả thêm state_after_switch (additive-only) — dump gate đọc state SAU switch; dump(Item) :1072-1114 (brief :1072-1113 thiếu `}`); full gate PID 7543 (03:03–03:24): Ran 6262 tests in 1223.176s, FAILED (failures=242, skipped=5), 0 errors — 242/242 Godot-absent `AssertionError: unexpectedly None` (236 thừa hưởng + 6 proof mới N2288/N2289/N2291/N2292/N2293/N2294; N2290 không thêm test)). Nợ Godot: 100 → 106 proofs + 2 re-run (N2196 + N2280) + 30 Windows-track (N2156–N2185, đã GREEN Linux).
- **Wave advances-9 {N2295 PayloadLoader acceptPayload, N2296 PayloadUnloader acceptPayload, N2297 PayloadDeconstructor acceptPayload + acceptUnitPayload, N2298 PayloadMassDriver acceptPayload, N2299 UnitAssemblerModule acceptPayload, N2300 BeamDrill N2195 proof fix, N2301 WallCrafter getEfficiency} acceptPayload rows + fix + fill — HOÀN TẤT + ĐÃ PUSH** (branch `integration/wave-advances-9-n2295-n2301`, base 9ca87a72; 7/7 slice xong + đã push: N2295 762ff9a1, N2296 14746b76, N2297 b03dbc84, N2298 ea7c5609, N2299 48d2bd72, N2300 0ae8a739, N2301 a78b498b; 6 slice targeted 3/4 PASS + proof Godot-absent; N2300 fix slice targeted 3/4 (test N2195 không đổi) + proof Godot-absent; SSOT gộp 11922/1749/1685/3162 (+34/+6/+8/+16, đúng kỳ vọng — slices +6 vì N2300 không có ledger entry); DEFERRED gộp 325 (321 − 8 resolve/removed + 12 mới, merge theo entry TEXT với base 321 gốc); 1 fix ở tích hợp: docstring register N2195 c36b0563 (claim stale "with no optional rows modeled yet" → hydrogen row live từ N2256); N2295: pure 5 keys, fits Java-exact (Payload.fits :50-52); N2296: **brief/SCOPE SAI về inheritance** — `PayloadUnloaderBuild extends PayloadLoaderBuild` (:32), gate thực là Loader override, entry 12 đúng từ đầu; pure N2295 + N2296 port cùng 1 Java method cho 2 driver (trùng logic đúng Java, không dedup); N2297: 2 pures (5+4 keys), super gate redundant AND lại đúng Java; N2298: cite entry 10 sai (:317-319 → :462-463); **cả 2 def thật override maxPayloadSize** (2.5f → 20, 4f → 32) — cần slice per-def threshold; N2299: 2 pures (4+5 keys), entry 51 sai 2 điểm (file ở units/, gate :110-111); quota qua arc `Mathf.round` (BIG_ENOUGH), không phải java Math.round; verdict any-match; N2300: chỉ LIVE tick stale (:92 → 1.0/0.5), :55/:60 KHÔNG sửa (toán pure đúng); thêm case hydrogen-seeded (key thứ 7); stamp facing_amount = 1 bắt buộc; N2301: BLOCK attributes (không reuse pure N2292), attribute :41 không phải :43; **⚠️ 2 proof cũ stale (N2223 + N2273)** — cần fix slice seed wall_edge_tiles; full gate PID 13482 (03:38–03:59): Ran 6286 tests in 1229.839s, FAILED (failures=248, skipped=5), 0 errors — 248/248 Godot-absent `AssertionError: unexpectedly None` (242 thừa hưởng + 6 proof mới N2295/N2296/N2297/N2298/N2299/N2301; N2300 không thêm test)). Nợ Godot: 106 → 112 proofs + 3 re-run (N2196 + N2280 + N2195) + 30 Windows-track (N2156–N2185, đã GREEN Linux).
- **Wave advances-10 {N2302 fix N2223 proof, N2303 fix N2273 proof, N2304 PMD per-def threshold, N2305 Fracker fraction fill, N2306 RepairTower live scan, N2307 cite cleanup, N2308 Deconstructor intake-gate wiring} fix + fill + wiring + cleanup — HOÀN TẤT + ĐÃ PUSH** (branch `integration/wave-advances-10-n2302-n2308`, base fa627ace; 7/7 slice xong + đã push: N2302 eb9c292b, N2303 51feaff4, N2304 a174435c, N2305 ab74a162, N2306 3c2d6629, N2307 2ee51c70, N2308 2726c503; 4 slice targeted 3/4 PASS + proof Godot-absent (N2304/N2305/N2306/N2308); N2302/N2303 fix slice targeted 3/4 (test không sửa) + proof Godot-absent; N2307 cleanup 11 module Ran 42 = 31 PASS + 11 proof; SSOT gộp 11933/1753/1688/3168 (+11/+4/+3/+6 — slices +4 vì N2308 có ledger entry shared-ownership; symbols +11: N2304 +3, N2305 +3, N2306 +5); DEFERRED gộp 325 (325 − 5 resolve/removed + 5 mới, merge theo entry TEXT); fix d516af80 — UAM register docstring stale note + spec Pump dump :180-182→:178-180 (N2088/N2090 + 2 dòng trùng) + spec N2291 + GOAL advances-8 bullet; N2302/N2303: seed wall_edge_tiles thay vì efficiency_factor (N2301 stamp ghi đè); N2304: pure MỚI for_def (N2298 test pin call string), helper per-def 2.5/4.0/3.0, catalog KHÔNG có maxPayloadSize; N2305: brief SAI về def — oil-extractor set attribute oil + baseEfficiency 0f → validTiles luôn 0, fraction = boost + env (LUÔN check def trong Blocks.java); N2306: within STRICT squared + hitSize/2 (brief gloss thiếu), entry 157 stale đã drop; N2307: 3 cites sai đã fix (PayloadBlock :92/:94/:95, Pump :178-180, UAM :28), drift tiền lệ manifest optional_mirror_fields + 27 return_type mirrors (không đổi totals); N2308: intake build descriptor từ incoming dict, missing block_size → reject, pushes N2291 nằm trong file PROOF (fixture +block_size, load-bearing); merge script DEFERRED sửa 2 lần (single-line repr + black-wrapped format → ast.parse); full gate run 2 Ran 6302 in 1216.770s, failures=252, skipped=5, 0 errors — 252/252 Godot-absent (248 inherited + 4 new proof tests N2304/N2305/N2306/N2308); run 1 (PID 20261) killed by VM restart #8 ~04:30, no footer (javalang reinstalled 0.13.0 04:31)). Nợ Godot: 112 → 116 proofs + 7 re-run (N2196 + N2280 + N2195 + N2223 + N2273 + N2298 + N2291) + 30 Windows-track (N2156–N2185, đã GREEN Linux).
- **Tiếp theo:** wave advances-11 (fix slice proof N2176 + N2213 + N2227 stale ozone + N2222 stale slag; Unloader intake-guard wiring; UAM handoff-gate wiring; Loader intake-guard wiring) → C08–C12 theo `DESIGN-frame-state-infra.md`
  (RepairTower live scan; frame items intake — Separator/ItemBridge/Constructor/
  ImpactReactor/Accelerator/projectors, cần design cho conveyor-delivery source;
  WallCrafter getEfficiency live fill; SolidPump live fraction fill; ItemBridge
  doDump; BeamDrill dump timer; RepairTurret literal-20 follow-up;
  PayloadDeconstructor deconstructing fill; acceptPayload rows; disabled
  early-return driver-wide slice; raw-delta audit) — xem `DESIGN-frame-state-infra.md` trong
  `~/workspace/mindustry-parallel/`.
- **KHÔNG chạy Godot ở VM này** (chỉ đạo user 2026-11-15, ưu tiên cao): mọi
  proof scene từ N2186 trở đi chỉ viết, chưa từng chạy ở đâu — ghi nợ ở §5,
  chờ agent Godot test.
- Repo làm việc là fork `Lasthope1508/mindustry-godot-transpiler`
  (`origin` = fork, `upstream` = `duynguyen16689/mindustry-godot-transpiler`).
  Local worktree: `~/workspace/mindustry-godot-transpiler`.

## 5. Nợ test Godot (Windows) — agent khác test, báo hoàn công sau

- **Nguyên tắc:** proof Godot của mỗi slice chạy trên Linux headless ở VM này
  là đủ điều kiện để push (Godot 4.6.2-stable Linux, build 71f334935, giống
  hệt build Windows 4.6.2). Chạy proof trên **Windows Godot là một track
  kiểm chứng riêng**, do agent khác đảm nhiệm (máy Windows admin-pc) — không
  chặn push, nhưng phải được ghi nợ ở đây và báo hoàn công sau.
  **Bổ sung 2026-11-15 (chỉ đạo user, ưu tiên cao, ghi đè nguyên tắc trên
  cho mọi slice từ N2186 trở đi): KHÔNG chạy Godot ở VM này nữa (cả headless
  lẫn MCP).** Proof scene chỉ viết, chưa từng chạy ở đâu; agent Godot do user
  giao sẽ test sau (Linux hoặc Windows đều được) — ghi nợ ở đây với đủ thông
  tin để agent đó làm tiếp mà không cần hỏi lại: tên scene, commit mang scene,
  số key, trạng thái "chờ agent Godot test", và lệnh chạy (targeted test với
  Godot 4.6.2 trên PATH, port 7777 trống).
- **Nợ đang mở (2026-11-13 ~12:11 +07):**
  - [x] N2148 `C07TurretPowerStatusProof` — Linux GREEN 09:35 (10 key).
    Scene tới Windows theo commit `9917082`. Đã chạy trên Windows Godot 2026-11-13 (PR #2, commit `b0a989c`): 48/48 test đạt, 10/10 scene matches=true — xem `docs/superpowers/reports/2026-11-13-windows-godot-n2146-n2155.md`.
  - [x] N2149 `C07BurstDrillPowerStatusProof` — Linux GREEN 10:50 (9 key).
    Scene tới Windows theo commit `ded31ea`. Đã chạy trên Windows Godot 2026-11-13 (PR #2, commit `b0a989c`): 48/48 test đạt, 10/10 scene matches=true — xem `docs/superpowers/reports/2026-11-13-windows-godot-n2146-n2155.md`.
  - [x] N2150 `C07SolidPumpPowerStatusProof` — Linux GREEN 11:5x (9 key).
    Scene tới Windows theo slice commit `765c2f3` (pushed ~12:2x, main
    `e605718`). Đã chạy trên Windows Godot 2026-11-13 (PR #2, commit `b0a989c`): 48/48 test đạt, 10/10 scene matches=true — xem `docs/superpowers/reports/2026-11-13-windows-godot-n2146-n2155.md`.
  - [x] N2151 `C07PointDefenseTurretPowerStatusProof` — Linux GREEN 12:45 (9 key).
    Scene tới Windows theo slice commit `b92a4ff` (pushed ~13:3x, main
    `4d23cd7`). Đã chạy trên Windows Godot 2026-11-13 (PR #2, commit `b0a989c`): 48/48 test đạt, 10/10 scene matches=true — xem `docs/superpowers/reports/2026-11-13-windows-godot-n2146-n2155.md`.
  - [x] N2152 `C07TractorBeamTurretPowerStatusProof` — Linux GREEN 13:55 (9 key).
    Scene tới Windows theo slice commit `4bba657` (pushed ~14:16, main
    `9e36cc0`). Đã chạy trên Windows Godot 2026-11-13 (PR #2, commit `b0a989c`): 48/48 test đạt, 10/10 scene matches=true — xem `docs/superpowers/reports/2026-11-13-windows-godot-n2146-n2155.md`.
  - [x] N2153 `C07FrackerPowerStatusProof` — Linux GREEN 14:40 (9 key).
    Scene tới Windows theo slice commit `07fa495` (pushed ~15:3x, main
    `ecf2641`). Đã chạy trên Windows Godot 2026-11-13 (PR #2, commit `b0a989c`): 48/48 test đạt, 10/10 scene matches=true — xem `docs/superpowers/reports/2026-11-13-windows-godot-n2146-n2155.md`.
  - [x] N2154 `C07MechanicalPumpPowerStatusProof` — Linux GREEN 16:23 (9 key).
    Scene tới Windows theo slice commit `f97c030` (pushed ~17:2x, main
    `4ff5936`). Đã chạy trên Windows Godot 2026-11-13 (PR #2, commit `b0a989c`): 48/48 test đạt, 10/10 scene matches=true — xem `docs/superpowers/reports/2026-11-13-windows-godot-n2146-n2155.md`.
  - [x] N2155 `C07BeamDrillPowerStatusProof` — Linux GREEN 17:45 (9 key).
    Scene tới Windows theo slice commit `ad1696f` (pushed ~18:3x, main
    `e4860fd`). Đã chạy trên Windows Godot 2026-11-13 (PR #2, commit `b0a989c`): 48/48 test đạt, 10/10 scene matches=true — xem `docs/superpowers/reports/2026-11-13-windows-godot-n2146-n2155.md`.
  - [ ] N2156 `C07MendProjectorPowerStatusProof` — Linux GREEN 19:09 (9 key).
    Scene tới Windows theo slice commit `fbe08f1` (pushed ~19:3x, main
    `0bf8a84`). Chưa chạy trên Windows Godot.
  - [ ] N2157 `C07OverdriveProjectorPowerStatusProof` — Linux GREEN 20:00 (9 key).
    Scene tới Windows theo slice commit `97f27f7` (pushed ~20:5x, main
    `d9ef566`). Chưa chạy trên Windows Godot.
  - [ ] N2158 `C07ForceProjectorPowerStatusProof` — Linux GREEN 21:15 (9 key).
    Scene tới Windows theo slice commit `5edf125` (pushed ~21:4x, main
    `1466f2c`). Chưa chạy trên Windows Godot.
  - [ ] N2159 `C07BaseShieldPowerStatusProof` — Linux GREEN 22:00 (9 key).
    Scene tới Windows theo slice commit `7fa573d` (pushed ~22:3x, main
    `1bc71df`). Chưa chạy trên Windows Godot.
  - [ ] N2160 `C07RegenProjectorPowerStatusProof` — Linux GREEN 23:05 (9 key).
    Scene tới Windows theo slice commit `4bc4f41` (pushed ~23:3x, main
    `c7dcb34`). Chưa chạy trên Windows Godot.
  - [ ] N2161 `C07ConstructorPowerStatusProof` — Linux GREEN 00:05 (9 key).
    Scene tới Windows theo slice commit `9593f78` (pushed ~00:3x, main
    `e64c7f9`). Chưa chạy trên Windows Godot.
  - [ ] N2162 `C07PayloadLoaderPowerStatusProof` — Linux GREEN 01:10 (9 key).
    Scene tới Windows theo slice commit `01a948f` (pushed ~01:3x, main
    `1a31cbd`). Chưa chạy trên Windows Godot.
  - [ ] N2163 `C07PayloadUnloaderPowerStatusProof` — Linux GREEN 02:13 (9 key).
    Scene tới Windows theo slice commit `373449b` (pushed ~02:3x, main
    `399a135`). Chưa chạy trên Windows Godot.
  - [ ] N2164 `C07PayloadMassDriverPowerStatusProof` — Linux GREEN 03:00 (9 key).
    Scene tới Windows theo slice commit `e656fc9` (pushed ~03:3x, main
    `409abf9`). Chưa chạy trên Windows Godot.
  - [ ] N2165 `C07UnitCargoLoaderPowerStatusProof` — Linux GREEN 04:05 (9 key).
    Scene tới Windows theo slice commit `abc46f4` (pushed ~04:3x, main
    `6ad08da`). Chưa chạy trên Windows Godot.
  - [ ] N2166 `C07PayloadDeconstructorPowerStatusProof` — Linux GREEN 05:0x (9 key).
    Scene tới Windows theo slice commit `a66fd4d` (pushed ~05:3x, main
    `2386113`). Chưa chạy trên Windows Godot.
  - [ ] N2167 `C07UnitFactoryPowerStatusProof` — Linux GREEN 06:15 (9 key).
    Scene tới Windows theo slice commit `604323b` (pushed ~06:4x, main
    `65e3b81`). Chưa chạy trên Windows Godot.
  - [ ] N2168 `C07UnitAssemblerModulePowerStatusProof` — Linux GREEN 07:14 (9 key).
    Scene tới Windows theo slice commit `f4353a1` (pushed ~07:5x, main
    `6eafa41`). Chưa chạy trên Windows Godot.
  - [ ] N2169 `C07SeparatorPowerStatusProof` — Linux GREEN 08:20 (9 key).
    Scene tới Windows theo slice commit `0bcec1e` (pushed ~09:2x, main
    `05d2011`). Chưa chạy trên Windows Godot.
  - [ ] N2170 `C07WallCrafterPowerStatusProof` — Linux GREEN 09:50 (9 key).
    Scene tới Windows theo slice commit `c1a85e9` (pushed ~10:2x, main
    `af82d58`). Chưa chạy trên Windows Godot.
  - [ ] N2171 `C07MassDriverPowerStatusProof` — Linux GREEN 10:52 (9 key).
    Scene tới Windows theo slice commit `2451250` (pushed ~11:3x, main
    `734e636`). Chưa chạy trên Windows Godot.
  - [ ] N2172 `C07LaunchPadPowerStatusProof` — Linux GREEN 12:18 (9 key).
    Scene tới Windows theo slice commit `cf2dbbe` (pushed ~13:2x, main
    `decebb7`). Chưa chạy trên Windows Godot.
  - [ ] N2173 `C07RadarPowerStatusProof` — Linux GREEN 13:5x (9 key).
    Scene tới Windows theo slice commit `7690efd` (pushed ~15:2x, main
    `fa58b0b`). Chưa chạy trên Windows Godot.
  - [ ] N2174 `C07RepairTurretPowerStatusProof` — Linux GREEN 16:0x (9 key).
    Scene tới Windows theo slice commit `bbfb461` (pushed ~16:3x, main
    `385f111`). Chưa chạy trên Windows Godot.
  - [ ] N2175 `C07ShieldWallPowerStatusProof` — Linux GREEN 17:2x (9 key).
    Scene tới Windows theo slice commit `8eb09d5` (pushed ~18:2x, main
    `0b96491`). Chưa chạy trên Windows Godot.
  - [ ] N2176 `C07RepairTowerPowerStatusProof` — Linux GREEN 19:0x (9 key).
    Scene tới Windows theo slice commit `5eadd36` (pushed ~19:5x, main
    `a0cb7fb`). Chưa chạy trên Windows Godot.
  - [ ] N2177 `C07ShockwaveTowerPowerStatusProof` — Linux GREEN 20:40 (9 key).
    Scene tới Windows theo slice commit `444aa04` (pushed ~21:3x, main
    `714544a`). Chưa chạy trên Windows Godot.
  - [ ] N2178 `C07ItemBridgePowerStatusProof` — Linux GREEN 22:40 (9 key).
    Scene tới Windows theo slice commit `6b99e27` (pushed ~23:1x, main
    `f3ebec5`). Chưa chạy trên Windows Godot.
  - [ ] N2179 `C07LiquidBridgePowerStatusProof` — Linux GREEN 23:3x (9 key).
    Scene tới Windows theo slice commit `901f181` (pushed ~00:4x, main
    `a2d644e`). Chưa chạy trên Windows Godot.
  - [ ] N2180 `C07StackConveyorPowerStatusProof` — Linux GREEN 01:0x (9 key).
    Scene tới Windows theo slice commit `7c3b67e` (pushed ~02:1x, main
    `df55fef`). Chưa chạy trên Windows Godot.
  - [ ] N2181 `C07StackRouterPowerStatusProof` — Linux GREEN 02:35 (9 key).
    Scene tới Windows theo slice commit `73f7fc3` (pushed ~03:2x, main
    `ec45a65`). Chưa chạy trên Windows Godot.
  - [ ] N2182 `C07ImpactReactorPowerStatusProof` — Linux GREEN 03:5x (9 key).
    Scene tới Windows theo slice commit `c53013f` (pushed ~04:5x, main
    `c2e182a`). Chưa chạy trên Windows Godot.
  - [ ] N2183 `C07AcceleratorPowerStatusProof` — Linux GREEN 05:2x (9 key).
    Scene tới Windows theo slice commit `fc5b03a` (pushed ~06:1x, main
    `e68facf`). Chưa chạy trên Windows Godot.
  - [ ] N2184 `C07BuildTurretPowerStatusProof` — Linux GREEN 06:4x (9 key).
    Scene tới Windows theo slice commit `5dfba6e` (pushed ~07:3x, main
    `7c6edd5`). Chưa chạy trên Windows Godot.
  - [ ] N2185 `C07LightBlockPowerStatusProof` — Linux GREEN 08:1x (9 key).
    Scene tới Windows theo slice commit `ffe1153` (pushed ~08:5x, main
    `1c161f8`). Chưa chạy trên Windows Godot.
  - [ ] N2188 `C07ItemBridgeShouldConsumeProof` — CHƯA CHẠY ở đâu (6 key:
    `gate_open_with_valid_link`, `gate_closed_when_unlinked`,
    `gate_closed_when_disabled`, `gate_reads_previous_tick_link`,
    `efficiency_zero_when_gate_closed`, `efficiency_kept_when_gate_open`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `c490f99e` trên
    `slice/N2188-item-bridge-should-consume` (integration cherry-pick `9de01cd5`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_item_bridge_should_consume` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2197 `C07ItemBridgeLinkFrameStateProof` — CHƯA CHẠY ở đâu (6 key:
    `link_defaults_to_minus_one`, `configure_point2_sets_relative_link`,
    `configure_integer_sets_absolute_link`,
    `link_valid_same_row_within_range`,
    `link_invalid_when_double_or_out_of_range`,
    `live_tick_recomputes_had_valid_link`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo commit `6a094cda` trên
    `integration/n2197-item-bridge-link` (slice gốc `bd07c93d` trên
    `slice/N2197-item-bridge-link-frame-state`; report/handoff/spec line
    khôi phục ở docs commit wave second-consumers-2 — docs commit gốc
    `ab84d2cf` không nằm trên line này nên entry này đã thiếu từ unification).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_item_bridge_link_frame_state` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2198 `C07LiquidBridgeShouldConsumeProof` — CHƯA CHẠY ở đâu (6 key:
    `gate_true_with_valid_link`, `gate_false_when_unlinked`,
    `gate_false_when_disabled`, `efficiency_zero_when_gate_false`,
    `efficiency_folds_power_when_gate_true`, `live_tick_recomputes_had_valid_link`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `ffe78c85` trên
    `slice/N2198-liquid-bridge-should-consume` (integration cherry-pick `aa271fcd`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_liquid_bridge_should_consume` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2199 `C07ItemBridgeAutoLinkProof` — CHƯA CHẠY ở đâu (8 key:
    `find_link_finds_unlinked_last_build`,
    `find_link_rejects_linked_or_same_tile`,
    `player_placed_configures_partner`,
    `player_placed_skips_adjacent_partner`,
    `player_placed_skips_when_already_linked`,
    `player_placed_updates_last_build_without_partner`,
    `live_placement_auto_links_and_updates_last_build`,
    `live_liquid_placement_auto_links`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `44fd1a77` trên
    `slice/N2199-item-bridge-auto-link`.
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_item_bridge_auto_link` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2200 `C07SeparatorShouldConsumeProof` — CHƯA CHẠY ở đâu (6 key:
    `gate_true_below_capacity`, `gate_false_when_full`,
    `gate_false_when_disabled`, `buffer_cons_items_subtracted`,
    `efficiency_zero_when_gate_false`, `efficiency_folds_power_when_gate_true`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `99822420` trên
    `slice/N2200-separator-should-consume` (integration cherry-pick `437667c4`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_separator_should_consume` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2201 `C07WallCrafterShouldConsumeProof` — CHƯA CHẠY ở đâu (6 key:
    `gate_true_below_capacity`, `gate_false_at_capacity`,
    `gate_ignores_enabled`, `large_def_capacity_twenty`,
    `efficiency_zero_when_gate_false`, `efficiency_folds_power_when_gate_true`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `a2a27ded` trên
    `slice/N2201-wall-crafter-should-consume` (integration cherry-pick `42020bbb`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_wall_crafter_should_consume` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2202 `C07BeamDrillShouldConsumeProof` — CHƯA CHẠY ở đâu (6 key:
    `gate_true_when_all_three_conditions`, `gate_false_when_items_full`,
    `gate_false_when_no_facing`, `gate_false_when_disabled`,
    `efficiency_zero_when_gate_false`, `efficiency_folds_power_when_gate_true`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `41ee66e0` trên
    `slice/N2202-beam-drill-should-consume` (integration cherry-pick `8e922c31`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_beam_drill_should_consume` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2203 `C07BurstDrillShouldConsumeProof` — CHƯA CHẠY ở đâu (6 key:
    `gate_open_below_threshold`, `gate_open_at_boundary`,
    `gate_closed_when_over_threshold`, `gate_closed_when_disabled`,
    `efficiency_zero_when_gate_closed`, `efficiency_kept_when_gate_open`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `4e249a60` trên
    `slice/N2203-burst-drill-should-consume` (integration cherry-pick `04438b4c`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_burst_drill_should_consume` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2204 `C07DrillShouldConsumeProof` — CHƯA CHẠY ở đâu (6 key:
    `gate_open_when_items_below_capacity`, `gate_closed_when_items_full`,
    `gate_closed_when_no_dominant_item`, `gate_closed_when_disabled`,
    `efficiency_zero_when_gate_closed`, `efficiency_kept_when_gate_open`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `c9651592` trên
    `slice/N2204-drill-should-consume` (integration cherry-pick `df565569`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_drill_should_consume` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2205 `C07MechanicalPumpShouldConsumeProof` — CHƯA CHẠY ở đâu (6 key:
    `gate_open_when_liquid_below_capacity`, `gate_closed_when_liquids_full`,
    `gate_closed_when_no_liquid_drop`, `gate_closed_when_disabled`,
    `efficiency_zero_when_gate_closed`, `efficiency_kept_when_gate_open`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `882ccb3e` trên
    `slice/N2205-mechanical-pump-should-consume` (integration cherry-pick `06e8b692`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_mechanical_pump_should_consume` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2206 `C07SolidPumpShouldConsumeProof` — CHƯA CHẠY ở đâu (6 key:
    `gate_true_below_capacity`, `gate_false_at_capacity`,
    `gate_ignores_enabled`, `efficiency_zero_when_gate_false`,
    `efficiency_folds_power_when_gate_true`, `def_constant_water_capacity_forty`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `6a85eed2` trên
    `slice/N2206-solid-pump-should-consume` (integration cherry-pick `26a9afe0`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_solid_pump_should_consume` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2207 `C07FrackerShouldConsumeProof` — CHƯA CHẠY ở đâu (6 key:
    `gate_true_below_capacity`, `gate_false_at_capacity`,
    `gate_ignores_enabled`, `efficiency_zero_when_gate_false`,
    `efficiency_folds_power_when_gate_true`, `def_constant_oil_capacity_forty`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `5342006a` trên
    `slice/N2207-fracker-should-consume` (integration cherry-pick `8bb5f81e`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_fracker_should_consume` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2208 `C07PayloadLoaderShouldConsumeProof` — CHƯA CHẠY ở đâu (6 key:
    `gate_true_with_payload`, `gate_false_without_payload`,
    `gate_ignores_enabled`, `efficiency_zero_when_gate_false`,
    `efficiency_folds_power_when_gate_true`,
    `def_payload_loader_consume_power_two_size_three`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `fcb9ff15` trên
    `slice/N2208-payload-loader-should-consume` (integration cherry-pick `88b92d1f`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_payload_loader_should_consume` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2209 `C07PayloadUnloaderShouldConsumeProof` — CHƯA CHẠY ở đâu (6 key:
    `gate_true_with_payload`, `gate_false_without_payload`,
    `gate_ignores_enabled`, `efficiency_zero_when_gate_false`,
    `efficiency_folds_power_when_gate_true`,
    `def_payload_unloader_consume_power_two_size_three`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `cb77521d` trên
    `slice/N2209-payload-unloader-should-consume` (integration cherry-pick `d9e2df14`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_payload_unloader_should_consume` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2210 `C07PayloadDeconstructorShouldConsumeProof` — CHƯA CHẠY ở đâu (6 key:
    `gate_true_when_deconstructing_and_enabled`,
    `gate_false_when_no_deconstructing`, `gate_false_when_disabled`,
    `frame_key_default_null`, `efficiency_zero_when_gate_false`,
    `efficiency_folds_power_when_gate_true`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `ba3f6bbd` trên
    `slice/N2210-payload-deconstructor-should-consume` (integration cherry-pick `1abaed7c`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_payload_deconstructor_should_consume` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2211 `C07UnitCargoLoaderShouldConsumeProof` — CHƯA CHẠY ở đâu (6 key:
    `gate_true_when_unit_null`, `gate_false_when_unit_present`,
    `gate_independent_of_enabled`, `efficiency_zero_when_gate_false`,
    `efficiency_folds_power_when_gate_true`, `frame_unit_default_null`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `1ee8ae0e` trên
    `slice/N2211-unit-cargo-loader-should-consume` (integration cherry-pick `5a9805f5`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_unit_cargo_loader_should_consume` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2212 `C07RepairTurretShouldConsumeProof` — CHƯA CHẠY ở đâu (6 key:
    `gate_true_when_target_present`, `gate_false_when_target_null`,
    `gate_false_when_disabled`, `efficiency_zero_when_gate_false`,
    `efficiency_folds_power_when_gate_true`, `frame_target_default_null`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `96de3ef1` trên
    `slice/N2212-repair-turret-should-consume` (integration cherry-pick `f6b4a044`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_repair_turret_should_consume` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2213 `C07RepairTowerShouldConsumeProof` — CHƯA CHẠY ở đâu (6 key:
    `gate_true_when_targets_nonempty`, `gate_false_when_targets_empty`,
    `gate_independent_of_enabled`, `efficiency_zero_when_gate_false`,
    `efficiency_folds_power_when_gate_true`, `frame_targets_default_empty`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `30fd7965` trên
    `slice/N2213-repair-tower-should-consume` (integration cherry-pick `cbaec851`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_repair_tower_should_consume` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2214 `C07RegenProjectorShouldConsumeProof` — CHƯA CHẠY ở đâu (6 key:
    `gate_true_when_any_targets`, `gate_false_when_no_targets`,
    `gate_independent_of_enabled`, `efficiency_zero_when_gate_false`,
    `efficiency_folds_power_when_gate_true`, `frame_any_targets_default_false`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `71e4e8ab` trên
    `slice/N2214-regen-projector-should-consume` (integration cherry-pick `49fbcec3`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_regen_projector_should_consume` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2215 `C07BuildTurretShouldConsumeProof` — CHƯA CHẠY ở đâu (6 key:
    `gate_true_when_plans_nonempty`, `gate_false_when_plans_empty`,
    `gate_false_when_heal_suppressed`, `efficiency_zero_when_gate_false`,
    `efficiency_folds_power_when_gate_true`, `frame_plans_default_empty`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `4a873633` trên
    `slice/N2215-build-turret-should-consume` (integration cherry-pick `ff6e85c9`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_build_turret_should_consume` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2216 `C07ConstructorShouldConsumeProof` — CHƯA CHẠY ở đâu (6 key:
    `gate_true_when_recipe_present`, `gate_false_when_recipe_null`,
    `gate_false_when_disabled`, `efficiency_zero_when_gate_false`,
    `efficiency_folds_power_when_gate_true`, `frame_recipe_default_null`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `0cf6ed6c` trên
    `slice/N2216-block-producer-should-consume` (integration cherry-pick `2f9641e6`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_constructor_should_consume` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2217 `C07PointDefenseTurretShouldConsumeProof` — CHƯA CHẠY ở đâu (6 key:
    `gate_true_when_target_present`, `gate_false_when_target_null`,
    `gate_false_when_disabled`, `efficiency_zero_when_gate_false`,
    `efficiency_folds_power_when_gate_true`, `frame_target_default_null`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `dc2efa45` trên
    `slice/N2217-point-defense-turret-should-consume` (integration cherry-pick `d0fc7ee7`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_point_defense_turret_should_consume` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2218 `C07TractorBeamTurretShouldConsumeProof` — CHƯA CHẠY ở đâu (6 key:
    `gate_true_when_target_present`, `gate_false_when_target_null`,
    `gate_false_when_disabled`, `efficiency_zero_when_gate_false`,
    `efficiency_folds_power_when_gate_true`, `frame_target_default_null`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `cecb074e` trên
    `slice/N2218-tractor-beam-turret-should-consume` (integration cherry-pick `929e276e`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_tractor_beam_turret_should_consume` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2219 `C07BurstDrillUpdateTileProof` — CHƯA CHẠY ở đâu (6 key:
    `progress_advances_when_efficient`, `warmup_approaches_progress_ratio`,
    `offload_at_drill_time`, `invert_time_set_on_offload`,
    `last_drill_speed_zero_when_blocked`, `live_tick_advances_progress`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `c48e365b` trên
    `slice/N2219-burst-drill-update-tile` (integration cherry-pick `97a5be46`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_burst_drill_update_tile` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2220 `C07SolidPumpUpdateTileProof` — CHƯA CHẠY ở đâu (6 key:
    `max_pump_folds_fraction_efficiency`, `last_pump_rate_from_max_pump`,
    `warmup_approaches_one_when_pumping`, `pump_time_advances_with_warmup`,
    `no_pump_when_full`, `frame_defaults_zero`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `bd8b7dc0` trên
    `slice/N2220-solid-pump-update-tile` (integration cherry-pick `5c84850b`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_solid_pump_update_tile` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2221 `C07MechanicalPumpUpdateTileProof` — CHƯA CHẠY ở đâu (6 key:
    `max_pump_capped_by_remaining_capacity`, `warmup_approaches_one_when_pumping`,
    `total_progress_advances_with_warmup`, `cons_timer_advances_and_wraps`,
    `no_pump_without_liquid_drop`, `live_tick_pumps_and_advances_warmup`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `439604f7` trên
    `slice/N2221-pump-update-tile` (integration cherry-pick `e94b044a`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_mechanical_pump_update_tile` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2222 `C07SeparatorUpdateTileProof` — CHƯA CHẠY ở đâu (6 key:
    `progress_advances_when_efficient`, `warmup_approaches_one_when_efficient`,
    `total_progress_advances_with_warmup`, `craft_completes_at_progress_one`,
    `offload_picks_weighted_result`, `live_tick_advances_progress_and_warmup`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `34861097` trên
    `slice/N2222-separator-update-tile` (integration cherry-pick `f26f7498`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_separator_update_tile` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2223 `C07WallCrafterUpdateTileProof` — CHƯA CHẠY ở đâu (6 key:
    `warmup_approaches_one_when_efficient`, `time_advances_with_eff_and_edelta`,
    `offload_at_drill_time`, `last_efficiency_folds_eff_timescale`,
    `total_time_advances_with_warmup`, `live_tick_advances_warmup_and_time`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `1827aaf6` trên
    `slice/N2223-wall-crafter-update-tile` (integration cherry-pick `c1ed1449`).
    **Scene đã UPDATE bởi fix N2302 (commit `eb9c292b` trên `slice/N2302-wall-crafter-n2223-proof-fix`): live-tick seed giờ là wall_edge_tiles (2 tiles × 0.5 = 1.0) thay vì efficiency_factor trực tiếp — chạy proof với scene MỚI (re-run).**
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_wall_crafter_update_tile` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2224 `C07FrackerUpdateTileProof` — CHƯA CHẠY ở đâu (6 key:
    `accumulator_advances_with_efficiency`, `consume_at_item_use_time`,
    `super_advance_pumps_oil`, `warmup_decays_when_no_efficiency`,
    `last_pump_zero_when_idle`, `frame_defaults_zero`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `46f65f31` trên
    `slice/N2224-fracker-update-tile` (integration cherry-pick `94be3ec4`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_fracker_update_tile` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2225 `C07ItemBridgeTransportProof` — CHƯA CHẠY ở đâu (6 key:
    `transport_counter_charges_with_edelta`,
    `handoff_at_transport_time`, `item_returns_when_partner_rejects`,
    `warmup_approaches_efficiency_when_linked`,
    `warmup_zero_when_unlinked`, `incoming_prunes_dead_links`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `5396a786` trên
    `slice/N2225-item-bridge-transport` (integration cherry-pick `7d2dfd87`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_item_bridge_transport` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2226 `C07RepairTurretUpdateTileProof` — CHƯA CHẠY ở đâu (6 key:
    `target_clears_when_dead_or_out_of_range`,
    `rotation_slerps_toward_target`, `strength_approaches_one_when_healing`,
    `heal_amount_folds_repair_speed_strength`,
    `reacquire_picks_closest_damaged_candidate`,
    `live_tick_writes_advance_frame_keys`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `04494ee9` trên
    `slice/N2226-repair-turret-update-tile` (integration cherry-pick `865eab15`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_repair_turret_update_tile` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2227 `C07RepairTowerUpdateTileProof` — CHƯA CHẠY ở đâu (6 key:
    `refresh_clears_targets_at_interval`,
    `warmup_approaches_efficiency_when_healing`,
    `warmup_zero_when_suppressed`, `total_progress_advances`,
    `heal_amounts_fold_heal_amount_edelta`, `frame_defaults_zero`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `0a768d68` trên
    `slice/N2227-repair-tower-update-tile` (integration cherry-pick `b97dd2d5`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_repair_tower_update_tile` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2228 `C07RegenProjectorUpdateTileProof` — CHƯA CHẠY ở đâu (6 key:
    `any_targets_folds_damaged_targets`, `mend_map_accumulates_heal_amount`,
    `warmup_approaches_one_when_regen`, `optional_timer_advances_and_resets`,
    `no_heal_when_suppressed`, `live_tick_advances_regen_frame`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `d84414e8` trên
    `slice/N2228-regen-projector-update-tile` (integration cherry-pick `741652ea`
    + coordinator fix `f240da22` đổi frame key `suppressed` →
    `heal_suppressed`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_regen_projector_update_tile` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2229 `C07PointDefenseUpdateTileProof` — CHƯA CHẠY ở đâu (7 key:
    `retarget_picks_closest_hittable_bullet`, `pooled_target_clears`,
    `rotation_moves_toward_target`, `reload_counter_charges_and_fires`,
    `shot_reduces_bullet_damage`, `shot_removes_weak_bullet`,
    `live_tick_writes_advance_frame_keys`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `bee50025` trên
    `slice/N2229-point-defense-update-tile` (integration cherry-pick `c024a31e`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_point_defense_turret_update_tile` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2230 `C07TractorBeamUpdateTileProof` — CHƯA CHẠY ở đâu (8 key:
    `retarget_picks_closest_flying_enemy`, `priority_beats_distance`,
    `rotation_moves_and_strength_rises`, `impulse_folds_force_and_range`,
    `coolant_consume_folds_heat_capacity`, `strength_decays_without_target`,
    `activation_timer_blocks_update`, `live_tick_writes_advance_frame_keys`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `57ec6873` trên
    `slice/N2230-tractor-beam-update-tile` (integration cherry-pick `1b785fdb`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_tractor_beam_update_tile` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2231 `C07PayloadLoaderUpdateTileProof` — CHƯA CHẠY ở đâu (6 key:
    `move_in_arrives_at_center`, `load_items_on_timer_tick`,
    `load_liquids_folds_edelta`, `battery_charges_and_exports_when_full`,
    `should_export_folds_flags`, `move_out_pushes_payload`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `d8f2a916` trên
    `slice/N2231-payload-loader-update-tile` (integration cherry-pick `39b24a9d`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_payload_loader_update_tile` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2232 `C07PayloadUnloaderUpdateTileProof` — CHƯA CHẠY ở đâu (7 key:
    `move_in_arrives_at_center`, `unload_items_on_timer_tick`,
    `unload_liquids_folds_edelta`, `battery_unloads_to_last_output_power`,
    `instant_deconstruct_clears_payload`, `move_out_pushes_payload`,
    `live_tick_advances_unloader_frame`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `76ecc3b5` trên
    `slice/N2232-payload-unloader-update-tile` (integration cherry-pick `195077bd`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_payload_unloader_update_tile` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2233 `C07PayloadDeconstructorUpdateTileProof` — CHƯA CHẠY ở đâu (7 key:
    `progress_advances_with_edelta`, `accum_folds_requirements`,
    `transfer_moves_whole_items`, `finish_clears_deconstructing`,
    `intake_moves_payload_to_deconstructing`, `progress_zero_without_deconstructing`,
    `live_tick_advances_progress`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `1b5264f8` trên
    `slice/N2233-payload-deconstructor-update-tile` (integration cherry-pick `8040e691`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_payload_deconstructor_update_tile` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2234 `C07UnitCargoLoaderUpdateTileProof` — CHƯA CHẠY ở đâu (6 key:
    `lost_unit_clears`, `readyness_folds_unit_presence`,
    `warmup_approaches_efficiency`, `build_progress_advances_when_empty`,
    `spawn_at_build_complete`, `live_tick_advances_cargo_frame`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `a0b5eac9` trên
    `slice/N2234-unit-cargo-loader-update-tile` (integration cherry-pick `e246e650`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_unit_cargo_loader_update_tile` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2235 `C07ForceProjectorUpdateTileProof` — CHƯA CHẠY ở đâu (6 key:
    `broken_sets_at_shield_health`, `buildup_cools_down`,
    `deflect_absorbs_bullet_in_polygon`, `live_tick_writes_advance_frame_keys`,
    `phase_heat_tracks_booster`, `radscl_follows_warmup`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `fb0ed566` trên
    `slice/N2235-force-projector-update-tile` (integration cherry-pick `4fdfa9ad`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_force_projector_update_tile` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2236 `C07BaseShieldUpdateTileProof` — CHƯA CHẠY ở đâu (6 key:
    `absorb_blocks_enemy_bullet`, `absorb_ignores_same_team`,
    `live_tick_writes_advance_frame_keys`, `no_repel_outside_radius`,
    `repel_pushes_enemy_unit`, `smooth_radius_tracks_efficiency`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `bfb1f442` trên
    `slice/N2236-base-shield-update-tile` (integration cherry-pick `ff8f6220`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_base_shield_update_tile` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2237 `C07MassDriverUpdateTileProof` — CHƯA CHẠY ở đâu (6 key:
    `reload_counter_decays`, `idle_accepts_waiting_shooter`,
    `shooting_registers_on_link`, `fire_transfers_items_and_resets_reload`,
    `no_fire_without_alignment`, `live_tick_writes_advance_frame_keys`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `0b79b770` trên
    `slice/N2237-mass-driver-update-tile` (integration cherry-pick `47fac343`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_mass_driver_update_tile` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2238 `C07LaunchPadUpdateTileProof` — CHƯA CHẠY ở đâu (6 key:
    `launch_clears_items_and_resets`, `launch_counter_advances_with_edelta`,
    `launch_fires_when_full_and_timed`, `live_tick_writes_advance_frame_keys`,
    `no_launch_before_launch_time`, `no_launch_when_not_full`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `1ed044a3` trên
    `slice/N2238-launch-pad-update-tile` (integration cherry-pick `624ae329`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_launch_pad_update_tile` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2239 `C07StackConveyorUpdateTileProof` — CHƯA CHẠY ở đâu (6 key:
    `cooldown_reels_with_speed_eff_delta`, `disabled_still_reels_but_not_transfers`,
    `live_tick_writes_advance_frame_keys`, `no_transfer_without_link`,
    `transfer_moves_all_items_to_front`, `unload_drains_last_item`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `c78168a7` trên
    `slice/N2239-stack-conveyor-update-tile` (integration cherry-pick `2ad1a270`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_stack_conveyor_update_tile` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2240 `C07StackRouterUpdateTileProof` — CHƯA CHẠY ở đâu (6 key:
    `current_picks_first_item`, `empty_resets_unloading`,
    `handoff_drains_current_item`, `live_tick_writes_advance_frame_keys`,
    `progress_charges_when_full`, `unloading_starts_at_cap`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `4fb9f447` trên
    `slice/N2240-stack-router-update-tile` (integration cherry-pick `e31f88e0`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_stack_router_update_tile` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2241 `C07LightBlockUpdateTileProof` — CHƯA CHẠY ở đâu (8 key,
    gộp với N2189 ở unification `00e6588b`:
    `smooth_time_lerp_delta_step`, `smooth_time_holds_at_time_scale`,
    `smooth_time_decays_when_time_scale_drops`,
    `smooth_time_converges_after_ticks`, `light_radius_clamps_at_two`,
    `frame_defaults_to_java_initial`,
    `live_tick_writes_advance_frame_keys`, `power_status_row_unchanged`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `341b9bc5` trên
    `slice/N2241-light-block-update-tile` (integration cherry-pick `2215a10b`),
    gộp với batch N2189 (`8803e1e7`) ở unification commit `00e6588b` trên
    `integration/unification-batch-1-3` — N2189 không cộng nợ mới.
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_light_block_update_tile` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2186 `C07LaunchPadShouldConsumeProof` — CHƯA CHẠY ở đâu (6 key:
    `gate_open_below_launch_time`, `gate_closed_at_launch_time`,
    `gate_closed_above_launch_time`, `counter_advances_by_edelta`,
    `efficiency_kept_when_gate_open`, `efficiency_zero_when_gate_closed`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo unification commit `5726e0ee` trên
    `integration/unification-batch-1-3` (batch slice `879fa13e`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_launch_pad_should_consume` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2187 `C07ShockwaveTowerShouldConsumeProof` — CHƯA CHẠY ở đâu (6 key:
    `gate_true_below_reload`, `gate_false_at_reload`,
    `gate_false_above_reload`, `efficiency_zero_when_gate_false`,
    `efficiency_folds_power_when_gate_true`,
    `reload_counter_advances_by_edelta`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo unification commit `20a08fbf` trên
    `integration/unification-batch-1-3` (batch slice `b69ba59d`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_shockwave_tower_should_consume` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2190 `C07RadarUpdateTileProof` — CHƯA CHẠY ở đâu (6 key:
    `smooth_efficiency_lerps_to_efficiency`,
    `progress_advances_edelta_over_discovery`, `progress_clamps_at_one`,
    `total_progress_accumulates`, `last_radius_updates_on_fog_change`,
    `live_tick_advances_and_keeps_power_row`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo unification commit `bea4d312` trên
    `integration/unification-batch-1-3` (batch slice `6baeb7bc`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_radar_update_tile` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2191 `C07AcceleratorUpdateTileProof` — CHƯA CHẠY ở đâu (6 key:
    `heat_lerps_toward_efficiency`, `status_lerp_tracks_power_status`,
    `launch_heat_lerps_by_launching`, `time_advances_and_slerps`,
    `progress_advances_and_clamps`, `live_tick_advances_and_folds_power`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo unification commit `01e599d9` trên
    `integration/unification-batch-1-3` (batch slice `fafe334f`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_accelerator_update_tile` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2192 `C07ImpactReactorUpdateTileProof` — CHƯA CHẠY ở đâu (6 key:
    `warmup_rises_toward_one`, `warmup_snaps_to_one`,
    `warmup_decays_toward_zero`, `total_progress_advances`,
    `production_efficiency_pow_five`,
    `live_tick_keeps_power_row_and_advances`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo unification commit `c1d8e762` trên
    `integration/unification-batch-1-3` (batch slice `52e3b178`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_impact_reactor_update_tile` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2193 `C07MendProjectorUpdateTileProof` — CHƯA CHẠY ở đâu (6 key:
    `smooth_efficiency_lerps_to_efficiency`,
    `heat_lerps_by_efficiency_and_can_heal`,
    `charge_advances_by_heat_delta`, `charge_resets_at_reload`,
    `phase_heat_lerps_to_optional_efficiency`, `efficiency_folds_power_min`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo unification commit `5478286e` trên
    `integration/unification-batch-1-3` (batch slice `d8dce467`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_mend_projector_update_tile` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2194 `C07OverdriveProjectorUpdateTileProof` — CHƯA CHẠY ở đâu (6 key:
    `smooth_efficiency_heat_lerp_toward_efficiency`,
    `charge_advances_and_resets_at_reload`,
    `phase_heat_lerps_when_has_boost`, `phase_heat_frozen_without_boost`,
    `use_progress_advances_and_wraps`,
    `live_tick_advances_frame_and_preserves_power`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo unification commit `ed52a099` trên
    `integration/unification-batch-1-3` (batch slice `2723e795`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_overdrive_projector_update_tile` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2195 `C07BeamDrillUpdateTileProof` — CHƯA CHẠY ở đâu (7 key:
    `warmup_approaches_one_when_powered`, `warmup_decays_to_zero_without_power`,
    `boost_warmup_lerps_to_optional_efficiency`,
    `multiplier_lerps_boost_intensity`, `time_advances_by_edelta_times_multiplier`,
    `live_tick_advances_warmup_and_time`, `live_tick_with_hydrogen_pins_boost_values`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo unification commit `d7512292` trên
    `integration/unification-batch-1-3` (batch slice `c42968e1`).
    **Scene đã UPDATE bởi fix N2300 (commit `0ae8a739` trên
    `slice/N2300-beam-drill-n2195-proof-fix`): live tick giờ pin multiplier 1.0 /
    time 0.5 khi không có hydrogen (N2256 fold), thêm case hydrogen-seeded pin
    1.75/0.875 — chạy proof với scene MỚI (re-run, nợ Godot thứ 3 cùng N2196 +
    N2280).**
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_beam_drill_update_tile` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2242 `C07MendProjectorHealScanProof` — CHƯA CHẠY ở đâu (6 key:
    `real_range_folds_phase_heat`, `heal_amount_formula`,
    `damaged_only_predicate`, `heal_suppressed_excluded`,
    `no_scan_below_reload`, `live_tick_scans_when_charged`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `b0bc1971` trên
    `slice/N2242-mend-projector-heal-scan` (integration cherry-pick `ac09e99f`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_mend_projector_heal_scan` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2243 `C07BuildTurretUpdateTileProof` — CHƯA CHẠY ở đâu (6 key:
    `rotation_follows_unit`, `look_at_when_building`,
    `suppression_zeroes_efficiency`, `multipliers_scale_with_potential`,
    `warmup_lerps_when_building`, `warmup_decays_when_idle`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `aaaf97ff` trên
    `slice/N2243-build-turret-update-tile` (integration cherry-pick `f1ed1729`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_build_turret_update_tile` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2244 `C07BuildTurretPlanLogicProof` — CHƯA CHẠY ở đâu (6 key:
    `follower_validation_clears_invalid`, `plan_search_picks_in_range`,
    `plan_search_rotates_queue`, `mimic_follows_nearby_builder`,
    `invalid_plan_discarded`, `suicide_plan_removed`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `f0077463` trên
    `slice/N2244-build-turret-plan-logic` (integration cherry-pick `340cec5d`,
    merge tay driver BuildTurret).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_build_turret_plan_logic` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2245 `C07PayloadMassDriverUpdateTileProof` — CHƯA CHẠY ở đâu (6 key:
    `charge_discharges_when_idle`, `reload_counter_decays`,
    `state_switches_to_accepting`, `state_switches_to_shooting`,
    `dump_unloads_when_idle`, `no_power_skips_branches`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `d995b023` trên
    `slice/N2245-payload-mass-driver-update-tile` (integration cherry-pick `5573dcd3`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_payload_mass_driver_update_tile` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2246 `C07PayloadMassDriverBranchesProof` — CHƯA CHẠY ở đâu (6 key:
    `accepting_bails_without_shooter`, `accepting_aligns_to_shooter`,
    `shooting_bails_without_link`, `load_advances_to_length`,
    `fire_gate_requires_queue_and_angles`, `transfer_resets_both_sides`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `107c2ad6` trên
    `slice/N2246-payload-mass-driver-branches` (integration cherry-pick `39b16e35`,
    merge tay driver PMD).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_payload_mass_driver_branches` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2247 `C07ShockwaveTowerUpdateTileProof` — CHƯA CHẠY ở đâu (6 key:
    `fire_gate_needs_charge_and_timer`, `scan_filters_enemy_hittable`,
    `wave_damage_falloff_formula`, `target_removed_below_wave_damage`,
    `heat_set_on_fire`, `heat_decays_every_tick`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `a46b276b` trên
    `slice/N2247-shockwave-tower-update-tile` (integration cherry-pick `66626216`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_shockwave_tower_update_tile` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2248 `C07UnitAssemblerModuleUpdateTileProof` — CHƯA CHẠY ở đâu (6 key:
    `link_refreshes_on_tile_change`, `no_refresh_without_change`,
    `handoff_needs_link_and_fit`, `handoff_clears_payload`,
    `handoff_blocked_when_occupied`, `handoff_blocked_without_power`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit `0ecf1534` trên
    `slice/N2248-unit-assembler-module-update-tile` (integration cherry-pick `2c3ded1b`).
    Trạng thái "chờ agent Godot test". Chạy: targeted test
    `tests.test_c07_unit_assembler_module_update_tile` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] N2249 `C07UnitCargoLoaderLiquidRowProof` — CHƯA CHẠY ở đâu (6 key:
    `row_folds_below_one_when_starved`, `row_caps_at_one_when_full`,
    `row_zeroes_when_edelta_zero`, `row_zeroes_without_liquid`,
    `live_tick_folds_liquid_row`, `live_tick_removes_liquid_when_running`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo slice commit trên
    `slice/N2249-unit-cargo-loader-liquid-row` (`8d98e988`).
  - [ ] N2250 `C07RepairTowerLiquidRowProof` — CHƯA CHẠY ở đâu (6 key: `row_folds_below_one_when_starved`, `row_caps_at_one_when_full`, `row_zeroes_when_edelta_zero`, `row_zeroes_without_liquid`, `live_tick_folds_liquid_row`, `live_tick_removes_liquid_when_running` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `c9364955` trên `slice/N2250-repair-tower-liquid-row`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_repair_tower_liquid_row` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2251 `C07BuildTurretLiquidRowProof` — CHƯA CHẠY ở đâu (6 key: `row_folds_below_one_when_starved`, `row_caps_at_one_when_full`, `row_zeroes_when_edelta_zero`, `row_zeroes_without_liquid`, `live_tick_folds_liquid_row`, `live_tick_removes_liquid_when_running` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `eec92c53` trên `slice/N2251-build-turret-liquid-row`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_build_turret_liquid_row` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2252 `C07SeparatorLiquidRowProof` — CHƯA CHẠY ở đâu (6 key: `row_folds_below_one_when_starved`, `row_caps_at_one_when_full`, `row_zeroes_when_edelta_zero`, `row_zeroes_without_liquid`, `live_tick_folds_liquid_row`, `live_tick_removes_liquid_when_running` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `b3922a5f` trên `slice/N2252-separator-liquid-row`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_separator_liquid_row` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2253 `C07LaunchPadLiquidRowProof` — CHƯA CHẠY ở đâu (8 key: `advanced_pad_has_oil_consumer`, `row_folds_below_one_when_starved`, `row_caps_at_one_when_full`, `row_zeroes_when_edelta_zero`, `row_zeroes_without_liquid`, `row_absent_for_plain_launch_pad`, `live_tick_folds_liquid_row`, `live_tick_removes_liquid_when_running` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `ecebb9c5` trên `slice/N2253-launch-pad-liquid-row`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_launch_pad_liquid_row` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2254 `C07ImpactReactorLiquidRowProof` — CHƯA CHẠY ở đâu (6 key: `row_folds_below_one_when_starved`, `row_caps_at_one_when_full`, `row_zeroes_when_edelta_zero`, `row_zeroes_without_liquid`, `live_tick_folds_liquid_row`, `live_tick_removes_liquid_when_running` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `2abb4c60` trên `slice/N2254-impact-reactor-liquid-row`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_impact_reactor_liquid_row` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2255 `C07FrackerLiquidRowProof` — CHƯA CHẠY ở đâu (6 key: `row_folds_below_one_when_starved`, `row_caps_at_one_when_full`, `row_zeroes_when_edelta_zero`, `row_zeroes_without_liquid`, `live_tick_folds_liquid_row`, `live_tick_removes_liquid_when_running` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `1fed72fc` trên `slice/N2255-fracker-liquid-row`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_fracker_liquid_row` với Godot 4.6.2 trên PATH, port 7777 trống.
    Trạng thái "chờ agent Godot test". Chạy: targeted test
  - [ ] N2256 `C07BeamDrillLiquidRowsProof` — CHƯA CHẠY ở đâu (6 key: `required_row_folds_min_when_starved`, `booster_row_folds_optional_when_starved`, `optional_capped_by_min_efficiency`, `row_caps_at_one_when_full`, `live_tick_folds_both_rows`, `live_tick_removes_liquid_when_running` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `6e654a14` trên `slice/N2256-beam-drill-liquid-rows`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_beam_drill_liquid_rows` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2257 `C07BurstDrillLiquidRowsProof` — CHƯA CHẠY ở đâu (6 key: `required_row_folds_min_when_starved`, `booster_row_folds_optional_when_starved`, `optional_capped_by_min_efficiency`, `row_caps_at_one_when_full`, `live_tick_folds_both_rows`, `live_tick_removes_liquid_when_running` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `c6c564fb` trên `slice/N2257-burst-drill-liquid-rows`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_burst_drill_liquid_rows` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2258 `C07ForceProjectorCoolantProof` — CHƯA CHẠY ở đâu (6 key: `coolant_row_folds_optional_when_present`, `filter_rejects_non_coolant`, `get_consumed_prefers_current_liquid`, `buildup_scale_uses_current_heat_capacity`, `no_coolant_no_scale`, `live_tick_consumes_coolant_only_when_buildup` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `4c0f4b77` trên `slice/N2258-force-projector-coolant`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_force_projector_coolant` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2259 `C07RepairTurretCoolantProof` — CHƯA CHẠY ở đâu (6 key: `coolant_row_folds_optional_when_present`, `filter_rejects_non_coolant`, `multiplier_uses_current_heat_capacity`, `repair_point_has_no_coolant_row`, `live_tick_folds_coolant_row`, `live_tick_removes_coolant_when_running` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `ae2cd4cc` trên `slice/N2259-repair-turret-coolant`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_repair_turret_coolant` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2260 `C07RegenProjectorSecondConsumersProof` — CHƯA CHẠY ở đâu (6 key: `hydrogen_row_folds_min_when_starved`, `phase_fabric_row_folds_optional_when_absent`, `item_row_binary_one_when_present`, `optional_capped_by_min_efficiency`, `live_tick_removes_hydrogen_when_running`, `consumed_tick_removes_phase_fabric` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `752a8b27` trên `slice/N2260-regen-projector-second-consumers`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_regen_projector_second_consumers` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2261 `C07ForceProjectorBoosterItemProof` — CHƯA CHẠY ở đâu (6 key: `item_row_binary_one_when_present`, `item_row_zero_when_absent`, `live_tick_folds_item_row`, `optional_folds_min_of_coolant_and_item`, `phase_heat_lerps_toward_phase_valid`, `phase_valid_follows_item_row` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `073ecde1` trên `slice/N2261-force-projector-booster-item`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_force_projector_booster_item` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2262 `C07OverdriveProjectorBoosterItemsProof` — CHƯA CHẠY ở đâu (6 key: `dome_row_folds_min_when_starved`, `dome_row_needs_both_stacks`, `dome_row_stops_power_when_starved`, `projector_row_folds_optional_when_absent`, `use_ready_removes_dome_stacks`, `use_ready_removes_projector_stack` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `a867f416` trên `slice/N2262-overdrive-projector-booster-items`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_overdrive_projector_booster_items` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2263 `C07MendProjectorBoosterItemsProof` — CHƯA CHẠY ở đâu (6 key: `booster_row_folds_optional_only`, `live_tick_folds_booster_row`, `mend_projector_row_binary_phase_fabric`, `mender_row_binary_silicon`, `optional_capped_by_min_efficiency`, `phase_heat_lerps_toward_optional` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `ac718a0a` trên `slice/N2263-mend-projector-booster-items`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_mend_projector_booster_items` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2264 `C07WallCrafterSecondConsumersProof` — CHƯA CHẠY ở đâu (6 key: `cliff_crusher_has_no_rows`, `graphite_row_folds_optional_when_absent`, `hydrogen_row_folds_min_when_starved`, `item_row_binary_one_when_present`, `item_valid_stamped_live`, `live_tick_removes_hydrogen_when_running` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `041c31e7` trên `slice/N2264-wall-crafter-second-consumers`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_wall_crafter_second_consumers` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2265 `C07ConstructorDynamicItemRowProof` — CHƯA CHẠY ở đâu (6 key: `dynamic_stacks_ceil_cost_multiplier`, `dynamic_row_binary_full_stacks`, `dynamic_row_zero_missing_stack`, `dynamic_row_one_empty_recipe`, `trigger_removes_rounded_amounts`, `live_tick_folds_dynamic_row` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `81a94e9a` trên `slice/N2265-block-producer-dynamic-items`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_constructor_dynamic_item_row` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2266 `C07ImpactReactorItemRowProof` — CHƯA CHẠY ở đâu (6 key: `item_row_binary_blast_compound`, `item_row_folds_required_min`, `timer_fires_at_item_duration`, `timer_no_fire_below_threshold`, `timer_consume_removes_one`, `timer_no_fire_when_gate_closed` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `a0ddd235` trên `slice/N2266-impact-reactor-item-row`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_impact_reactor_item_row` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2267 `C07AcceleratorItemRowsProof` — CHƯA CHẠY ở đâu (6 key: `item_row_binary_core_nucleus_stacks`, `item_row_zero_missing_thorium`, `capacities_sum_item_capacity_25000`, `max_accepted_adds_core_bonus_when_built`, `accept_item_below_max_only`, `live_tick_folds_item_row` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `cbdce69a` trên `slice/N2267-accelerator-item-rows`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_accelerator_item_rows` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2268 `C07FrackerItemRowProof` — CHƯA CHẠY ở đâu (6 key: `item_row_binary_sand`, `item_row_zero_no_sand`, `item_row_folds_required_min`, `sand_row_blocks_power_when_starved`, `advance_removal_unchanged`, `live_tick_folds_sand_row` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `47f89c86` trên `slice/N2268-fracker-item-row`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_fracker_item_row` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2269 `C07MendProjectorBoosterTimerProof` — CHƯA CHẠY ở đâu (6 key: `timer_fires_at_use_time`, `timer_no_fire_below_threshold`, `timer_requires_positive_optional`, `timer_consume_removes_booster_item`, `timer_uses_per_def_stack`, `timer_no_fire_when_time_scale_zero` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `1791376a` trên `slice/N2269-mend-projector-booster-timer`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_mend_projector_booster_timer` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2270 `C07PayloadLoaderDynamicPowerProof` — CHƯA CHẠY ở đâu (6 key: `usage_base_when_exporting`, `usage_base_when_no_battery`, `usage_charging_when_battery_and_not_exporting`, `usage_reads_catalog_base_power`, `usage_stored_on_frame_each_tick`, `usage_zero_when_no_payload` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `5a11de4e` trên `slice/N2270-payload-loader-dynamic-power`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_payload_loader_dynamic_power` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2271 `C07AcceleratorLaunchProof` — CHƯA CHẠY ở đâu (6 key: `can_launch_false_when_launching`, `can_launch_requires_full_battery`, `can_launch_requires_positive_efficiency`, `can_launch_requires_progress_one`, `launch_clears_items_and_resets_progress`, `launch_drains_battery_by_requirement` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `69d07e3f` trên `slice/N2271-accelerator-launch`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_accelerator_launch` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2272 `C07BuildTurretUpdateBuildLogicProof` — CHƯA CHẠY ở đâu (6 key: `counter_accumulates_and_clamps`, `counter_nan_resets_to_zero`, `selection_fallback_rotates_to_nearest`, `selection_picks_first_valid_in_range`, `validate_keeps_valid_plan`, `validate_removes_null_tile_plan` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `48ec98f0` trên `slice/N2272-build-turret-update-build-logic`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_build_turret_update_build_logic` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2273 `C07WallCrafterTimerConsumeProof` — CHƯA CHẠY ở đâu (6 key: `timer_consume_removes_graphite`, `timer_fires_at_use_time`, `timer_no_fire_below_threshold`, `timer_no_fire_when_time_scale_zero`, `timer_no_item_for_cliff_crusher`, `timer_requires_item_valid_and_positive_eff` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `550bfeb5` trên `slice/N2273-wall-crafter-timer-consume`. **Scene đã UPDATE bởi fix N2303 (commit `51feaff4` trên `slice/N2303-wall-crafter-n2273-proof-fix`): live-tick seed giờ là wall_edge_tiles (3 tiles 0.5+0.25+0.25 = 1.0) thay vì efficiency_factor trực tiếp — chạy proof với scene MỚI (re-run).** Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_wall_crafter_timer_consume` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2274 `C07BlockProducerUpdateTileProof` — CHƯA CHẠY ở đâu (8 key: `heat_lerps_toward_produce`, `live_tick_advances_progress`, `move_out_payload_approaches_dest`, `no_progress_without_recipe`, `progress_accumulates_when_producing`, `progress_completes_spawns_payload`, `progress_keeps_remainder_mod_one`, `time_accumulates_with_heat` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `f5d6d862` trên `slice/N2274-block-producer-update-tile`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_block_producer_update_tile` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2275 `C07LiquidBridgeUpdateTransportProof` — CHƯA CHẠY ở đâu (6 key: `move_liquid_transfers_by_pressure`, `moved_set_when_flow_above_threshold`, `no_transfer_when_partner_full`, `transport_blocked_below_warmup_quarter`, `warmup_approaches_efficiency`, `warmup_zero_when_unlinked` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `1ba2f18e` trên `slice/N2275-liquid-bridge-update-transport`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_liquid_bridge_update_transport` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2276 `C07PayloadDeconstructorDumpProof` — CHƯA CHẠY ở đâu (7 key: `dump_accumulates_with_delta`, `dump_cursor_advances`, `dump_fires_when_accum_reaches_one`, `dump_rate_four_per_tick`, `dump_removes_item_from_store`, `live_tick_dumps_item`, `no_dump_when_items_empty` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `75ce778a` trên `slice/N2276-payload-deconstructor-dump`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_payload_deconstructor_dump` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2277 `C07RegenProjectorTargetsFillProof` — CHƯA CHẠY ở đâu (6 key: `live_tick_refreshes_targets`, `rect_is_square_not_circle`, `targets_include_damaged_flag`, `targets_only_same_team_in_rect`, `targets_refresh_on_tile_change`, `targets_unchanged_without_tile_change` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `053860ff` trên `slice/N2277-regen-projector-targets-fill`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_regen_projector_targets_fill` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2278 `C07PayloadLoaderLiveFillProof` — CHƯA CHẠY ở đâu (6 key: `handle_clamps_pay_vector_to_half_size`, `handle_clears_exporting`, `handle_ignored_when_payload_present`, `handle_sets_pay_rotation`, `handle_sets_payload_and_vector`, `take_returns_and_clears_payload` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `46b659ad` trên `slice/N2278-payload-loader-live-fill`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_payload_loader_live_fill` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2279 `C07PayloadUnloaderLiveFillProof` — CHƯA CHẠY ở đâu (7 key: `handle_clamps_pay_vector_to_half_size`, `handle_ignored_when_payload_present`, `handle_sets_pay_rotation`, `handle_sets_payload_and_vector`, `live_tick_fills_payload_from_incoming`, `no_exporting_flag_on_unloader`, `take_returns_and_clears_payload` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `654039d9` trên `slice/N2279-payload-unloader-live-fill`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_payload_unloader_live_fill` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2280 `C07RepairTurretTimerTargetProof` — CHƯA CHẠY ở đâu (6 key: `timer_fires_at_twenty_ticks`, `timer_no_fire_below_threshold`, `timer_no_fire_when_time_scale_zero`, `timer_passes_candidates_on_fire`, `timer_passes_empty_when_not_fired`, `timer_resets_elapsed_on_fire` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `a91baae0` trên `slice/N2280-repair-turret-timer-target`. **Scene đã UPDATE bởi fix N2290 (commit `e65bd685` trên `slice/N2290-repair-turret-literal-20`): threshold giờ là literal 20, không chia timeScale — chạy proof với scene MỚI (re-run, nợ Godot thứ 2 cùng N2196).** Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_repair_turret_timer_target` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2281 `C07SeparatorTimerDumpProof` — CHƯA CHẠY ở đâu (6 key: `dump_cursor_advances`, `dump_removes_item_from_store`, `live_tick_dumps_item`, `no_dump_when_items_empty`, `timer_fires_at_five_ticks`, `timer_no_fire_below_threshold` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `15905aad` trên `slice/N2281-separator-timer-dump`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_separator_timer_dump` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2282 `C07BurstDrillTimerDumpProof` — CHƯA CHẠY ở đâu (7 key: `dump_cursor_advances`, `dump_falls_back_to_null`, `dump_prefers_dominant_item`, `live_tick_dumps_item`, `no_dump_without_dominant_item`, `timer_fires_at_five_ticks`, `timer_no_fire_below_threshold` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `eafd3fb5` trên `slice/N2282-burst-drill-timer-dump`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_burst_drill_timer_dump` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2283 `C07WallCrafterTimerDumpProof` — CHƯA CHẠY ở đâu (6 key: `dump_cursor_advances`, `dump_removes_output_item`, `live_tick_dumps_output`, `no_dump_when_output_absent`, `timer_fires_at_five_ticks`, `timer_no_fire_below_threshold` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `ca592ed9` trên `slice/N2283-wall-crafter-timer-dump`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_wall_crafter_timer_dump` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2284 `C07FrackerDumpLiquidProof` — CHƯA CHẠY ở đâu (6 key: `dump_no_transfer_below_threshold`, `dump_no_transfer_when_neighbour_full`, `dump_runs_in_both_branches`, `dump_scales_by_two`, `dump_transfers_to_neighbour`, `live_tick_dumps_liquid` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `2365f112` trên `slice/N2284-fracker-dump-liquid`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_fracker_dump_liquid` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2285 `C07PumpDumpLiquidProof` — CHƯA CHẠY ở đâu (6 key: `dump_no_transfer_below_threshold`, `dump_no_transfer_when_neighbour_full`, `dump_scales_by_two`, `dump_skipped_when_no_liquid_drop`, `dump_transfers_to_neighbour`, `live_tick_dumps_liquid` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `321785c5` trên `slice/N2285-pump-dump-liquid`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_pump_dump_liquid` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2286 `C07SolidPumpDumpLiquidProof` — CHƯA CHẠY ở đâu (6 key: `dump_no_transfer_below_threshold`, `dump_no_transfer_when_neighbour_full`, `dump_runs_when_efficiency_zero`, `dump_scales_by_two`, `dump_transfers_to_neighbour`, `live_tick_dumps_liquid` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `3bfdf49f` trên `slice/N2286-solid-pump-dump-liquid`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_solid_pump_dump_liquid` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2287 `C07LiquidBridgeDoDumpProof` — CHƯA CHẠY ở đâu (7 key: `dump_cursor_advances`, `dump_no_transfer_below_threshold`, `dump_no_transfer_when_neighbour_full`, `dump_only_when_unlinked`, `dump_scales_by_one`, `dump_transfers_to_neighbour`, `live_tick_dumps_liquid` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `fc48fa18` trên `slice/N2287-liquid-bridge-do-dump`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_liquid_bridge_do_dump` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2288 `C07ItemBridgeDoDumpProof` — CHƯA CHẠY ở đâu (6 key: `dump_fires_when_accum_reaches_one`, `dump_multiple_times_per_frame`, `dump_no_fire_below_threshold`, `dump_only_when_unlinked`, `dump_removes_item_from_store`, `live_tick_dumps_item` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `dca7c8d6` trên `slice/N2288-item-bridge-do-dump`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_item_bridge_do_dump` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2289 `C07BeamDrillTimerDumpProof` — CHƯA CHẠY ở đâu (6 key: `dump_cursor_advances`, `dump_removes_item_from_store`, `live_tick_dumps_item`, `no_dump_when_items_empty`, `timer_fires_at_five_ticks`, `timer_no_fire_below_threshold` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `56cbb21e` trên `slice/N2289-beam-drill-dump-timer`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_beam_drill_timer_dump` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2291 `C07PayloadDeconstructorDeconstructingFillProof` — CHƯA CHẠY ở đâu (6 key: `handle_sets_payload_and_clears_accum`, `handoff_sets_deconstructing_on_arrival`, `live_tick_fills_deconstructing`, `move_in_approaches_zero`, `no_handoff_before_arrival`, `no_handoff_without_payload` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `847ac589` trên `slice/N2291-payload-deconstructor-deconstructing-fill`. **Scene đã UPDATE bởi slice N2308 (commit `2726c503` trên `slice/N2308-deconstructor-intake-gate`): fixture thêm `block_size: 2` (load-bearing — intake gate mới reject push thiếu block_size) — chạy proof với scene MỚI (re-run).** Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_payload_deconstructor_deconstructing_fill` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2292 `C07SolidPumpFractionFillProof` — CHƯA CHẠY ở đâu (6 key: `boost_sums_attributes`, `deep_floor_excluded_when_not_floating`, `env_adds_when_attribute_present`, `fraction_clamps_at_zero`, `live_tick_fills_fraction`, `valid_tiles_counts_pumpable` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `bddb98ef` trên `slice/N2292-solid-pump-fraction-fill`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_solid_pump_fraction_fill` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2293 `C07PayloadUnloaderDumpProof` — CHƯA CHẠY ở đâu (6 key: `dump_accum_grows_by_four_delta`, `dump_items_via_accumulate`, `dump_no_transfer_when_neighbour_full`, `dump_scales_liquid_by_two`, `dump_transfers_liquid_to_neighbour`, `live_tick_dumps_both` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `a4c75553` trên `slice/N2293-payload-unloader-dump-rows`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_payload_unloader_dump` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2294 `C07MassDriverDumpProof` — CHƯA CHẠY ở đâu (6 key: `dump_blocked_when_shooting`, `dump_fires_when_accepting`, `dump_fires_when_idle`, `dump_removes_item_from_store`, `dump_runs_without_power`, `live_tick_dumps_item` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `b9d17508` trên `slice/N2294-mass-driver-dump-accumulate`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_mass_driver_dump` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2295 `C07PayloadLoaderAcceptPayloadProof` — CHƯA CHẠY ở đâu (6 key: `base_gate_rejects_when_payload_present`, `battery_accepted`, `item_container_accepted`, `liquid_container_accepted`, `non_build_payload_rejected`, `oversize_or_under_capacity_rejected` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `762ff9a1` trên `slice/N2295-payload-loader-accept-payload`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_payload_loader_accept_payload` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2296 `C07PayloadUnloaderAcceptPayloadProof` — CHƯA CHẠY ở đâu (6 key: `accept_item_always_false`, `accept_liquid_always_false`, `accepts_container_when_empty`, `live_tick_exposes_all_three_verdicts`, `rejects_non_container_payload`, `rejects_when_payload_present` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `14746b76` trên `slice/N2296-payload-unloader-accept-payload`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_payload_unloader_accept_payload` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2297 `C07PayloadDeconstructorAcceptPayloadProof` — CHƯA CHẠY ở đâu (6 key: `accepts_payload_when_empty_with_requirements`, `accepts_unit_when_allowed`, `rejects_core_spawned_unit`, `rejects_empty_requirements_payload`, `rejects_oversize_unit`, `rejects_payload_when_deconstructing_busy` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `b03dbc84` trên `slice/N2297-payload-deconstructor-accept-payload`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_payload_deconstructor_accept_payload` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2298 `C07PayloadMassDriverAcceptPayloadProof` — CHƯA CHẠY ở đâu (6 key: `accepts_when_empty_and_size_fits`, `boundary_size_24_accepted`, `live_tick_exposes_verdict`, `no_payload_offered_false`, `rejects_oversize`, `rejects_when_payload_present` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `ea7c5609` trên `slice/N2298-payload-mass-driver-accept-payload`. **Tick path đã ĐỔI bởi slice N2304 (commit `a174435c` trên `slice/N2304-pmd-per-def-threshold`): tick giờ gọi pure per-def thay vì pure class-default (live-tick values 16/32 vẫn giữ) — chạy lại proof để kiểm chứng (re-run).** Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_payload_mass_driver_accept_payload` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2299 `C07UnitAssemblerModuleAcceptPayloadProof` — CHƯA CHẠY ở đâu (6 key: `assembler_accepts_below_quota`, `assembler_rejects_at_quota`, `live_tick_exposes_both_verdicts`, `module_accepts_when_linked_empty_link_accepts`, `module_rejects_when_unlinked`, `module_source_minus_one_adjustment` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `48d2bd72` trên `slice/N2299-unit-assembler-module-accept-payload`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_unit_assembler_module_accept_payload` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2301 `C07WallCrafterGetEfficiencyProof` — CHƯA CHẠY ở đâu (6 key: `empty_edge_zero_efficiency`, `ignores_non_solid_tiles`, `live_tick_fills_efficiency_factor`, `placement_gate_efficiency_positive`, `rotation_carried_through`, `sums_solid_tile_attributes` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `a78b498b` trên `slice/N2301-wall-crafter-get-efficiency`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_wall_crafter_get_efficiency` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2304 `C07PayloadMassDriverPerDefThresholdProof` — CHƯA CHẠY ở đâu (6 key: `class_default_boundary_24_accepted`, `large_def_boundary_32_accepted`, `large_def_size_33_rejected`, `live_tick_exposes_per_def_verdict`, `small_def_boundary_20_accepted`, `small_def_size_24_rejected` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `a174435c` trên `slice/N2304-pmd-per-def-threshold`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_payload_mass_driver_per_def_threshold` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2305 `C07FrackerFractionFillProof` — CHƯA CHẠY ở đâu (6 key: `boost_sums_oil_attributes`, `deep_floor_excluded_when_not_floating`, `env_adds_when_attribute_present`, `fraction_clamps_at_zero`, `live_tick_fills_fraction`, `valid_tiles_zero_with_zero_base_efficiency` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `ab74a162` trên `slice/N2305-fracker-fraction-fill`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_fracker_fraction_fill` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2306 `C07RepairTowerLiveScanProof` — CHƯA CHẠY ở đâu (6 key: `damaged_in_range_supplied`, `empty_candidates_empty`, `gate_opens_with_target`, `healthy_excluded`, `live_tick_refills_targets`, `out_of_range_excluded` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `3c2d6629` trên `slice/N2306-repair-tower-live-scan`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_repair_tower_live_scan` với Godot 4.6.2 trên PATH, port 7777 trống.
  - [ ] N2308 `C07PayloadDeconstructorIntakeGateProof` — CHƯA CHẠY ở đâu (6 key: `intake_accepts_when_verdict_true`, `intake_drops_when_deconstructing_busy`, `intake_drops_when_verdict_false`, `intake_drops_without_block_size`, `live_tick_wires_the_gate`, `null_push_still_consumed` + `registry_valid` / `one_headquarter_per_ssot` / `matches`). Scene mang theo slice commit `2726c503` trên `slice/N2308-deconstructor-intake-gate`. Trạng thái "chờ agent Godot test". Chạy: targeted test `tests.test_c07_payload_deconstructor_intake_gate` với Godot 4.6.2 trên PATH, port 7777 trống.
    `tests.test_c07_unit_cargo_loader_liquid_row` với Godot 4.6.2 trên PATH,
    port 7777 trống.
  - [ ] Mọi slice sau này: proof scene mới nào cũng ghi nợ Windows theo mẫu
    trên (ghi rõ commit đưa scene tới Windows).
  - [ ] Agent khác đang test các lỗi fail trên Windows Godot (PR #1 đã merge
    08:31: 101 Godot-dependent methods, baseline 96 pass / 5 fail, sau 5
    fixture repair thì 101/101 cumulative — xem
    `docs/superpowers/reports/2026-11-13-windows-godot-validation.md`).
    Kết quả test tiếp theo của họ cũng báo về đây.
- **Báo hoàn công (khi agent khác test xong):** họ báo lại (qua user hoặc
  PR) từng mục: scene nào, commit nào, chạy trên Windows Godot kết quả
  pass/fail + bằng chứng (log/JSON). Ghi lại vào mục nợ này: đánh dấu `[x]`
  kèm ngày + bằng chứng. Nếu phát hiện lỗi thật (không phải fixture cũ),
  không đóng nợ âm thầm — mở slice/fix mới theo quy trình slice.
- **Không phải nợ:** proof Linux headless (xong trước mỗi lần push); full
  gate chạy không có Godot trên PATH theo thiết kế (các failure Godot-absent
  trong gate là kỳ vọng, không phải nợ test).

## 6. Quy trình slice (bắt buộc, theo `AGENTS.md`)

Đọc design spec + 5 file SSOT + manifest/shards + upstream Java chính xác →
RED tests → GREEN → targeted → neighbours → Godot proof → full gate → report
+ spec + handoff → `git diff --check` → stage đúng file của slice → commit
theo mẫu 3 commit (slice / docs / handoff-hash) → push lên origin main.

Một slice chỉ được push khi **tests + Godot proof + gate đều xanh**. Không
commit/push slice chưa đủ điều kiện.

## 7. Những điều không được hiểu sai

- **Ledger không phải tiến độ tổng.** Ledger chỉ đếm slice đã đăng ký
  (`Done 1600 / Not done 0` không liệt kê phương thức upstream chưa di cư).
  **Không tính % parity từ số file parse, số test hoặc số slice** (backlog
  cấm điều này). Muốn ước lượng phần còn lại thì phải chạy inventory C08:
  quét lại 5.390 hàm null-body, phân loại source-empty / deferred / việc
  thật — làm sau N2150 hoặc khi user yêu cầu, không làm giữa slice.
- **Game giữ nguyên như nó vốn có.** Chỉ sửa proof/test harness để proof
  không fail về mặt kỹ thuật/code; không bao giờ đụng gameplay.
- **Báo cáo 15 phút 1 lần** bằng tiếng Việt, ngắn gọn, số liệu đã kiểm chứng.
  Khi không có thay đổi thì báo ngắn gọn là không có thay đổi, đừng bịa tiến
  độ.
- **Port 7777:** không chạy proof scene song song với gate hay với agent
  khác đang dùng Godot; check port trống trước mỗi proof run. Port bận sẽ
  in `ERROR:` vào output scene và làm fail proof test — đó là lỗi môi
  trường, không phải lỗi code.
- **VM restart xóa javalang** (cài system-wide, `/usr/local` là tmpfs):
  sau restart phải cài lại (`pip install --break-system-packages -r
  tools/mindustry_godot_transpiler/requirements.txt` từ repo root) trước mọi
  gate.
- **Gate chỉ launch từ main thread** (backgrounded `&&` chain, `setsid
  nohup`): gate launch từ worker/cron session **chết khi session end** (đã
  xảy ra ở N2146, N2147, N2149). Sau khi launch, ghi PID + attempt vào
  handoff ngay.
- **Không stage:** `*.gd.uid`, `godot-mindustry/project.godot`,
  `arc-upstream/`, `mindustry-upstream/`, proof `.json`, gate logs
  (`full-suite-*.log`, `targeted-env-fix.log`). Không bao giờ `git add .`.
- **Browser login dùng Chrome của user**, không dùng in-app browser.
- **Worker/cron báo cáo có thể sai hoặc cũ** so với trạng thái live: luôn
  kiểm chứng số liệu quyết định (ps, log tail/mtime, git log/status, SSOT,
  proof JSON, FAIL/ERROR counts) trên worktree thật trước khi báo cáo.

## 8. Đọc trước khi làm

- Tài liệu này (`docs/superpowers/GOAL.md`).
- `AGENTS.md` (house rules).
- Design spec:
  `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`.
- Backlog: `docs/superpowers/handoffs/2026-11-02-mindustry-completion-backlog.md`.
- Handoff mới nhất trong `docs/superpowers/handoffs/` (mục "Next" + "Deferred").
- 5 file SSOT + manifest `source_ssot_modules.json` + shards
  (`godot-mindustry/src/generated/`).
- Upstream Java chính xác trong `mindustry-upstream/` (không đoán tên,
  default, hay công thức).
