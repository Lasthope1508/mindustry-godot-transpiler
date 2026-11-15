# Report — N2213: RepairTower shouldConsume gate (C07)

Date: 2026-11-15. Slice branch `slice/N2213-repair-tower-should-consume`, base
`c3718d04` (wave-payload docs tip). Integrated on `integration/wave-targets-n2212-n2214`
(cherry-pick `cbaec851`). Status: **DONE (code + SSOT + neighbours + gate
clean except Godot; NOT merged into main; slice branch pushed 14:46 per
push-as-you-go; integration branch pushed immediately after the docs commit
— see STATUS.md).**

Done by worker-N2213 (slice, done 14:44 +07); integrated and documented by
coordinator lượt 4. Slice commit `30fd7965`; merged SSOT `89e79132`
(wave-level, 11427/1655/1578/2947).

## What changed

The RepairTower power.status slice (N2176) folded power only and deferred
the shouldConsume gate ("the port tracks no live target on any
placed-building frame"). N2213 wires the gate over a new frame key (the
DESIGN-frame-state-infra.md targets pattern — the Separator N2200 /
payload N2208 precedent: frame key added, live fill deferred; the port has
no live target store on placed buildings):

- **Pure gate** `source_repair_tower_should_consume_state(frame)` in
  `SourceRepairTowerBuildState.gd` — mirrors
  RepairTowerBuild.shouldConsume() (RepairTower.java:89-91): `return
  targets.size > 0;` — this gate has NO `&& enabled`, mirrored exactly
  (the pure gate does NOT read `frame["enabled"]`). Returns
  `{"should_consume", "target_count"}` (the N2201 precedent: the second
  result symbol is the value the gate reads).
- **Frame key `targets`** (default [] — the Java field is `public Seq<Unit>
  targets = new Seq<>();`, RepairTower.java:54, refreshed periodically when
  `potentialEfficiency > 0 && (refresh += Time.delta) >= refreshInterval`
  (refreshInterval = 6f, static final :19) via `Units.nearby(team, x, y,
  range, damaged)` (:59-65)). The gate reads only the size; no live fill
  sets the key yet (targets refresh waits for the updateTile advance slice).
- The driver feeds `should_consume` into the consumption machinery (the
  N2188/N2198 precedent), so efficiency folds to 0 when the gate is false
  (BuildingComp.java:1960/:1992-1994).
- The power.row limit comment now says the gate is LIVE.

## RED

Test module `tools/mindustry_godot_transpiler/tests/test_c07_repair_tower_should_consume.py`
+ register script `tools/mindustry_godot_transpiler/register_c07_repair_tower_should_consume.py`
written by worker-N2213. Register script: EXACT_EXPRS = the 13 verified
exprs (all 13 unique, all present verbatim in upstream — script check,
0 missing), DEFERRED 257 entries (the RepairTower gate entry resolved; 1 new
deferral added: RepairTower live targets refresh via Units.nearby).

RED run: failures=2, errors=2 (registration + exact-evidence fail
`KeyError: 'N2213'`, the state test fails on the missing pure function, and
the proof test fails Godot-absent (`AssertionError: unexpectedly None` at
`assertIsNotNone(godot)`) — the same RED pattern as N2211's report).

## GREEN

- Pure gate + driver wiring in `SourceRepairTowerBuildState.gd`; frame key
  `targets`; the limit comment updated. Header quotes the exact exprs, each
  Java line on ONE comment line (the N2148 lesson).
- Proof scene `godot-mindustry/tools/runtime_proofs/C07RepairTowerShouldConsumeProof.gd`
  + `.tscn` (6 keys + registry_valid / one_headquarter_per_ssot / matches):
  gate_true_when_targets_nonempty, gate_false_when_targets_empty,
  gate_independent_of_enabled, efficiency_zero_when_gate_false,
  efficiency_folds_power_when_gate_true, frame_targets_default_empty. The proof
  injects a minimal list fixture `[{"type": "dart"}]` as the targets
  (only the size is read — stated in the proof; no real Unit is built).
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

- Slice: `30fd7965` — C07: N2213 RepairTower shouldConsume gate, 5 files
  (+739/−7), on `slice/N2213-repair-tower-should-consume` (base `c3718d04`).
  Cherry-pick `cbaec851` on `integration/wave-targets-n2212-n2214`.
- Coordinator fix `5779a6c4` at integration (by design, not a regression):
  seed a targets fixture into the N2176 power proof — the tower there has
  no targets, so its `efficiency_folds_power_min` key would read 0 on Godot
  now that the gate closes on an empty frame (the 481315f8 / 53ed2029
  precedent). Same fix applied to the N2174 + N2160 power proofs in the
  same commit. Verified the ticks do not reset the new frame keys.
- SSOT: merged `89e79132` — wave-level SSOT (11427/1655/1578/2947), audit
  1336, legacy 0, validator errors [].
- Docs: (this commit) — report + handoff + spec + GOAL for N2212–N2214.
- NOT merged into main. Slice branch pushed 14:46, integration branch
  pushed per push-as-you-go immediately after the docs commit (user order
  12:08 + parent 12:26); push recorded in STATUS.md.

## Deferred (NOT this slice)

- Live targets refresh: frame `targets` is never filled on the live path yet —
  the periodic `Units.nearby` refresh (RepairTower.java:59-65) belongs to the
  RepairTower updateTile advance, own slice.
- The ozone liquid consumer (consumeLiquid ozone 3f/60f, Blocks.java:6583) —
  the second consumer, own slice (the N2174 coolant precedent).
- The driver-wide disabled early return (BuildingComp.java:1954-1957) —
  deferred (same deviation as N2188/N2198/N2201–N2204).
- Godot proof never run on this VM (no Godot here, user order) — debt in GOAL.md §5:
  `C07RepairTowerShouldConsumeProof`, commit carrying the scene `30fd7965`,
  6 keys (listed above + `registry_valid` / `one_headquarter_per_ssot` /
  `matches`), status "chờ agent Godot test". Run: targeted test
  `tests.test_c07_repair_tower_should_consume` with Godot 4.6.2 on PATH, port
  7777 free.
- Next: plans (BuildTurret gate — see `DESIGN-frame-state-infra.md` in
  `~/workspace/mindustry-parallel/`) → units → updateTile advances.
