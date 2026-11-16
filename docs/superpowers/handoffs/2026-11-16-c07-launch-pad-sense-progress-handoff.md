# Handoff: N2206 — C07 LaunchPad sense(progress)

Date: 2026-11-16. Batch: N2206 (single slice). Status: **GREEN + gate LAUNCHED (main thread ~09:41 +07). Targeted 4/4 OK, family 12/12 OK, wiring 32/32 OK — GREEN total 48/48. Full gate Ran ~5917 expected, failures ~156, skipped 5, 0 errors. Report/spec/GOAL + commit/push NOT done.**
N2205 DONE + PUSHED (slice 68b32928 + docs b56b13b8 + GOAL 9df5a0bf +
hash-naming 2fa75d50 + handoff-status 8cb6e987 + main-thread spec fix-up
7fac96a2; HEAD == origin/main == 7fac96a2, verified by fetch this run).**

## RED (2026-11-16 ~09:2x, this run)

- Test file written:
  `tools/mindustry_godot_transpiler/tests/test_c07_launch_pad_sense_progress.py`
  (4 tests, N2205 pattern). Targeted run: **Ran 4, failures=2,
  errors=2 — classic RED**: registration KeyError 'N2206' (register
  runs at GREEN); evidence test KeyError 'N2206'; state test missing
  `source_launch_pad_sense_state`; proof test fails with godot on PATH
  (scene `C07LaunchPadSenseProgressProof.tscn` does not exist yet —
  re-verified with `PATH="$HOME/workspace/godot-bin:$PATH"`, Ran 1,
  failures=1). Without PATH the proof test fails at `which('godot')`
  instead — same RED, wrong reason; GREEN proof run must export PATH
  first (N2177 lesson).
- RED decisions PINNED (all four open questions from the scope section
  are now decided — GREEN implements exactly this):
  1. Signature `source_launch_pad_sense_state(frame: Dictionary,
     sensor: String, launch_time: float) -> Dictionary`; wire is the
     generic laccess shape (`sense_value` + `sense_value_is_nan`,
     SourceBlockSenseState.laccess_state) PLUS an explicit `handled`
     flag: progress → `{"handled": true, "sense_value": fraction,
     "sense_value_is_nan": false}`; any other sensor →
     `{"handled": false, "sense_value": null,
     "sense_value_is_nan": true}` (fall through to super.sense).
  2. Absent `launch_counter` → **0.0 (Option A, Java-init-faithful)**:
     `public float launchCounter;` defaults to 0.0f, so a freshly
     built pad senses clamp(0 / launchTime) = 0.0; absent → NaN would
     preserve the port's current UNFAITHFUL output, and unlike N2205
     there is no live regression (no consumer reads this value yet).
     Code pinned: `0.0 if observed == null else float(observed)`.
  3. Sensor string **"progress"** — LAccess.java:28 `progress,`
     (verified verbatim this run); generic sense layer matches enum
     names as strings.
  4. Clamp edge pinned: `clampf(counter / launch_time, 0.0, 1.0)` —
     counter at/above launchTime → 1.0, counter 0 → 0.0.
- Java evidence re-verified verbatim this run: LaunchPad.java:98-101
  (`public double sense(LAccess sensor){` / `if(sensor ==
  LAccess.progress) return Mathf.clamp(launchCounter / launchTime);` /
  `return super.sense(sensor);`); BuildingComp.java:2093 + 2123
  (`default -> Float.NaN; //gets converted to null in logic`, no
  progress case) + 617-619 (`public float progress(){` / `return 0f;`
  — a DIFFERENT method, never called by sense); LAccess.java:28;
  MendProjector.java:126-129 (same shape, charge/reload).
- One result symbol registered by the RED test:
  `source_launch_pad_sense_state_result.sense_value` (N2205 +1
  pattern). Proof keys (6): sense_progress_below_launch_time,
  sense_progress_at_launch_time, sense_progress_above_launch_time,
  sense_progress_absent_counter_zero, sense_fall_through_non_progress,
  sense_progress_advanced_pad.
- Environment re-checked this run: HEAD == origin/main == 7fac96a2
  (fetch, no new commits); javalang 0.13.0 importable; port 7777 free;
  worktree clean except the pre-existing untracked `*.gd.uid` noise
  + this test file (untracked, do NOT stage .uid files).

## GREEN (2026-11-16 ~09:4x, this run)

- Pure function implemented in `SourceLaunchPadBuildState.gd` next to
  the shouldConsume function: `source_launch_pad_sense_state(frame,
  sensor, launch_time)` — `sensor == "progress"` returns
  `{"handled": true, "sense_value": clampf(counter / launch_time,
  0.0, 1.0), "sense_value_is_nan": false}` with absent
  `launch_counter` → 0.0 (Java init, pinned RED decision); any other
  sensor returns `{"handled": false, "sense_value": null,
  "sense_value_is_nan": true}` (fall through to super.sense). NO
  driver tick line (N2203 precedent). One fix after the first
  targeted run: the `default -> Float.NaN; //gets converted to null
  in logic` comment expr was split across two lines and failed the
  state test's assertIn — rejoined onto one line, sentence restored.
- Proof scene written: `C07LaunchPadSenseProgressProof.gd` / `.tscn`
  (pure-function pattern, N2203 shape). Proof JSON 9 keys (6 semantic
  + matches + 2 harness), `matches: true`, 0 false (refreshed by the
  green-log targeted re-run ~09:4x; .json is git-ignored, never
  stage).
- Register script written
  (`register_c07_launch_pad_sense_progress.py`, N2205 pattern,
  DEFERRED carried by import from the N2205 register);
  `--verify` 22/22 EXACT_EXPRS (18 + 3 inputs + 1 output). Register
  run: SSOT 11428/1655/1576/2943 → **11429/1656/1577/2945** (+1
  symbol, +1 slice, +1 contract, +2 schemas input+result); audit
  1335 unchanged; no shard change (campaign, not defense — same as
  N2205). `git diff --check` clean.
- **Targeted 4/4 OK** in 13.446s (log
  `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2206-green.log`),
  Godot 4.6.2 on PATH, port 7777 FREE. **Family 12/12 OK** in 43.594s
  (N2172 power_status + N2205 should_consume + N2206 sense_progress,
  log `n2206-family.log`). **Wiring 32/32 OK** in 121.204s (9 modules:
  power_graph_live_update_binding, battery_power_status_binding,
  battery_placement_binding, power_graph_consumer_cheating,
  factory_live_loop, adjacent_factory_live_loop,
  unit_factory_live_loop, turret_live_loop,
  continuous_liquid_turret_live_loop; log `n2206-wiring.log`).
  **GREEN total 48/48.**
- Environment this run: VM restarted after the RED run (uptime 17 min
  at 09:31 — restart #21); javalang 0.13.0 importable (survived);
  port 7777 free; HEAD == origin/main == 7fac96a2.
- Function at `SourceLaunchPadBuildState.gd` after shouldConsume
  (:82); proof keys as pinned at RED; no driver line.

## Next: full gate (main thread), then report/spec/GOAL, push

- Full gate from the MAIN THREAD, godot NOT on PATH:
  `python3 -m unittest discover -s tests` from
  `tools/mindustry_godot_transpiler`, log
  `full-suite-n2206-gate.log`. Expected: Ran ~5917, failures ~156,
  skipped 5, 0 errors — all Godot-absent (extrapolated from N2205:
  Ran 5913, failures 155). Do NOT launch it from a worker run.
- Then report/spec/GOAL → slice commit + docs + GOAL + hash-naming
  commits → push (5-commit pattern).
- After N2206: LaunchPad updateTile advance (launchCounter advance +
  launch), then MassDriver sense(progress) / acceptItem, then the
  MassDriver updateTile split, then RepairTurret coolant, then
  Units.nearby live query.

## Next: GREEN N2206, then gate, push

- Implement `source_launch_pad_sense_state` in
  `SourceLaunchPadBuildState.gd` next to the shouldConsume function
  (NO driver line — N2203 precedent) → write proof .gd/.tscn (copy the
  N2205 proof shape, 6 keys) → register script (copy N2205 register;
  DEFERRED carry by import, NOT ast.literal_eval — N2205's DEFERRED is
  a computed expression) → register --verify (EXACT_EXPRS verbatim) →
  targeted 4/4 → proof headless (PATH export first, port 7777 free) →
  neighbours (family + wiring 32/32) → full gate from the main thread,
  godot NOT on PATH → report/spec/GOAL → slice commit `8db29088` + docs
  `13fe94f3` + GOAL `fca286e8` + hash-naming commits → push (5-commit pattern).

## Scope (verified against upstream Java + the port this run)

- **N2206 is the LaunchPad sense(progress) override, and nothing else.** One
  family (launch-pad + advanced-launch-pad share the implementation), one
  pure function (`source_launch_pad_sense_state`) in
  `SourceLaunchPadBuildState.gd`, one proof scene. It closes the exact
  observable gap the N2205 spec row names: sense(progress)
  (LaunchPad.java:98-101) is deferred — "needs the sense-dispatch hook".
  A logic processor reading `progress` on a launch pad currently gets
  NaN/null (the BuildingComp.sense default, BuildingComp.java:2123,
  `default -> Float.NaN; //gets converted to null in logic`), while Java
  returns the clamped launch fraction `Mathf.clamp(launchCounter /
  launchTime)` (LaunchPad.java:99).
- **Why this item, why now:** the next deferred item after N2205 per the
  N2205 handoff ("After N2205: LaunchPad sense(progress), then LaunchPad
  updateTile advance..."), and the smallest deferred row left in the
  LaunchPad group: one formula over one frame key (`launch_counter`,
  already read by the N2205 gate) plus the per-def `launchTime` the N2205
  driver already selects. It needs no new frame key, no inventory state,
  no entity spawn, and no sense-dispatch change in this slice (see the
  scope decision below).
- **Scope decision — pure function only, NO dispatch hook in this slice:**
  the N2205 spec row says sense "needs the sense-dispatch hook", but the
  minimal faithful slice is the pure function + tests + proof, following
  the N2203 damage() precedent (event-driven, NO driver tick line — the
  proof calls the pure function directly with synthetic frames). Sense is
  a logic read, not a tick write: no `source_launch_pad_tick_buildings_state`
  line belongs here (verified: the driver at
  SourceLaunchPadBuildState.gd:143 contains no sense call, and the file's
  only sense mentions are the :129-130 deferred-row comment). The
  logic-processor integration — how a logic `sense progress` read on a
  placed launch pad reaches the family function — is its own later slice
  with a documented limit. Do NOT extend the generic
  `SourceBlockSenseState.laccess_state`: it is the Block-level sense
  (Block.java:1651-1664), takes no frame/launch-counter input, and adding
  family state there would break its generic shape; the BuildingComp
  sense bridges are likewise the wrong layer (they port the BuildingComp
  switch, which has no progress case by design).
- **Precedent:** the per-family pure-function pattern is established —
  N2201 BuildTurret, N2205 LaunchPad shouldConsume
  (`source_launch_pad_should_consume_state(frame, launch_time)`),
  N2203 ShieldWall damage. N2206 follows it exactly: pure function +
  targeted 4 tests + proof with 6 semantic keys (N2201 shape). It is the
  FIRST live per-family sense(progress) override in the port: MendProjector
  carries the same Java shape (`if(sensor == LAccess.progress) return
  Mathf.clamp(charge / reload);`, MendProjector.java:126-129) only as
  source-text constants
  (`SourceMendProjectorSourceTextState.gd:10-11`, tested by
  test_mend_projector_source_text_slice.py) — no live pure function, no
  proof scene. If N2206's shape works, it becomes the precedent for
  MassDriver sense(progress) (`Mathf.clamp(1f - reloadCounter)`,
  MassDriver.java:224-228) and ShockwaveTower sense(progress)
  (`reloadCounter / reload`, ShockwaveTower.java:110 — unclamped, its own
  slice).
- **Frame key:** reuses `launch_counter`, already read by the N2205 gate
  with the absent → "no observation yet" default. No new frame key, no
  SOURCE_CONSUMER_FRAME_META_KEYS change, no simulate_factory wiring
  change, no shard change (campaign, not defense — same as N2205).
- **Per-def launchTime:** reuse `SOURCE_LAUNCH_PAD_LAUNCH_TIMES`
  (launch-pad 1200.0, advanced-launch-pad 1800.0, class default 1.0) —
  the N2205 driver already selects it by block id; the pure function
  takes it as a parameter, mirroring
  `source_launch_pad_should_consume_state(frame, launch_time)`.
- **SSOT baseline re-verified from the generated JSONs this run**
  (origin/main 7fac96a2, N2205 DONE + PUSHED): symbols **11428** + slices
  **1655** + contracts **1576** + schemas **2943**; audit
  `totalSourceFunctions` 1335; N2206 NOT in the ledger yet. The N2205
  register pattern adds +1/+1/+1/+2 (verify at RED — the N2172 register
  added two schemas, not one).
- **Environment (checked this run):** port 7777 FREE; javalang 0.13.0
  importable (no reinstall needed; uptime 41 min — VM restart #20 was
  ~08:20, no restart since); Godot binary exists at
  `~/workspace/godot-bin/godot` (4.6.2-stable, symlink) but is NOT on PATH
  in the worker shell — the GREEN proof run must export
  `PATH="$HOME/workspace/godot-bin:$PATH"` first (the N2177 lesson), and
  the full gate must run with godot NOT on PATH, launched from the main
  thread (worker-launched gates die with the session — 10 recorded
  deaths). Worktree clean except pre-existing untracked `*.gd.uid` noise
  + old `full-suite-*.log` files (never stage). HEAD 7fac96a2.
- **Expected shape (estimate, verify at each step):** targeted 4/4;
  proof 6 semantic keys + `matches` + 2 harness keys; neighbours family
  + wiring 32/32; full gate Ran ~5917, failures ~155, skipped 5,
  0 errors — all Godot-absent (extrapolated from N2205: Ran 5913,
  failures 155). Files to write:
  `tools/mindustry_godot_transpiler/tests/test_c07_launch_pad_sense_progress.py`,
  `tools/mindustry_godot_transpiler/register_c07_launch_pad_sense_progress.py`
  (copy the N2205 register),
  `godot-mindustry/tools/runtime_proofs/C07LaunchPadSenseProgressProof.gd` / `.tscn`,
  this handoff, design-spec row, GOAL.md pointer (5-commit pattern).

## Java source evidence (all verified verbatim this run — grep 2026-11-16 ~09:0x)

- `public double sense(LAccess sensor){` (LaunchPad.java:98) +
  `if(sensor == LAccess.progress) return Mathf.clamp(launchCounter / launchTime);`
  (LaunchPad.java:99) + `return super.sense(sensor);` (LaunchPad.java:100)
- `public float launchCounter;` (LaunchPad.java:84)
- `public float launchTime = 1f;` (LaunchPad.java:32) — class default; defs
  override it (launch-pad 1200f, Blocks.java:6794; advanced 1800f,
  Blocks.java:6804)
- `progress,` (LAccess.java:28) — the sensor enum value
- `public double sense(LAccess sensor){` (BuildingComp.java:2093) — the
  super switch has NO `progress` case; `default -> Float.NaN; //gets
  converted to null in logic` (BuildingComp.java:2123)
- `public float progress(){` + `return 0f;` (BuildingComp.java:617-619) —
  a DIFFERENT method, NOT used by sense (the sense switch never calls
  progress()); do not confuse the two. `totalProgress()` returns
  Time.time (BuildingComp.java:612-615), also unrelated.
- `Mathf.clamp(x)` one-arg = clamp to [0, 1]. GDScript spelling is
  `clampf(value, 0.0, 1.0)` — precedent SourceShockwaveTowerBuildState.gd:306.
- Same expression drives the progress bar (LaunchPad.java:70,
  `Mathf.clamp(build.launchCounter / launchTime)`) and the draw lights
  use the unclamped fraction (LaunchPad.java:116,
  `Math.min((float)items.total() / itemCapacity, launchCounter / launchTime)`).
- MassDriver sense for contrast (own slice, NOT this one):
  MassDriver.java:224-228, `Mathf.clamp(1f - reloadCounter)` — needs a
  `reload_counter` frame key the port does not track.
- ShockwaveTower sense for contrast (own slice, NOT this one):
  ShockwaveTower.java:110, `if(sensor == LAccess.progress) return
  reloadCounter / reload;` — UNCLAMPED, unlike LaunchPad/MendProjector.

## Port evidence (all verified this run)

- `SourceBlockSenseState.laccess_state` (Block.java sense) handles
  color/health/solid/size/itemCapacity/liquidCapacity/powerCapacity/id,
  default NaN — NO "progress" case (grep: zero hits).
- `SourceBuildingSenseState` + `SourceBuildingSensePortBridge.gd` split
  the BuildingComp sense switch into position / health-process / totals /
  capacity-power-net / enabled-controlled / payload-size / camera-default /
  object bridges — none takes a `progress` sensor, none takes a frame.
  No caller of `source_block_sense_laccess_state` exists outside the
  bridge files; sense is invoked via bridges only.
- No live per-family sense override exists anywhere in the port (grep
  `LAccess.progress` in src/game: only the LaunchPad :129-130 comment
  and the MendProjector source-text constants).
- `SourceLaunchPadBuildState.gd:129-130` already documents this row:
  "# (LAccess.progress) reads the same counter (LaunchPad.java:98,
  `if(sensor == LAccess.progress) return Mathf.clamp(launchCounter /
  launchTime);`)" — inside the N2205 shouldConsume comment.
- `SourceLaunchPadBuildState.gd` is 197 lines; driver
  `source_launch_pad_tick_buildings_state` at :143; shouldConsume pure
  function at :82. The new pure function goes in the same file, next to
  the shouldConsume function.
- N2205 test/register files to copy:
  `tools/mindustry_godot_transpiler/tests/test_c07_launch_pad_should_consume.py`
  and `tools/mindustry_godot_transpiler/register_c07_launch_pad_should_consume.py`
  (N2172 power-status register alongside).

## Open RED decisions (DECIDED at RED 2026-11-16 ~09:2x — pinned in the
RED section above; GREEN implements exactly that, do not re-decide)

1. **Pure-function signature + fall-through wire shape.** Candidate:
   `source_launch_pad_sense_state(frame, sensor, launch_time)` mirroring
   the N2205 gate. For `sensor == "progress"` it returns the clamped
   fraction; for any other sensor it must signal "not handled — fall
   through to super.sense". Decide at RED whether the wire is
   `{"handled": false, "sense_value": null}` (a new flag) or the generic
   `laccess_state` NaN wire (`sense_value: null` +
   `sense_value_is_nan: true`). Either way the proof must pin the
   fall-through case (e.g. sensor "health" → not handled), because Java
   delegates non-progress sensors to super.sense.
2. **Absent `launch_counter` default — genuine tension, decide at RED and
   pin in the proof.** Option A (Java-init-faithful): absent → 0.0,
   because `public float launchCounter;` defaults to 0.0f in Java, so a
   freshly built pad senses 0.0. Option B (N2205 absent-means-"no
   observation yet" precedent): absent → NaN/null, preserving the
   current port behavior (generic sense returns NaN for unhandled
   sensors) until the future updateTile advance stamps `launch_counter`
   live. Note the asymmetry with N2205: there, absent → `enabled`
   preserved a GREEN behavior; here, absent → 0.0 ALSO preserves the
   only observable Java behavior at init, while absent → NaN preserves
   the port's current (unfaithful) output. RED must pick one, justify it
   against both precedents, and pin it with a dedicated test + proof key.
   Do NOT default absent to 1.0 or to launchTime (that would claim a full
   counter with no observation).
3. **Sensor string spelling.** The generic sense takes `sensor: String`
   ("color", "health", ...). RED must verify what string the logic
   layer passes for LAccess.progress ("progress") and use exactly that —
   do not invent a variant. Check how existing sense tests spell sensor
   names before writing the tests.
4. **Clamp edge:** `launch_counter` above `launch_time` (counter full,
   waiting for items) → clamp to 1.0; counter 0 → 0.0; negative counter
   cannot occur in Java (counter only grows and resets to 0) but clamp
   floors it to 0.0 anyway — pin the ≥ launchTime → 1.0 case in tests +
   proof (it is the observable state of a full pad).

## Why not the other deferred items

- **LaunchPad updateTile** (LaunchPad.java:143-161): launchCounter
  advance + consume() + LaunchPayload entity spawn + items.clear +
  sound/Fx — the entity spawn is a new subsystem, and it needs an
  items.total frame input. Own slice(s) after the gate — it is also the
  slice that will start stamping `launch_counter` live, which is what
  makes the N2206 absent-default decision observable.
- **LaunchPad acceptItem** (LaunchPad.java:138-140): needs items.total +
  first item + acceptMultipleItems — inventory frame state the port does
  not track yet.
- **LaunchPad liquid consumer row** (advanced-launch-pad consumeLiquid oil
  9f/60f, Blocks.java:6808): second consumer on one def — own slice.
- **LaunchPad draw / read-write / config-display** (LaunchPad.java:104-140
  / 211-222 / 164-...): presentation / serialization / campaign sector
  config — each its own slice.
- **MassDriver sense(progress)** (MassDriver.java:224-228): same
  sense-dispatch question as N2206 but needs a `reload_counter` frame
  key the port does not track; take it after N2206 establishes the
  per-family sense shape.
- **MassDriver acceptItem / updateTile split / fire / handlePayload /
  link / config / read-write / draw:** per the N2205 handoff — each its
  own slice, after the LaunchPad rows.
- **RepairTurret coolant, Units.nearby live query:** still deferred after
  the MassDriver/LaunchPad rows, per the N2204 Next order.

## Next: RED N2206, then GREEN, gate, push

- Write RED tests first (4 targeted: progress fraction below launchTime;
  counter at/above launchTime → 1.0; non-progress sensor → fall-through;
  absent launch_counter → the decided default) → confirm classic RED
  failure (missing pure function) → implement
  `source_launch_pad_sense_state` (NO driver line — N2203 precedent) →
  register --verify (EXACT_EXPRS verbatim in upstream) → targeted 4/4 →
  proof headless (PATH export first, port 7777 free) → neighbours
  (family + wiring 32/32) → full gate from the main thread, godot NOT on
  PATH → report/spec/GOAL → slice commit + docs + GOAL + hash-naming
  commits → push (5-commit pattern).
- After N2206: LaunchPad updateTile advance (launchCounter advance +
  launch), then MassDriver sense(progress) / acceptItem, then the
  MassDriver updateTile split (reload drain → state transitions → fire),
  then RepairTurret coolant, then Units.nearby live query.

## GREEN verification + gate (main thread, ~09:41 +07)

- GREEN verified by main thread: targeted re-run Ran 4 OK in 14.497s; family log Ran 12 OK (43.594s); wiring log Ran 32 OK (121.204s). GREEN total 48/48. Proof JSON 9 keys (6 semantic + matches + 2 harness), matches:true, 0 false. Register --verify 22/22 exprs present, exit 0.
- Function `source_launch_pad_sense_state(frame, sensor, launch_time)` at :142 (no driver line, N2203 event-driven precedent — sense is a query, not a tick). SSOT 11429/1656/1577/2945 (symbols +1, ledger +1, contracts +1, schema +2; audit 1335).
- VM restart #21 ~09:14 (uptime 27 min at the 09:41 check) — javalang survived this one, no reinstall needed.
- Gate (main thread, PID 4429, SID 4429, ~09:41): godot NOT on PATH, javalang OK, log fresh and growing (dots + F's only, 291 bytes at launch check). Parent subshell PID 4426 stays alive. Expected: Ran ~5917, failures ~156, skipped 5, 0 errors.
