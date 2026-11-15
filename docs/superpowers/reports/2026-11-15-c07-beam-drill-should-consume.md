# Report — N2202: BeamDrill shouldConsume gate (C07)

Date: 2026-11-15. Slice branch `slice/N2202-beam-drill-should-consume`,
base `fb7c20e5` (N2199 tip). Integrated on
`integration/wave-items-n2200-n2204` (cherry-pick `8e922c31`). Status:
**DONE (code + SSOT + neighbours + gate clean except Godot; NOT merged
into main; slice branch pushed 13:21 per push-as-you-go; integration
branch pushed immediately after the docs commit — see STATUS.md).**

Done by worker-N2202 (slice, done 13:20 +07); integrated by coordinator
lượt 3 (cherry-pick + merged SSOT + neighbours + gate + the N2155 proof
fix `481315f8`) and documented by coordinator lượt 4. Slice commit
`41ee66e0`; merged SSOT `80e99ebe` (wave-level, 11407/1645/1568/2927).

## What changed

The BeamDrill power.status slice (N2155) folded power only and deferred
the shouldConsume gate ("items state is not tracked yet"). N2202 wires the
gate over the items frame key plus the facing amount (the
DESIGN-frame-state-infra.md items pattern: frame key `items` + the existing
`SourceDrillInventoryRuntimeState` helpers):

- **Pure gate** `source_beam_drill_should_consume_state(frame,
  item_capacity)` in `SourceBeamDrillBuildState.gd` — mirrors
  BeamDrillBuild.shouldConsume() (BeamDrill.java:270-272): `return
  items.total() < itemCapacity && facingAmount > 0 && enabled;`. All three
  conditions, in Java order. Returns `{"should_consume", "facing_amount"}`.
  BeamDrill extends Block, NOT Drill (BeamDrillBuild extends Building,
  BeamDrill.java:220) — this gate is independent of the Drill family.
- **Frame keys `items` + `facing_amount`** (default 0):
  `_initial_frame()` gains both keys. `facingAmount` is recomputed by
  updateFacing (BeamDrill.java:375-410) from updateTile/onProximityUpdate,
  so the gate reads the PREVIOUS tick's facingAmount — the Java order
  (BuildingComp:2274-2277, updateConsumption before updateTile). The live
  facing scan itself is DEFERRED to the BeamDrill updateTile advance.
- **itemCapacity from the catalog** (10/20, fallback 10).
- The driver reads the gate through the pure function and feeds
  `should_consume` into the consumption machinery (the N2188/N2198
  precedent), so efficiency folds to 0 when the gate is false
  (BuildingComp.java:1960/:1992-1994). The power.row limit comment now says
  the gate is LIVE.
- **Coordinator fix at integration (`481315f8`):** the old N2155 proof
  `C07BeamDrillPowerStatusProof` key `efficiency_folds_power_min` seeds a
  plasma-bore with the new frame — with `facing_amount` defaulting to 0 the
  gate now closes and efficiency folds to 0, so the key would FAIL on Godot
  until the proof seeds `facing_amount > 0`. The fix seeds `facing_amount=1`
  in the N2155 proof. The other 4 old proofs needed no fix.

## RED

Test module `tools/mindustry_godot_transpiler/tests/test_c07_beam_drill_should_consume.py`
+ register script `tools/mindustry_godot_transpiler/register_c07_beam_drill_should_consume.py`
written by worker-N2202. Register script: EXACT_EXPRS = the 16 verified
exprs (all 16 unique, all present verbatim in upstream — script check,
0 missing), DEFERRED **251** entries (N2199's 252 minus the resolved
BeamDrill gate entry; no new deferral added by this slice).

RED run: the expected no-Godot pattern — registration + exact-evidence fail
`KeyError: 'N2202'`, the state test fails on the missing pure function, and
the proof test fails Godot-absent (`AssertionError: unexpectedly None` at
`assertIsNotNone(godot)`).

## GREEN

- Pure gate + driver wiring in `SourceBeamDrillBuildState.gd`; frame keys
  `items` + `facing_amount`; the limit comment updated. Header quotes the
  exact exprs, each Java line on ONE comment line (the N2148 lesson).
- Proof scene `godot-mindustry/tools/runtime_proofs/C07BeamDrillShouldConsumeProof.gd`
  + `.tscn` (6 keys + registry_valid / one_headquarter_per_ssot / matches):
  gate_true_when_all_three_conditions, gate_false_when_items_full,
  gate_false_when_no_facing, gate_false_when_disabled,
  efficiency_zero_when_gate_false, efficiency_folds_power_when_gate_true.
  Proof `.json` is gitignored (never stage, per AGENTS.md rule on proof .json).
- Register script: SSOT single-slice **+3/+1/+1/+2 → 11399/1641/1564/2919**
  from the N2199 base 11396/1640/1563/2917 (**3 symbols**, not 2, because
  the result includes `facing_amount`); audit totalSourceFunctions 1336,
  legacy 0. **Production shard CHANGED** (4 files).
- Targeted: **Ran 4 tests, 3/4 PASS** (registration, exact-evidence 16/16,
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

- Slice: `41ee66e0` — C07: N2202 BeamDrill shouldConsume gate, 5 files
  (+559/−15), on `slice/N2202-beam-drill-should-consume` (base `fb7c20e5`).
  Cherry-pick `8e922c31` on `integration/wave-items-n2200-n2204`.
- Coordinator fix: `481315f8` — seed facing_amount=1 in the N2155
  BeamDrill power proof (otherwise its `efficiency_folds_power_min` key
  fails on Godot now that the gate closes at facing_amount 0).
- SSOT: merged `80e99ebe` — wave-level SSOT (11407/1645/1568/2927), audit
  1336, legacy 0, validator errors [].
- Docs: (this commit) — report + handoff + spec + GOAL for N2200–N2204.
- NOT merged into main. Slice branch pushed 13:21, integration branch
  pushed per push-as-you-go immediately after the docs commit (user order
  12:08 + parent 12:26); push recorded in STATUS.md.

## Deferred (NOT this slice)

- Live facing scan: `facingAmount` is never recomputed on the live path
  yet (updateFacing, BeamDrill.java:375-410) — belongs to the BeamDrill
  updateTile advance, own slice. Until then the gate reads the seeded /
  previous-tick value.
- Live item intake: frame `items` is never filled on the live path yet —
  belongs to the BeamDrill updateTile advance (drop loop), own slice.
- The driver-wide disabled early return (BuildingComp.java:1954-1957) —
  deferred (same deviation as N2188/N2198/N2200–N2201/N2203–N2204).
- Godot proof never run on this VM (no Godot here, user order) — debt in GOAL.md §5:
  `C07BeamDrillShouldConsumeProof`, commit carrying the scene `41ee66e0`,
  6 keys (listed above + `registry_valid` / `one_headquarter_per_ssot` /
  `matches`), status "chờ agent Godot test". Run: targeted test
  `tests.test_c07_beam_drill_should_consume` with Godot 4.6.2 on PATH, port
  7777 free.
- Next: liquids wave (N2205 Pump, N2206 SolidPump, N2207 Fracker
  shouldConsume gates — scoping in `SCOPE-liquids-wave.md`) → payload →
  targets (see `DESIGN-frame-state-infra.md` in
  `~/workspace/mindustry-parallel/`).
