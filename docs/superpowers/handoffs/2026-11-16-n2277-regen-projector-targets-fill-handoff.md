# N2277 RegenProjector Targets Computation Live Fill — Handoff

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-6, integration branch `integration/wave-advances-6-n2274-n2280`, base `253151ad`).

## What this slice did

RegenProjector updateTargets live fill: pure `source_regen_projector_update_targets_state` → 3 keys (targets, last_change, refreshed). Refresh when tile_changes != last_change; scan same-team buildings whose center is inside the square of side range×tilesize (half-side 112.0, range 28); entries in the exact format the N2228 advance reads.

## Key facts for the next agent

- **range = 28 is Blocks.java:2012, not :2011** (the brief and SCOPE §5 both said :2011).
- **The indexer is BlockIndexer.java** (no Indexer.java at this pin); eachBlock :364-380, quadtree intersect :371, privileged filter :372.
- **Java's query is hitbox-intersect, not center-in-rect** — the port uses center-in-rect (inclusive) as a documented deviation + new DEFERRED entry.
- `taken` (:21) is only cleared (:117), never read at this pin — not porting it loses no behavior. The projector itself is included (Java predicate `b -> true`). `damaged` is `health < maxHealth - 0.001f` (HealthComp.java:47-49).
- **No live world.tileChanges counter exists in the port** — the driver reads the frame input as-is; the live counter is its own game-state slice (new DEFERRED entry). mendMap flush is NOT this slice.
- ⚠️ **Register base lesson:** the worker built its register on ledger N2273 (291 entries) instead of the merged file (290) — its snapshot held PRE-WAVE versions of 6 entries + the wrong Unloader dynamic power entry. The merge rejected all of those and took only the true delta. The merged DEFERRED file stays canonical.
- SSOT +3/+1/+1/+2 → 11798/1724/1655/3102 (audit 1336). Exact-evidence 25/25. DEFERRED 292 in the slice register (−1 resolved + 2 new: live tileChanges counter, hitbox overlap + privileged filter).

## Godot debt (this slice)

`C07RegenProjectorTargetsFillProof` — 6 keys: targets_refresh_on_tile_change, targets_unchanged_without_tile_change, targets_only_same_team_in_rect, targets_include_damaged_flag, rect_is_square_not_circle, live_tick_refreshes_targets (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Targeted test: `tests.test_c07_regen_projector_targets_fill`. Do NOT mark done until it passes there.
