# Handoff — N2159: BaseShield power.status live read (shield-projector / large-shield-projector) (C07)

Date: 2026-11-13. Batch: N2159 (single slice). Status: **DONE (2026-11-13 ~22:30 +07, 22:30 report run — targeted 4/4 OK, neighbours 92/92 OK, Godot proof GREEN 9 keys matches:true, full gate attempt 1 GREEN except Godot: Ran 5733, failures=110, skipped=5, 0 errors, all 110 verified Godot-absent asserts, finished ~22:25 +07). Commit + push after this run.**

## Scope (decided at RED)

- Family: the BaseShield implementation — **shield-projector** (consumePower 5f, size 3, radius 200f default) and **large-shield-projector** (consumePower 5f, size 4, radius 400f, Blocks.java:2060). hasPower=true, update=true, solid=true, rebuildable=false, canPickup=true. Catalog confirms implementation BaseShield + consumePower 5.0 for both (content_registry.json — to re-verify at GREEN; the Blocks.java def is the source of truth, see Exact exprs).
- Why: BaseShield (BaseShield.java:18, `public class BaseShield extends Block{`) has NO placed-buildings driver at all — shield-projector / large-shield-projector would shield as if power.status were 1.0. N2159 is the BaseShield family's live read — the same proven N2145–N2158 pure-row pattern, one new file over. Fourth projector family: the deferred list in the N2158 handoff named remaining projectors (BaseShield/Regen) as the next group after ForceProjector.
- BaseShield extends Block, NOT a drill or factory, so it cannot reuse an existing frame key; it gets its own family frame key (the mechanical-pump / beam-drill / mend-projector / overdrive-projector / force-projector precedent).
- The port has NO SourceBaseShield* files at all yet — no display/runtime state to lean on. The efficiency fold this slice proves is the smooth-radius fold (BaseShield.java:89, `smoothRadius = Mathf.lerpDelta(smoothRadius, radius * efficiency, 0.05f);`), with the shield only engaging past radius 1 (BaseShield.java:91-93, `float rad = radius();` + `if(rad > 1){`).
- Out of scope for this slice: RegenProjector (regen-projector, 1f) stays deferred — the last projector family. BaseShield has NO item or liquid consumers at all, so there are no booster/coolant rows to defer; power is its only consumer.

## Design (decided in scoping, to confirm at RED)

- New file `godot-mindustry/src/game/SourceBaseShieldBuildState.gd` (mirrors SourceForceProjectorBuildState.gd): pure `source_base_shield_power_status_row_state(frame, has_power_consumer)` returning `{"has_power_row": false, "row": {}}` without a consumer, else `{"has_power_row": true, "row": {"result": <live>, "is_power": true}}` where live is the stamped frame value, null folding to 1.0 (the assembler convention, UnitAssembler.java:469); plus driver `source_base_shield_tick_buildings_state(game, seconds)` mirroring the force-projector driver's shape — iterate placed BaseShield buildings (`source_unique_buildings_state`), bind the frame if missing, refresh frame keys (block_implementation, team_id, rules_state, cheating, enabled), and when `block.properties.has("consumePower")` and enabled and not cheating, fold the pure row into frame["efficiency"] through the shared machinery (`update_consumption_setup_state` + `update_consumption_state` + `apply_update_consumption_state`, should_consume=true when enabled, production_valid=true) as the only first-pass row, so the smooth-radius fold (BaseShield.java:89) follows power.status.
- Frame key (DECIDED at RED 2026-11-13 ~21:45 +07): `"source_base_shield_building"` — verified no collision: grep finds no `source_base_shield_building` anywhere in the port. GREEN adds it to `SourcePlacedPowerGraphState.SOURCE_CONSUMER_FRAME_META_KEYS` (one line, same mechanism as the force-projector key).
- Wiring: call the driver from `SourceFactoryRuntimeState.simulate_factory` (preload const + one call next to the force-projector tick, the production grouping).
- Header comment quotes: `return build.power.status;` (ConsumePower.java:39), the null-fold line (UnitAssembler.java:469), `hasConsumers = consumers.length > 0;` (Block.java:1449), the smooth-radius gate `smoothRadius = Mathf.lerpDelta(smoothRadius, radius * efficiency, 0.05f);` (BaseShield.java:89), the rad gate `float rad = radius();` (BaseShield.java:91), the default radius `public float radius = 200f;` (BaseShield.java:20), the large radius `radius = 400f;` (Blocks.java:2060), the shouldConsume default `public boolean shouldConsume(){` (BuildingComp.java:755) — keep each on ONE comment line (the N2148 shootWarmup lesson: a split line fails the source-text test).
- Documented limits (GREEN must record in the pure function's comment, same discipline as N2148–N2158): (1) power-only first pass — BaseShield has no item/liquid consumers at all, so the folded efficiency is the min over the *modeled* consumers (power only) with nothing else to defer. (2) No shouldConsume gate — BaseShieldBuild has no shouldConsume override, so the default (BuildingComp.java:755-757, `return enabled;`) applies; the machinery runs with should_consume=true when enabled. (3) No updateTile advance — smoothRadius / bullet absorb / unit repel / broken / hit (BaseShield.java:88-99) wait for their own slices; the proof carries no shield/radius/broken keys, the smooth-radius fold (BaseShield.java:89) is what the efficiency keys prove. (4) No drawShield rows — shieldColor / animateShields / sides 24 / hit alpha (BaseShield.java:125-147) are presentation, not state.
- Proof scene (new, modeled on the N2158 proof — Main scene, campaign playable slice, `RuntimeProofState`), prefix `C_07_BASE_SHIELD_POWER_STATUS_PROOF `, 6 keys: `shield_has_power_consumer` (catalog shield-projector AND large-shield-projector properties have consumePower), `power_row_half`, `power_row_absent_without_consumer`, `power_row_null_folds_one`, `efficiency_folds_power_min` (live tick — place shield-projector live, stamp frame["power_status"] = 0.5, call the driver directly so the graph update does not overwrite the stamp), `efficiency_zero_at_no_power`.

## Exact exprs (13, all verified verbatim at scoping — grep 2026-11-13 ~21:45)

- `return build.power.status;` (ConsumePower.java:39)
- `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;` (UnitAssembler.java:469)
- `hasConsumers = consumers.length > 0;` (Block.java:1449)
- `consumePower(5f);` (Blocks.java:2053, shield-projector def 2048)
- `public class BaseShield extends Block{` (BaseShield.java:18)
- `hasPower = true;` (BaseShield.java:62)
- `smoothRadius = Mathf.lerpDelta(smoothRadius, radius * efficiency, 0.05f);` (BaseShield.java:89)
- `public float radius = 200f;` (BaseShield.java:20)
- `radius = 400f;` (Blocks.java:2060, large-shield-projector def 2056)
- `public boolean shouldConsume(){` (BuildingComp.java:755)
- `float rad = radius();` (BaseShield.java:91)
- `for(var cons : block.nonOptionalConsumers){` (BuildingComp.java:1969)
- `minEfficiency = Math.min(minEfficiency, result);` (BuildingComp.java:1976)

## RED (DONE 2026-11-13 ~21:45 +07, 21:45 report run)

- Test module `tools/mindustry_godot_transpiler/tests/test_c07_base_shield_power_status.py` + register script `tools/mindustry_godot_transpiler/register_c07_base_shield_power_status.py` written (modeled on N2158; frame key decided: `"source_base_shield_building"`).
- RED run: Ran 4 tests in 1.011s, FAILED (failures=1, errors=3) — exactly as expected: registration ERROR KeyError 'N2159', evidence ERROR KeyError 'N2159', source-text ERROR FileNotFoundError on `SourceBaseShieldBuildState.gd` (file does not exist yet), proof FAIL returncode 1 (scene missing, Godot 4.6.2-stable Linux). Re-run confirmed the same breakdown (2× KeyError 'N2159' + FileNotFoundError + returncode 1). Port 7777 was FREE. 13/13 exact exprs verified verbatim at RED (grepped in the Java sources during scoping). SSOT baseline 11326/1609/1530/2851 (unchanged from N2158 — main at 26a8ef4), audit 1335. javalang 0.13.0 present (no reinstall needed).
- Next: GREEN (new `SourceBaseShieldBuildState.gd` pure row + driver, wiring in `SourceFactoryRuntimeState.simulate_factory`, key added to `SOURCE_CONSUMER_FRAME_META_KEYS`, proof scene `C07BaseShieldPowerStatusProof` 6 keys, register script run → expected SSOT 11328/1610/1531/2853), then targeted 4/4 → neighbours → Godot proof → full gate (main thread) → commit + push only when all green.

## GREEN (DONE 2026-11-13 ~22:0x +07, 22:00 report run)

- New `godot-mindustry/src/game/SourceBaseShieldBuildState.gd` (pure row `source_base_shield_power_status_row_state` + driver `source_base_shield_tick_buildings_state` + bind + tick-frame wiring, frame key `"source_base_shield_building"`), proof scene `C07BaseShieldPowerStatusProof` (6 keys) + `.tscn`, wiring in `SourceFactoryRuntimeState.simulate_factory` (preload + one call next to the force-projector tick), key added to `SOURCE_CONSUMER_FRAME_META_KEYS` in `SourcePlacedPowerGraphState.gd`. Register script run OK.
- Targeted: Ran 4 tests in 15.027s, OK (includes the Godot proof test). Godot proof GREEN standalone: 9 keys all true, `matches: true`, no ERROR (port 7777 was FREE). Neighbours: C07 power-status family 60/60 OK (191.6s, 15 modules incl. N2159) + wiring-sensitive modules 32/32 OK (113.5s) — factory live loop, power-graph grouping/live-update, battery binding/placement, adjacent/unit-factory live loops, turret live loop, consumer cheating. SSOT 11328/1610 (symbols/slices; was 11326/1609), audit 1335. `git diff --check` clean.
- Next: full gate (main thread — expected Ran ~5733, failures=110, skipped=5, 0 errors, all Godot-absent asserts), then report + design spec (Status Summary 1609→1610) + handoff + GOAL.md §5 debt line, then commit + push only when all green.

## Gate (DONE — attempt 1, finished ~22:25 +07)

- Full gate attempt 1 **launched from the MAIN THREAD ~22:10 +07** by main thread: `cd tools/mindustry_godot_transpiler && python3 -c "import javalang" && setsid nohup python3 -m unittest discover -s tests > full-suite-n2159-gate.log 2>&1 < /dev/null &` — **PID 13158, SID 13158 (own session), PPID 13155 (background subshell)**. **Finished ~22:25 +07 (log mtime 22:25:58 +07): Ran 5733 tests in 894.668s, FAILED (failures=110, skipped=5), 0 errors** — exactly the expected outcome (109 inherited + 1 new N2159 proof test). **Verified by the 22:30 cron run: 110 `FAIL:` lines, 0 `ERROR:` lines, all 110 FAIL blocks mention Godot (script check: non-Godot-cause blocks NONE) — 109 plain assertIsNotNone(godot) + 1 hydration assertIsNotNone(godot, 'Godot required for hydration proof'), including the new N2159 proof test (fails only on `assertIsNotNone(godot)` at test line 158 — the gate env has no Godot on PATH; the proof itself is GREEN headless). Gate clean except Godot. First-attempt finish.** No Godot on PATH. No proof scene ran while the gate ran (port-7777 rule).

## Commits (PENDING)

## Deferred (NOT this slice)

- BaseShield updateTile advance (smoothRadius / bulletConsumer absorb / unitConsumer repel / broken / hit, BaseShield.java:88-99), BaseShield drawShield rows (BaseShield.java:125-147), BaseShield radius / sides rows (radius 200f/400f, sides 24), BaseShield broken / hit rows (BaseShield.java:83-84).
- Remaining projector family (RegenProjector regen-projector 1f); payload producers (Constructor / PayloadLoader / Unloader / MassDriver / UnitCargoLoader / PayloadDeconstructor).
- ForceProjector updateTile advance / booster item rows / coolant rows / phase-radius / phase-shield rows / broken / buildup rows; OverdriveProjector updateTile advance / booster item rows / range rows / useProgress rows; MendProjector updateTile advance / suppression gate / booster item rows / range rows; BeamDrill / Pump / Fracker / SolidPump updateTile advance / shouldConsume / liquid / proximity rows (see register script DEFERRED).
- spawn_occupied / allow_update / moveOutPayload, net drone sync.
- C07–C12 remain open.

## Notes

- Another agent is using Godot to test the fail errors (user, 08:05). Port 7777 was FREE at RED. Before any proof run, re-check `ss -ltnp | grep 7777` and run proof scenes sequentially — never while a gate runs (port-7777 rule).
- Godot binary is at ~/workspace/godot-bin/godot (symlink to Godot_v4.6.2-stable_linux.x86_64) — NOT on PATH by default; targeted/neighbours ran with PATH="$HOME/workspace/godot-bin:$PATH".
- Worktree at RED: main `26a8ef4`, clean except untracked `*.gd.uid` (never stage). New uncommitted files: the N2159 test module + register script + this handoff.
- VM restarts wipe the system-wide javalang install — reinstalled 0.13.0 at the N2158 RED run; present at this RED run. After any VM restart, reinstall javalang first before any gate.
- N2159 proof not yet run on Windows Godot (debt in GOAL.md §5 — to add at GREEN completion, scene reaches Windows with the slice commit).
