# N1195 LiquidTurret.init Finalize

## Scope

- Slice: `N1195`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/LiquidTurret.java`
- Java method: `LiquidTurret.init()`
- Godot owner: `PortGame.source_liquid_turret_init_state`
- Runtime proof: `/root/Main.generated_liquid_turret_init_bridge_state`

## Source Evidence

Exact upstream expressions preserved:

- `@Override`
- `public void init(){`
- `consume(new ConsumeLiquidFilter(i -> ammoTypes.containsKey(i), 1f){`
- `public void update(Building build){`
- `public void display(Stats stats){`
- `if(targetGround){`
- `ammoTypes.each((item, type) -> placeOverlapRange = Math.max(placeOverlapRange, range + type.rangeChange + placeOverlapMargin));`
- `super.init();`

Deferred:

- `ConsumeLiquidFilter` concrete internals beyond recorded filter and amount.
- Empty `update(Building build)` and `display(Stats stats)` bodies remain no-op per upstream.
- `LiquidTurretBuild.shouldActiveSound()` starts at `N1196`.

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read migration spec entry for `N1195`.
- [x] Read SSOT roots and N1195 shards.
- [x] Read exact upstream Java method.
- [x] Added RED status assertion in `test_generated_liquid_turret_init_slice_is_registered_with_source_backing`.
- [x] RED failed for expected reason: `active != done`.
- [x] GREEN updated N1195 status in canonical ledger and mirror shards.
- [x] Focused tests passed: `5 passed`.
- [x] SSOT validator passed: `module_count=112`, `errors=[]`, `defense_checked=137`, `ledger_checked=1073`.
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed`.
- [x] Godot MCP runtime started project and returned `errors=[]` before runtime call.
- [x] TCP runtime proof called `/root/Main.generated_liquid_turret_init_bridge_state`.
- [x] Runtime `target_ground=true`, `place_overlap_range=60`, `range_value=100`, `place_overlap_margin=8`, entries `rangeChange=5,-20` returned `matches=true`, `place_overlap_range_after=113`, and 2 overlap updates.
- [x] Runtime `target_ground=false` returned `matches=true`, `place_overlap_range_after=60`, and empty overlap updates.
- [x] Godot debug output after runtime proof returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Progress

- Total slices: `1073`
- Done: `892`
- Not done: `181`
- Progress: `83.13%`

## Files Updated

- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_modules/defense_slices.json`
- `godot-mindustry/src/generated/source_modules/source_slice_ledger_slices.json`
- `tools/mindustry_godot_transpiler/tests/test_source_symbols.py`
- `docs/superpowers/plans/2026-07-11-n1195-liquid-turret-init-finalize.md`

## Next

- `N1196`: `LiquidTurretBuild.shouldActiveSound()`
- Status before next slice: `active`
