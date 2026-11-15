# Handoff — N2200 Separator shouldConsume gate

Date: 2026-11-15. Slice branch `slice/N2200-separator-should-consume`, base
`fb7c20e5` (N2199 tip). Integrated on `integration/wave-items-n2200-n2204`
(cherry-pick `437667c4`). Status: **DONE (code + SSOT + neighbours + gate
clean except Godot; slice 99822420, merged SSOT 80e99ebe; NOT merged into
main; slice branch pushed 13:21, integration branch pushed immediately
after the docs commit).**

Done by worker-N2200 (slice, done 13:19 +07); integrated by coordinator
lượt 3, documented by coordinator lượt 4.

## Scoping (DONE 2026-11-15 12:19 +07, SCOPE-items-wave.md + brief-n2200-separator.md)

- `SeparatorBuild.shouldConsume()` (Separator.java:92-101): `int total =
  items.total();` (:93), subtract the consItems buffer
  (`for(ItemStack stack : consItems.items){ total -=
  items.get(stack.item); }`, :96-97), `return total < itemCapacity &&
  enabled;` (:100).
- The separator def has no consumeItem (Blocks.java:1231-1246) — consItems
  null, nothing subtracted; the disassembler consumes scrap
  (`consumeItem(Items.scrap);`, Blocks.java:1263). `itemCapacity` default
  10 (Block.java:75); disassembler 20 (Blocks.java:1261).
- Port: `SourceSeparatorBuildState.gd`, `_initial_frame()` returns `{}` —
  the slice adds frame key `items` + pure gate + driver wiring (gate feeds
  `should_consume` into the machinery, the N2188/N2198 precedent). Helpers
  already exist in `SourceDrillInventoryRuntimeState` (`items_total` etc.);
  the factory precedent is frame key `frame["items"] = {}`.
- SSOT baseline re-verified from the generated JSONs (base `fb7c20e5`):
  symbols 11396 + slices 1640 + contracts 1563 + schemas 2917; audit
  `totalSourceFunctions` 1336. Expected after N2200 (single-slice):
  **11398/1641/1564/2919** — confirmed.

## Design (decided in scoping, recorded in test + register)

- Pure `source_separator_should_consume_state(frame, cons_items,
  item_capacity)` → `{should_consume, total}`; the consItems list comes
  from the catalog `consumeItem` of the def.
- Frame key `items` only (Dictionary keyed by item name). The driver reads
  the gate through the pure function; the machinery folds efficiency to 0
  when the gate is false.
- Proof scene `C07SeparatorShouldConsumeProof.gd/.tscn` (6 keys, N2185 pattern).

## RED (DONE 2026-11-15 13:19 +07, worker-N2200)

- Test module `tools/mindustry_godot_transpiler/tests/test_c07_separator_should_consume.py`
  + register script `tools/mindustry_godot_transpiler/register_c07_separator_should_consume.py`.
- Register script verified standalone: **exit 0**. **18 exact exprs, 0 missing**;
  DEFERRED 252 entries. OWNER
  `SourceSeparatorBuildState.source_separator_should_consume_state`, PROOF
  `/root/C07SeparatorShouldConsumeProof`.
- Targeted RED run: the expected pattern — `KeyError: 'N2200'`
  (registration + exact-evidence), the missing pure function (state test),
  proof test fails Godot-absent (`AssertionError: unexpectedly None` at
  `assertIsNotNone(godot)`). No other failures. `git diff --check` clean.

## GREEN (DONE 2026-11-15 13:19 +07, worker-N2200)

- Pure gate + driver wiring + frame key `items` (5 files, +552/−9); proof
  scene (6 keys); all 18 exact exprs present, each on ONE comment line.
  The limit comment in the Separator power row now says the gate is LIVE.
- SSOT at GREEN (single-slice): **11398/1641/1564/2919**, audit 1336,
  legacy 0. Production shard CHANGED (4 files). `git diff --check` clean.
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

See `register_c07_separator_should_consume.py` EXACT_EXPRS (18 entries,
including `int total = items.total();`, the consItems subtraction loop,
`return total < itemCapacity && enabled;`, and the Blocks.java def lines).

## Next

- Liquids wave (N2205 Pump, N2206 SolidPump, N2207 Fracker shouldConsume
  gates — scoping in `SCOPE-liquids-wave.md`) → payload → targets → plans
  → units (see `DESIGN-frame-state-infra.md` in
  `~/workspace/mindustry-parallel/`).
- Standalone coordinator-serial work still pending: the driver-wide disabled
  early return fix (BuildingComp.java:1954-1957); the raw-delta audit of
  remaining runtime files; the N2198 tick cross-def fix slice.
- Godot proof debt: `C07SeparatorShouldConsumeProof`, 6 keys, status
  "chờ agent Godot test" (GOAL.md §5).

## Commits

- Slice: `99822420` — C07: N2200 Separator shouldConsume gate, 5 files (+552/−9).
  Cherry-pick `437667c4` on `integration/wave-items-n2200-n2204`.
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
