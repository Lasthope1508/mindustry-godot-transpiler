# Handoff N2329 — MendProjector heal scan range query

## What this slice did

Wired the MendProjector heal scan range query: a new pure filters frame
heal candidates by the eachBlock rect, and the tick passes the filtered
list into the N2242 heal_scan (replacing the `[]` literal). 5 files,
+1041/−12, commit `dd624585` on
`slice/N2329-mend-projector-heal-scan-range`.

## Key facts for the next agent

- Pure `source_mend_projector_supplied_heal_candidates_state(candidates,
  real_range, building_x, building_y)` → `{candidates}`: rect centered
  (half-side realRange, INCLUSIVE, center-in-rect — N2277 precedent).
  The pure only filters — entry dicts keep their keys intact (damaged /
  heal_suppressed / max_health untouched). Missing x/y → EXCLUDED. NO
  damaged/suppressed filter here (the heal_scan pure already does it).
- The scan runs AFTER the advance (same position as the current heal_scan
  call — realRange needs post-advance phase_heat); the driver computes
  real_range = range + phase_heat × phase_range_boost from the
  post-advance frame + block props (the SAME formula the heal_scan pure
  uses internally).
- Frame input `heal_candidates` (default [] — the live building index
  still defers).
- **No follow-through needed:** the N2242 test only pins the prefix
  `source_mend_projector_heal_scan_state(frame` (:135) — the worker
  verified the whole file.
- Scope corrections: eachBlock float-range overload is
  BlockIndexer.java:324–328 in `core/src/mindustry/ai/`, NOT `world/`;
  the rect is only the BROAD phase (:345), real admission is STRICT within
  circle + !privileged (:346) — documented deviation in the driver +
  DEFERRED (separate entry).
- DEFERRED entry 27 was partly stale (realRange fold now live) — the
  coordinator rewrote it at merge.
- SSOT +1/+1/+1/+2 (exactly the SCOPE estimate). DEFERRED 325→326 (−1+2,
  NOT −1+1 as scoped: the within/privileged refinement is a separate
  entry).

## Godot debt (this slice)

- NEW proof `C07MendProjectorHealScanRangeProof` (6 keys) — never run.
