# N2294 MassDriver DumpAccumulate — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-8, integration branch `integration/wave-advances-8-n2288-n2294`, base `2fcdc554`).

## Source

`//dump when idle or accepting` + `if(state == DriverState.idle || state == DriverState.accepting){ dumpAccumulate(); }` (MassDriver.java:163-166) — BEFORE the efficiency check (`if(efficiency <= 0f){ return; }`, **:168-171** — the brief's :168-170 was off: comment :168 + if :169 + return :170, block closes :171), so **the dump runs even with no power**. `dumpAccumulate()` delegates `dumpAccumulate(null)` (BuildingComp.java:1048-1050). `dumpAccumulate(Item)` (BuildingComp.java:1053-1061): `dumpAccum += delta(); while(dumpAccum >= 1f){ res |= dump(item); dumpAccum -= 1f; }` (verbatim `dumpAccum -=1f;`). `dump()` = `dump(null)` (BuildingComp.java:1064-1066; `dump(Item)` **:1072-1114** — the brief's :1072-1113 omitted the closing brace: `return false;` :1113, `}` :1114). `private transient float dumpAccum;` (:99); `hasItems = true;` (MassDriver.java:51); `delta()` :1922-1924.

## Implementation

`SourceMassDriverBuildState.gd`: pure `source_mass_driver_dump_state(frame, state_after_switch, source_delta, time_scale, content_item_ids, neighbour_accepts_item, neighbour_can_dump)` → 4 keys {dump_accum_after, dumped, items_after, cursor_after}. Gates the WHOLE accumulation on the post-switch state (idle/accepting → dump; shooting → the accumulator does NOT grow), accumulates `source_delta × time_scale` via the shared `dump_accumulate_state` static (the PortBridge `source_dump_accumulate_attempt_state` is an INSTANCE method delegating to it — the static pure calls the underlying static directly, same function, no duplication, no helper modified), and routes each attempt through the shared `dump_item_state` (dump(null), neighbour-outer/item-inner, cursor per neighbour checked). **Key design point:** the N2237 advance now also returns `state_after_switch` (additive key only — signature, call site, and all N2237 test/proof assertions untouched). The dump gate must read the state the switch produced, not the final state: a shooting driver that fires ends the tick idle but must NOT dump. Running the dump after the advance is Java-equivalent for items because fire() — the only item-mutating branch — runs only while shooting. Tick wires the dump after the N2237 advance, unconditionally — dump runs even at efficiency 0. Frame key `dump_accum` (default 0.0). Neighbour accept/canDump are frame inputs (default `[]`).

## Commits

Slice `b9d17508` (worker-N2294, branch `slice/N2294-mass-driver-dump-accumulate`, 5 files, +1142/−4, đã push, remote tip verified by ls-remote). Integration cherry-pick `fdbddcea` on `integration/wave-advances-8-n2288-n2294` (base 2fcdc554). No coordinator fix needed for this slice.

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 36/36, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings (36 tests across MassDriver power/update-tile, PayloadMassDriver power/update-tile/branches, LaunchPad power/should-consume/update-tile/liquid-row): 27 pass, 9 failures all proof tests failing `AssertionError: unexpectedly None`; dump neighbours N2281/N2287: 8 tests, 2 failures, both their proof tests — 0 other failures. **Proof arithmetic validated by a Python simulation mirroring the GDScript + helpers exactly: 17/17 checks pass** (incl. multi-dump 2.5-tick while loop, time_scale 2.0, cursor 0→2, failed attempts consuming accumulator, guard paths keeping cursor). Full gate (wave advances-8 integration, PID 7543, 03:03–03:24): Ran 6262 tests in 1223.176s, FAILED (failures=242, skipped=5), 0 errors — 242/242 Godot-absent `AssertionError: unexpectedly None` (236 inherited + 6 new proof tests N2288/N2289/N2291/N2292/N2293/N2294; N2290 adds no test).

## SSOT / DEFERRED

SSOT single-slice +4/+1/+1/+2 → 11859/1738/1671/3134; audit stays 1336. Only the 4 canonical JSONs changed in the worker's register run — no shard changes (the merged run's shard changes come from the other slices). DEFERRED 314 (313 − 1 resolved: MassDriver dumpAccumulate/dump rows + 2 new: dump neighbour live fill, dump neighbour write-back). Merged wave DEFERRED: 321 entries (DEFERRED-after-advances-8.py) — 313 − 8 resolved/removed + 16 new, resolved by entry TEXT not number.

## Godot debt

`C07MassDriverDumpProof` — 6 keys: dump_fires_when_idle, dump_fires_when_accepting, dump_blocked_when_shooting, dump_runs_without_power, dump_removes_item_from_store, live_tick_dumps_item (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
