# N2294 MassDriver DumpAccumulate — Handoff

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-8, integration branch `integration/wave-advances-8-n2288-n2294`, base `2fcdc554`).

## What this slice did

MassDriver dumpAccumulate when idle/accepting, before the efficiency check (dump runs even with no power). Pure `source_mass_driver_dump_state` → 4 keys (dump_accum_after, dumped, items_after, cursor_after).

## Key facts for the next agent

- Dump gate: `if(state == DriverState.idle || state == DriverState.accepting){ dumpAccumulate(); }` (MassDriver.java:164-166), BEFORE the efficiency check (:168-171 — the block closes at :171, not :170).
- **Key design point:** the N2237 advance now also returns `state_after_switch` (additive key only — signature, call site, N2237 tests untouched). The dump gate must read the state the switch produced, not the final state: a shooting driver that fires ends the tick idle but must NOT dump.
- Shooting → the accumulator does NOT grow (dumpAccumulate() is only called when idle/accepting).
- `dump(Item)` is :1072-1114 (the method closes at :1114 — the brief's :1072-1113 omitted the closing brace).
- The PortBridge `source_dump_accumulate_attempt_state` is an INSTANCE method delegating to the `dump_accumulate_state` static (:186-193) — the static pure calls the static directly.
- Proof arithmetic validated by a Python simulation mirroring the GDScript + helpers exactly: 17/17 checks pass.
- SSOT +4/+1/+1/+2 → 11859/1738/1671/3134 (audit 1336). Exact-evidence 36/36. DEFERRED 314 (−1 +2 new).

## Godot debt (this slice)

`C07MassDriverDumpProof` — 6 keys: dump_fires_when_idle, dump_fires_when_accepting, dump_blocked_when_shooting, dump_runs_without_power, dump_removes_item_from_store, live_tick_dumps_item (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Targeted test: `tests.test_c07_mass_driver_dump`. Do NOT mark done until it passes there.
