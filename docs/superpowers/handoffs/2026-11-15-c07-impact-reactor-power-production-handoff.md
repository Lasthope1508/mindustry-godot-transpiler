# N2186 handoff: C07 ImpactReactor powerProduction live read (producer side)

Date: 2026-11-15. Batch: N2186 (single slice). Status: **DONE + PUSHED (gate clean except Godot; slice ec17915, docs 931c49b, GOAL 8a126c1).**

## Status

- **N2185 LightBlock DONE + PUSHED** (origin/main `de9ab89`). C07 power.status is COMPLETE for every catalog consumePower def with a driver.
- **Next slice: N2186** — ImpactReactor producer side, deferred explicitly by N2182 (handoff §"Documented limits" (4): "No producer-side modeling -- getPowerProduction / productionEfficiency (PowerGenerator.java:156-158) wait for their own slice").
- Scoping drafted by the 09:00 cron run; RED done by the 09:15 run; GREEN done by the 09:30 run; neighbours 204/204 done ~09:48; gate attempt 1 DONE ~10:04 (Ran 5841, failures=137, all Godot-absent). Push next in the full 5-commit pattern — same as N2182–N2185.

## Scope (verified against upstream Java this run)

- **Impact-reactor ONLY** — single def, `impact-reactor`, `powerProduction = 130f` (Blocks.java:2636), `itemDuration = 140f` (Blocks.java:2637, overrides the class default 60f), `consumePower(25f)` (Blocks.java:2642). No family split, no second def.
- **What N2182 already did (NOT to redo):** consumer-side fold — `return build.power.status;` (ConsumePower.java:39) via `SourceImpactReactorBuildState.source_impact_reactor_power_status_row_state`, frame key `"source_impact_reactor_building"`, driver `source_impact_reactor_tick_buildings_state` in `simulate_factory`. Frame keys so far: `block_implementation`, `team_id`, `rules_state`, `cheating`, `enabled` — **no `warmup` / `production_efficiency` / `total_progress` / `power_production` keys yet** (verified in `SourceImpactReactorBuildState.gd` this run: grep for `frame["warmup"]` / `frame["power_production"]` / `source_lerp_delta` all 0).
- **What N2186 adds (producer side):**
  1. Warmup advance in `updateTile` (ImpactReactor.java:79–100): hard gate `efficiency >= 0.9999f && power.status >= 0.99f` → `warmup = Mathf.lerpDelta(warmup, 1f, warmupSpeed * timeScale)` (`warmupSpeed = 0.001f`, ImpactReactor.java:19), snap `warmup = 1f` when `Mathf.equal(warmup, 1f, 0.001f)`; else `warmup = Mathf.lerpDelta(warmup, 0f, 0.01f)`. Then `totalProgress += warmup * Time.delta;` and `productionEfficiency = Mathf.pow(warmup, 5f);`.
  2. Live `getPowerProduction()` (PowerGenerator.java:156–158): `return enabled ? powerProduction * productionEfficiency : 0f;` — 130f at full warmup, 0f when disabled or cold.
  3. One pure function `SourceImpactReactorBuildState.source_impact_reactor_power_production_state(frame, delta) -> Dictionary` returning `{"warmup", "production_efficiency", "total_progress", "power_production"}`, stamped onto the frame by the EXISTING driver after the consumption fold. Frame keys are snake_case, the port's frame-key convention (`power_status`, `efficiency`) — this CORRECTS the scoping draft's camelCase (`productionEfficiency`, `totalProgress`).
  4. Proof scene `C07ImpactReactorPowerProductionProof.gd/.tscn` (mirror the N2182 proof, 6 keys): warmup rises under full power, cools without power, production_efficiency = pow(warmup, 5), power_production = 130 * production_efficiency, 0 when disabled, 0 when cold. The proof calls the pure function with synthetic frames (no long live tick: warmupSpeed 0.001f approaches 1f exponentially). The draft's net-bar key is DROPPED — the net bar (`Math.max(getPowerProduction - consPower.usage, 0)`, ImpactReactor.java:50) is display and waits for its own slice; replaced by the warmup-cools key (the else branch).

## Exact exprs (60, verified verbatim from upstream this run)

See `register_c07_impact_reactor_power_production.py` EXACT_EXPRS (60 entries). Core (all re-verified against ImpactReactor.java / PowerGenerator.java / Blocks.java this run):

- `if(efficiency >= 0.9999f && power.status >= 0.99f){` (ImpactReactor.java:79)
- `boolean prevOut = consPower != null && getPowerProduction() <= consPower.requestedPower(this);` (ImpactReactor.java:80)
- `warmup = Mathf.lerpDelta(warmup, 1f, warmupSpeed * timeScale);` (ImpactReactor.java:82)
- `if(Mathf.equal(warmup, 1f, 0.001f)){` (ImpactReactor.java:83)
- `warmup = 1f;` (ImpactReactor.java:84)
- `if(!prevOut && consPower != null && (getPowerProduction() > consPower.requestedPower(this))){` (ImpactReactor.java:87)
- `Events.fire(Trigger.impactPower);` (ImpactReactor.java:88)
- `if(timer(timerUse, itemDuration / timeScale)){` (ImpactReactor.java:91)
- `consume();` (ImpactReactor.java:92)
- `warmup = Mathf.lerpDelta(warmup, 0f, 0.01f);` (ImpactReactor.java:95)
- `totalProgress += warmup * Time.delta;` (ImpactReactor.java:98)
- `productionEfficiency = Mathf.pow(warmup, 5f);` (ImpactReactor.java:100)
- `public float warmup, totalProgress;` (ImpactReactor.java:75)
- `public float warmupSpeed = 0.001f;` (ImpactReactor.java:19)
- `powerProduction = 130f;` (Blocks.java:2636)
- `public float getPowerProduction(){` (PowerGenerator.java:156)
- `return enabled ? powerProduction * productionEfficiency : 0f;` (PowerGenerator.java:157)
- `public float productionEfficiency = 0.0f;` (PowerGenerator.java:96)
- `return enabled ? productionEfficiency : 0f;` (PowerGenerator.java:105, `warmup()` in GeneratorBuild)
- `write.f(productionEfficiency);` / `productionEfficiency = read.f();` (PowerGenerator.java:166/172 — persistence; deferred to read/write slice)

## RED decisions (the 5 open scoping questions — RESOLVED at RED, recorded in test + register)

1. **Consume timer:** the warmup advance does NOT consume. The `timer(timerUse, itemDuration / timeScale)` → `consume()` call (ImpactReactor.java:91–92) burns blast-compound + cryofluid — both wait for their own item/liquid slices. The advance is modeled with `productionValid` default true (N2182 precedent); the consume call is a deferred expr.
2. **impactPower event:** DEFERRED to its own event slice (`Events.fire(Trigger.impactPower)`, ImpactReactor.java:87–88). The N2186 proof carries no impactPower key.
3. **Driver placement:** SAME driver `source_impact_reactor_tick_buildings_state` (it already ticks placed reactors) — new frame keys, no new driver function.
4. **Gate inputs:** the driver reads the FOLDED efficiency already on the frame (`frame["efficiency"]`, set by `update_consumption_state` earlier in the same tick) and the live `power.status` (`frame["power_status"]`, stamped by the N2142 graph update), not a fresh fold.
5. **LerpDelta semantics:** the port already has the frame-rate independent delta-scaled helper — `SourceMathState.source_lerp_delta(from_value, to_value, progress, source_delta)` (`lerpf(from, to, clampf(delta * progress, 0, 1))`, the SourceBlockProducerBuildUpdateState precedent). GREEN uses it; nothing invented. The test asserts `source_lerp_delta` + `SourceMathState.gd` (preload) in the family file.

## RED (DONE 2026-11-15 ~09:1x +07)

- Test module `tools/mindustry_godot_transpiler/tests/test_c07_impact_reactor_power_production.py` (23,547 bytes) + register script `tools/mindustry_godot_transpiler/register_c07_impact_reactor_power_production.py` (76,456 bytes; generated by `/tmp/gen_n2186_register.py`, which carries N2185's DEFERRED list verbatim — 242 entries — and appends 7 N2186 entries, total 249).
- Register script verified standalone: **exit 0**. SSOT after the register run — **symbols 11384 / slices 1637 / contracts 1558 / schemas 2907** (from 11380/1636/1557/2905: +4 symbols — the 4 result symbols — +1 slice, +1 contract, +2 schemas), power_slices 111→112, power_api_contracts 90→91, audit `totalSourceFunctions` 1335 (unchanged). N2186 row: owner `SourceImpactReactorBuildState.source_impact_reactor_power_production_state`, 60 exact exprs, 249 deferred exprs. `git diff --check` clean.
- Targeted run (Godot 4.6.2 on PATH via `export PATH="$HOME/workspace/godot-bin:$PATH"` — the binary is NOT on PATH by default in a fresh shell; note for later runs): **Ran 4 tests in 1.052s, FAILED (failures=2)** — the expected RED reasons: FAIL `test_impact_reactor_power_production_state` — missing `source_impact_reactor_power_production_state` function (the .gd file has all the Java exprs as comments already, from N2182); FAIL `test_reference_graph_and_actual_c07_impact_reactor_power_production` — Godot `Cannot open file 'res://tools/runtime_proofs/C07ImpactReactorPowerProductionProof.tscn'` (proof scene not yet written). Registration + exact-evidence tests already pass (register ran at RED, same as N2185).
- Port 7777 FREE. No VM restart since #8 (~07:31 +07; uptime 1:44 at 09:15). javalang 0.13.0 intact. Worktree: only the two new files untracked + 6 SSOT JSONs modified by the register run (+ the pre-existing untracked `*.gd.uid` noise and old `full-suite-*.log` files, never stage).

## GREEN (DONE 2026-11-15 ~09:3x–09:4x +07, 09:30 worker)

- `SourceImpactReactorBuildState.gd` extended (same file as N2182, +29 lines): `const source_math_state := preload("res://src/game/SourceMathState.gd")` + pure `source_impact_reactor_power_production_state(frame, delta) -> Dictionary` — reads folded efficiency + live power.status + enabled + warmup + total_progress from the frame; gate `efficiency >= 0.9999 && power_status >= 0.99` → lerpDelta warmup toward 1 (warmupSpeed 0.001, snap within 0.001), else lerpDelta toward 0 (0.01); `total_progress += warmup * delta`; `production_efficiency = pow(warmup, 5)`; `power_production = enabled ? 130.0 * production_efficiency : 0.0`; returns the 4-key dict. In `source_impact_reactor_tick_buildings_state`, after `apply_update_consumption_state`, the driver calls the pure function and stamps `frame["warmup"]`, `frame["production_efficiency"]`, `frame["total_progress"]`, `frame["power_production"]` (4 stamps, no new driver).
- Proof scene `godot-mindustry/tools/runtime_proofs/C07ImpactReactorPowerProductionProof.gd/.tscn` (6 keys, mirror the N2182 proof): warmup_rises_under_full_power, warmup_cools_without_power, production_efficiency_is_pow_warmup_5, power_production_is_130_times_production_efficiency, power_production_zero_when_disabled, power_production_zero_when_cold. Calls the pure function with synthetic frames (no long live tick: warmupSpeed 0.001f approaches 1f exponentially).
- SSOT re-verified at GREEN: **11384/1637/1558/2907**, power_slices 112, power_api_contracts 91, audit 1335 — exactly as expected. `git diff --check` clean.
- Targeted run (main-thread re-run at completion, Godot 4.6.2 on PATH, port 7777 FREE): **Ran 4, OK in 16.188s** — registration, exact-evidence (60/60), production-state, Godot proof (6 keys, matches:true, no ERROR). Proof JSON: 9 keys all true (`matches`, `one_headquarter_per_ssot`, `registry_valid` + 6 domain keys).
- Proof N2186 not yet run on Windows Godot (debt in GOAL.md §5, same as N2182–N2185).

## Deferred (NOT N2186)

- Item/liquid consumption (blast-compound 1, cryofluid 0.25f, consume timer) — own slices.
- impactPower event — own event slice.
- `read`/`write` persistence of `warmup` / `productionEfficiency` / `generateTime` — own slice.
- Net power bar display (`ImpactReactor.java:50`) — display slice.
- `GeneratorBuild.warmup()` accessor / `ambientVolume()` / `generateTime` — own slices if a later Java line needs them.
- Other generators' producer sides (thermal, solar, etc.) — each its own slice; N2186 is impact-reactor only.
- Windows Godot proof — debt in GOAL.md §5, same as N2182–N2185.

## Environment checks (09:15 run)

- Port 7777 FREE. javalang 0.13.0 intact. No VM restart since #8 (~07:31 +07; uptime 1:44). Godot 4.6.2 binary at `~/workspace/godot-bin/godot` — NOT on PATH by default; targeted runs need `export PATH="$HOME/workspace/godot-bin:$PATH"`. Worktree clean except untracked `*.gd.uid` (never stage) + old `full-suite-*.log` files. origin/main `de9ab89`.


## Commits

- Slice: `ec17915` — C07: N2186 ImpactReactor powerProduction live read (impact-reactor producer side; pure function + driver stamping; proof 6 keys), 11 files.
- Docs: `931c49b` — Docs: N2186 report + design spec + handoff (gate clean except Godot).
- GOAL: `8a126c1` — Docs: GOAL.md names the N2186 slice commit that carries its proof to Windows.
- Status: (this commit) — Docs: N2186 handoff Commits records DONE + PUSHED (slice ec17915, docs 931c49b, GOAL 8a126c1).

## Neighbours (DONE 2026-11-15 ~09:4x +07, log `n2186-neighbours.log`)

- **Family run (09:30 worker, main-thread verified from the log): Ran 164 tests in 536.375s, OK, FAMILY EXIT 0, ZERO flakes.** The `test_c07_*_power_status.py` pattern does NOT include the new production module (its name ends `_power_production`, not `_power_status`) — so the family count stays 164 and the new module was run separately.
- **New module (09:30 worker): Ran 4 tests in 12.973s, OK, NEWMOD_EXIT=0.**
- **Wiring-standard set (9 modules / 32 tests, main thread ~09:48):** ALL OK (4+3+3+3+4+4+4+3+4), each module ~13–15s. The 09:30 worker's wiring loop DIED mid-factory_live_loop when its session timed out (N2180 lesson again — worker-launched runs die with their session); main thread re-ran the full set.
- Neighbours final: targeted **4/4** + family **164/164** + new module **4/4** + wiring **32/32** = **204/204 OK**.
- **VM restart #9 ~09:31 +07** (uptime 14 min at the 09:45 check): javalang wiped, reinstalled 0.13.0 by the 09:30 worker before GREEN. No work lost (GREEN files + SSOT survived in ~/workspace).

## Gate (DONE 2026-11-15 ~10:04 +07, log `full-suite-n2186-gate.log`)

- Full gate attempt 1 **launched from the MAIN THREAD ~09:48 +07**: `cd tools/mindustry_godot_transpiler && python3 -c "import javalang" && setsid nohup python3 -m unittest discover -s tests > full-suite-n2186-gate.log 2>&1 < /dev/null &` — **PID 3675, SID 3675 (own session), PPID 3672 (background subshell)**. Single gate only. No Godot on PATH. No proof scene ran while the gate ran (port-7777 rule).
- Finished ~10:04 +07 (log mtime 03:04:53 UTC): **Ran 5841 tests in 976.583s, FAILED (failures=137, skipped=5)** — no errors field, 0 `ERROR:` lines. All 137 verified Godot-absent (grep on the log): **137 × `AssertionError: unexpectedly None`** (the N2175 lesson — count by the error message, not the exact-no-message-arg awk), including the new N2186 proof test (`test_reference_graph_and_actual_c07_impact_reactor_power_production`, log line 299, `assertIsNotNone(godot)` — expected, no Godot on PATH in the gate), 0 port-7777 bind errors. The gate is clean except Godot — exactly as expected (136 inherited + 1 new). No VM restart during the gate (restart #9 was ~09:31, before launch; uptime 29 min at 10:00, javalang 0.13.0 intact). Gate at normal speed (976.6s, same as N2185's 985.6s).
