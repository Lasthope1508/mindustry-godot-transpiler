# Report — N2210: Units.nearby live query (Units.java:434-451, RepairTower.java:59-66, C07)

Date: 2026-11-16. Batch: N2210 (single slice). Status: **DONE + GATE VERIFIED (2026-11-16 ~14:11 +07 — targeted 4/4, family 24/24, wiring 32/32; full gate Ran 5933, failures=160, skipped=5, 0 errors, all 160 verified Godot-absent). Ready to push (origin/main 0c742bf7 — fast-forwarded before committing, no rebase needed).**

## What changed

N2209 is DONE + PUSHED (main 37870e0e); this tick finishes the Units.nearby live query — the next deferred item after N2209 per the N2209 report ("Units.nearby live query — still deferred after the RepairTurret coolant row"). Java: `Units.nearby(team, x, y, range, u -> { if(u.damaged()){ targets.add(u); } })` (RepairTower.java:59-66, `range = 80f`, `refreshInterval = 6f`) over the circle overload `Units.nearby(team, x, y, radius, cons)` (Units.java:444-451) — yet the port had no live count of damaged units in range, so the RepairTower refresh stamped `targets_count` only when an observation already existed. No gameplay change; slice committed in this tick, docs + push below.

What N2210 adds (9 files):

- **One pure function, no driver tick line** `source_units_nearby_damaged_count_state(units, team_id, x, y, radius)` (:266) in the EXISTING `SourceUnitRuntimeState.gd`, after the N2140 `source_units_can_create_state`. Returns `{"nearby_damaged_units": int}`: circle query — rect pre-filter subsumed by the circle test `unit.within(x, y, radius + unit.hitSize/2f)` (strict `<`); `damaged()` = `health < maxHealth - 0.001f` (HealthComp.java:48 verbatim, with the 0.001f epsilon). Absent-key defaults pinned: no `hit_size` → 6.0 (UnitType default), no `health` → 0.0, no `max_health` → 1.0 (field init). No driver tick line (N2208/N2209 precedent — a query, not a tick write); the RepairTower driver integration that calls it on refresh is its own later slice.
- **Test module + register script** `test_c07_units_nearby.py` + `register_c07_units_nearby.py` (N2209 pattern; register DEFERRED imported from the N2209 register script, never retyped). SSOT baseline re-verified from disk: 11434/1659/1581/2951, audit 1335. After GREEN: **11435/1660/1582/2955** (+1/+1/+1/+2, exactly as expected at RED), audit 1335. No shard change (no shard selection matches Units.java / RepairTower.java, N2188/N2209 precedent).
- **Proof scene** `C07UnitsNearbyProof.gd` (+ `.tscn`, `.json` untracked per .gitignore:6), N2208 pure-function proof shape. 6 semantic keys: count_damaged_same_team_inside / count_excludes_other_team / count_excludes_rect_corner_outside_circle / count_excludes_undamaged_inside / count_null_team_counts_all_teams / count_strict_boundary_excluded.
- **Handoff** `docs/superpowers/handoffs/2026-11-16-c07-units-nearby-live-query-handoff.md` — design, RED decisions (all pinned), Java evidence (32 exprs), scope, gate result.

## RED

Tests written first per the slice process (4 targeted: input evidence exact; registration; state; reference graph + actual incl. Godot proof). Targeted run: **Ran 4, FAILED (failures=2, errors=2) — classic RED** (log `n2210-red.log`): registration ERROR KeyError 'N2210' (register runs at GREEN); evidence ERROR KeyError 'N2210'; state FAIL missing `source_units_nearby_damaged_count_state`; proof FAIL Godot parse error (function not found yet). Main-thread re-run Ran 4 in 10.368s, same signature (log `n2210-red-mainverify.log`). Register --verify: **32/32 exprs present, exit 0** (26 exact + 5 inputs + 1 output). Port 7777 was FREE at run start. `git diff --check` clean.

## GREEN (2026-11-16 ~13:5x +07; main-thread verified ~13:54)

One pure function in `SourceUnitRuntimeState.gd` (:266). One RED-fix along the way: the register script's output field carried `source=REPAIR_TOWER`, so the symbol's `java_source` was RepairTower.java, but the test pins Units.java for all source_symbols; fixed by sourcing the output from Units.java with expr `cons.get(unit);` (Units.java:450 — one cons.get per unit the circle test yields) and re-running the register. `git diff --check` clean. Targeted GREEN **Ran 4 OK in 14.831s** (log `n2210-green.log`, includes the Godot proof run); family Units + RepairTower **24/24 OK in 79.755s** (log `n2210-family.log` — N2140 canCreate + N2141 group counts + N2176 RepairTower power + N2190 refresh + N2191 shouldConsume + N2210 nearby); wiring **32/32 OK in 120.509s** (9 modules; log `n2210-wiring.log`). **GREEN tổng 60/60**. Proof `C07UnitsNearbyProof.json` (9 keys: 6 semantic + matches + 2 harness), matches:true, 0 false, Godot headless 4.6.2-stable Linux in this VM. Register --verify 32/32 exprs present, exit 0. Port 7777 free at every proof run.

## Gate (VERIFIED 2026-11-16 ~14:11 +07)

Full gate `python3 -m unittest discover -s tests` launched from the MAIN thread (PID 12768, ~13:54; godot NOT on PATH, javalang OK). Finished: **Ran 5933 tests in 1029.062s — FAILED (failures=160, skipped=5), 0 errors, 0 `ERROR:` lines.** All 160 failures verified Godot-absent: 160 × `AssertionError: unexpectedly None` (plain `assertIsNotNone(godot)`). +4 tests / +1 failure vs N2209's 5929/159: the new N2210 proof test, also Godot-absent in the gate (its real Godot proof ran green headless at GREEN; same pattern as the N2209 coolant proof test already in the failure list). No failure names any N2210 function except that one proof test. Gate clean except Godot — the expected signature. Log `tools/mindustry_godot_transpiler/full-suite-n2210-gate.log` (untracked, never staged). Gate attempt 1 (worker PID 12506, claimed "main thread") DIED with the worker session — log stopped at 3729 bytes, no footer; the worker's claim was false, 11th such death on record. No duplicate gate this run (PID 12768 gone at 14:15 check).

## PUSH (in this tick)

Gate verified: report → spec (Done/ledger 1659 → 1660 + N2210 row) → GOAL.md §5 (Windows proof stays debt). Slice commit (9 files, fast-forwarded to origin/main 0c742bf7 first — validation merges b03f69bb + 0c742bf7 landed since N2209, docs-only, no rebase needed) → docs commit + GOAL commit → hash-naming commit → handoff-status commit → push to origin main in this tick (origin/main re-checked before push).

## Deferred (NOT this slice)

- RepairTower Units.nearby driver integration (the slice that stamps `nearby_damaged_units` live on refresh) — next after N2210.
- The quadtree (`team.data().tree().intersect`) — the port has no spatial index yet, so the pure function scans the observed-units list.
- Team filtering — the frame carries observed units; the team filter is a later slice.
- RepairTurret target acquisition / heal advance, ImpactReactor impactPower event, Accelerator battery side.
- Windows Godot proof — debt in GOAL.md §5, same as N2175–N2209.
