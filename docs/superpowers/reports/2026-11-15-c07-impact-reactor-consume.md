# Report — N2187: ImpactReactor consume live read (blast-compound timer burn + cryofluid drain) (C07)

Date: 2026-11-15. Batch: N2187 (single slice). Status: **DONE + PUSHED (2026-11-15 ~11:4x +07 — targeted 4/4 OK, neighbours 204/204 OK, Godot proof GREEN 7 keys matches:true, full gate attempt 1 Ran 5845 in 966.109s, failures=138, skipped=5, 0 errors — all 138 verified Godot-absent asserts). Slice commit `b6ead74`.**

## What changed

The consume-side slice N2186 explicitly deferred (its handoff §"Deferred": "Item/liquid consumption (blast-compound 1, cryofluid 0.25f, consume timer) — own slices"). Single def, **impact-reactor** (`consumePower(25f)`, Blocks.java:2642, folded by N2182; `consumeItem(Items.blastCompound)`, Blocks.java:2643; `consumeLiquid(Liquids.cryofluid, 0.25f)`, Blocks.java:2644; `itemDuration = 140f`, Blocks.java:2637, overriding the class default 60f; `liquidCapacity = 80f`, Blocks.java:2640). No family split, no second def.

What N2182/N2186 already did (NOT redone): the consumer-side power fold (N2182) and the warmup + production model (N2186) — `source_impact_reactor_power_production_state` in the same `SourceImpactReactorBuildState.gd`, frame keys `warmup` / `production_efficiency` / `total_progress` / `power_production`.

What N2187 adds (consume side), in the SAME `SourceImpactReactorBuildState.gd` file (no new file):

- Pure `source_impact_reactor_consume_state(frame, delta) -> Dictionary` — timer accumulator reset-to-0 on fire (overshoot dropped, `Interval.get` semantics: `return Time.time - times[id] >= time || Time.time < times[id]`, TimerComp.java; zero time_scale → infinite interval → never fires); burn **−1 blast-compound per fire, only inside the warmup hard gate** (`efficiency >= 0.9999f && power.status >= 0.99f`, ImpactReactor.java:79 → `if(timer(timerUse, itemDuration / timeScale)){ consume(); }`, ImpactReactor.java:91-92; `consume()` iterates `block.consumers` and only `ConsumeItems.trigger` fires — `build.items.remove(stack.item, Math.round(stack.amount * multiplier))`, ConsumeItems.java:44-48, amount 1 by default); cryofluid drain **0.25f × edelta per tick whenever enabled and efficiency > 0, NOT gated on the warmup hard gate** (`build.liquids.remove(liquid, amount * build.edelta() * multiplier)`, ConsumeLiquid.java:37-39; `edelta() = efficiency * delta()`, BuildingComp.java:1927-1929; run by `updateConsumption()`'s second pass when `update && efficiency > 0`, BuildingComp.java:1996-2000). Both removes clamp at the stock on hand, neither dict ever goes negative.
- The EXISTING driver stamps `items` / `liquids` / `time_scale` / `consume_timer` before the call and all five result keys (`blast_compound_burned` / `cryofluid_drained` / `consume_timer` / `items` / `liquids`) after it. No new driver. No gameplay touched — pure function + driver stamping only.
- Proof scene `godot-mindustry/tools/runtime_proofs/C07ImpactReactorConsumeProof.gd/.tscn` (mirror the N2186 proof, 4 keys): burn −1 per 140s inside the gate, no burn outside the gate, cryofluid drains 0.25f × edelta per tick while efficiency > 0, no drain when disabled / efficiency 0. The proof calls the pure function with synthetic frames (no long live tick: drive the pure function with a pre-advanced timer stamp).

The 4 RED questions were RESOLVED at RED (recorded in test + register): (1) timer stamp representation — accumulator reset-to-0 (overshoot dropped, matching `Interval.get`'s reset-to-Time.time). (2) Frame `items` / `liquids` / `time_scale` / `consume_timer` were NOT on the reactor frame — the driver stamps them (N2186 precedent). (3) Proof keys: the 4 above. (4) `consumeTriggerValid()` interplay: `ConsumeItems.efficiency` is `build.consumeTriggerValid() || build.items.has(items, multiplier)` (ConsumeItems.java:51-53) — the folded efficiency already accounts for item presence via N2182's fold, so the burn assumes the gate held; modeled with `productionValid` default true (N2182 precedent).

**VM restart #10 ~11:12 +07** (04:12 UTC; uptime 3 min at the 11:15 check): javalang wiped, reinstalled 0.13.0 by the 11:00 worker. No work lost (GREEN files + SSOT survived in ~/workspace). The restart killed the 10:45 worker's wiring loop mid-run (stopped at test_turret_live_loop); main thread re-ran the full wiring set after the reinstall.

## RED

Test module `tools/mindustry_godot_transpiler/tests/test_c07_impact_reactor_consume.py` (22,049 bytes, 359 lines) + register script `tools/mindustry_godot_transpiler/register_c07_impact_reactor_consume.py` (15,322 bytes), written by the 10:30 worker. Register script: EXACT_EXPRS = the 42 verified exprs (all present verbatim in upstream — script check, 0 missing), DEFERRED = N2186's 249 + 4 new entries = 253.

RED run: Ran 4 tests, FAILED (failures=2, errors=2) — the classic RED signature (register NOT yet run, unlike N2185/N2186 where the register ran at RED): ERROR `test_c07_impact_reactor_consume_registration` + `test_all_c07_impact_reactor_consume_input_evidence_is_exact` — `KeyError: 'N2187'` (ledger has no N2187 row); FAIL `test_impact_reactor_consume_state` — missing `source_impact_reactor_consume_state` function; FAIL `test_reference_graph_and_actual_c07_impact_reactor_consume` — Godot `Cannot open file 'res://tools/runtime_proofs/C07ImpactReactorConsumeProof.tscn'` (proof scene not yet written). Log: `tools/mindustry_godot_transpiler/n2187-red.log`. Port 7777 FREE before the run. SSOT at RED — **symbols 11384 / slices 1637 / contracts 1558 / schemas 2907** (the N2186 baseline — register not yet run). `git diff --check` clean.

## GREEN

- `SourceImpactReactorBuildState.gd` extended (same file as N2182/N2186, +50 lines): pure `source_impact_reactor_consume_state(frame, delta)` + driver stamping of `items` / `liquids` / `time_scale` / `consume_timer` before the call and the 5 result keys after it.
- Proof scene `godot-mindustry/tools/runtime_proofs/C07ImpactReactorConsumeProof.gd` + `.tscn` (N2186 model, 4 keys + registry_valid / one_headquarter_per_ssot / matches). Proof `.json` is gitignored (never stage, per AGENTS.md rule on proof .json).
- Register script run at GREEN (`python3 register_c07_impact_reactor_consume.py`, exit OK): SSOT **11389/1638/1559/2909** — exactly the expected values (+5/+1/+1/+2; symbols +5 — the consume function + 4 result symbols); audit 1335 unchanged; ledger N2187 status done. Power shard DID change: power_slices 112→113, power_api_contracts 91→92, purely additive N2187 mirrors (the N2182 precedent — ImpactReactor.java lives under `world/blocks/power/`).
- Targeted (main-thread re-run at completion, Godot 4.6.2 on PATH, port 7777 FREE): **Ran 4 tests in 17.713s, OK**. (One earlier main-thread re-run failed 1 test — a port-7777 collision with the family run in flight at the time; re-run between the family's proof scenes passed 4/4. Environmental, not a regression.)
- Godot proof (inside the targeted run, Linux headless 4.6.2): **7 keys all true, matches:true** — `burn_minus_one_per_140s_inside_gate`, `no_burn_outside_gate`, `cryofluid_drains_per_tick_while_efficiency_positive`, `no_drain_when_disabled_or_efficiency_zero`, `registry_valid`, `one_headquarter_per_ssot`, `matches`. No ERROR in output.

## Neighbours

Family run ~10:5x +07 (41 modules, 164 tests — the `test_c07_*_power_status.py` pattern does NOT match the new consume module, its name ends `_consume`, so the family count stays 164), Godot 4.6.2 on PATH — log `tools/mindustry_godot_transpiler/n2187-neighbours.log`. **Ran 164 tests in 561.687s, FAILED (failures=5)** on the first pass — all 5 are `test_reference_graph_and_actual_*` proof tests (accelerator, adjacent-factory, base-shield, beam-drill, build-turret), the classic port-7777 flake signature (proof itself matches:true, only the no-ERROR assert trips). **Isolated re-run of all 5 modules: each 4/4 OK** (log `n2187-family-rerun.log`) → family **164/164**.

New consume module (10:45 worker): **Ran 4 tests in 12.973s, OK**.

Wiring-standard set (9 modules / 32 tests, the N2177 lesson) — main thread ~11:17, sequentially after the family run (one script, no parallel Godot runs, no port-7777 contention): **ALL OK (4+3+3+3+4+4+4+3+4)**, each module ~13s. The 10:45 worker's wiring loop DIED mid-run when VM restart #10 hit ~11:12 (stopped at test_turret_live_loop); main thread re-ran the full set.

Neighbours final: targeted **4/4 OK**; family **164/164 OK**; new module **4/4 OK**; wiring **32/32 OK**. Total **204/204 OK**. No regression from N2187.

## Gate

Full gate attempt 1 **launched from the MAIN THREAD ~11:17 +07**: `cd tools/mindustry_godot_transpiler && python3 -c "import javalang" && setsid nohup python3 -m unittest discover -s tests > full-suite-n2187-gate.log 2>&1 < /dev/null &` — **PID 2525, SID 2525 (own session), PPID 2522 (background subshell), CPU ~93%, log growing**. Single gate only. No Godot on PATH. No proof scene ran while the gate ran (port-7777 rule).

Finished ~11:33 +07 (log mtime 04:33 UTC): **Ran 5845 tests in 966.109s, FAILED (failures=138, skipped=5)** — no errors field, 0 `ERROR:` lines. All 138 verified Godot-absent (grep on the log): **138 × `AssertionError: unexpectedly None`** (the N2175 lesson — count by the error message, not the exact-no-message-arg awk), including the new N2187 proof test (`test_reference_graph_and_actual_c07_impact_reactor_consume`, `assertIsNotNone(godot)` — expected, no Godot on PATH in the gate), 0 port-7777 bind errors. The gate is clean except Godot — exactly as expected (137 inherited + 1 new). No VM restart during the gate (restart #10 was ~11:12, before launch; javalang 0.13.0 intact). Gate at normal speed (966.1s, same as N2186's 976.6s).

## Commits

- Slice: `b6ead74` — C07: N2187 ImpactReactor consume live read (blast-compound timer burn + cryofluid drain; pure function + driver stamping; proof 4 keys), 11 files.
- Docs: `1989387` — Docs: N2187 report + design spec + handoff (gate clean except Godot).
- GOAL: `0172685` — Docs: GOAL.md names the N2187 slice commit that carries its proof to Windows.
- Pushed 2026-11-15 ~11:4x +07 to the fork (Lasthope1508). See the handoff Commits section for the hashes.

## Deferred (NOT this slice)

- impactPower event (`Events.fire(Trigger.impactPower)`, ImpactReactor.java:87-88) — own event slice (N2186 deferred).
- `read`/`write` persistence of `warmup` / `productionEfficiency` / `generateTime` — own slice (N2186 deferred).
- Net power bar display (`ImpactReactor.java:50`) — display slice (N2186 deferred).
- Other generators' producer/consume sides (thermal, solar, etc.) — each its own slice; N2187 is impact-reactor only.
- Windows Godot proof — debt in GOAL.md §5, same as N2182–N2186.
