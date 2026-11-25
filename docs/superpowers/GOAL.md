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

**Chia family giữa hai line (Isabella 2026-11-17):** VM này chỉ làm
Turret/BurstDrill/Radar/Game + **BuildTurret** (quyết main thread 2026-11-22 ~16:10 +07: BuildTurret extends BaseTurret, BlockGroup.turrets, họ Turret; slice đầu N2423); line Windows chỉ làm RepairTower/RepairTurret
+ PointDefenseTurret (Isabella 2026-11-18 ~16:08 +07, sau 9 slice liên tiếp
N2239–N2247 của line Windows) + **Weapon** (Isabella 2026-11-23 ~12:56 +07,
remote đã làm 11 slice Weapon liên tiếp N2534–N2544)
(chi tiết + lý do xem AGENTS.md). Không làm slice thuộc family của line kia.

**Chia số N theo line (Isabella 2026-11-23 ~12:56 +07):** VM line chỉ lấy
N2449–N2999; line Windows chỉ lấy N3000 trở lên (khoảng 2545–2999 để trống
cố tình, remote max N2544 lúc merge). Không lấy số ngoài range của line
mình; sắp vượt range thì DỪNG và báo. Draft scope không ghi số N tạm, chỉ
nhãn slot — số thật cấp lúc spawn từ allocations.json.

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
  - [ ] N2215 `C07RepairTurretStrengthLerpProof` — Linux GREEN ~19:0x (8 key).
    Scene tới Windows theo slice commit `dcfff971` (pushed ~19:4x, main
    `bedcf73b`). Chưa chạy trên Windows Godot.
  - [ ] N2216 `C07ImpactReactorImpactPowerProof` — Linux GREEN ~21:0x (8 key).
    Scene tới Windows theo slice commit `86bce937` (pushed ~21:1x, main
    `7a16b0da`). Chưa chạy trên Windows Godot.
  - [ ] N2217 `C07RepairTurretReadWriteProof` — Linux GREEN ~22:2x (8 key).
    Scene tới Windows theo slice commit `7b7bd0a8` (pushed ~22:2x, main
    `4a6b665e`). Chưa chạy trên Windows Godot.
  - [ ] N2218 `C07AcceleratorBatteryProof` — Linux GREEN ~22:5x (6 key).
    Scene tới Windows theo slice commit `5652bba4` (pushed ~23:3x, main
    `f959f50b`). Chưa chạy trên Windows Godot.
  - [ ] N2219 `C07RepairTurretDrawBeamProof` — Linux GREEN ~00:1x (8 key).
    Scene tới Windows theo slice commit `e33b33dc` (pushed ~01:1x, main
    `e4ec1a40`). Chưa chạy trên Windows Godot.
  - [ ] N2220 `C07RepairTurretDrawSelectPlaceProof` — Linux GREEN ~01:4x (8 key).
    Scene tới Windows theo slice commit `c2f81746` (pushed ~02:1x, main
    `6dd261a4`). Chưa chạy trên Windows Godot.
  - [ ] N2221 `C07RepairTurretShouldAmbientSoundStatusProof` — Linux GREEN ~02:4x (8 key).
    Scene tới Windows theo slice commit `ad384b23` (pushed ~03:0x, main
    `54ad2333`). Chưa chạy trên Windows Godot.
  - [ ] N2222 `C07RepairTurretAmbientSoundLoopProof` — Linux GREEN ~03:5x (6 key).
    Scene tới Windows theo slice commit `21c4e8a9` (pushed ~04:0x, main
    `0aee9f09`). Chưa chạy trên Windows Godot.
  - [ ] N2223 `C07RepairTurretSenseRangeRotationProof` — Linux GREEN ~04:3x (6 key).
    Scene tới Windows theo slice commit `99bafab1` (pushed ~04:5x, main
    `64db845f`). Chưa chạy trên Windows Godot.
  - [ ] N2224 `C07RepairTurretSetStatsProof` — Linux GREEN ~05:5x (8 key).
    Scene tới Windows theo slice commit `794dda4e` (pushed ~06:1x, main
    `78c5e470`). Chưa chạy trên Windows Godot.
  - [ ] N2225 `C07RepairTurretDrawProof` — Linux GREEN ~07:0x (6 key).
    Scene tới Windows theo slice commit `2c4a7f90` (pushed ~07:5x, main
    `3191fa9b`). Chưa chạy trên Windows Godot.
  - [ ] N2226 `C07RepairTurretInitProof` — Linux GREEN ~08:2x (3 key).
    Scene tới Windows theo slice commit `66b086e5` (pushed ~09:1x, main
    `33467ea1`). Chưa chạy trên Windows Godot.
  - [ ] N2227 `C07RepairTurretIconsProof` — Linux GREEN ~09:2x (3 key).
    Scene tới Windows theo slice commit `e1634f5a` (pushed ~09:5x, main
    `67ca79a6`). Chưa chạy trên Windows Godot.
  - [ ] N2228 `C07RepairTowerHealAdvanceProof` — Linux GREEN ~10:3x (8 key).
    Scene tới Windows theo slice commit `e08dc4ce` (pushed ~11:1x, main
    `3ddfa015`). Chưa chạy trên Windows Godot.
  - [ ] N2229 `C07RepairTowerOzoneConsumeProof` — Linux GREEN ~12:0x (7 key).
    Scene tới Windows theo slice commit `53f61ce6` (pushed ~13:0x, main
    `e18b6f61`). Chưa chạy trên Windows Godot.
  - [ ] N2230 `C07RepairTowerSetStatsProof` — Linux GREEN ~14:0x (4 key).
    Scene tới Windows theo slice commit `64b06843` (pushed ~14:3x, main
    `d0da254f`). Chưa chạy trên Windows Godot.
  - [ ] N2231 `C07RepairTowerDrawSelectPlaceProof` — Linux GREEN ~15:3x (9 key).
    Scene tới Windows theo slice commit `7a9fb143` (pushed ~16:0x, main
    `0ad1724d`). Chưa chạy trên Windows Godot.
  - [ ] N2232 `C07RepairTowerDrawProof` — Linux GREEN ~16:4x (12 key).
    Scene tới Windows theo slice commit `b570908e` (pushed ~17:2x, main
    `b3d7a5e1`). Chưa chạy trên Windows Godot.
  - [ ] N2233 `C07RepairTurretRangeBuildRotationProof` — Linux GREEN ~18:0x (6 key).
    Scene tới Windows theo slice commit `e776b073` (pushed ~18:3x, main
    `3a171f86`). Chưa chạy trên Windows Godot.
  - [ ] N2234 `C07RepairTurretSenseObjectProof` — Linux GREEN ~19:0x (7 key).
    Scene tới Windows theo slice commit `20e107f3` (pushed ~19:4x, main
    `d2dd4aeb`). Chưa chạy trên Windows Godot.
  - [ ] N2235 `C07RepairTurretAmbientSoundVolumeProof` — Linux GREEN ~20:0x (7 key).
    Scene tới Windows theo slice commit `0a1b5247` (pushed ~20:3x, main
    `1093c7c7`). Chưa chạy trên Windows Godot.
  - [ ] N2236 `C07RepairTurretBindBlockIdProof` — Linux GREEN ~21:3x (7 key).
    Scene tới Windows theo slice commit `96357c4b` (pushed ~21:5x, main
    `aaeb017c`). Chưa chạy trên Windows Godot.
  - [ ] N2237 `C07RepairTurretPerDefStatsProof` — Linux GREEN ~22:3x (5 key).
    Scene tới Windows theo slice commit `129eae95` (pushed ~22:5x, main
    `a921bf46`). Chưa chạy trên Windows Godot.
  - [ ] N2238 `C07RepairTowerPerDefStatsProof` — Linux GREEN ~23:34 (4 key).
    Scene tới Windows theo slice commit `f5683526` (pushed ~00:0x, main
    `8732b80b`). Chưa chạy trên Windows Godot.
  - [ ] N2239 `C07PointDefenseTurretTargetAcquireProof` — Linux GREEN ~00:38 (8 key).
    Scene tới Windows theo slice commit `7016e8d3` (pushed ~01:0x, main
    `e7ed23ca`). Chưa chạy trên Windows Godot.
  - [ ] N2240 `C07PointDefenseTurretAimShootProof` — Linux GREEN ~02:01 (8 key).
    Scene tới Windows theo slice commit `ca72f6b9` (pushed ~02:3x, main
    `480fd31c`). Chưa chạy trên Windows Godot.
  - [ ] N2241 `C07PointDefenseTurretShouldConsumeCoolantProof` — Linux GREEN ~03:13 (8 key).
    Scene tới Windows theo slice commit `64091326` (pushed ~04:0x, main
    `de65d796`). Chưa chạy trên Windows Godot.
  - [ ] N2242 `C07PointDefenseTurretLiveBulletsWiringProof` — Linux GREEN ~05:33 (8 key).
    Scene tới Windows theo slice commit `af2d4208` (pushed ~06:0x, main
    `f5bbd03c`). Chưa chạy trên Windows Godot.
  - [ ] N2243 `C07PointDefenseTurretSpawnTeamStampProof` — Linux GREEN ~09:19 (6 key).
    Scene tới Windows theo slice commit `e1fed830` (pushed ~10:0x, main
    `24bcef78`). Chưa chạy trên Windows Godot.
  - [ ] N2244 `C07PointDefenseTurretDrawProof` — Linux GREEN ~11:00 (6 key).
    Scene tới Windows theo slice commit `910e7fdf` (pushed ~11:5x, main
    `8f4a9d53`). Chưa chạy trên Windows Godot.
  - [ ] N2245 `C07PointDefenseTurretWriteReadProof` — Linux GREEN ~12:12 (8 key).
    Scene tới Windows theo slice commit `0f0683b7` (pushed ~12:5x, main
    `61a5ad16`). Chưa chạy trên Windows Godot.
  - [ ] N2246 `C07PointDefenseTurretSetStatsIconsProof` — Linux GREEN ~13:09 (8 key).
    Scene tới Windows theo slice commit `7b51999a` (pushed ~14:1x, main
    `6ac8c3ea`). Chưa chạy trên Windows Godot.
  - [ ] N2247 `C07PointDefenseTurretHitSizeRemovalProof` — Linux GREEN ~14:38 (8 key).
    Scene tới Windows theo slice commit `07100c53` (pushed ~15:3x, main
    `92f1468e`). Chưa chạy trên Windows Godot.
  - [ ] N2248 `C07PointDefenseTurretCoolantProof` — Linux GREEN ~16:4x (12 key).
    Scene tới Windows theo slice commit `997082d9` (pushed ~17:2x, main
    `7beadabe`). Chưa chạy trên Windows Godot.
  - [ ] N2249 `C07PointDefenseTurretPersistenceIntegrationProof` — Linux GREEN ~18:4x (8 key).
    Scene tới Windows theo slice commit `d6f7537d` (pushed ~20:0x, main
    `dd114d09`). Chưa chạy trên Windows Godot.
  - [ ] N2250 `C07ItemTurretAimShootProof` — Linux GREEN ~21:2x (10 key).
    Scene tới Windows theo slice commit `a2270c04` (pushed ~22:1x, main
    `9639adbc`). Chưa chạy trên Windows Godot.
  - [ ] N2251 `C07ItemTurretValidateTargetProof` — Linux GREEN ~23:1x (8 key).
    Scene tới Windows theo slice commit `0ecc5608` (pushed ~00:1x, main
    `059a737d`). Chưa chạy trên Windows Godot.
  - [ ] N2252 `C07ItemTurretBulletSpawnProof` — Linux GREEN ~01:1x (8 key).
    Scene tới Windows theo slice commit `3a846b15` (pushed ~01:5x, main
    `aba09129`). Chưa chạy trên Windows Godot.
  - [ ] N2253 `C07TurretWarmupProof` — Linux GREEN ~02:3x (8 key).
    Scene tới Windows theo slice commit `41f09353` (pushed ~03:2x, main
    `50163cc1`). Chưa chạy trên Windows Godot.
  - [ ] N2254 `C07TurretRecoilHeatProof` — Linux GREEN ~03:5x (8 key).
    Scene tới Windows theo slice commit `223fbcf0`. Chưa chạy trên Windows Godot.
  - [ ] N2255 `C07TurretShootStampProof` — Linux GREEN ~05:27 (8 key).
    Scene tới Windows theo slice commit `076e10e8`. Chưa chạy trên Windows Godot.
  - [ ] N2256 `C07TurretMultiRecoilProof` — Linux GREEN ~06:30 (8 key).
    Scene tới Windows theo slice commit `0a6a5494`. Chưa chạy trên Windows Godot.
  - [ ] N2257 `C07TurretMultiRecoilStampProof` — Linux GREEN ~08:1x (9 key).
    Scene tới Windows theo slice commit `2f244b54`. Chưa chạy trên Windows Godot.
  - [ ] N2258 `C07TurretRecoilOffsetProof` — Linux GREEN ~09:2x (8 key).
    Scene tới Windows theo slice commit `0ba552b7`. Chưa chạy trên Windows Godot.
  - [ ] N2259 `C07TurretChargeProof` — Linux GREEN ~11:2x (8 key).
    Scene tới Windows theo slice commit `e90d1466`. Chưa chạy trên Windows Godot.
  - [ ] N2260 `C07TurretUnitSyncProof` — Linux GREEN ~13:0x (8 key).
    Scene tới Windows theo slice commit `6e5acc29`. Chưa chạy trên Windows Godot.
  - [ ] N2261 `C07TurretLogicControlTimeProof` — Linux GREEN ~13:5x (8 key).
    Scene tới Windows theo slice commit `4cebe133`. Chưa chạy trên Windows Godot.
  - [ ] N2262 `C07TurretRotateSyncProof` — Linux GREEN ~14:3x (9 key).
    Scene tới Windows theo slice commit `f97d8dc0`. Chưa chạy trên Windows Godot.
  - [ ] N2263 `C07TurretHeatReqProof` — Linux GREEN ~15:3x (9 key).
    Scene tới Windows theo slice commit `7a5bbc88`. Chưa chạy trên Windows Godot.
  - [ ] N2264 `C07TurretControlProof` — Linux GREEN ~16:1x (10 key).
    Scene tới Windows theo slice commit `64c41a11`. Chưa chạy trên Windows Godot.
  - [ ] N2265 `C07TurretEfficiencyMultiplierProof` — Linux GREEN ~17:35 (9 key).
    Scene tới Windows theo slice commit `92a9a639`. Chưa chạy trên Windows Godot.
  - [ ] N2266 `C07TurretTargetPositionControlProof` — Linux GREEN ~18:2x (9 key).
    Scene tới Windows theo slice commit `a421f48a`. Chưa chạy trên Windows Godot.
  - [ ] N2267 `C07TurretSuperControlProof` — Linux GREEN ~19:3x (9 key).
    Scene tới Windows theo slice commit `5295a7ec`. Chưa chạy trên Windows Godot.
  - [ ] N2268 `C07TurretConfiguredDispatchProof` — Linux GREEN ~20:2x (12 key).
    Scene tới Windows theo slice commit `1d030ba5`. Chưa chạy trên Windows Godot.
  - [ ] N2269 `C07TurretQueuedBulletsProof` — Linux GREEN ~21:15 (12 key).
    Scene tới Windows theo slice commit `188a1ac3`. Chưa chạy trên Windows Godot.
  - [ ] N2270 `C07TurretPowerHeatFoldProof` — Linux GREEN ~23:05 (12 key).
    Scene tới Windows theo slice commit `b8e7f57b`. Chưa chạy trên Windows Godot.
  - [ ] N2271 `C07TurretChargeStateProof` — Linux GREEN ~00:3x (8 key).
    Scene tới Windows theo slice commit `a66bf630`. Chưa chạy trên Windows Godot.
  - [ ] N2272 `C07TurretCanConsumeHeatGateProof` — Linux GREEN ~01:5x (11 key).
    Scene tới Windows theo slice commit `5968f4f5`. Chưa chạy trên Windows Godot.
  - [ ] N2273 `C07TurretChargeEffectProof` — Linux GREEN ~03:20 (8 key).
    Scene tới Windows theo slice commit `62680702`. Chưa chạy trên Windows Godot.
  - [ ] N2274 `C07TurretUnitWorldPositionProof` — Linux GREEN ~04:00 (8 key).
    Scene tới Windows theo slice commit `40e856d7`. Chưa chạy trên Windows Godot.
  - [ ] N2275 `C07TurretUnitMaxHealthProof` — Linux GREEN ~05:10 (4 key).
    Scene tới Windows theo slice commit `67f55503`. Chưa chạy trên Windows Godot.
  - [ ] N2276 `C07TurretUnitHealthProof` — Linux GREEN ~06:3x (4 key).
    Scene tới Windows theo slice commit `a5ccb08e`. Chưa chạy trên Windows Godot.
  - [ ] N2277 `C07TurretIsShootingProof` — Linux GREEN ~08:3x (5 key).
    Scene tới Windows theo slice commit `23b993d8`. Chưa chạy trên Windows Godot.
  - [ ] N2278 `C07TurretLogicControlledProof` — Linux GREEN ~09:53 (5 key).
    Scene tới Windows theo slice commit `7d2d024f`. Chưa chạy trên Windows Godot.
  - [ ] N2279 `C07TurretActivationTimerProof` — Linux GREEN ~11:2x (5 key).
    Scene tới Windows theo slice commit `9bfee770`. Chưa chạy trên Windows Godot.
  - [ ] N2280 `C07TurretIsActiveProof` — Linux GREEN ~12:0x (6 key).
    Scene tới Windows theo slice commit `d523d6f6`. Chưa chạy trên Windows Godot.
  - [ ] N2281 `C07TurretCanHealProof` — Linux GREEN ~14:0x (6 key).
    Scene tới Windows theo slice commit `6865ec40`. Chưa chạy trên Windows Godot.
  - [ ] N2282 `C07TurretProgressProof` — Linux GREEN ~15:4x (5 key).
    Scene tới Windows theo slice commit `ef382162`. Chưa chạy trên Windows Godot.
  - [ ] N2283 `C07TurretSenseProof` — Linux GREEN ~17:0x (10 key).
    Scene tới Windows theo slice commit `8fda2dce`. Chưa chạy trên Windows Godot.
  - [ ] N2284 `C07BuildingCompSenseProof` — Linux GREEN ~18:0x (40 key).
    Scene tới Windows theo slice commit `bc60b186`. Chưa chạy trên Windows Godot.
  - [ ] N2285 `C07TurretStatusProof` — Linux GREEN ~10:0x (12 key).
    Scene tới Windows theo slice commit `fd76c4f`. Chưa chạy trên Windows Godot.
  - [ ] N2286 `C07BurstDrillWriteReadProof` — Linux GREEN ~10:4x (11 key).
    Scene tới Windows theo slice commit `44d5394`. Chưa chạy trên Windows Godot.
  - [ ] N2287 `C07SoundControlLoopProof` — Linux GREEN ~09:5x (10 key).
    Scene tới Windows theo slice commit `81d116f`. Chưa chạy trên Windows Godot.
  - [ ] N2288 `C07RadarIconsProof` — Linux GREEN ~12:5x (5 key).
    Scene tới Windows theo slice commit `3760228`. Chưa chạy trên Windows Godot.
  - [ ] N2289 `C07RepairTurretDrawBeamJitterProof` — Linux GREEN ~12:4x (11 key).
    Scene tới Windows theo slice commit `128c9f9`. Chưa chạy trên Windows Godot.
  - [ ] N2290 `C07RepairTurretDrawBeamPulseProof` — Linux GREEN ~13:3x (11 key).
    Scene tới Windows theo slice commit `ca0a252`. Chưa chạy trên Windows Godot.
  - [ ] N2291 `C07TurretShouldConsumeProof` — Linux GREEN ~12:4x (8 key).
    Scene tới Windows theo slice commit `4edf8ca`. Chưa chạy trên Windows Godot.
  - [ ] N2292 `C07TurretProgressProof` — Linux GREEN ~13:3x (8 key).
    Scene tới Windows theo slice commit `0573346`. Chưa chạy trên Windows Godot.
  - [ ] N2293 `C07TurretSenseProof` — Linux GREEN ~14:4x (12 key).
    Scene tới Windows theo slice commit `23a5ed1`. Chưa chạy trên Windows Godot.
  - [ ] N2294 `C07BurstDrillUpdateTileProof` — Linux GREEN ~14:0x (11 key).
    Scene tới Windows theo slice commit `b68749c`. Chưa chạy trên Windows Godot.
  - [ ] N2295 `C07BurstDrillShouldConsumeProof` — Linux GREEN ~14:5x (9 key).
    Scene tới Windows theo slice commit `fb21582`. Chưa chạy trên Windows Godot.
  - [ ] N2296 `C07BurstDrillLiquidRowsProof` — Linux GREEN ~14:5x (12 key).
    Scene tới Windows theo slice commit `ae71e71`. Chưa chạy trên Windows Godot.
  - [ ] N2297 `C07TurretMicroAccessorsProof` — Linux GREEN ~12:4x (15 key).
    Scene tới Windows theo slice commit `95973c7`. Chưa chạy trên Windows Godot.
  - [ ] N2298 `C07DrillSenseProof` — Linux GREEN ~12:4x (9 key).
    Scene tới Windows theo slice commit `230fee6`. Chưa chạy trên Windows Godot.
  - [ ] N2299 `C07SoundControlShouldPlayProof` — Linux GREEN ~13:1x (7 key).
    Scene tới Windows theo slice commit `dee32c7`. Chưa chạy trên Windows Godot.
  - [ ] N2300 `C07GameHeadlessProof` — Linux GREEN ~15:5x (6 key).
    Scene tới Windows theo slice commit `f84c402`. Chưa chạy trên Windows Godot.
  - [ ] N2301 `C07TurretEstimateDpsProof` — Linux GREEN ~11:0x (7 key).
    Scene tới Windows theo slice commit `b24ced5`. Chưa chạy trên Windows Godot.
  - [ ] N2302 `C07BurstDrillOnProximityUpdateProof` — Linux GREEN ~11:0x (11 key).
    Scene tới Windows theo slice commit `e994170`. Chưa chạy trên Windows Godot.
  - [ ] N2303 `C07RadarProgressProof` — Linux GREEN ~11:0x (4 key).
    Scene tới Windows theo slice commit `abf3dd0`. Chưa chạy trên Windows Godot.
  - [ ] N2305 `C07DrillShouldAmbientSoundProof` — Linux GREEN ~18:3x (6 check key).
    Scene tới Windows theo slice commit `647ad34`. Chưa chạy trên Windows Godot.
  - [ ] N2306 `C07SoundControlAlwaysPlayMusicProof` — Linux GREEN ~18:1x (6 check key).
    Scene tới Windows theo slice commit `2b2b51f`. Chưa chạy trên Windows Godot.
  - [ ] N2307 `C07TurretUnitProof` — Linux GREEN ~18:3x (7 check key).
    Scene tới Windows theo slice commit `c300a4b`. Chưa chạy trên Windows Godot.
  - [ ] N2308 `C07TurretUpdateTileWarmupProof` — Linux GREEN ~12:3x (15 key).
    Scene tới Windows theo slice commit `e50f45e`. Chưa chạy trên Windows Godot.
  - [ ] N2309 `C07BurstDrillSetStatsProof` — Linux GREEN ~12:3x (5 key).
    Scene tới Windows theo slice commit `10d3db6`. Chưa chạy trên Windows Godot.
  - [ ] N2310 `C07RadarWriteReadProof` — Linux GREEN ~12:3x (7 key).
    Scene tới Windows theo slice commit `4368280`. Chưa chạy trên Windows Godot.
  - [ ] N2311 `C07TurretFogRadiusProof` — Linux GREEN ~16:3x (10 key).
    Scene tới Windows theo slice commit `83bf0bc`. Chưa chạy trên Windows Godot.
  - [ ] N2312 `C07BurstDrillIconsProof` — Linux GREEN ~16:3x (6 key).
    Scene tới Windows theo slice commit `2b49c54`. Chưa chạy trên Windows Godot.
  - [ ] N2313 `C07TurretHasAmmoProof` — Linux GREEN ~00:1x (9 domain key).
    Scene tới Windows theo slice commit `3dbe237`. Chưa chạy trên Windows Godot.
  - [ ] N2314 `C07BurstDrillDrawProof` — Linux GREEN ~00:3x (12 domain key).
    Scene tới Windows theo slice commit `d7ed8c2`. Chưa chạy trên Windows Godot.
  - [ ] N2315 `C07SoundControlIsDarkProof` — Linux GREEN ~00:2x (8 domain key).
    Scene tới Windows theo slice commit `c062ccc`. Chưa chạy trên Windows Godot.
  - [ ] N2316 `C07TurretFindTargetProof` — Linux GREEN ~14:0x (14 key).
    Scene tới Windows theo slice commit `8e9ee6a`. Chưa chạy trên Windows Godot.
  - [ ] N2317 `C07BurstDrillAmbientVolumeProof` — Linux GREEN ~16:4x (8 key).
    Scene tới Windows theo slice commit `69751d1`. Chưa chạy trên Windows Godot.
  - [ ] N2318 `C07RadarCanPickupProof` — Linux GREEN ~16:4x (6 key).
    Scene tới Windows theo slice commit `52c7854`. Chưa chạy trên Windows Godot.
  - [ ] N2319 `C07TurretTrackingRangeProof` — Linux GREEN ~16:2x (10 key).
    Scene tới Windows theo slice commit `99a4c9f`. Chưa chạy trên Windows Godot.
  - [ ] N2320 `C07RadarUpdateTileProof` — Linux GREEN ~12:4x (10 key).
    Scene tới Windows theo slice commit `40e54d9`. Chưa chạy trên Windows Godot.
  - [ ] N2321 `C07RadarFogRadiusProof` — Linux GREEN ~12:4x (9 key).
    Scene tới Windows theo slice commit `205c102`. Chưa chạy trên Windows Godot.
  - [ ] N2322 `C07TurretWriteReadProof` — Linux GREEN ~19:1x (11 key).
    Scene tới Windows theo slice commit `aedbfdd`. Chưa chạy trên Windows Godot.
  - [ ] N2323 `C07DrillAmbientVolumeProof` — Linux GREEN ~19:1x (8 key).
    Scene tới Windows theo slice commit `f26a03d`. Chưa chạy trên Windows Godot.
  - [ ] N2327 `C07RadarDrawProof` — Linux GREEN ~19:2x (11 key).
    Scene tới Windows theo slice commit `c21704a`. Chưa chạy trên Windows Godot.
  - [ ] N2328 `C07TurretIsActiveProof` — Linux GREEN ~20:3x (11 key).
    Scene tới Windows theo slice commit `40e8152`. Chưa chạy trên Windows Godot.
  - [ ] N2332 `C07DrillSetStatsProof` — Linux GREEN ~20:3x (12 key).
    Scene tới Windows theo slice commit `38fd39d`. Chưa chạy trên Windows Godot.
  - [ ] N2333 `C07RadarDrawSelectProof` — Linux GREEN ~20:2x (10 key).
    Scene tới Windows theo slice commit `ef121c8`. Chưa chạy trên Windows Godot.
  - [ ] N2340 `C07TurretMinRangeProof` — Linux GREEN ~21:4x (10 key).
    Scene tới Windows theo slice commit `a3ed3fe`. Chưa chạy trên Windows Godot.
  - [ ] N2341 `C07DrillDrawSelectProof` — Linux GREEN ~22:0x (12 key).
    Scene tới Windows theo slice commit `8dcc205`. Chưa chạy trên Windows Godot.
  - [ ] N2342 `C07RadarDrawPlaceProof` — Linux GREEN ~22:1x (13 key).
    Scene tới Windows theo slice commit `c9735cb`. Chưa chạy trên Windows Godot.
  - [ ] N2506 `C07TurretSenseObjectProof` — Linux GREEN ~20:05 (6 key).
    Scene tới Windows theo slice commit `51258c1e`. Chưa chạy trên Windows Godot.
  - [ ] N2507 `C07TurretLogicSenseDispatchProof` — Linux GREEN ~21:47 (6 key).
    Scene tới Windows theo slice commit `39b0231b`. Chưa chạy trên Windows Godot.
  - [ ] N2508 `C07TurretLogicSenseContentProof` — Linux GREEN ~23:30 (6 key).
    Scene tới Windows theo slice commit `c1405c4e`. Chưa chạy trên Windows Godot.
  - [ ] N2509 `C07TurretLogicSenseSizeProof` — Linux GREEN ~01:35 (6 key).
    Scene tới Windows theo slice commit `7bf2630f`. Chưa chạy trên Windows Godot.
  - [ ] N2510 `C07TurretLogicSenseLAccessProof` — Linux GREEN ~03:16 (6 key).
    Scene tới Windows theo slice commit `a86bd7a6`. Chưa chạy trên Windows Godot.
  - [ ] N2511 `C07BuildingCompSenseDeadProof` — Linux GREEN ~05:18 (6 key).
    Scene tới Windows theo slice commit `dcca355e`. Chưa chạy trên Windows Godot.
  - [ ] N2512 `C07BuildingCompSenseHealthProof` — Linux GREEN ~06:1x (6 key).
    Scene tới Windows theo slice commit `d0d4bbd7`. Chưa chạy trên Windows Godot.
  - [ ] N2513 `C07BuildingCompSenseTotalItemsProof` — Linux GREEN ~07:35 (6 key).
    Scene tới Windows theo slice commit `1d726f35`. Chưa chạy trên Windows Godot.
  - [ ] N2514 `C07BuildingCompSensePowerNetInProof` — Linux GREEN ~09:19 (6 key).
    Scene tới Windows theo slice commit `05ee5b98`. Chưa chạy trên Windows Godot.
  - [ ] N2515 `C07BuildingCompSensePowerNetOutProof` — Linux GREEN ~11:02 (6 key).
    Scene tới Windows theo slice commit `7a7bd733`. Chưa chạy trên Windows Godot.
  - [ ] N2516 `C07BuildingCompSensePowerNetStoredProof` — Linux GREEN ~11:53 (6 key).
    Scene tới Windows theo slice commit `8f09495d`. Chưa chạy trên Windows Godot.
  - [ ] N2517 `C07BuildingCompSensePowerNetCapacityProof` — Linux GREEN ~12:40 (6 key).
    Scene tới Windows theo slice commit `d1cab0a5`. Chưa chạy trên Windows Godot.
  - [ ] N2518 `C07BuildingCompSenseCameraProof` — Linux GREEN ~14:15 (8 key).
    Scene tới Windows theo slice commit `16a4c589`. Chưa chạy trên Windows Godot.
  - [ ] N2519 `C07BuildingCompSenseWiringProof` — Linux GREEN ~15:00 (15 key).
    Scene tới Windows theo slice commit `f7db9a06`. Chưa chạy trên Windows Godot.
  - [ ] N2520 `C07TurretSenseFrameStampProof` — Linux GREEN ~16:51 (10 key).
    Scene tới Windows theo slice commit `653a5c2f`. Chưa chạy trên Windows Godot.
  - [ ] N2521 `C07TurretAmmoItemsStampProof` — Linux GREEN ~18:33 (8 key).
    Scene tới Windows theo slice commit `f1c3c133`. Chưa chạy trên Windows Godot.
  - [ ] N2522 `C07TurretPowerGraphLastValuesStampProof` — Linux GREEN ~19:49 (8 key).
    Scene tới Windows theo slice commit `a9cae2a9`. Chưa chạy trên Windows Godot.
  - [ ] N2523 `C07TurretControlledStampProof` — Linux GREEN ~21:46 (5 key).
    Scene tới Windows theo slice commit `80bb3601`. Chưa chạy trên Windows Godot.
  - [ ] N2524 `C07TurretShouldConsumeProof` — Linux GREEN ~23:34 (5 key).
    Scene tới Windows theo slice commit `5b4d3ed4`. Chưa chạy trên Windows Godot.
  - [ ] N2525 `C07TurretCoolingProof` — Linux GREEN ~02:19 (5 key).
    Scene tới Windows theo slice commit `c4fb3409`. Chưa chạy trên Windows Godot.
  - [ ] N2526 `C07TurretRangeProof` — Linux GREEN ~04:31 (8 key).
    Scene tới Windows theo slice commit `cf949d7a`. Chưa chạy trên Windows Godot.
  - [ ] N2527 `C07TurretStatusProof` — Linux GREEN ~06:16 (8 key).
    Scene tới Windows theo slice commit `bd0ea3c8`. Chưa chạy trên Windows Godot.
  - [ ] N2528 `C07TurretEstimateDpsProof` — Linux GREEN ~08:46 (8 key).
    Scene tới Windows theo slice commit `901a3e8a`. Chưa chạy trên Windows Godot.
  - [ ] N2529 `C07BulletTypeEstimateDpsProof` — Linux GREEN ~10:45 (8 key).
    Scene tới Windows theo slice commit `a1edad54`. Chưa chạy trên Windows Godot.
  - [ ] N2530 `C07TurretCanControlProof` — Linux GREEN ~11:10 (8 key).
    Scene tới Windows theo slice commit `611231fe`. Chưa chạy trên Windows Godot.
  - [ ] N2531 `C07TurretFogRadiusProof` — Linux GREEN ~12:51 (8 key).
    Scene tới Windows theo slice commit `34cbcc90`. Chưa chạy trên Windows Godot.
  - [ ] N2532 `C07TurretDrawrotProof` — Linux GREEN ~14:21 (8 key).
    Scene tới Windows theo slice commit `4aedbbf6`. Chưa chạy trên Windows Godot.
  - [ ] N2533 `C07UnitTypeEstimateDpsProof` — Linux GREEN ~16:07 (8 key).
    Scene tới Windows theo slice commit `33a284de`. Chưa chạy trên Windows Godot.
  - [ ] N2534 `C07WeaponDpsProof` — Linux GREEN ~17:54 (8 key).
    Scene tới Windows theo slice commit `fb8a6ab5`. Chưa chạy trên Windows Godot.
  - [ ] N2535 `C07WeaponShotsPerSecProof` — Linux GREEN ~19:30 (8 key).
    Scene tới Windows theo slice commit `7f61f2d8`. Chưa chạy trên Windows Godot.
  - [ ] N2536 `C07UnitTypeWeaponsDpsSumProof` — Linux GREEN ~21:13 (8 key).
    Scene tới Windows theo slice commit `3a6481d9`. Chưa chạy trên Windows Godot.
  - [ ] N2537 `C07WeaponDrawOutlineProof` — Linux GREEN ~22:05 (8 key).
    Scene tới Windows theo slice commit `2e49bd95`. Chưa chạy trên Windows Godot.
  - [ ] N2538 `C07WeaponDrawProof` — Linux GREEN ~01:30 (8 key).
    Scene tới Windows theo slice commit `20e10b76`. Chưa chạy trên Windows Godot.
  - [ ] N2539 `C07WeaponRangeProof` — Linux GREEN ~03:15 (4 key).
    Scene tới Windows theo slice commit `19b5a529`. Chưa chạy trên Windows Godot.
  - [ ] N2540 `C07WeaponUpdateDecayProof` — Linux GREEN ~05:15 (11 key).
    Scene tới Windows theo slice commit `27a829fe`. Chưa chạy trên Windows Godot.
  - [ ] N2541 `C07WeaponUpdateAimProof` — Linux GREEN ~07:15 (9 key).
    Scene tới Windows theo slice commit `fcd53003`. Chưa chạy trên Windows Godot.
  - [ ] N2542 `C07WeaponCooldownTimeDefaultProof` — Linux GREEN (2 key).
    Scene tới Windows theo merge commit `0bb09aef` (merge 1: remote
    N2542 heat-decay function trimmed, chỉ giữ field decl
    `cooldownTime = 20f;`; proof cũ `C07WeaponUpdateHeatProof` đã drop).
    Chưa chạy trên Windows Godot.
  - [ ] N2543 `C07WeaponSideFlipDefaultsProof` — Linux GREEN (5 key).
    Scene tới Windows theo merge commit `891d76d8` (merge 2: remote
    N2543 side-flip function trimmed, chỉ giữ comment + 4 field decl;
    proof cũ `C07WeaponUpdateSideFlipProof` đã drop). Chưa chạy trên
    Windows Godot.
  - [ ] N2544 `C07WeaponInitProof` — Linux GREEN ~11:45 (4 key).
    Scene tới Windows theo slice commit `700cdf91`. Chưa chạy trên Windows Godot.
  - [ ] N2455 `C07WaveSpawnerGetFirstSpawnProof` — Linux GREEN 2026-11-24 ~05:32 (8 key).
    Scene tới Windows theo slice commit `def371c6`. Chưa chạy trên Windows Godot.
  - [ ] N2456 `C07TeamGetProof` — Linux GREEN 2026-11-24 ~13:35 (8 key).
    Scene tới Windows theo slice commit `757172b2`. Chưa chạy trên Windows Godot.
  - [ ] N2457 `C07SpawnGroupEqualsProof` — Linux GREEN 2026-11-24 ~14:08 (10 key).
    Scene tới Windows theo slice commit `c95cff4e`. Chưa chạy trên Windows Godot.
  - [ ] N2460 `C07GameStatsProof` — Linux GREEN 2026-11-24 ~17:40 (8 key).
    Scene tới Windows theo slice commit `663d9520`. Chưa chạy trên Windows Godot.
  - [ ] N2458 `C07RulesModeProof` — Linux GREEN 2026-11-24 ~17:40 (8 key).
    Scene tới Windows theo slice commit `e4ef9814`. Chưa chạy trên Windows Godot.
  - [ ] N2464 `C07RulesUnitBuildSpeedProof` — Linux GREEN 2026-11-25 ~06:40 (8 key).
    Scene tới Windows theo slice commit `07ad40e7`. Chưa chạy trên Windows Godot.
  - [ ] N2465 `C07RulesIsBannedProof` — Linux GREEN 2026-11-25 ~11:01 (8 key).
    Scene tới Windows theo slice commit `14caa79e`. Chưa chạy trên Windows Godot.
  - [ ] N2466 `C07RulesUnitActivationDelayProof` — Linux GREEN 2026-11-25 ~13:35 (8 key).
    Scene tới Windows theo slice commit `62c64a78`. Chưa chạy trên Windows Godot.
  - [ ] N2467 `C07RulesHasEnvProof` — Linux GREEN 2026-11-25 ~17:37 (8 key).
    Scene tới Windows theo slice commit `0e16d85b`. Chưa chạy trên Windows Godot.
  - [ ] N2468 `C07RulesUnitMineSpeedProof` — Linux GREEN 2026-11-25 ~19:52 (8 key), commit 1b7101b8.
  - [ ] N2469 `C07RulesIsBannedUnitProof` — Linux GREEN 2026-11-25 ~22:51 (8 key), commit dbf973de.
    Scene tới Windows theo slice commit (chưa commit — main thread điền hash khi commit). Chưa chạy trên Windows Godot.
  - [ ] N2470 `C07RulesBlockHealthProof` — Linux GREEN 2026-11-26 ~01:16 (8 key).
    Scene tới Windows theo slice commit `d04a6ac3`. Chưa chạy trên Windows Godot.
  - [ ] N2463 `C07TeamCompareToProof` — Linux GREEN 2026-11-25 ~03:51 (8 key).
    Scene tới Windows theo slice commit `d508da77`. Chưa chạy trên Windows Godot.
  - [ ] N2462 `C07RulesUnitDamageProof` — Linux GREEN 2026-11-25 ~01:20 (8 key).
    Scene tới Windows theo slice commit `7713cfa7`. Chưa chạy trên Windows Godot.
  - [ ] N2461 `C07RulesBuildRadiusProof` — Linux GREEN 2026-11-24 ~23:15 (8 key).
    Scene tới Windows theo slice commit `d0dcac23`. Chưa chạy trên Windows Godot.
  - [ ] N2459 `C07RulesUnitHealthProof` — Linux GREEN 2026-11-24 ~20:30 (8 key).
    Scene tới Windows theo slice commit `9edd36f1`. Chưa chạy trên Windows Godot.
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
