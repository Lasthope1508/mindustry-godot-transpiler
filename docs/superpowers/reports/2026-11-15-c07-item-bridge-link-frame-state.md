# Report — N2197: ItemBridge link frame state (C07, infra)

Date: 2026-11-15. Single-slice integration (branch
`integration/n2197-item-bridge-link`). Status: **DONE (code + SSOT + neighbours +
gate clean except Godot; NOT pushed, NOT merged — local branches only, per user order).**

Worker: worker-N2197 (coordinator-verified; worker handoff arrived 11:13 +07
and matched every coordinator-verified number). Slice commit `bd07c93d` on
`slice/N2197-item-bridge-link-frame-state`; no worker SSOT commit (the worker
ran the register script to verify, then reverted `generated/` per
BRIEF-COMMON — the coordinator ran the register at integration).
Integration cherry-pick: slice `6a094cda`; SSOT `fe328383`.

## What changed

N2188 (ItemBridge shouldConsume gate) stopped at scoping in wave 1: the port
stored no `link` and no config of any kind on a placed building, so
`hadValidLink` — recomputed every tick from `link` (ItemBridge.java:332-333,
`Tile other = world.tile(link);` / `hadValidLink = linkValid(tile, other);`) —
could not be computed at all. N2197 is the link frame-state infra that
unblocks it (see `DESIGN-frame-state-infra.md` in
`~/workspace/mindustry-parallel/`):

- Frame keys `link` (default -1, the Java field default,
  ItemBridge.java:198, `public int link = -1;`) and `had_valid_link`
  (default false, ItemBridge.java:202) on the ItemBridge family frame,
  in `_initial_frame()` and preserved in the tick-frame.
- Pure `source_item_bridge_configure_state(frame, config)` mirroring the two
  config handlers in the ItemBridge constructor (:64, :66): Point2 relative
  (`{x, y}` + tile pos, packed) / Integer absolute (assigned directly).
  Config is a transient input through `configured()` (BuildingComp.java:382-386,
  :1414-1439); the frame key `link` is the runtime state, mirroring the Java
  build field. Sprite-meta config is deferred to C10 (rebuild/schematic).
- Pure `source_item_bridge_link_valid_state(...)` mirroring `linkValid`
  (:145, :149-156) + `positionsValid` (:157-166), with private helpers
  `_point2_pack` / `_point2_unpack` / `_to_short` (arc Point2.java:35-42;
  GDScript ints are 64-bit, so the short must be masked and sign-extended).
  Pack/unpack verified by a Python simulation (round-trip, unpack(-1) = (-1,-1)).
- The driver recomputes `had_valid_link` every tick AFTER the consumption
  fold, only when enabled — the Java order (`updateConsumption()` then
  `updateTile()`, BuildingComp.java:2274-2277; ItemBridge
  `noUpdateDisabled = true;`, ItemBridge.java:54). The gate (N2188) reads the
  previous tick's value, exactly like Java.
- **The gate does NOT change in this slice:** the driver still folds with
  `should_consume=true` when enabled. N2188 wires
  `should_consume = had_valid_link && enabled` (ItemBridge.java:495-496).
- The worker also fixed 6 wrong build-field line refs in the family comments
  (link :202→:198, incoming :203→:199, warmup :204→:200, time :205→:201,
  wasMoved :206→:202, transportCounter :207→:203).

## RED

Test module `tools/mindustry_godot_transpiler/tests/test_c07_item_bridge_link_frame_state.py`
+ register script `tools/mindustry_godot_transpiler/register_c07_item_bridge_link_frame_state.py`
written by worker-N2197. Register script: EXACT_EXPRS = the 31 verified exprs
(all 31 unique, all present verbatim in upstream — script check, 0 missing),
DEFERRED 248 entries (245 carried from N2193, minus the resolved entry
`ItemBridge link / findLink / linkValid rows`, plus 4 new deferrals:
auto-link, transport advance, config() getter/rebuild, draw/config UI).
The `ItemBridge shouldConsume gate` entry is KEPT for N2188.

RED run: failures=2, errors=2 — `KeyError: 'N2197'` (registration +
exact-evidence) and the missing pure functions (row-state); the proof test
fails Godot-absent (`AssertionError: unexpectedly None` at
`assertIsNotNone(godot)`) — the expected no-Godot pattern on this VM.

## GREEN

- Pure configure + linkValid + driver recompute in
  `godot-mindustry/src/game/SourceItemBridgeBuildState.gd`; header quotes the
  exact exprs. Documented limits updated (link state LIVE, gate still N2188).
- Proof scene `godot-mindustry/tools/runtime_proofs/C07ItemBridgeLinkFrameStateProof.gd`
  + `.tscn` (6 keys + registry_valid / one_headquarter_per_ssot / matches).
  Proof `.json` is gitignored (never stage, per AGENTS.md rule on proof .json).
- Register script run by the coordinator at integration: SSOT **11382/1637/1558/2907**
  (+2/+1/+1/+2 from baseline 11380/1636/1557/2905); audit 1335 unchanged;
  ledger N2197 status done. **No shard changed** (no distribution shard
  exists — the conveyor shard only matches Conveyor.java). Owner
  `SourceItemBridgeBuildState.source_item_bridge_link_valid_state`; the two
  new symbols share one link-result schema
  (`source_item_bridge_link_result.link` + `.had_valid_link` — configure and
  linkValid own one frame state).
- Targeted: **Ran 4 tests in 0.269s, 3/4 PASS** (registration, exact-evidence
  31/31, row-state) + 1 FAIL, the proof test, failing exactly
  `AssertionError: unexpectedly None` at `assertIsNotNone(godot)` — **no Godot
  binary exists on this VM** (user order 2026-11-15: no Godot runs here at all —
  no headless, no MCP, no editor). The proof scene is written but NEVER run;
  see GOAL.md §5 debt.
- Coordinator verification note: in the worker worktree the targeted run
  showed failures=1, errors=2 (the 2 errors are the `KeyError: 'N2197'` from
  the reverted `generated/`, exactly per process) — after the coordinator's
  register run at integration the same suite is 3/4 PASS.
- DESIGN correction (coordinator, 2026-11-15): the worker spotted a
  contradiction — `DESIGN-frame-state-infra.md` §4.2 said hadValidLink was
  computed "before the consumption fold", but the brief and the real Java
  (BuildingComp.java:2274-2277) both say AFTER. The worker followed the
  brief/Java (recompute after the fold); the coordinator fixed DESIGN §4.2
  with a dated correction note. No code change.
- No coordinator code fix needed. The `range` parameter of
  `source_item_bridge_link_valid_state` shadows a GDScript builtin (per the
  brief's signature) — no ERROR is produced; the first Godot run will confirm.

## Neighbours (single-slice — coordinator, main thread)

New targeted 3/4 + family bridge power_status (4 modules, 16 tests) 12/16 +
wiring-standard set (9 modules / 32 tests) 23/32: **38/52 PASS**,
14 failures ALL verified `AssertionError: unexpectedly None` (1 new targeted +
4 family + 9 wiring), 0 other failures, 0 `ERROR:` lines — no regression.
Log `tools/mindustry_godot_transpiler/n2197-neighbours.log` (untracked).

## Gate (single-slice)

Full gate attempt 1 (PID 24699, coordinator main thread, launch 11:20 +07)
was killed by a VM restart ~11:22 (log frozen at 3637 bytes, no footer;
javalang wiped by the restart and reinstalled 0.13.0 from requirements.txt).
Attempt 2 (PID 1944, coordinator main thread, launch 11:24, done 11:39 +07,
log `tools/mindustry_godot_transpiler/full-suite-n2197-gate.log`, untracked):
Ran 5841 in 945.797s, failures=137, skipped=5, 0 errors — 137/137 verified
Godot-absent (136 inherited + 1 new proof test N2197, confirmed present in
the failures; 0 `ERROR:` lines). Gate clean except Godot; no regression.

## Commits

- Slice: `bd07c93d` — C07: N2197 ItemBridge link frame state, 5 files (+621/−8),
  on `slice/N2197-item-bridge-link-frame-state`.
- Integration: slice cherry-pick `6a094cda` on
  `integration/n2197-item-bridge-link`; SSOT `fe328383` (11382/1637/1558/2907,
  4 files, +557, no shard change).
- Docs: (this commit) — report + handoff + spec + GOAL for N2197.
- NOT pushed, NOT merged into main — local branches only; main agent merges after
  user approval.

## Deferred (NOT this slice)

- The shouldConsume gate itself (`hadValidLink && enabled`) — N2188 (slice
  done 11:21, `c490f99e`, awaiting wave-2 integration with N2198).
- Placement auto-link (playerPlaced / findLink / lastBuild) — N2199 (needs
  game-level `lastBuild` state + cross-build configure at placement).
- The updateTile transport advance (checkIncoming / transportCounter /
  warmup / doDump, ItemBridge.java:319-363) — own slice.
- `config()` getter / rebuild (ItemBridge.java:500-502, write :512 / read
  :526) + draw/config UI — own slices (C10 for rebuild).
- The N2197 test pins the pre-gate driver line (`test_c07_item_bridge_link_frame_state.py:222`
  asserts `var should_consume: bool = bool(frame.get("enabled", true))` with
  the comment "N2188 wires the gate") — the wave-2 integration updates that
  assertion to the new gate line (coordinator fix, by design, not a regression).
- Godot proof never run on this VM (no Godot here, user order) — debt in GOAL.md §5:
  `C07ItemBridgeLinkFrameStateProof`, commit carrying the scene `bd07c93d`, 6 keys
  (`link_defaults_to_minus_one`, `configure_point2_sets_relative_link`,
  `configure_integer_sets_absolute_link`, `link_valid_same_row_within_range`,
  `link_invalid_when_double_or_out_of_range`, `live_tick_recomputes_had_valid_link`
  + `registry_valid` / `one_headquarter_per_ssot` / `matches`),
  status "chờ agent Godot test". Run: targeted test
  `tests.test_c07_item_bridge_link_frame_state` with Godot 4.6.2 on PATH, port 7777 free.
- Next: wave 2 {N2188 ItemBridge gate (done, awaiting integration) + N2198
  LiquidBridge gate (worker running)} → N2199 auto-link → items → liquids →
  payload → targets (see `DESIGN-frame-state-infra.md` in
  `~/workspace/mindustry-parallel/`).
