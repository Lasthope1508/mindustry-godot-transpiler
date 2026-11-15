# N2223 WallCrafter updateTile Advance — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 4 — wave advances-1, integration branch `integration/wave-advances-1-n2219-n2223`, base `2b6e6a33`).

## Source

- WallCrafterBuild.updateTile (WallCrafter.java:187-223): super.updateTile(); cons = shouldConsume(); itemValid = itemConsumer != null && itemConsumer.efficiency(this) > 0; warmup approachDelta → num(efficiency > 0) at 1/40f; eff = getEfficiency(tile.x, tile.y, rotation, ...) * lerp(1, liquidBoostIntensity, hasLiquidBooster ? optionalEfficiency : 0) * (itemValid ? itemBoostIntensity : 1f); if itemValid && eff*efficiency > 0 && timer(timerUse, boostItemUseTime/timeScale): consume() deferred (timer + item booster); lastEfficiency = eff * timeScale * efficiency; if cons && (time += edelta() * eff) >= drillTime: offload(output); time %= drillTime; totalTime += edelta() * warmup * (eff <= 0 ? 0 : 1); timerDump dump(output) deferred.
- getEfficiency (WallCrafter.java:141-180): adjacent solid-tile scan — no port helper yet; live fill deferred.
- liquidBoostIntensity 1.6f (:35), itemBoostIntensity 1.6f (:47). output = sand (:43, Blocks.java:3009/:3023 — worker corrected :3024). drillTime defs: cliff-crusher **110f** (NOT 48f as the scope said), large-cliff-crusher 48f (Blocks.java:3020).
- **Finding: `hasLiquidBooster` = false for BOTH defs** — the large def's hydrogen consumer has no `.boost()` (Blocks.java:3028; only the commented-out nitrogen and the graphite itemConsumer have `.boost()`). This contradicts the N2170/N2201 driver comments calling hydrogen "a booster" — worker kept the old comments (out of scope) and recorded the verified fact in the new code/register; needs a fix slice/comment cleanup (coordinator serial).
- BuildingComp.java:2274-2278 — updateConsumption runs BEFORE updateTile.

## Implementation

- `SourceWallCrafterBuildState.gd`:
  - Frame keys: time, warmup, total_time, last_efficiency (+ eff, offloaded, items written). Frame inputs: `efficiency_factor` (default 0.0), `item_valid`, `has_liquid_booster` (default false).
  - Pure `source_wall_crafter_update_tile_advance_state(frame, source_delta, time_scale, drill_time, output_item, item_capacity)`: warmup approachDelta 1/40f; eff = frame `efficiency_factor` × lerp(1, 1.6, has_liquid_booster ? optional_efficiency : 0) × (item_valid ? 1.6 : 1); last_efficiency = eff × time_scale × efficiency; time advances ONLY when cons (Java :213 short-circuit — store full means time stands still), offload + `time %= drillTime` via existing helper `inventory.offload_item_state` (fallback own inventory, the handleItem path BuildingComp :1014/:860-861); totalTime uses the UPDATED warmup, no cons guard. Driver calls after the consumption fold, enabled-gated.
  - drillTime/output/capacity read from the catalog per def (110f/sand/10, 48f/sand/20).
  - Pin drift fixed vs brief/scope: drillTime class default WallCrafter :33 (not :32); build fields :184 (not :185); hasLiquidBooster init :106 (not :119); large output Blocks :3023 (not :3024); cliff-crusher drillTime 110f (not 48f).

## Commits

- Slice `1827aaf6` (worker-N2223, branch `slice/N2223-wall-crafter-update-tile`, 5 files +712/−5; đã push 16:21, remote tip 1827aaf6).
- Integration cherry-pick `c1ed1449`; SSOT gộp `bde67d63` (wave advances-1): 11470/1664/1587/2965 (slice riêng +7/+1/+1/+2 → 11442/1660/1583/2957).

## Tests

- RED đúng mẫu trước GREEN (KeyError N2223 + thiếu advance function).
- Post-register: 3/4 PASS + proof FAIL đúng `AssertionError: unexpectedly None` (Godot-absent; `which godot` rc=1, không chạy Godot).
- SSOT: register exit 0, **+7/+1/+1/+2 → 11442/1660/1583/2957; audit totalSourceFunctions 1336, legacy 0**.
- **Exact exprs: 50**, verify verbatim 0 missing trên 4 file upstream (WallCrafter/BuildingComp/Blocks/Block).
- **DEFERRED: 258** — REMOVE entry "WallCrafter updateTile advance (…)", ADD 1 entry: live fill (getEfficiency scan WallCrafter.java:141-180; timerUse consume :207-209; timerDump dump :220-222; offload neighbor routing BuildingComp.java:1001-1014; updateEffect chance :196-205; disabled early return :1954-1957) — including the note that the advance only runs when enabled (pragmatic choice per the N2195 fix) and a live crusher accumulates no time until the getEfficiency fill lands.
- **Shard đổi: 4 production shards** (production_api_contracts + production_slices + production_state_schema + production_symbols) + 4 file SSOT chính. Generated diff purely additive (+901 dòng, 0 xóa).
- Family regression: N2170 power + N2201 gate vẫn 3/4, fail duy nhất là proof Godot-absent của chính chúng.

## Godot proof (debt — chưa chạy, chờ agent Godot test)

- `C07WallCrafterUpdateTileProof` — 6 keys: warmup_approaches_one_when_efficient, time_advances_with_eff_and_edelta, offload_at_drill_time, last_efficiency_folds_eff_timescale, total_time_advances_with_warmup, live_tick_advances_warmup_and_time (live-tick key instead of the brief's `frame_defaults_zero` example — defaults are covered by static `frame.get(...)` asserts in the row-state test; the live key proves driver wiring). Ghi nợ trong GOAL.md §5 + handoff + STATUS.md.
