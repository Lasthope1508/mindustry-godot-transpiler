# N2289 BeamDrill TimerDump — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-8, integration branch `integration/wave-advances-8-n2288-n2294`, base `2fcdc554`).

## Source

`if(timer(timerDump, dumpTime / timeScale)){ dump(); }` (BeamDrill.java:264-266 — if :264, `dump();` :265, close :266), AFTER the drop loop (:253-262) in the same tick. `dumpTime = 5` (Block.java:438, NO overrides anywhere in upstream, grep-verified); `timerDump = timers++;` (Block.java:436). `dump()` = `dump(null)` (BuildingComp.java:1064-1066; `dump(Item)` :1072-1114). `hasItems = true;` (BeamDrill.java:66).

## Implementation

`SourceBeamDrillBuildState.gd` (mirror of the N2281 Separator precedent, same shape): pure `source_beam_drill_timer_dump_state` → 5 keys {fired, elapsed_after, dumped, items_after, cursor_after} (frame-local Interval-equivalent: frame key `timer_dump_elapsed`, accumulate unconditionally each tick, fire at 5/time_scale, reset 0 on fire including failed dumps, never fires at time_scale ≤ 0). Dump via shared `dump_item_state` (dump(null) semantics) — `SourceBuildingItemDumpState.gd` untouched. New frame keys `timer_dump_elapsed` + `cdump` (`cdump` did not exist on this driver). Tick wires the dump AFTER the N2195 advance in the same enabled gate (Java order :264-266 after drop loop :253-262); persists items/cdump/clock back to the frame. **First-fire deviation** (documented in docstring + DEFERRED): Java fires nearly immediately after placement; the frame clock delays the first fire by one full interval (5 ticks). The drop loop + time reset (entry 223) is NOT in this slice.

## Commits

Slice `56cbb21e` (worker-N2289, branch `slice/N2289-beam-drill-dump-timer`, 5 files, +1181/−6, đã push, remote tip verified by ls-remote). Integration cherry-pick `646b1a15` on `integration/wave-advances-8-n2288-n2294` (base 2fcdc554). No coordinator fix needed for this slice.

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 33/33, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings (BeamDrill power + should-consume + update-tile + liquid rows): 12/12 non-proof PASS; 4 failures are all proof tests, all `AssertionError: unexpectedly None` — 0 other failures. Proof live-tick: plasma-bore, facing_amount 1 opens the gate, power_status 1.0, clock 4.0 → efficiency 1.0, optional_efficiency 0 (no hydrogen), warmup 1/60, multiplier 1.0, time 1.0, copper 5→4, cdump 0→1, clock 0.0. Full gate (wave advances-8 integration, PID 7543, 03:03–03:24): Ran 6262 tests in 1223.176s, FAILED (failures=242, skipped=5), 0 errors — 242/242 Godot-absent `AssertionError: unexpectedly None` (236 inherited + 6 new proof tests N2288/N2289/N2291/N2292/N2293/N2294; N2290 adds no test).

## SSOT / DEFERRED

SSOT single-slice +5/+1/+1/+2 → 11860/1738/1671/3134; audit stays 1336. DEFERRED 315 (313 − 1 resolved: BeamDrill dump timer + 3 new: first-fire deviation, dump neighbour live fill, dump neighbour write-back). Merged wave DEFERRED: 321 entries (DEFERRED-after-advances-8.py) — 313 − 8 resolved/removed + 16 new, resolved by entry TEXT not number.

## Godot debt

`C07BeamDrillTimerDumpProof` — 6 keys: timer_fires_at_five_ticks, timer_no_fire_below_threshold, dump_removes_item_from_store, dump_cursor_advances, no_dump_when_items_empty, live_tick_dumps_item (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.

**Flag (not this slice):** the N2195 live proof (`C07BeamDrillUpdateTileProof`) is STALE since N2256 — it asserts multiplier 1.75 / time 0.875 at power_status 0.5, but with no hydrogen the booster row folds optionalEfficiency to 0, so the multiplier is now 1.0 and time 0.5. It needs an N2290-style fix slice (queued for advances-9).
