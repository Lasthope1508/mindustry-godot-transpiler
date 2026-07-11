# N1165 Reload Turret Set Stats Finalize

Goal: finalize source-backed Godot bridge for `ReloadTurret.setStats()`.

Source:
- `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java:10`
- `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java:17`
- Exact field default: `public float reload = 10f;`
- Exact override: `@Override`
- Exact method boundary: `public void setStats(){`
- Exact super call: `super.setStats();`
- Exact coolant gate: `if(coolant != null){`
- Exact stat replace call: `stats.replace(Stat.booster, StatValues.boosters(reload, coolant.amount, coolantMultiplier, true, coolant::consumes));`

Checklist:
- [x] Read `AGENTS.md`.
- [x] Read transpiler spec.
- [x] Read SSOT roots and N1164-N1166 ledger state.
- [x] Read `source_ssot_modules.json` and relevant defense/source slice shards.
- [x] Read exact upstream Java for `ReloadTurret.setStats`.
- [x] RED test added in `test_generated_reload_turret_set_stats_slice_is_registered_with_source_backing`; expected pre-GREEN failure was `AssertionError: 'active' != 'done'`.
- [x] GREEN status update for N1165 in canonical ledger and mirror shards.
- [x] N1166 remains first unfinished slice.
- [x] Focused tests passed: `5 passed in 0.93s`.
- [x] SSOT validator passed: `module_count=112`, `errors=[]`, `defense_checked=137`, `ledger_checked=1073`.
- [x] Godot MCP runtime proof on `/root/Main.generated_reload_turret_set_stats_bridge_state`.
- [x] Godot MCP debug output returned `errors=[]`.
- [x] Godot MCP stop returned `finalErrors=[]`.
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed in 406.10s`.

Godot MCP proof:
- Godot: `4.6.2-stable (official)`
- Project: `Mindustry Godot Port`
- Method: `/root/Main.generated_reload_turret_set_stats_bridge_state`
- True-branch input: `coolant_present=true`, `reload_value=10.0`, `coolant_amount=0.2`, `coolant_multiplier=1.5`
- True-branch generated owner: `ReloadTurret.java_method_setStats_0`
- True-branch source owner: `PortGame.source_reload_turret_set_stats_state`
- True-branch match result: `true`
- True-branch super call recorded: `true`
- True-branch booster replace called: `true`
- True-branch booster replace call: `{"base": true, "call": "stats.replace(Stat.booster, StatValues.boosters(reload, coolant.amount, coolantMultiplier, true, coolant::consumes));", "consumes": "coolant::consumes", "coolant_amount": 0.2, "coolant_multiplier": 1.5, "reload": 10.0, "stat": "Stat.booster"}`
- False-branch input uses same numeric values with `coolant_present=false`.
- False-branch match result: `true`
- False-branch booster replace called: `false`
- Runtime ledger status: `done`
- Runtime SSOT status: `done`
- Runtime SSOT nested status: `done`

Progress:
- Total ledger slices: `1073`
- Done after N1165: `862`
- Not done after N1165: `211`
- Done percent after N1165: `80.34%`
- First unfinished slice: `N1166`

Files intentionally changed:
- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_modules/defense_slices.json`
- `godot-mindustry/src/generated/source_modules/source_slice_ledger_slices.json`
- `tools/mindustry_godot_transpiler/tests/test_source_symbols.py`
- `docs/superpowers/plans/2026-07-11-n1165-reload-turret-set-stats-finalize.md`

Not part of this slice:
- `godot-mindustry/project.godot`
- `godot-mindustry/src/generated/classes/mindustry/entities/comp/BuildingComp.gd`
- `godot-mindustry/src/generated/classes/mindustry/entities/comp/BuildingTetherComp.gd`
- `godot-mindustry/src/generated/classes/mindustry/entities/comp/UnitTetherComp.gd`
- `arc-upstream/`
- generated `.gd.uid` files
