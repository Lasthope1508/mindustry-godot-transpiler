# N1161 Turret Limit Range Finalize

Goal: finalize source-backed Godot bridge for `Turret.limitRange(BulletType bullet, float margin)`.

Source:
- `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/Turret.java:242`
- Exact method boundary: `public void limitRange(BulletType bullet, float margin){`
- Exact real range expression: `float realRange = bullet.rangeChange + range;`
- Exact source comment: `//doesn't handle drag`
- Exact lifetime mutation: `bullet.lifetime = (realRange + margin + bullet.extraRangeMargin + 10f) / bullet.speed;`

Checklist:
- [x] Read `AGENTS.md`.
- [x] Read transpiler spec.
- [x] Read SSOT roots and N1161/N1162 ledger state.
- [x] Read exact upstream Java for `Turret.limitRange(BulletType bullet, float margin)`.
- [x] RED test added in `test_generated_turret_limit_range_slice_is_registered_with_source_backing`; expected pre-GREEN failure was `AssertionError: 'active' != 'done'`.
- [x] GREEN status update for N1161 in canonical ledger and mirror shards.
- [x] N1162 remains first unfinished slice.
- [x] Focused tests passed: `5 passed in 0.97s`.
- [x] SSOT validator passed: `module_count=112`, `errors=[]`, `defense_checked=137`, `ledger_checked=1073`.
- [x] Godot MCP runtime proof on `/root/Main.generated_turret_limit_range_bridge_state`.
- [x] Godot MCP debug output returned `errors=[]`.
- [x] Godot MCP stop returned `finalErrors=[]`.
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed in 416.86s`.

Godot MCP proof:
- Godot: `4.6.2-stable (official)`
- Project: `Mindustry Godot Port`
- Method: `/root/Main.generated_turret_limit_range_bridge_state`
- Input bullet: `{"rangeChange": 16.0, "extraRangeMargin": 4.0, "speed": 3.5}`
- Input margin: `5.0`
- Input turret range: `110.0`
- Generated owner: `Turret.java_method_limitRange_8`
- Source owner: `PortGame.source_turret_limit_range_state`
- Real range: `126.0`
- Bullet lifetime: `41.4285714285714`
- Updated bullet: `{"extraRangeMargin": 4.0, "lifetime": 41.4285714285714, "rangeChange": 16.0, "speed": 3.5}`
- Match result: `true`
- Runtime ledger status: `done`
- Runtime SSOT status: `done`

Progress:
- Total ledger slices: `1073`
- Done after N1161: `858`
- Not done after N1161: `215`
- Done percent after N1161: `79.96%`
- First unfinished slice: `N1162`

Files intentionally changed:
- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_modules/defense_slices.json`
- `godot-mindustry/src/generated/source_modules/source_slice_ledger_slices.json`
- `tools/mindustry_godot_transpiler/tests/test_source_symbols.py`
- `docs/superpowers/plans/2026-07-11-n1161-turret-limit-range-finalize.md`

Not part of this slice:
- `godot-mindustry/project.godot`
- `godot-mindustry/src/generated/classes/mindustry/entities/comp/BuildingComp.gd`
- `godot-mindustry/src/generated/classes/mindustry/entities/comp/BuildingTetherComp.gd`
- `godot-mindustry/src/generated/classes/mindustry/entities/comp/UnitTetherComp.gd`
- `arc-upstream/`
- generated `.gd.uid` files
