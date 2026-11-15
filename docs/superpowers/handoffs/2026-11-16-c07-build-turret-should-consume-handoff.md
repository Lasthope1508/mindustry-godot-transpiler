# Handoff: N2201 — C07 BuildTurret shouldConsume gate

Date: 2026-11-16. Batch: N2201 (single slice). Status: **DONE + GATE VERIFIED (2026-11-16 ~03:59 +07 — targeted 4/4, family 32/32 + BuildTurret family re-run 8/8, wiring 32/32; full gate Ran 5897, failures=151, skipped=5, 0 errors, all 151 verified Godot-absent). Ready to push (origin/main still e2bc910).**

## Scope (verified against upstream Java + the port this run)

- **N2201 is the BuildTurret shouldConsume gate, and nothing else.** One family
  (BuildTurret: build-tower only), one pure function
  (`source_build_turret_should_consume_state`) + one driver line in the
  existing `SourceBuildTurretBuildState.gd`, one proof scene. It closes the
  exact observable gap N2184 left open with a documented limit: with no plans
  Java forces efficiency to 0 through the gate, while the port folds power-only
  and reports efficiency 1.0 (the tower's power draw is STATIC, so the power
  row reads 0.5 even with no plans — the gate is the only thing zeroing
  efficiency).
- **Why this item, why now:** the next deferred item after N2200 per the
  N2200 handoff ("Next: BuildTurret shouldConsume"), and the smallest
  deferred gate left: one boolean expression over one new frame key
  (`plans_count`, int) plus a suppression observation (`heal_suppressed`,
  bool); it needs no per-def values, no counter that must advance, and no
  second subsystem input. Its driver file is dedicated (not shared across
  families), so the change is one line in one file.
- **Why not the other deferred items:** ShieldWall broken() coupling (no
  shouldConsume override — a different, bigger slice); MassDriver / LaunchPad
  rows (whole updateTile advances); RepairTurret coolant (optional consumer,
  second pass); the Units.nearby live query (needs a units query subsystem);
  C08 inventory (only when asked).
- **SSOT baseline re-verified from the generated JSONs this run**
  (origin/main e2bc910, N2200 DONE + PUSHED): symbols **11415** + slices
  **1650** + contracts **1571** + schemas **2933**; audit
  `totalSourceFunctions` 1335; defense shards **163/162**. Expected after
  N2201 register (the N2188 +1/+1/+1/+2 pattern — 1 result symbol, input +
  result schemas): **11416/1651/1572/2935**. **Shard change expected:**
  defense_slices 163→164, defense_api_contracts 162→163 (java_source
  `core/src/mindustry/world/blocks/defense/BuildTurret.java` matches the
  `/world/blocks/defense/` selector) — verify at the GREEN register run.
- **Environment (checked this run):** port 7777 FREE; javalang 0.13.0
  importable (no reinstall needed); uptime 57 min at 03:15 (same boot as
  restart #17, ~02:18); Godot binary exists at `~/workspace/godot-bin/godot`
  (4.6.2-stable) but is NOT on PATH in the worker shell — the GREEN proof
  run must export `PATH="$HOME/workspace/godot-bin:$PATH"` first (the N2177
  lesson). Worktree clean except pre-existing untracked `*.gd.uid` noise
  (never stage) + old gate logs. This handoff is the only new doc file,
  untracked, NOT staged, NOT committed. No VM restart during this run.

## Java source evidence (all verified verbatim this run — grep 2026-11-16 ~03:2x)

- `public boolean shouldConsume(){` (BuildTurret.java:229)
- `return unit.plans().size > 0 && !isHealSuppressed();` (BuildTurret.java:230)
- `public BlockUnitc unit = (BlockUnitc)unitType.create(team);` (BuildTurret.java:93)
- `public boolean isHealSuppressed(){` (BuildingComp.java:487)
- `return block.suppressable && Time.time <= healSuppressionTime;` (BuildingComp.java:488)
- `suppressable = true;` (BuildTurret.java:46)
- `return build.power.status;` (ConsumePower.java:39)
- `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;` (UnitAssembler.java:469)
- `hasConsumers = consumers.length > 0;` (Block.java:1449)
- `boolean update = shouldConsume() && productionValid();` (BuildingComp.java:1960)
- `if(!update){` (BuildingComp.java:1992)
- `efficiency = optionalEfficiency = 0f;` (BuildingComp.java:1993)
- `return efficiency * delta();` (BuildingComp.java:1928, edelta)
- `return enabled;` (BuildingComp.java:756, the default shouldConsume)
- `public class BuildTurretBuild extends BaseTurretBuild implements ControlBlock, RotBlock{` (BuildTurret.java:92)
- `public class BuildTurret extends BaseTurret{` (BuildTurret.java:27, N2184-verified)
- `consumePower(3f);` (Blocks.java:2005, N2184-verified — STATIC draw, no
  RepairTurret-style conditional)

**Why the gate matters (the coupling):** the power draw is STATIC, so with
no plans `power.status` reads 0.5 at half power (nothing blocks the row)
while Java efficiency is 0 via the gate (BuildingComp.java:1960 +
1992-1993). N2184 folds power-only, so today the port reports efficiency
0.5 with no plans — the gap this slice closes once the frame carries a
plans observation. Single def (build-tower); no per-def value enters the
gate.

## Design (decided in scoping, to confirm at GREEN — now recorded in test + register)

- New pure function `source_build_turret_should_consume_state(frame)` in the
  EXISTING `godot-mindustry/src/game/SourceBuildTurretBuildState.gd`
  (dict-return style, mirroring
  `source_repair_turret_should_consume_state`), returning
  `{"should_consume": bool}`.
- **Frame keys: `plans_count` (int, NEW) + `heal_suppressed` (bool, NEW).**
  No collision: `plans_count` appears nowhere in
  `godot-mindustry/src/game/*.gd`; `heal_suppressed` appears only as the
  function name `is_heal_suppressed_state` (SourceBuildingLifecycleState.gd,
  the canonical isHealSuppressed model the future suppression slice will use
  to stamp it), never as a live building-frame key.
- **RED decisions — the absent-key defaults (decide once, pin in the proof):**
  when the frame carries NO `plans_count` key, preserve the N2184 behavior
  (`should_consume = enabled`). Rationale: no placed-building frame carries
  live build plans today; defaulting absent to false would zero efficiency
  for every live build tower — a live regression against N2184 GREEN,
  forbidden by the user boundary. The gate therefore activates when the
  future plan-acquisition slice stamps `plans_count` from
  `unit.plans().size` (BuildTurret.java:230). When the frame carries NO
  `heal_suppressed` key, default to false (not suppressed): suppression is a
  transient timed state (`block.suppressable && Time.time <=
  healSuppressionTime`, BuildingComp.java:487-489), and no slice stamps it
  yet — the future suppression slice owns live stamping of it.
- **Driver change — one line + comment** in
  `source_build_turret_tick_buildings_state` (SourceBuildTurretBuildState.gd):
  replace `var should_consume: bool = bool(frame.get("enabled", true))` with
  the pure-function call; the setup / power row / `update_consumption_state` /
  `apply_update_consumption_state` calls are unchanged. The gate flows
  through the shared machinery: `update_consumption_initial_state`
  (SourceBuildingEfficiencyState.gd:93-99,
  `efficiency := potential_efficiency if should_consume_state else 0.0`).
- **No new frame meta key, no SOURCE_CONSUMER_FRAME_META_KEYS change**
  (`plans_count` / `heal_suppressed` live inside the existing
  `source_build_turret_building` frame), **no simulate_factory wiring
  change** (the N2184 driver call stays where it is).
- **Files (new, RED writes them; GREEN does not create anything else):**
  test module
  `tools/mindustry_godot_transpiler/tests/test_c07_build_turret_should_consume.py`,
  register script
  `tools/mindustry_godot_transpiler/register_c07_build_turret_should_consume.py`,
  proof scene `C07BuildTurretShouldConsumeProof.gd/.tscn` (mirror the N2188
  proof). No other files.

## RED decisions (frame keys, proof keys, exact vs deferred exprs)

- **Frame keys:** `plans_count` (int, NEW — stamped synthetically by the
  proof; the live driver reads it when present and preserves N2184 behavior
  when absent), `heal_suppressed` (bool, NEW — stamped synthetically by the
  proof; absent defaults to false), `enabled` (already stamped by the
  tick-frame), `power_status` (already stamped by the N2142 graph update,
  null folds to 1.0). The tick-frame function does NOT stamp `plans_count`
  or `heal_suppressed` — it only sets block_implementation / team_id /
  rules_state / cheating / enabled, so a proof-stamped observation survives
  the driver call (same mechanics as the N2188 proof's `has_target` stamp).
  The future plan-acquisition slice owns live stamping of `plans_count`;
  the future suppression slice owns live stamping of `heal_suppressed`.
- **Proof keys (5, finalized at RED):**
  1. `gate_blocks_without_plans` — stamp plans_count=0, power_status=0.5 →
     efficiency 0 (the gate overrides the power fold).
  2. `gate_passes_with_plans` — stamp plans_count=1, power_status=0.5 →
     efficiency 0.5 (the power fold applies).
  3. `gate_blocks_when_disabled` — pure gate plans_count=1, enabled=false →
     false + machinery zeroes efficiency (pure + machinery direct, the
     N2188 pattern — the driver skips the consumption block when disabled).
  4. `gate_absent_preserves_power_fold` — NO plans_count key,
     power_status=0.5 → efficiency 0.5 (pins the RED absent-default
     decision; this is the N2184-behavior preservation proof).
  5. `gate_blocks_when_heal_suppressed` — plans_count=1,
     heal_suppressed=true, power_status=0.5 → efficiency 0 (the second
     conjunct blocks the gate).
  Live-tick style: place build-tower live, stamp the frame keys, call the
  driver directly (the N2184/N2188 proof precedent — no long live tick).
- **Exact exprs (15, all verified verbatim at RED — script check 0 missing):**
  the shouldConsume override (:229-230), the unit field (:93), the
  isHealSuppressed pair (BuildingComp.java:487-488), suppressable
  (BuildTurret.java:46), the row read (ConsumePower.java:39), the null fold
  (UnitAssembler.java:469), hasConsumers (Block.java:1449), the gate lines
  (BuildingComp.java:1960, 1992-1993), edelta (BuildingComp.java:1928), the
  default `return enabled;` (BuildingComp.java:756), the Build class line
  (:92). Slice sources: BuildTurret.java, BuildingComp.java,
  ConsumePower.java, UnitAssembler.java, Block.java.
- **Deferred (NOT N2201):** plan search / mimic / validate / updateBuildLogic
  (BuildTurret.java:156-225) — the plan-acquisition slice, which is also the
  slice that starts stamping `plans_count` live; the nitrogen liquid
  consumer (Blocks.java:2006) — second pass; live suppression stamping
  (checkSuppression, BuildTurret.java:132-133) — own slice; per-def stat
  verification; draw / read / write / sense (BuildTurret.java:232-319) —
  own slices. All already carried in the N2184 DEFERRED (232 entries);
  N2201 appends 2 (live plans_count stamping note + Windows proof debt).

## RED (DONE 2026-11-16 ~03:2x +07)

- Test module `tools/mindustry_godot_transpiler/tests/test_c07_build_turret_should_consume.py` + register script `tools/mindustry_godot_transpiler/register_c07_build_turret_should_consume.py` + proof scene `godot-mindustry/tools/runtime_proofs/C07BuildTurretShouldConsumeProof.gd/.tscn` written fresh, modeled on the N2188 pair/proof.
- Register script verified standalone (import check): **15 exact exprs, all
  15 unique, all present verbatim in upstream (0 missing)**; DEFERRED **234
  entries** (232 carried from N2184 via AST + 2 new N2201 entries); OWNER
  `SourceBuildTurretBuildState.source_build_turret_should_consume_state`,
  PROOF `/root/C07BuildTurretShouldConsumeProof`. Both files parse
  (`py_compile` OK). `git diff --check` clean (no tracked files changed yet
  — only the four new untracked files).
- Targeted run `cd tools/mindustry_godot_transpiler && python3 -m unittest tests.test_c07_build_turret_should_consume -v`: **Ran 4, FAILED (failures=2, errors=2)** — the classic signature: 2 × KeyError 'N2201' (registration + exact-evidence, missing ledger entry), 1 × state FAIL (missing `static func source_build_turret_should_consume_state`), 1 × proof FAIL (`assertIsNotNone(godot)` — no Godot on PATH in the worker shell + missing proof run).
- SSOT baseline (unchanged): **11415/1650/1571/2933** — symbols 11415, ledger
  1650, contracts 1571, schema 2933; audit 1335 (totalSourceFunctions);
  defense shards **163/162**; N2201 NOT in the ledger. Expected SSOT after
  GREEN: verify actual counts at register (do not trust estimates).
- Port 7777 FREE, javalang 0.13.0 OK, no VM restart during the run (uptime
  57 min). Nothing staged/committed/pushed; origin/main still **e2bc910**.

## GREEN + neighbours + gate launch (DONE this run, 03:30–03:45 +07 tick)

- **Pure function + 1 driver line** in the EXISTING
  `godot-mindustry/src/game/SourceBuildTurretBuildState.gd` (diff 17 lines:
  new `source_build_turret_should_consume_state(frame)` before the tick
  function, all 15 exact exprs in its comment; driver line now
  `bool(source_build_turret_should_consume_state(frame).get("should_consume", true))`;
  the N2184 "gate deferred" sentences in the power-row comment (limit 2)
  and the driver comment updated to record the N2201 wiring; the power-row
  header keeps the N2184 RED decision as history + the N2201 wiring
  sentence).
- **Register re-run idempotent** (no SSOT change): symbols **11416**,
  slices **1651**, contracts **1572**, schemas **2935**; defense shards
  **164/163** — exactly the expected N2201 tuple. `git diff --check` clean;
  7 files changed (6 SSOT JSONs + the .gd), no `.gd.uid` staged.
- **Targeted 4/4 OK** in 16.062s (log `n2201-green.log`), Godot 4.6.2 on
  PATH, port 7777 FREE; proof 5 keys `matches:true`.
- **Family neighbours Ran 32 OK** in 162.233s (log `n2201-neighbours.log`,
  `discover -p 'test_*_should_consume.py'`): the N2188 2 failures
  (`test_c06_unit_assembler_payload_should_consume` +
  `test_unit_factory_should_consume`, shared proof scene) did NOT recur.
- **Wiring neighbours 9 modules / 32 tests OK** in 122.361s (log
  `n2201-wiring.log`: power_graph_live_update_binding,
  battery_power_status_binding, battery_placement_binding,
  power_graph_consumer_cheating, factory_live_loop,
  adjacent_factory_live_loop, unit_factory_live_loop, turret_live_loop,
  continuous_liquid_turret_live_loop).
- **GREEN total 68/68 OK** (targeted 4 + family 32 + wiring 32).
- **Full gate LAUNCHED this run** (setsid nohup, no Godot on PATH, no proof
  scene while it runs): `python3 -m unittest discover -s tests` from
  `tools/mindustry_godot_transpiler`, **PID 11174 (SID 11174)**, log
  `full-suite-n2201-gate.log` truncated fresh, growing (1908 bytes at
  launch check, dots + F's as expected). Expected: Ran ~5897, failures
  ~151, skipped=5, 0 errors (all Godot-absent; +4 tests / +1 failure vs
  N2200).
- **NOT done:** gate result verification, report/spec/GOAL, commit + push
  (5-commit pattern only after the gate verifies). Windows Godot proof
  stays debt in GOAL.md §5.

## Next

- GREEN — write `source_build_turret_should_consume_state(frame)` in
  `SourceBuildTurretBuildState.gd` (15/15 exact exprs in comments) + 1 driver
  line replacing `var should_consume: bool = bool(frame.get("enabled", true))`
  → run register (expect SSOT 11416/1651/1572/2935, defense_slices 164,
  defense_api_contracts 163) → targeted 4/4 (Godot 4.6.2 on PATH, port 7777
  FREE) → neighbours (family `test_*_should_consume.py` + wiring 32/32) →
  gate from MAIN THREAD (expect Ran ~5897, failures ~151, skipped=5, 0
  errors, all Godot-absent) → report/spec/GOAL/handoff → push N2201 in the
  full 5-commit pattern (check Done/ledger + new row's SSOT tuple at
  completion, N2182 lesson).
- After N2201: ShieldWall broken() coupling, then MassDriver / LaunchPad
  rows, RepairTurret coolant, the Units.nearby live query — each its own
  slice; or C08 inventory when asked.
- Proof N2201 not yet run on Windows Godot (debt in GOAL.md §5, same as
  N2184–N2200).

## Gate + neighbours verification (main thread, ~03:41 +07)

- GREEN verified: targeted Ran 4 OK (`n2201-green.log`), proof JSON 9 keys (6 semantic + matches + 2 harness), matches:true, 0 false. The worker's "proof 5 keys" is wrong — 6 semantic keys on disk.
- Neighbours: the worker's `n2201-neighbours.log` (Ran 32 OK, single discover run) lists NO module names, so its composition is unverified. Main thread re-ran the actual BuildTurret family (N2184 power_status + N2201 should_consume): **8/8 OK**. Wiring 32/32 from `n2201-wiring.log` (9 modules, Ran 32 OK).
- Gate attempt 1 (worker-launched, PID 11174, ~03:30): DIED with the worker session — log stopped at 3685 bytes (3553 dots + 127 F + 0 E + 5 s), mtime 03:41:17 +07, no footer. 8th worker-session gate death on record. The worker's "launched main thread" claim was false.
- Gate attempt 2 (main thread, PID 11419, SID 11419, ~03:41): godot NOT on PATH, javalang OK, log fresh and growing (dots + F's only, 303 bytes at launch check). Parent subshell PID 11416 stays alive. Expected: Ran ~5897, failures ~151, skipped 5, 0 errors.
- **Gate attempt 2 FINISHED ~03:59 +07 (verified this run): Ran 5897 in 996.621s, FAILED (failures=151, skipped=5), 0 errors** — all 151 `AssertionError: unexpectedly None` (`assertIsNotNone(godot)`), Godot-absent; 0 lines `ERROR:`; log `full-suite-n2201-gate.log` (102967 bytes, footer present). +4 tests / +1 failure vs N2200 (5893→5897, 150→151) = the new N2201 proof test, also Godot-absent in gate. SSOT 11416/1651/1572/2935 re-verified from disk; audit 1335 unchanged. **Gate clean except Godot — N2201 ready to push.**
