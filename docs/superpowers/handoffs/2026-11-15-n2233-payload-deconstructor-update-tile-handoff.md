# N2233 PayloadDeconstructor updateTile Advance — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave advances-3, coordinator lượt 4).

## What this slice did

- PayloadDeconstructor dump/progress/accum/transfer/finish + moveInPayload intake as a pure advance in `SourcePayloadDeconstructorBuildState.gd` (PayloadDeconstructor.java:109-204).
- 10 result symbols. **progress += shift (NOT realShift — can exceed 1)**; proof pins 1.05. payRotation uses edelta, moveIn uses delta.

## Key facts for the next agent

- UnitPayload buildTime = `unit.type.getBuildTime()` (UnitPayload.java:66-68) — the scope's `unit.buildTime` was WRONG.
- Guard `shift = 0` when build_time <= 0 protects the minimal N2166/N2210 fixtures (N2222 precedent).
- Register: 68 exact exprs, 0 missing. DEFERRED: 262 (260 − 1 + 3 new: puddles dump, moveIn live payload positioning, Fx.breakBlock finish effect).
- Slice commit `1b5264f8` (branch `slice/N2233-payload-deconstructor-update-tile`, đã push 17:41); integration cherry-pick `8040e691`; SSOT gộp `b5129382` (11568/1675/1598/2987).

## Godot debt (this slice)

- `C07PayloadDeconstructorUpdateTileProof` — 7 keys (6 scope + live_tick_advances_progress). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
