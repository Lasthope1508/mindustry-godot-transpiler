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

## 4. Tiến độ hiện tại (2026-11-15 21:07 +07)

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
- **Wave second-consumers-1 {N2249 UnitCargoLoader nitrogen, N2250 RepairTower ozone, N2251 BuildTurret nitrogen, N2252 Separator slag, N2253 LaunchPad oil, N2254 ImpactReactor cryofluid, N2255 Fracker water} required ConsumeLiquid rows — HOÀN TẤT + ĐÃ PUSH** (branch `integration/wave-second-consumers-1-n2249-n2255`, base c2d27fb0; 7/7 slice xong + đã push: N2249 8d98e988, N2250 c9364955, N2251 eec92c53, N2252 b3922a5f, N2253 ecebb9c5, N2254 2abb4c60, N2255 1fed72fc; mỗi slice +2/+1/+1/+2, targeted 3/4 PASS + proof Godot-absent; SSOT gộp 11720/1705/1627/3045; DEFERRED gộp 293; fix cites 81b0dbe4 — ConsumeLiquid efficiency :42-47 / update :37-39, Fracker guard :141-142; second-pass removal trực tiếp ở cả 7 slice — machinery chỉ record actor, không gọi update; full gate Ran 6110 in 1143.879s, failures=204, skipped=5, 0 errors — 204/204 Godot-absent (197 inherited + 7 new proof tests N2249–N2255)). Nợ Godot: 73 → 80 proofs + 1 re-run (N2196).
- **Tiếp theo:** units → updateTile advances → second consumers (xem
  `DESIGN-frame-state-infra.md` trong `~/workspace/mindustry-parallel/`).
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
  - [ ] N2195 `C07BeamDrillUpdateTileProof` — CHƯA CHẠY ở đâu (6 key:
    `warmup_approaches_one_when_powered`, `warmup_decays_to_zero_without_power`,
    `boost_warmup_lerps_to_optional_efficiency`,
    `multiplier_lerps_boost_intensity`, `time_advances_by_edelta_times_multiplier`,
    `live_tick_advances_warmup_and_time`
    + `registry_valid` / `one_headquarter_per_ssot` / `matches`).
    Scene mang theo unification commit `d7512292` trên
    `integration/unification-batch-1-3` (batch slice `c42968e1`).
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
