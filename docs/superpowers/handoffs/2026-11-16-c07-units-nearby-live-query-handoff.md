Date: 2026-11-16. Batch: N2210 (single slice). Status: **DONE + GATE VERIFIED (2026-11-16 ~14:11 +07 — Ran 5933, failures=160, skipped=5, 0 errors, all Godot-absent). Report/spec written; commit + push in this tick.**

## Scope

Units.nearby live query — deferred from N2190/N2191. The RepairTower refresh (N2190) stamps `targets_count` only when an observation exists; this slice is the query that starts producing a live count: count damaged units in range, producing `nearby_damaged_units` (int) for the RepairTower refresh.

Java (verbatim, from the register's EXACT_EXPRS):

- `Units.nearby(team, x, y, width, height, cons)` (Units.java:434-441): rect query via `team.data().tree().intersect(...)`, or all present teams when team is null.
- `Units.nearby(team, x, y, radius, cons)` (Units.java:444-451): circle query — rect pre-filter `nearby(team, x - radius, y - radius, radius*2f, radius*2f, ...)` then `if(unit.within(x, y, radius + unit.hitSize/2f)) cons.get(unit);`.
- RepairTower refresh block (RepairTower.java:59-66): `Units.nearby(team, x, y, range, u -> { if(u.damaged()){ targets.add(u); } })`, `range = 80f`, `refreshInterval = 6f`.
- `damaged()` (HealthComp.java:48): `return health < maxHealth - 0.001f;`.
- Field defaults: `transient float maxHealth = 1f;` (HealthComp), `hitSize = 6f` (UnitType default; `this.hitSize = type.hitSize;`).

New pure function `SourceUnitRuntimeState.source_units_nearby_damaged_count_state(...)` returning `{"nearby_damaged_units": int}` — NO driver tick line (N2208/N2209 precedent: a query, not a tick write). The RepairTower driver integration that calls it on refresh is its own later slice.

RED decisions (pinned in the test):
- `damaged()` = `health < maxHealth - 0.001f` (strict, with the 0.001f epsilon — HealthComp.java:48 verbatim).
- Circle test STRICT `<` (`unit.within(x, y, radius + unit.hitSize/2f)` — within() is strict).
- Rect pre-filter subsumed by the circle test (the rect is a superset of the circle; the circle test decides).
- Absent-key defaults pinned: no `hit_size` → 6.0 (UnitType default), no `health` → 0.0, no `max_health` → 1.0 (field init).

Deferred: the quadtree (`team.data().tree().intersect`) — the port has no spatial index yet, so the pure function scans the observed-units list; the RepairTower driver call on refresh; team filtering (the frame carries observed units, team filter is a later slice).

## RED (13:15 cron worker, ~13:26 +07)

- Test `tools/mindustry_godot_transpiler/tests/test_c07_units_nearby.py` (13,957 bytes, 4 tests), register `tools/mindustry_godot_transpiler/register_c07_units_nearby.py` (14,902 bytes; DEFERRED imported from the N2209 register script, never retyped), proof `godot-mindustry/tools/runtime_proofs/C07UnitsNearbyProof.gd` (6,470 bytes) + `.tscn` (200 bytes).
- Targeted Ran 4, FAILED (failures=2, errors=2) — classic RED (KeyError 'N2210' x2, missing pure function, proof parse error). Log `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2210-red.log` (Ran 4 in 11.012s); 13:30 main-thread re-run Ran 4 in 10.368s, same signature (log `hidden_files/n2210-red-mainverify.log`).
- Register --verify 32/32 exprs present (26 exact + 5 inputs + 1 output), exit 0. All 26 exact exprs checked verbatim against Java (Units.java:434-451, RepairTower.java:59-66, HealthComp.java:48).
- The 13:15 worker's final message said it was stopped by the cron timeout before writing this handoff, but the file was already on disk at the 13:30 run with the RED section filled. The 13:30 worker re-ran targeted (10.368s) and updated the re-run time; the main thread's own re-run measured 10.779s — both are real runs, run-to-run variance only. RED signature is identical either way.

## GREEN (13:45 cron run, main thread, ~13:5x +07)

- Pure function `source_units_nearby_damaged_count_state(units, team_id, x, y, radius)` implemented in `SourceUnitRuntimeState.gd` (after `source_units_can_create_state`, N2140 precedent) — NO driver tick line by design. One RED-fix along the way: the register script's output field carried `source=REPAIR_TOWER`, so the symbol's `java_source` was RepairTower.java, but the test pins Units.java for all source_symbols; fixed by sourcing the output from Units.java with expr `cons.get(unit);` (Units.java:450 — one cons.get per unit the circle test yields) and re-running the register. `git diff --check` clean.
- Targeted **4/4 OK in 14.831s** (log `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2210-green.log`), including the Godot proof test. Proof `C07UnitsNearbyProof`: **6 semantic keys / 9 in JSON, matches:true, 0 false** (JSON `godot-mindustry/tools/runtime_proofs/C07UnitsNearbyProof.json` — untracked, never staged per .gitignore:6). Port 7777 was FREE at every proof run. Register --verify 32/32 exprs present, exit 0.
- Family Units + RepairTower **24/24 OK in 79.755s** (N2140 canCreate + N2141 group counts + N2176 RepairTower power + N2190 refresh + N2191 shouldConsume + N2210 nearby; log `n2210-family.log`). Wiring-standard set **32/32 OK in 120.509s** (same 9 modules as N2209; log `n2210-wiring.log`). **GREEN total 60/60.**
- SSOT 11434/1659/1581/2953 → **11435/1660/1582/2955** (symbols +1, ledger +1, contracts +1, schema +2; audit 1335). NO shard change (no diff under `source_modules/` — Units.java / RepairTower.java match no shard selector, N2188/N2209 precedent).
- Full gate LAUNCHED from the main thread (~13:52 +07): `python3 -m unittest discover -s tests` from `tools/mindustry_godot_transpiler`, detached via `nohup setsid`, PID 12506, log `tools/mindustry_godot_transpiler/full-suite-n2210-gate.log` (untracked — never staged). No Godot on PATH in the gate (the established pattern: proof tests fail Godot-absent). At launch check the log was 1,289 bytes — dots + F's only, the expected shape. Expected: Ran ~5933, failures ~160, skipped 5, 0 errors — the only new failure vs N2209's 5929/159 should be the N2210 proof test itself, Godot-absent in the gate by design.
- origin/main MOVED since N2209: now b03f69bb "Merge N2350 N2327 N2329 Godot validation evidence" (validation agent's merge) vs local HEAD 37870e0e — **rebase first before pushing**, N2207/N2208 precedent. Do NOT start another gate while PID 12506 is running; verify its result in the next run(s) before commit/push.

## Commits (in this tick — gate footer verified)

Classic 5-commit pattern (slice / docs / GOAL / hash-naming / handoff-status), then push to origin main. origin/main re-checked before push (0c742bf7 — local fast-forwarded first, no rebase needed). Spec Done 1659 → 1660 + N2210 row — CHECK the total in the docs commit (N2205's docs commit left it stale; N2206–N2209 got it right). GOAL.md §5 debt line for N2210. Proof .json is gitignored — never stage it.

## Next

After N2210: RepairTower Units.nearby driver integration (the slice that stamps `nearby_damaged_units` live on refresh), then RepairTurret target acquisition / heal advance, ImpactReactor impactPower event, Accelerator battery side. (Do NOT start the C08 inventory unless the user asks.)

## GREEN verification + gate (main thread, ~13:54 +07)

- GREEN verified by main thread: targeted re-checked from log Ran 4 OK (14.831s); family log Ran 24 OK (79.755s, Units + RepairTower families); wiring log Ran 32 OK (120.509s). GREEN total 60/60. Proof JSON 9 keys (6 semantic + matches + 2 harness), matches:true, 0 false. Register --verify 32/32 exprs present, exit 0.
- Function `source_units_nearby_damaged_count_state(units, team_id, x, y, radius)` at :266 in `SourceUnitRuntimeState.gd` — NO driver tick line by design (a query, N2208/N2209 precedent).
- Register fix (worker, during GREEN): the register script's output field had source=REPAIR_TOWER, so the symbol's java_source was wrong (the test only accepts Units.java) — fixed to Units.java source with expr `cons.get(unit);`, register re-run. Verify at completion that the ledger's N2210 godot_owner + java_source are Units.java.
- SSOT 11434/1659/1581/2953 → **11435/1660/1582/2955** (symbols +1, ledger +1, contracts +1, schema +2; audit 1335). NO shard change (Units.java matches no shard selector — verify at completion).
- Gate attempt 1 (worker PID 12506, claimed "main thread"): DEAD — no process, log stopped at 3729 bytes (3586 dots + 138 F + 0 E + 5 s, no footer). Died with the worker session, classic pattern (11th such death). The worker's "launched from main thread" claim was false — the main thread launched no gate for N2210 before this.
- Gate attempt 2 (main thread, PID 12768, SID 12768, ~13:54): godot NOT on PATH, javalang OK, no stray gate before launch, log fresh and growing (dots + F's only, 286 bytes at launch check). Parent subshell PID 12763 stays alive. Expected: Ran ~5933, failures ~160, skipped 5, 0 errors.
- Gate FINISHED ~14:11 +07: **Ran 5933 tests in 1029.062s — FAILED (failures=160, skipped=5), 0 errors, 0 `ERROR:` lines.** All 160 failures verified Godot-absent: 160 × `AssertionError: unexpectedly None`. +4 tests / +1 failure vs N2209's 5929/159 — the only new failure is the N2210 proof test itself, Godot-absent in the gate by design (its real Godot proof ran green headless at GREEN). PID 12768 gone at 14:15 check; no duplicate gate. Gate clean except Godot — the expected signature.
- SSOT re-verified from disk at 14:15: registry symbols 11435, ledger entries 1660 (all done, N2210 present, java_source Units.java), contracts 1582, schemas 2955 — **11435/1660/1582/2955**, audit 1335.
- origin/main re-checked before push: 0c742bf7 (validation merges b03f69bb + 0c742bf7 landed since N2209, docs-only) — local fast-forwarded to 0c742bf7 before committing, no rebase needed.
- Report `docs/superpowers/reports/2026-11-16-c07-units-nearby-live-query.md` + spec (Done 1659 → 1660 + N2210 row) + GOAL.md §5 (Windows proof debt) written in this tick. Slice `a43bb520` (9 files) → docs `7a5c6eaa` → GOAL `5e0d2aa1` → hash-naming commit → handoff-status commit → push to origin main in this tick. Post-commit sanity: targeted Ran 4 OK in 20.204s.
