# Report — N2217: RepairTurret read/write persistence (RepairTurret.java:236-254, C07)

Date: 2026-11-16. Batch: N2217 (single slice). Status: **DONE + GATE VERIFIED (2026-11-16 ~22:2x +07 — targeted 4/4, family 32/32, wiring 32/32; full gate Ran 5961, failures=167, skipped=5, 0 errors, all 167 verified Godot-absent). Slice (this commit) / docs (this commit) / GOAL (next commit). Ready to push (origin/main bccb6fb0 — no movement since the N2216 push, no rebase needed).**

## What changed

N2216 is DONE + PUSHED (main bccb6fb0); this slice persists the RepairTurret's rotation — the piece the N2216 handoff named ("RepairTurret read/write persistence / drawBeam rows, per backlog"). Java: `public void write(Writes write){ super.write(write); write.f(rotation); }` (RepairTurret.java:236-239), `public void read(Reads read, byte revision){ super.read(read, revision); if(revision >= 1){ rotation = read.f(); } }` (:243-248), `public byte version(){ return 1; }` (:252-254). No gameplay change; slice committed in this tick, docs + push below.

What N2217 adds (9 files, NO shard change):

- **Two new pure functions + one const.** `SourceRepairTurretBuildState.source_repair_turret_write_state(frame)` (:286) — returns `{"rotation": float(frame.get("rotation", 90.0))}`. `source_repair_turret_read_state(frame, saved_rotation, revision)` (:303) — returns `{"rotation": saved_rotation if revision >= 1 else float(frame.get("rotation", 90.0))}`: a revision-0 save leaves the turret pointing where it already points. `const REPAIR_TURRET_SAVE_VERSION := 1` (:284). The version is a CONST, not a function: Java version() takes no parameters, and the SSOT schema validator requires every schema entry to carry non-empty keys, so a zero-input function could not be registered — the const pins the `return 1;` fact. Rotation default 90.0 is the field default (`public float strength, rotation = 90;`, RepairTurret.java:156). Both defs share RepairPointBuild (repair-point, powerUse 1f, Blocks.java:6391; repair-turret, powerUse 5f, Blocks.java:6402), so one set of functions covers both.
- **NO driver tick line.** Persistence is not a per-tick call, and the port has no save/load stream to call these functions yet — wiring them into a save/load path waits for a persistence-integration slice (deferred). The ConstructBuildIo precedent likewise has pure read/write functions with no live caller (only a preload).
- **Test module + register script** `test_c07_repair_turret_read_write.py` + `register_c07_repair_turret_read_write.py`. SSOT baseline re-verified from disk: 11450/1666/1589/2969, audit 1335. After GREEN: **11452/1667/1591/2973** (+2/+1/+2/+4), audit 1335. NO shard change (RepairTurret family is not in the power shards — N2213/N2214/N2215 precedent; verified from `git status` at completion). Correction to the RED expectation: the 4th tuple number counts schema ENTRIES, not keys — N2217 adds 4 entries (write 1 input + 1 result, read 3 inputs + 1 result... actually write input + write result + read input + read result), so 2969 + 4 = 2973, not 2975.
- **Proof scene** `C07RepairTurretReadWriteProof.gd` (+ `.tscn`, `.json` untracked per .gitignore:6). 8 semantic keys: write returns current rotation 145.5 / write defaults to 90.0 when absent / write returns only rotation (result size == 1) / read restores saved 200.0 at revision 1 / read restores saved 33.0 at revision 2 / read keeps current 145.5 at revision 0 / read defaults to 90.0 when absent and revision 0 / version is 1.
- **Handoff** `docs/superpowers/handoffs/2026-11-16-c07-repair-turret-read-write-handoff.md` — design, RED decisions, Java evidence, scope, gate result.

## RED → GREEN (21:15 cron worker; verified by main thread ~21:47 +07; re-verified 22:15 cron run)

Targeted RED: Ran 4, failures=2, errors=2 — classic RED (KeyError 'N2217' ×2, missing `source_repair_turret_write_state` / `source_repair_turret_read_state` / `REPAIR_TURRET_SAVE_VERSION`). GREEN: targeted **4/4 OK in 29.171s** (worker, log `n2217-green.log` was NOT written then). Main-thread re-run **4/4 OK in 26.018s** (live Godot proof). Post-gate re-run: **4/4 OK in 17.643s** (log `hidden_files/n2217-green.log`). Register --verify 19/19 exprs present (13 exact + 6 inputs/outputs), exit 0. Proof JSON 11 keys (8 semantic + matches + 2 harness), matches:true, 0 false, Godot headless 4.6.2-stable Linux in this VM.

## Family/wiring (21:30 cron worker; verified by main thread ~21:47 +07)

Family RepairTurret **32/32 OK in 205.240s** (N2174 + N2188 + N2209 + N2212 + N2213 + N2214 + N2215 + N2217; log `n2217-family.log`). Wiring-standard set **32/32 OK in 234.653s** (same 9 modules as N2215; log `n2217-wiring.log`). **GREEN total 68/68.** Port 7777 free before every proof run; no parallel run active. Cron 21:30 timed out after 900s before launching the gate — main thread launched it (see below). No VM restart during this slice (uptime 1:56 at completion, restart #26 ~20:20; javalang 0.13.0 OK throughout).

## Gate (VERIFIED 2026-11-16 ~22:2x +07)

Full gate `python3 -m unittest discover -s tests` launched from the MAIN thread (PID 9745, SID 9745, ~21:47; godot NOT on PATH, javalang OK). Finished: **Ran 5961 tests in 1930.762s — FAILED (failures=167, skipped=5), 0 errors.** All 167 failures verified Godot-absent: 167 × `AssertionError: unexpectedly None` (plain `assertIsNotNone(godot)`), zero `ERROR:` lines in the log. +4 tests / +1 failure vs N2216's 5957/166: the 4 new N2217 tests; the +1 failure is the new N2217 proof test, also Godot-absent in the gate (its real Godot proof ran green headless at GREEN and again in the post-gate targeted re-run). No failure names any N2217 function except that one proof test. Gate clean except Godot — the expected signature. Log `tools/mindustry_godot_transpiler/full-suite-n2217-gate.log` (untracked, never staged). `git diff --check` clean.

## PUSH (in this tick)

Gate verified: report → spec (Done/ledger 1666 → 1667 + N2217 row) → GOAL.md §5 (Windows proof stays debt). Slice commit (9 files, no shard change) → docs + GOAL → hash-naming commit → handoff-status commit → push to origin main in this tick (origin/main bccb6fb0 — no movement since the N2216 push; re-checked before push).

## Deferred (NOT this slice)

- Persistence integration (wiring read/write into a save/load stream) — waits for a persistence-integration slice.
- RepairTurret drawBeam/draw, config-display, sense rows — separate slices.
- Accelerator battery side — next candidate per backlog.
- Windows Godot proof — debt in GOAL.md §5, same as N2216.
- C08 inventory — NOT started unless the user asks.

## Commits

- Slice: (this commit)
- Docs: (this commit)
- GOAL: (next commit)
