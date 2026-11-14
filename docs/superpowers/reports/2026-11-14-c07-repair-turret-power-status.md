# Report — N2174: RepairTurret power.status live read (repair-point / repair-turret) (C07)

Date: 2026-11-14. Batch: N2174 (single slice). Status: **DONE + PUSHED (2026-11-14 ~16:3x +07 — targeted 4/4 OK, neighbours 152/152 OK, Godot proof GREEN 6 keys matches:true, full gate attempt 1 Ran 5793 in 962.332s, failures=125, skipped=5, 0 errors — all 125 verified Godot-absent asserts).**

## What changed

The next `power.status` consumer family after the N2173 radar slice: the RepairTurret implementation family — TWO defs, **repair-point** (powerUse 1f, Blocks.java:6391; repairSpeed 0.45f, repairRadius 60f, Blocks.java:6388-6389) and **repair-turret** (powerUse 5f, Blocks.java:6402; size 2, repairSpeed 3f, repairRadius 145f, Blocks.java:6398-6401; acceptCoolant true, coolantUse 0.16f, coolantMultiplier 1.6f, Blocks.java:6404-6406). RepairTurret extends Block (RepairTurret.java:25, `public class RepairTurret extends Block{`); its build extends Building (RepairTurret.java:153, `public class RepairPointBuild extends Building implements Ranged, RotBlock{`). Catalog confirms implementation RepairTurret + hasPower true + consumesPower true for both defs, with consumePower None (source_modules/content_registry_blocks.json, repair-point / repair-turret entries) — None because the power draw is CONDITIONAL, not absent: `consumePowerCond(powerUse, (RepairPointBuild entity) -> entity.target != null);` (RepairTurret.java:89). Blocks.java defs are the source of truth, see Exact exprs.

The repair turret has NO driver at all — no `SourceRepairTurret*` file exists in godot-mindustry/src/game, it extends Block, not a factory or crafter, so no existing driver matches it (the turret driver's line-28 comment mentions RepairTurret explicitly but does NOT list it — its list is ItemTurret/LiquidTurret/PowerTurret/LaserTurret/ContinuousTurret only), and no frame key exists for it, so the N2142 stamp never reaches a repair-turret frame. Its updateTile heal advance (RepairTurret.java:207, `target.heal(repairSpeed * strength * edelta() * multiplier);`) heals by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`), so a repair turret with no power would never heal — its target's health would sit frozen as if power.status were 1.0. N2174 is the repair turret's live read — the same proven N2145–N2173 pure-row pattern, on the N2173 radar precedent (new family file + own driver + own frame key + simulate_factory wiring): one new pure function on a new state file + a driver fold + a new frame key + the wiring. The same driver covers both defs via the catalog implementation (the conditional consumer is registered per def through powerUse, not consumePower).

**Power is CONDITIONAL, not static** — the one way this family differs from Radar/LaunchPad: `consumePowerCond(powerUse, (RepairPointBuild entity) -> entity.target != null);` (RepairTurret.java:89, init()). ConsumePowerCondition only draws when its condition holds: `return consume.get(entity) ? usage : 0f;` (ConsumePowerCondition.java:17). Catalog consumePower None is CORRECT for this family — it records no static consumePower def, and the power draw is 1f / 5f only while a target is locked. The pure row is still the same ConsumePower read (`return build.power.status;`, ConsumePower.java:39) — ConsumePowerCondition does not override efficiency(), so the row folds power.status exactly like the static case.

**shouldConsume override EXISTS** — unlike Radar (no override, BuildingComp default applies), RepairPointBuild overrides it: `return target != null && enabled;` (RepairTurret.java:222). And updateConsumption forces efficiency to zero when the gate is false: `boolean update = shouldConsume() && productionValid();` (BuildingComp.java:1960) + `if(!update){` (BuildingComp.java:1992, efficiency = optionalEfficiency = 0f). Decided at RED (option (b)): fold power-only in this slice, defer the gate with a documented limit — no placed-building frame in the port carries a live `target`/`has_target` key (grep over godot-mindustry/src/game/*.gd — targets exist only in bullet/enemy-unit contexts and in pure-function call records, never as live building-frame state); the PointDefenseTurret N2151 precedent deferred the identical gate (`return super.shouldConsume() && target != null;`) the same way. With no target requestedPower is 0 so power.status reads 1.0 while Java efficiency is 0 — the observable gap is efficiency 1.0 vs 0.0 with no target. The driver runs with should_consume=true when enabled (the MendProjector suppression precedent).

New file `godot-mindustry/src/game/SourceRepairTurretBuildState.gd`, class_name SourceRepairTurretBuildState, with `SOURCE_REPAIR_TURRET_BUILD_IMPLEMENTATIONS := ["RepairTurret"]` and frame meta key `"source_repair_turret_building"`:

- Pure `source_repair_turret_power_status_row_state(frame, has_power_consumer)` (mirrors `source_radar_power_status_row_state`): without a consumer → `{"has_power_row": false, "row": {}}`; else `{"has_power_row": true, "row": {"result": <live>, "is_power": true}}` where live is the stamped frame value, null folding to 1.0 (the assembler convention, UnitAssembler.java:469).
- `source_repair_turret_tick_frame_state` (mirrors the radar tick-frame: block_implementation / team_id / rules_state / cheating via TeamComp.cheating(), preserve disabled frame).
- `source_repair_turret_bind_frame_state` (mirrors the radar bind: empty frame under the repair-turret meta key, no-op for other blocks / already-bound sprites).
- Driver `source_repair_turret_tick_buildings_state(game, seconds)` (mirrors the radar driver: iterate placed buildings, match implementation, bind frame, tick frame, when the block has the conditional power consumer and enabled and not cheating fold the pure row via `source_building_efficiency_state.update_consumption_state(true, ...)` with has_consumers=true — the power consumer counts toward hasConsumers, Block.java:1449 — and apply it; no consumer actors, no production tick, no updateTile heal advance).

**Driver-gate adaptation (the one way this family differs from Radar at GREEN):** the catalog records NO `consumePower` property for repair-point / repair-turret (consumePowerCond registers no static def — catalog consumePower None is CORRECT), only `consumesPower: true` + `hasPower: true`. A gate on `block.properties.has("consumePower")` alone would never tick either def, so the driver gate is `block.properties.has("consumePower") or block.properties.get("consumesPower", false)` — the required `has("consumePower")` string is kept, and the conditional consumer is read through the catalog `consumesPower` flag. Documented in the driver comment. The proof's live keys confirm the gate fires (efficiency 0.5 / 0.0).

New frame key `"source_repair_turret_building"` added to `SourcePlacedPowerGraphState.SOURCE_CONSUMER_FRAME_META_KEYS` so the N2142 graph stamp/write-back finds the repair-turret frame. Wiring in `SourceFactoryRuntimeState.simulate_factory`: preload `source_repair_turret_build_state` + call `source_repair_turret_tick_buildings_state(game, delta)` (immediately after the radar call).

Documented limits in the pure function's comment, same discipline as N2148–N2173: (1) power-only first pass — the repair turret's power consumer is conditional (ConsumePowerCondition, target-gated), so the folded efficiency is the min over the *modeled* consumers (power only); the coolant optional consumer (repair-turret only) is the second pass and waits for its own slice. (2) shouldConsume gate — RepairPointBuild overrides shouldConsume (`target != null && enabled`, RepairTurret.java:221-223); when the gate is false Java forces efficiency to 0 (BuildingComp.java:1960 + 1992-1994); the driver's handling of the gate is decided at RED (option (b), fold power-only, documented limit) and must be recorded, not silently skipped. (3) No updateTile heal advance — target re-acquire / heal / rotation slerp / strength lerp (RepairTurret.java:187-219) wait for their own slices; the proof carries no heal/strength/rotation/target keys, the heal advance (RepairTurret.java:207) is what the efficiency keys prove. (4) Two defs — repair-point (powerUse 1f) and repair-turret (powerUse 5f + coolant) share the one driver; repairSpeed / repairRadius / length / beamWidth / pulseRadius per-def values wait for their own verification slice. (5) RepairTower (unit-repair-tower) is a different class and NOT covered by this driver.

**Naming trap, recorded so it is not re-scoped:** the candidate name "RepairTower" in the N2173 handoff is the RepairTurret implementation family (repair-point / repair-turret). There is a SEPARATE, unrelated class `RepairTower` (mindustry-upstream/core/src/mindustry/world/blocks/units/RepairTower.java:18, `public class RepairTower extends Block{`) backing the single def **unit-repair-tower** (Blocks.java:6575, `consumePower(1f);` + ozone liquid) — a unit-carried repair block, NOT this family, NOT in scope for N2174. Do not confuse the two.

Scope decision (verified this run): the candidate order after Radar listed RepairTower next. Verified against the catalog and the driver list: both RepairTurret defs carry hasPower + consumesPower true with a conditional power draw (powerUse 1f / 5f), and NO driver covers them — no SourceRepairTurret* file, no RepairTurret entry in any SOURCE_*_IMPLEMENTATIONS list (the turret driver covers ItemTurret/LiquidTurret/PowerTurret/LaserTurret/ContinuousTurret only; the adjacent driver covers Separator/Incinerator/WallCrafter/SingleBlockProducer only; the base-shield driver covers BaseShield only). The Incinerator lesson was applied: each candidate was checked for an existing driver before scoping.

## Proof keys (new scene, 6 keys)

New scene `C07RepairTurretPowerStatusProof` (modeled on the N2173 proof — Main scene, campaign playable slice, `RuntimeProofState`), prefix `C_07_REPAIR_TURRET_POWER_STATUS_PROOF `:

- `repair_turret_has_power_consumer`: catalog RepairTurret properties have hasPower + consumesPower true on BOTH defs (neither carries a static consumePower value).
- `power_row_half`: pure row over frame `{"power_status": 0.5}`, has_power_consumer true → row result 0.5, `is_power` true.
- `power_row_absent_without_consumer`: has_power_consumer false → `has_power_row` false.
- `power_row_null_folds_one`: frame without `power_status` → row result 1.0.
- `efficiency_folds_power_min`: live tick — place repair-point live, stamp `frame["power_status"] = 0.5`, call the driver directly so the graph update does not overwrite the stamp → frame efficiency 0.5.
- `efficiency_zero_at_no_power`: same, `power_status` 0.0 → efficiency 0.0.

## Exact exprs (19, all verified verbatim at scoping/RED)

- `return build.power.status;` (ConsumePower.java:39)
- `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;` (UnitAssembler.java:469)
- `hasConsumers = consumers.length > 0;` (Block.java:1449)
- `public class RepairTurret extends Block{` (RepairTurret.java:25)
- `public class RepairPointBuild extends Building implements Ranged, RotBlock{` (RepairTurret.java:153)
- `public float powerUse;` (RepairTurret.java:34)
- `hasPower = true;` (RepairTurret.java:60)
- `consumePowerCond(powerUse, (RepairPointBuild entity) -> entity.target != null);` (RepairTurret.java:89)
- `return consume.get(entity) ? usage : 0f;` (ConsumePowerCondition.java:17)
- `powerUse = 1f;` (Blocks.java:6391)
- `powerUse = 5f;` (Blocks.java:6402)
- `public boolean shouldConsume(){` (RepairTurret.java:221)
- `return target != null && enabled;` (RepairTurret.java:222)
- `boolean update = shouldConsume() && productionValid();` (BuildingComp.java:1960)
- `for(var cons : block.nonOptionalConsumers){` (BuildingComp.java:1969)
- `minEfficiency = Math.min(minEfficiency, result);` (BuildingComp.java:1976)
- `if(!update){` (BuildingComp.java:1992)
- `if(target != null && efficiency > 0){` (RepairTurret.java:203)
- `target.heal(repairSpeed * strength * edelta() * multiplier);` (RepairTurret.java:207)

## Verified numbers (measured in this VM)

- Test module `test_c07_repair_turret_power_status.py`: **4/4 OK in 15.749s** (GREEN ~16:0x). Godot on PATH via `PATH="$HOME/workspace/godot-bin:$PATH"`.
- RED run (~15:5x +07, 2026-11-14): Ran 4 tests in 2.762s, FAILED (failures=1, errors=3), all expected — registration ERROR KeyError 'N2174', evidence ERROR KeyError 'N2174', source-text ERROR FileNotFoundError (new state file did not exist yet), proof FAIL returncode 1 (scene missing, Godot 4.6.2-stable Linux). Port 7777 was FREE. 19/19 exact exprs verified verbatim at RED. SSOT baseline 11356/1624/1545/2881 (main 78a3eef), audit 1335. javalang 0.13.0 confirmed present at RED (no reinstall needed — no VM restart since the N2173 reinstall).
- Neighbours: **152/152 OK** — C07 power-status family 30 modules / 120 tests in 395.502s (log `tools/mindustry_godot_transpiler/n2174-neighbours.log`) + wiring-sensitive 9 modules / 32 tests re-run by main thread ~16:13 (discover per-module, no flake). Targeted re-run 4/4 OK in 15.239s by main thread.
- Godot proof: **GREEN ~16:0x +07** (2026-11-14) — proof JSON 9 keys, all true, `matches: true` (6 semantic keys + `registry_valid` + `one_headquarter_per_ssot` + `matches`), verified by the passing proof test in the targeted run, on Godot 4.6.2-stable Linux in this VM (build 71f334935, identical to the Windows 4.6.2 build). Not yet run on Windows Godot — the scene/source reach Windows only with this slice's commit.
- `git diff --check` clean (verified at GREEN and again at completion).
- SSOT +2/+1/+1/+2 → **11358 / 1625 / 1546 / 2883** (registry `symbols` 11358, ledger `slices` 1625, contracts 1546, schemas 2883); audit stays 1335. No source_modules shard changed — no shard selection matches RepairTurret.java (units block).
- Environment note: Godot binary is at ~/workspace/godot-bin/godot (symlink to Godot_v4.6.2-stable_linux.x86_64) — NOT on PATH by default; targeted/neighbours ran with PATH="$HOME/workspace/godot-bin:$PATH". javalang 0.13.0 present (no reinstall needed this run — no VM restart since the N2173 reinstall).

## Gate / suite

- Full gate attempt 1 (main thread, PID 14424, ~16:13 +07, fresh log `tools/mindustry_godot_transpiler/full-suite-n2174-gate.log`) **finished ~16:29 +07: Ran 5793 tests in 962.332s, FAILED (failures=125, skipped=5), 0 errors** — all 125 verified Godot-absent asserts from the log by this run (125 × `AssertionError: unexpectedly None` — 124 inherited + 1 new N2174 proof test `test_reference_graph_and_actual_c07_repair_turret_power_status`; 0 `ERROR:` lines). No real failures. The gate took 962s (~16 min) — back to normal speed after the ~14:38 VM restart.
- Next after gate + push: N2175 — next C07 power.status family; scope at the next run from the catalog, checking the driver first (Incinerator lesson). Remaining consumePower families without a live read (verified at N2174 scoping): ShieldWall (shielded-wall, 0.05) / ShockwaveTower (1.6667) / ItemBridge (phase-conveyor, 0.3) / LiquidBridge (bridge-conduit None / phase-conduit 0.3 — family split) / StackConveyor (plastanium-conveyor None / surge-conveyor 0.0167 — family split) / StackRouter (surge-router, 0.05) / ImpactReactor (25.0 — generator, consume-vs-produce care needed) / Accelerator (interplanetary-accelerator, 10.0) / BuildTurret (build-tower, 3.0). Design-spec Status Summary 1624→1625 + GOAL.md §5 debt line + handoff Commits section written at completion (after gate verification).
