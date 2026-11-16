# Report N2349 — Disassembler scrap item efficiency row

**Slice:** N2349 — Separator disassembler scrap item efficiency row
(ConsumeItems; binary items.has(scrap, 1); disassembler-only fold).
**Wave:** advances-16. **Commit:** `79d467e2` on
`slice/N2349-disassembler-scrap-row` (base `4f31a099`). **Files:** 5,
+983/−2.

## Source

Java: ConsumeItems efficiency ConsumeItems.java:51-53; consumeTriggerValid
base false (BuildingComp.java:764-766), the only override in the codebase
is ConsumeGeneratorBuild (grep-verified — no Separator/GenericCrafter
override); multiplier 1.0 default (Consume.java:18); Consume.update is
empty (Consume.java:52). The catalog carries consumeItem scrap ×1 for the
disassembler; the separator def has NO consumeItem. Disassembler def rows
in content/Blocks.java: craftTime :1258, size :1259, itemCapacity :1260,
consumePower :1262, consumeItem :1263, consumeLiquid :1264.

## Implementation

New pure `source_separator_disassembler_scrap_row_state(frame,
has_item_consumer, stacks, multiplier=1.0)` → `{has_item_row, row:
{result, is_power: false}}` (the envelope N2153/N2268 — the brief sketched
`{efficiency}`, which is the row's `result` value; the shared fold reads
`required_results` as `{"result","is_power"}` dicts). Binary 1/0 on
`items.has` of every stack at `round(amount * multiplier)`, via the shared
`inventory.item_count` helper. The tick fold reads the stacks from the
catalog `consumeItem` rows, gated on `block.properties.has("consumeItem")`,
appended to `required_results` after the liquid row — only the disassembler
def folds it (the separator def has no `consumeItem`). No removal:
`Consume.update` is empty; scrap removal stays in the N2222 advance
`consume()`.

## Commits

- Slice: `79d467e2` (5 files, +983/−2).
- Integration cherry-pick: `1a0de7f6` (clean).

## Tests

Targeted (new module `tests.test_c07_separator_disassembler_scrap_row`):
3/4 PASS + proof test FAIL exactly AssertionError: unexpectedly None — NO
Godot binary on this VM (user order 2026-11-15). Exact-evidence 18/18.
Siblings: all 6 Separator modules 3/4 each (proof Godot-absent).
Full gate (wave advances-16 integration, run 2 PID 1743, 09:24–09:46): Ran
6443 tests in 1290.524s, FAILED (failures=287, skipped=5), 0 errors —
287/287 Godot-absent `AssertionError: unexpectedly None` (280 inherited +
7 new proof tests N2344–N2350). Gate run 1 (PID 9349, 09:10–09:24) was
killed by VM restart #11 ~09:24 (javalang wiped, reinstalled 09:24, no
commit/file loss).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+1/+2** → 11978/1782/1714/3220 (not +1 as
estimated — the pure returns 2 keys: row + has_item_row); all 4 production
shards; ledger `java_source` is Separator.java per the N2268
family-pattern lesson (a consumer `java_source` breaks the
`consumer_slices` shard with `KeyError 'generated_owner'`). Audit stays
1336.
DEFERRED **−1+0** (resolve the scrap entry — #218 in merged numbering,
#220 in the worker's stale-334 list — 0 new: the intake gap is already on
the 'Separator items intake rows' entry; no second-pass removal exists for
items). ⚠️ The register was built on the STALE 334 snapshot — the
advances-16 merge script excluded entries #326/#31 from this worker's
"added" list and merged by entry TEXT.

## Godot debt

- NEW proof `C07SeparatorDisassemblerScrapRowProof` (6 keys:
  `item_row_binary_scrap`, `item_row_zero_no_scrap`,
  `item_row_folds_required_min`, `advance_removal_unchanged` (the N2222
  advance still removes 1 scrap at craft, 3→2),
  `live_tick_folds_scrap_row` (A: 2 scrap + slag 1.0 + power 1.0 → eff
  1.0; B: no scrap + slag 1.0 + power 1.0 → eff 0.0),
  `scrap_row_blocks_power_when_starved`) — written but NEVER run; debt in
  GOAL.md §5.
- Follow-through: NO old proof stale, no seeding, no re-run (all 6
  C07Separator proofs tick the **separator** def only — every
  `record_placed_block` uses `blocks_by_id["separator"]` — and the
  separator def has no `consumeItem`; the two AdjacentFactory proofs that
  place a disassembler never call `source_separator_tick_buildings_state`).
- Scope corrections: (1) pure shape envelope (above); (2) DEFERRED
  numbering #218 merged vs #220 worker list; (3) **cite fix NOT applied by
  the worker** (verified but out of scope): disassembler `itemCapacity =
  20` is **Blocks.java:1260**, not :1261 as driver comments + DEFERRED
  entry #44 say (:1261 is a blank line; entry #44 is off by +1 on 3 of 4
  cites) → **fixed by the coordinator at integration** (fix `888c552a`:
  driver comment + 2 test comments; entry #44 rewritten in place in the
  merged DEFERRED snapshot with corrected cites craftTime :1258, size
  :1259, itemCapacity :1260, consumePower :1262, consumeItem :1263,
  consumeLiquid :1264).
