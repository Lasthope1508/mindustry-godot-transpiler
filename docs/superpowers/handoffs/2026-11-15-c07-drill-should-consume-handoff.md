# Handoff — N2204 base Drill shouldConsume gate

Date: 2026-11-15. Slice branch `slice/N2204-drill-should-consume`, base
`fb7c20e5` (N2199 tip). Integrated on `integration/wave-items-n2200-n2204`
(cherry-pick `df565569`). Status: **DONE (code + SSOT + neighbours + gate
clean except Godot; slice c9651592, merged SSOT 80e99ebe; NOT merged into
main; slice branch pushed 13:21, integration branch pushed immediately
after the docs commit).**

Done by worker-N2204 (slice, done 13:20 +07); integrated by coordinator
lượt 3, documented by coordinator lượt 4.

## Scoping (DONE 2026-11-15 12:19 +07, SCOPE-items-wave.md + brief-n2204-drill.md)

- `DrillBuild.shouldConsume()` (Drill.java:247-249): `return items.total()
  < itemCapacity && enabled && dominantItem != null;`.
- Port: `SourceDrillConsumptionRuntimeState.gd` (the base Drill power.status
  driver — there is no separate `SourceDrillBuildState.gd`). The frame
  ALREADY has every key needed (`items`, `dominant_item`,
  `dominant_items`, `enabled`) — the most self-contained slice of the wave:
  pure gate + driver wiring in the same file. The runtime context already
  computes `inventory.items_total(frame["items"]) <
  block.properties["itemCapacity"]` — the gate reuses it.
- `dominant_item` is set by the proximity path (Drill.java:275-277), null
  when there is no ore. `itemCapacity` from the catalog (10/10/10/20).
- File scope: ONLY `SourceDrillConsumptionRuntimeState.gd` (+
  test/register/proof) — does NOT touch `SourceBurstDrillBuildState.gd`
  (N2203's file). The base driver only ticks the 4 base Drill defs
  (implementation "Drill" + has consumeLiquid), so this gate cannot
  mis-apply to BurstDrill.
- SSOT baseline re-verified from the generated JSONs (base `fb7c20e5`):
  symbols 11396 + slices 1640 + contracts 1563 + schemas 2917; audit
  `totalSourceFunctions` 1336. Expected after N2204 (single-slice):
  **11398/1641/1564/2919** — confirmed.

## Design (decided in scoping, recorded in test + register)

- Pure `source_drill_should_consume_state(frame, item_capacity)` →
  `{should_consume}`; reads `items`, `enabled`, `dominant_item` from the
  drill frame.
- No new frame keys. The driver reads the gate through the pure function;
  the machinery folds efficiency to 0 when the gate is false.
- Proof scene `C07DrillShouldConsumeProof.gd/.tscn` (6 keys, N2185 pattern).

## RED (DONE 2026-11-15 13:20 +07, worker-N2204)

- Test module `tools/mindustry_godot_transpiler/tests/test_c07_drill_should_consume.py`
  + register script `tools/mindustry_godot_transpiler/register_c07_drill_should_consume.py`.
- Register script verified standalone: **exit 0**. **18 exact exprs, 0 missing**;
  DEFERRED 252 entries (unchanged — the base Drill gate was never deferred,
  so no entry is removed). OWNER
  `SourceDrillConsumptionRuntimeState.source_drill_should_consume_state`, PROOF
  `/root/C07DrillShouldConsumeProof`.
- Targeted RED run: the expected pattern — `KeyError: 'N2204'`
  (registration + exact-evidence), the missing pure function (state test),
  proof test fails Godot-absent (`AssertionError: unexpectedly None` at
  `assertIsNotNone(godot)`). No other failures. `git diff --check` clean.

## GREEN (DONE 2026-11-15 13:20 +07, worker-N2204)

- Pure gate + driver wiring (5 files, +593/−1); proof scene (6 keys); all
  18 exact exprs present, each on ONE comment line. The limit comment in
  the Drill power row now says the gate is LIVE.
- SSOT at GREEN (single-slice): **11398/1641/1564/2919**, audit 1336,
  legacy 0. Production shards: symbols 449 (+2), slices 49 (+1), contracts
  43 (+1), state_schema 45 (+1 — the input schema only; the shard does not
  mirror the result schema, the BurstDrill power-status precedent).
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

See `register_c07_drill_should_consume.py` EXACT_EXPRS (18 entries,
including `return items.total() < itemCapacity && enabled && dominantItem
!= null;` and the Blocks.java def lines).

## Next

- Liquids wave (N2205 Pump, N2206 SolidPump, N2207 Fracker shouldConsume
  gates — scoping in `SCOPE-liquids-wave.md`) → payload → targets → plans
  → units (see `DESIGN-frame-state-infra.md` in
  `~/workspace/mindustry-parallel/`).
- Standalone coordinator-serial work still pending: the driver-wide disabled
  early return fix (BuildingComp.java:1954-1957); the raw-delta audit of
  remaining runtime files; the N2198 tick cross-def fix slice.
- Godot proof debt: `C07DrillShouldConsumeProof`, 6 keys, status
  "chờ agent Godot test" (GOAL.md §5).

## Commits

- Slice: `c9651592` — C07: N2204 base Drill shouldConsume gate, 5 files (+593/−1).
  Cherry-pick `df565569` on `integration/wave-items-n2200-n2204`.
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
