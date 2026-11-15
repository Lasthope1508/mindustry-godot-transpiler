# Handoff — N2188 ItemBridge shouldConsume gate (retry)

Date: 2026-11-15. Wave 2: N2188 + N2198 (integration branch
`integration/wave2-n2188-n2198`, base `fe328383` = N2197 tip). Status:
**DONE (code + SSOT + neighbours + gate clean except Godot; slice c490f99e;
NOT pushed, NOT merged).**

Worker: worker-N2188 (retry), done 11:21 +07; worker handoff arrived 11:21 +07
and matched every coordinator-verified number. Coordinator verified the commit,
the register run, and the targeted run directly from git. One coordinator fix
at integration (N2197 test gate line — by design, see GREEN).

## Scoping (DONE 2026-11-15 11:17 +07, brief + N2197 infra)

- First attempt (wave 1, 10:10) stopped at scoping, no code: the port stored
  no `link` and no config of any kind on a placed building, so `hadValidLink`
  could not be computed. N2197 (DONE 11:13, integrated `fe328383`) supplied
  the frame keys + pure configure + pure linkValid + the driver recompute —
  the retry branch was reset from main de9ab89c onto `fe328383`.
- `ItemBridgeBuild.shouldConsume()` returns `hadValidLink && enabled`
  (ItemBridge.java:495-496) — the override INCLUDES enabled, unlike N2186/N2187.
- phase-conveyor: consumePower 0.30f (Blocks.java:2125), range 12 (:2118),
  transportTime 2f (:2119). bridge-conveyor (BufferedItemBridge, no power def)
  OUT of scope.
- SSOT baseline re-verified from the generated JSONs (base `fe328383`):
  symbols 11382 + slices 1637 + contracts 1558 + schemas 2907; audit
  `totalSourceFunctions` 1335. Expected after N2188: **11384/1638/1559/2909**
  — reached at the register run. No shard change expected (no distribution
  shard exists) — confirmed.

## Design (decided in scoping, recorded in test + register)

- Pure `SourceItemBridgeBuildState.source_item_bridge_should_consume_state(frame)`
  returning `{"should_consume", "had_valid_link"}` — the override exactly.
  The driver reads `should_consume` through it; the machinery folds
  efficiency to 0 when the gate is false (BuildingComp.java:1960/:1992-1994).
- The gate reads the previous tick's `had_valid_link` (the N2197 recompute
  runs AFTER the consumption fold, the Java order, BuildingComp.java:2274-2277).
- The proof sets the link through the N2197 pure configure — no auto-link
  (N2199) needed.
- Proof scene `C07ItemBridgeShouldConsumeProof.gd/.tscn` (6 keys, N2185 pattern).

## RED (DONE 2026-11-15 ~11:1x +07, worker-N2188)

- Test module `tools/mindustry_godot_transpiler/tests/test_c07_item_bridge_should_consume.py`
  + register script `tools/mindustry_godot_transpiler/register_c07_item_bridge_should_consume.py`.
- Register script verified standalone: **exit 0**. **19 exact exprs, 0 missing**;
  DEFERRED 247 entries. OWNER
  `SourceItemBridgeBuildState.source_item_bridge_should_consume_state`, PROOF
  `/root/C07ItemBridgeShouldConsumeProof`.
- Targeted RED run: 4 tests, failures=2, errors=2 — `KeyError: 'N2188'`
  (registration + exact-evidence), the missing pure function (gate-state),
  proof test fails Godot-absent (`AssertionError: unexpectedly None` at
  `assertIsNotNone(godot)`). No other failures. `git diff --check` clean.

## GREEN (DONE 2026-11-15 11:21 +07, worker-N2188)

- Pure gate + driver wiring in `SourceItemBridgeBuildState.gd` (5 files,
  +505/−5); proof scene (6 keys); all 19 exact exprs present, each on ONE
  comment line.
- SSOT at GREEN (coordinator register run): **11384/1638/1559/2909** (single-slice),
  audit 1335, no shard changed. `git diff --check` clean.
- Targeted run: **Ran 4 tests in 0.264s, 3/4 PASS** (registration,
  exact-evidence 19/19, gate-state) + proof test FAIL, exactly
  `AssertionError: unexpectedly None` — no Godot on this VM (user order: no
  Godot runs here at all).
- Coordinator fix `2bf6bfa9` at integration: the N2197 test pinned the
  pre-gate driver line (`test_c07_item_bridge_link_frame_state.py:222`) with
  the comment "N2188 wires the gate" — updated to assert the new gate lines
  (following the N2188 test pattern). The N2197 suite is 3/4 PASS again
  after the fix. By design, not a regression.
- No worker code fix needed. No LiquidBridge file touched.

## Neighbours (DONE 2026-11-15 ~11:4x +07, wave 2 — coordinator, main thread)

- New targeted 9/12 (N2197 + N2188 + N2198, 3 Godot-absent). Family bridge
  power_status (4 modules / 16 tests): 12/16 PASS, 4 Godot-absent.
  Wiring-standard set (9 modules / 32 tests): 23/32 PASS, 9 Godot-absent.
  **Total 44/60 PASS, 16 Godot-absent, 0 other failures, 0 `ERROR:` lines —
  no regression.** Log `wave2-neighbours.log` (untracked).

## Exact exprs (19, all verified verbatim at scoping — script check, 0 missing)

See `register_c07_item_bridge_should_consume.py` EXACT_EXPRS (19 entries,
including `return hadValidLink && enabled;`, the link gate lines, the
updateConsumption fold, and the Java update order).

## Next

- N2198 LiquidBridge gate (same wave, done).
- After wave 2: N2199 auto-link (playerPlaced + findLink + lastBuild) →
  items → liquids → payload → targets → plans → units (see
  `DESIGN-frame-state-infra.md` in `~/workspace/mindustry-parallel/`).
- The driver-wide disabled early return (BuildingComp.java:1954-1957) is a
  separate fix slice.
- Godot proof debt: `C07ItemBridgeShouldConsumeProof`, 6 keys, status
  "chờ agent Godot test" (GOAL.md §5).

## Commits

- Slice: `c490f99e` — C07: N2188 ItemBridge shouldConsume gate, 5 files (+505/−5).
- Integration: slice cherry-pick `9de01cd5` on
  `integration/wave2-n2188-n2198`; coordinator fix `2bf6bfa9` (N2197 test gate
  line); wave-2 SSOT `630f4924` (combined 11386/1639/1560/2911).
- Docs: (this commit) — report + handoff + spec + GOAL for N2188/N2198.

## Gate (DONE 2026-11-15 12:00 +07, log `full-suite-wave2-gate.log`, wave 2)

Full gate (wave 2, PID 4240, coordinator main thread, launch 11:44, done 12:00 +07,
log `tools/mindustry_godot_transpiler/full-suite-wave2-gate.log`, untracked):
Ran 5849 in 1003.342s, failures=139, skipped=5, 0 errors — 139/139 verified
Godot-absent (136 inherited + 3 new proof tests N2197/N2188/N2198, all confirmed
present in the failures; 0 `ERROR:` lines).
Gate clean except Godot; no regression.
