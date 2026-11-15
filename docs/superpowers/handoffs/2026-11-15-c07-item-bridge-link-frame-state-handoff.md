# Handoff — N2197 ItemBridge link frame state

Date: 2026-11-15. Single-slice integration (branch
`integration/n2197-item-bridge-link`). Status: **DONE (code + SSOT + neighbours +
gate clean except Godot; slice bd07c93d, SSOT fe328383; NOT pushed,
NOT merged).**

Worker: worker-N2197, done 11:13 +07; worker handoff arrived 11:13 +07 and
matched every coordinator-verified number. Coordinator verified the commit,
the register run, and the targeted run directly from git. No coordinator code
fix needed (one DESIGN doc correction — see GREEN).

## Scoping (DONE 2026-11-15 ~10:5x +07, coordinator — design doc)

- N2188 stopped at scoping in wave 1 (10:10, no code): `hadValidLink` is
  recomputed every tick from `link` (ItemBridge.java:332-333), but the port
  stored no `link` and no config of any kind on a placed building
  (`record_placed_block` takes no config, placement never calls
  `playerPlaced`). A link cannot be inferred from geometry (two unconfigured
  bridges in range still have `hadValidLink = false` in Java; checkDouble
  needs the partner build's `link`).
- Java ground truth verified from upstream (see
  `DESIGN-frame-state-infra.md` in `~/workspace/mindustry-parallel/`):
  `Building.configure` only saves `block.lastConfig` + sends
  `Call.tileConfig` (BuildingComp.java:382-386); real application is
  `configured()` (:1414-1439) dispatching via `block.configurations`;
  `config()` defaults null (:2024-2026). ItemBridge config handlers (:64,
  :66), `linkValid` (:145, :149-156), `positionsValid` (:157-166),
  `findLink` (:167-173), `public int link = -1;` (:198),
  `hadValidLink` (:202), `playerPlaced` (:211), `updateTile` (:319-347),
  `shouldConsume` (:495-496), `config()` (:500-502). Update order:
  `updateConsumption()` then `updateTile()` (:2274-2277). arc Point2
  pack/unpack (Point2.java:35-42).
- The slice touches ONLY the ItemBridge family file + new files (no shared
  PortGame/PlacedBlock/Placement files), so a worker could do it like a
  normal slice; the coordinator integrates + runs SSOT after.
- SSOT baseline re-verified from the generated JSONs (main de9ab89c, N2185 DONE):
  symbols 11380 + slices 1636 + contracts 1557 + schemas 2905; audit
  `totalSourceFunctions` 1335. Expected after N2197: **11382/1637/1558/2907**
  — reached at the register run. No shard change expected (no distribution
  shard exists) — confirmed.

## Design (decided in scoping, recorded in test + register)

- Config enters the frame via a per-family pure configure function, NOT via
  sprite meta (this phase): the runtime state is the Java build field
  (`link`), the config object is only a transient input. Frame keys `link`
  (default -1) + `had_valid_link` (default false); every default comes from
  the Java field default — no invented defaults.
- `had_valid_link` is a frame key recomputed by the driver each tick AFTER
  the consumption fold (the Java update order), so the gate reads the
  previous tick's value, exactly like Java. Pure core
  `source_item_bridge_link_valid_state(...)` takes explicit inputs (tile pos,
  other pos, range, block-match flag, team-match flag, other link, this pos);
  the driver gathers inputs (partner sprite lookup through placed_blocks by
  the unpacked link cell; the partner's frame link).
- Placement auto-link (playerPlaced + findLink + lastBuild) is a separate
  later slice (N2199): it needs game-level `lastBuild` state + cross-build
  configure at placement (shared files). N2188 does NOT need auto-link: the
  proof sets the link directly through the pure configure.
- The gate does NOT change in this slice — N2188 wires it.
- Proof scene `C07ItemBridgeLinkFrameStateProof.gd/.tscn` (6 keys, N2185 pattern).

## RED (DONE 2026-11-15 ~11:0x +07, worker-N2197)

- Test module `tools/mindustry_godot_transpiler/tests/test_c07_item_bridge_link_frame_state.py`
  + register script `tools/mindustry_godot_transpiler/register_c07_item_bridge_link_frame_state.py`.
- Register script verified standalone: **exit 0**. **31 exact exprs, 0 missing**;
  DEFERRED 248 entries. OWNER
  `SourceItemBridgeBuildState.source_item_bridge_link_valid_state`, PROOF
  `/root/C07ItemBridgeLinkFrameStateProof`.
- Targeted RED run: failures=2, errors=2 — `KeyError: 'N2197'`
  (registration + exact-evidence) and the missing pure functions (row-state);
  proof test fails Godot-absent (`AssertionError: unexpectedly None` at
  `assertIsNotNone(godot)`). No other failures. `git diff --check` clean.

## GREEN (DONE 2026-11-15 11:13 +07, worker-N2197)

- Frame keys + pure configure + pure linkValid + driver recompute in
  `SourceItemBridgeBuildState.gd` (5 files, +621/−8); proof scene (6 keys);
  all 31 exact exprs present, each on ONE comment line. 6 wrong build-field
  line refs in the family comments fixed (link :202→:198, incoming :203→:199,
  warmup :204→:200, time :205→:201, wasMoved :206→:202,
  transportCounter :207→:203).
- SSOT at GREEN (coordinator register run): **11382/1637/1558/2907**, audit 1335,
  no shard changed. `git diff --check` clean.
- Targeted run: **Ran 4 tests in 0.269s, 3/4 PASS** (registration,
  exact-evidence 31/31, row-state) + proof test FAIL, exactly
  `AssertionError: unexpectedly None` — no Godot on this VM (user order: no
  Godot runs here at all). In the worker worktree the run showed failures=1,
  errors=2 — the 2 errors are the `KeyError: 'N2197'` from the reverted
  `generated/`, exactly per process.
- DESIGN correction (coordinator): the worker spotted that DESIGN §4.2 said
  hadValidLink was computed "before the consumption fold", contradicting the
  brief and the real Java (BuildingComp.java:2274-2277, AFTER). The worker
  followed the brief/Java; the coordinator fixed DESIGN §4.2 with a dated
  correction note. No code change.
- No coordinator code fix: correct Java order (recompute after the fold) and
  correct Point2 pack/unpack (verified by Python simulation) from the start.
  The `range` parameter shadows a GDScript builtin (per the brief's
  signature) — no ERROR is produced; the first Godot run will confirm.

## Neighbours (DONE 2026-11-15 ~11:1x +07, single-slice — coordinator, main thread)

- New targeted 3/4 (1 Godot-absent). Family bridge power_status (4 modules /
  16 tests): 12/16 PASS, 4 Godot-absent. Wiring-standard set (9 modules /
  32 tests): 23/32 PASS, 9 Godot-absent. **Total 38/52 PASS, 14 Godot-absent,
  0 other failures, 0 `ERROR:` lines — no regression.**
  Log `n2197-neighbours.log` (untracked).

## Exact exprs (31, all verified verbatim at scoping — script check, 0 missing)

See `register_c07_item_bridge_link_frame_state.py` EXACT_EXPRS (31 entries,
including the config handlers, `linkValid` + `positionsValid`, the build
fields, the updateTile link lines, and the arc Point2 pack/unpack).

## Next

- Wave 2 {N2188 ItemBridge gate (slice done 11:21, `c490f99e`, awaiting
  integration) + N2198 LiquidBridge gate (worker running)} — integrate on a
  new branch from `fe328383` (cherry-pick both slices + SSOT + neighbours +
  gate + docs). **Integration note: the N2197 test pins the pre-gate driver
  line** (`test_c07_item_bridge_link_frame_state.py:222` asserts
  `var should_consume: bool = bool(frame.get("enabled", true))` with the
  comment "N2188 wires the gate") — the wave-2 integration updates that
  assertion to the new gate line (coordinator fix, by design).
- After wave 2: N2199 auto-link (playerPlaced + findLink + lastBuild) →
  items → liquids → payload → targets → plans → units (see
  `DESIGN-frame-state-infra.md` in `~/workspace/mindustry-parallel/`).
- The driver-wide disabled early return (BuildingComp.java:1954-1957) is a
  separate fix slice (N2191/N2192/N2194/N2195 document the stale-efficiency
  deviation).
- Godot proof debt: `C07ItemBridgeLinkFrameStateProof`, 6 keys, status
  "chờ agent Godot test" (GOAL.md §5).

## Commits

- Slice: `bd07c93d` — C07: N2197 ItemBridge link frame state, 5 files (+621/−8).
- Integration: slice cherry-pick `6a094cda` on
  `integration/n2197-item-bridge-link`; SSOT `fe328383` (11382/1637/1558/2907,
  4 files, +557, no shard change).
- Docs: (this commit) — report + handoff + spec + GOAL for N2197.

## Gate (DONE 2026-11-15 11:39 +07, log `full-suite-n2197-gate.log`, single-slice)

Full gate attempt 1 (PID 24699, coordinator main thread, launch 11:20 +07)
was killed by a VM restart ~11:22 (log frozen at 3637 bytes, no footer).
Attempt 2 (PID 1944, coordinator main thread, launch 11:24, done 11:39 +07,
log `tools/mindustry_godot_transpiler/full-suite-n2197-gate.log`, untracked):
Ran 5841 in 945.797s, failures=137, skipped=5, 0 errors — 137/137 verified
Godot-absent (136 inherited + 1 new proof test N2197, confirmed present in
the failures; 0 `ERROR:` lines). Gate clean except Godot; no regression.
