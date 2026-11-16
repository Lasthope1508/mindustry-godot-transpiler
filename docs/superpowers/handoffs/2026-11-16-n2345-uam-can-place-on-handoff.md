# Handoff N2345 — UnitAssemblerModule canPlaceOn

## What this slice did

Ported the UnitAssemblerModule canPlaceOn placement gate as a pure: true
iff the frame carries a link (the getLink verdict). 5 files, +764/−1,
commit `fcbf2293` on `slice/N2345-uam-can-place-on`.

## Key facts for the next agent

- Pure `source_unit_assembler_module_can_place_on_state(frame)` →
  `{can_place_on}` (true iff frame["link"] != null).
- **canPlaceOn is UnitAssemblerModule.java:48-51** (signature :49, return
  :50) — NOT :53-55 (inside drawPlanRegion; the DEFERRED entry + brief
  were wrong).
- Default is RESTRICTIVE (no link → cannot place — Java-exact, link field
  defaults null :72; unlike N2330's permissive default).
- Pure-only, NO tick stamp (a placement gate, the N2330 precedent). The
  live placement call site is a new DEFERRED entry (hook
  SourceBlockGeometry.gd:1149-1151).
- SSOT +1/+1/+1/+2 (1 symbol). DEFERRED net 0 (resolve #41 + 1 new).
- N2348 shares this driver — manual merge at integration (docstring
  segment :89); this slice's code was untouched by the merge.
- Follow-through: none. NO re-run.

## Godot debt (this slice)

- NEW proof `C07UnitAssemblerModuleCanPlaceOnProof` (4 keys) — never run.
