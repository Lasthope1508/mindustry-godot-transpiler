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

## 4. Tiến độ hiện tại (2026-11-13 ~11:52 +07)

- Main trên fork ở `a3c01eb` (N2149 BurstDrill power.status DONE + PUSHED).
- **N2150 SolidPump power.status (water-extractor): GREEN xong** (targeted
  4/4, Godot proof 9 key xanh, SSOT 11310/1601/1522/2835 trên disk) — đang
  chờ neighbours xanh rồi launch gate, sau đó mới commit + push.
- Sau N2150: PointDefenseTurret (segment) / TractorBeamTurret (parallax)
  power.status, rồi các mục deferred (spawn_occupied, allow_update,
  moveOutPayload, net drone sync, turret ammo/nitrogen rows, shouldConsume
  gates, updateTile advances).
- Repo làm việc là fork `Lasthope1508/mindustry-godot-transpiler`
  (`origin` = fork, `upstream` = `duynguyen16689/mindustry-godot-transpiler`).
  Local worktree: `~/workspace/mindustry-godot-transpiler`.

## 5. Nợ test Godot (Windows) — agent khác test, báo hoàn công sau

- **Nguyên tắc:** proof Godot của mỗi slice chạy trên Linux headless ở VM này
  là đủ điều kiện để push (Godot 4.6.2-stable Linux, build 71f334935, giống
  hệt build Windows 4.6.2). Chạy proof trên **Windows Godot là một track
  kiểm chứng riêng**, do agent khác đảm nhiệm (máy Windows admin-pc) — không
  chặn push, nhưng phải được ghi nợ ở đây và báo hoàn công sau.
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
  - [ ] N2186 `C07ImpactReactorPowerProductionProof` — Linux GREEN 09:4x (9 key).
    Scene tới Windows theo slice commit `ec17915` (pushed ~10:2x, main
    `931c49b`). Chưa chạy trên Windows Godot.
  - [ ] N2187 `C07ImpactReactorConsumeProof` — Linux GREEN 10:5x (7 key).
    Scene tới Windows theo slice commit `02e812d` (pushed ~11:4x, main
    `19d3078`). Chưa chạy trên Windows Godot.
  - [ ] N2188 `C07RepairTurretShouldConsumeProof` — Linux GREEN 12:35 (9 key).
    Scene tới Windows theo slice commit `5b716a5` (pushed ~13:2x, main
    `1db19d6`). Chưa chạy trên Windows Godot.
  - [ ] N2189 `C06UnitFactoryShouldConsumeProof` — Linux GREEN ~13:4x (45 key).
    Scene tới Windows theo slice commit `bcde8e4` (pushed ~14:0x, main
    `0607d3e`). Chưa chạy trên Windows Godot.
  - [ ] N2190 `C07RepairTowerTargetRefreshProof` — Linux GREEN 14:45 (7 key).
    Scene tới Windows theo slice commit `f10c459` (pushed ~15:5x, main
    `377984d`). Chưa chạy trên Windows Godot.
  - [ ] N2191 `C07RepairTowerShouldConsumeProof` — Linux GREEN 16:3x (5 key).
    Scene tới Windows theo slice commit `23f5a99` (pushed ~16:5x, main
    `2a5bca1`). Chưa chạy trên Windows Godot.
  - [ ] N2192 `C07ShockwaveTowerChargeProof` — Linux GREEN 17:1x (6 key).
    Scene tới Windows theo slice commit `b028951` (pushed ~17:4x, main
    `8b609ad`). Chưa chạy trên Windows Godot.
  - [ ] N2193 `C07ShockwaveTowerShouldConsumeProof` — Linux GREEN 18:1x (6 key).
    Scene tới Windows theo slice commit `2e75942` (pushed ~18:5x, main
    `927e6fd`). Chưa chạy trên Windows Godot.
  - [ ] N2194 `C07ShockwaveTowerFireProof` — Linux GREEN 19:1x (6 key).
    Scene tới Windows theo slice commit `a0a59cb` (pushed ~19:5x, main
    `188c3f5`). Chưa chạy trên Windows Godot.
  - [ ] N2195 `C07ShockwaveTowerBulletScanProof` — Linux GREEN 20:1x (6 key).
    Scene tới Windows theo slice commit `5a59201` (pushed ~20:5x, main
    `24b6602`). Chưa chạy trên Windows Godot.
  - [ ] N2196 `C07ShockwaveTowerWaveDamageProof` — Linux GREEN 21:15 (6 key).
    Scene tới Windows theo slice commit `3d1d842` (pushed ~21:5x, main
    `58b8b74`). Chưa chạy trên Windows Godot.
  - [ ] N2197 `C07ShockwaveTowerFireEffectsProof` — Linux GREEN 22:15 (5 key).
    Scene tới Windows theo slice commit `827214b` (pushed ~22:5x, main
    `ac73b00`). Chưa chạy trên Windows Godot.
  - [ ] N2198 `C07ShockwaveTowerHitEffectProof` — Linux GREEN 23:15 (5 key).
    Scene tới Windows theo slice commit `e9a93fc` (pushed ~23:5x, main
    `e337f79`). Chưa chạy trên Windows Godot.
  - [ ] N2199 `C07ShockwaveTowerUseEventProof` — Linux GREEN 00:15 (5 key).
    Scene tới Windows theo slice commit `b358550` (pushed ~00:5x, main
    `2ab4ec0`). Chưa chạy trên Windows Godot.
  - [ ] N2200 `C07ShockwaveTowerTimerCadenceProof` — Linux GREEN 01:45 (8 key).
    Scene tới Windows theo slice commit `9e0ee48` (pushed ~03:1x, main
    `1136e56`). Chưa chạy trên Windows Godot.
  - [ ] N2201 `C07BuildTurretShouldConsumeProof` — Linux GREEN 03:42 (6 key).
    Scene tới Windows theo slice commit `d7a3027` (pushed ~04:1x, main
    `05c4877`). Chưa chạy trên Windows Godot.
  - [ ] N2202 `C07ShieldWallBrokenProof` — Linux GREEN 04:39 (6 key).
    Scene tới Windows theo slice commit `4532fb20` (pushed ~05:0x, main
    `8d573fa2`). Chưa chạy trên Windows Godot.
  - [ ] N2203 `C07ShieldWallDamageProof` — Linux GREEN 05:3x (6 key).
    Scene tới Windows theo slice commit `4c7ece6c` (pushed ~06:0x, main
    `bb46612f`). Chưa chạy trên Windows Godot.
  - [ ] N2204 `C07ShieldWallUpdateTileProof` — Linux GREEN 06:4x (8 key).
    Scene tới Windows theo slice commit `ef32a852` (pushed ~07:2x, main
    `17cd0e20`). Chưa chạy trên Windows Godot.
  - [ ] N2205 `C07LaunchPadShouldConsumeProof` — Linux GREEN ~08:03 (6 key).
    Scene tới Windows theo slice commit `68b32928` (pushed ~08:5x, main
    `b56b13b8`). Chưa chạy trên Windows Godot.
  - [ ] N2206 `C07LaunchPadSenseProgressProof` — Linux GREEN ~09:4x (6 key).
    Scene tới Windows theo slice commit `8db29088` (pushed ~10:0x, main
    `13fe94f3`). Chưa chạy trên Windows Godot.
  - [ ] N2207 `C07LaunchPadUpdateTileProof` — Linux GREEN ~10:2x (6 key).
    Scene tới Windows theo slice commit `6d642065` (pushed ~11:0x, main
    `dd7fb715`). Chưa chạy trên Windows Godot.
  - [ ] N2208 `C07MassDriverSenseProgressAcceptItemProof` — Linux GREEN ~11:3x (6 key).
    Scene tới Windows theo slice commit `1cd99dfc` (pushed ~12:1x, main
    `7b1d4523`). Chưa chạy trên Windows Godot.
  - [ ] N2209 `C07RepairTurretCoolantProof` — Linux GREEN ~12:3x (6 key).
    Scene tới Windows theo slice commit `a901d10e` (pushed ~13:0x, main
    `1ea52dfd`). Chưa chạy trên Windows Godot.
  - [ ] N2210 `C07UnitsNearbyProof` — Linux GREEN ~13:5x (6 key).
    Scene tới Windows theo slice commit `a43bb520` (pushed ~14:2x, main
    `7a5c6eaa`). Chưa chạy trên Windows Godot.
  - [ ] N2211 `C07RepairTowerNearbyDriverProof` — Linux GREEN ~14:5x (6 key).
    Scene tới Windows theo slice commit `978de467` (pushed ~15:2x, main
    `43116028`). Chưa chạy trên Windows Godot.
  - [ ] N2212 `C07RepairTurretTargetAcquireProof` — Linux GREEN ~15:3x (8 key).
    Scene tới Windows theo slice commit `67e50698` (pushed ~16:2x, main
    `fd0b5363`). Chưa chạy trên Windows Godot.
  - [ ] N2213 `C07RepairTurretHealAdvanceProof` — Linux GREEN ~17:1x (8 key).
    Scene tới Windows theo slice commit `fd7a3739` (pushed ~17:2x, main
    `288e7c47`). Chưa chạy trên Windows Godot.
  - [ ] N2214 `C07RepairTurretRotationSlerpProof` — Linux GREEN ~17:5x (8 key).
    Scene tới Windows theo slice commit `e1322bb7` (pushed ~18:3x, main
    `1513486b`). Chưa chạy trên Windows Godot.
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
