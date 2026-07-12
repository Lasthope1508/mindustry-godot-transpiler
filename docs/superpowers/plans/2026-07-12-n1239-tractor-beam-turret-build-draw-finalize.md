# N1239 TractorBeamBuild.draw Finalize

## Scope

- Slice: `N1239`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/TractorBeamTurret.java`
- Java method: `TractorBeamBuild.draw()`
- Godot owner: `PortGame.source_tractor_beam_turret_build_draw_state`
- Runtime proof: `/root/Main.generated_tractor_beam_turret_build_draw_bridge_state`

## Source Evidence

```java
151:         @Override
152:         public void draw(){
153:             Draw.rect(baseRegion, x, y);
154:             Drawf.shadow(region, x - (size / 2f), y - (size / 2f), rotation - 90);
155:             Draw.rect(region, x, y, rotation - 90);
156:
157:             //draw laser if applicable
158:             if(any && !isPayload()){
159:                 Draw.z(Layer.bullet);
160:                 float ang = angleTo(lastX, lastY);
161:
162:                 Draw.mixcol(laserColor, Mathf.absin(4f, 0.6f));
163:
164:                 Drawf.laser(laser, laserStart, laserEnd,
165:                 x + Angles.trnsx(ang, shootLength), y + Angles.trnsy(ang, shootLength),
166:                 lastX, lastY, strength * efficiency * laserWidth);
167:
168:                 Draw.mixcol();
169:             }
170:         }
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT roots/shards relevant to this source-backed slice.
- [x] Read upstream Java `TractorBeamBuild.draw()`.
- [x] Added RED assertion for `N1239.status == done`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1239` status to `done` in canonical ledger and shards.
- [x] Flipped nested `source_slice_ledger_slices.N1239.slice.status` mirror to `done`.
- [x] Focused GREEN passed.
- [x] SSOT validator passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot debug output stayed clean.
- [x] Godot stop returned clean final errors.
- [x] Full Python suite passed.
- [x] Progress recalculated from canonical ledger.

## Verification

- Focused RED:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_draw_slice_is_registered_with_source_backing`
  - Result: `1 failed, 1064 deselected in 9.68s`
  - Expected failure: `AssertionError: 'active' != 'done'`
- Focused GREEN:
  - Command: same focused pytest command
  - Result: `1 passed, 1064 deselected in 0.46s`
- SSOT validator:
  - Result: `{"module_count":112,"errors":[]}`
- Godot MCP runtime:
  - Startup: Godot `4.6.2.stable.official.71f334935`, TCP port `7777`.
  - TCP laser case: `matches=true`, `laser_guard=true`, `draw_rotation=45`, `shadow_call.x=8`, `shadow_call.y=18`, `laser_call.start_x=14.8`, `laser_call.start_y=23.6`, `laser_call.width=1.125`, `mixcol_reset_called=true`.
  - TCP payload case: `matches=true`, `laser_guard=false`, `draw_rotation=45`, `laser_call={}`, `mixcol_call={}`, `mixcol_reset_called=false`.
  - After TCP: `errors=[]`
  - Stop: `finalErrors=[]`
- Full Python suite:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 390.22s (0:06:30)`

## Progress

- Total slices: `1073`
- Done: `936`
- Not done: `137`
- Active: `38`
- Source-backed not done: `99`
- Progress: `87.23%`
- Remaining: `12.77%`
- Next slice: `N1240 TractorBeamBuild.updateTile() activation timer`
- Next owner: `PortGame.source_tractor_beam_turret_build_update_tile_activation_state`
- Next status: `source-backed`

## Notes

- Full game is not complete yet.
- This checklist only closes `N1239`.
- Existing SSOT variable names `base_region`, `region`, `rotation_value`, `any_state`, `is_payload`, `last_x`, `last_y`, `mathf_absin_4_0_6`, `laser_guard`, `laser_call`, `mixcol_call`, and `mixcol_reset_called` are preserved.
- Deferred internals remain explicit: `Actual Arc Draw and Drawf rendering side effects are represented as call dictionaries in this slice`; `TextureRegion loading and isPayload implementation are supplied as explicit inputs`.
- Continue with max 1-3 source-backed slices per turn.
