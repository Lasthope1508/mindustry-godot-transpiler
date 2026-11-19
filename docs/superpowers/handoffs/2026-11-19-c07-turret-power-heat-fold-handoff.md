# Handoff — N2270 Turret power heat fold (C07) [DONE, chờ commit + push]

## Status: DONE, chờ commit + push (2026-11-19 ~23:45 +07, lượt cron 23:45) — targeted 147 passed + proof matches:true 15/15 + register --verify 16/16 + gate Ran 6173, failures=220 toàn Godot-absent (đã xác minh độc lập).

## Scope (đã khóa, xác minh từ đĩa)

- Slice Turret power heat fold (Turret.java:53/:55, :674-679): `public float heatRequirement = -1f;` (:53); `public float maxHeatEfficiency = 3f;` (:55); `public void updateEfficiencyMultiplier(){` (:674) / `if(heatRequirement > 0){` (:675) / `efficiency *= Math.min(Math.max(heatReq / heatRequirement, cheating() ? 1f : 0f), maxHeatEfficiency);` (:676) / `}` (:677-679) — override BuildingComp.java:1932-1935 `float scale = efficiencyScale();` / `efficiency *= scale;` / `optionalEfficiency *= scale;` — override thay thế base, không gọi super, không chạm optionalEfficiency (N2265 đã pin). `updateConsumption()` gọi `updateEfficiencyMultiplier()` (:1949 cheating path / :1996 normal path); `BuildingComp.update()` gọi `updateConsumption()` TRƯỚC `updateTile()` (:2274-2278) nên fold đọc heatReq của TICK TRƯỚC (heatReq chỉ tính lại sau ở updateTile :538-540, N2263).
  - Catalog: afflict `heatRequirement = 20f;` / `maxHeatEfficiency = 1f;` (Blocks.java:5122-5123); malign `heatRequirement = 144f;` / `maxHeatEfficiency = 1f;` (Blocks.java:6240-6241). Chỉ afflict và malign set heatRequirement > 0 trong số các turret; mọi turret khác đọc class default -1.0 / 3.0 → guard :675 off, efficiency giữ nguyên. Duo không set (Blocks.java:3257-3331) → guard off (đã pin ở N2265).
- 1 pure function `source_turret_heat_requirement_state(block)` (1 param, 2 keys: heat_requirement, max_heat_efficiency) trong `SourceTurretBuildState.gd:888` — null block hoặc catalog không có override thì đọc class default -1.0 / 3.0; ngược lại đọc giá trị catalog (afflict 20 / 1, malign 144 / 1). Wiring fold vào driver tick `source_turret_tick_buildings_state` (:1006-1008): gọi pure function lấy heat_requirement / max_heat_efficiency, rồi gọi lại `source_turret_efficiency_multiplier_state` của N2265 với (frame efficiency default 1.0, heat_requirement, frame heat_req default 0.0 — tick trước, frame cheating, max_heat_efficiency), stamp frame["efficiency"]. frame["heat_req"] vẫn ở field default 0.0 (live calculateHeat scan chờ slice riêng, N2263) → afflict / malign không cheating, không heater thì fold về 0 — đúng hành vi no-heater trung thực. Nhánh này đã loại cheating team (nhánh consumption N2148) nên floor cheating 1.0 không chạm được live ở đây — và dù sao cũng giống hệt, vì cap của cả hai def đều là 1.0.
- 12 proof keys: catalog_afflict_20_1, catalog_malign_144_1, read_afflict_20_1, read_malign_144_1, read_default_neg1_3, fold_afflict_no_heat_zero, fold_afflict_half_heat, fold_afflict_full_heat_1, fold_afflict_live, fold_afflict_cheating_floor_one, fold_malign_partial, fold_malign_full_heat_1.
- SSOT sau GREEN (đo từ đĩa): symbols 11640 (+2), Done 1720 (+1), contracts 1654 (+1), schemas 3099 (+2) → 11640/1720/1654/3099. Shard defense: slices 197 (+1), contracts 196 (+1) — slice đi shard defense vì java_source là Turret.java (tiền lệ N2265/N2266); comp giữ nguyên 557/461.

## GREEN (đã xong, đã xác minh độc lập lượt này)

- `python3 register_c07_turret_power_heat_fold.py --verify`: **16/16 exprs present**, exit 0.
- Targeted neighbours: **147 passed (472.42s)**, gồm 4 test mới test_c07_turret_power_heat_fold.py. Wiring: **32/32 OK (122.94s)**.
- Proof JSON đọc trực tiếp: matches:true, 15/15 true (12 keys + matches + registry_valid + one_headquarter_per_ssot). Proof chạy live trong neighbours test, port 7777 đã trống.
- `git diff --check` OK (chạy lại sau khi viết docs).
- File thay đổi (chưa commit): SourceTurretBuildState.gd (M), MindustryContentRegistry.gd (M), 9 SSOT JSON (M: registry, ledger, contracts, schema + content_registry + content_registry_blocks + defense_slices + defense_api_contracts; audit report tái sinh giống hệt, không diff), content_registry.py (M), test + register + proof .gd/.tscn + handoff/report này (mới). Proof .json không stage (theo quy tắc). Không stage/commit gì ở bước GREEN.
- Gate (log tools/mindustry_godot_transpiler/full-suite-n2270-gate.log, chuỗi n2270-chain-main.sh, GATE-START 16:12:14Z, GATE-EXIT 1 16:31:11Z): Ran 6173 trong 1134.674s, failures=220, skipped=5, errors=0 — xác minh độc lập từ log: 220 FAIL header = 220 × "unexpectedly None", 0 KeyError, 0 return_schema_linkage, 0 ERROR, toàn Godot-absent (+4 tests / +1 failure so với gate N2269, đúng 4 test mới; +1 failure là test reference-graph của chính N2270, Godot-absent trong môi trường gate).

## Tiếp theo (main thread)

- Commit + push N2270 (5 commit theo mẫu N2269: slice + docs + GOAL + status + hashes), rồi làm N2271 từ deferred list (xem dưới).

## Deferred (không đổi, trừ power heat fold đang làm)

- Efficiency fold cho def khác ngoài duo (afflict 20f / malign 144f là PowerTurret, consumption branch riêng) — DONE bởi slice này (N2270); là mục deferred đầu tiên trong handoff N2269.
- calculateHeat live proximity scan (BuildingComp.java:410-461) — BLOCKED, live entity scan.
- Turret control() shootp live wiring — logic executor chưa có trong driver, không driver tick nào resolve target_position_deferred.
- Turret charge sound / charge effect cho firstShotDelay > 0 — effects/sound chờ slice riêng; N2269 chỉ pin nhánh firstShotDelay > 0 tồn tại (Turret.java:747-748).
- Turret configured() handler bodies — handler là Cons2 closure do block đăng ký (Block.config, Block.java:926-929); dispatch chỉ báo handler chạy. Duo không có handler nên không có body nào để model cho duo.
- Unit maxHealth/health re-sync từ tile() (cần live tile_health — frame chưa có key health; không có damage model cho turret building).
- Unit world position từ set(tile) (cần quyết định representation world-position; frame làm việc theo cell).
- effects/sound, findTarget (BLOCKED — live entity scan), các def ItemTurret khác ngoài duo.
- Live coolant driver wiring + suppression/targets live list vẫn BLOCKED (catalog capture).
