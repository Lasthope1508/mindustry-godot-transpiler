# Report N2358 — UnitAssemblerModule getLink discovery

**Slice:** N2358 — moduleFits geometry pure + getLink discovery over an
explicit candidate list. **Wave:** advances-18. **Commit:** `dc5f5de6a`
on `slice/N2358-uam-getlink-discovery` (base `1843003e2`). **Files:** 5,
+1200/−17.

## Source

Java: UnitAssembler.java:338-351 (moduleFits geometry), :323-378
(checkTier context); UnitAssemblerModule.java:65-83 (findLink/getLink);
Tile.java:82-84 (relativeTo); Vars.java:135 (tilesize 8); arc
Geometry d4 tables; Mathf.equal (FLOAT_ROUNDING_ERROR 1e-6). 34 exact
exprs, all verified verbatim.

## Implementation

Two new pures on SourceUnitAssemblerModuleBuildState:
(a) `source_unit_assembler_module_fits_state` — moduleFits geometry
(spawn uses assembler rot/pos; dx/dy + relativeTo use module rot — the
proof pins module rot 3 vs assembler rot 0; reuses
`tile_relative_float_state`, d4 tables local + posmod, Mathf.equal
inline 1e-6); (b) `source_unit_assembler_module_get_link_state` —
discovery over an EXPLICIT candidate list, first fit, returning the
N2351 frame-input format `{"block", "cell": Vector2i}` or null; skips
malformed entries. The tick fills `frame["link_candidate"]` before the
N2248 advance, ONLY when `frame.has("link_candidates")` (the N2352
precedent — preserves the N2248/N2351 proofs, which seed no
candidates).

## Commits

- Slice: `dc5f5de6a` (5 files, +1200/−17).
- Integration cherry-pick: `4d6adad36` (clean).

## Tests

Targeted (new module `tests.test_c07_unit_assembler_module_get_link_discovery`):
3/4 PASS + proof test FAIL exactly AssertionError: unexpectedly None —
NO Godot binary on this VM (user order 2026-11-15). Exact-evidence
34/34. Siblings 21/28 PASS (7 proof Godot-absent), 0 other errors.
Full gate (wave advances-18 integration, PID 21965, 11:52–12:17): Ran
6493 tests in 1482.684s, FAILED (failures=299, skipped=5), 0 errors —
299/299 Godot-absent `AssertionError: unexpectedly None` (293 inherited
+ 6 new proof tests N2358–N2363; N2364 adds no new proof test).

## SSOT / DEFERRED

SSOT single-slice **+10/+1/+2/+4** → 12009/1794/1729/3250 (brief est +4
symbols low — the fits pure echoes intermediates). Audit stays 1336.
DEFERRED **326 → 326 (−1+1)**: resolved the getLink discovery entry
(#318 1-based; the SCOPE/worker cited #317 0-based — see the DEFERRED
numbering lesson), +1 new entry (live flagged-buildings index fill,
documenting the `link_candidates` frame-input format).

## Godot debt

- NEW proof `C07UnitAssemblerModuleGetLinkDiscoveryProof` (14 keys:
  `fits_side_module`, `fits_rotated_assembler`,
  `fits_module_rotation_differs`, `fits_default_area_size`,
  `no_fit_wrong_direction`, `no_fit_wrong_distance`,
  `no_fit_module_on_spawn`, `discovery_first_fit`,
  `discovery_no_fit_null`, `discovery_skips_malformed`,
  `discovery_empty_list_null`, `live_tick_discovery_links`,
  `live_tick_no_fit_null`, `live_tick_no_candidates_keeps_seed`) —
  written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run.
- Follow-through: the handoff gate (UAM.java:138) still reads the frame
  predicate `module_fits` (default false) — wiring the fits pure into
  the gate is a separate slice (backlog advances-19).
