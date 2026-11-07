# Handoff — Executable Tile changeBuild / changed / full two-pass setBlock (N2029–N2031)

Date: 2026-11-07. Parent: `3890f39` (WIP backup 2026-11-07). Sequential C01–C12 goal. Read with `docs/superpowers/handoffs/2026-11-02-mindustry-completion-backlog.md` and `docs/superpowers/reports/2026-11-07-tile-change-build-set-block.md`; this handoff does not replace upstream Java or root SSOT.

## What this slice did

Composed the N2026–N2028 proximity/pre-change primitives into executable Tile mutations on actual Tile dictionaries, in `godot-mindustry/src/game/SourceBlockGeometry.gd`:

- **N2029 `source_apply_tile_change_build`** — removes the old Building, updates each unique edge Building once through the canonical edge owner, creates a new Building only when the new Block has one, `init_update = block.update && !state.isEditor()`.
- **N2030 `source_apply_tile_changed`** — own-build or non-changing `Geometry.d4` neighbour proximity outside generation, gated change event, static recache.
- **N2031 `source_apply_tile_set_block`** — full `setBlock` in source order: static guard, `forceTeam`, `preChanged`, block assign, `changeBuild` (rotation `posmod 4`), `build.team()`, multiblock two-pass with fresh lookups per pass, `changed`, `changing = false`, `block.blockChanged(this)`.

SSOT delta: **61 symbols / 3 input schemas / 3 void contracts / 3 slices**. Totals now: **10141 symbols / 1486 slices / 1375 contracts / 2540 schemas**. Content 425 blocks; manifest 100 direct modules; expanded validation 113 modules.

## How it was verified

- RED first: registration test failed with `KeyError: 'N2029'` / `'N2030'` / `'N2031'` before the registration script ran.
- Targeted: registration test OK, exact-evidence test OK (all 61 symbol exprs + ledger exprs exact against `Tile.java` at pinned upstream `2bdedfed25932ebf11330d3584092c50e2e26d96`), `test_tile_slice` 41 OK, proximity void-catalog tests 6 OK.
- Catalog: 0 errors, JSON modules 0 errors / 113 modules. `git diff --check` clean.
- Godot proof: `TileChangeBuildSetBlockProof` — all 15 checks true, `matches=true`, Godot `4.6.2.stable.official.71f334935` headless. Proof JSON at `godot-mindustry/tools/runtime_proofs/TileChangeBuildSetBlockProof.json`.
- Two environment fixes were needed on a fresh Linux checkout and are NOT part of the slice: (1) upstream checkouts were missing, so `mindustry-upstream/` was populated from the pinned-commit tarball and `arc-upstream/` likewise (`f30acd23…`); both are gitignored. (2) The Godot proof first failed with `ERROR: Unrecognized UID: "uid://csajjlruh8jey"` (MCPRuntime autoload) plus one wrong fixture lookup; fixed by running `godot --headless --path godot-mindustry --import` once to build the gitignored `.godot/` cache, and by correcting the size-2 edge fixture to real `edge_points_state(2)` offsets. If a proof run shows UID errors on a fresh checkout, import first.
- Full Python suite was started in the background when this slice was committed; check `/tmp/full-suite-n2029.log` before treating the push as fully gated. Editor parse and deterministic replay are part of that gate.

## Files in this slice (stage/commit exactly these)

- `godot-mindustry/src/game/SourceBlockGeometry.gd` (3 new `source_apply_*` functions + `SourceBlockPlanGeometryState` preload)
- `godot-mindustry/src/generated/source_symbol_registry.json`, `source_slice_ledger.json`, `source_api_contracts.json`, `source_state_schema.json`, `source_symbol_audit_report.json` (audit totals unchanged; diff is a reorder of `sourceFunctions`)
- `godot-mindustry/tools/runtime_proofs/TileChangeBuildSetBlockProof.gd`, `TileChangeBuildSetBlockProof.tscn`
- `tools/mindustry_godot_transpiler/register_tile_change_build_set_block.py`, `tools/mindustry_godot_transpiler/tests/test_tile_change_build_set_block.py`
- `docs/superpowers/reports/2026-11-07-tile-change-build-set-block.md`, `docs/superpowers/handoffs/2026-11-07-tile-change-build-set-block-handoff.md`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md` (totals 1483 → 1486, N2029–N2031 checklist/table/log rows)

Do NOT stage `mindustry-upstream/`, `arc-upstream/`, `.godot/`, `godot-mindustry/project.godot`, or `*.gd.uid` (gitignored / known workspace noise).

## What is still open (next batch)

1. Bind N2029–N2031 at production placement and world reload: actual Building/proximity/Team state, real `changeBuild`/`setBlock` call sites, entity group removal/init through the real provider, actual event/renderer/pathfinder context. Bind multiblock pass-0 `setBlock(Blocks.air)` to the real recursive `setBlock`; the proof probe only records the call.
2. Superclass `noSleep` with actual `sleepTime`/`sleeping`/group/`sleepingEntities`; power `onProximityRemoved`/`Added` and turret unregister with actual domain hooks.
3. Controller pickup/world transitions, remaining Tile/Floor side effects. Then C02 output/dump/transport, C03 power, C04 liquid, C05 consumer init, C06 full gameplay loop, C07 units/waves, C08 null-body classification, C09 facade debt, C10 save/load/network, C11 UI/audio/perf, C12 clean-checkout release candidate.

No whole-domain acceptance or parity percentage is inferred from ledger counts.
