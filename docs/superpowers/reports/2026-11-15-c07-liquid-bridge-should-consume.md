# Report — N2198: LiquidBridge shouldConsume gate (C07)

Date: 2026-11-15. Wave 2: N2188 + N2198 (integration branch
`integration/wave2-n2188-n2198`, base `fe328383` = N2197 tip). Status:
**DONE (code + SSOT + neighbours + gate clean except Godot; NOT pushed,
NOT merged — local branches only, per user order).**

Worker: worker-N2198. Worker handoff arrived 11:24 +07 and matched every
coordinator-verified number. Slice commit `ffe78c85` on
`slice/N2198-liquid-bridge-should-consume`; no worker SSOT commit (the worker
ran the register script to verify, then reverted `generated/` per
BRIEF-COMMON — the coordinator ran the register at integration).
Integration cherry-pick: slice `aa271fcd`.

## What changed

`LiquidBridge extends ItemBridge` (LiquidBridge.java:7),
`LiquidBridgeBuild extends ItemBridgeBuild` (:19), and the subclass overrides
NEITHER `shouldConsume` NOR `linkValid` / `positionsValid` / `updateTile`
(verified by grep: 0 matches — only `updateTransport` + `doDump` are
overridden). The gate `hadValidLink && enabled` (ItemBridge.java:495-496) is
inherited verbatim. But the port has a separate LiquidBridge driver
(`SourceLiquidBridgeBuildState.gd`, own frame key
`"source_liquid_bridge_building"`), so the gate had to be wired into that
driver — reusing the N2197 machinery:

- **Reuse, not a second copy:** the LiquidBridge driver preloads
  `SourceItemBridgeBuildState.gd` and calls
  `source_item_bridge_link_valid_state(...)` (:186); the proof sets links
  through `source_item_bridge_configure_state(...)`. Precedent:
  `SourceFactoryRuntimeState.gd` preloads family BuildState files and calls
  their static funcs (:40-41, :456, :467); no precedent forbids a family
  driver preloading another family driver, and the Java inheritance
  (LiquidBridgeBuild extends ItemBridgeBuild, not re-implementing
  linkValid/configure) makes reuse the faithful mirror. No preload cycle
  (the ItemBridge file does not preload the LiquidBridge file).
- The only duplication is the arc Point2 primitives (`_to_short` /
  `_point2_pack` / `_point2_unpack`, :90-103, private) — arc primitives, not
  ItemBridge logic; the ItemBridge copies are private and that file was
  being edited by N2188 in parallel. Precedent: the N2191 slerpDelta local
  + N2197 keeping helpers private per family.
- Frame keys `link` (default -1) + `had_valid_link` (default false) on the
  LiquidBridge frame; pure gate `source_liquid_bridge_should_consume_state`
  returning `{"should_consume", "had_valid_link"}`; the driver folds with
  `should_consume = enabled and gate.should_consume` and recomputes
  `had_valid_link` AFTER the consumption fold, only when enabled (the Java
  order, BuildingComp.java:2274-2277; `noUpdateDisabled` inherited). The
  partner must be a LiquidBridge (the block clause, ItemBridge.java:152,
  with `this` the LiquidBridge block); the partner's link comes from its own
  liquid-bridge frame; range from `block.properties.get("range", 0)`.
- phase-conduit: range 12 (Blocks.java:2388), consumePower 0.30f (:2396).
  bridge-conduit (`hasPower = false`, no power def) stays out of scope of
  the fold — but still gets the link keys + recompute like every
  LiquidBridgeBuild, exactly per Java.
- The worker also fixed the same 6 wrong build-field line refs in the
  LiquidBridge file that N2197 fixed in the ItemBridge file (:202→:198,
  :203→:199, :204→:200, :205→:201, :206→:202, :207→:203).

## RED

Test module `tools/mindustry_godot_transpiler/tests/test_c07_liquid_bridge_should_consume.py`
+ register script `tools/mindustry_godot_transpiler/register_c07_liquid_bridge_should_consume.py`
written by worker-N2198. Register script: EXACT_EXPRS = the 30 verified exprs
(all 30 unique, all present verbatim in upstream — script check, 0 missing),
DEFERRED 247 entries (copy forward from N2197's 248, minus the resolved
`LiquidBridge shouldConsume gate` entry; the link/findLink entries are KEPT
because auto-link N2199 + config() are still deferred).

RED run: 4 tests, failures=2, errors=2 — `KeyError: 'N2198'`
(registration + exact-evidence), the missing pure function (gate-state), and
the proof test fails Godot-absent (`AssertionError: unexpectedly None` at
`assertIsNotNone(godot)`) — the expected no-Godot pattern on this VM.

## GREEN

- Frame keys + pure gate + driver wiring in
  `godot-mindustry/src/game/SourceLiquidBridgeBuildState.gd`; header quotes
  the exact exprs. Documented limits updated (gate LIVE; auto-link → N2199).
- Proof scene `godot-mindustry/tools/runtime_proofs/C07LiquidBridgeShouldConsumeProof.gd`
  + `.tscn` (6 keys + registry_valid / one_headquarter_per_ssot / matches).
  The gate reads the previous tick's `had_valid_link` (correct Java order) —
  the proof uses a 2-tick design for the efficiency-gate-true key (tick 1
  recomputes, tick 2 folds power 0.5); conduit A links B via configure
  Point2 {x:3, y:0} → pack 2031637, conduit C unlinked as the efficiency-0
  sample. Proof `.json` is gitignored (never stage, per AGENTS.md rule on
  proof .json).
- Register script run by the coordinator at integration: SSOT single-slice
  **11384/1638/1559/2909** (+2/+1/+1/+2 from the wave-2 base 11382/1637/1558/2907);
  audit 1335 unchanged; ledger N2198 status done. **No shard changed** (no
  distribution/liquid-bridge shard exists). Owner
  `SourceLiquidBridgeBuildState.source_liquid_bridge_should_consume_state`.
- Targeted: **Ran 4 tests in 0.194s, 3/4 PASS** (registration, exact-evidence
  30/30, gate-state) + 1 FAIL, the proof test, failing exactly
  `AssertionError: unexpectedly None` at `assertIsNotNone(godot)` — **no Godot
  binary exists on this VM** (user order 2026-11-15: no Godot runs here at all —
  no headless, no MCP, no editor). The proof scene is written but NEVER run;
  see GOAL.md §5 debt.
- Safety check by the worker (not a neighbours run): the N2179 + N2197
  modules run 8 tests, 6/6 non-proof PASS, the 2 failures only the proof
  tests Godot-absent — the edit broke no existing test on the same file.
- No coordinator code fix needed. No ItemBridge file touched (N2188 edited
  it in parallel).

## Neighbours (wave 2 — coordinator, main thread)

New targeted 9/12 (N2197 + N2188 + N2198, 3 Godot-absent) + family bridge
power_status (4 modules, 16 tests) 12/16 (4 Godot-absent) + wiring-standard
set (9 modules / 32 tests) 23/32 (9 Godot-absent): **44/60 PASS**,
16 failures ALL verified `AssertionError: unexpectedly None`, 0 other
failures, 0 `ERROR:` lines — no regression.
Log `tools/mindustry_godot_transpiler/wave2-neighbours.log` (untracked).

## Gate (wave 2)

Full gate (wave 2, PID 4240, coordinator main thread, launch 11:44, done 12:00 +07,
log `tools/mindustry_godot_transpiler/full-suite-wave2-gate.log`, untracked):
Ran 5849 in 1003.342s, failures=139, skipped=5, 0 errors — 139/139 verified
Godot-absent (136 inherited + 3 new proof tests N2197/N2188/N2198, all confirmed
present in the failures; 0 `ERROR:` lines).
Gate clean except Godot; no regression.

## Commits

- Slice: `ffe78c85` — C07: N2198 LiquidBridge shouldConsume gate, 5 files (+652/−10),
  on `slice/N2198-liquid-bridge-should-consume` (base `fe328383`).
- Integration: slice cherry-pick `aa271fcd` on
  `integration/wave2-n2188-n2198`; wave-2 SSOT `630f4924` (combined
  11386/1639/1560/2911).
- Docs: (this commit) — report + handoff + spec + GOAL for N2188/N2198.
- NOT pushed, NOT merged into main — local branches only; main agent merges after
  user approval.

## Deferred (NOT this slice)

- The liquid transport advance (updateTransport warmup gate
  `if(warmup >= 0.25f){`, LiquidBridge.java:23, + doDump) — own slice.
- Placement auto-link (playerPlaced / findLink / lastBuild) — N2199.
- `config()` getter / rebuild + draw/config UI — own slices (C10 for rebuild).
- The driver-wide disabled early return (BuildingComp.java:1954-1957) —
  deferred (same deviation as N2188).
- Godot proof never run on this VM (no Godot here, user order) — debt in GOAL.md §5:
  `C07LiquidBridgeShouldConsumeProof`, commit carrying the scene `ffe78c85`, 6 keys
  (`gate_true_with_valid_link`, `gate_false_when_unlinked`,
  `gate_false_when_disabled`, `efficiency_zero_when_gate_false`,
  `efficiency_folds_power_when_gate_true`, `live_tick_recomputes_had_valid_link`
  + `registry_valid` / `one_headquarter_per_ssot` / `matches`),
  status "chờ agent Godot test". Run: targeted test
  `tests.test_c07_liquid_bridge_should_consume` with Godot 4.6.2 on PATH, port 7777 free.
- Next: N2199 auto-link → items → liquids → payload → targets (see
  `DESIGN-frame-state-infra.md` in `~/workspace/mindustry-parallel/`).
