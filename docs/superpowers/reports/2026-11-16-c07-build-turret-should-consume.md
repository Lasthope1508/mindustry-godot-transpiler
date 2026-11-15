# Report — N2201: BuildTurret shouldConsume gate (BuildTurret.java:229-230, C07)

Date: 2026-11-16. Batch: N2201 (single slice). Status: **DONE + GATE VERIFIED (2026-11-16 ~03:59 +07 — targeted 4/4, family 32/32 + BuildTurret family re-run 8/8, wiring 32/32; full gate Ran 5897, failures=151, skipped=5, 0 errors, all 151 verified Godot-absent). Ready to push (origin/main still e2bc910).**

## What changed

N2200 is DONE + PUSHED (main e2bc910); this tick finishes the BuildTurret shouldConsume gate — the deferred item N2184 left open, and the next item after N2200 per the N2200 handoff ("Next: BuildTurret shouldConsume"). Java: `shouldConsume()` returns `unit.plans().size > 0 && !isHealSuppressed()` (BuildTurret.java:229-230). The power draw is STATIC (consumePower 3f, Blocks.java:2005), so with no plans `power.status` reads 0.5 at half power while Java efficiency is 0 via the gate (BuildingComp.java:1960 + 1992-1993). N2184 folds power-only, so the port reported efficiency 0.5 with no plans — the gap this slice closes once the frame carries a plans observation. No gameplay change; nothing staged/committed/pushed yet.

What RED adds (4 files, not staged):

- **Test module + register script** `test_c07_build_turret_should_consume.py` + `register_c07_build_turret_should_consume.py` (N2188 pattern). SSOT baseline re-verified from disk: 11415/1650/1571/2933, audit 1335, defense shards 163/162. Expected after GREEN: **11416/1651/1572/2935**, audit 1335, defense shards 164/163.
- **Proof scene** `C07BuildTurretShouldConsumeProof.gd` (+ `.tscn`, `.json` untracked per .gitignore:6), N2188 proof shape. 6 semantic keys: gate blocks without plans / passes with plans / blocks when disabled / absent preserves power fold / blocks when heal suppressed / build-tower has power consumer.
- **Handoff** `docs/superpowers/handoffs/2026-11-16-c07-build-turret-should-consume-handoff.md` — design, frame keys (`plans_count`, `heal_suppressed`), proof keys, RED decisions, Java evidence.

## RED

Tests written first per the slice process. Targeted RED run: `python3 -m unittest tests.test_c07_build_turret_should_consume -v` (port 7777 FREE, javalang 0.13.0 OK): **Ran 4, FAILED (failures=2, errors=2)** — the classic signature: 2 × KeyError 'N2201' (registration + exact-evidence, missing ledger entry), 1 × state FAIL (missing `static func source_build_turret_should_consume_state`), 1 × proof FAIL (`assertIsNotNone(godot)` — no Godot on PATH in the worker shell + missing proof run). All four failures are the missing implementation, exactly the RED expectation. EXACT_EXPRS verified verbatim against upstream at RED (15/15 present, 0 missing); DEFERRED 234 entries (232 carried from N2184 via AST + 2 new N2201 entries). `git diff --check` clean.

## GREEN (03:30–03:45 +07 tick, main-thread verified)

Pure function `source_build_turret_should_consume_state(frame)` + 1 driver line in the EXISTING `SourceBuildTurretBuildState.gd` (diff 17 lines: the new function before the tick function, all 15 exact exprs in its comment; driver line now `bool(source_build_turret_should_consume_state(frame).get("should_consume", true))`; the N2184 "gate deferred" sentences updated to record the N2201 wiring). Frame keys: `plans_count` (int, NEW) + `heal_suppressed` (bool, NEW). Absent-key defaults pinned in the proof: no `plans_count` → `should_consume = enabled` (preserves N2184 behavior — defaulting absent to false would zero efficiency for every live build tower, a live regression, forbidden by the user boundary); no `heal_suppressed` → false (not suppressed). The gate flows through the shared machinery: `update_consumption_initial_state` (SourceBuildingEfficiencyState.gd:93-99, `efficiency := potential_efficiency if should_consume_state else 0.0`). No new frame meta key, no simulate_factory wiring change. Register: SSOT **11416/1651/1572/2935** đúng kỳ vọng, defense shards **164/163**. Targeted GREEN **Ran 4 OK trong 16.062s** (log `n2201-green.log`), proof 6 semantic keys + 3 meta = 9 keys matches:true, 0 false, Godot headless 4.6.2 (proof JSON 03:42 +07). Neighbours: family `test_*_should_consume.py` **Ran 32 OK** trong 162.233s (log `n2201-neighbours.log` — lists NO module names, composition unverified; main thread re-ran the actual BuildTurret family N2184 + N2201: **8/8 OK**; the N2188 2 failures on the shared proof scene did NOT recur) + wiring **32/32 OK** trong 122.361s (log `n2201-wiring.log`, 9 modules). **GREEN tổng 68/68** theo logs (+ 8/8 family re-run). `git diff --check` sạch. Logs `n2201-green.log`, `n2201-neighbours.log`, `n2201-wiring.log`.

## Gate (xanh — trừ Godot-absent)

Full gate `python3 -m unittest discover -s tests`, attempt 2 launched from the MAIN thread (PID 11419, SID 11419, ~03:41, `nohup setsid`, không Godot trên PATH, log `full-suite-n2201-gate.log`) FINISHED ~03:59 +07: **Ran 5897 trong 996.621s, FAILED (failures=151, skipped=5), 0 errors** — cả 151 đều `AssertionError: unexpectedly None` (`assertIsNotNone(godot)`), dạng Godot-absent; 0 dòng `ERROR:`. +4 tests / +1 failure so với N2200 (5893 → 5897, 150 → 151) là test proof mới của N2201, cũng Godot-absent trong gate. Attempt 1 (PID 11174, worker-launched, ~03:30) chết theo worker session — log dừng ở 3685 bytes, không footer (lần thứ 8 worker-session gate death được ghi nhận; setsid/nohup không cứu được gate do worker launch). SSOT 11416/1651/1572/2935 xác nhận từ disk; audit `totalSourceFunctions` 1335 không đổi.

## PUSH (gate verified ~03:59 +07)

Gate clean except Godot (Ran 5897, failures=151 all Godot-absent, skipped=5, 0 errors). Spec updated in the docs commit (Done/ledger 1650 → 1651 + N2201 row); GOAL.md §5 keeps the Windows proof as debt. Slice `SLICE_HASH` (11 files) → docs `DOCS_HASH` + GOAL `GOAL_HASH` → this hash-naming commit → handoff-status commit → push to origin main in this tick (origin/main re-checked before push: still e2bc910).

## Deferred (NOT this slice)

- Plan search / mimic / validate / updateBuildLogic (BuildTurret.java:156-225) — the plan-acquisition slice, which is also the slice that starts stamping `plans_count` live.
- The nitrogen liquid consumer (Blocks.java:2006) — second pass.
- Live suppression stamping (checkSuppression, BuildTurret.java:132-133) — own slice.
- Per-def stat verification; draw / read / write / sense (BuildTurret.java:232-319) — own slices.
- The remaining C07 deferred items per the N2201 handoff — ShieldWall broken(), MassDriver / LaunchPad rows, RepairTurret coolant, the Units.nearby live query — each its own slice; or C08 inventory (classify the 5,390 null-body functions) when asked.
- Windows Godot proof — debt in GOAL.md §5, same as N2184–N2200.
