# N2187 handoff: C07 ImpactReactor consume — blast-compound timer burn + cryofluid continuous drain

Date: 2026-11-15. Batch: N2187 (single slice). Status: **DONE + PUSHED (gate clean except Godot; slice 02e812d, docs 19d3078, GOAL 840d7eb).**

## Status

- **N2186 ImpactReactor powerProduction DONE + PUSHED** (origin/main `0ebab3e`; slice ec17915, docs 931c49b, GOAL 8a126c1, handoff-status 2ca9de3, report-hash 0ebab3e). Gate Ran 5841, failures=137, all Godot-absent. C07 power.status complete for every catalog consumePower def with a driver; ImpactReactor producer side done too.
- **Next slice: N2187** — ImpactReactor consume, deferred explicitly by N2186 (handoff §"Deferred": "Item/liquid consumption (blast-compound 1, cryofluid 0.25f, consume timer) — own slices"). Direct continuation of the reactor work: N2182 folded the power row, N2186 modeled warmup + production; N2187 burns the fuel that keeps it warm.
- No code written this run — scoping only. Worktree clean except pre-existing untracked `*.gd.uid` noise (never stage). SSOT on disk unchanged: **11384/1637/1558/2907**, audit 1335.

## Scope (verified against upstream Java this run)

- **Impact-reactor ONLY** — single def, `impact-reactor`, Blocks.java:2632-2645: `consumePower(25f)` (2642, folded by N2182), `consumeItem(Items.blastCompound)` (2643), `consumeLiquid(Liquids.cryofluid, 0.25f)` (2644), `itemDuration = 140f` (2637), `liquidCapacity = 80f` (2640). No family split, no second def.
- **Two coupled but distinct mechanisms — do not conflate them:**
  1. **Timer burn (item side).** `ImpactReactorBuild.updateTile()` (ImpactReactor.java:91-92), INSIDE the warmup hard gate (`efficiency >= 0.9999f && power.status >= 0.99f`, ImpactReactor.java:79): `if(timer(timerUse, itemDuration / timeScale)){ consume(); }`. `Building.consume()` (BuildingComp.java:1911-1915) iterates `block.consumers` and calls `cons.trigger(self())` on each. `Consume.trigger()` default is a no-op (Consume.java:50), so only `ConsumeItems.trigger` fires: `build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)))` (ConsumeItems.java:44-48). `consumeItem(item)` defaults to amount 1 (Block.java:1167-1168, `consumeItem(item, 1)` → `ItemStack(item, 1)`), multiplier default 1f (Consume.java:18) → **−1 blast-compound per timer fire**. `timerUse` is `public final int timerUse = timers++;` (ImpactReactor.java:18) — a per-building `Interval(6)` slot (TimerComp.java:10-13).
  2. **Continuous drain (liquid side).** `ConsumeLiquid` has NO trigger override — the cryofluid is NOT burned by the timer fire. Its drain is `update()`: `build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build))` (ConsumeLiquid.java:37-39), i.e. **0.25f × edelta × 1f per tick**, run by `updateConsumption()`'s second pass (BuildingComp.java:1996-2000: `if(update && efficiency > 0){ for(var cons : block.updateConsumers){ cons.update(self()); } }`). `Consume.update = true` by default (Consume.java:16), so ConsumeLiquid is in `updateConsumers` (Block.java:1448). `edelta() = efficiency * delta()` (BuildingComp.java:1927-1929), `delta() = Time.delta * timeScale` (BuildingComp.java:1922-1924). This drain is **NOT gated on the warmup hard gate** — it runs whenever `shouldConsume() && productionValid()` and folded efficiency > 0. (ImpactReactor has no shouldConsume override → default `return enabled;`.)
- **What N2182/N2186 already did (NOT to redo):** power fold, warmup advance + snap, totalProgress, productionEfficiency = pow(warmup, 5), getPowerProduction = enabled ? 130 * productionEfficiency : 0, driver `source_impact_reactor_tick_buildings_state(game, seconds)` stamping `warmup` / `production_efficiency` / `total_progress` / `power_production` on the frame.
- **What N2187 adds:** one pure function (e.g. `source_impact_reactor_consume_state(frame, delta)` in `SourceImpactReactorBuildState.gd`, same file as N2182/N2186) returning the burn/drain result, stamped onto the frame by the EXISTING driver; proof scene `C07ImpactReactorConsumeProof.gd/.tscn` (mirror the N2186 proof): blast-compound −1 per 140s at full gate, no burn outside the gate, cryofluid drains 0.25f × edelta per tick while efficiency > 0, no drain when disabled / efficiency 0.

## Exact exprs (core, verified verbatim from upstream this run)

- `if(timer(timerUse, itemDuration / timeScale)){` (ImpactReactor.java:91)
- `consume();` (ImpactReactor.java:92)
- `public final int timerUse = timers++;` (ImpactReactor.java:18)
- `public boolean timer(int index, float time){` (TimerComp.java:10)
- `if(Float.isInfinite(time)) return false;` (TimerComp.java:11)
- `return timer.get(index, time);` (TimerComp.java:12)
- `public void consume(){` (BuildingComp.java:1911)
- `for(Consume cons : block.consumers){` (BuildingComp.java:1912)
- `cons.trigger(self());` (BuildingComp.java:1913)
- `public void trigger(Building build){}` (Consume.java:50 — default no-op)
- `build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));` (ConsumeItems.java:46)
- `public ConsumeItems consumeItem(Item item){` (Block.java:1167)
- `return consumeItem(item, 1);` (Block.java:1168)
- `consumeItem(Items.blastCompound);` (Blocks.java:2643)
- `consumeLiquid(Liquids.cryofluid, 0.25f);` (Blocks.java:2644)
- `itemDuration = 140f;` (Blocks.java:2637)
- `build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));` (ConsumeLiquid.java:38)
- `public float edelta(){` (BuildingComp.java:1927)
- `return efficiency * delta();` (BuildingComp.java:1928)
- `return Time.delta * timeScale;` (BuildingComp.java:1923, `delta()`)
- `if(update && efficiency > 0){` (BuildingComp.java:1997, second pass gate)
- `cons.update(self());` (BuildingComp.java:1999)
- `public boolean update = true;` (Consume.java:16)
- `public Floatf<Building> multiplier = b -> 1f;` (Consume.java:18)

## Timer semantics — read this before RED (Interval is absolute-time, not an accumulator)

- `arc.util.Interval.get(id, time)` (arc-upstream/arc-core/src/arc/util/Interval.java): `got = check(id, time)` where `check` is `Time.time - times[id] >= time || Time.time < times[id]`; if got, `times[id] = Time.time` (stamp reset to absolute game time — overshoot is DROPPED, not carried). So the burn fires when absolute `Time.time − lastFire ≥ itemDuration / timeScale` (140s / timeScale at timeScale 1).
- Port modeling decision (OPEN — decide at RED, record in test + register): the driver receives `seconds` (delta), not absolute `Time.time`. A per-frame accumulator `consume_timer += seconds; if consume_timer >= 140 / timeScale: fire, consume_timer = 0` drops overshoot exactly like `Interval.get` and is faithful except for the `Time.time < times[id]` wrap case (global time reset — negligible, document it). Do NOT model it as subtract-the-interval (that would carry overshoot and drift the burn cadence vs Java).
- Frame keys: `frame["items"]` dict precedent exists (SourceUnitFactoryBuildState.gd:1403-1404, item module on the frame); liquids precedent exists (`SourceLiquidModuleState.gd:11` `{"liquids": ..., "current": ...}`, `SourcePlacedBlockState.gd:35` `"liquids": existing_liquids`). Whether the reactor driver frame already carries them — VERIFY at RED; if absent, the slice stamps/reads them the same way N2186 stamped the 4 production keys. Key names snake_case per port convention.
- `timeScale` on the frame: the timer interval is `itemDuration / timeScale` — verify which frame key carries timeScale at RED (the N2186 driver reads folded efficiency + power.status from the frame; timeScale must come from the same place or the rules state).

## RED questions (resolve at RED, record in test + register)

1. Timer stamp representation (accumulator reset-to-0 vs absolute-time key) — see above.
2. Frame `items` / `liquids` keys present on the reactor frame already? If not, stamp them in the driver (N2186 precedent).
3. Proof keys: burn −1 per 140s inside gate / no burn outside gate / cryofluid 0.25f × edelta per tick while efficiency > 0 / no drain when disabled. Synthetic frames + pure function, mirror N2186 (no long live tick: drive the pure function with a pre-advanced timer stamp).
4. `consumeTriggerValid()` interplay: `ConsumeItems.efficiency` is `build.consumeTriggerValid() || build.items.has(items, multiplier)` (ConsumeItems.java:51-53) — the folded efficiency already accounts for item presence via N2182's fold, so the burn assumes the gate held; record this as the RED decision (N2182 precedent: advance modeled with `productionValid` default true).

## Deferred (NOT N2187)

- impactPower event (`Events.fire(Trigger.impactPower)`, ImpactReactor.java:87-88) — own event slice (N2186 deferred).
- `read`/`write` persistence of `warmup` / `productionEfficiency` / `generateTime` — own slice (N2186 deferred).
- Net power bar display (`ImpactReactor.java:50`) — display slice (N2186 deferred).
- Other generators' producer/consume sides (thermal, solar, etc.) — each its own slice; N2187 is impact-reactor only.
- Windows Godot proof — debt in GOAL.md §5, same as N2182–N2186.

## RED (run 10:30, this run)

- **Status: RED confirmed.** Targeted run `cd tools/mindustry_godot_transpiler && PATH="$HOME/workspace/godot-bin:$PATH" python3 -m unittest tests.test_c07_impact_reactor_consume -v` → **Ran 4, FAILED (failures=2, errors=2), 0 passes, in 1.191s.** Log: `tools/mindustry_godot_transpiler/n2187-red.log`. Port 7777 FREE before the run (no collision with the other agent's Godot). javalang 0.13.0 intact, no VM restart since #9 (uptime 1:07 at 10:31).
- **Failure breakdown (all expected, all RED-true):**
  - `test_c07_impact_reactor_consume_registration` — ERROR, `KeyError: 'N2187'` (ledger has no N2187 row; the register script is written but NOT run at RED, per the slice flow).
  - `test_all_c07_impact_reactor_consume_input_evidence_is_exact` — ERROR, same `KeyError: 'N2187'`.
  - `test_impact_reactor_consume_state` — FAIL, `AssertionError: 'static func source_impact_reactor_consume_state(frame: Dictionary, delta: float) -> Dictionary:' not found` (the function does not exist yet in `SourceImpactReactorBuildState.gd`).
  - `test_reference_graph_and_actual_c07_impact_reactor_consume` — FAIL, Godot exit 1: `Cannot open file 'res://tools/runtime_proofs/C07ImpactReactorConsumeProof.tscn'` (proof scene not created yet).
  - No test passed unexpectedly; nothing was adjusted to force a pass.
- **Files created this run (untracked, NOT staged, NOT committed):**
  - `tools/mindustry_godot_transpiler/tests/test_c07_impact_reactor_consume.py` (4 tests, mirror of N2186).
  - `tools/mindustry_godot_transpiler/register_c07_impact_reactor_consume.py` (imports clean: DEFERRED 253 = N2186's 249 verbatim + 4 N2187 appends; EXACT_EXPRS 42; OWNER `SourceImpactReactorBuildState.source_impact_reactor_consume_state`; PROOF `/root/C07ImpactReactorConsumeProof`).
  - `tools/mindustry_godot_transpiler/n2187-red.log` (the RED run log).
- **4 RED decisions (recorded in the test module + register docstring):**
  1. **Timer stamp — accumulator reset-to-0.** `consume_timer += delta; if consume_timer >= 140 / time_scale: fire, consume_timer = 0` — overshoot dropped exactly like `Interval.get` stamping `Time.time` (`if(got) times[id] = Time.time;`); do NOT subtract the interval. The global-time wrap case (`Time.time < times[id]`) is not modeled, documented as negligible. Zero time_scale → interval infinite → `timer()` returns false (TimerComp.java:11), so the timer never fires.
  2. **Frame keys — NOT present yet, GREEN stamps them.** Verified at RED: the reactor driver stamps only block_implementation / team_id / rules_state / cheating / enabled / efficiency / efficiency_scale / power_status / warmup / production_efficiency / total_progress / power_production. GREEN stamps `items` (dict, `frame["items"]` precedent in SourceUnitFactoryBuildState.gd), `liquids` (dict, SourcePlacedBlockState.gd `{"liquids": ...}` precedent), `time_scale` (float, default 1.0, `source_placed_block_state.time_scale` precedent) and `consume_timer` (float, default 0.0) in the EXISTING driver (N2186 precedent); the driver stamps all five result keys onto the frame. Content slugs are `blast-compound` / `cryofluid` (content_registry_blocks.json).
  3. **Proof keys (4):** `burn_minus_one_per_140s_inside_gate`, `no_burn_outside_gate`, `cryofluid_drains_per_tick_while_efficiency_positive`, `no_drain_when_disabled_or_efficiency_zero`. Synthetic frames + pure function with a pre-advanced timer stamp (consume_timer = 139.9 + delta 0.2 fires once, −1 blast-compound, timer back to 0); no long live tick.
  4. **consumeTriggerValid interplay.** Default false (BuildingComp.java:764-766), so `ConsumeItems.efficiency` is 1 iff the building has the blast-compound (ConsumeItems.java:52) — the burn assumes the hard gate held (folded efficiency ≥ 0.9999 already implies the item was present); the pure function burns unconditionally on timer fire inside the gate (matching `ConsumeItems.trigger`); folding the item row into the driver's min efficiency waits for its own slice. The drain is NOT gated on the warmup hard gate — it runs whenever `shouldConsume() && productionValid()` and folded efficiency > 0 (BuildingComp.java:1960, 1997-2000). Both removes clamp at stock on hand (`ItemModule.remove`: `amount = Math.min(amount, items[item.id]);`; `LiquidModule.remove`: `//cap to prevent negative removal`), so neither dict ever goes negative. Drain formula pinned: 0.25 × efficiency × delta × time_scale per tick (edelta = efficiency × Time.delta × timeScale; the port's delta is Time.delta, the N2186 precedent).
- **GREEN next:** implement `source_impact_reactor_consume_state(frame, delta)` in `SourceImpactReactorBuildState.gd` (same file as N2182/N2186) + driver stamping of `items` / `liquids` / `time_scale` / `consume_timer` + all five result keys + proof scene `C07ImpactReactorConsumeProof.gd/.tscn` (mirror N2186 proof, 4 keys above); then run the register script, targeted tests, neighbours + wiring, full gate (main thread), Godot proof headless here. Do NOT commit/push until tests + proof + gate are green.

## Environment checks (10:15 run)

- Port 7777 FREE. javalang 0.13.0 intact. No VM restart since #9 (~09:31 +07; uptime 45 min at 10:15). Godot 4.6.2 binary at `~/workspace/godot-bin/godot` — NOT on PATH by default; targeted runs need `export PATH="$HOME/workspace/godot-bin:$PATH"`. Worktree clean except untracked `*.gd.uid` (never stage). origin/main `0ebab3e` (N2186).

## GREEN (run 10:47, this run)

- **Status: GREEN confirmed.** Targeted run `cd tools/mindustry_godot_transpiler && PATH="$HOME/workspace/godot-bin:$PATH" python3 -m unittest tests.test_c07_impact_reactor_consume -v` → **Ran 4 tests in 15.069s, OK (0 failures, 0 errors).** Log: `tools/mindustry_godot_transpiler/n2187-green.log` (0 `ERROR:` lines). Port 7777 FREE before the run (no collision with the other agent's Godot). javalang 0.13.0 intact, no VM restart since #9 (uptime 1:19 at 10:49).
- **Proof GREEN (Godot 4.6.2 headless, via the targeted test's reference-graph run).** Proof JSON `godot-mindustry/tools/runtime_proofs/C07ImpactReactorConsumeProof.json`: `{"burn_minus_one_per_140s_inside_gate":true,"cryofluid_drains_per_tick_while_efficiency_positive":true,"matches":true,"no_burn_outside_gate":true,"no_drain_when_disabled_or_efficiency_zero":true,"one_headquarter_per_ssot":true,"registry_valid":true}` — **7/7 keys true, matches:true**. (The proof's stdout line is captured by the unittest subprocess and only surfaces on failure, so the proof JSON on disk is the evidence.) The proof JSON is gitignored on disk — the N2186 proof JSON is tracked, so the main thread decides at commit whether to `git add -f` it.
- **What GREEN implemented (all 4 RED decisions as recorded):** pure function `source_impact_reactor_consume_state(frame, delta)` in `SourceImpactReactorBuildState.gd` (same file as N2182/N2186): timer accumulator reset-to-0 on fire (overshoot dropped, `Interval.get` semantics; zero time_scale → infinite interval → never fires); burn −1 blast-compound per fire inside the warmup hard gate only; cryofluid drain 0.25 × efficiency × delta × time_scale whenever enabled and efficiency > 0 (NOT gated on the warmup hard gate); both removes clamp at the stock on hand, neither dict ever goes negative. The EXISTING driver stamps `items` / `liquids` / `time_scale` / `consume_timer` before the call and all five result keys (`blast_compound_burned` / `cryofluid_drained` / `consume_timer` / `items` / `liquids`) after it. No gameplay touched — pure function + driver stamping only.
- **Files changed / created this run (NOT staged, NOT committed — commit/push is the main thread's step after the gate):**
  - Modified: `godot-mindustry/src/game/SourceImpactReactorBuildState.gd` (+50 lines, `git diff --check` clean).
  - Created: `godot-mindustry/tools/runtime_proofs/C07ImpactReactorConsumeProof.gd` + `.tscn` (mirror of the N2186 proof, 4 keys).
  - Register script run (`python3 register_c07_impact_reactor_consume.py`, exit OK): SSOT `11384/1637/1558/2907` → **11389/1638/1559/2909** (symbols +5, ledger done +1, contracts +1, schemas +2); power shard `power_slices` 112→113, `power_api_contracts` 91→92; `source_symbol_audit_report.json` rewritten identically (no diff). N2187 ledger row status `done`, owner `SourceImpactReactorBuildState.source_impact_reactor_consume_state`, runtime proof `/root/C07ImpactReactorConsumeProof`.
  - Logs: `tools/mindustry_godot_transpiler/n2187-green.log` (targeted run) + proof JSON above.
- **NOT done this run (per task):** no neighbours/wiring run, no full gate (main thread), no commit, no push.
- **GREEN next (main thread):** neighbours + wiring, full gate, then commit + push per the slice flow; Windows Godot proof stays debt in GOAL.md §5.


## Neighbours (DONE 2026-11-15 ~11:1x +07, logs `n2187-neighbours.log` + `n2187-family-rerun.log` + `n2187-wiring.log`)

- **Family run (10:45 worker, main-thread verified from the logs): Ran 164 tests in 561.687s, FAILED (failures=5) on the first pass** — all 5 are `test_reference_graph_and_actual_*` proof tests (accelerator, adjacent-factory, base-shield, beam-drill, build-turret), the classic port-7777 flake signature (proof itself matches:true, only the no-ERROR assert trips). **Isolated re-run of all 5 modules: each 4/4 OK** → family **164/164**.
- **New module (10:45 worker, verified): Ran 4, OK.**
- **Wiring-standard set (9 modules / 32 tests, main thread ~11:17):** ALL OK (4+3+3+3+4+4+4+3+4), each module ~13s. The 10:45 worker's wiring loop DIED mid-run (stopped at test_turret_live_loop) when **VM restart #10** hit ~11:12; main thread re-ran the full set after javalang was reinstalled.
- Neighbours final: targeted **4/4** + family **164/164** + new module **4/4** + wiring **32/32** = **204/204 OK**.
- **VM restart #10 ~11:12 +07** (04:12 UTC; uptime 3 min at the 11:15 check): javalang wiped, reinstalled 0.13.0 by the 11:00 worker. No work lost (GREEN files + SSOT survived in ~/workspace).

## Gate (GREEN — attempt 1, verified by main thread ~11:37 +07)

- Full gate attempt 1 (main thread, PID 2525, launched ~11:17): **Ran 5845 tests in 966.109s, FAILED (failures=138, skipped=5)** — log `tools/mindustry_godot_transpiler/full-suite-n2187-gate.log` (94,316 bytes, footer present). Verified from the log itself: 138 × `FAIL:` lines, 0 × `ERROR:`, 138 × `AssertionError: unexpectedly None`, 0 other AssertionErrors, 0 × `ERROR` lines, 0 × `7777`, 0 × `Address already in use`. The 82 `bind` grep hits are all the word "binding" in test names (consumer_binding / placement_binding / dump_binding) — NOT port-bind errors. N2187's new `test_reference_graph_and_actual_c07_impact_reactor_consume` is among the 138 (the +1 vs N2186's 137, Godot-absent in the gate as expected — no Godot on PATH). **Gate GREEN per the slice flow: all 138 failures are Godot-absent asserts, 0 errors.**
- **N2187 is COMPLETE per process:** RED (Ran 4, failures=2, errors=2) → GREEN (targeted 4/4 OK, proof 7/7 keys matches:true) → neighbours 204/204 → gate green (138 Godot-absent, 0 errors). SSOT 11389/1638/1559/2909 (ledger rows 1638 verified from disk ~11:37; N2187 row status done).
- **NOT done this run: commit + push.** Next run (11:45): stage EXACT slice files only — 7 modified (SourceImpactReactorBuildState.gd + source_api_contracts.json + power_api_contracts.json + power_slices.json + source_slice_ledger.json + source_state_schema.json + source_symbol_registry.json) + new test_c07_impact_reactor_consume.py + register_c07_impact_reactor_consume.py + proof C07ImpactReactorConsumeProof.gd/.tscn. NEVER stage the proof .json (gitignored, and NO proof .json is tracked in the repo — verified by main thread: `git ls-files 'godot-mindustry/tools/runtime_proofs/*.json'` returns 0 files; the "N2186 precedent — its proof JSON is tracked" claim in this section was wrong), *.gd.uid, *.log files, or the old full-suite-*/n21*-*.log noise. Then the 5-commit pattern (slice / docs report+spec+handoff / GOAL / handoff-status / report-hash) + push to origin main. Verify Done/ledger 1638 + N2187 row SSOT tuple at completion (N2182 lesson). Windows Godot proof stays debt in GOAL.md §5.

## Commits

- Slice: `02e812d` — C07: N2187 ImpactReactor consume live read (blast-compound timer burn + cryofluid drain; pure function + driver stamping; proof 4 keys), 11 files.
- Docs: `19d3078` — Docs: N2187 report + design spec + handoff (gate clean except Godot).
- GOAL: `840d7eb` — Docs: GOAL.md names the N2187 slice commit that carries its proof to Windows.
- Status: (this commit) — Docs: N2187 handoff Commits records DONE + PUSHED (slice 02e812d, docs 19d3078, GOAL 840d7eb).
