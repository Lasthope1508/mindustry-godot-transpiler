# Handoff — N2217 RepairTurret read/write persistence (C07)

## Status: DONE + PUSHED (slice 7b7bd0a8, main c960823a).

## GREEN (21:30 +07 run)

- GREEN code added: `const REPAIR_TURRET_SAVE_VERSION := 1` +
  `source_repair_turret_write_state` + `source_repair_turret_read_state`
  in `godot-mindustry/src/game/SourceRepairTurretBuildState.gd` (after
  the N2215 strength-lerp function, before the driver). NO driver tick
  line (per RED scoping).
- Register (NOT --verify) run: N2217 in the ledger, status "done",
  both result symbols present. Register --verify re-run 21:45: 19/19
  exprs present, exit 0.
- Family RepairTurret 32/32 OK (205.240s, log
  `hidden_files/n2217-family.log`, 21:40 +07); wiring-standard 32/32
  OK (234.653s, log `hidden_files/n2217-wiring.log`, 21:44 +07).
  Both runs include the 4 N2217 tests (family = 8 slices x 4; wiring
  = 9 modules / 32 tests), so targeted 4/4 is covered — but no
  standalone `n2217-green.log` exists yet; main thread should run one
  clean targeted 4/4 after the gate for the record.
- SSOT after register: 11452/1667/1591/2973. CORRECTION to the RED
  expectation (2975): the 4th tuple number counts schema ENTRIES,
  not keys — N2217 adds 4 entries (write input/result, read
  input/result), so 2969 + 4 = 2973 is correct. Symbols +2, ledger
  +1, contracts +2, all as expected. NO shard change (RepairTurret
  family not in the power shards; verify at completion).
- `git diff --check` clean (verified 21:45). Uncommitted diff: 5
  files, +522 insertions (state .gd + 4 generated JSONs). The
  `.gd.uid` files in `git status` are workspace noise — never stage.
- Gate (full suite, `python3 -m unittest discover -s tests`,
  launched ~21:46-21:47 +07, apparently by the main thread):
  at 21:48 +07, 3749/5961 marks, 143 F, 5 skipped, 0 E — on track
  (expected Ran ~5961, failures ~167, skipped 5, 0 errors, all
  Godot-absent). Do NOT launch a second gate; do NOT run proof
  scenes in parallel with it (port 7777).
- 22:11 +07 update (22:00 cron run): gate STILL RUNNING, PID 9745
  alive, elapsed 25:06, log 5641/5961 marks, 151 F, 0 E, 5 skipped.
  The tail is SLOW (5610 marks at 22:00 → 5641 at 22:11: the
  remaining tests are the slow Godot proof tests). Expected footer
  still Ran ~5961, failures ~167, skipped 5, 0 errors. Verify the
  footer from `tools/mindustry_godot_transpiler/full-suite-n2217-gate.log`
  (count F/E + the `Ran ... FAILED` line) before committing; do NOT
  assume the 151 F are all Godot-absent until the footer + a grep
  for `ERROR:` / non-`unexpectedly None` failures confirm it.
- 22:15 +07 update (22:15 cron run): gate STILL RUNNING, PID 9745
  alive, elapsed 29:40, log 5647/5961 marks (5496 dots + 151 F +
  5 s), 0 E, NO footer yet. Tail still slow (~6 marks in ~4 min).
  javalang 0.13.0 OK, no VM restart (uptime 1:57, restart #26
  ~20:20), port 7777 free at check moment, origin/main == HEAD ==
  bccb6fb0 (no movement; fetch only surfaced a new validation
  branch `codex/godot-wave26-batch3-report`, not main). SSOT
  re-verified from disk: 11452/1667/1591/2973, N2217 in ledger.
  NO commit/push yet — waits for the gate footer. NO targeted
  re-run yet (would collide with the running gate on port 7777).
- origin/main == HEAD == bccb6fb0 at 21:48 (no movement since N2216
  push). No VM restart (uptime 1:28, restart #26 ~20:20; javalang
  0.13.0 OK).

Next slice after N2216 (DONE + PUSHED, main bccb6fb0): the
RepairTurret read/write persistence — the piece the N2216 handoff
named ("RepairTurret read/write persistence / drawBeam rows, per
backlog"), before the Accelerator battery side.

## RED

- Test `tools/mindustry_godot_transpiler/tests/test_c07_repair_turret_read_write.py`
  (4 tests), register `tools/mindustry_godot_transpiler/register_c07_repair_turret_read_write.py`,
  proof `godot-mindustry/tools/runtime_proofs/C07RepairTurretReadWriteProof.gd` + `.tscn`.
- Targeted RED: Ran 4, failures=2, errors=2 — classic RED (KeyError
  'N2217' ×2 in the registration + exact-evidence tests, missing
  `source_repair_turret_write_state` / `source_repair_turret_read_state` /
  `REPAIR_TURRET_SAVE_VERSION` in the state test, the reference test
  fails on Godot parse errors — `Static function
  "source_repair_turret_write_state()" not found in base
  "SourceRepairTurretBuildState"` + `Cannot find member
  "REPAIR_TURRET_SAVE_VERSION"` + `Failed to load script`); log
  `hidden_files/n2217-red.log` (16.860s, re-run into the log file;
  first run 18.650s).
- Register --verify 19/19 (13 exact + 6 inputs/outputs), exit 0.
- javalang 0.13.0 OK at run start (no reinstall needed). Port 7777 free, no parallel run active. No VM restart during this run.

## Scoping pinned in RED (do not re-decide in GREEN)

- RepairPointBuild persists exactly ONE field, its rotation:
  `public void write(Writes write){` / `super.write(write);` /
  `write.f(rotation);` (RepairTurret.java:236-239), and restores it
  only for saves at revision >= 1: `public void read(Reads read,
  byte revision){` / `super.read(read, revision);` /
  `if(revision >= 1){` / `rotation = read.f();`
  (RepairTurret.java:243-248), because `public byte version(){`
  returns 1 (RepairTurret.java:252-254).
- Strength is NOT persisted: it is re-lerped every tick
  (`strength = Mathf.lerpDelta(strength, healed ? 1f : 0f, 0.08f *
  Time.delta);`, RepairTurret.java:212), so a loaded turret
  rebuilds it from 0. Target is NOT persisted either: it is
  re-acquired by the 20-tick timer (`target = Units.closest(team,
  x, y, repairRadius, Unit::damaged);`, RepairTurret.java:216).
  Write returns ONLY rotation (the proof checks the result has
  exactly one key).
- Two pure functions on the same family file N2174/N2188/N2209/
  N2212-N2215 built, plus one save-version const:
  - `source_repair_turret_write_state(frame)` returning
    `{"rotation": float(frame.get("rotation", 90.0))}`.
  - `source_repair_turret_read_state(frame, saved_rotation, revision)`
    returning `{"rotation": saved_rotation if revision >= 1 else
    float(frame.get("rotation", 90.0))}` — a revision-0 save leaves
    the turret pointing where it already points.
  - `const REPAIR_TURRET_SAVE_VERSION := 1`.
- The version is a CONST, not a function: Java version() takes no
  parameters, and the SSOT schema validator requires every schema
  entry to carry non-empty keys (`validate_source_state_schema`:
  "keys must be a non-empty object"), so a zero-input function
  could not be registered — the const pins the `return 1;` fact.
  (Verified this run: no empty-keys schema exists on disk; the
  ConstructBuildIo `version_state()` precedent was never registered
  in SSOT.)
- NO driver tick line: persistence is not a per-tick call, and the
  port has no save/load stream to call these functions yet —
  wiring them into a save/load path waits for a
  persistence-integration slice (deferred). The ConstructBuildIo
  precedent likewise has pure read/write functions with no live
  caller (only a preload).
- The rotation default is 90.0, the field default (`public float
  strength, rotation = 90;`, RepairTurret.java:156).
- Both defs share RepairPointBuild (repair-point, powerUse 1f,
  Blocks.java:6391; repair-turret, powerUse 5f, Blocks.java:6402),
  so one set of functions covers both.
- drawBeam is rendering only, not persistence — deferred to its own
  slice (no frame key).
- Proof math pinned (8 semantic keys): write returns the current
  rotation 145.5 / write defaults to 90.0 when absent / write
  returns only rotation (result size == 1) / read restores saved
  200.0 at revision 1 / read restores saved 33.0 at revision 2 /
  read keeps current 145.5 at revision 0 / read defaults to 90.0
  when absent and revision 0 / version is 1.
- SSOT before: 11450/1666/1589/2969 (verified from disk at RED).
  Expected after register: 11452/1667/1591/2975 (symbols +2,
  ledger +1, contracts +2, schema +6 — write 1 input + 1 result,
  read 3 inputs + 1 result; NO shard change expected — the
  RepairTurret family is not in the power shards, N2213/N2214/N2215
  precedent; verify at completion).

## GREEN plan

1. Add `const REPAIR_TURRET_SAVE_VERSION := 1` plus
   `source_repair_turret_write_state` and
   `source_repair_turret_read_state` to
   `godot-mindustry/src/game/SourceRepairTurretBuildState.gd`
   (after the N2215 strength-lerp function, before the driver) with
   the EXACT lines the test pins — signatures, the `var rotation`
   reads, the `if revision >= 1:` / `rotation = saved_rotation`
   guard, and the `return {"rotation": rotation}` verbatim. The
   function comments MUST contain, verbatim, every Java line the
   test asserts (write :236-239, read :243-248, version :252-254,
   field default :156, strength lerp :212, target acquire :216).
2. NO driver tick line (see scoping above).
3. Run register (NOT --verify) to add N2217 to SSOT, targeted GREEN
   4/4, family RepairTurret (N2174 + N2188 + N2209 + N2212 + N2213 +
   N2214 + N2215 + N2217, 32 tests), wiring-standard set (same 9
   modules / 32 tests as N2215), Godot proof (11 keys: 8 semantic +
   matches + 2 harness), full gate from the main thread only, then
   the classic 5-commit pattern + push. SSOT before:
   11450/1666/1589/2969.
4. Check port 7777 free before any proof run; never run proof scenes
   in parallel with another run. Check `git fetch origin` +
   origin/main before pushing (validation agent merges regularly).
   NOTE: godot is NOT on PATH in this shell — the binary lives at
   `~/workspace/godot-bin/godot`; GREEN must run the reference/proof
   tests with `PATH=~/workspace/godot-bin:$PATH`, otherwise the
   reference test fails with `godot is None`.

## Remaining (main thread)

1. Gate footer (running, PID 9745, ~21:46 +07) — expected Ran ~5961,
   failures ~167, skipped 5, 0 errors, all Godot-absent. Then one
   clean targeted 4/4 re-run into `hidden_files/n2217-green.log`
   (for the record; family + wiring already cover the 4 tests).
2. The classic 5-commit pattern + push (slice commit, docs commit,
   GOAL.md §5 Windows debt line, hash-naming commit, handoff-status
   commit). Check `git fetch origin` + origin/main before pushing
   (validation agent merges regularly). Stage exact slice files
   only (5 files above + handoff/report/docs); never stage
   `*.gd.uid`.

## After N2217

Accelerator battery side, or RepairTurret drawBeam rows, per
backlog. (Do NOT start the C08 inventory unless the user asks.)

## GREEN verification + gate (main thread, ~21:47 +07)

- GREEN verified by main thread: targeted re-run Ran 4 OK in 26.018s; family log Ran 32 OK (RepairTurret N2188+N2209+N2212+N2213+N2214+N2215+N2217); wiring log Ran 32 OK. GREEN total 68/68. Proof JSON 11 keys, matches:true, 0 false. Register --verify 19/19, exit 0.
- Pure functions `source_repair_turret_write_state(frame)` + `source_repair_turret_read_state(frame)` + const REPAIR_TURRET_SAVE_VERSION in `SourceRepairTurretBuildState.gd` (worker-implemented; cron timed out before gate).
- SSOT 11450/1666/1589/2969 → **11452/1667/1591/2973** (symbols +2, ledger +1, contracts +2, schema +4 — the worker's "schema +6" was wrong; disk says +4). N2217 in ledger. Shard change: verify at completion (check `git status` before staging).
- Handoff Status line above is STALE (still says RED) — fix at completion with the real Status.
- Gate (main thread, PID 9745, SID 9745, ~21:47): godot NOT on PATH, javalang OK, no stray gate before launch, log fresh and growing (dots + F only, 188 bytes at launch check). Parent subshell PID 9734 stays alive. Expected: Ran ~5961, failures ~167, skipped 5, 0 errors.

## Gate footer + completion (main thread, ~22:2x +07)

- Gate FINISHED: Ran 5961 tests in 1930.762s — FAILED (failures=167, skipped=5), 0 errors. All 167 failures verified Godot-absent: 167 × `AssertionError: unexpectedly None`, 0 `ERROR:` headers, 0 `ERROR:` lines. +4 tests / +1 failure vs N2216's 5957/166 — the 4 new N2217 tests; the +1 failure is the new N2217 proof test, Godot-absent in the gate (its real Godot proof ran green headless at GREEN and again in the post-gate targeted re-run). No failure names any N2217 function except that one proof test. Gate clean except Godot.
- Post-gate targeted re-run: Ran 4 OK in 17.643s, log `hidden_files/n2217-green.log` (closes the missing-log note from the 21:45 run).
- SSOT final: 11452/1667/1591/2973. NO shard change (verified from `git status` — no `source_modules/` diff). Slice commit: 9 files.
- origin/main == HEAD == bccb6fb0 at completion (no validation merge since the N2216 push; fetch showed only a new validation branch `codex/godot-wave26-batch3-report`). No rebase needed.

## Commits

- Slice: 7b7bd0a8 (C07: N2217 RepairTurret read/write persistence, 9 files)
- Docs: 4a6b665e (report + handoff + design spec, Done 1667 + N2217 row)
- GOAL: b55c7e37 (§5 Windows debt line for N2217)
- Hash-naming: (this commit)
- Handoff-status: (next commit)
