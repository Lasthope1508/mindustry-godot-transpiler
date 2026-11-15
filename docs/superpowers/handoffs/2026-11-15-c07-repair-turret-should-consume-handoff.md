# Handoff — N2212 RepairTurret shouldConsume gate

Date: 2026-11-15. Slice branch `slice/N2212-repair-turret-should-consume`, base
`c3718d04` (wave-payload docs tip). Integrated on `integration/wave-targets-n2212-n2214`
(cherry-pick `f6b4a044`). Status: **DONE (code + SSOT + neighbours + gate
clean except Godot; slice 96de3ef1, merged SSOT 89e79132; NOT merged into
main; slice branch pushed 14:45, integration branch pushed immediately
after the docs commit).**

Done by worker-N2212 (slice, done 14:44 +07); integrated and documented by
coordinator lượt 4.

## Scoping (DONE 2026-11-15 ~14:55 +07, SCOPE-targets-wave.md + brief-n2212.md)

- `RepairPointBuild.shouldConsume()` (RepairTurret.java:221-223): `return
  target != null && enabled;` — HAS `&& enabled`. Build class is
  `RepairPointBuild` (:153), NOT `RepairTurretBuild`. Field `public Unit
  target;` (:154), default null; set via `Units.closest(team, x, y,
  repairRadius, Unit::damaged)` (:216), cleared when dead / out of range /
  fully healed (:193-194).
- Power consumer is conditional: `consumePowerCond(powerUse, entity ->
  entity.target != null)` (RepairTurret.java:89).
- Defs: repair-point (repairRadius 60f, powerUse 1f, Blocks.java:6386-6394)
  and repair-turret (repairRadius 145f, powerUse 5f + coolant,
  Blocks.java:6396-6410); class default repairRadius 50f (RepairTurret.java:32).
- Port: `SourceRepairTurretBuildState.gd`, `_initial_frame()` returns `{}` —
  the slice adds frame key `target` + pure gate + driver wiring. The port
  has no live target store on placed buildings; live fill is deferred to
  the updateTile advance slice (the Separator N2200 / payload N2208 precedent).
- SSOT baseline re-verified from the generated JSONs (base `c3718d04`):
  symbols 11421 + slices 1652 + contracts 1575 + schemas 2941; audit
  `totalSourceFunctions` 1336. Expected after N2212 (single-slice):
  **11423/1653/1576/2943** — confirmed.

## Design (decided in scoping, recorded in test + register)

- Pure `source_repair_turret_should_consume_state(frame)` →
  `{should_consume, has_target}` (the N2201 precedent: the second result
  symbol is the value the gate reads).
- Frame key `target` only (null default). The pure gate reads
  `frame["target"]` and `frame["enabled"]` (the ItemBridge N2188
  precedent — the gate HAS an enabled term). The driver reads the gate
  through the pure function; the machinery folds efficiency to 0 when the
  gate is false (BuildingComp.java:1960/:1992-1994).
- Proof scene `C07RepairTurretShouldConsumeProof.gd/.tscn` (6 keys, N2185 pattern).

## RED (DONE 2026-11-15 14:44 +07, worker-N2212)

- Test module `tools/mindustry_godot_transpiler/tests/test_c07_repair_turret_should_consume.py`
  + register script `tools/mindustry_godot_transpiler/register_c07_repair_turret_should_consume.py`.
- Register script verified standalone: **exit 0**. **13 exact exprs, 0 missing**;
  DEFERRED 257 entries. OWNER
  `SourceRepairTurretBuildState.source_repair_turret_should_consume_state`, PROOF
  `/root/C07RepairTurretShouldConsumeProof`.
- Targeted RED run: failures=2, errors=2 — `KeyError: 'N2212'`
  (registration + exact-evidence), the missing pure function (state test),
  proof test fails Godot-absent (`AssertionError: unexpectedly None` at
  `assertIsNotNone(godot)`). Pre-register after GREEN: failures=1, errors=2.
  No other failures. `git diff --check` clean.

## GREEN (DONE 2026-11-15 14:44 +07, worker-N2212)

- Pure gate + driver wiring + frame key `target` (5 files, +746/−9);
  proof scene (6 keys); all 13 exact exprs present, each on ONE comment
  line. The limit comment in the RepairTurret power row now says the gate
  is LIVE.
- SSOT at GREEN (single-slice): **11423/1653/1576/2943**, audit 1336,
  legacy 0. No shard changed. `git diff --check` clean.
- Targeted run: **Ran 4 tests, 3/4 PASS** (registration, exact-evidence
  13/13, state) + proof test FAIL, exactly `AssertionError: unexpectedly
  None` — no Godot on this VM (user order: no Godot runs here at all).
- Coordinator verification (lượt 4): commit + 5 files match the brief;
  register exit 0; targeted 3/4 after register; generated/ reverted,
  working tree clean. Neighbour check: N2174 power-status tests still 3/4.

## Neighbours (DONE 2026-11-15 ~14:50 +07, coordinator, main thread — wave-level)

- Repair/regen family power_status (16 tests): 12 PASS + 4 Godot-absent, 0
  other failures. Targeted 3 wave modules (12 tests): 9 PASS + 3 proof
  tests Godot-absent. No regression.
- Coordinator fix `5779a6c4` at integration (by design, not a regression):
  seed a target fixture into the N2174 power proof — the turret there has
  no target, so its `efficiency_folds_power_min` key would read 0 on Godot
  now that the gate closes on an empty frame (the 481315f8 / 53ed2029
  precedent). Same fix for the N2176 + N2160 power proofs in the same
  commit. Verified the ticks do not reset the new frame keys.

## Exact exprs (13, all verified verbatim at scoping — script check, 0 missing)

See `register_c07_repair_turret_should_consume.py` EXACT_EXPRS (13 entries,
including `return target != null && enabled;`, the field/build-class lines,
`Units.closest`, the heal advance, `consumePowerCond`, BuildingComp
1960/1992, `return enabled;`, and `powerUse = 1f;`/`5f;`).

## Next

- Plans (BuildTurret gate — see `DESIGN-frame-state-infra.md` in
  `~/workspace/mindustry-parallel/`) → units → updateTile advances.
- Standalone coordinator-serial work still pending: the driver-wide disabled
  early return fix (BuildingComp.java:1954-1957); the raw-delta audit of
  remaining runtime files; the N2198 tick cross-def fix slice; the N2160
  driver cite-cleanup slice (pin-drift cites listed in the N2214 report).
- Godot proof debt: `C07RepairTurretShouldConsumeProof`, 6 keys, status
  "chờ agent Godot test" (GOAL.md §5).

## Commits

- Slice: `96de3ef1` — C07: N2212 RepairTurret shouldConsume gate, 5 files (+746/−9).
  Cherry-pick `f6b4a044` on `integration/wave-targets-n2212-n2214`.
- Coordinator fix: `5779a6c4` — seed target/targets/any_targets fixtures in
  the N2174/N2176/N2160 power proofs.
- SSOT: merged `89e79132` — wave-level SSOT (11427/1655/1578/2947), audit
  1336, legacy 0, validator errors [].
- Docs: (this commit) — report + handoff + spec + GOAL for N2212–N2214.

## Gate (DONE 2026-11-15, log `full-suite-wave-targets-gate.log`)

Full gate (PID 15436, launch 14:47 by coordinator lượt 4, done 15:05 +07, log
`tools/mindustry_godot_transpiler/full-suite-wave-targets-gate.log`, untracked): Ran 5913 in 1040.657s,
failures=155, skipped=5, 0 errors — 155/155 verified Godot-absent (152 inherited + 3 new proof tests
N2212–N2214, all confirmed present in the failures; 0 `ERROR:` lines). Gate clean except Godot; no
regression.
