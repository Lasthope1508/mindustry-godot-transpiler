# N1423 BlockProducer Move Out Payload Finalize

## Scope

- Slice: `N1423`
- Java source: `core/src/mindustry/world/blocks/payloads/BlockProducer.java`
- Parent Java source: `core/src/mindustry/world/blocks/payloads/PayloadBlock.java`
- Java method: `BlockProducerBuild.updateTile() moveOutPayload`
- Godot owner: `PortGame.source_block_producer_build_update_tile_move_out_payload_state`
- Generated owner: `BlockProducer.BlockProducerBuild.updateTile.moveOutPayload`
- Runtime proof: `/root/Main.generated_block_producer_build_update_tile_move_out_payload_bridge_state`

## Source Evidence

`BlockProducerBuild.updateTile()` source dispatch:

```java
@Override
public void updateTile(){
    super.updateTile();
    var recipe = recipe();
    boolean produce = recipe != null && efficiency > 0 && payload == null;

    if(produce){
        progress += buildSpeed * edelta();

        if(progress >= recipe.buildTime){
            consume();
            payload = new BuildPayload(recipe, team);
            payload.block().placeEffect.at(x, y, payload.size() / tilesize);
            payVector.setZero();
            progress %= 1f;
        }
    }

    heat = Mathf.lerpDelta(heat, Mathf.num(produce), 0.15f);
    time += heat * delta();

    moveOutPayload();
}
```

`PayloadBlockBuild.moveOutPayload()` source:

```java
public void moveOutPayload(){
    if(payload == null) return;

    updatePayload();

    Vec2 dest = Tmp.v1.trns(rotdeg(), size * tilesize/2f);

    payRotation = Angles.moveToward(payRotation, rotdeg(), payloadRotateSpeed * delta());
    payVector.approach(dest, payloadSpeed * delta());

    Building front = front();
    boolean canDump = front == null || !front.tile.solid();
    boolean canMove = front != null && (front.block.outputsPayload || front.block.acceptsPayload);

    if(canDump && !canMove){
        pushOutput(payload, 1f - (payVector.dst(dest) / (size * tilesize / 2f)));
    }

    if(payVector.within(dest, 0.001f)){
        payVector.clamp(-size * tilesize / 2f, -size * tilesize / 2f, size * tilesize / 2f, size * tilesize / 2f);

        if(canMove){
            if(movePayload(payload)){
                payload = null;
            }
        }else if(canDump){
            dumpPayload();
        }
    }
}
```

Deferred side effects stay represented by explicit flags/results:

- `pushOutput(payload, fraction)`
- `movePayload(payload)`
- `dumpPayload()`
- `front()` world lookup via explicit `front_*` inputs

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1423`.
- [x] Read exact upstream Java `BlockProducer.java`.
- [x] Read exact upstream Java `PayloadBlock.java`.
- [x] Confirmed `PortGame.source_block_producer_build_update_tile_move_out_payload_state` is backed by exact source expressions.
- [x] Added RED status assertion for `N1423`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1423` status to `done` in canonical ledger and shard mirrors.
- [x] Focused GREEN passed for source symbol/ledger registration.
- [x] Focused source helper tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1423` canonical and nested status are `done`.
- [x] Godot TCP proof confirmed no-payload guard returns without update/dest.
- [x] Godot TCP proof confirmed pushOutput fraction path for canDump and not canMove.
- [x] Godot TCP proof confirmed arrived + canMove calls movePayload and clears payload on success.
- [x] Godot TCP proof confirmed arrived + canDump calls dumpPayload.
- [x] Godot TCP proof confirmed generated bridge matches canonical helper.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_block_producer_build_update_tile_move_out_payload_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Status guard:
  - Command: `python -c "import json; from pathlib import Path ..."`
  - Result: `N1422 done`, `N1423 done`, `N1424 done`, `N478 done`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_block_producer_build_update_tile_move_out_payload_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k block_producer_build_update_tile_move_out_payload`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k block_producer_build_update_tile_move_out_payload`
  - Result: `1 passed, 842 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k block_producer_build_update_tile_move_out_payload`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 383.67s (0:06:23)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1423")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP no-payload guard: `update_payload_called=false`, `dest=null`, `payload_after_present=false`.
  - TCP pushOutput path: `dest={"x":8.0,"y":0.0}`, `can_dump=true`, `can_move=false`, `pushed_output_fraction=0.0`, `arrived=false`.
  - TCP movePayload success path: `arrived=true`, `can_move=true`, `move_payload_called=true`, `payload_after_present=false`.
  - TCP dumpPayload path: `arrived=true`, `can_dump=true`, `dump_payload_called=true`, `pushed_output_fraction=1.0`, `payload_after_present=true`.
  - TCP generated bridge: `matches=true`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1073`
- Not done: `0`
- Source-backed remaining: `0`
- Progress: `100.00%`
- Remaining: `0.00%`
- Remaining slice ids: none
- Next gate: full playable integration audit; do not call full migration complete from ledger alone.
