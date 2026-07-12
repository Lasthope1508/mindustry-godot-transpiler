# N1240 TractorBeamBuild.updateTile Activation Finalize

## Scope

- Slice: `N1240`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/TractorBeamTurret.java`
- Java method: `TractorBeamBuild.updateTile() activation timer`
- Godot owner: `PortGame.source_tractor_beam_turret_build_update_tile_activation_state`
- Runtime proof: `/root/Main.generated_tractor_beam_turret_build_update_tile_activation_bridge_state`

## Source Evidence

```java
77:         @Override
78:         public void updateTile(){
79:             if(activationTimer > 0){
80:                 activationTimer -= Time.delta;
81:                 return;
82:             }
83:
84:             float eff = efficiency * coolantMultiplier, edelta = eff * delta();
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT roots/shards relevant to this source-backed slice.
- [x] Read upstream Java activation block in `TractorBeamBuild.updateTile()`.
- [x] Added RED assertion for `N1240.status == done`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1240` status to `done` in canonical ledger and shards.
- [x] Flipped nested `source_slice_ledger_slices.N1240.slice.status` mirror to `done`.
- [x] Added RED test requiring N1240 generated bridge to return activation-only result subset.
- [x] Focused GREEN passed for status and bridge subset.
- [x] SSOT validator passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot debug output stayed clean after fresh runtime proof.
- [x] Godot stop returned clean final errors after fresh runtime proof.
- [x] Full Python suite passed.
- [x] Progress recalculated from canonical ledger.

## Verification

- Focused status RED:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_update_tile_activation_slice_is_registered_with_source_backing`
  - Result: `1 failed, 1064 deselected in 9.74s`
  - Expected failure: `AssertionError: 'source-backed' != 'done'`
- Focused bridge subset RED:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k port_game_exposes_generated_tractor_beam_turret_build_update_tile_activation_bridge_state`
  - Expected failure: missing `var activation_result := {`
- Focused GREEN:
  - Status result: `1 passed, 1064 deselected in 0.47s`
  - Bridge subset result: `1 passed, 1544 deselected in 0.50s`
- SSOT validator:
  - Result: `{"module_count":112,"errors":[]}`
- Godot MCP runtime:
  - Fresh startup: Godot `4.6.2.stable.official.71f334935`, TCP port `7777`.
  - TCP active case `activation_timer=3.5`, `time_delta=0.75`: `matches=true`, `activation_guard=true`, `activation_timer_after=2.75`, `returned_early=true`.
  - TCP inactive case `activation_timer=0`, `time_delta=0.75`: `matches=true`, `activation_guard=false`, `activation_timer_after=0`, `returned_early=false`.
  - Bridge result keys limited to activation slice fields.
  - After TCP: `errors=[]`
  - Stop: `finalErrors=[]`
- Full Python suite:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 388.48s (0:06:28)`

## Progress

- Total slices: `1073`
- Done: `937`
- Not done: `136`
- Active: `38`
- Source-backed not done: `98`
- Progress: `87.33%`
- Remaining: `12.67%`
- Next slice: `N1241 TractorBeamBuild.updateTile() eff/edelta`
- Next owner: `PortGame.source_tractor_beam_turret_build_update_tile_eff_state`
- Next status: `source-backed`

## Notes

- Full game is not complete yet.
- This checklist only closes `N1240`.
- Existing SSOT variable names `activation_timer`, `time_delta`, `activation_guard`, `activation_timer_after`, and `returned_early` are preserved.
- Bridge now returns an activation-only generated result subset so deferred updateTile fields from later slices are not serialized during N1240 runtime proof.
- Continue with max 1-3 source-backed slices per turn.
