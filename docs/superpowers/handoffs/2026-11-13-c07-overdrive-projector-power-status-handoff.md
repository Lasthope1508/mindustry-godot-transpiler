# Handoff — N2157: OverdriveProjector power.status live read (overdrive-projector / overdrive-dome) (C07)

Date: 2026-11-13. Batch: N2157 (single slice). Status: **GREEN DONE (2026-11-13 ~20:0x +07, 20:00 report run — verified by main thread: targeted re-run 4/4 OK in 15.0s, proof JSON 9 keys all true, SSOT 11324/1608/1529/2849; neighbours 52/52 + wiring 29/29 OK per the 20:00 run, recorded in the handoff). Full gate attempt 1 (worker PID 12581) DIED at session end ~20:12 (log stopped 3,513 bytes, no footer). Attempt 2 launched from the MAIN THREAD ~20:13 +07 (PID 12792, SID 12792) FINISHED ~20:31 +07: Ran 5725 in 1099.125s, failures=108, skipped=5, 0 errors — all 108 verified Godot-absent asserts (107 plain + 1 hydration), verified by the 20:45 report run. Slice committed + pushed after the gate verification (see Commits).**

## Scope (decided at RED)

- Family: the OverdriveProjector implementation — **overdrive-projector** (consumePower 3.50f, size 2, range 80f, speedBoost 1.5f, speedBoostPhase 0.75f, useTime 400f, phaseRangeBoost 20f, hasBoost=true, phaseFabric booster) and **overdrive-dome** (consumePower 10f, size 3, range 200f, speedBoost 2.5f, useTime 300f, hasBoost=false, phaseFabric + silicon booster). Both havePower=true, hasItems=true. Catalog confirms implementation OverdriveProjector + consumePower 3.5 / 10 (content_registry.json — to re-verify at GREEN; the Blocks.java defs are the source of truth, see Exact exprs).
- Why: OverdriveProjector (OverdriveProjector.java:21, `public class OverdriveProjector extends Block{`) has NO placed-buildings driver at all — overdrive-projector / overdrive-dome would overdrive as if power.status were 1.0. N2157 is the OverdriveProjector family's live read — the same proven N2145–N2156 pure-row pattern, one new file over. Second projector family: the deferred list in the N2156 handoff named remaining projectors (Overdrive/Force/BaseShield/Regen) as the next group after MendProjector.
- OverdriveProjector extends Block, NOT a drill or factory, so it cannot reuse an existing frame key; it gets its own family frame key (the mechanical-pump / beam-drill / mend-projector precedent).
- The port already has OverdriveProjector display/runtime state (SourceOverdriveProjectorRuntimeState.gd: `runtime_step_state` lerps smooth_efficiency and heat toward 1.0, and `real_boost(overdrive_projector, phase_heat, efficiency)` multiplies by efficiency with default 1.0 — the boost fold already consumes efficiency) — the missing piece is the live power.status → efficiency driver, which is exactly this slice. Note the runtime step hardcodes the lerp targets to 1.0 today (not live efficiency); the driver is what makes frame["efficiency"] live, and the updateTile advance (which wires efficiency into smoothEfficiency/heat/phaseHeat) waits for its own slice.
- Families still deferred after this slice: remaining projectors (ForceProjector force-projector 4f, BaseShield shield-projector 5f, RegenProjector regen-projector 1f); payload producers (Constructor / PayloadLoader / Unloader / MassDriver / UnitCargoLoader / PayloadDeconstructor).

## Design (decided in scoping, to confirm at RED)

- New file `godot-mindustry/src/game/SourceOverdriveProjectorBuildState.gd` (mirrors SourceMendProjectorBuildState.gd): pure `source_overdrive_projector_power_status_row_state(frame, has_power_consumer)` returning `{"has_power_row": false, "row": {}}` without a consumer, else `{"has_power_row": true, "row": {"result": <live>, "is_power": true}}` where live is the stamped frame value, null folding to 1.0 (the assembler convention, UnitAssembler.java:469); plus driver `source_overdrive_projector_tick_buildings_state(game, seconds)` mirroring the mend-projector driver's shape — iterate placed OverdriveProjector buildings (`source_unique_buildings_state`), bind the frame if missing, refresh frame keys (block_implementation, team_id, rules_state, cheating, enabled), and when `block.properties.has("consumePower")` and enabled and not cheating, fold the pure row into frame["efficiency"] through the shared machinery (`update_consumption_setup_state` + `update_consumption_state` + `apply_update_consumption_state`, should_consume=true when enabled, production_valid=true) as the only first-pass row, so the real-boost fold (OverdriveProjector.java:124) follows power.status.
- Frame key (DECIDED at RED 2026-11-13 ~19:45 +07): `"source_overdrive_projector_building"` — verified no collision: grep finds no `source_overdrive_projector_building` anywhere in the port (the existing `SourceOverdriveProjector*` files use per-cell state dicts, not this meta key). GREEN adds it to `SourcePlacedPowerGraphState.SOURCE_CONSUMER_FRAME_META_KEYS` (one line, same mechanism as the mend-projector key).
- Wiring: call the driver from `SourceFactoryRuntimeState.simulate_factory` (preload const + one call next to the mend-projector tick, the production grouping).
- Header comment quotes: `return build.power.status;` (ConsumePower.java:39), the null-fold line (UnitAssembler.java:469), `hasConsumers = consumers.length > 0;` (Block.java:1449), the smooth-efficiency gate `smoothEfficiency = Mathf.lerpDelta(smoothEfficiency, efficiency, 0.08f);` (OverdriveProjector.java:98), the heat gate `heat = Mathf.lerpDelta(heat, efficiency > 0 ? 1f : 0f, 0.08f);` (OverdriveProjector.java:99), the charge advance `charge += heat * Time.delta;` (OverdriveProjector.java:100), the real-boost fold `return (speedBoost + phaseHeat * speedBoostPhase) * efficiency;` (OverdriveProjector.java:124) — keep each on ONE comment line (the N2148 shootWarmup lesson: a split line fails the source-text test).
- Documented limits (GREEN must record in the pure function's comment, same discipline as N2148–N2156): (1) power-only first pass — the phaseFabric (overdrive-projector) and phaseFabric+silicon (overdrive-dome) booster item rows wait for their own slices; the folded efficiency is the min over the *modeled* consumers (power only). (2) No shouldConsume gate — OverdriveBuild has no shouldConsume override, so the default (BuildingComp.java:755-757, `return enabled;`) applies; the machinery runs with should_consume=true when enabled. (3) No updateTile advance — smoothEfficiency / heat / charge / phaseHeat / useProgress / boost application (OverdriveProjector.java:97-120) wait for their own slices; the proof carries no progress/boost keys, the real-boost fold (OverdriveProjector.java:124) is what the efficiency keys prove. (4) No useProgress consume() rows — useTime 400f / dome 300f (OverdriveProjector.java:117-120) wait for their own slice; the dome's hasBoost=false (Blocks.java:1960) means its phaseHeat stays 0, also part of the updateTile advance.
- Proof scene (new, modeled on the N2156 proof — Main scene, campaign playable slice, `RuntimeProofState`), prefix `C_07_OVERDRIVE_PROJECTOR_POWER_STATUS_PROOF `, 6 keys: `overdrive_has_power_consumer` (catalog overdrive-projector properties has consumePower), `power_row_half`, `power_row_absent_without_consumer`, `power_row_null_folds_one`, `efficiency_folds_power_min` (live tick — place overdrive-projector live, stamp frame["power_status"] = 0.5, call the driver directly so the graph update does not overwrite the stamp), `efficiency_zero_at_no_power`.

## Exact exprs (13, all verified verbatim at scoping — grep 2026-11-13 ~19:45)

- `return build.power.status;` (ConsumePower.java:39)
- `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;` (UnitAssembler.java:469)
- `hasConsumers = consumers.length > 0;` (Block.java:1449)
- `consumePower(3.50f);` (Blocks.java:1946, overdrive-projector def 1944)
- `consumePower(10f);` (Blocks.java:1954, overdrive-dome def 1952)
- `public class OverdriveProjector extends Block{` (OverdriveProjector.java:21)
- `hasPower = true;` (OverdriveProjector.java:38)
- `smoothEfficiency = Mathf.lerpDelta(smoothEfficiency, efficiency, 0.08f);` (OverdriveProjector.java:98)
- `heat = Mathf.lerpDelta(heat, efficiency > 0 ? 1f : 0f, 0.08f);` (OverdriveProjector.java:99)
- `charge += heat * Time.delta;` (OverdriveProjector.java:100)
- `return (speedBoost + phaseHeat * speedBoostPhase) * efficiency;` (OverdriveProjector.java:124)
- `for(var cons : block.nonOptionalConsumers){` (BuildingComp.java:1969)
- `minEfficiency = Math.min(minEfficiency, result);` (BuildingComp.java:1976)

## RED (DONE 2026-11-13 ~19:45 +07, 19:45 report run)

- Test module `tools/mindustry_godot_transpiler/tests/test_c07_overdrive_projector_power_status.py` + register script `tools/mindustry_godot_transpiler/register_c07_overdrive_projector_power_status.py` written (modeled on N2156; frame key decided: `"source_overdrive_projector_building"`).
- RED run: Ran 4 tests in 1.321s, FAILED (failures=1, errors=3) — exactly as expected: registration ERROR KeyError 'N2157', evidence ERROR KeyError 'N2157', source-text ERROR FileNotFoundError on `SourceOverdriveProjectorBuildState.gd` (file does not exist yet), proof FAIL returncode 1 (scene missing, Godot 4.6.2-stable Linux). Re-run confirmed the same breakdown (2× KeyError 'N2157' + FileNotFoundError + returncode 1). Port 7777 was FREE. 13/13 exact exprs verified verbatim at RED (grepped in the Java sources during scoping). SSOT baseline 11322/1607/1528/2847 (unchanged from N2156 — main at 5c4f092), audit 1335. javalang 0.13.0 already present (no reinstall needed).
- Next: GREEN (new `SourceOverdriveProjectorBuildState.gd` pure row + driver, wiring in `SourceFactoryRuntimeState.simulate_factory`, key added to `SOURCE_CONSUMER_FRAME_META_KEYS`, proof scene `C07OverdriveProjectorPowerStatusProof` 6 keys, register script run → expected SSOT 11324/1608/1529/2849), then targeted 4/4 → neighbours → Godot proof → full gate (main thread) → commit + push only when all green.

## GREEN (DONE 2026-11-13 ~20:0x +07, 20:00 report run)

- New `godot-mindustry/src/game/SourceOverdriveProjectorBuildState.gd` (mirrors the mend-projector file): pure `source_overdrive_projector_power_status_row_state` + `source_overdrive_projector_tick_buildings_state` driver + `source_overdrive_projector_tick_frame_state` + `source_overdrive_projector_bind_frame_state`, frame key `"source_overdrive_projector_building"`.
- Wiring: preload const + one tick call in `SourceFactoryRuntimeState.simulate_factory` (next to the mend-projector tick); key added to `SourcePlacedPowerGraphState.SOURCE_CONSUMER_FRAME_META_KEYS`.
- Proof scene `godot-mindustry/tools/runtime_proofs/C07OverdriveProjectorPowerStatusProof.gd` + `.tscn` (modeled on the N2156 proof, overdrive-projector live, 6 keys).
- Register script run OK. SSOT 11324/1608/1529/2849 (exactly as expected at RED), audit 1335. `git diff --check` clean.
- Targeted: Ran 4 tests in 16.279s, OK (includes the Godot proof test). Godot proof GREEN: 9 keys all true, `matches: true` (proof JSON written by the targeted run). Neighbours: C07 power-status family 52/52 OK (170.578s) + wiring-sensitive modules (factory live loop, power-graph grouping/live-update, battery binding, adjacent/unit-factory live loops, turret live loop, consumer cheating) 29/29 OK (110.855s). Port 7777 was FREE at GREEN; javalang 0.13.0 already present (no reinstall needed).
- Next: full gate (attempt 1 launched ~20:12 +07, PID 12581, see Gate) → verify → report/spec/handoff docs → commit + push only when all green.

## Gate (attempt 2 FINISHED GREEN except Godot — main thread, PID 12792, ~20:31 +07)

- Full gate attempt 1 (PID 12581, launched by the 20:00 report worker ~20:12) **DIED at session end ~20:12 +07** — verified by main thread: PID gone, log stopped at 3,513 bytes, no footer. Same worker-launched-gate failure as N2146 PID 9699, N2147 PID 3427, N2149 PID 3798, N2151 PID 16626, N2154 PID 14878.
- Full gate attempt 2 **launched from the MAIN THREAD ~20:13 +07** by main thread: `cd tools/mindustry_godot_transpiler && python3 -c "import javalang" && setsid nohup python3 -m unittest discover -s tests > full-suite-n2157-gate.log 2>&1 < /dev/null &` — **PID 12792, SID 12792 (own session), PPID 12789 (background subshell), CPU ~89%**. No Godot on PATH. No proof scene ran while the gate ran (port-7777 rule). **FINISHED ~20:31 +07: Ran 5725 tests in 1099.125s, FAILED (failures=108, skipped=5), 0 errors** — exactly the expected outcome (107 inherited + 1 new N2157 proof test). Verified by the 20:45 report run: 108 `FAIL:` lines, 0 `ERROR:` lines, all 108 `AssertionError: unexpectedly None` (107 plain assertIsNotNone(godot) + 1 hydration assertIsNotNone(godot, 'Godot required for hydration proof')), including the new N2157 proof test (fails only on assertIsNotNone(godot) at test line 160 — the gate env has no Godot; the proof itself is GREEN headless). Gate clean except Godot. Second-attempt finish.

## Commits (TODO)

## Deferred (NOT this slice)

- OverdriveProjector updateTile advance (smoothEfficiency / heat / charge / phaseHeat / useProgress / boost application, OverdriveProjector.java:97-120), OverdriveProjector booster item rows (overdrive-projector phaseFabric Blocks.java:1948; overdrive-dome phaseFabric+silicon Blocks.java:1961), OverdriveProjector range / phase-range rows (realRange = range + phaseHeat * phaseRangeBoost, OverdriveProjector.java:110), OverdriveProjector useProgress consume() rows (useTime 400f / dome 300f, OverdriveProjector.java:117-120; dome hasBoost=false, Blocks.java:1960).
- MendProjector updateTile advance / suppression gate / booster item rows / range rows (see N2156 handoff).
- BeamDrill updateTile advance / shouldConsume gate / liquid rows / facing-laser binding / drillMultipliers rows; Pump / Fracker / SolidPump updateTile advance / shouldConsume / proximity / warmup rows.
- Remaining projector families (ForceProjector, BaseShield, RegenProjector); payload-producer families (Constructor / PayloadLoader / Unloader / MassDriver / UnitCargoLoader / PayloadDeconstructor).
- spawn_occupied / allow_update / moveOutPayload, net drone sync.
- C07–C12 remain open.

## Notes

- Another agent is using Godot to test the fail errors (user, 08:05). Port 7777 was FREE at RED. Before any proof run, re-check `ss -ltnp | grep 7777` and run proof scenes sequentially — never while a gate runs (port-7777 rule).
- Godot binary is at ~/workspace/godot-bin/godot (symlink to Godot_v4.6.2-stable_linux.x86_64) — NOT on PATH by default; targeted/neighbours ran with PATH="$HOME/workspace/godot-bin:$PATH".
- Worktree at RED: main `5c4f092`, clean except untracked `*.gd.uid` (never stage) + old `full-suite-*.log` files (never stage). New uncommitted files: the N2157 test module + register script + this handoff.
- VM restarts wipe the system-wide javalang install — reinstalled 0.13.0 by the 18:45 run; still present at this RED run. After any VM restart, reinstall javalang first before any gate.
