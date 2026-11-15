# Report — N2212: RepairTurret shouldConsume gate (C07)

Date: 2026-11-15. Slice branch `slice/N2212-repair-turret-should-consume`, base
`c3718d04` (wave-payload docs tip). Integrated on `integration/wave-targets-n2212-n2214`
(cherry-pick `f6b4a044`). Status: **DONE (code + SSOT + neighbours + gate
clean except Godot; NOT merged into main; slice branch pushed 14:45 per
push-as-you-go; integration branch pushed immediately after the docs commit
— see STATUS.md).**

Done by worker-N2212 (slice, done 14:44 +07); integrated and documented by
coordinator lượt 4. Slice commit `96de3ef1`; merged SSOT `89e79132`
(wave-level, 11427/1655/1578/2947).

## What changed

The RepairTurret power.status slice (N2174) folded power only and deferred
the shouldConsume gate ("the port tracks no live target on any
placed-building frame"). N2212 wires the gate over a new frame key (the
DESIGN-frame-state-infra.md targets pattern — the Separator N2200 /
payload N2208 precedent: frame key added, live fill deferred; the port has
no live target store on placed buildings):

- **Pure gate** `source_repair_turret_should_consume_state(frame)` in
  `SourceRepairTurretBuildState.gd` — mirrors
  RepairPointBuild.shouldConsume() (RepairTurret.java:221-223): `return
  target != null && enabled;` — this gate HAS `&& enabled`, mirrored
  exactly (the pure gate reads both `frame["target"]` and
  `frame["enabled"]`, the ItemBridge N2188 precedent). Returns
  `{"should_consume", "has_target"}` (the N2201 precedent: the second
  result symbol is the value the gate reads).
- **Frame key `target`** (default null — the Java field is `public Unit
  target;`, RepairTurret.java:154, set in updateTile via `Units.closest(
  team, x, y, repairRadius, Unit::damaged)` (:216), cleared when the target
  is dead / out of range / fully healed (:193-194)). The gate reads only
  null-ness; no live fill sets the key yet (target acquire waits for the
  updateTile advance slice).
- The driver feeds `should_consume` into the consumption machinery (the
  N2188/N2198 precedent), so efficiency folds to 0 when the gate is false
  (BuildingComp.java:1960/:1992-1994). This also resolves the N2174
  deviation: with no target requestedPower was 0 so power.status read 1.0
  while Java efficiency was 0 (the power consumer is conditional —
  `consumePowerCond(powerUse, entity -> entity.target != null)`,
  RepairTurret.java:89).
- The power.row limit comment now says the gate is LIVE (N2212).

## RED

Test module `tools/mindustry_godot_transpiler/tests/test_c07_repair_turret_should_consume.py`
+ register script `tools/mindustry_godot_transpiler/register_c07_repair_turret_should_consume.py`
written by worker-N2212. Register script: EXACT_EXPRS = the 13 verified
exprs (all 13 unique, all present verbatim in upstream — script check,
0 missing), DEFERRED 257 entries (the RepairTurret gate entry resolved; 1 new
deferral added: RepairTurret live target acquire via Units.closest).

RED run: failures=2, errors=2 (registration + exact-evidence fail
`KeyError: 'N2212'`, the state test fails on the missing pure function, and
the proof test fails Godot-absent (`AssertionError: unexpectedly None` at
`assertIsNotNone(godot)`); pre-register after GREEN: failures=1, errors=2 —
the expected KeyError pattern).

## GREEN

- Pure gate + driver wiring in `SourceRepairTurretBuildState.gd`; frame key
  `target`; the limit comment updated. Header quotes the exact exprs, each
  Java line on ONE comment line (the N2148 lesson).
- Proof scene `godot-mindustry/tools/runtime_proofs/C07RepairTurretShouldConsumeProof.gd`
  + `.tscn` (6 keys + registry_valid / one_headquarter_per_ssot / matches):
  gate_true_when_target_present, gate_false_when_target_null,
  gate_false_when_disabled, efficiency_zero_when_gate_false,
  efficiency_folds_power_when_gate_true, frame_target_default_null. The proof
  injects a minimal Dictionary fixture `{"type": "dart"}` as the target
  (only null-ness is read — stated in the proof; no real Unit is built).
  Proof `.json` is gitignored (never stage, per AGENTS.md rule on proof .json).
- Register script: SSOT single-slice **+2/+1/+1/+2 → 11423/1653/1576/2943**
  from the wave-payload base 11421/1652/1575/2941; audit totalSourceFunctions
  1336, legacy 0. **No shard changed** (only the 4 canonical SSOT JSONs).
- Targeted: **Ran 4 tests, 3/4 PASS** (registration, exact-evidence 13/13,
  state) + 1 FAIL, the proof test, failing exactly
  `AssertionError: unexpectedly None` at `assertIsNotNone(godot)` — **no Godot
  binary exists on this VM** (user order 2026-11-15: no Godot runs here at all —
  no headless, no MCP, no editor). The proof scene is written but NEVER run;
  see GOAL.md §5 debt.

## Neighbours (coordinator, main thread — wave-level)

Repair/regen family power_status (16 tests: RepairTurret N2174, RepairTower
N2176, RegenProjector N2160, MendProjector N2193): 12 PASS + 4 Godot-absent
(the 4 power_status proofs), 0 other failures. Targeted 3 wave modules
(12 tests): 9 PASS + 3 proof tests Godot-absent. No regression.

## Gate

Full gate (PID 15436, launch 14:47 by coordinator lượt 4, done 15:05 +07, log
`tools/mindustry_godot_transpiler/full-suite-wave-targets-gate.log`, untracked): Ran 5913 in 1040.657s,
failures=155, skipped=5, 0 errors — 155/155 verified Godot-absent (152 inherited + 3 new proof tests
N2212–N2214, all confirmed present in the failures; 0 `ERROR:` lines). Gate clean except Godot; no
regression.

## Commits

- Slice: `96de3ef1` — C07: N2212 RepairTurret shouldConsume gate, 5 files
  (+746/−9), on `slice/N2212-repair-turret-should-consume` (base `c3718d04`).
  Cherry-pick `f6b4a044` on `integration/wave-targets-n2212-n2214`.
- Coordinator fix `5779a6c4` at integration (by design, not a regression):
  seed a target fixture into the N2174 power proof — the turret there has
  no target, so its `efficiency_folds_power_min` key would read 0 on Godot
  now that the gate closes on an empty frame (the 481315f8 / 53ed2029
  precedent). Same fix applied to the N2176 + N2160 power proofs in the
  same commit. Verified the ticks do not reset the new frame keys.
- SSOT: merged `89e79132` — wave-level SSOT (11427/1655/1578/2947), audit
  1336, legacy 0, validator errors [].
- Docs: (this commit) — report + handoff + spec + GOAL for N2212–N2214.
- NOT merged into main. Slice branch pushed 14:45, integration branch
  pushed per push-as-you-go immediately after the docs commit (user order
  12:08 + parent 12:26); push recorded in STATUS.md.

## Deferred (NOT this slice)

- Live target acquire: frame `target` is never filled on the live path yet —
  the clear (:193-194) + re-acquire every 20 ticks via `Units.closest`
  (:214-216) belong to the RepairTurret updateTile advance, own slice.
- The coolant optional consumer (repair-turret only: ConsumeCoolant,
  coolantUse 0.16f, coolantMultiplier 1.6f, Blocks.java:6404-6406) — the
  second pass, own slice.
- The driver-wide disabled early return (BuildingComp.java:1954-1957) —
  deferred (same deviation as N2188/N2198/N2201–N2204).
- Godot proof never run on this VM (no Godot here, user order) — debt in GOAL.md §5:
  `C07RepairTurretShouldConsumeProof`, commit carrying the scene `96de3ef1`,
  6 keys (listed above + `registry_valid` / `one_headquarter_per_ssot` /
  `matches`), status "chờ agent Godot test". Run: targeted test
  `tests.test_c07_repair_turret_should_consume` with Godot 4.6.2 on PATH, port
  7777 free.
- Next: plans (BuildTurret gate — see `DESIGN-frame-state-infra.md` in
  `~/workspace/mindustry-parallel/`) → units → updateTile advances.
