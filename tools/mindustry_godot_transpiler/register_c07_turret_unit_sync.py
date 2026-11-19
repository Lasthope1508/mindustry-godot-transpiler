"""Register the Turret unit sync (N2260).

TurretBuild.updateTile (Turret.java:490-615) syncs its block
unit every tick, after the charge advance and before the
recoilOffset draw: `unit.tile(this);`
`unit.rotation(rotation);`
`unit.team(team);`
(Turret.java:529-531). The unit is the per-building
BlockUnitc,
`public BlockUnitc unit = (BlockUnitc)UnitTypes.block.create(team);`
(:291). tile() re-asserts the tile link and re-derives the
unit stats from the building
(`this.tile = tile;` / `hitSize(tile.block.size * tilesize * 0.7f);`,
BlockUnitComp.java:18/:23); rotation() is the plain
RotComp field assignment (RotComp.java,
`@SyncField(false) @SyncLocal float rotation;`); team()
re-syncs the unit team and only calls back into the
building when the teams drifted
(`if(tile != null && this.team != team){` /
`tile.changeTeam(team);`, BlockUnitComp.java:79/:83).
The new C07 duo driver (N2250-N2259) never stamped the
unit mirror -- the controlled()/unit.controller() reads
had no live unit frame keys. This slice adds the one
pure function on the shared TurretBuild driver file
(updateTile() is TurretBuild's method, common to every
turret, not ItemTurret-only) plus one driver tick in the
duo branch AFTER the N2259 charge tick and BEFORE the
N2258 recoilOffset tick (Java order :527 charge, :529-531
unit sync, :532 offset).

GREEN decisions (pinned by this slice): (1) One pure function
on SourceTurretBuildState.gd,
source_turret_unit_sync_state(unit_tile, rotation,
unit_team, team_id, tile_team, block_size, tilesize),
returning `{"unit_tile": .., "unit_rotation": ..,
"unit_team": .., "unit_hit_size": ..,
"tile_change_team_called": ..}` -- unit_tile is the tile
passed in (the link is re-asserted every tick; tile is
`this` at this call site, so the null guard is always
true); unit_rotation is the building rotation (a plain
field assignment, no formula); unit_team is always the
building team_id (team() sets this.team = team when the
outer guard passes and keeps it when already synced);
unit_hit_size is block_unit_tile_hit_size(block_size,
tilesize) = block_size * tilesize * 0.7 (already ported
in SourceBlockGeometry.gd:863, scale 0.7 in
SourceBlockDefaults.gd:26); tile_change_team_called is
(unit_team != team_id) and (tile_team != team_id) -- the
outer guard of team() plus the inner tile-team guard.
Plus one driver tick in the duo branch (right after the
N2259 charge tick, before the N2258 recoilOffset tick)
that reads the cell, the frame rotation (default 90.0,
the aim stamp default) and the previous unit team
(default team_id -- the unit is created on the building
team), calls the pure function with duo size 1.0
(Block.java:215 default, never overridden) and tilesize
8.0 (Vars.tilesize), then stamps all five keys back on
the frame -- the tick runs BEFORE the aim call, so aim
reads a live unit mirror (Java :529-531 runs before
:601/:609). (2) `block_size = 1.0` / `tilesize = 8.0`
are NOT in exact_exprs (size lives in Block.java, the
tilesize in Vars) -- the duo values are pinned by a
comment in the .gd plus an assert on the .gd text in
the test, same rule as N2257's `recoils = 2;` and
N2258's `recoil = 0.5f;`. (3) The maxHealth/health
re-sync of tile() and the set(tile) world position
still wait for their own slices: the frame carries no
live building-health key yet, and the frame works in
cells while set() positions the unit in world
coordinates. (4) No legacy `source_turret_unit_sync_result`
schema exists (unlike N2258's recoilOffset), so the
contract validator falls through to the new
source_turret_unit_sync_state_result schema and no alias
is needed. SSOT expected after GREEN:
symbols +5, Done +1, contracts +1, schema +5,
11613/1709/1643/3077 -> 11618/1710/1644/3082; defense
shard slices 188 -> 189, contracts 187 -> 188.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_charge import DEFERRED as N2259_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
BLOCK_UNIT = 'core/src/mindustry/entities/comp/BlockUnitComp.java'
PROOF = '/root/C07TurretUnitSyncProof'
UNIT_SYNC_OWNER = 'SourceTurretBuildState.source_turret_unit_sync_state'
TESTS = ['test_c07_turret_unit_sync_registration', 'test_all_c07_turret_unit_sync_input_evidence_is_exact', 'test_turret_unit_sync_state', 'test_reference_graph_and_actual_c07_turret_unit_sync']
# The slice source the N2260 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/entities/comp/BlockUnitComp.java',
]
EXACT_EXPRS = ['unit.tile(this);', 'unit.rotation(rotation);', 'unit.team(team);', 'public BlockUnitc unit = (BlockUnitc)UnitTypes.block.create(team);']

# DEFERRED is carried from the N2259 register script via import --
# never retyped. The unit sync is done by this slice, so the
# N2259 "unit sync ... waits for its own slice" entry is
# superseded (the unit sync tick is N2260 itself); the
# maxHealth/health re-sync, the set(tile) world position, the
# cross-tick queuedBullets counter, effects/sound, findTarget /
# the other ItemTurret defs still wait.
DEFERRED = list(N2259_DEFERRED) + [
    'Turret unit sync Windows Godot proof -- debt in GOAL.md section 5, same as N2240-N2259: the N2260 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Turret unit sync (unit.tile/rotation/team, Turret.java:529-531) -- DONE by this slice (N2260); the N2259 deferred entry above saying it waits for its own slice is superseded.',
    'Turret unit sync for defs other than duo -- the pure function takes unit_tile / rotation / unit_team / team_id / tile_team / block_size / tilesize as params; only duo is wired in the driver (size 1.0, tilesize 8.0).',
    'Unit maxHealth/health re-sync from tile() -- waits for a live building-health source: the frame carries no live health key yet, and there is no damage model for the turret building.',
    'Unit world position from set(tile) -- waits for a world-position representation decision: the frame works in cells while set() positions the unit in world coordinates.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    unit_sync_inputs = {
        'unit_tile': a('Vector2i', 'unit.tile(this);', 'The building cell re-asserted as the unit tile every tick (Turret.java:529; the driver passes cell, the origin cell of the placed building -- tile is `this` at this call site, so the link is always the building itself).'),
        'rotation': a('float', 'unit.rotation(rotation);', 'The building rotation the unit rotation follows (Turret.java:530, the plain RotComp field assignment; the driver reads frame["rotation"], default 90.0, the aim stamp default).'),
        'unit_team': a('int', 'unit.team(team);', 'The unit team before this tick (Turret.java:531; the driver reads frame["unit_team"], default team_id -- the unit is created on the building team, `public BlockUnitc unit = (BlockUnitc)UnitTypes.block.create(team);`, :291).'),
        'team_id': a('int', 'public BlockUnitc unit = (BlockUnitc)UnitTypes.block.create(team);', 'The building team (Turret.java:291, the unit is created on the building team; the driver passes the frame team_id).'),
        'tile_team': a('int', 'if(tile.team != team){', 'The tile team guarding the changeTeam callback (BlockUnitComp.java:82; the driver passes team_id -- tile is `this` at this call site, so the tile team is the building team).', source=BLOCK_UNIT),
        'block_size': a('float', 'hitSize(tile.block.size * tilesize * 0.7f);', 'The block size feeding the unit hit size (BlockUnitComp.java:23; duo size is 1, the Block.java:215 default, never overridden, so the driver passes 1.0).', source=BLOCK_UNIT),
        'tilesize': a('float', 'hitSize(tile.block.size * tilesize * 0.7f);', 'The world tilesize feeding the unit hit size (BlockUnitComp.java:23; Vars.tilesize is 8, so the driver passes 8.0).', source=BLOCK_UNIT),
    }
    unit_sync_outputs = {
        'unit_tile': a('Vector2i', 'this.tile = tile;', 'The unit tile after the tick (BlockUnitComp.java:18 -- tile() re-asserts the link every tick; the driver stamps it on frame["unit_tile"]).', source=BLOCK_UNIT),
        'unit_rotation': a('float', 'unit.rotation(rotation);', 'The unit rotation after the tick (Turret.java:530 -- the plain RotComp field assignment; the driver stamps it on frame["unit_rotation"]).'),
        'unit_team': a('int', 'this.team = team;', 'The unit team after the tick (BlockUnitComp.java:80 -- team() sets this.team = team when the guard passes; the post-sync team is always the building team).', source=BLOCK_UNIT),
        'unit_hit_size': a('float', 'hitSize(tile.block.size * tilesize * 0.7f);', 'The unit hit size after the tick (BlockUnitComp.java:23 -- block_size * tilesize * 0.7; 5.6 live for duo).', source=BLOCK_UNIT),
        'tile_change_team_called': a('bool', 'tile.changeTeam(team);', 'Whether team() called back into the building (BlockUnitComp.java:83 -- only when the unit team drifted AND the tile team drifted; false live for duo).', source=BLOCK_UNIT),
    }
    return unit_sync_inputs, unit_sync_outputs


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
    unit_sync_inputs, unit_sync_outputs = definitions()

    entries = [
        ('N2260', UNIT_SYNC_OWNER, 'source_turret_unit_sync_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.updateTile()', unit_sync_inputs, unit_sync_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret unit sync from Turret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret unit sync from Turret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: unit_tile, unit_rotation,
    # unit_team, unit_hit_size, tile_change_team_called.
    by_slice['N2260'] = [
        'source_turret_unit_sync_state_result.unit_tile',
        'source_turret_unit_sync_state_result.unit_rotation',
        'source_turret_unit_sync_state_result.unit_team',
        'source_turret_unit_sync_state_result.unit_hit_size',
        'source_turret_unit_sync_state_result.tile_change_team_called',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2260', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.updateTile()', godot_owner=UNIT_SYNC_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2260'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
