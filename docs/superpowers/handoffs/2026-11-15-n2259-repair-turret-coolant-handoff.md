# N2259 RepairTurret Coolant (ConsumeCoolant optional, coolantUse 0.16f, coolantMultiplier 1.6f) — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave second-consumers-2, coordinator lượt 6).

## What this slice did

ConsumeCoolant optional row in `SourceRepairTurretBuildState.gd` (ConsumeCoolant.java:12 filter; ConsumeLiquidFilter.java:50-55 efficiency with ed = edelta, NO efficiencyScale; :63-76 getConsumed; :42-47 update): repair-turret only — coolantUse 0.16f, coolantMultiplier 1.6f, acceptCoolant=true (Blocks.java:6405-6407). Pure `source_repair_turret_coolant_row_state` → 3 result symbols: row, has_coolant_row, consumed_liquid. Multiplier = `1f + liquids.current().heatCapacity * coolantMultiplier * optionalEfficiency` (RepairTurret.java:190), wired via frame key `coolant_multiplier`.

## Key facts for the next agent

**Verified line numbers**: filter ConsumeCoolant.java:12; efficiency :50-55, getConsumed :63-76, update :42-47; coolantUse 0.16f / coolantMultiplier 1.6f / acceptCoolant=true Blocks.java:6405-6407 (**not :6404-6406 — :6404 is pulseRadius**); consumer `optional(true, true)` RepairTurret.java:84-86, update=true default; multiplier formula :190 (block :188-191, **not :189-191**); heal :207. **Multiplier via frame key, not a param** — the N2226 test pins the 8-arg advance call. **Repair-point detected by `block_id == "repair-turret"`** — the catalog has no acceptCoolant flag; repair-point has no coolant consumer (`acceptCoolant = false`, RepairTurret.java:39). **Direct removal, not the updates-array actor** — the machinery's second pass only records update consumers, it never calls update on them. Register: ledger/contract java_source is RepairTurret.java. Register: 41 exact exprs, all grep-verified verbatim. DEFERRED: 295 (293 − 1 resolved + 3 new: display rows, build rows, stat/effect rows). Slice commit `ae2cd4cc` (branch `slice/N2259-repair-turret-coolant`, đã push). Integration cherry-pick `f0761182`; coordinator fix `33893e22` (Fracker guard cite :141→:221).

## Godot debt (this slice)

`C07RepairTurretCoolantProof` — 6 keys: coolant_row_folds_optional_when_present, filter_rejects_non_coolant, multiplier_uses_current_heat_capacity, repair_point_has_no_coolant_row, live_tick_folds_coolant_row, live_tick_removes_coolant_when_running. Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
