# Report — N2216: BlockProducer (Constructor) shouldConsume gate (C07)

Date: 2026-11-15. Slice branch `slice/N2216-block-producer-should-consume`, base
`599b7573` (wave-targets docs tip). Integrated on `integration/wave-plans-n2215-n2216`
(cherry-pick `2f9641e6`). Status: **DONE (code + SSOT + neighbours + gate
clean except Godot; NOT merged into main; slice branch pushed 15:11 per
push-as-you-go; integration branch pushed immediately after the docs commit
— see STATUS.md).**

Done by worker-N2216 (slice, done 15:10 +07); integrated and documented by
coordinator lượt 4. Slice commit `0cf6ed6c`; merged SSOT `3977a45d`
(wave-level, 11431/1657/1580/2951).

## What changed

The Constructor power.status slice (N2161) folded power only and deferred
the shouldConsume gate ("recipe state is not tracked yet"). N2216 wires
the gate over a new frame key (the DESIGN-frame-state-infra.md pattern —
the Separator N2200 / payload N2208 precedent: frame key added, live fill
deferred; the port has no live recipe store on placed buildings):

- **Pure gate** `source_constructor_should_consume_state(frame)` in
  `SourceConstructorBuildState.gd` — mirrors
  BlockProducerBuild.shouldConsume() (BlockProducer.java:102-104): `return
  super.shouldConsume() && recipe() != null;`. `super` is the BuildingComp
  default `return enabled;` (BuildingComp.java:755-756) — PayloadBlockBuild
  does NOT override shouldConsume (verified by grep, 0 matches) — so the
  gate is effectively `enabled && recipe() != null`, mirrored exactly
  (the pure gate reads `frame["enabled"]` internally, the ItemBridge
  N2188 / N2212 precedent). Returns `{"should_consume", "has_recipe"}`
  (the N2201 precedent: the second result symbol is the value the gate
  reads).
- **Frame key `recipe`** (default null — the Java field is `public
  @Nullable Block recipe;`, Constructor.java:**59**, set via config
  `config(Block.class, ...)` (:32-37, only when `canProduce(block)`),
  cleared via `configClear` (:31/:38)). The gate reads only null-ness;
  no live fill sets the key yet (config path waits for the config
  advance slice).
- The driver feeds `should_consume` into the consumption machinery (the
  N2188/N2198 precedent), so efficiency folds to 0 when the gate is false
  (BuildingComp.java:1960/:1992-1994).
- The power.row limit comment now says the gate is LIVE.
- **Cite fix (part of this slice):** the coordinator scope cited the
  recipe field at Constructor.java:61 and config at :33-38 / configClear
  at :32/:39 — WRONG at this pin; the worker verified by grep and fixed
  all cites to :59 / :32-37 / :31/:38 (the N2214 precedent: never trust a
  scope cite blind).
- **No SingleBlockProducer slice:** the other BlockProducer subclass
  (`SingleBlockProducer.recipe()` returns a fixed block, always
  non-null) has NO defs in Blocks.java (grep 0 matches), so its gate is
  just the `enabled` default — no slice needed.

## RED

Test module `tools/mindustry_godot_transpiler/tests/test_c07_constructor_should_consume.py`
+ register script `tools/mindustry_godot_transpiler/register_c07_constructor_should_consume.py`
written by worker-N2216. Register script: EXACT_EXPRS = the 16 verified
exprs (all 16 unique, all present verbatim in upstream — script check,
0 missing), DEFERRED 257 entries (the BlockProducer gate entry resolved; 1 new
deferral added: Constructor live recipe config fill).

RED run: failures=2, errors=2 (registration + exact-evidence fail
`KeyError: 'N2216'`, the state test fails on the missing pure function, and
the proof test fails Godot-absent (`AssertionError: unexpectedly None` at
`assertIsNotNone(godot)`); pre-register after GREEN: failures=1, errors=2 —
the expected KeyError pattern).

## GREEN

- Pure gate + driver wiring in `SourceConstructorBuildState.gd`; frame key
  `recipe`; the limit comment updated. Header quotes the exact exprs, each
  Java line on ONE comment line (the N2148 lesson).
- Proof scene `godot-mindustry/tools/runtime_proofs/C07ConstructorShouldConsumeProof.gd`
  + `.tscn` (6 keys + registry_valid / one_headquarter_per_ssot / matches):
  gate_true_when_recipe_present, gate_false_when_recipe_null,
  gate_false_when_disabled, efficiency_zero_when_gate_false,
  efficiency_folds_power_when_gate_true, frame_recipe_default_null. The proof
  injects a minimal Dictionary fixture `{"block": "conveyor"}` as the recipe
  (only null-ness is read — stated in the proof; no real Block is built).
  Proof `.json` is gitignored (never stage, per AGENTS.md rule on proof .json).
- Register script: SSOT single-slice **+2/+1/+1/+2 → 11429/1656/1579/2949**
  from the wave-targets base 11427/1655/1578/2947; audit totalSourceFunctions
  1336, legacy 0. **Payload shard CHANGED** (`payload_api_contracts` +
  `payload_slices` — BlockProducer is a payload block).
- Targeted: **Ran 4 tests, 3/4 PASS** (registration, exact-evidence 16/16,
  state) + 1 FAIL, the proof test, failing exactly
  `AssertionError: unexpectedly None` at `assertIsNotNone(godot)` — **no Godot
  binary exists on this VM** (user order 2026-11-15: no Godot runs here at all —
  no headless, no MCP, no editor). The proof scene is written but NEVER run;
  see GOAL.md §5 debt.

## Neighbours (coordinator, main thread — wave-level)

Build/constructor family power_status (8 tests: BuildTurret N2184,
Constructor N2161): 6 PASS + 2 Godot-absent (the 2 power_status proofs),
0 other failures. Targeted 2 wave modules (8 tests): 6 PASS + 2 proof
tests Godot-absent. No regression.

## Gate

Full gate run 1 (PID 19171, launch 15:12 by coordinator lượt 4) KILLED by VM restart 3 ~15:22;
run 2 (PID 1756, relaunch 15:22, done 15:38 +07, log
`tools/mindustry_godot_transpiler/full-suite-wave-plans-gate.log`, untracked): Ran 5921 in 959.898s,
failures=157, skipped=5, 0 errors — 157/157 verified Godot-absent (155 inherited + 2 new proof tests
N2215–N2216, all confirmed present in the failures; 0 `ERROR:` lines). Gate clean except Godot; no
regression. No commits/files lost in the restart (javalang reinstalled 0.13.0).

## Commits

- Slice: `0cf6ed6c` — C07: N2216 BlockProducer (Constructor) shouldConsume gate,
  5 files (+788/−9), on `slice/N2216-block-producer-should-consume` (base
  `599b7573`). Cherry-pick `2f9641e6` on `integration/wave-plans-n2215-n2216`.
- Coordinator fix `c36f1cb7` at integration (by design, not a regression):
  seed a recipe fixture into the N2161 power proof — the constructor there
  has no recipe, so its `efficiency_folds_power_min` key would read 0 on
  Godot now that the gate closes on an empty frame (the 481315f8 / 53ed2029 /
  5779a6c4 precedent). Same fix applied to the N2184 power proof in the
  same commit. Verified the ticks do not reset the new frame keys.
- SSOT: merged `3977a45d` — wave-level SSOT (11431/1657/1580/2951), audit
  1336, legacy 0, validator errors [].
- Docs: (this commit) — report + handoff + spec + GOAL for N2215–N2216.
- NOT merged into main. Slice branch pushed 15:11, integration branch
  pushed per push-as-you-go immediately after the docs commit (user order
  12:08 + parent 12:26); push recorded in STATUS.md.

## Deferred (NOT this slice)

- Live recipe config fill: frame `recipe` is never filled on the live path
  yet — the config set/clear path (Constructor.java:31-38) belongs to the
  config advance slice, own slice.
- The dynamic item consumer (ConsumeItemDynamic over recipe requirements,
  BlockProducer.java:39-58) — the second consumer, own slice.
- The driver-wide disabled early return (BuildingComp.java:1954-1957) —
  deferred (same deviation as N2188/N2198/N2201–N2204).
- Godot proof never run on this VM (no Godot here, user order) — debt in GOAL.md §5:
  `C07ConstructorShouldConsumeProof`, commit carrying the scene `0cf6ed6c`,
  6 keys (listed above + `registry_valid` / `one_headquarter_per_ssot` /
  `matches`), status "chờ agent Godot test". Run: targeted test
  `tests.test_c07_constructor_should_consume` with Godot 4.6.2 on PATH, port
  7777 free.
- Next: units → updateTile advances → second consumers (see
  `DESIGN-frame-state-infra.md` in `~/workspace/mindustry-parallel/`).
