# Handoff — N2158: ForceProjector power.status live read (force-projector) (C07)

Date: 2026-11-13. Batch: N2158 (single slice). Status: **DONE + PUSHED (gate attempt 1 finished ~21:40 +07, verified by main thread: Ran 5729 in 917.555s, failures=109, skipped=5, 0 errors — all 109 Godot-absent asserts; slice commit 5edf125 on top of PR #2 merge b0a989c).**

## Scope (decided at RED)

- Family: the ForceProjector implementation — **force-projector** (consumePower 4f, size 3, radius 101.7f, shieldHealth 750f Blocks override, cooldownNormal 1.5f, cooldownLiquid 1.2f, cooldownBrokenBase 0.35f, phaseUseTime 350f, phaseRadiusBoost 80f, phaseShieldBoost 400f, sides 6, phaseFabric itemConsumer booster, ConsumeCoolant 0.1f). hasPower=true, hasLiquids=true, hasItems=true. Catalog confirms implementation ForceProjector + consumePower 4.0 (content_registry.json — to re-verify at GREEN; the Blocks.java def is the source of truth, see Exact exprs).
- Why: ForceProjector (ForceProjector.java:30, `public class ForceProjector extends Block{`) has NO placed-buildings driver at all — force-projector would shield as if power.status were 1.0. N2158 is the ForceProjector family's live read — the same proven N2145–N2157 pure-row pattern, one new file over. Third projector family: the deferred list in the N2157 handoff named remaining projectors (Force/BaseShield/Regen) as the next group after OverdriveProjector.
- ForceProjector extends Block, NOT a drill or factory, so it cannot reuse an existing frame key; it gets its own family frame key (the mechanical-pump / beam-drill / mend-projector / overdrive-projector precedent).
- The port has NO SourceForceProjector* files at all yet — no display/runtime state to lean on. The efficiency fold this slice proves is the warmup fold (ForceProjector.java:221, `warmup = Mathf.lerpDelta(warmup, efficiency, 0.1f);`), with radscl following warmup (ForceProjector.java:215) and realRadius folding both (ForceProjector.java:280).
- Out of scope for this slice: large-shield-projector is **BaseShield**, a different class (consumePower 5f, Blocks.java:2056) — stays deferred with shield-projector (BaseShield, 5f). RegenProjector (regen-projector, 1f) also stays deferred.

## Design (decided in scoping, to confirm at RED)

- New file `godot-mindustry/src/game/SourceForceProjectorBuildState.gd` (mirrors SourceOverdriveProjectorBuildState.gd): pure `source_force_projector_power_status_row_state(frame, has_power_consumer)` returning `{"has_power_row": false, "row": {}}` without a consumer, else `{"has_power_row": true, "row": {"result": <live>, "is_power": true}}` where live is the stamped frame value, null folding to 1.0 (the assembler convention, UnitAssembler.java:469); plus driver `source_force_projector_tick_buildings_state(game, seconds)` mirroring the overdrive-projector driver's shape — iterate placed ForceProjector buildings (`source_unique_buildings_state`), bind the frame if missing, refresh frame keys (block_implementation, team_id, rules_state, cheating, enabled), and when `block.properties.has("consumePower")` and enabled and not cheating, fold the pure row into frame["efficiency"] through the shared machinery (`update_consumption_setup_state` + `update_consumption_state` + `apply_update_consumption_state`, should_consume=true when enabled, production_valid=true) as the only first-pass row, so the warmup fold (ForceProjector.java:221) follows power.status.
- Frame key (DECIDED at RED 2026-11-13 ~21:00 +07): `"source_force_projector_building"` — verified no collision: grep finds no `source_force_projector_building` anywhere in the port. GREEN adds it to `SourcePlacedPowerGraphState.SOURCE_CONSUMER_FRAME_META_KEYS` (one line, same mechanism as the overdrive-projector key).
- Wiring: call the driver from `SourceFactoryRuntimeState.simulate_factory` (preload const + one call next to the overdrive-projector tick, the production grouping).
- Header comment quotes: `return build.power.status;` (ConsumePower.java:39), the null-fold line (UnitAssembler.java:469), `hasConsumers = consumers.length > 0;` (Block.java:1449), the warmup gate `warmup = Mathf.lerpDelta(warmup, efficiency, 0.1f);` (ForceProjector.java:221), the radscl gate `radscl = Mathf.lerpDelta(radscl, broken ? 0f : warmup, 0.05f);` (ForceProjector.java:215), the real-radius fold `return (radius + phaseHeat * phaseRadiusBoost) * radscl;` (ForceProjector.java:280), the phase-heat gate `phaseHeat = Mathf.lerpDelta(phaseHeat, Mathf.num(phaseValid), 0.1f);` (ForceProjector.java:209), the consume gate `if(phaseValid && !broken && timer(timerUse, phaseUseTime / timeScale) && efficiency > 0){` (ForceProjector.java:211) — keep each on ONE comment line (the N2148 shootWarmup lesson: a split line fails the source-text test).
- Documented limits (GREEN must record in the pure function's comment, same discipline as N2148–N2157): (1) power-only first pass — the phaseFabric booster item row (Blocks.java:1974) and the ConsumeCoolant 0.1f coolant rows (ForceProjector.java:69-71) wait for their own slices; the folded efficiency is the min over the *modeled* consumers (power only). (2) No shouldConsume gate — ForceBuild has no shouldConsume override, so the default (BuildingComp.java:755-757, `return enabled;`) applies; the machinery runs with should_consume=true when enabled. (3) No updateTile advance — phaseValid / phaseHeat / consume() / radscl / warmup / buildup / broken / deflectBullets (ForceProjector.java:207-268) wait for their own slices; the proof carries no shield/warmup/buildup keys, the warmup fold (ForceProjector.java:221) is what the efficiency keys prove. (4) No phase-radius / phase-shield rows — realRadius (ForceProjector.java:280) and shieldHealth + phaseShieldBoost * phaseHeat (ForceProjector.java:195) need phaseHeat state the tick does not track yet.
- Proof scene (new, modeled on the N2157 proof — Main scene, campaign playable slice, `RuntimeProofState`), prefix `C_07_FORCE_PROJECTOR_POWER_STATUS_PROOF `, 6 keys: `force_has_power_consumer` (catalog force-projector properties has consumePower), `power_row_half`, `power_row_absent_without_consumer`, `power_row_null_folds_one`, `efficiency_folds_power_min` (live tick — place force-projector live, stamp frame["power_status"] = 0.5, call the driver directly so the graph update does not overwrite the stamp), `efficiency_zero_at_no_power`.

## Exact exprs (13, all verified verbatim at scoping — grep 2026-11-13 ~21:00)

- `return build.power.status;` (ConsumePower.java:39)
- `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;` (UnitAssembler.java:469)
- `hasConsumers = consumers.length > 0;` (Block.java:1449)
- `consumePower(4f);` (Blocks.java:1975, force-projector def 1964)
- `public class ForceProjector extends Block{` (ForceProjector.java:30)
- `hasPower = true;` (ForceProjector.java:76)
- `warmup = Mathf.lerpDelta(warmup, efficiency, 0.1f);` (ForceProjector.java:221)
- `radscl = Mathf.lerpDelta(radscl, broken ? 0f : warmup, 0.05f);` (ForceProjector.java:215)
- `return (radius + phaseHeat * phaseRadiusBoost) * radscl;` (ForceProjector.java:280)
- `phaseHeat = Mathf.lerpDelta(phaseHeat, Mathf.num(phaseValid), 0.1f);` (ForceProjector.java:209)
- `if(phaseValid && !broken && timer(timerUse, phaseUseTime / timeScale) && efficiency > 0){` (ForceProjector.java:211)
- `for(var cons : block.nonOptionalConsumers){` (BuildingComp.java:1969)
- `minEfficiency = Math.min(minEfficiency, result);` (BuildingComp.java:1976)

## RED (DONE 2026-11-13 ~21:00 +07, 21:00 report run)

- Test module `tools/mindustry_godot_transpiler/tests/test_c07_force_projector_power_status.py` + register script `tools/mindustry_godot_transpiler/register_c07_force_projector_power_status.py` written (modeled on N2157; frame key decided: `"source_force_projector_building"`).
- RED run: Ran 4 tests in 2.654s, FAILED (failures=1, errors=3) — exactly as expected: registration ERROR KeyError 'N2158', evidence ERROR KeyError 'N2158', source-text ERROR FileNotFoundError on `SourceForceProjectorBuildState.gd` (file does not exist yet), proof FAIL returncode 1 (scene missing, Godot 4.6.2-stable Linux). Re-run confirmed the same breakdown (2× KeyError 'N2158' + FileNotFoundError + returncode 1). Port 7777 was FREE. 13/13 exact exprs verified verbatim at RED (grepped in the Java sources during scoping). SSOT baseline 11324/1608/1529/2849 (unchanged from N2157 — main at 314eaf7), audit 1335. javalang 0.13.0 REINSTALLED at this run (VM restart had wiped it again — fourth wipe today; `pip install --break-system-packages -r tools/mindustry_godot_transpiler/requirements.txt` from repo root).
- Next: GREEN (new `SourceForceProjectorBuildState.gd` pure row + driver, wiring in `SourceFactoryRuntimeState.simulate_factory`, key added to `SOURCE_CONSUMER_FRAME_META_KEYS`, proof scene `C07ForceProjectorPowerStatusProof` 6 keys, register script run → expected SSOT 11326/1609/1530/2851), then targeted 4/4 → neighbours → Godot proof → full gate (main thread) → commit + push only when all green.

## GREEN (DONE 2026-11-13 ~21:30 +07, 21:15 report run)

- New `godot-mindustry/src/game/SourceForceProjectorBuildState.gd` (mirror of the overdrive driver): pure `source_force_projector_power_status_row_state` + `source_force_projector_tick_frame_state` + `source_force_projector_bind_frame_state` + driver `source_force_projector_tick_buildings_state`; frame key `"source_force_projector_building"`; implementation list `["ForceProjector"]`.
- Wiring: preload + one call in `SourceFactoryRuntimeState.simulate_factory` next to the overdrive-projector tick; `"source_force_projector_building"` appended to `SOURCE_CONSUMER_FRAME_META_KEYS` in `SourcePlacedPowerGraphState.gd` (line 140).
- Proof scene `godot-mindustry/tools/runtime_proofs/C07ForceProjectorPowerStatusProof.gd` + `.tscn` (mirror of the N2157 proof, prefix `C_07_FORCE_PROJECTOR_POWER_STATUS_PROOF `, 6 keys).
- Register script run: SSOT 11326/1609/1530/2851 — exactly as expected. Audit 1335 (unchanged).
- Targeted: Ran 4 tests in 14.927s, OK (includes the Godot proof test). Godot proof GREEN standalone: 9 keys all true, `matches: true`, no ERROR (port 7777 was FREE). Neighbours: C07 power-status family 56/56 OK (167.4s) + wiring-sensitive modules 32/32 OK (113.3s) — factory live loop, power-graph grouping/live-update, battery binding/placement, adjacent/unit-factory live loops, turret live loop, consumer cheating.
- javalang 0.13.0 already present (no reinstall needed). `git diff --check` clean (run at completion).
- Next: full gate from the MAIN THREAD (expected Ran ~5729, failures=109, skipped=5, 0 errors — all Godot-absent asserts), then commit + push only when the gate is verified green. Slice files to stage (never `*.gd.uid`): the new driver + proof scene .gd/.tscn, the test module + register script, this handoff, `SourceFactoryRuntimeState.gd`, `SourcePlacedPowerGraphState.gd`, SSOT JSONs under `godot-mindustry/src/generated/`.

## Gate (DONE — attempt 1, finished ~21:40 +07)

- Full gate attempt 1 **launched from the MAIN THREAD ~21:25 +07** by main thread: `cd tools/mindustry_godot_transpiler && python3 -c "import javalang" && setsid nohup python3 -m unittest discover -s tests > full-suite-n2158-gate.log 2>&1 < /dev/null &` — **PID 7853, SID 7853 (own session), PPID 7850 (background subshell), CPU ~92%, log growing** (765 → 1,120 bytes in 3s, verified ~21:25). No Godot on PATH. No proof scene ran while the gate ran (port-7777 rule). **FINISHED ~21:40 +07 (first-attempt finish): Ran 5729 in 917.555s, FAILED (failures=109, skipped=5), 0 errors** — exactly as expected (108 inherited + 1 new N2158 proof test). Verified by main thread: 109 `FAIL:` lines, 0 `ERROR:` lines, 108 plain assertIsNotNone(godot) bodies + 1 hydration (`test_live_block_shared_consumers_and_optional_efficiency_runtime`), including the new N2158 proof test (fails only on `assertIsNotNone(godot)` — the gate env has no Godot on PATH; the proof itself is GREEN headless). Gate clean except Godot.
- While the gate ran, the user asked to merge PR #2 (Windows Godot verification of N2146–N2155, duynguyen16689) — merged server-side ~21:41 +07 (commit `b0a989c`, rebased onto main `314eaf7`), then pulled locally. The PR adds only docs + evidence files (64 files, +1840/−0, no .gd/.py game or test changes), so it did not touch the gate's files or the uncommitted N2158 slice files; the gate footer was already written before the pull. N2158 commits are made on top of `b0a989c`.

## Commits

- Slice: `5edf125` — C07: N2158 ForceProjector power.status live read (force-projector; pure power row + driver wiring; proof 6 keys), 13 files, +924/−1.
- Docs: `1466f2c` (report + design spec + this handoff).
- GOAL.md debt-line: `5ecb42d` (names the N2158 slice commit `5edf125`; also checks off the N2148–N2155 Windows Godot debt entries — PR #2, commit `b0a989c`).
- Handoff-hash: this commit.

## Deferred (NOT this slice)

- ForceProjector updateTile advance (phaseValid / phaseHeat / consume() / radscl / warmup / buildup / broken / deflectBullets, ForceProjector.java:207-268), ForceProjector booster item row (phaseFabric, Blocks.java:1974), ForceProjector coolant rows (ConsumeCoolant 0.1f, ForceProjector.java:69-71), ForceProjector phase-radius / phase-shield rows (ForceProjector.java:280/195), ForceProjector broken / buildup rows (ForceProjector.java:223-262).
- Remaining projector families (BaseShield shield-projector 5f / large-shield-projector 5f, RegenProjector regen-projector 1f); payload producers (Constructor / PayloadLoader / Unloader / MassDriver / UnitCargoLoader / PayloadDeconstructor).
- OverdriveProjector updateTile advance / booster item rows / range rows / useProgress rows; MendProjector updateTile advance / suppression gate / booster item rows / range rows; BeamDrill / Pump / Fracker / SolidPump updateTile advance / shouldConsume / liquid / proximity rows (see register script DEFERRED).
- spawn_occupied / allow_update / moveOutPayload, net drone sync.
- C07–C12 remain open.

## Notes

- Another agent is using Godot to test the fail errors (user, 08:05). Port 7777 was FREE at RED. Before any proof run, re-check `ss -ltnp | grep 7777` and run proof scenes sequentially — never while a gate runs (port-7777 rule).
- Godot binary is at ~/workspace/godot-bin/godot (symlink to Godot_v4.6.2-stable_linux.x86_64) — NOT on PATH by default; targeted/neighbours ran with PATH="$HOME/workspace/godot-bin:$PATH".
- Worktree at RED: main `314eaf7`, clean except untracked `*.gd.uid` (never stage). New uncommitted files: the N2158 test module + register script + this handoff.
- VM restarts wipe the system-wide javalang install — reinstalled 0.13.0 at this RED run. After any VM restart, reinstall javalang first before any gate.
- N2158 proof not yet run on Windows Godot (debt in GOAL.md §5 — to add at GREEN completion, scene reaches Windows with the slice commit).
