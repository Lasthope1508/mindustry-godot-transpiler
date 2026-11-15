# Report — N2200: Separator shouldConsume gate (C07)

Date: 2026-11-15. Slice branch `slice/N2200-separator-should-consume`, base
`fb7c20e5` (N2199 tip). Integrated on `integration/wave-items-n2200-n2204`
(cherry-pick `437667c4`). Status: **DONE (code + SSOT + neighbours + gate
clean except Godot; NOT merged into main; slice branch pushed 13:21 per
push-as-you-go; integration branch pushed immediately after the docs commit
— see STATUS.md).**

Done by worker-N2200 (slice, done 13:19 +07); integrated by coordinator
lượt 3 (cherry-pick + merged SSOT + neighbours + gate) and documented by
coordinator lượt 4. Slice commit `99822420`; merged SSOT `80e99ebe`
(wave-level, 11407/1645/1568/2927).

## What changed

The Separator power.status slice (N2169) folded power only and deferred the
shouldConsume gate ("items state is not tracked yet"). N2200 wires the gate
over the items frame key (the DESIGN-frame-state-infra.md items pattern:
frame key `items` + the existing `SourceDrillInventoryRuntimeState` helpers,
the factory precedent `frame["items"] = {}`):

- **Pure gate** `source_separator_should_consume_state(frame, cons_items,
  item_capacity)` in `SourceSeparatorBuildState.gd` — mirrors
  SeparatorBuild.shouldConsume() (Separator.java:92-101): `int total =
  items.total();` (:93), then — when the block has a ConsumeItems consumer
  — the consItems buffer is subtracted (`for(ItemStack stack :
  consItems.items){ total -= items.get(stack.item); }`, :96-97), and
  `return total < itemCapacity && enabled;` (:100). Returns
  `{"should_consume", "total"}`.
- **consItems from the catalog**: the separator def has no consumeItem
  (Blocks.java:1231-1246), so its consItems is null and nothing is
  subtracted; the disassembler consumes scrap (`consumeItem(Items.scrap);`,
  Blocks.java:1263) and subtracts all held scrap. `itemCapacity` from the
  catalog (10/20, fallback 10; `public int itemCapacity = 10;`,
  Block.java:75, the default; disassembler `itemCapacity = 20;`,
  Blocks.java:1261).
- **Frame key `items`** (only): `_initial_frame()` gains the key; the
  driver reads the gate through the pure function and feeds `should_consume`
  into the consumption machinery (the N2188/N2198 precedent), so efficiency
  folds to 0 when the gate is false (BuildingComp.java:1960/:1992-1994).
- The power.row limit comment now says the gate is LIVE.

## RED

Test module `tools/mindustry_godot_transpiler/tests/test_c07_separator_should_consume.py`
+ register script `tools/mindustry_godot_transpiler/register_c07_separator_should_consume.py`
written by worker-N2200. Register script: EXACT_EXPRS = the 18 verified
exprs (all 18 unique, all present verbatim in upstream — script check,
0 missing), DEFERRED 252 entries (the Separator gate entry resolved; 1 new
deferral added: Separator items intake rows — no live intake fills
frame["items"] yet).

RED run: the expected no-Godot pattern — registration + exact-evidence fail
`KeyError: 'N2200'`, the state test fails on the missing pure function, and
the proof test fails Godot-absent (`AssertionError: unexpectedly None` at
`assertIsNotNone(godot)`).

## GREEN

- Pure gate + driver wiring in `SourceSeparatorBuildState.gd`; frame key
  `items`; the limit comment updated. Header quotes the exact exprs, each
  Java line on ONE comment line (the N2148 lesson).
- Proof scene `godot-mindustry/tools/runtime_proofs/C07SeparatorShouldConsumeProof.gd`
  + `.tscn` (6 keys + registry_valid / one_headquarter_per_ssot / matches):
  gate_true_below_capacity, gate_false_when_full, gate_false_when_disabled,
  buffer_cons_items_subtracted, efficiency_zero_when_gate_false,
  efficiency_folds_power_when_gate_true. Proof `.json` is gitignored (never
  stage, per AGENTS.md rule on proof .json).
- Register script: SSOT single-slice **+2/+1/+1/+2 → 11398/1641/1564/2919**
  from the N2199 base 11396/1640/1563/2917; audit totalSourceFunctions 1336,
  legacy 0. **Production shard CHANGED** (4 `production_*` files — the
  N2201 note: production shards mirror this family).
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

- Slice: `99822420` — C07: N2200 Separator shouldConsume gate, 5 files
  (+552/−9), on `slice/N2200-separator-should-consume` (base `fb7c20e5`).
  Cherry-pick `437667c4` on `integration/wave-items-n2200-n2204`.
- SSOT: merged `80e99ebe` — wave-level SSOT (11407/1645/1568/2927), audit
  1336, legacy 0, validator errors [].
- Docs: (this commit) — report + handoff + spec + GOAL for N2200–N2204.
- NOT merged into main. Slice branch pushed 13:21, integration branch
  pushed per push-as-you-go immediately after the docs commit (user order
  12:08 + parent 12:26); push recorded in STATUS.md.

## Deferred (NOT this slice)

- Live item intake: frame `items` is never filled on the live path yet —
  belongs to the Separator updateTile advance (progress/craft), own slice.
- The driver-wide disabled early return (BuildingComp.java:1954-1957) —
  deferred (same deviation as N2188/N2198/N2201–N2204).
- Godot proof never run on this VM (no Godot here, user order) — debt in GOAL.md §5:
  `C07SeparatorShouldConsumeProof`, commit carrying the scene `99822420`,
  6 keys (listed above + `registry_valid` / `one_headquarter_per_ssot` /
  `matches`), status "chờ agent Godot test". Run: targeted test
  `tests.test_c07_separator_should_consume` with Godot 4.6.2 on PATH, port
  7777 free.
- Next: liquids wave (N2205 Pump, N2206 SolidPump, N2207 Fracker
  shouldConsume gates — scoping in `SCOPE-liquids-wave.md`) → payload →
  targets (see `DESIGN-frame-state-infra.md` in
  `~/workspace/mindustry-parallel/`).
