# N1237 TractorBeamBuild.write finalize

## Scope

- Slice: `N1237`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/TractorBeamTurret.java`
- Java method: `TractorBeamBuild.write(Writes write)`
- Godot owner: `PortGame.source_tractor_beam_turret_build_write_state`
- Runtime proof: `/root/Main.generated_tractor_beam_turret_build_write_bridge_state`

## Upstream Evidence

```java
172:         @Override
173:         public void write(Writes write){
174:             super.write(write);
175:
176:             write.f(rotation);
177:         }
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT roots/shards relevant to this source-backed slice.
- [x] Read exact upstream Java.
- [x] Add RED status assertion for `N1237`.
- [x] Focused RED confirmed expected status failure.
- [x] Flip only `N1237` status to `done` in canonical ledger and shard mirrors.
- [x] Focused GREEN passed.
- [x] SSOT validator passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.
- [x] Full Python suite passed.
- [x] Progress recalculated from canonical ledger.
- [ ] `git diff --check` passed.
- [ ] Exact files staged.
- [ ] Slice committed.

## Test Evidence

- Focused RED:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_write_slice_is_registered_with_source_backing`
  - Result: `AssertionError: 'active' != 'done'`
  - Summary: `1 failed, 1064 deselected in 9.78s`
- Focused GREEN:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_write_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected in 0.46s`
- SSOT validator:
  - Result: `{"module_count":112,"errors":[]}`
- Full Python suite:
  - Result: `4017 passed, 39290 subtests passed in 384.37s (0:06:24)`

## Godot MCP Runtime Evidence

- Runtime startup: Godot `4.6.2.stable.official.71f334935`, TCP port `7777`.
- Call `generated_tractor_beam_turret_build_write_bridge_state(0.0)`:
  - `matches=true`
  - `rotation=0`
  - `super_write_called=true`
  - `write_f_call={"call":"write.f(rotation);","value":0}`
- Call `generated_tractor_beam_turret_build_write_bridge_state(45.25)`:
  - `matches=true`
  - `rotation=45.25`
  - `super_write_called=true`
  - `write_f_call={"call":"write.f(rotation);","value":45.25}`
- Debug output: `errors=[]`
- Stop output: `finalErrors=[]`

## Progress

- Total slices: `1073`
- Done: `934`
- Not done: `139`
- Active: `40`
- Source-backed: `99`
- Progress: `87.05%`
- Remaining: `12.95%`

## Next

- Next slice: `N1238`
- Java method: `TractorBeamBuild.read(Reads read, byte revision)`
- Godot owner: `PortGame.source_tractor_beam_turret_build_read_state`
- Status: `active`
