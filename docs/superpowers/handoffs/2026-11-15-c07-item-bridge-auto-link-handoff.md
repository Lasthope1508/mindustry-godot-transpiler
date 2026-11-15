# Handoff — N2199 ItemBridge placement auto-link

Date: 2026-11-15. Slice branch `slice/N2199-item-bridge-auto-link`, base
`c4ec49d0` (wave-2 tip). Status: **DONE (code + SSOT + neighbours + gate
clean except Godot; slice 44fd1a77, SSOT e354d757; NOT merged into main;
branch pushed per push-as-you-go immediately after the docs commit).**

Done serially by coordinator lượt 3 (shared placement flow — AGENTS.md
forbids delegating it to a worker). No worker involved.

## Scoping (DONE 2026-11-15 ~12:0x +07, brief-n2199-auto-link.md)

- `lastBuild` is a per-block-def field on the Block (ItemBridge.java:41-42,
  `//for autolink` / `public @Nullable ItemBridgeBuild lastBuild;`), never
  cleared on removal; `findLink(x, y)` (:167-173) returns lastBuild.tile iff
  tile != null && lastBuild != null && linkValid(tile, lastBuild.tile)
  [checkDouble=true] && lastBuild.tile != tile && lastBuild.link == -1;
  `playerPlaced(config)` (:210-219) does `Tile link = findLink(tile.x,
  tile.y); if(linkValid(tile, link) && this.link != link.pos() &&
  !proximity.contains(link.build)){ link.build.configure(tile.pos()); }
  lastBuild = this;` (unconditional); super.playerPlaced is a no-op
  (BuildingComp.java:1350-1352).
- playerPlaced is called ONLY when the builder is the local player unit
  (ConstructBlock.java:106-109, `if(!headless && builder == player.unit()){
  tile.build.playerPlaced(config);}`), with plan config applied first via
  configured (:93).
- Proximity for a size-1 block = 4 orthogonal same-team neighbours
  (updateProximity, BuildingComp.java:1879-1896, over Edges.getEdges(block.size);
  Edges.java:20-37 gives (0,-1),(0,1),(-1,0),(1,0) for size 1) → the proximity
  check reduces to a Manhattan-distance-1 test once linkValid has required a
  team match.
- LiquidBridgeBuild extends ItemBridgeBuild with no playerPlaced override
  (LiquidBridge.java:7, :19) → auto-link applies to liquid bridges with their
  own per-def lastBuild.
- A DESIGN-vs-Java note from N2197 stands: the driver recompute runs AFTER
  the consumption fold (Java order, BuildingComp:2274-2277).
- SSOT baseline re-verified from the generated JSONs (base `c4ec49d0`):
  symbols 11386 + slices 1639 + contracts 1560 + schemas 2911; audit
  `totalSourceFunctions` 1335. Expected after N2199 (scoping estimate):
  **11392/1640/1562/2915** — WRONG, because scoping did not anticipate the
  PortGame dispatch entry (Fix 1): actual **11396/1640/1563/2917**, audit
  1336, legacy 0. No shard change expected (no distribution shard exists) —
  confirmed.

## Design (decided in scoping, recorded in test + register)

- Pure `source_item_bridge_find_link_state(...)` → `{found, link_cell}`;
  calls the N2197 pure linkValid internally (check_double=true), Java check
  order.
- Pure `source_item_bridge_player_placed_state(...)` → `{configure_other,
  other_cell, config_value, new_last_build_cell}`; calls find_link, re-checks
  linkValid (as Java does), then this.link and proximity checks;
  new_last_build_cell is always this tile.
- Driver `source_item_bridge_auto_link_placement_state(game, sprite, block,
  cell)` in SourceItemBridgeBuildState.gd: gathers inputs (lastBuild dict
  from game keyed by block id; partner sprite via placed_blocks; bind frame
  if missing for both this and partner; STRICT def match: other block id ==
  this block id; team match; adjacency = Manhattan 1), calls pure
  playerPlaced, applies configure to partner frame via N2197 pure configure
  (Integer = packed absolute pos), updates lastBuild dict.
- Liquid twin `source_liquid_bridge_auto_link_placement_state(...)` in
  SourceLiquidBridgeBuildState.gd reusing the item-bridge pures via preload
  (N2198 precedent); no new liquid symbols (driver is wiring).
- lastBuild store: game var `source_item_bridge_last_build_by_block:
  Dictionary = {}` in `SourcePortGameBuildProjectorStatePortBridge.gd`
  (block id → Vector2i cell). Java stores the Building ref; the port stores
  the origin cell and resolves via placed_blocks (N2197 driver precedent).
- PortGame method `source_item_bridge_player_placed_dispatch_state(sprite,
  block, cell)` dispatching by implementation via the new
  `SourceSelectedBuildState.is_item_bridge / is_liquid_bridge` predicates
  (ItemBridge + BufferedItemBridge → item driver; LiquidBridge → liquid
  driver; else no-op). The `_dispatch` infix is REQUIRED (Fix 3): the
  catalog validator derives result schemas from function names.
- Hook in `SourceBlockPlacement.place_selected_block_at_world` AFTER
  `record_placed_block`, guarded: `if
  game.has_method("source_item_bridge_player_placed_dispatch_state"):
  game.call(...)`. The has_method guard is REQUIRED: FakePlacementGame in
  `BlockPlacementModuleProof.gd` lacks the method. NOT hooked in
  record_placed_block because scenario/schematic placement does not call
  playerPlaced in Java.
- Catalog facts: phase-conveyor = ItemBridge, range 12, consumePower 0.3;
  bridge-conveyor = BufferedItemBridge, range 4, no power; phase-conduit =
  LiquidBridge, range 12, consumePower 0.3; bridge-conduit = LiquidBridge,
  range 4, no power.
- Proof scene `C07ItemBridgeAutoLinkProof.gd/.tscn` (8 keys, N2185 pattern).

## RED (DONE 2026-11-15 ~12:0x +07, coordinator lượt 3)

- Test module `tools/mindustry_godot_transpiler/tests/test_c07_item_bridge_auto_link.py`
  + register script `tools/mindustry_godot_transpiler/register_c07_item_bridge_auto_link.py`.
- Register script verified standalone: **exit 0**. **30 exact exprs, 0 missing**;
  DEFERRED 252 entries. OWNER
  `SourceItemBridgeBuildState.source_item_bridge_player_placed_state`, PROOF
  `/root/C07ItemBridgeAutoLinkProof`.
- Targeted RED run: 4 tests, failures=2, errors=2 — `KeyError: 'N2199'`
  (registration + exact-evidence), the missing pure function (state test),
  proof test fails Godot-absent (`AssertionError: unexpectedly None` at
  `assertIsNotNone(godot)`). No other failures. `git diff --check` clean.

## GREEN (DONE 2026-11-15 12:17 +07, coordinator lượt 3)

- Pures + drivers + dispatch + predicates + hook + game var (10 files,
  +838/−1); proof scene (8 keys); all 30 exact exprs present, each on ONE
  comment line. The limit-(6) comment in the ItemBridge power row now says
  auto-link is LIVE.
- SSOT at GREEN: **11396/1640/1563/2917**, audit 1336, legacy 0, no shard
  changed. `git diff --check` clean.
- Targeted run: **Ran 4 tests in 0.290s, 3/4 PASS** (registration,
  exact-evidence 30/30, state) + proof test FAIL, exactly
  `AssertionError: unexpectedly None` — no Godot on this VM (user order: no
  Godot runs here at all).
- Four fixes during the slice (see the report for detail): Fix 1 (dispatch
  register entry — audit discovery), Fix 2 (predicate dispatch — PortGame
  convention), Fix 3 (dispatch rename — validator name derivation, found by
  gate run 1), Fix 4 (JSON sort_keys bug — coordinator's own bug, found by
  gate run 2; fixed by checkout + re-run register).

## Neighbours (DONE 2026-11-15 ~12:3x +07, coordinator, main thread)

- Bridge family + hydration (9 modules / 38 tests): 30 PASS + 7 Godot-absent
  + 1 skipped, 0 other failures. Playable + reports (2338 tests): OK.
  Gate-run-1's 9 failed tests re-run after Fix 3: 16 tests OK. Registration
  sample after Fix 4 (8 modules / 29 tests): 21 PASS + 8 Godot-absent proof
  tests, 0 other failures. No regression.

## Exact exprs (30, all verified verbatim at scoping — script check, 0 missing)

See `register_c07_item_bridge_auto_link.py` EXACT_EXPRS (30 entries,
including findLink `public Tile findLink(int x, int y){`, the playerPlaced
gate `if(linkValid(tile, link) && this.link != link.pos() &&
!proximity.contains(link.build)){`, `lastBuild = this;`, the player-only
call site `if(!headless && builder == player.unit()){`, the proximity
lines, and the LiquidBridge extends lines).

## Next

- Items wave (N2200 Separator, N2201 WallCrafter, N2202 BeamDrill, N2203
  BurstDrill, N2204 base Drill shouldConsume gates — briefs ready in
  `~/workspace/mindustry-parallel/`, scoping in `SCOPE-items-wave.md`) →
  liquids → payload → targets → plans → units (see
  `DESIGN-frame-state-infra.md` in `~/workspace/mindustry-parallel/`).
- Standalone coordinator-serial work still pending: the driver-wide disabled
  early return fix (BuildingComp.java:1954-1957); the raw-delta audit of
  remaining runtime files; the N2198 tick cross-def fix slice.
- Godot proof debt: `C07ItemBridgeAutoLinkProof`, 8 keys, status
  "chờ agent Godot test" (GOAL.md §5).

## Commits

- Slice: `44fd1a77` — C07: N2199 ItemBridge placement auto-link, 10 files (+838/−1).
- SSOT: `e354d757` — 5 files (+1049/−4), 11396/1640/1563/2917, audit 1336, legacy 0.
- Docs: (this commit) — report + handoff + spec + GOAL for N2199.

## Gate (DONE 2026-11-15 13:12 +07, log `full-suite-n2199-gate3.log`)

Full gate run 3 (PID 11877, coordinator main thread, launch 12:55, done 13:12 +07,
log `tools/mindustry_godot_transpiler/full-suite-n2199-gate3.log`, untracked):
Ran 5853 in 989.761s, failures=140, skipped=5, 0 errors — 140/140 verified
Godot-absent (136 inherited + 4 new proof tests N2197/N2188/N2198/N2199, all
confirmed present in the failures; 0 `ERROR:` lines).
Gate clean except Godot; no regression.
(Run 1, PID 7854, 12:17–12:33: Ran 5853 in 972.201s, failures=149 — 140
Godot-absent + 9 validator, Fix 3. Run 2, PID 10082, 12:37–12:54: Ran 5853 in
964.646s, failures=245 — 140 Godot-absent + 105 registration, Fix 4.)
