# N2259 RepairTurret Coolant (ConsumeCoolant optional, coolantUse 0.16f, coolantMultiplier 1.6f) — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 6 — wave second-consumers-2, integration branch `integration/wave-second-consumers-2-n2256-n2259`, base `73185810`).

## Source

ConsumeCoolant filter (ConsumeCoolant.java:12): `liquid.coolant && temp ≤ 0.5 && flammability < 0.1 && non-gas` (maxTemp 0.5, maxFlammability 0.1 :5; allowLiquid true, allowGas false :6). `ConsumeLiquidFilter.efficiency` :50-55 uses ed = edelta with NO efficiencyScale; `getConsumed` :63-76 (current liquid first if filter matches + amount > 0, else first in content order); `update` :42-47. RepairTurret: coolantUse 0.16f, coolantMultiplier 1.6f, acceptCoolant=true (Blocks.java:6405-6407); consumer `optional(true, true)` (RepairTurret.java:84-86, update=true default). Multiplier = `1f + liquids.current().heatCapacity * coolantMultiplier * optionalEfficiency` (:190; block :188-191; heal :207). **Scope corrections (verified by grep): Blocks.java coolant defs are :6405-6407 (not :6404-6406 — :6404 is pulseRadius); the multiplier formula is :190 (block :188-191, not :189-191).**

## Implementation

`SourceRepairTurretBuildState.gd`: pure `source_repair_turret_coolant_row_state(frame, ...)` (filter + consumed + multiplier pures alongside) → 3 result symbols: row, has_coolant_row, consumed_liquid. The multiplier is wired via frame key `coolant_multiplier` (NOT a new advance param — the N2226 test pins the 8-arg advance call). Repair-point is detected by `block_id == "repair-turret"` (the catalog has no acceptCoolant flag; repair-point has no coolant consumer — `acceptCoolant = false`, RepairTurret.java:39). Direct second-pass removal after apply_update_consumption_state (update=true default, so the second pass consumes; guard `update && efficiency > 0`, edelta from the FOLDED efficiency). Register: ledger/contract java_source is RepairTurret.java.

## Commits

Slice `ae2cd4cc` (worker-N2259, branch `slice/N2259-repair-turret-coolant`, 5 files, +1231/−11, đã push, remote tip verified by ls-remote). Integration cherry-pick `f0761182` on `integration/wave-second-consumers-2-n2256-n2259` (base 73185810). Coordinator fix `33893e22` at integration: Fracker guard cite :141→:221 in the driver.

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 41/41, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings: 12/16 PASS (4 proof Godot-absent), 0 other failures. Full wave gate: Ran 6126 in 1081.029s, failures=208, skipped=5, 0 errors — 208/208 Godot-absent (204 inherited + 4 new proof tests N2256–N2259).

## SSOT / DEFERRED

SSOT single-slice +3/+1/+1/+2 → 11723/1706/1628/3047; audit stays 1336. DEFERRED 295 (293 − 1 resolved + 3 new: ConsumeLiquidFilter display rows, build rows, coolant stat/effect rows). Merged wave DEFERRED: 293 entries (DEFERRED-after-second-consumers-2.py) — the RepairTurret live-fill entry's coolant sub-part trimmed by the coordinator (entry stays, coolant wording removed).

## Godot debt

`C07RepairTurretCoolantProof` — 6 keys: coolant_row_folds_optional_when_present, filter_rejects_non_coolant, multiplier_uses_current_heat_capacity, repair_point_has_no_coolant_row, live_tick_folds_coolant_row, live_tick_removes_coolant_when_running (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
