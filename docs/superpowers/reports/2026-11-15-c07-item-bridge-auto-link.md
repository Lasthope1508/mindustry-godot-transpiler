# Report — N2199: ItemBridge placement auto-link (C07)

Date: 2026-11-15. Slice branch `slice/N2199-item-bridge-auto-link`, base
`c4ec49d0` (wave-2 tip). Status: **DONE (code + SSOT + neighbours + gate
clean except Godot; NOT merged into main; branch pushed per push-as-you-go
immediately after the docs commit — see STATUS.md).**

Done serially by coordinator lượt 3 (the slice touches the shared placement
flow — `SourceBlockPlacement.gd`, `PortGame.gd`, game state — so AGENTS.md
forbids delegating it to a worker). Slice commit `44fd1a77`; SSOT commit
`e354d757`.

## What changed

N2197 gave the item bridge its link frame state (frame keys `link` /
`had_valid_link` + pure configure + pure linkValid + the driver recompute
every tick) and N2188 wired the shouldConsume gate over it — but a bridge
placed by the player still started unlinked: the Java auto-link
(playerPlaced / findLink / lastBuild, ItemBridge.java:41, 167-173, 211-220)
was missing, so two bridges placed in a row never linked each other. N2199
is the placement auto-link:

- **Pure findLink** `source_item_bridge_find_link_state(...)` in
  `SourceItemBridgeBuildState.gd` — mirrors findLink (ItemBridge.java:167-173,
  `public Tile findLink(int x, int y){` with `Tile tile = world.tile(x, y);`
  and `if(tile != null && lastBuild != null && linkValid(tile, lastBuild.tile)
  && lastBuild.tile != tile && lastBuild.link == -1){` / `return
  lastBuild.tile;` / `return null;`), in Java's check order, calling the N2197
  pure linkValid with checkDouble=true (`return linkValid(tile, other, true);`,
  ItemBridge.java:147). Returns `{"found", "link_cell"}`.
- **Pure playerPlaced** `source_item_bridge_player_placed_state(...)` —
  mirrors playerPlaced (ItemBridge.java:210-219, `public void
  playerPlaced(Object config){` with `super.playerPlaced(config);` — the super
  is a no-op, BuildingComp.java:1350-1352 — `Tile link = findLink(tile.x,
  tile.y);`, `if(linkValid(tile, link) && this.link != link.pos() &&
  !proximity.contains(link.build)){`, `link.build.configure(tile.pos());`,
  and `lastBuild = this;`). The linkValid re-check is mirrored even though
  findLink already checked it (Java re-checks). `lastBuild` is recorded
  unconditionally, even when nothing is configured. Returns
  `{"configure_other", "other_cell", "config_value", "new_last_build_cell"}`.
- **Game lastBuild store** `source_item_bridge_last_build_by_block:
  Dictionary = {}` in `SourcePortGameBuildProjectorStatePortBridge.gd`, keyed
  by block id → Vector2i cell. `lastBuild` is a field on the Block
  (ItemBridge.java:41-42, `//for autolink` / `public @Nullable ItemBridgeBuild
  lastBuild;`) — one per block def, never cleared on removal, overwritten by
  the next placement of the same def. Java keeps the Building reference; the
  port keeps the origin cell and resolves the sprite through placed_blocks
  (the N2197 driver precedent).
- **Placement drivers** `source_item_bridge_auto_link_placement_state(...)`
  and the liquid twin
  `source_liquid_bridge_auto_link_placement_state(...)` (reusing the
  item-bridge pures through the N2198 preload — no new liquid symbols; the
  driver is wiring). The driver binds this frame if the tick has not bound
  it yet, reads the game lastBuild store, gathers the partner (STRICT def
  match: other block id == this block id, ItemBridge.java:152; team match;
  adjacency = Manhattan distance 1), calls the pure playerPlaced, applies
  the Integer configure to the partner frame through the N2197 pure
  configure, and records this cell as the new lastBuild for the def.
  Proximity is the 4 orthogonal same-team neighbours for a size-1 block
  (updateProximity, BuildingComp.java:1879-1896, over Edges.getEdges(block.size);
  Edges.java:20-37 gives (0,-1),(0,1),(-1,0),(1,0) for size 1), so the
  proximity check reduces to a Manhattan-distance-1 test once linkValid has
  required the team match.
- **PortGame dispatch**
  `source_item_bridge_player_placed_dispatch_state(sprite, block, cell)` in
  `PortGame.gd` (ItemBridge + BufferedItemBridge → item driver; LiquidBridge
  → liquid driver; else no-op), routed through the new
  `SourceSelectedBuildState.is_item_bridge / is_liquid_bridge` predicates
  (the PortGame convention — PortGame.gd never reads the implementation
  field off the block directly, `test_port_game_uses_selected_build_implementation_predicates`,
  which scans comments too). BufferedItemBridge routes to the item driver
  (it extends ItemBridge, BufferedItemBridge.java:9, no playerPlaced
  override). The method is named `..._dispatch_state`, NOT
  `..._player_placed_state` — see Fix 3.
- **Hook** in `SourceBlockPlacement.place_selected_block_at_world`, AFTER
  `record_placed_block`, guarded by `has_method` (FakePlacementGame in
  `BlockPlacementModuleProof` lacks the method). Java calls playerPlaced
  ONLY when the builder is the local player unit (ConstructBlock.java:106-109,
  `if(!headless && builder == player.unit()){` /
  `tile.build.playerPlaced(config);`), so the hook lives on the player path
  only — scenario/schematic placement (`add_source_block` /
  `source_place_schematic_state`) does not call it. NOT hooked in
  `record_placed_block` for the same reason.
- LiquidBridgeBuild extends ItemBridgeBuild with no playerPlaced override
  (LiquidBridge.java:7, :19) → auto-link applies to liquid bridges with
  their own per-def lastBuild (phase-conduit and bridge-conduit never share
  one). Catalog: phase-conveyor = ItemBridge, range 12, consumePower 0.3;
  bridge-conveyor = BufferedItemBridge, range 4, no power; phase-conduit =
  LiquidBridge, range 12, consumePower 0.3; bridge-conduit = LiquidBridge,
  range 4, no power.

## RED

Test module `tools/mindustry_godot_transpiler/tests/test_c07_item_bridge_auto_link.py`
+ register script `tools/mindustry_godot_transpiler/register_c07_item_bridge_auto_link.py`
written by coordinator lượt 3. Register script: EXACT_EXPRS = the 30 verified
exprs (all 30 unique, all present verbatim in upstream — script check,
0 missing), DEFERRED 252 entries (ledger N2198's 247 minus the resolved
auto-link entry plus 6 new: handlePlacementLine, pickedUp link reset, the
N2198 tick cross-def deviation, BufferedItemBridge link frame state,
schematic playerPlaced, drawPlace preview).

RED run: 4 tests, failures=2, errors=2 — `KeyError: 'N2199'`
(registration + exact-evidence), the missing pure function (state test), and
the proof test fails Godot-absent (`AssertionError: unexpectedly None` at
`assertIsNotNone(godot)`) — the expected no-Godot pattern on this VM.

## GREEN

- Pures + drivers in `SourceItemBridgeBuildState.gd` (findLink, playerPlaced,
  placement driver) and `SourceLiquidBridgeBuildState.gd` (liquid twin);
  PortGame dispatch in `PortGame.gd`; predicates in
  `SourceSelectedBuildState.gd`; hook in `SourceBlockPlacement.gd`; game var
  in `SourcePortGameBuildProjectorStatePortBridge.gd`. The limit-(6) comment
  in the ItemBridge power row now says auto-link is LIVE. Header quotes the
  exact exprs, each Java line on ONE comment line (the N2148 lesson).
- Proof scene `godot-mindustry/tools/runtime_proofs/C07ItemBridgeAutoLinkProof.gd`
  + `.tscn` (8 keys + registry_valid / one_headquarter_per_ssot / matches):
  find_link_finds_unlinked_last_build, find_link_rejects_linked_or_same_tile,
  player_placed_configures_partner, player_placed_skips_adjacent_partner,
  player_placed_skips_when_already_linked,
  player_placed_updates_last_build_without_partner,
  live_placement_auto_links_and_updates_last_build,
  live_liquid_placement_auto_links. Pack values: pack(28,21)=1835029,
  pack(31,21)=2031637, pack(32,21)=2097173, pack(31,25)=2031641. The proof
  calls the PortGame dispatch directly after record_placed_block (the N2197
  precedent); the hook line in place_selected_block_at_world is pinned by
  the Python test. Proof `.json` is gitignored (never stage, per AGENTS.md
  rule on proof .json).
- Register script: SSOT **11396/1640/1563/2917** (+10/+1/+3/+6 from the wave-2
  base 11386/1639/1560/2911); audit totalSourceFunctions 1335 → 1336 (the new
  PortGame dispatch method), legacyUnregisteredOwners 0. **No shard changed**
  (no distribution shard exists). Owner
  `SourceItemBridgeBuildState.source_item_bridge_player_placed_state`.
  Three register entries (findLink 2 result symbols, playerPlaced 4, PortGame
  dispatch 4) — the dispatch entry is REQUIRED, not decorative (see Fix 1).
- Targeted: **Ran 4 tests in 0.290s, 3/4 PASS** (registration, exact-evidence
  30/30, state) + 1 FAIL, the proof test, failing exactly
  `AssertionError: unexpectedly None` at `assertIsNotNone(godot)` — **no Godot
  binary exists on this VM** (user order 2026-11-15: no Godot runs here at all —
  no headless, no MCP, no editor). The proof scene is written but NEVER run;
  see GOAL.md §5 debt.
- Four fixes during the slice (all coordinator, all recorded here — see
  STATUS.md Fix 1–4 for the full story):
  - **Fix 1 (SSOT):** the PortGame dispatch is a non-static `func source_*`
    method, so the audit discovers it (`^func source_`, static funcs
    excluded) — the two pure-function entries alone left
    `port_game.source_item_bridge_player_placed_state` legacy-unregistered
    (audit 1336, legacy 1). Added the third register entry (4 result symbols
    + 1 contract + 2 schemas, owner `PortGame...`).
  - **Fix 2 (PortGame convention):** the dispatch first read
    `block.implementation` directly → `test_playable`
    `test_port_game_uses_selected_build_implementation_predicates` failed.
    Added `is_item_bridge` / `is_liquid_bridge` predicates to
    `SourceSelectedBuildState.gd` (via `implementation_name(block)`) and the
    dispatch calls them. Note: the assertNotIn scans comments too — the
    PortGame comment must not contain the literal field access either.
  - **Fix 3 (validator — gate run 1):** the catalog validator derives each
    contract's result schema from the FUNCTION name
    (`_contract_result_schema_name`), so a dispatch sharing the pure
    function's name resolved BOTH contracts to one result schema and failed
    the pure contract's `config_value` key (9 failures, all
    `return_schema_linkage`). Renamed the PortGame method to
    `..._player_placed_dispatch_state` (hook + proof + register + test
    followed) and deleted the stale SSOT entries. Lesson: a new non-static
    PortGame method must have a DIFFERENT function name from the pure
    function it dispatches to (the used_by fallback cannot match PortGame
    owners: canonical `port_game.` vs lowercased `portgame.`).
  - **Fix 4 (JSON sort — gate run 2, coordinator's own bug):** the stale-entry
    deletion script used `json.dump(..., sort_keys=True)`, sorting ALL keys
    in registry/contracts/schemas (582/2911 schemas reordered; 244k-line
    diff) and breaking 105 `*_registration` tests (they compare schema key
    ORDER against contract params). Fixed by `git checkout --
    godot-mindustry/src/generated/` + re-running the register script (the
    repo's writer preserves insertion order). Lesson: NEVER re-dump SSOT
    JSON with sort_keys — only edit through the repo's writers, or checkout
    + re-run register.

## Neighbours (coordinator, main thread)

Bridge family + hydration (9 modules / 38 tests): 30 PASS + 7 Godot-absent +
1 skipped, 0 other failures. Playable + reports (2338 tests): OK. The 9
tests that failed in gate run 1 (power generator/node + catalog validator)
re-run after Fix 3: 16 tests OK. A registration sample after Fix 4 (8 modules
/ 29 tests): 21 PASS + 8 Godot-absent proof tests, 0 other failures.
No regression.

## Gate

Full gate run 3 (PID 11877, coordinator main thread, launch 12:55, done 13:12 +07,
log `tools/mindustry_godot_transpiler/full-suite-n2199-gate3.log`, untracked):
Ran 5853 in 989.761s, failures=140, skipped=5, 0 errors — 140/140 verified
Godot-absent (136 inherited + 4 new proof tests N2197/N2188/N2198/N2199, all
confirmed present in the failures; 0 `ERROR:` lines).
Gate clean except Godot; no regression.
(Run 1, PID 7854, 12:17–12:33: Ran 5853 in 972.201s, failures=149 — 140
Godot-absent + 9 validator, Fix 3. Run 2, PID 10082, 12:37–12:54: Ran 5853 in
964.646s, failures=245 — 140 Godot-absent + 105 registration, Fix 4. Both runs
invalidated by their fixes; run 3 is the valid gate.)

## Commits

- Slice: `44fd1a77` — C07: N2199 ItemBridge placement auto-link, 10 files (+838/−1),
  on `slice/N2199-item-bridge-auto-link` (base `c4ec49d0`).
- SSOT: `e354d757` — 5 files (+1049/−4), 11396/1640/1563/2917, audit 1336, legacy 0.
- Docs: (this commit) — report + handoff + spec + GOAL for N2199.
- NOT merged into main. Branch pushed per push-as-you-go immediately after the
  docs commit (user order 12:08 + parent 12:26); push recorded in STATUS.md.

## Deferred (NOT this slice)

- handlePlacementLine (ItemBridge.java:184-193 — the port has no placement
  lines / BuildPlan list) and pickedUp link reset (:205-207) — own slices.
- drawPlace / drawPlanConfigTop preview (draw only) — own slice.
- BufferedItemBridge link frame state (no driver/frame at all) — own slice.
- Schematic/scenario playerPlaced (needs builder tracking) — own slice.
- **N2198 tick deviation:** the liquid tick driver accepts any LiquidBridge
  implementation as partner, but Java requires the SAME block def
  (ItemBridge.java:152) — a phase-conduit must not validate against a
  bridge-conduit. Needs its own fix slice + proof update.
- The driver-wide disabled early return (BuildingComp.java:1954-1957) —
  deferred (same deviation as N2188/N2198).
- Godot proof never run on this VM (no Godot here, user order) — debt in GOAL.md §5:
  `C07ItemBridgeAutoLinkProof`, commit carrying the scene `44fd1a77`, 8 keys
  (listed above + `registry_valid` / `one_headquarter_per_ssot` / `matches`),
  status "chờ agent Godot test". Run: targeted test
  `tests.test_c07_item_bridge_auto_link` with Godot 4.6.2 on PATH, port 7777 free.
- Next: items wave (N2200 Separator, N2201 WallCrafter, N2202 BeamDrill,
  N2203 BurstDrill, N2204 base Drill shouldConsume gates — briefs ready in
  `~/workspace/mindustry-parallel/`, scoping in `SCOPE-items-wave.md`) →
  liquids → payload → targets (see `DESIGN-frame-state-infra.md` in
  `~/workspace/mindustry-parallel/`).
