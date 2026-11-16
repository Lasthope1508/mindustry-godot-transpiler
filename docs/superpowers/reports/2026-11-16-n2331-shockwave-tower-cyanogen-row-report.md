# Report N2331 — ShockwaveTower cyanogen ConsumeLiquids row

**Slice:** N2331 — ShockwaveTower cyanogen ConsumeLiquids row (required fold +
second-pass removal). **Wave:** advances-14.
**Commit:** `9a6c18de` on `slice/N2331-shockwave-cyanogen-row` (base `f3f7af8e`).
**Files:** 5, +1107/−2.

## Source

Java: `consumeLiquids(LiquidStack.with(Liquids.cyanogen, 1.5f / 60f));`
(Blocks.java:2041). `ConsumeLiquids` extends `Consume` directly
(ConsumeLiquids.java:11) — a DIFFERENT class from ConsumeLiquidBase.
`ConsumeLiquids.efficiency` is :52-60 (min over stacks from 1f; the
single-stack def collapses to min(cyanogen / (0.025·ed·mult), 1f));
`update` is :44-49 (removal only when update && efficiency > 0). The
single-stack numbers coincide with ConsumeLiquid's, but the port follows
the ConsumeLiquids lines. Brief/SCOPE cites Blocks.java:2041/2042 and
ConsumeLiquids.java:11 are all CORRECT (verified line by line).

## Implementation

New pure `source_shockwave_tower_liquid_consumer_row_state` — the
ConsumeLiquids efficiency folds as a REQUIRED row into the first-pass min
alongside power, + second-pass removal of amount × folded edelta via the
shared `source_remove_state`. The tick syncs the sprite liquids meta into
the frame before the fold and lazily initializes the store when missing
(LiquidBridge precedent). Documented limits (1) updated: cyanogen row live
(N2331).

**Catalog gap (verified):** PortGame `record_placed_block` only binds liquid
consumers for blocks with a catalog `consumeLiquid` property
(PortGame.gd:30-34), and the shockwave-tower catalog entry has NO
`consumeLiquid`/`consumeLiquids` property — so no store exists at placement.
The tick lazily initializes it; the proof initializes it explicitly before
seeding. The brief's "liquids store đã có sprite meta" was WRONG for
shockwave-tower.

**⚠️ STALENESS FLAG — old proofs go stale, NOT fixed (out of scope):** the
required row folds efficiency 0 for any live tick without seeded cyanogen.
Verified by reading each proof's live-tick section:
- N2177 PowerStatus: `efficiency_folds_power_min` (expects 0.5 → will be 0.0).
- N2187 ShouldConsume: `efficiency_folds_power_when_gate_true` (0.5 → 0.0) +
  `reload_counter_advances_by_edelta` (eff 1.0/counter 11 → 0/10).
  `efficiency_zero_when_gate_false` OK.
- N2318 TimerCheck: `live_tick_passes_check_ready_on_fire` (targets not cleared
  — counter stays 79) + `timer_fire_alone_does_not_fire_wave` (counter 80 → 79).
  `timer_resets_elapsed_on_fire` OK.
- N2327 BulletScan: `live_tick_passes_scanned_bullets` (no fire — counter stays
  79, heat 0.4875, targets []).
- N2247 UpdateTile: NOT stale (`heat_decays_every_tick` — heat decay is
  unconditional in the advance).
Fix = seed cyanogen in the sprite liquids store in those proofs; needs a fix
slice in a later wave (recorded as a DEFERRED entry in this slice's register).

**Scope corrections:** the brief's Fracker guard cite
`SourceFrackerBuildState.gd:221` is WRONG — :221 is a docstring comment line;
the guard code is :170 (shouldConsume gate) and :279 (liquid-row guard); the
driver cites :279. The related stale cite "Fracker:361" frame sync is now at
`SourceFrackerBuildState.gd:623` (sweep backlog for a cite-cleanup slice).

## Commits

- Slice: `9a6c18de` (5 files, +1107/−2).
- Integration cherry-pick: `3515ad80` (clean).

## Tests

Targeted (new module `tests.test_c07_shockwave_tower_cyanogen_row`): 3/4
PASS + proof test FAIL exactly AssertionError: unexpectedly None — NO
Godot binary on this VM (user order 2026-11-15). Exact-evidence 27/27.
Siblings: all 5 ShockwaveTower modules (power_status, should_consume,
update_tile, timer_check, bullet_scan) green except their own Godot-absent
proof tests — no regressions.
Full gate (wave advances-14 integration, PID 11801, 07:14–07:36): Ran 6394 tests in 1305.500s, FAILED (failures=275, skipped=5), 0 errors — 275/275 Godot-absent `AssertionError: unexpectedly None` (268 inherited + 7 new proof tests N2330–N2336).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+1/+2** → 11962/1770/1702/3196: symbols
`source_shockwave_tower_liquid_consumer_row_state_result.row`
(ConsumeLiquids.java) + `.has_liquid_row` (BuildingComp.java); audit stays
1336. Shards changed: `defense_api_contracts.json` + `defense_slices.json`
only — ledger java_source kept as ShockwaveTower.java per the N2255 lesson,
so no consumer_slices shard failure.
DEFERRED 329→332 (−1+4: resolved #76 liquid-row entry; added live cyanogen
intake, catalog consumeLiquids capture, old-proof cyanogen seeding,
ConsumeLiquids build/display rows).

## Godot debt

- NEW proof `C07ShockwaveTowerCyanogenRowProof` (6 keys:
  `row_folds_cyanogen_amount` (0.01 → 0.4), `row_zero_when_starved` (0 → 0;
  edelta 0 → 0), `row_full_when_satisfied` (10.0 → 1.0 cap),
  `live_tick_folds_liquid_row` (eff 1.0 / 0.5 / 0.0 across full/half/starved
  ticks, counter 1.0 / 1.5 / frozen), `second_pass_removes_cyanogen`
  (10.0 → 9.975), `power_row_unchanged`) — written but NEVER run; debt in
  GOAL.md §5.
