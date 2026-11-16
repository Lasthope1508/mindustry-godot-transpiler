# Report N2348 — UnitAssemblerModule tier stamp

**Slice:** N2348 — UnitAssemblerModule tier stamp (tier = 1 class default;
frame tier every tick). **Wave:** advances-16. **Commit:** `9f5612f8` on
`slice/N2348-uam-tier-stamp` (base `4f31a099`). **Files:** 5, +830/−1.

## Source

Java: tier = 1 (UnitAssemblerModule.java:22), tier() (:85-86).
**moduleFits takes NO tier term** — UnitAssembler.java:338-351 is geometry
only (the brief/SCOPE said "moduleFits/sort" — half wrong; tier is used
only in the checkTier sort :364-369; re-verified from Java by the
coordinator: no "tier" in :338-351). **The checkTier pure is ALREADY live
since N2133** (`source_unit_factory_assembler_check_tier_state`, wired
into the shouldConsume gate, reading the assembler frame `modules` list of
ints). The catalog has NO tier key for basic-assembler-module and the def
sets no tier (Blocks.java:6566-6573).

## Implementation

New pure `source_unit_assembler_module_tier_state(block_id, tier_default)`
→ `{tier}` (class default 1 via const
SOURCE_UNIT_ASSEMBLER_MODULE_TIER_DEFAULT; block_id is the def key for the
contract, the pure is def-agnostic — `@warning_ignore("unused_parameter")`
per the in-file tick precedent). The tick stamps frame["tier"] every tick
(own N2348 block after `wired`, before the power-consumer fold —
unconditional, overwrites stale seeds, runs even when disabled).

## Commits

- Slice: `9f5612f8` (5 files, +830/−1).
- Integration cherry-pick: `5ad421ab` (MANUAL merge — the UAM driver
  docstring "Documented limits" segment :89 conflicted with the N2345
  cherry-pick: N2345 had removed canPlaceOn from the "No ... rows" list,
  N2348 had removed tier; the merge keeps `No link/draw/onRemoved rows`
  + both live sentences. Coordinator fix `888c552a` updated the N2348
  test pin to the merged string).

## Tests

Targeted (new module `tests.test_c07_unit_assembler_module_tier_stamp`):
3/4 PASS (RED KeyError N2348) + proof test FAIL exactly AssertionError:
unexpectedly None — NO Godot binary on this VM (user order 2026-11-15).
Exact-evidence 7/7. Siblings 5 modules Ran 20 (15 PASS + 5 proof
Godot-absent, incl. C06 check-tier N2133).
Full gate (wave advances-16 integration, run 2 PID 1743, 09:24–09:46): Ran
6443 tests in 1290.524s, FAILED (failures=287, skipped=5), 0 errors —
287/287 Godot-absent `AssertionError: unexpectedly None` (280 inherited +
7 new proof tests N2344–N2350). Gate run 1 (PID 9349, 09:10–09:24) was
killed by VM restart #11 ~09:24 (javalang wiped, reinstalled 09:24, no
commit/file loss).

## SSOT / DEFERRED

SSOT single-slice **+1/+1/+1/+2** → 11977/1782/1714/3220, exactly as
estimated (1 symbol; no shard changes). Audit stays 1336.
DEFERRED net 0 (resolve #40 + 1 new: UnitAssembler checkTier tier
consumption — the remaining work is cross-building wiring: feeding linked
modules' stamped frame["tier"] values into the assembler frame `modules`
list on updateModules/removeModule events, UnitAssembler.java:355-362; no
existing DEFERRED entry covers this wiring — #211 is link/findLink rows,
different). Base was the merged 332.

## Godot debt

- NEW proof `C07UnitAssemblerModuleTierStampProof` (5 keys:
  `pure_returns_class_default_tier`, `pure_honors_explicit_default`
  (tier_default 2 → 2, proving the param — not a hardcoded 1 — is the
  value's source), `live_tick_stamps_tier`,
  `tier_stamp_overwrites_stale_seed` (seed 99 → 1),
  `tier_stamp_survives_disabled`) — written but NEVER run; debt in GOAL.md
  §5.
- Follow-through: none (N2299's assertNotIn on the old doc-limits string
  still holds; N2314 ordering pins unaffected — the stamp lands before all
  three pinned calls; no proof re-runs — frame["tier"] is a new key).
- Merge note: no N2345 code touched (pure + stamp + const in
  clearly-marked separate blocks); the manual merge with N2345 was the
  docstring segment :89 only.
