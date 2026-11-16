# Report N2388 — Separator sense rows (sense-only)

**Slice:** N2388 — Separator `sense()` rows: `sense(LAccess.progress)`
progress as-is. **canDump does NOT land** (verify-first verdict —
see below). **Wave:** advances-21. **Commit:** `aefb3fd60` on
`slice/N2388-separator-sense-rows` (base `d35c67781`).
**Files:** 5, +897/−1.

## Source

Java: Separator.java:169-172 (`sense(LAccess.progress)` = progress),
:175-177 (`canDump` = `!consumesItem`); Block.java:774-776
(`consumesItem(item)` = `itemFilter[item.id]`); Blocks.java:
1231-1246 (separator def — no `consumeItem`, so `consItems` is
null), :1263 (disassembler consumes scrap).

## Implementation

New pure `source_separator_sense_state(sensor, progress,
super_value = null)` (the N2383 shape): progress → frame `progress`
**as-is, NO clamp** (Java-exact vs. the MendProjector clamp — 1.5
stays 1.5, −0.25 stays −0.25, pinned in the proof); other sensors →
the caller-supplied `super_value` (null = the `Float.NaN` default
branch); the super.sense switch is not re-modeled.

**Verdict: SENSE-ONLY (per the brief's verify-first rule).**
`consumesItem(item)` = `itemFilter[item.id]`. The port models
`Block.consumesItem` only generically
(`SourceBlockQueryFilterState.consumes_item_state`, caller-supplied
`item_filter`); **no Separator itemFilter is modeled anywhere** —
no Separator register/GDScript references `item_filter`, no
Separator code calls `consumes_item_state`, and neither driver nor
catalog supplies the separator/disassembler def filter (the
separator def has no `consumeItem`, so `consItems` is null; the
disassembler consumes scrap). Building the def filter would invent
a consumesItem model, so canDump stays deferred under the rewritten
#38 entry.

**Pure-only verified:** grep `sense` in the driver finds only the
documented-limits comment — the tick never calls sense; sense is
called by logic.

## Commits

- Slice: `aefb3fd60` (5 files, +897/−1).
- Integration cherry-pick: `74928cd10` (clean).

## Tests

Targeted (new module `tests.test_c07_separator_sense_rows`): 3/4
PASS + proof test FAIL exactly AssertionError: unexpectedly None —
NO Godot binary on this VM (user order 2026-11-15).
Full gate (wave advances-21 integration, PID 20509, from 14:01):
Ran 6575 tests in 1517.133s, FAILED (failures=319, skipped=5), 0 errors — 319/319 Godot-absent `AssertionError: unexpectedly None` (312 inherited + 7 new proof tests N2386–N2392; N2393 adds no test).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+1/+2** → 12053/1813/1741/3274 (2 symbols:
`source_separator_sense_state_result.value`, `.is_progress`).
Audit stays 1336. DEFERRED **#38 REWRITTEN IN PLACE** — the old
combined "Separator sense / canDump rows" entry is now the
canDump-only entry (sense live since N2388; canDump waits for a
Separator itemFilter/consumesItem model) — count stays 306.

## Godot debt

- NEW proof `C07SeparatorSenseRowsProof` (6 keys:
  `sense_progress_zero`, `sense_progress_partial`,
  `sense_progress_unclamped` (1.5→1.5, −0.25→−0.25 — the no-clamp
  evidence), `sense_super_sensor`, `sense_super_default`,
  `sense_live_frame_values` (placed separator, 1 tick: progress
  0.5 + 1/35, sensed as-is)) — written but NEVER run; debt in
  GOAL.md §5.
- No old proof needs a re-run.
- Follow-through: a future slice to model the Separator itemFilter
  / consumesItem (separator: all-false filter; disassembler:
  scrap-only) so canDump (`!consumesItem`) can land; the
  logic-executor call site for sense (port-wide, not a Separator
  deferral).
