# N2277 RegenProjector Targets Computation Live Fill — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-6, integration branch `integration/wave-advances-6-n2274-n2280`, base `253151ad`).

## Source

`updateTargets()` (RegenProjector.java:115-119): `targets.clear(); taken.clear(); indexer.eachBlock(team, Tmp.r1.setCentered(x, y, range * tilesize), b -> true, targets::add);` Trigger in updateTile (:122-125): `if(lastChange != world.tileChanges){ lastChange = world.tileChanges; updateTargets(); }`. `range = 28` (**Blocks.java:2012, not :2011** — the brief and SCOPE §5 both said :2011; N2228 had fixed it once, the scope still had it wrong). `anyTargets = targets.contains(b -> b.damaged());` (:139) — the fold is live since N2228. The indexer is **BlockIndexer.java** (no Indexer.java exists at this pin); `eachBlock` :364-380, quadtree intersect :371, privileged filter :372. `taken` (:21) is only cleared (:117), never read at this pin — not porting it loses no behavior. **Java's query is hitbox-intersect, not center-in-rect** — the port uses center-in-rect (inclusive) as a documented deviation + new DEFERRED entry. `setCentered(x, y, range * tilesize)` is a SQUARE of side range*tilesize (not a circle) — no dst2. `damaged` is `health < maxHealth - 0.001f` (HealthComp.java:47-49).

## Implementation

`SourceRegenProjectorBuildState.gd`: pure `source_regen_projector_update_targets_state(frame, building_x, building_y, candidates)` → {targets, last_change, refreshed}. Refresh when `tile_changes != last_change`; scan same-team buildings whose center is inside the square (half-side 112.0, range 28); `damaged` computed in the pure per HealthComp; entries in the exact format the N2228 advance reads (pos, block_health, health, damaged, heal_suppressed). The driver runs the scan BEFORE the advance every tick (Java order :122-125), with a pre-check gate before gathering candidates; candidate center = drawx/drawy of the origin cell (RepairTurret precedent), pos = `tile_pos_state`, team/health from sprite metas. The projector itself is included (Java predicate `b -> true`). **No live world.tileChanges counter exists in the port** — the driver reads the frame input tile_changes as-is; the live counter is its own game-state slice (new DEFERRED entry).

## Commits

Slice `053860ff` (worker-N2277, branch `slice/N2277-regen-projector-targets-fill`, 5 files, +1043/−20, đã push, remote tip verified by ls-remote). Integration cherry-pick `0354f530` on `integration/wave-advances-6-n2274-n2280` (base 253151ad). ⚠️ **Register base discrepancy (coordinator handled at merge):** the worker built its register on ledger N2273 (291 entries) instead of the merged file (290), claiming the merged file was stale. The ledger snapshot actually holds PRE-WAVE versions of 6 entries (WallCrafter live fill, PayloadLoader dynamic power, Accelerator battery/canLaunch/launch, BuildTurret updateBuildLogic) + the WRONG Unloader dynamic power entry (removed at lượt 9) — the merge REJECTED all of those and took only the true delta (−1 resolve + 2 new). The merged file stays canonical; the wave cite fix d0ea2b64 touched this register's DEFERRED snapshot only.

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 25/25, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings (12/16 PASS: power + should-consume + second-consumers + update-tile), the fails all their Godot proof tests — 0 other failures. Full wave gate run 2 (PID 4988, launch 01:07 by coordinator lượt 10, done 01:47 +07 16/11): Ran 6210 in 2126.929s, failures=229, skipped=5, 0 errors — 229/229 Godot-absent (222 inherited + 7 new proof tests N2274–N2280). Run 1 (PID 2132, launch 00:31, done 01:07) invalid: Ran 5527, failures=231, errors=15 — all javalang-import (VM restart #6 ~00:27 wiped javalang; reinstalled 0.13.0 at 01:00).

## SSOT / DEFERRED

SSOT single-slice +3/+1/+1/+2 → 11798/1724/1655/3102; audit stays 1336. DEFERRED 292 in the slice register (291 − 1 resolved: targets computation live fill + 2 new: live tileChanges counter, hitbox overlap + privileged filter — on the worker's 291 base; the merged wave file applies the same delta to the canonical 290 base). Merged wave DEFERRED: 298 entries (DEFERRED-after-advances-6.py) — 290 − 9 resolved/removed + 17 new, resolved by entry TEXT not number. Entry 192 (updateTile live fill bundle) was narrowed at merge: the updateTargets clause is now live.

## Godot debt

`C07RegenProjectorTargetsFillProof` — 6 keys: targets_refresh_on_tile_change, targets_unchanged_without_tile_change, targets_only_same_team_in_rect, targets_include_damaged_flag, rect_is_square_not_circle, live_tick_refreshes_targets (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
