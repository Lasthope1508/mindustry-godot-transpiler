# Handoff — N2156: MendProjector power.status live read (mender / mend-projector) (C07)

Date: 2026-11-13. Batch: N2156 (single slice). Status: **GREEN DONE (2026-11-13 ~19:0x +07, 19:00 report run — verified by main thread: targeted re-run 4/4 OK in 14.5s, proof JSON 9 keys all true, SSOT 11322/1607/1528/2847; neighbours 90/90 OK in 307.4s per the 19:00 run, recorded in the handoff). Full gate attempt 1 (MAIN THREAD ~19:09 +07, PID 5359) FINISHED ~19:27 +07, verified by the 19:30 report run: Ran 5721 in 1083.854s, failures=107, skipped=5, 0 errors — all 107 Godot-absent asserts (106 plain + 1 hydration), including the new N2156 proof test. Gate GREEN except Godot. Slice DONE + PUSHED (see Commits).**

## Scope (decided at RED)

- Family: the MendProjector implementation — **mender** (consumePower 0.3f, size 1, reload 200f, range 40f, healPercent 4f, phaseBoost 4f, phaseRangeBoost 20f, silicon booster) and **mend-projector** (consumePower 1.5f, size 2, reload 250f, range 85f, healPercent 11f, phaseBoost 15f, phaseFabric booster). Both havePower=true, hasItems=true. Catalog confirms implementation MendProjector + consumePower 0.3 / 1.5, consumesPower true, hasPower true, connectedPower true (content_registry.json).
- Why: MendProjector (MendProjector.java:21, `public class MendProjector extends Block{`) has NO placed-buildings driver at all — mender / mend-projector would heal as if power.status were 1.0. N2156 is the MendProjector family's live read — the same proven N2145–N2155 pure-row pattern, one new file over. First projector family: the deferred list in the N2155 handoff named projectors (Mend/Overdrive/Force/BaseShield) as the next group after BeamDrill.
- MendProjector extends Block, NOT a drill or factory, so it cannot reuse an existing frame key; it gets its own family frame key (the mechanical-pump / beam-drill precedent).
- The port already has MendProjector display/runtime state (SourceMendProjectorRuntimeState.gd reads `runtime_step.get("efficiency", 1.0)` and multiplies the heal by it, `healed_amount *= float(runtime_step.get("efficiency", 1.0))` at :67) — the heal fold already consumes efficiency; the missing piece is the live power.status → efficiency driver, which is exactly this slice.
- Families still deferred after this slice: remaining projectors (OverdriveProjector overdrive-projector 3.5f / overdrive-dome 10f, ForceProjector 4f, BaseShield shield-projector 5f, RegenProjector 1f); payload producers (Constructor / PayloadLoader / Unloader / MassDriver / UnitCargoLoader / PayloadDeconstructor).

## Design (decided in scoping, to confirm at RED)

- New file `godot-mindustry/src/game/SourceMendProjectorBuildState.gd` (mirrors SourceBeamDrillBuildState.gd): pure `source_mend_projector_power_status_row_state(frame, has_power_consumer)` returning `{"has_power_row": false, "row": {}}` without a consumer, else `{"has_power_row": true, "row": {"result": <live>, "is_power": true}}` where live is the stamped frame value, null folding to 1.0 (the assembler convention, UnitAssembler.java:469); plus driver `source_mend_projector_tick_buildings_state(game, seconds)` mirroring the beam-drill driver's shape — iterate placed MendProjector buildings (`source_unique_buildings_state`), bind the frame if missing, refresh frame keys (block_implementation, team_id, rules_state, cheating, enabled), and when `block.properties.has("consumePower")` and enabled and not cheating, fold the pure row into frame["efficiency"] through the shared machinery (`update_consumption_setup_state` + `update_consumption_state` + `apply_update_consumption_state`, should_consume=true when enabled, production_valid=true) as the only first-pass row, so the heal fold (MendProjector.java:113) follows power.status.
- Frame key (DECIDED at RED 2026-11-13 ~18:45 +07): `"source_mend_projector_building"` — verified no collision: grep finds no `source_mend_projector_building` anywhere in the port (the existing `SourceMendProjector*` files use per-cell state dicts, not this meta key). GREEN adds it to `SourcePlacedPowerGraphState.SOURCE_CONSUMER_FRAME_META_KEYS` (one line, same mechanism as the beam-drill key).
- Wiring: call the driver from `SourceFactoryRuntimeState.simulate_factory` (preload const + one call next to the beam-drill tick, the production grouping).
- Header comment quotes: `return build.power.status;` (ConsumePower.java:39), the null-fold line (UnitAssembler.java:469), `hasConsumers = consumers.length > 0;` (Block.java:1449), the smooth-efficiency gate `smoothEfficiency = Mathf.lerpDelta(smoothEfficiency, efficiency, 0.08f);` (MendProjector.java:96), the heat gate `heat = Mathf.lerpDelta(heat, efficiency > 0 && canHeal ? 1f : 0f, 0.08f);` (MendProjector.java:97), the charge advance `charge += heat * delta();` (MendProjector.java:98), the heal fold `other.heal(other.maxHealth() * (healPercent + phaseHeat * phaseBoost) / 100f * efficiency);` (MendProjector.java:113) — keep each on ONE comment line (the N2148 shootWarmup lesson: a split line fails the source-text test).
- Documented limits (GREEN must record in the pure function's comment, same discipline as N2148–N2155): (1) power-only first pass — the silicon (mender) and phaseFabric (mend-projector) booster item rows wait for their own slices; the folded efficiency is the min over the *modeled* consumers (power only). (2) No shouldConsume gate — MendBuild has no shouldConsume override, so the default (BuildingComp.java:755-757, `return enabled;`) applies; the machinery runs with should_consume=true when enabled. (3) No suppression gate — `canHeal = !checkSuppression();` (MendProjector.java:94) needs suppression state the tick does not track yet. (4) No updateTile advance — smoothEfficiency / heat / charge / phaseHeat / heal (MendProjector.java:94-120) wait for their own slices; the proof carries no progress/heal keys, the heal fold (MendProjector.java:113) is what the efficiency keys prove.
- Proof scene (new, modeled on the N2155 proof — Main scene, campaign playable slice, `RuntimeProofState`), prefix `C_07_MEND_PROJECTOR_POWER_STATUS_PROOF `, 6 keys: `mender_has_power_consumer` (catalog mender properties has consumePower), `power_row_half`, `power_row_absent_without_consumer`, `power_row_null_folds_one`, `efficiency_folds_power_min` (live tick — place mender live, stamp frame["power_status"] = 0.5, call the driver directly so the graph update does not overwrite the stamp), `efficiency_zero_at_no_power`.

## Exact exprs (13, all verified verbatim at scoping — grep 2026-11-13 ~18:45)

- `return build.power.status;` (ConsumePower.java:39)
- `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;` (UnitAssembler.java:469)
- `hasConsumers = consumers.length > 0;` (Block.java:1449)
- `consumePower(0.3f);` (Blocks.java:1921, mender def 1919)
- `consumePower(1.5f);` (Blocks.java:1934, mend-projector def 1932)
- `public class MendProjector extends Block{` (MendProjector.java:21)
- `hasPower = true;` (MendProjector.java:42)
- `smoothEfficiency = Mathf.lerpDelta(smoothEfficiency, efficiency, 0.08f);` (MendProjector.java:96)
- `heat = Mathf.lerpDelta(heat, efficiency > 0 && canHeal ? 1f : 0f, 0.08f);` (MendProjector.java:97)
- `charge += heat * delta();` (MendProjector.java:98)
- `other.heal(other.maxHealth() * (healPercent + phaseHeat * phaseBoost) / 100f * efficiency);` (MendProjector.java:113)
- `for(var cons : block.nonOptionalConsumers){` (BuildingComp.java:1969)
- `minEfficiency = Math.min(minEfficiency, result);` (BuildingComp.java:1976)

## RED (DONE 2026-11-13 ~18:45 +07, 18:45 report run)

- Test module `tools/mindustry_godot_transpiler/tests/test_c07_mend_projector_power_status.py` + register script `tools/mindustry_godot_transpiler/register_c07_mend_projector_power_status.py` written (modeled on N2155; frame key decided: `"source_mend_projector_building"`).
- RED run: Ran 4 tests in 4.126s, FAILED (failures=1, errors=3) — exactly as expected: registration ERROR KeyError 'N2156', evidence ERROR KeyError 'N2156', source-text ERROR FileNotFoundError on `SourceMendProjectorBuildState.gd` (file does not exist yet), proof FAIL returncode 1 (scene missing, Godot 4.6.2-stable Linux). Re-run confirmed the same breakdown (2× KeyError 'N2156' + FileNotFoundError + returncode 1). Port 7777 was FREE. 13/13 exact exprs verified verbatim at RED (grepped in the Java sources during scoping). SSOT baseline 11320/1606/1527/2845 (unchanged from N2155 — main at 516ac38), audit 1335. javalang 0.13.0 REINSTALLED at RED (VM restarted since the N2155 run — the system-wide pip install was wiped; `pip install --break-system-packages -r tools/mindustry_godot_transpiler/requirements.txt` from the repo root).
- Next: GREEN (new `SourceMendProjectorBuildState.gd` pure row + driver, wiring in `SourceFactoryRuntimeState.simulate_factory`, key added to `SOURCE_CONSUMER_FRAME_META_KEYS`, proof scene `C07MendProjectorPowerStatusProof` 6 keys, register script run → expected SSOT 11322/1607/1528/2847), then targeted 4/4 → neighbours → Godot proof → full gate (main thread) → commit + push only when all green.

## GREEN (DONE 2026-11-13 ~19:0x +07, 19:00 report run)

- New `godot-mindustry/src/game/SourceMendProjectorBuildState.gd` (mirrors SourceBeamDrillBuildState.gd): pure `source_mend_projector_power_status_row_state` (null stamp folds to 1.0, assembler convention) + `source_mend_projector_tick_buildings_state` driver + `source_mend_projector_bind_frame_state` + `source_mend_projector_tick_frame_state`, frame key `"source_mend_projector_building"`.
- Wiring: preload + one call in `SourceFactoryRuntimeState.simulate_factory` next to the beam-drill tick; `"source_mend_projector_building"` added to `SOURCE_CONSUMER_FRAME_META_KEYS` in SourcePlacedPowerGraphState.gd (one line).
- Proof scene `tools/runtime_proofs/C07MendProjectorPowerStatusProof.gd` + `.tscn`, prefix `C_07_MEND_PROJECTOR_POWER_STATUS_PROOF`, 6 keys (mender_has_power_consumer, power_row_half, power_row_absent_without_consumer, power_row_null_folds_one, efficiency_folds_power_min, efficiency_zero_at_no_power).
- Register script run OK. SSOT 11322/1607/1528/2847 (exactly as expected at RED), audit 1335. `git diff --check` clean.
- Targeted tests: **4/4 OK in 16.158s** (registration + exact-exprs + source-text + reference-graph/proof test — the proof scene ran headless, matches:true). Port 7777 was FREE. javalang 0.13.0 already present (no reinstall needed).
- Neighbours: **90/90 OK in 307.393s** — C07 power family N2142/N2145–N2156 (13 modules × 4 = 52) + battery power-status binding + factory/adjacent/unit-factory/continuous-liquid-turret consumer bindings + factory/adjacent/unit-factory/turret/continuous-liquid-turret live loops (38).
- Godot proof standalone re-run: exit 0, 0 `ERROR:` lines, proof JSON 9 keys all true, `matches:true`. Port 7777 was FREE before and after the run; no gate was running.
- Next: full gate (main thread, ~15 min) → commit + push only when all green. Worktree: main 516ac38 + N2156 files uncommitted (never stage `*.gd.uid`, `targeted-env-fix.log`, `full-suite-*.log`).

## Gate (DONE — attempt 1, GREEN except Godot)

- Full gate attempt 1 **launched from the MAIN THREAD ~19:09 +07** by main thread: `cd tools/mindustry_godot_transpiler && python3 -c "import javalang" && setsid nohup python3 -m unittest discover -s tests > full-suite-n2156-gate.log 2>&1 < /dev/null &` — **PID 5359, SID 5359 (own session), PPID 5356 (background subshell)**. No Godot on PATH. No proof scene ran while the gate ran (port-7777 rule).
- **FINISHED ~19:27 +07, verified by the 19:30 report run: Ran 5721 tests in 1083.854s, FAILED (failures=107, skipped=5), 0 errors** — exactly the expected outcome (106 inherited + 1 new N2156 proof test). Verification: 107 `FAIL:` lines, 0 `ERROR:` lines — all 107 `AssertionError: unexpectedly None` (106 plain assertIsNotNone(godot) + 1 hydration assertIsNotNone(godot, 'Godot required for hydration proof')), including the new N2156 proof test `test_reference_graph_and_actual_c07_mend_projector_power_status`. Gate clean except Godot. First-attempt finish. Note: VM restarted ~18:39 +07 (third restart today) and wiped javalang again — reinstalled 0.13.0 by the 18:45 run; import verified OK before this launch.

## Commits

- Slice: `fbe08f1` — C07: N2156 MendProjector power.status live read (mender / mend-projector; pure power row + driver wiring; proof 6 keys) — 13 files, +900/−1.
- Docs: `0bf8a84` — Docs: N2156 report + design spec + handoff (gate clean except Godot) — report + spec (Status Summary 1606→1607) + handoff.
- GOAL.md debt line: `353c447` — Docs: GOAL.md names the N2156 slice commit (fbe08f1) that carries its proof to Windows.
- This handoff-hash commit records the slice + docs hashes above. All four commits pushed to origin main (see push verification below).
- Push: `git push origin main` from the 19:30 report run — main at this commit; `git log origin/main` confirms the four commits on the fork.

## Deferred (NOT this slice)

- MendProjector updateTile advance (smoothEfficiency / heat / charge / phaseHeat / heal, MendProjector.java:94-120), MendProjector suppression gate (canHeal = !checkSuppression(), MendProjector.java:94), MendProjector booster item rows (silicon / phaseFabric, Blocks.java:1929/1941), MendProjector range / phase-range rows (realRange = range + phaseHeat * phaseRangeBoost, MendProjector.java:104).
- BeamDrill updateTile advance / shouldConsume gate / liquid rows / facing-laser binding / drillMultipliers rows; Pump / Fracker / SolidPump updateTile advance / shouldConsume / proximity / warmup rows.
- Remaining projector families (OverdriveProjector, ForceProjector, BaseShield, RegenProjector); payload-producer families (Constructor / PayloadLoader / Unloader / MassDriver / UnitCargoLoader / PayloadDeconstructor).
- spawn_occupied / allow_update / moveOutPayload, net drone sync.
- C07–C12 remain open.

## Notes

- Another agent is using Godot to test the fail errors (user, 08:05). Port 7777 was FREE at RED. Before any proof run, re-check `ss -ltnp | grep 7777` and run proof scenes sequentially — never while a gate runs (port-7777 rule).
- Godot binary is at ~/workspace/godot-bin/godot (symlink to Godot_v4.6.2-stable_linux.x86_64) — NOT on PATH by default; targeted/neighbours ran with PATH="$HOME/workspace/godot-bin:$PATH".
- Worktree at RED: main `516ac38`, clean except untracked `*.gd.uid` (never stage) + old `full-suite-*.log` files (never stage). New uncommitted files: the N2156 test module + register script + this handoff.
- VM restarted between the N2155 completion (~18:3x) and this run — javalang was wiped and reinstalled 0.13.0 at RED. After any VM restart, reinstall javalang first before any gate.
