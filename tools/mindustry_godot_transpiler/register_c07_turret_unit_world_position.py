"""Register the Turret unit world position (N2274).

TurretBuild.updateTile (Turret.java:490-615) syncs its block
unit every tick: `unit.tile(this);` (Turret.java:529) -- and
tile() positions the unit in world coordinates: `set(tile);`
(BlockUnitComp.java:24) -> `set(pos.getX(), pos.getY());`
(PosComp.java:24) -> Tile.getX()/getY() are drawx()/drawy()
(Tile.java:727-734), drawx() is `block().offset + worldx()`
(:175-177), worldx() is `x * tilesize` (:166-168), and
Block.offset is `offset = ((size + 1) % 2) * tilesize / 2f;`
(Block.java:761) -- 0 for odd sizes, tilesize/2 for even
sizes. N2260 stamped the cell (`unit_tile`); the frame still
had no world position, so controlled()/unit.controller()
reads that need world coordinates had nothing live. This
slice adds the one pure function on the shared TurretBuild
driver file plus one driver tick in the duo branch AFTER the
N2260 unit sync tick and BEFORE the N2258 recoilOffset tick
(Java order :529-531 sync, :532 offset).

GREEN decisions (pinned by this slice): (1) One pure function
on SourceTurretBuildState.gd,
source_turret_unit_world_position_state(cell, block_size,
tilesize), returning `{"unit_world_x": .., "unit_world_y": ..,
"unit_tile": ..}` -- unit_world_x/y are the Tile drawx/drawy
values (the port already has them as
SourceBlockGeometry.tile_drawx_state / tile_drawy_state);
block_offset is fmod(block_size + 1.0, 2.0) * tilesize / 2.0
(Block.java:761); unit_tile is the cell passed in (the link
is re-asserted every tick, same as N2260). Plus one driver
tick in the duo branch (right after the N2260 unit sync tick,
before the N2258 recoilOffset tick) that reads the cell,
calls the pure function with duo size 1.0 (Block.java:215
default, never overridden) and tilesize 8.0 (Vars.tilesize),
then stamps all three keys back on the frame -- the tick runs
BEFORE the aim call, so aim reads a live unit mirror (Java
:529-531 runs before :601/:609). The x/y stamp defaults are
the duo live values for the cell (offset 0, tilesize 8, so
cell * 8). (2) `block_size = 1.0` / `tilesize = 8.0` are NOT
in exact_exprs (size lives in Block.java, the tilesize in
Vars) -- the duo values are pinned by a comment in the .gd
plus an assert on the .gd text in the test, same rule as
N2260's `1.0, 8.0` and N2257's `recoils = 2;`. (3) The
maxHealth/health re-sync of tile() still waits for its own
slice: the frame carries no live building-health key yet,
and there is no damage model for the turret building. (4)
No legacy `source_turret_unit_world_position_result` schema
exists, so the contract validator falls through to the new
source_turret_unit_world_position_state_result schema and no
alias is needed. SSOT expected after GREEN:
symbols +3, Done +1, contracts +1, schema +2,
11647/1723/1657/3105 -> 11650/1724/1658/3107; defense
shard slices 200 -> 201, contracts 199 -> 200.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_charge_effect import DEFERRED as N2273_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
BLOCK_UNIT = 'core/src/mindustry/entities/comp/BlockUnitComp.java'
POS_COMP = 'core/src/mindustry/entities/comp/PosComp.java'
TILE = 'core/src/mindustry/world/Tile.java'
BLOCK = 'core/src/mindustry/world/Block.java'
PROOF = '/root/C07TurretUnitWorldPositionProof'
UNIT_WORLD_POSITION_OWNER = 'SourceTurretBuildState.source_turret_unit_world_position_state'
TESTS = ['test_c07_turret_unit_world_position_registration', 'test_all_c07_turret_unit_world_position_input_evidence_is_exact', 'test_turret_unit_world_position_state', 'test_reference_graph_and_actual_c07_turret_unit_world_position']
# The slice sources the N2274 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/entities/comp/BlockUnitComp.java',
    'core/src/mindustry/entities/comp/PosComp.java',
    'core/src/mindustry/world/Tile.java',
    'core/src/mindustry/world/Block.java',
]
EXACT_EXPRS = ['unit.tile(this);', 'set(tile);', 'set(pos.getX(), pos.getY());', 'return drawx();', 'return drawy();', 'return block().offset + worldx();', 'return block().offset + worldy();', 'return x * tilesize;', 'return y * tilesize;', 'offset = ((size + 1) % 2) * tilesize / 2f;']

# DEFERRED is carried from the N2273 register script via import --
# never retyped. The unit world position is done by this slice, so
# the N2260/N2273 "unit world position from set(tile)" entry is
# superseded (the world position tick is N2274 itself); the
# maxHealth/health re-sync, the cross-tick queuedBullets counter,
# effects/sound, findTarget / the other ItemTurret defs still wait.
DEFERRED = list(N2273_DEFERRED) + [
    'Turret unit world position from set(tile) (BlockUnitComp.tile() `set(tile);` -> PosComp.set `set(pos.getX(), pos.getY());` -> Tile drawx/drawy) -- DONE by this slice (N2274); the N2260/N2273 deferred entry above saying it waits for a world-position representation decision is superseded. The frame now stamps unit_world_x / unit_world_y (Tile.getX()/getY() verbatim: block offset + cell * tilesize) alongside the N2260 unit_tile, live on the duo driver right after the unit sync tick.',
    'Turret unit world position for defs other than duo -- the pure function takes cell / block_size / tilesize as params; only duo is wired in the driver (size 1.0, tilesize 8.0).',
    'Unit maxHealth/health re-sync from tile() -- waits for a live building-health source: the frame carries no live health key yet, and there is no damage model for the turret building.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    unit_world_position_inputs = {
        'cell': a('Vector2i', 'unit.tile(this);', 'The building cell whose world position the unit takes (Turret.java:529; the driver passes cell, the origin cell of the placed building -- tile is `this` at this call site, so the world position is always the building tile itself).'),
        'block_size': a('float', 'offset = ((size + 1) % 2) * tilesize / 2f;', 'The block size feeding the draw offset (Block.java:761; duo size is 1, the Block.java:215 default, never overridden, so the driver passes 1.0 and the offset is 0).', source=BLOCK),
        'tilesize': a('float', 'return x * tilesize;', 'The world tilesize feeding the world position (Tile.java:167; Vars.tilesize is 8, so the driver passes 8.0).', source=TILE),
    }
    unit_world_position_outputs = {
        'unit_world_x': a('float', 'return drawx();', 'The unit world x after the tick (Tile.java:728 -- getX() is drawx(), block offset + cell x * tilesize; 224.0 live for duo at cell (28, 21)).', source=TILE),
        'unit_world_y': a('float', 'return drawy();', 'The unit world y after the tick (Tile.java:733 -- getY() is drawy(), block offset + cell y * tilesize; 168.0 live for duo at cell (28, 21)).', source=TILE),
        'unit_tile': a('Vector2i', 'this.tile = tile;', 'The unit tile after the tick (BlockUnitComp.java:18 -- tile() re-asserts the link every tick; the driver stamps it on frame["unit_tile"], same key as N2260).', source=BLOCK_UNIT),
    }
    return unit_world_position_inputs, unit_world_position_outputs


def verify():
    """Check every EXACT_EXPRS line and every input/output
    java_expr appears verbatim in its upstream source, without
    touching any SSOT JSON. Exit 0 when all are present."""
    upstream = {}
    for source in SLICE_SOURCES:
        upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
        upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
    missing = []
    for expr in EXACT_EXPRS:
        if not any(expr in text for text in upstream.values()):
            missing.append(expr)
    inputs_outputs = definitions()
    total = len(EXACT_EXPRS)
    for keys in inputs_outputs:
        total += len(keys)
        for field, meta in keys.items():
            source = meta['java_source']
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            text = (upstream_root / source).read_text(encoding='utf-8')
            if meta['java_expr'] not in text:
                missing.append('%s: %s' % (field, meta['java_expr']))
    if missing:
        for expr in missing:
            print('MISSING: %s' % expr)
        print('%d/%d exprs present' % (total - len(missing), total))
        return 1
    print('%d/%d exprs present' % (total, total))
    return 0


def main():
    symbols = {}
    unit_world_position_inputs, unit_world_position_outputs = definitions()

    entries = [
        ('N2274', UNIT_WORLD_POSITION_OWNER, 'source_turret_unit_world_position_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.updateTile()', unit_world_position_inputs, unit_world_position_outputs, True, 'Dictionary'),
    ]
    all_names = []
    for sid, owner, prefix, source, cls, method, inputs, outputs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                if suffix == 'result':
                    symbol = name + '.' + field
                    names.append(symbol)
                    symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret unit world position from BlockUnitComp.tile() / PosComp.set / Tile drawx/drawy.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret unit world position from BlockUnitComp.tile() / PosComp.set / Tile drawx/drawy.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: unit_world_x, unit_world_y,
    # unit_tile.
    by_slice['N2274'] = [
        'source_turret_unit_world_position_state_result.unit_world_x',
        'source_turret_unit_world_position_state_result.unit_world_y',
        'source_turret_unit_world_position_state_result.unit_tile',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2274', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.updateTile()', godot_owner=UNIT_WORLD_POSITION_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2274'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

    source_symbols.upsert_source_symbols(GODOT, symbols)
    source_symbols.write_source_symbol_audit_report(GODOT)

    manifest = json.loads((GODOT / 'src/generated/source_ssot_modules.json').read_text(encoding='utf-8'))
    modules = manifest['modules']
    new_owners = {definition[1] for definition in entries}
    for name, module in modules.items():
        if module.get('canonical_module') == 'api_contracts':
            selected = source_ssot.build_extension_shard(GODOT, name)[module['root_key']]
            if new_owners.intersection(selected):
                optional = module.setdefault('optional_mirror_fields', [])
                if 'return_type' not in optional:
                    optional.append('return_type')
    source_ssot.write_registered_json(GODOT, 'module_manifest', manifest)
    for canonical in ['slice_ledger', 'api_contracts', 'state_schema', 'registry', 'audit_report', 'module_manifest']:
        for name, module in modules.items():
            if module.get('canonical_module') == canonical:
                source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))


if __name__ == '__main__':
    if '--verify' in sys.argv:
        sys.exit(verify())
    main()
