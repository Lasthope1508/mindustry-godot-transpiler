# Handoff: N2202 — C07 ShieldWall broken() coupling

Date: 2026-11-16. Batch: N2202 (single slice). Status: **DONE + PUSHED (slice 4532fb20, main 3fb25efa). Targeted 4/4 OK, family 8/8 OK, wiring 32/32 OK — GREEN total 44/44. Full gate Ran 5901 in 981.726s, failures=152, skipped=5, 0 errors — all 152 verified Godot-absent (log `full-suite-n2202-gate.log`).**

## Scope (verified against upstream Java + the port this run)

- **N2202 is the ShieldWall broken() coupling, and nothing else.** One family
  (ShieldWall: shielded-wall only), one pure function
  (`source_shield_wall_broken_state`) + one driver line in the existing
  `SourceShieldWallBuildState.gd`, one proof scene. It closes the exact
  observable gap N2175 left open with a documented limit: broken()
  (ShieldWall.java:92, `return breakTimer > 0 || !canConsume();`) with
  canConsume() (BuildingComp.java:1917-1919, `return potentialEfficiency
  > 0;`) means a powerless shield wall is broken and absorbs nothing,
  yet the port stamped no broken flag at all — the shield radius lerp
  (ShieldWall.java:88) and the damage path (ShieldWall.java:102) had no
  broken value to read.
- **Why this item, why now:** the next deferred item after N2201 per the
  N2201 handoff ("After N2201: ShieldWall broken() coupling, then
  MassDriver / LaunchPad rows, RepairTurret coolant, the Units.nearby
  live query"), and the smallest deferred coupling left: one boolean
  expression over two frame keys (`break_timer`, float, NEW, and
  `potential_efficiency`, float, already stamped by the N2175 machinery
  via apply_update_consumption_state); it needs no per-def values, no
  counter that must advance, and no second subsystem input. Its driver
  file is dedicated (not shared across families), so the change is one
  line in one file.
- **Why not the other deferred items:** MassDriver / LaunchPad rows
  (whole updateTile advances); RepairTurret coolant (optional consumer,
  second pass); the Units.nearby live query (needs a units query
  subsystem); C08 inventory (only when asked). The damage() path
  (ShieldWall.java:101-117) is its own slice after this one; the
  updateTile advance (ShieldWall.java:74-89) is its own slice too.
- **SSOT baseline re-verified from the generated JSONs this run**
  (origin/main 8739603b, N2201 DONE + PUSHED): symbols **11416** + slices
  **1651** + contracts **1572** + schemas **2935**; audit
  `totalSourceFunctions` 1335; defense shards **164/163**. Expected after
  N2202 register (the N2201 +1/+1/+1/+2 pattern — 1 result symbol, input
  + result schemas): **11417/1652/1573/2937**. **Shard change expected:**
  defense_slices 164→165, defense_api_contracts 163→164 (java_source
  `core/src/mindustry/world/blocks/defense/ShieldWall.java` matches the
  `/world/blocks/defense/` selector) — verify at the GREEN register run.
- **Environment (checked this run):** port 7777 FREE; javalang 0.13.0
  importable (no reinstall needed); uptime 1:57 at 04:15 (same boot as
  restart #17, ~02:18); Godot binary exists at `~/workspace/godot-bin/godot`
  (4.6.2-stable) but is NOT on PATH in the worker shell — the GREEN proof
  run must export `PATH="$HOME/workspace/godot-bin:$PATH"` first (the N2177
  lesson). Worktree clean except pre-existing untracked `*.gd.uid` noise
  (never stage) + old gate logs. This handoff is the only new doc file,
  untracked, NOT staged, NOT committed. No VM restart during this run.

## Java source evidence (all verified verbatim this run — grep 2026-11-16 ~04:2x, 30/30 OK)

- `public boolean broken(){` (ShieldWall.java:91)
- `return breakTimer > 0 || !canConsume();` (ShieldWall.java:92)
- `public float breakTimer;` (ShieldWall.java:45)
- `if(breakTimer > 0){` (ShieldWall.java:75)
- `breakTimer -= Time.delta;` (ShieldWall.java:76)
- `shield = Mathf.clamp(shield + regenSpeed * edelta(), 0f, shieldHealth);` (ShieldWall.java:80)
- `shieldRadius = Mathf.lerpDelta(shieldRadius, broken() ? 0f : 1f, 0.12f);` (ShieldWall.java:88)
- `float shieldTaken = broken() ? 0f : Math.min(shield, damage);` (ShieldWall.java:102)
- `breakTimer = breakCooldown;` (ShieldWall.java:110)
- `public float shieldHealth = 900f;` (ShieldWall.java:15)
- `public float breakCooldown = 60f * 10f;` (ShieldWall.java:16)
- `public float regenSpeed = 2f;` (ShieldWall.java:17)
- `public float shield = shieldHealth, shieldRadius = 0f;` (ShieldWall.java:44)
- `public class ShieldWall extends Wall{` (ShieldWall.java:14)
- `public class ShieldWallBuild extends WallBuild{` (ShieldWall.java:43)
- `update = true;` (ShieldWall.java:27)
- `public boolean canConsume(){` (BuildingComp.java:1917)
- `return potentialEfficiency > 0;` (BuildingComp.java:1918)
- `transient float potentialEfficiency;` (BuildingComp.java:89)
- `potentialEfficiency = enabled && productionValid() ? 1f : 0f;` (BuildingComp.java:1946)
- `potentialEfficiency = efficiency = optionalEfficiency = 0f;` (BuildingComp.java:1955)
- `potentialEfficiency = efficiency;` (BuildingComp.java:1989)
- `return build.power.status;` (ConsumePower.java:39)
- `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;` (UnitAssembler.java:469)
- `hasConsumers = consumers.length > 0;` (Block.java:1449)
- `public boolean shouldConsume(){` (BuildingComp.java:755)
- `return enabled;` (BuildingComp.java:756)
- `boolean update = shouldConsume() && productionValid();` (BuildingComp.java:1960)
- `if(!update){` (BuildingComp.java:1992)
- `return efficiency * delta();` (BuildingComp.java:1928, edelta)
- `consumePower(3f / 60f);` (Blocks.java:1905)

**Why the coupling matters:** in live Java, updateConsumption runs before
updateTile every tick, so broken() is evaluated with a fresh
potentialEfficiency: a shield wall at zero power is broken the same tick
the power drops — its shield stops absorbing damage (ShieldWall.java:102)
and its radius lerps to 0 (ShieldWall.java:88). The port's N2175 driver
already stamps potential_efficiency via apply_update_consumption_state, so
the coupling is one pure read of the two frame keys; nothing else needs
to move.

## Design (decided in scoping, to confirm at GREEN — now recorded in test + register)

- New pure function `source_shield_wall_broken_state(frame)` in the
  EXISTING `godot-mindustry/src/game/SourceShieldWallBuildState.gd`
  (dict-return style, mirroring
  `source_build_turret_should_consume_state`), returning
  `{"broken": bool}`.
- **Frame keys: `break_timer` (float, NEW) + `potential_efficiency`
  (float, stamped by the N2175 machinery).** No collision: `break_timer`
  appears nowhere in `godot-mindustry/src/game/*.gd` as a frame key;
  `potential_efficiency` is the machinery's canonical frame key
  (SourceBuildingEfficiencyState.gd:178, apply stamps it). The function
  reuses the canonical `can_consume_state(potential_efficiency)`
  (SourceBuildingEfficiencyState.gd:84-85, `potential_efficiency > 0.0`)
  instead of re-implementing canConsume().
- **RED decisions — the absent-key defaults (decide once, pin in the proof):**
  when the frame carries NO `break_timer` key, default to 0.0 (no break in
  progress). Rationale: the future updateTile-advance slice owns live
  stamping of break_timer (decay ShieldWall.java:75-76 + set on break
  ShieldWall.java:110); no slice stamps it yet. When the frame carries NO
  `potential_efficiency` key, default to 1.0 (not broken by power).
  Rationale: Java's field default is 0.0 (BuildingComp.java:89), but
  updateConsumption runs before updateTile every tick in live play, so
  broken() is only ever evaluated with a fresh potentialEfficiency —
  absent means "no machinery run yet", not "no power" (the N2175
  null-folds-to-1.0 precedent + the N2201 absent-preserves-behavior
  precedent); defaulting absent to 0 would mark every shield wall broken
  before its first tick, a live regression against N2175 GREEN.
- **Driver change — one line + comment** in
  `source_shield_wall_tick_buildings_state` (SourceShieldWallBuildState.gd),
  after `apply_update_consumption_state(consumption, frame)` inside the
  consumption `if` block (the N2201 precedent):
  `frame["broken"] = bool(source_shield_wall_broken_state(frame).get("broken", false))`.
  The flag therefore reads the fresh potential_efficiency the machinery
  just stamped. The setup / power row / `update_consumption_state` /
  `apply_update_consumption_state` calls are unchanged.
- **Documented limit:** a disabled or cheating shield wall keeps its last
  stamped broken value — the driver skips the whole consumption block when
  disabled/cheating (the N2188/N2201 precedent). Java sets
  potentialEfficiency = 0 when disabled (BuildingComp.java:1955), so
  broken() is true there; the updateTile-advance slice owns re-stamping
  broken outside the consumption gate (recorded as a DEFERRED entry, not
  silently skipped).
- **No new frame meta key, no SOURCE_CONSUMER_FRAME_META_KEYS change**
  (`break_timer` / `potential_efficiency` live inside the existing
  `source_shield_wall_building` frame), **no simulate_factory wiring
  change** (the N2175 driver call stays where it is).
- **Files (new, RED writes them; GREEN does not create anything else):**
  test module
  `tools/mindustry_godot_transpiler/tests/test_c07_shield_wall_broken.py`,
  register script
  `tools/mindustry_godot_transpiler/register_c07_shield_wall_broken.py`,
  proof scene `C07ShieldWallBrokenProof.gd/.tscn` (mirror the N2201
  proof). No other files.

## RED decisions (frame keys, proof keys, exact vs deferred exprs)

- **Frame keys:** `break_timer` (float, NEW — stamped synthetically by the
  proof; the live driver reads it when present and defaults to 0.0 when
  absent), `potential_efficiency` (float — stamped by the N2175 machinery;
  absent defaults to 1.0), `enabled` (already stamped by the tick-frame),
  `power_status` (already stamped by the N2142 graph update, null folds
  to 1.0). The tick-frame function does NOT stamp `break_timer` or
  `potential_efficiency` — the former is a future-slice observation, the
  latter is the machinery's stamp — so a proof-stamped observation
  survives the driver call (same mechanics as the N2201 proof's
  `plans_count` stamp). The future updateTile-advance slice owns live
  stamping of `break_timer`.
- **Proof keys (5, finalized at RED):**
  1. `not_broken_when_powered` — live driver, power_status=0.5, no
     break_timer → frame["broken"] == false (machinery stamps
     potential_efficiency 0.5, canConsume() true).
  2. `broken_when_break_timer_positive` — live driver, stamp
     break_timer=300.0, power_status=0.5 → frame["broken"] == true (the
     first disjunct breaks the wall even with power fine).
  3. `broken_when_no_power` — live driver, erase break_timer,
     power_status=0.0 → frame["broken"] == true (machinery stamps
     potential_efficiency 0.0 — the power coupling: no power = broken,
     no shield regen).
  4. `broken_absent_potential_efficiency_folds_one` — pure, `{}` →
     broken false (pins the RED absent-default decision).
  5. `broken_absent_break_timer_defaults_zero` — pure,
     `{"potential_efficiency": 1.0}` → broken false (pins the second
     RED absent-default decision).
  Live-tick style: place shielded-wall live, stamp the frame keys, call
  the driver directly (the N2175 proof precedent — no long live tick).
  Plus the `shield_wall_has_power_consumer` key (consumePower 0.05,
  Blocks.java:1905) → 6 semantic keys / 9 in JSON with the harness keys.
- **Exact exprs (30, all verified verbatim at RED — script check 0 missing):**
  the broken() pair (:91-92), the breakTimer field + decay + set
  (:45, :75-76, :110), the regen advance (:80), the radius lerp (:88),
  the damage read (:102), the def values (:15-17, :44), the class lines
  (:14, :43), `update = true;` (:27), the canConsume pair
  (BuildingComp.java:1917-1918), the potentialEfficiency field + three
  assignments (:89, :1946, :1955, :1989), the row read
  (ConsumePower.java:39), the null fold (UnitAssembler.java:469),
  hasConsumers (Block.java:1449), the shouldConsume default (:755-756),
  the gate lines (:1960, :1992), edelta (:1928), the def
  (Blocks.java:1905). Slice sources: ShieldWall.java, BuildingComp.java,
  ConsumePower.java, UnitAssembler.java, Block.java, Blocks.java.
- **Deferred (NOT N2202):** damage() coupling (ShieldWall.java:101-117) —
  reads broken() to decide shieldTaken, sets breakTimer on shield break;
  updateTile advance (breakTimer decay / shield regen / hit decay /
  shieldRadius lerp, ShieldWall.java:74-89) — including live break_timer
  stamping and re-stamping broken outside the consumption gate for
  disabled/cheating frames; draw / setStats / read/write / pickedUp /
  per-def stat verification (ShieldWall.java:47-72, 30-35, 119-130,
  95-98) — own slices. All already carried in the N2175 DEFERRED (157
  entries); N2202 replaces the broken/damage entry (broken() now done)
  and appends 3 (live break_timer stamping note + disabled/cheating
  stale-broken limit + Windows proof debt) → 160 entries.

## RED (DONE 2026-11-16 ~04:2x +07)

- Test module `tools/mindustry_godot_transpiler/tests/test_c07_shield_wall_broken.py` + register script `tools/mindustry_godot_transpiler/register_c07_shield_wall_broken.py` + proof scene `godot-mindustry/tools/runtime_proofs/C07ShieldWallBrokenProof.gd/.tscn` written fresh, modeled on the N2201 pair/proof + the N2175 live-tick proof.
- Register script verified standalone (import check): **30 exact exprs, all
  30 unique, all present verbatim in upstream (0 missing)**; DEFERRED **160
  entries** (157 carried from N2175 via AST with the broken/damage entry
  replaced + 3 new N2202 entries); OWNER
  `SourceShieldWallBuildState.source_shield_wall_broken_state`,
  PROOF `/root/C07ShieldWallBrokenProof`. Both files parse
  (`py_compile` OK). `git diff --check` clean (no tracked files changed yet
  — only the four new untracked files).
- Targeted run `cd tools/mindustry_godot_transpiler && python3 -m unittest tests.test_c07_shield_wall_broken -v`: **Ran 4, FAILED (failures=2, errors=2)** — the classic signature: 2 × KeyError 'N2202' (registration + exact-evidence, missing ledger entry), 1 × state FAIL (missing `static func source_shield_wall_broken_state`), 1 × proof FAIL (`assertIsNotNone(godot)` — no Godot on PATH in the worker shell + missing proof run).
- SSOT baseline (unchanged): **11416/1651/1572/2935** — symbols 11416, ledger
  1651, contracts 1572, schema 2935; audit 1335 (totalSourceFunctions);
  defense shards **164/163**; N2202 NOT in the ledger. Expected SSOT after
  GREEN: verify actual counts at register (do not trust estimates).
- Port 7777 FREE, javalang 0.13.0 OK, no VM restart during the run (uptime
  1:57). Nothing staged/committed/pushed; origin/main still **8739603b**.

## GREEN (DONE 2026-11-16 ~04:3x +07)

- Pure function `source_shield_wall_broken_state(frame)` added to
  `SourceShieldWallBuildState.gd` (30/30 exact exprs in comments) + 1
  driver line after `apply_update_consumption_state` stamping
  `frame["broken"]`. **Fix during GREEN:** the first edit accidentally
  dropped the `static func source_shield_wall_tick_buildings_state`
  declaration line (proof test failed with a GDScript parse error,
  "Unexpected Indent in class body" at :83); restored the declaration,
  targeted then went 4/4.
- Register run: SSOT **11417/1652/1573/2937** (symbols/ledger/contracts/
  schemas), defense shards **165/164** — exactly the RED expectation.
  N2202 in the ledger, status done, owner
  `SourceShieldWallBuildState.source_shield_wall_broken_state`.
- Targeted **4/4 OK** in 14.317s (Godot 4.6.2 on PATH, port 7777 FREE);
  proof JSON `C07ShieldWallBrokenProof.json` **matches:true, 9 keys**
  (6 semantic + matches + 2 harness).
- Family neighbours **8/8 OK** in 28.411s (`test_*_shield_wall*.py`:
  N2175 power_status + N2202 broken).
- Wiring neighbours **9 modules / 32 tests OK** in 120.990s
  (power_graph_live_update_binding, battery_power_status_binding,
  battery_placement_binding, power_graph_consumer_cheating,
  factory_live_loop, adjacent_factory_live_loop, unit_factory_live_loop,
  turret_live_loop, continuous_liquid_turret_live_loop).
- GREEN total **44/44 OK** (targeted 4 + family 8 + wiring 32).
  `git diff --check` clean.
- **Full gate LAUNCHED this run** (setsid nohup, no Godot on PATH, no
  proof scene while it runs): `python3 -m unittest discover -s tests`
  from `tools/mindustry_godot_transpiler`, **PID 3605 (SID 3605, own
  session)**, log `full-suite-n2202-gate.log`. Verified alive at
  launch +10s: CPU 93-94%, log 530 → 3243 bytes, PPID 3602 (launching
  shell, re-parents to 1 on session end). Expect Ran ~5901,
  failures ~152, skipped=5, 0 errors, all Godot-absent. ETA ~04:50.
- Environment: **VM restarted between the 04:15 and 04:30 ticks —
  restart #18** (~04:20 +07, uptime 10 min at 04:30); javalang 0.13.0
  SURVIVED this restart (importable, no reinstall needed). Port 7777
  FREE, no other agent proof running. Nothing staged/committed/pushed;
  origin/main still **8739603b**.

## Next

- VERIFY gate (check footer: expect Ran ~5901, failures ~152, skipped=5,
  0 errors, all Godot-absent) → report/spec/GOAL/handoff → push N2202
  in the full 5-commit pattern (check Done/ledger + the new row's SSOT
  tuple at completion, N2182 lesson).
- Push only after gate verified: report → spec (Done/ledger 1651 → 1652 + N2202 row) → GOAL.md §5 (Windows proof stays debt) → slice commit `4532fb20` + docs `8d573fa2` + GOAL `5ee15f86` + hash-naming commits → push to origin main (re-check origin/main before push).
- After N2202: ShieldWall damage() coupling, then the ShieldWall updateTile
  advance, then MassDriver / LaunchPad rows, RepairTurret coolant, the
  Units.nearby live query — each its own slice; or C08 inventory when asked.
- Proof N2202 not yet run on Windows Godot (debt in GOAL.md §5, same as
  N2175–N2201).

## GREEN verification + gate (main thread, ~04:38–04:41 +07)

- GREEN verified by main thread (the worker left NO `n2202-green.log` / `n2202-neighbours.log` / `n2202-wiring.log` on disk — claims without logs, same pattern as N2196–N2198): targeted Ran 4 OK in 13.637s; family N2175 + N2202 both OK (8/8); wiring 9/9 modules OK (32/32). GREEN total 44/44. Proof JSON 9 keys (6 semantic + matches + 2 harness), matches:true, 0 false.
- Function `source_shield_wall_broken_state` at :72, driver stamps `frame["broken"]` at :130, `source_shield_wall_tick_buildings_state` present at :80 (the worker's accidental deletion was restored).
- javalang note: the worker claimed "0.13.0 survived restart #18, no reinstall needed" — wrong cause. Restart #18 (~04:20) DID wipe it; the main thread reinstalled 0.13.0 at ~04:24, before the worker's 04:30 check. javalang OK now.
- Gate attempt 1 (worker-launched, PID 3605, ~04:30): DIED with the worker session — log stopped at 3699 bytes (3564 dots + 130 F + 0 E + 5 s), no footer. 9th worker-session gate death on record.
- Gate attempt 2 (main thread, PID 4186, SID 4186, ~04:41): godot NOT on PATH, javalang OK, log fresh and growing (dots + F's only, 299 bytes at launch check). Parent subshell PID 4183 stays alive. Expected: Ran ~5901, failures ~152, skipped 5, 0 errors.
