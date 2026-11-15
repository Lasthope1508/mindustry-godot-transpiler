# Report — N2203: BurstDrill shouldConsume gate (C07)

Date: 2026-11-15. Slice branch `slice/N2203-burst-drill-should-consume`,
base `fb7c20e5` (N2199 tip). Integrated on
`integration/wave-items-n2200-n2204` (cherry-pick `04438b4c`). Status:
**DONE (code + SSOT + neighbours + gate clean except Godot; NOT merged
into main; slice branch pushed 13:21 per push-as-you-go; integration
branch pushed immediately after the docs commit — see STATUS.md).**

Done by worker-N2203 (slice, done 13:19 +07); integrated by coordinator
lượt 3 (cherry-pick + merged SSOT + neighbours + gate) and documented by
coordinator lượt 4. Slice commit `4e249a60`; merged SSOT `80e99ebe`
(wave-level, 11407/1645/1568/2927).

## What changed

The BurstDrill power.status slice (N2149) folded power only and deferred
the shouldConsume gate ("items state is not tracked yet"). N2203 wires the
gate over the shared drill frame (the DESIGN-frame-state-infra.md items
pattern: frame key `items` + the existing
`SourceDrillInventoryRuntimeState` helpers):

- **Pure gate** `source_burst_drill_should_consume_state(frame,
  item_capacity)` in `SourceBurstDrillBuildState.gd` — mirrors
  BurstDrillBuild.shouldConsume() (BurstDrill.java:128-130): `return
  items.total() <= itemCapacity - dominantItems && enabled;`. Note the
  **`<=`** (not `<`) and the **`itemCapacity - dominantItems`** threshold.
  BurstDrill extends Drill (:17), BurstDrillBuild extends DrillBuild (:70).
  Returns `{"should_consume"}`.
- **Shared frame key**: `SOURCE_BURST_DRILL_BUILDING_META_KEY :=
  "source_drill_building"` — the SAME key as the base Drill driver
  (`SourceDrillConsumptionRuntimeState`, whose `_initial_frame()` already
  provides `items: {}`, `dominant_item: null`, `dominant_items: 0`,
  `enabled: true`). Scoping confirmed the bind order: the proximity bind
  runs before placement, so the BurstDrill tick meets an already-existing
  frame and binds with applied=false — no key is added twice, and the key
  itself is NOT changed. This slice touches ONLY
  `SourceBurstDrillBuildState.gd` — it does NOT touch
  `SourceDrillConsumptionRuntimeState.gd` (N2204's file).
- **`dominant_items`** is set by the base Drill proximity path
  (Drill.java:277); `itemCapacity` from the catalog (eruption 60, impact
  40, fallback 10).
- The driver reads the gate through the pure function and feeds
  `should_consume` into the consumption machinery (the N2188/N2198
  precedent), so efficiency folds to 0 when the gate is false
  (BuildingComp.java:1960/:1992-1994). The power.row limit comment now says
  the gate is LIVE.

## RED

Test module `tools/mindustry_godot_transpiler/tests/test_c07_burst_drill_should_consume.py`
+ register script `tools/mindustry_godot_transpiler/register_c07_burst_drill_should_consume.py`
written by worker-N2203. Register script: EXACT_EXPRS = the 18 verified
exprs (all 18 unique, all present verbatim in upstream — script check,
0 missing), DEFERRED 252 entries (the BurstDrill gate entry resolved; 1 new
deferral added: BurstDrill live items fill — no live tick fills burst-drill
items yet, the offload waits for the updateTile advance).

RED run: the expected no-Godot pattern — registration + exact-evidence fail
`KeyError: 'N2203'`, the state test fails on the missing pure function, and
the proof test fails Godot-absent (`AssertionError: unexpectedly None` at
`assertIsNotNone(godot)`).

## GREEN

- Pure gate + driver wiring in `SourceBurstDrillBuildState.gd`; the limit
  comment updated. Header quotes the exact exprs, each Java line on ONE
  comment line (the N2148 lesson).
- Proof scene `godot-mindustry/tools/runtime_proofs/C07BurstDrillShouldConsumeProof.gd`
  + `.tscn` (6 keys + registry_valid / one_headquarter_per_ssot / matches):
  gate_open_below_threshold, gate_open_at_boundary,
  gate_closed_when_over_threshold, gate_closed_when_disabled,
  efficiency_zero_when_gate_closed, efficiency_kept_when_gate_open. Proof
  `.json` is gitignored (never stage, per AGENTS.md rule on proof .json).
- Register script: SSOT single-slice **+2/+1/+1/+2 → 11398/1641/1564/2919**
  from the N2199 base 11396/1640/1563/2917; audit totalSourceFunctions 1336,
  legacy 0. **Production shard CHANGED** (4 `production_*` files).
- Targeted: **Ran 4 tests, 3/4 PASS** (registration, exact-evidence 18/18,
  state) + 1 FAIL, the proof test, failing exactly
  `AssertionError: unexpectedly None` at `assertIsNotNone(godot)` — **no Godot
  binary exists on this VM** (user order 2026-11-15: no Godot runs here at all —
  no headless, no MCP, no editor). The proof scene is written but NEVER run;
  see GOAL.md §5 debt.

## Neighbours (coordinator, main thread — wave-level)

Production family (64 tests): 48 PASS + 16 Godot-absent, 0 other failures.
(One ERROR loading a module during the neighbours run was the missing
javalang after the VM restart ~13:24 — reinstalled 0.13.0, the module then
ran OK 4/4.) Targeted 5 wave modules (20 tests): 15 PASS + 5 proof tests
Godot-absent. No regression.

## Gate

Full gate (PID 2102, launch 13:25 by coordinator lượt 3, done 13:42 +07,
verified by coordinator lượt 4, log
`tools/mindustry_godot_transpiler/full-suite-wave-items-gate.log`, untracked):
Ran 5873 in 985.433s, failures=145, skipped=5, 0 errors — 145/145 verified
Godot-absent (140 inherited + 5 new proof tests N2200–N2204, all confirmed
present in the failures; 0 `ERROR:` lines). Gate clean except Godot; no
regression.

## Commits

- Slice: `4e249a60` — C07: N2203 BurstDrill shouldConsume gate, 5 files
  (+552/−12), on `slice/N2203-burst-drill-should-consume` (base `fb7c20e5`).
  Cherry-pick `04438b4c` on `integration/wave-items-n2200-n2204`.
- SSOT: merged `80e99ebe` — wave-level SSOT (11407/1645/1568/2927), audit
  1336, legacy 0, validator errors [].
- Docs: (this commit) — report + handoff + spec + GOAL for N2200–N2204.
- NOT merged into main. Slice branch pushed 13:21, integration branch
  pushed per push-as-you-go immediately after the docs commit (user order
  12:08 + parent 12:26); push recorded in STATUS.md.

## Deferred (NOT this slice)

- Live item intake: frame `items` is never filled on the live path yet —
  belongs to the BurstDrill updateTile advance, own slice.
- The driver-wide disabled early return (BuildingComp.java:1954-1957) —
  deferred (same deviation as N2188/N2198/N2200–N2202/N2204).
- Godot proof never run on this VM (no Godot here, user order) — debt in GOAL.md §5:
  `C07BurstDrillShouldConsumeProof`, commit carrying the scene `4e249a60`,
  6 keys (listed above + `registry_valid` / `one_headquarter_per_ssot` /
  `matches`), status "chờ agent Godot test". Run: targeted test
  `tests.test_c07_burst_drill_should_consume` with Godot 4.6.2 on PATH,
  port 7777 free.
- Next: liquids wave (N2205 Pump, N2206 SolidPump, N2207 Fracker
  shouldConsume gates — scoping in `SCOPE-liquids-wave.md`) → payload →
  targets (see `DESIGN-frame-state-infra.md` in
  `~/workspace/mindustry-parallel/`).
