# Report — N2188: ItemBridge shouldConsume gate (C07, retry)

Date: 2026-11-15. Wave 2: N2188 + N2198 (integration branch
`integration/wave2-n2188-n2198`, base `fe328383` = N2197 tip). Status:
**DONE (code + SSOT + neighbours + gate clean except Godot; NOT pushed,
NOT merged — local branches only, per user order).**

Worker: worker-N2188 (retry; first attempt stopped at scoping 10:10, no code
— the link infra did not exist yet). Worker handoff arrived 11:21 +07 and
matched every coordinator-verified number. Slice commit `c490f99e` on
`slice/N2188-item-bridge-should-consume`; no worker SSOT commit (the worker
ran the register script to verify, then reverted `generated/` per
BRIEF-COMMON — the coordinator ran the register at integration).
Integration cherry-pick: slice `9de01cd5`.

## What changed

`ItemBridgeBuild.shouldConsume()` returns `hadValidLink && enabled`
(ItemBridge.java:495-496). The driver folded with `should_consume=true`
whenever enabled — an unlinked phase-conveyor read power.status 1.0 while
Java efficiency was 0. N2197 supplied the link frame state (frame
`link`/`had_valid_link` + pure configure + pure linkValid + the driver
recompute every tick after the consumption fold); N2188 wires the gate over
it:

- Pure `source_item_bridge_should_consume_state(frame)` returning
  `{"should_consume", "had_valid_link"}` — the override exactly, INCLUDING
  the enabled check (unlike the N2186 LaunchPad / N2187 ShockwaveTower
  overrides, whose enabled handling lives in updateConsumption,
  BuildingComp.java:1954-1957). A missing link validity reads false (fresh
  build, unlinked); a missing enabled reads true (the Java field default).
- The driver reads `should_consume` through the pure function
  (`var gate: Dictionary = source_item_bridge_should_consume_state(frame)` /
  `var should_consume: bool = bool(gate.get("should_consume", false))`);
  when the gate is false the machinery folds efficiency to 0
  (BuildingComp.java:1960, `boolean update = shouldConsume() &&
  productionValid();`, with :1992-1994, `if(!update){` /
  `efficiency = optionalEfficiency = 0f;`).
- The gate reads the previous tick's `had_valid_link` — the recompute runs
  after the fold, the Java order (BuildingComp.java:2274-2277) — so a
  freshly linked bridge consumes from the next tick, and a freshly unlinked
  bridge consumes for one more tick.
- Documented limits updated: gate LIVE; transport advance, warmup, sense,
  draw/config, auto-link (N2199) still deferred.

## RED

Test module `tools/mindustry_godot_transpiler/tests/test_c07_item_bridge_should_consume.py`
+ register script `tools/mindustry_godot_transpiler/register_c07_item_bridge_should_consume.py`
written by worker-N2188. Register script: EXACT_EXPRS = the 19 verified exprs
(all 19 unique, all present verbatim in upstream — script check, 0 missing),
DEFERRED 247 entries (copy forward from N2197's 248, minus the resolved
`ItemBridge shouldConsume gate` entry; the LiquidBridge gate entry is KEPT
for N2198).

RED run: 4 tests, failures=2, errors=2 — `KeyError: 'N2188'`
(registration + exact-evidence), the missing pure function (gate-state), and
the proof test fails Godot-absent (`AssertionError: unexpectedly None` at
`assertIsNotNone(godot)`) — the expected no-Godot pattern on this VM.

## GREEN

- Pure gate + driver wiring in
  `godot-mindustry/src/game/SourceItemBridgeBuildState.gd`; header quotes the
  exact exprs. Documented limits updated (gate LIVE).
- Proof scene `godot-mindustry/tools/runtime_proofs/C07ItemBridgeShouldConsumeProof.gd`
  + `.tscn` (6 keys + registry_valid / one_headquarter_per_ssot / matches).
  The proof sets the link through the N2197 pure configure (Point2 relative
  {3,0} from (28,21) → pack 2031637) — no auto-link (N2199) needed.
  Proof `.json` is gitignored (never stage, per AGENTS.md rule on proof .json).
- Register script run by the coordinator at integration: SSOT single-slice
  **11384/1638/1559/2909** (+2/+1/+1/+2 from the wave-2 base 11382/1637/1558/2907);
  audit 1335 unchanged; ledger N2188 status done. **No shard changed** (no
  distribution shard exists). Owner
  `SourceItemBridgeBuildState.source_item_bridge_should_consume_state`.
- Targeted: **Ran 4 tests in 0.264s, 3/4 PASS** (registration, exact-evidence
  19/19, gate-state) + 1 FAIL, the proof test, failing exactly
  `AssertionError: unexpectedly None` at `assertIsNotNone(godot)` — **no Godot
  binary exists on this VM** (user order 2026-11-15: no Godot runs here at all —
  no headless, no MCP, no editor). The proof scene is written but NEVER run;
  see GOAL.md §5 debt.
- Coordinator fix `2bf6bfa9` (integration, by design, not a regression): the
  N2197 test pinned the pre-gate driver line
  (`test_c07_item_bridge_link_frame_state.py:222` asserted
  `var should_consume: bool = bool(frame.get("enabled", true))` with the
  comment "N2188 wires the gate") — updated to assert the new gate lines,
  following the N2188 test pattern. The N2197 suite is 3/4 PASS again after
  the fix (proof test Godot-absent only).
- No worker code fix needed. No LiquidBridge file touched (grep commit = 0).

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

- Slice: `c490f99e` — C07: N2188 ItemBridge shouldConsume gate, 5 files (+505/−5),
  on `slice/N2188-item-bridge-should-consume` (base `fe328383`).
- Integration: slice cherry-pick `9de01cd5` on
  `integration/wave2-n2188-n2198`; coordinator fix `2bf6bfa9` (N2197 test gate
  line); wave-2 SSOT `630f4924` (combined 11386/1639/1560/2911).
- Docs: (this commit) — report + handoff + spec + GOAL for N2188/N2198.
- NOT pushed, NOT merged into main — local branches only; main agent merges after
  user approval.

## Deferred (NOT this slice)

- The updateTile transport advance (checkIncoming / transportCounter /
  warmup / doDump, ItemBridge.java:319-363) — own slice.
- Placement auto-link (playerPlaced / findLink / lastBuild) — N2199.
- `config()` getter / rebuild (ItemBridge.java:500-502, write :512 / read
  :526) + draw/config UI — own slices (C10 for rebuild).
- The driver-wide disabled early return (BuildingComp.java:1954-1957): the
  gate reads a frozen `had_valid_link` while disabled (correct per
  `noUpdateDisabled`), but the frame efficiency is never zeroed when disabled;
  deferred.
- Godot proof never run on this VM (no Godot here, user order) — debt in GOAL.md §5:
  `C07ItemBridgeShouldConsumeProof`, commit carrying the scene `c490f99e`, 6 keys
  (`gate_open_with_valid_link`, `gate_closed_when_unlinked`,
  `gate_closed_when_disabled`, `gate_reads_previous_tick_link`,
  `efficiency_zero_when_gate_closed`, `efficiency_kept_when_gate_open`
  + `registry_valid` / `one_headquarter_per_ssot` / `matches`),
  status "chờ agent Godot test". Run: targeted test
  `tests.test_c07_item_bridge_should_consume` with Godot 4.6.2 on PATH, port 7777 free.
- Next: N2198 LiquidBridge gate (same wave, done) → N2199 auto-link → items →
  liquids → payload → targets (see `DESIGN-frame-state-infra.md` in
  `~/workspace/mindustry-parallel/`).
