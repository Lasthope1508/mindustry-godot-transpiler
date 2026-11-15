# N2234 UnitCargoLoader updateTile Advance — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave advances-3, coordinator lượt 4).

## What this slice did

- UnitCargoLoader lost clear/readUnitId unbox/warmup/readyness/build/spawn as a pure advance in `SourceUnitCargoLoaderBuildState.gd` (UnitCargoLoader.java:92-133, file in `blocks/units/` NOT `blocks/payloads/`).
- 7 result symbols. Gate reads the PRE-advance unit so a spawn closes the INVERTED N2211 gate the NEXT tick.

## Key facts for the next agent

- **manifold does NOT set `useUnitCap = false`** (that line at UnitTypes.java:4612 belongs to assemblyDrone; default `useUnitCap = true`, UnitType.java:205) → canCreate is a genuinely live cap check.
- Cite corrections: build class :84 (not :85), readUnitId :86, progress :87, warmup :88, unit :89.
- Register: 50 exact exprs, 0 missing. DEFERRED: 259 (260 − 3 + 2 new: live unit fill, live canCreate check). **NO shard changes** (unit_building_slices only matches UnitFactory.java).
- Slice commit `a0b5eac9` (branch `slice/N2234-unit-cargo-loader-update-tile`, đã push 17:40); integration cherry-pick `e246e650`; SSOT gộp `b5129382` (11568/1675/1598/2987).

## Godot debt (this slice)

- `C07UnitCargoLoaderUpdateTileProof` — 6 keys (live_tick_advances_cargo_frame replaces frame_defaults_zero, N2228 precedent). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
