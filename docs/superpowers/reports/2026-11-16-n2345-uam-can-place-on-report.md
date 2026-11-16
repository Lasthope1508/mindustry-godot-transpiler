# Report N2345 — UnitAssemblerModule canPlaceOn

**Slice:** N2345 — UnitAssemblerModule canPlaceOn placement gate (getLink
!= null; the frame link verdict). **Wave:** advances-16. **Commit:**
`fcbf2293` on `slice/N2345-uam-can-place-on` (base `4f31a099`). **Files:**
5, +764/−1.

## Source

Java: canPlaceOn is **UnitAssemblerModule.java:48-51** (signature :49,
return :50) — NOT :53-55 as the DEFERRED entry + SCOPE/brief said (:53-55
is inside drawPlanRegion — re-verified from Java by the coordinator);
`getLink` at :79 (findLink); the link field defaults null (:72). The file
is in `blocks/units/`, NOT `payloads/`.

## Implementation

New pure `source_unit_assembler_module_can_place_on_state(frame)` →
`{can_place_on}` (true iff frame["link"] != null — the getLink verdict the
frame already carries; the N2248 advance re-discovers it via findLink).
Pure-only, NO tick stamp (a placement gate, the N2330 precedent). The
default is RESTRICTIVE (no link → cannot place — Java-exact, the link
field defaults null; unlike N2330's permissive default). The pure lives in
its own `# --- N2345 ---` block between the N2299 acceptPayload pures and
the vec2 helper; no touch of N2348's territory beyond one docstring
segment (:89).

## Commits

- Slice: `fcbf2293` (5 files, +764/−1).
- Integration cherry-pick: `041f3852` (clean; the N2348 cherry-pick later
  conflicted on the shared UAM driver docstring — resolved by manual
  merge, see the N2348 report).

## Tests

Targeted (new module `tests.test_c07_unit_assembler_module_can_place_on`):
3/4 PASS (RED KeyError N2345) + proof test FAIL exactly AssertionError:
unexpectedly None — NO Godot binary on this VM (user order 2026-11-15).
Exact-evidence 8/8. Siblings 5 modules Ran 20 (15 PASS + 5 proof
Godot-absent — UAM power_status, update_tile, accept_payload,
handoff_gate + UCL canPlaceOn N2330).
Full gate (wave advances-16 integration, run 2 PID 1743, 09:24–09:46): Ran
6443 tests in 1290.524s, FAILED (failures=287, skipped=5), 0 errors —
287/287 Godot-absent `AssertionError: unexpectedly None` (280 inherited +
7 new proof tests N2344–N2350). Gate run 1 (PID 9349, 09:10–09:24) was
killed by VM restart #11 ~09:24 (javalang wiped, reinstalled 09:24, no
commit/file loss).

## SSOT / DEFERRED

SSOT single-slice **+1/+1/+1/+2** → 11977/1782/1714/3220, exactly as
estimated (1 symbol; no shard changes, no manifest drift, audit 1336).
DEFERRED net 0 (resolve #41 + 1 new: live placement call site, hook
SourceBlockGeometry.gd:1149-1151). ⚠️ The register was built on the STALE
334 snapshot (not the merged 332) — the advances-16 merge script excluded
entries #326/#31 from this worker's "added" list.

## Godot debt

- NEW proof `C07UnitAssemblerModuleCanPlaceOnProof` (4 keys, not 6:
  `can_place_on_when_linked`, `cannot_place_on_when_unlinked`,
  `cannot_place_on_without_link_input` (link_candidate-only → false: the
  pure reads frame["link"] only), `can_place_on_after_link_refresh`
  (composes the N2248 advance)) — written but NEVER run; debt in GOAL.md
  §5.
- Follow-through: none (no test/proof pins changed).
