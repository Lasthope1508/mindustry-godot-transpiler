# C05 per-block cost multiplier — N2097

Date: 2026-11-09. Batch: N2097 (single slice, third C05 batch). SSOT +2/+1/+1/+2 → 10824 / 1550 / 1438 / 2667; audit `totalSourceFunctions` stays 1335.

## What changed

The consumer multiplier was a default-only binding: `SourceConsumeState.source_cost_multiplier_state` (N2007) returned `{"multiplier": 1.0}` unconditionally. The actual source callbacks are per-consumer: `Consume.multiplier` is a field on each consumer (Consume.java:18, default `b -> 1f`), and unit factories override it with `b -> state.rules.unitCost(b.team)` (UnitFactory.java:109, Reconstructor.java:149, UnitAssembler.java:175 — the same line in all three files).

- N2097 `SourceConsumeState.source_cost_multiplier_for_block_state(build)` — reads `block_implementation`, `team_id` and `rules_state` from the build dict (the building frame) and returns `Rules.unitCost` (via N2096's `source_unit_cost_state`) for UnitFactory/Reconstructor/UnitAssembler blocks, 1.0 otherwise. A build without the keys keeps the 1.0 default, so the N2007 behavior is preserved for old callers.
- The drill's tick (`SourceDrillConsumptionRuntimeState.source_tick_state`) sets the three frame keys before the consumers are created — block implementation from the block, team from the sprite's `team_id` meta (`SourceBlockGeometry.SOURCE_BUILD_TEAM_META_KEY`), rules from the game's `rules_state` or `{}` — and passes this function as the consumer Callable instead of the default-only one. The drill is not a unit factory, so it keeps 1.0 through the new path (proven live).

## Verification

- New test `tools/mindustry_godot_transpiler/tests/test_cost_multiplier_for_block_binding.py` (registration + exact-evidence + Godot proof) — RED before the register script ran (1 failure, 2 errors), GREEN after. Two fixes on the way: the proof first read `frame["consumers"][0]["consumer"]`, but the frame holds the RuntimeConsumer directly (`frame["consumers"][index]` is the actor the tick calls `efficiency` on); and a rerun without `godot` on PATH failed fast at `shutil.which` — the PATH export must be in the same command as the test run.
- Godot proof `CostMultiplierForBlockProof` **14/14 true** on the real Main scene: factory 2.0 x 0.5 → 1.0, reconstructor team 2 → 3.0, factory defaults 1.0, drill/pump ignore the rules, bare build 1.0, live drill frame keys (Drill, team 1, rules dict) + live consumer Callable 1.0.
- Targeted gate: the cost-multiplier + rules-unit-cost + content-registry + hydration + emitter + parity + symbols + playable tests — **4961 tests OK in 723.240s, exit=0** (log `~/workspace/logs/targeted-n2097.log`).
- Full Python suite: **5490 tests OK in 1369.931s, exit=0** (log `~/workspace/logs/full-suite-n2097b.log`). The first full-suite run (`full-suite-n2097.log`) died mid-run after the VM restarted (~09:37) with 17 F's visible and no summary; the rerun is clean, so those F's were restart fallout, not N2097 breakage.

## SSOT delta

+2 symbols / +1 slice / +1 contract / +2 schemas → 10824 / 1550 / 1438 / 2667; audit `totalSourceFunctions` stays 1335. The owner (`world/blocks/units/UnitFactory.java`) mirrors into the `unit_building_*` module shards (all 4 files).

## Still open

- C05: the game rules state itself (a live, mutable rules dict on the game, read by the tick — it currently passes an empty rules state, so unitCost reads the 1.0 defaults until then), live TeamRules cheating, and the descriptor/apply/adapter cache invalidation on Block reinit/reload. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open. A live thorium-reactor placement proof (placed reactor consuming thorium + cryofluid in the world) is a future slice.
