# N1238 TractorBeamBuild.read Finalize

## Scope

- Slice: `N1238`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/TractorBeamTurret.java`
- Java method: `TractorBeamBuild.read(Reads read, byte revision)`
- Godot owner: `PortGame.source_tractor_beam_turret_build_read_state`
- Runtime proof: `/root/Main.generated_tractor_beam_turret_build_read_bridge_state`

## Source Evidence

```java
179:         @Override
180:         public void read(Reads read, byte revision){
181:             super.read(read, revision);
182:
183:             rotation = read.f();
184:         }
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT roots/shards relevant to this source-backed slice.
- [x] Read upstream Java `TractorBeamBuild.read(Reads read, byte revision)`.
- [x] Added RED assertion for `N1238.status == done`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1238` status to `done` in canonical ledger and shards.
- [x] Flipped nested `source_slice_ledger_slices.N1238.slice.status` mirror to `done`.
- [x] Focused GREEN passed.
- [x] SSOT validator passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot debug output stayed clean.
- [x] Godot stop returned clean final errors.
- [x] Full Python suite passed.
- [x] Progress recalculated from canonical ledger.

## Verification

- Focused RED:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_read_slice_is_registered_with_source_backing`
  - Result: `1 failed, 1064 deselected in 9.79s`
  - Expected failure: `AssertionError: 'active' != 'done'`
- Focused GREEN:
  - Command: same focused pytest command
  - Result: `1 passed, 1064 deselected in 0.47s`
- SSOT validator:
  - Result: `{"module_count":112,"errors":[]}`
- Godot MCP runtime:
  - Startup: Godot `4.6.2.stable.official.71f334935`, TCP port `7777`.
  - TCP case `read_f_value=0.0`, `revision_value=0`: `matches=true`, `rotation_after=0`, `super_read_call={"call":"super.read(read, revision);","revision":0}`, `read_f_call={"call":"read.f();","value":0}`.
  - TCP case `read_f_value=45.25`, `revision_value=2`: `matches=true`, `rotation_after=45.25`, `super_read_call={"call":"super.read(read, revision);","revision":2}`, `read_f_call={"call":"read.f();","value":45.25}`.
  - After TCP: `errors=[]`
  - Stop: `finalErrors=[]`
- Full Python suite:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 393.51s (0:06:33)`

## Progress

- Total slices: `1073`
- Done: `935`
- Not done: `138`
- Active: `39`
- Source-backed not done: `99`
- Progress: `87.14%`
- Remaining: `12.86%`
- Next slice: `N1239 TractorBeamBuild.draw()`
- Next owner: `PortGame.source_tractor_beam_turret_build_draw_state`
- Next status: `active`

## Notes

- Full game is not complete yet.
- This checklist only closes `N1238`.
- Existing SSOT variable names `read_f_value`, `revision_value`, `rotation_after`, `super_read_call`, and `read_f_call` are preserved.
- Deferred internals remain explicit: `BaseTurretBuild super.read(read, revision) deserialized fields outside this slice`; `Reads stream implementation outside this source-state bridge`.
- Continue with max 1-3 source-backed slices per turn.
