# Handoff — N2203 BurstDrill shouldConsume gate

Date: 2026-11-15. Slice branch `slice/N2203-burst-drill-should-consume`,
base `fb7c20e5` (N2199 tip). Integrated on
`integration/wave-items-n2200-n2204` (cherry-pick `04438b4c`). Status:
**DONE (code + SSOT + neighbours + gate clean except Godot; slice
4e249a60, merged SSOT 80e99ebe; NOT merged into main; slice branch pushed
13:21, integration branch pushed immediately after the docs commit).**

Done by worker-N2203 (slice, done 13:19 +07); integrated by coordinator
lượt 3, documented by coordinator lượt 4.

## Scoping (DONE 2026-11-15 12:19 +07, SCOPE-items-wave.md + brief-n2203-burst-drill.md)

- `BurstDrillBuild.shouldConsume()` (BurstDrill.java:128-130): `return
  items.total() <= itemCapacity - dominantItems && enabled;`. Note the
  **`<=`** (not `<`) and the **`itemCapacity - dominantItems`** threshold.
  BurstDrill extends Drill (:17), BurstDrillBuild extends DrillBuild (:70).
- **SHARED FRAME KEY**: `SOURCE_BURST_DRILL_BUILDING_META_KEY :=
  "source_drill_building"` — the SAME key as the base Drill driver
  (`SourceDrillConsumptionRuntimeState`, whose `_initial_frame()` already
  provides `items: {}`, `dominant_item: null`, `dominant_items: 0`,
  `enabled: true`). Scoping confirmed the bind order: the proximity bind
  runs before placement, so the BurstDrill tick meets an already-existing
  frame and binds with applied=false — no key is added twice, and the key
  itself is NOT changed.
- `dominant_items` is set by the base Drill proximity path (Drill.java:277);
  `itemCapacity` from the catalog (eruption 60, impact 40, fallback 10).
- File scope: ONLY `SourceBurstDrillBuildState.gd` (+ test/register/proof)
  — does NOT touch `SourceDrillConsumptionRuntimeState.gd` (N2204's file).
- SSOT baseline re-verified from the generated JSONs (base `fb7c20e5`):
  symbols 11396 + slices 1640 + contracts 1563 + schemas 2917; audit
  `totalSourceFunctions` 1336. Expected after N2203 (single-slice):
  **11398/1641/1564/2919** — confirmed.

## Design (decided in scoping, recorded in test + register)

- Pure `source_burst_drill_should_consume_state(frame, item_capacity)` →
  `{should_consume}`; reads `items`, `dominant_items`, `enabled` from the
  shared drill frame.
- No new frame keys (the shared frame already has all of them). The driver
  reads the gate through the pure function; the machinery folds efficiency
  to 0 when the gate is false.
- Proof scene `C07BurstDrillShouldConsumeProof.gd/.tscn` (6 keys, N2185 pattern).

## RED (DONE 2026-11-15 13:19 +07, worker-N2203)

- Test module `tools/mindustry_godot_transpiler/tests/test_c07_burst_drill_should_consume.py`
  + register script `tools/mindustry_godot_transpiler/register_c07_burst_drill_should_consume.py`.
- Register script verified standalone: **exit 0**. **18 exact exprs, 0 missing**;
  DEFERRED 252 entries. OWNER
  `SourceBurstDrillBuildState.source_burst_drill_should_consume_state`, PROOF
  `/root/C07BurstDrillShouldConsumeProof`.
- Targeted RED run: the expected pattern — `KeyError: 'N2203'`
  (registration + exact-evidence), the missing pure function (state test),
  proof test fails Godot-absent (`AssertionError: unexpectedly None` at
  `assertIsNotNone(godot)`). No other failures. `git diff --check` clean.

## GREEN (DONE 2026-11-15 13:19 +07, worker-N2203)

- Pure gate + driver wiring (5 files, +552/−12); proof scene (6 keys); all
  18 exact exprs present, each on ONE comment line. The limit comment in
  the BurstDrill power row now says the gate is LIVE.
- SSOT at GREEN (single-slice): **11398/1641/1564/2919**, audit 1336,
  legacy 0. Production shard CHANGED (4 `production_*` files).
  `git diff --check` clean.
- Targeted run: **Ran 4 tests, 3/4 PASS** (registration, exact-evidence
  18/18, state) + proof test FAIL, exactly `AssertionError: unexpectedly
  None` — no Godot on this VM (user order: no Godot runs here at all).
- Coordinator verification (lượt 3): commit + 5 files match the brief;
  register exit 0; targeted 3/4 after register; generated/ reverted,
  working tree clean.

## Neighbours (DONE 2026-11-15 ~13:2x +07, coordinator, main thread — wave-level)

- Production family (64 tests): 48 PASS + 16 Godot-absent, 0 other
  failures. Targeted 5 wave modules (20 tests): 15 PASS + 5 proof tests
  Godot-absent. No regression. (One module ERROR during neighbours was the
  missing javalang after the VM restart ~13:24 — reinstalled 0.13.0, the
  module then ran OK 4/4.)

## Exact exprs (18, all verified verbatim at scoping — script check, 0 missing)

See `register_c07_burst_drill_should_consume.py` EXACT_EXPRS (18 entries,
including `return items.total() <= itemCapacity - dominantItems &&
enabled;` and the Blocks.java def lines).

## Next

- Liquids wave (N2205 Pump, N2206 SolidPump, N2207 Fracker shouldConsume
  gates — scoping in `SCOPE-liquids-wave.md`) → payload → targets → plans
  → units (see `DESIGN-frame-state-infra.md` in
  `~/workspace/mindustry-parallel/`).
- Standalone coordinator-serial work still pending: the driver-wide disabled
  early return fix (BuildingComp.java:1954-1957); the raw-delta audit of
  remaining runtime files; the N2198 tick cross-def fix slice.
- Godot proof debt: `C07BurstDrillShouldConsumeProof`, 6 keys, status
  "chờ agent Godot test" (GOAL.md §5).

## Commits

- Slice: `4e249a60` — C07: N2203 BurstDrill shouldConsume gate, 5 files (+552/−12).
  Cherry-pick `04438b4c` on `integration/wave-items-n2200-n2204`.
- SSOT: merged `80e99ebe` — wave-level SSOT (11407/1645/1568/2927), audit
  1336, legacy 0, validator errors [].
- Docs: (this commit) — report + handoff + spec + GOAL for N2200–N2204.

## Gate (DONE 2026-11-15, log `full-suite-wave-items-gate.log`)

Full gate (PID 2102, launch 13:25 by coordinator lượt 3, done 13:42 +07,
verified by coordinator lượt 4, log
`tools/mindustry_godot_transpiler/full-suite-wave-items-gate.log`, untracked):
Ran 5873 in 985.433s, failures=145, skipped=5, 0 errors — 145/145 verified
Godot-absent (140 inherited + 5 new proof tests N2200–N2204, all confirmed
present in the failures; 0 `ERROR:` lines). Gate clean except Godot; no
regression.
