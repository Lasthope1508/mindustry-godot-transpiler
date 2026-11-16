# Report N2465 — WallCrafter setBars row

**Slice:** N2465 — WallCrafter setBars: one pure-only pure models
the drillspeed bar (bundle.format label Dict + Pal.ammo + raw
warmup fraction). **Wave:** advances-31. **Commit:** `ff487168b`
on `slice/N2465-wall-crafter-set-bars-row` (base `43a5c79ad`).
**Files:** 5, +794/−1.

## Source

WallCrafter.java (core/src/mindustry/world/blocks/production/):
setBars :68-73: `super.setBars(); addBar("drillspeed",
(WallCrafterBuild e) -> new Bar(() -> Core.bundle.format(
"bar.drillspeed", Strings.fixed(e.lastEfficiency * 60 /
drillTime, 2)), () -> Pal.ammo, () -> e.warmup));`
`lastEfficiency` / `warmup` are build fields tracked by the N2223
advance; `drillTime` is the class field (WallCrafter.java:33).

## Implementation

One pure-only pure (no tick wiring):
`source_wall_crafter_bar_state(last_efficiency, drill_time,
warmup)` → `{label, color, fraction, drillspeed}`. label = {key:
"bar.drillspeed", amount: "..."} — a Dict, because Java calls
Core.bundle.format with an argument (the N2450 precedent — the UI
composes the rendered string); amount = Strings.fixed(
lastEfficiency * 60 / drillTime, 2) — Strings.fixed TRUNCATES to 2
places (`floor(v*100+0.0001)/100` + `%.2f`, the N2426 lesson). color
= "Pal.ammo" (token). fraction = warmup RAW (Bar clamps at render —
the N2422 lesson). The amount computation is the SAME as the
drawPlace drillspeed text (N2426) — no shared helper exists, so it
is duplicated with a note.

**Proof arithmetic verified by Python mirror (double, like
GDScript):** 2.0/110→"1.09", 1.099→"1.09", 3.125→"3.12",
60/110→"0.54", 60/48→"1.25", 60/150→"0.40", 0→"0.00".

**Verify-first findings (Java wins — recorded in register docstring
+ driver comment):**
1. `drillTime` class default is WallCrafter.java:**33**, not :44
   (the brief flagged "verify").
2. The Strings.fixed truncation line is arc Strings.java:**737** in
   this checkout, not :735 as the brief/N2426/N2450 cite (the expr
   text is identical — only the line number differs).
3. `setBars()` spans WallCrafter.java:**68-73** (the DEFERRED entry
   says :68-76 — the entry text is kept, only the cite is
   corrected).
4. Operand order: the bar is `lastEfficiency * 60 / drillTime`,
   drawPlace N2426 is `60f / drillTime * eff` — the same formula,
   equal in double; the pure keeps the bar expr's order.

## Commits

- Slice: `ff487168b` (5 files, +794/−1).
- Integration cherry-pick: `04e4a3b54` (clean).

## Tests

Targeted (new module `tests.test_c07_wall_crafter_bar_rows`):
3/4 PASS (registration, exact-evidence, row-state) + proof test
FAIL exactly AssertionError: unexpectedly None — NO Godot binary on
this VM (user order 2026-11-15). Neighbours (11 WallCrafter
modules): Ran 44 (33 PASS + 11 proof Godot-absent), 0 errors.
Full gate (wave advances-31 integration, PID 8788, from 23:14): Ran 6846 tests in 1750.614s, FAILED (failures=386, skipped=5), 0 errors — 386/386 Godot-absent (379 inherited + 7 new proof tests N2462–N2468; Ran 6846 = 6818 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+3/+1/+1/+2** → 12344/1879/1827/3446 (exactly
as estimated). 3 symbols label/color/fraction, 1 contract, 2
schemas (input+result). Shards: production_symbols/slices/
contracts/state_schema; no manifest drift. DEFERRED **#30
RESOLVED** (246→245, by entry TEXT; no new entry).

## Godot debt

- NEW proof `C07WallCrafterBarRowsProof` (6 keys: `bar_label`,
  `bar_truncation`, `bar_color`, `bar_fraction_warmup`,
  `bar_def_values`, `bar_zero_efficiency`) — written but NEVER run;
  debt in GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring).
