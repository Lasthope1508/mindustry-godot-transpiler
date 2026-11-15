# N2221 Pump updateTile Advance — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 4 — wave advances-1, integration branch `integration/wave-advances-1-n2219-n2223`, base `2b6e6a33`).

## Source

- PumpBuild.updateTile (Pump.java:161-182): if efficiency > 0 && liquidDrop != null: maxPump = min(liquidCapacity - liquids.get(liquidDrop), amount * pumpAmount * edelta()); liquids.add(liquidDrop, maxPump); consTimer += delta(); if consTimer >= consumeTime (60f*5f, :22): consume(); consTimer %= 1f; warmup approachDelta toward (maxPump > 0.001f ? 1 : 0) at warmupSpeed 0.019f (:23); else warmup → 0; totalProgress += warmup * Time.delta; if liquidDrop != null: dumpLiquid(liquidDrop) deferred.
- consumeTime 60f*5f (Pump.java:22), warmupSpeed 0.019f (:23), amount field (:113, set by onProximityUpdate).
- pumpAmount 0.2f class default (Pump.java:20); def constants: rotary 0.2f, impulse 0.22f. Capacity def constants rotary 80f / impulse 200f.
- BuildingComp.java:2274→2277 — updateConsumption runs BEFORE updateTile.

## Implementation

- `SourceMechanicalPumpBuildState.gd`:
  - Frame keys: warmup, total_progress, cons_timer.
  - Pure `source_mechanical_pump_update_tile_advance_state(frame, liquid_drop, amount, liquids, liquid_capacity, pump_amount, source_delta, time_scale, liquid_id_by_name)` → 5 keys in Java order: max_pump, liquid_amount, cons_timer, warmup, total_progress. The pure function does NOT mutate the store — the driver does `liquids.add` via `source_add_state` (matches `LiquidModule.add`, LiquidModule.java:84-91).
  - Delta distinction exactly Java: maxPump/consTimer use `delta() = Time.delta * timeScale` (via edelta), while warmup approachDelta and totalProgress use raw `Time.delta` (Mathf.java:420-422, Pump.java:176).
  - liquidDrop/amount reuse the per-tick `source_pump_proximity_state` (N2087) from N2205 — no new scan.
  - `consume()` is a documented no-op (Pump.java:165; both defs rotary/impulse have no item consumer — Blocks.java:2304-2320).
  - Driver wired after consumption, in the N2205 block, enabled-gated per the N2195 precedent + fix 7fa5d6ad (noted: Java runs updateTile even when disabled; the driver-wide disabled-early-return slice will remove this gate).
  - Only the placed-pump driver is wired — the scenario path (SourcePumpRuntimeState) is untouched (N2205 already deferred it separately).

## Commits

- Slice `439604f7` (worker-N2221, branch `slice/N2221-pump-update-tile`, 5 files +962/−18; đã push 16:17, remote tip 439604f7).
- Integration cherry-pick `e94b044a`; SSOT gộp `bde67d63` (wave advances-1): 11470/1664/1587/2965 (slice riêng +5/+1/+1/+2 → 11440/1660/1583/2957).

## Tests

- Post-register: 3/4 PASS + proof FAIL đúng `AssertionError: unexpectedly None` (Godot-absent; `which godot` rc=1, không chạy Godot).
- SSOT: register exit 0, **+5/+1/+1/+2 → 11440/1660/1583/2957; audit totalSourceFunctions 1336, legacy 0**.
- **Exact exprs: 23**, tất cả verify verbatim bằng grep (23/23 OK).
- **DEFERRED: 258** — REMOVE entry "Pump updateTile advance (…)", ADD 1 entry: dumpLiquid on the placed-pump path (dumpLiquid(liquidDrop), Pump.java:178-180 — the scenario path's `source_pump_dump_liquid_state` helper is bound to the scenario frame + its own capacity, so the placed pump keeps pumped liquid until a dedicated dump slice). Note: the older "Pump warmup / totalProgress rows" entry is now STALE (N2221 implements warmup/totalProgress) — coordinator removes it from the merged list at integration.
- **Shard đổi: 4 production shards** (production_slices 56→57, production_symbols 464→469, production_api_contracts 50→51, production_state_schema 52→53, input-only like the N2200–N2205 precedent) + 4 file SSOT chính.
- Neighbours cùng family (N2154 power + N2205 gate) đều 3/4 PASS — không vỡ.

## Godot proof (debt — chưa chạy, chờ agent Godot test)

- `C07MechanicalPumpUpdateTileProof` — 6 keys: max_pump_capped_by_remaining_capacity (capped 0.1 when store 79.9/80; uncapped 0.8), warmup_approaches_one_when_pumping (60 ticks → 1.0), total_progress_advances_with_warmup (10 ticks warmup 1.0 → 10.0; + pin totalProgress uses the NEW warmup after approachDelta: 0.5→0.481), cons_timer_advances_and_wraps (10→11; 299.5→0.5 wrap; 299→0.0 exact; timeScale 2.0 → 12.0; efficiency 0 stands still), no_pump_without_liquid_drop (empty frame defaults 0; warmup decay 1.0→0.0 after 60 ticks; consTimer stands still), live_tick_pumps_and_advances_warmup (rotary-pump on shallow-water, power 0.5, 1 tick 1/60s: efficiency 0.5, store +0.4 water, warmup 0.019, total_progress 0.019, cons_timer 1.0). Ghi nợ trong GOAL.md §5 + handoff + STATUS.md.
