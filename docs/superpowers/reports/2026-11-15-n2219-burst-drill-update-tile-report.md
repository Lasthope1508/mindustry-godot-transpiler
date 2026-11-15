# N2219 BurstDrill updateTile Advance — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 4 — wave advances-1, integration branch `integration/wave-advances-1-n2219-n2223`, base `2b6e6a33`).

## Source

- BurstDrillBuild.updateTile (BurstDrill.java:~73-122 — worker verified exact lines by grep): dominantItem null → return; invertTime decay `invertTime -= delta() / invertedTime` (invertedTime 200f, :26); timerDump dump (deferred — no timer infra); drillTime = getDrillTime(dominantItem); smoothProgress lerpDelta 0.1f toward progress/(drillTime-20f); gate branch (items.total() <= capacity - dominantItems && dominantItems > 0 && efficiency > 0): warmup approachDelta 0.01f toward progress/drillTime, speed = lerp(1, liquidBoostIntensity, optionalEfficiency) * efficiency, timeDrilled += speedCurve(progress/drillTime) * speed, lastDrillSpeed = 1/drillTime * speed * dominantItems, progress += delta() * speed; else branch: warmup → 0, lastDrillSpeed = 0, return; offload branch (dominantItems > 0 && progress >= drillTime && items.total() < capacity): offload × dominantItems, invertTime = 1f, progress %= drillTime; effects (shake/sound/drillEffect) deferred — presentation.
- getDrillTime override BurstDrill.java:53-55: `drillTime / drillMultipliers.get(item, 1f)` (NO hardness term — NOT Drill.java:170-172).
- speedCurve = Interp.pow2In (BurstDrill.java:19; pow2In = ratio², Interp.java:29 + PowIn.apply).
- BuildingComp.java:2274-2278 — updateConsumption runs BEFORE updateTile; advance sits in the consumption block after `apply_update_consumption_state`, enabled-gated (N2195 precedent).

## Implementation

- `SourceBurstDrillBuildState.gd`:
  - Frame keys: progress, warmup, time_drilled, last_drill_speed, smooth_progress, invert_time (default 0f).
  - Pure `source_burst_drill_update_tile_state(frame, source_delta, time_scale, drill_time, liquid_boost_intensity, drill_multiplier, dominant_item_name, item_capacity)` → 10 result symbols: progress, warmup, time_drilled, last_drill_speed, smooth_progress, invert_time, items, offloaded, drill_time, speed.
  - approachDelta/lerpDelta use raw Time.delta; invertTime decay/progress use delta() = Time.delta × timeScale; timeDrilled has NO delta factor (exactly Java).
  - Per-def tables in the driver (catalog lacks impact drillTime — `60f * 12f` is an unevaluated expression — and lacks liquidBoostIntensity for both defs): `SOURCE_BURST_DRILL_DRILL_TIME` {eruption 281.25, impact 720.0}, `SOURCE_BURST_DRILL_LIQUID_BOOST_INTENSITY` {2.0, 1.75}, fallback Drill class defaults (300 / 1.6f). Beryllium multiplier 2f (Blocks.java:3083/:3114).
  - Offload uses the fallback branch `handleItem(self(), item)` via `add_item_state` (base-Drill driver :290 precedent); neighbor routing deferred.
  - Dominant item name resolved via `load()` instead of `preload()` (preload would cycle: Factory preloads BurstDrill, DrillRuntime preloads Factory — `load()` precedent in SourceDrillConsumptionRuntimeState.gd:299).
  - Fixed 1 wrong comment in the driver ("runs updateConsumption through super.updateTile()") → real Building.update() order; BurstDrill override does not call super.updateTile().

## Commits

- Slice `c48e365b` (worker-N2219, branch `slice/N2219-burst-drill-update-tile`, 5 files +776/−8; đã push 16:19, remote tip c48e365b).
- Integration cherry-pick `97a5be46`; SSOT gộp `bde67d63` (wave advances-1): 11470/1664/1587/2965 (slice riêng +10/+1/+1/+2 → 11445/1660/1583/2957).

## Tests

- RED đúng mẫu trước GREEN (2× KeyError N2219, 1× thiếu function, 1× Godot-absent).
- Post-register: 3/4 PASS + proof FAIL đúng `AssertionError: unexpectedly None` (Godot-absent; `which godot` rc=1, không chạy Godot).
- SSOT: register exit 0, **+10/+1/+1/+2 → 11445/1660/1583/2957; audit totalSourceFunctions 1336, legacy 0**.
- **Exact exprs: 52**, tất cả verify verbatim trong upstream (BurstDrill/Drill/BuildingComp/Blocks/Block.java).
- **DEFERRED: 258** — copy nguyên văn DEFERRED-after-wave-turrets.py bằng script, REMOVE entry "BurstDrill updateTile advance (…)", ADD 1 entry: timerDump dump + offload effects + offload neighbor routing (BurstDrill.java:83-85; :114-118; BuildingComp.java:1001-1017).
- **Shard đổi: 4 production shards** (production_api_contracts + production_slices + production_state_schema + production_symbols) + 4 file SSOT chính.
- Neighbours cùng family (N2149 power + N2203 gate) vẫn 3/4 PASS — không vỡ.

## Godot proof (debt — chưa chạy, chờ agent Godot test)

- `C07BurstDrillUpdateTileProof` — 6 keys: progress_advances_when_efficient, warmup_approaches_progress_ratio, offload_at_drill_time (beryllium 2x: effective drillTime 140.625, offload 5, progress → 0.375), invert_time_set_on_offload (set 1f + decay 1/200/tick), last_drill_speed_zero_when_blocked (efficiency 0 và store đầy), live_tick_advances_progress (eruption-drill live, power 0.5 → efficiency 0.5, progress 0.75). Ghi nợ trong GOAL.md §5 + handoff + STATUS.md.
