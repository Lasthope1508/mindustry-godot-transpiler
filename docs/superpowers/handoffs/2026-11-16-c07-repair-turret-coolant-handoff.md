# Handoff — N2209: RepairTurret coolant heal multiplier (repair-turret) (C07)

Date: 2026-11-16. Batch: N2209 (single slice). Status: **DONE + PUSHED (slice a901d10e, main 52ffa5d4).**

## GREEN (DONE 2026-11-16 ~12:3x +07, this run)

- One pure function in `SourceRepairTurretBuildState.gd` (after `source_repair_turret_should_consume_state`, no driver tick line — the N2208 precedent): `source_repair_turret_coolant_multiplier_state(frame, accept_coolant, coolant_multiplier)` — accept_coolant=false → `{"heal_multiplier": 1.0, "coolant_active": false}`; true → `1.0 + heat_capacity * coolant_multiplier * optional_efficiency` with `coolant_active: true`; frame keys `liquids_current_heat_capacity` (absent → 0.0) and `optional_efficiency` (absent → 1.0). All 11 Java-quote assertIn strings present in the file.
- Register script run → SSOT **11434/1659/1581/2953** (symbols +1, ledger +1, contracts +1, schema +2 — exactly as predicted at RED); no source_modules shard change — no shard selection matches RepairTurret.java (N2188 precedent). Register --verify 28/28 exprs present, exit 0.
- Targeted **4/4 OK in 15.536s** (log `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2209-green.log`), including the Godot proof test. Family RepairTurret **12/12 OK in 43.263s** (N2174 power + N2188 shouldConsume + N2209 coolant; log `n2209-family.log`). Wiring-standard set **32/32 OK in 122.313s** (9 modules: factory_live_loop, power_graph_live_update_binding, battery_power_status_binding, battery_placement_binding, adjacent_factory_live_loop, unit_factory_live_loop, turret_live_loop, continuous_liquid_turret_live_loop, power_graph_consumer_cheating; log `n2209-wiring.log`). **GREEN total 48/48.**
- Godot proof `C07RepairTurretCoolantProof`: **6 semantic keys / 9 in JSON, matches:true, 0 false** (JSON `godot-mindustry/tools/runtime_proofs/C07RepairTurretCoolantProof.json` — untracked, never staged per .gitignore:6). Port 7777 was FREE at every proof run; no gate running in parallel. `git diff --check` clean.
- Next: full gate (MAIN THREAD ONLY — workers must not launch gates) → commit + push only when the gate is clean except Godot-absent. Slice files when committing: `SourceRepairTurretBuildState.gd` + 4 SSOT JSONs + proof .gd/.tscn + register script + test module + this handoff (11 files expected, N2208 pattern); never stage `*.gd.uid`, gate logs, or proof .json.

## RED (DONE 2026-11-16 ~12:2x +07, this run)

- Test module `tools/mindustry_godot_transpiler/tests/test_c07_repair_turret_coolant.py` (13,034 bytes, 4 tests, N2188 pattern) + register script `tools/mindustry_godot_transpiler/register_c07_repair_turret_coolant.py` (16,146 bytes, DEFERRED carried from N2188 via import) + proof `godot-mindustry/tools/runtime_proofs/C07RepairTurretCoolantProof.gd` (6,104 bytes) + `.tscn` (216 bytes) written.
- Register --verify: **28/28 exprs present, exit 0** (24 exact + 4 input/output exprs).
- RED run: **Ran 4 tests in 12.826s, FAILED (failures=2, errors=2) — classic RED** (log `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2209-red.log`): registration ERROR KeyError 'N2209' (register runs at GREEN); evidence ERROR KeyError 'N2209'; state FAIL missing `source_repair_turret_coolant_multiplier_state`; proof FAIL Godot parse error (function not found yet). Port 7777 was FREE at run start. SSOT baseline 11433/1658/1580/2951 (unchanged from N2208 — register not run at RED). javalang 0.13.0 confirmed present (no reinstall needed — no VM restart since N2208). Godot 4.6.2-stable Linux on PATH via ~/workspace/godot-bin. `git diff --check` clean.
- Next: full gate (main thread only) → commit + push N2209 only when the gate is clean except Godot-absent. Next after N2209: Units.nearby live query. (Do NOT start the C08 inventory unless the user asks.)

## Scope

RepairTurret coolant heal multiplier (RepairTurret.java:188-190, 207; file at `mindustry-upstream/core/src/mindustry/world/blocks/units/RepairTurret.java`):

```java
float multiplier = 1f;
if(acceptCoolant){
    multiplier = 1f + liquids.current().heatCapacity * coolantMultiplier * optionalEfficiency;
}
```

```java
target.heal(repairSpeed * strength * edelta() * multiplier);
```

One new pure function in `SourceRepairTurretBuildState.gd` (next to the N2188 shouldConsume gate, no driver tick line — the multiplier feeds the updateTile heal advance, the N2208 precedent):

- `source_repair_turret_coolant_multiplier_state(frame, accept_coolant, coolant_multiplier)` — frame keys `liquids_current_heat_capacity` (float, absent → 0.0) and `optional_efficiency` (float, absent → 1.0); accept_coolant=false returns `{"heal_multiplier": 1.0, "coolant_active": false}`; accept_coolant=true returns `{"heal_multiplier": 1.0 + heat_capacity * coolant_multiplier * optional_efficiency, "coolant_active": true}`. Per-def coolantMultiplier passed in by the caller (repair-turret 1.6f, Blocks.java:6405; class default 1f, RepairTurret.java:45), the N2207 precedent.

RED decisions (pinned in the test):
- accept_coolant=false → 1.0 (the Java `if(acceptCoolant){` guard leaves multiplier at 1f; repair-point never boosts).
- Absent `liquids_current_heat_capacity` → 0.0 → multiplier 1.0 (no current coolant liquid observed yet; the future liquid-state slice stamps it from `liquids.current().heatCapacity`; Java's `current()` can never be null in practice — `private Liquid current = content.liquid(0);`, LiquidModule.java:24 — but the port frame carries no liquid observation yet, and absent means "no observation", not "a liquid with zero heat capacity"; the observable is the same either way).
- Absent `optional_efficiency` → 1.0 (BuildingComp initializes `efficiency = optionalEfficiency = 1f` before the optional pass, BuildingComp.java:1965).
- coolantUse is NOT a parameter: it belongs to the ConsumeCoolant consumer's efficiency/update (the optional coolant row that folds optionalEfficiency from the liquid amount), which waits for its own slice; the multiplier formula never reads it.
- No driver tick line for this function; no new frame meta key, no SOURCE_CONSUMER_FRAME_META_KEYS change, no simulate_factory wiring change. The logic/heal-advance integration that calls the multiplier is its own later slice.
- Do NOT confuse this multiplier with the tractor-beam coolant rows (SourceTractorBeamTurretBuildUpdateTileCoolantState): those port TractorBeamBuild.updateTile's own consume-coolant block (`coolantMultiplier = 1f + (used * liquid.heatCapacity * coolantMultiplier);`), a different class with a different formula — RepairTurret multiplies by optionalEfficiency, TractorBeam multiplies by the used amount.

Deferred: RepairTurret updateTile heal advance (target re-acquire / heal / rotation slerp / strength lerp, RepairTurret.java:187-218); optional coolant row (liquid amount → optionalEfficiency via ConsumeCoolant/ConsumeLiquidFilter efficiency); liquid-state stamping of `liquids_current_heat_capacity`; per-def repairSpeed/repairRadius/length/beamWidth/pulseRadius verification; RepairTower (different class); spawn_occupied/allow_update frame inputs, moveOutPayload(), net drone sync. C07–C12 remain open.

## Exact exprs (24, all verified verbatim at scoping)

- `public class RepairTurret extends Block{` (RepairTurret.java:25)
- `public boolean acceptCoolant = false;` (RepairTurret.java:39)
- `public float coolantUse = 0.5f;` (RepairTurret.java:41)
- `public float coolantMultiplier = 1f;` (RepairTurret.java:45)
- `if(acceptCoolant){` (RepairTurret.java:76/84/189)
- `consume(new ConsumeCoolant(coolantUse)).optional(true, true);` (RepairTurret.java:86)
- `float multiplier = 1f;` (RepairTurret.java:188)
- `multiplier = 1f + liquids.current().heatCapacity * coolantMultiplier * optionalEfficiency;` (RepairTurret.java:190)
- `target.heal(repairSpeed * strength * edelta() * multiplier);` (RepairTurret.java:207)
- `public class RepairPointBuild extends Building implements Ranged, RotBlock{` (RepairTurret.java:153)
- `hasLiquids = true;` (RepairTurret.java:85)
- `coolantUse = 0.16f;` + `coolantMultiplier = 1.6f;` + `acceptCoolant = true;` (Blocks.java:6404-6406)
- `public class ConsumeCoolant extends ConsumeLiquidFilter{` (ConsumeCoolant.java)
- `public float maxTemp = 0.5f, maxFlammability = 0.1f;` (ConsumeCoolant.java)
- `liquid.coolant && (this.allowLiquid && !liquid.gas || this.allowGas && liquid.gas) && liquid.temperature <= maxTemp && liquid.flammability < maxFlammability;` (ConsumeCoolant.java:12)
- `return liq != null ? Math.min(build.liquids.get(liq) / (amount * ed * multiplier.get(build)), 1f) : 0f;` (ConsumeLiquidFilter.java:53)
- `optionalEfficiency = Math.min(optionalEfficiency, cons.efficiency(self()));` (BuildingComp.java:1981)
- `efficiency = optionalEfficiency = 1f;` (BuildingComp.java:1965)
- `private Liquid current = content.liquid(0);` (LiquidModule.java:24)
- `public float heatCapacity = 0.5f;` (Liquid.java:42)
- `public boolean coolant = true;` (Liquid.java:50)
- `public float repairSpeed = 0.3f;` (RepairTurret.java:32)

## Notes

- N2208 DONE + PUSHED before this run (slice 1cd99dfc, main a4562e05; origin/main == local HEAD at run start). Worktree clean except untracked `*.gd.uid` (never stage) + pre-existing untracked gate logs.
- Another agent is using Godot to test the fail errors (user, 2026-11-13 ~08:05). Port 7777 was FREE at RED. Before any proof run, re-check `ss -ltnp | grep 7777` and run proof scenes sequentially — never while a gate runs (port-7777 rule).
- Godot binary is at ~/workspace/godot-bin/godot (symlink to Godot_v4.6.2-stable_linux.x86_64) — NOT on PATH by default; targeted runs use PATH="$HOME/workspace/godot-bin:$PATH".
- N2209 proof not yet run on Windows Godot (debt in GOAL.md §5 will be added at completion, same as N2175–N2208).
- Workers must NOT launch gates; only the main thread launches, into a fresh log (N2168 collision lesson; duplicate-gate incident at N2207, PID 10001 killed by main thread).
- Next after N2209: Units.nearby live query. (Do NOT start the C08 inventory unless the user asks.)

## VM restart #22 (main thread, ~12:29 +07)

- Uptime only 11 min at the 12:29 check — VM restarted again (#22, ~12:18). The 12:15 worker's claim "javalang 0.13.0 còn nguyên" was WRONG: javalang was wiped (ModuleNotFoundError on import). Main thread reinstalled 0.13.0 at ~12:29 (pip install from repo root, verified import OK).
- No work lost: N2209 RED files on disk are intact (test/register/proof), SSOT unchanged.

## GREEN verification + gate (main thread, ~12:39 +07)

- GREEN verified by main thread: targeted re-run Ran 4 OK in 14.788s; family log Ran 12 OK (43.263s); wiring log Ran 32 OK (122.313s). GREEN total 48/48. Proof JSON 9 keys (6 semantic + matches + 2 harness), matches:true, 0 false. Register --verify 28/28 exprs present, exit 0.
- Function `source_repair_turret_coolant_multiplier_state(frame, accept_coolant, coolant_multiplier)` at :81 — NO driver tick line by design (a heal multiplier, not a tick write; N2208 precedent).
- SSOT 11433/1658/1580/2951 → **11434/1659/1581/2953** (symbols +1, ledger +1, contracts +1, schema +2; audit 1335). NO shard change (RepairTurret.java is defense/ but the shard selectors cover only the families registered so far — verify at completion; N2188/N2190/N2191 precedent: units/ + repair-turret slices changed NO shard).
- Gate (main thread, PID 3710, SID 3710, ~12:39): godot NOT on PATH, javalang OK, log fresh and growing (dots + F's only, 303 bytes at launch check). Parent subshell PID 3707 stays alive. Expected: Ran ~5929, failures ~159, skipped 5, 0 errors.
- Gate progress (12:45 cron, ~12:49): still RUNNING, PID 3710 alive, log `tools/mindustry_godot_transpiler/full-suite-n2209-gate.log` 5,600 bytes — 5,434 dots + 143 F + 5 s ≈ 94.5% done (5,582/5,929), 0 E. Last stretch is slow (only ~18 tests in ~3.5 min — a slow module, process State R, not stuck on I/O). On track vs expected ~159 F / 0 E; commit+push waits for the gate summary. Next cron (13:00) checks completion.

## Gate VERIFIED + push (main thread, 13:00 run, ~13:0x +07)

- Gate FINISHED ~12:55 +07: **Ran 5929 tests in 987.026s — FAILED (failures=159, skipped=5), 0 errors, 0 `ERROR:` lines.** All 159 failures verified Godot-absent: 159 × `AssertionError: unexpectedly None`. +4 tests / +1 failure vs N2208's 5925/158 — the only new failure is the N2209 proof test itself, Godot-absent in the gate by design (its real Godot proof ran green headless at GREEN). PID 3710 gone at 13:00 check; no duplicate gate. Gate clean except Godot — the expected signature.
- SSOT re-verified from disk at 13:00: registry symbols 11434, ledger entries 1659 (all done, N2209 present), contracts 1581, schemas 2953 — **11434/1659/1581/2953**, audit 1335.
- origin/main re-checked before push: still a4562e05 (no validation merge since N2208) — no rebase needed. (New remote branches slice/N2372–N2374 exist — validation agent's work, untouched.)
- Report `docs/superpowers/reports/2026-11-16-c07-repair-turret-coolant.md` + spec (Done 1658 → 1659 + N2209 row) + GOAL.md §5 (Windows proof debt) written in this tick. Slice `a901d10e` (9 files) → docs `1ea52dfd` → GOAL `c062f576` → hash-naming commit → handoff-status commit → push to origin main in this tick. Post-commit sanity: targeted Ran 4 OK in 15.819s.
- Next after N2209: Units.nearby live query. (Do NOT start the C08 inventory unless the user asks.)
