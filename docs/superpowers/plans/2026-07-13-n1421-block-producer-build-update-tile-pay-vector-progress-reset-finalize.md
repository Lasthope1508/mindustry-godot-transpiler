# N1421 BlockProducerBuild UpdateTile PayVector Progress Reset Finalize

## Scope

- Slice: `N1421`
- Title: `Generated BlockProducerBuild updateTile payVector/progress reset bridge state`
- Java source: `core/src/mindustry/world/blocks/payloads/BlockProducer.java`
- Java method: `BlockProducerBuild.updateTile() payVector/progress reset`
- Godot owner: `PortGame.source_block_producer_build_update_tile_pay_vector_progress_reset_state`
- Generated owner: `BlockProducer.BlockProducerBuild.updateTile.payVectorProgressReset`
- Runtime proof: `/root/Main.generated_block_producer_build_update_tile_pay_vector_progress_reset_bridge_state`

## Source Evidence

```java
payVector.setZero();
progress %= 1f;
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1421`.
- [x] Read exact upstream Java `BlockProducer.java`.
- [x] Confirmed `PortGame.source_block_producer_build_update_tile_pay_vector_progress_reset_state` is backed by exact source expressions.
- [x] Confirmed generated `BlockProducer.BlockProducerBuild.updateTile.payVectorProgressReset` bridge matches canonical reset state.
- [x] Added RED status assertion for `N1421`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1421` status to `done` in canonical ledger and shard mirrors.
- [x] Confirmed `N1422` remains `source-backed`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1421` canonical and nested status are `done`.
- [x] Godot TCP generated bridge proof confirmed true guard resets payVector to zero and applies progress modulo.
- [x] Godot TCP generated bridge proof confirmed false guard preserves payVector/progress.
- [x] Godot TCP source proof confirmed canonical reset state.
- [x] Godot TCP regression proof confirmed previous `BlockProducerBuild.updateTile.payloadCreation` bridge still matches.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_producer_build_update_tile_pay_vector_progress_reset_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_producer_build_update_tile_pay_vector_progress_reset_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k "source_block_producer_build_update_tile_pay_vector_progress_reset or generated_block_producer_build_update_tile_pay_vector_progress_reset"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k block_producer_build_update_tile_pay_vector_progress_reset`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k block_producer_build_update_tile_pay_vector_progress_reset`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k block_producer_build_update_tile_pay_vector_progress_reset`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 397.46s (0:06:37)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1421")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.generated_block_producer_build_update_tile_pay_vector_progress_reset_bridge_state(true, 3.5, -2.25, 7.75)`: `matches=true`, `pay_vector_after={"x":0,"y":0}`, `progress_after=0.75`.
  - TCP `/root/Main.generated_block_producer_build_update_tile_pay_vector_progress_reset_bridge_state(false, 3.5, -2.25, 7.75)`: `matches=true`, `pay_vector_after={"x":3.5,"y":-2.25}`, `progress_after=7.75`.
  - TCP `/root/Main.source_block_producer_build_update_tile_pay_vector_progress_reset_state(true, 3.5, -2.25, 7.75)`: `pay_vector_after={"x":0,"y":0}`, `progress_after=0.75`.
  - TCP `/root/Main.generated_block_producer_build_update_tile_payload_creation_bridge_state(true, {"block":"router"}, "sharded", 10.0, 20.0, 16.0, 8.0)`: `matches=true`, `payload_after.team=sharded`, `effect_radius=2`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1057`
- Not done: `16`
- Source-backed remaining: `16`
- Progress: `98.51%`
- Remaining: `1.49%`
- Next slice: `N1422`
- Next slice status: `source-backed`
- Next slice title: `Generated BlockProducerBuild updateTile heat/time bridge state`
