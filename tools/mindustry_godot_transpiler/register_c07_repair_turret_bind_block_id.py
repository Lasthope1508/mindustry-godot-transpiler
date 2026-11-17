"""Register the RepairTurret bind block_id stamp (N2236).

N2235 left the live repair-turret frame without block_id: the
bind (`source_repair_turret_bind_frame_state`) created an empty
frame (`_initial_frame()` returns `{}`) and the driver read
block_id off the sprite meta instead (`source_placed_block_state.
SOURCE_BLOCK_ID_META_KEY`, stamped at placement,
SourcePlacedBlockState.gd:81), so the per-def ambientSoundVolume
(repair-point 0.9f, Blocks.java:6393; repair-turret 1.25f,
Blocks.java:6408) never activated on a live frame -- the loop
reads it from `frame.get("block_id", "")` (N2235). The bind
itself is the stamp point (the N2108 turret-bind precedent
registers the bind function with input sprite/block and result
applied/frame): the bound frame records `frame["block_id"] =
str(block.id)`, the port block identity (catalog id string,
e.g. "repair-point"; the Factory precedent
SourceFactoryBuildState.gd:117 stamps the same value, and
placement stamps it on the sprite meta,
SourcePlacedBlockState.gd:81).

RED decisions (resolved at RED, recorded in the test
docstring): (1) The bind itself is the stamp point: the bound
frame records `frame["block_id"] = str(block.id)`, the port
block identity (catalog id string, e.g. "repair-point"; the
Factory precedent SourceFactoryBuildState.gd:117 stamps the
same value, and placement stamps it on the sprite meta,
SourcePlacedBlockState.gd:81). (2) No new pure function, no
signature change, no driver edit -- the driver already calls
bind (:697) and the stamp rides that call; the already-bound
branch returns the frame stamped at its first bind. (3) The
bind was never registered before (no
source_repair_turret_bind_frame_state_* symbol or schema
existed), so N2236 registers it now with the 4-symbol N2108
shape; the frame result symbol's rule documents the block_id
stamp. (4) Deferred pool: no entry resolved (none names the
bind stamp), +1 Windows-proof debt entry for N2236.
Four symbols: input sprite/block, result applied/frame.

The bind is placement creating the Building (`public final
Building newBuilding(){`, Block.java:1002); the two defs are
`repairPoint = new RepairTurret("repair-point"){{`
(Blocks.java:6386) and `repairTurret = new RepairTurret(
"repair-turret"){{` (Blocks.java:6397), of the block
`public class RepairTurret extends Block{`
(RepairTurret.java:25). The stamp is what lets the N2235
ambient-sound loop resolve the per-def volume from a live
frame through `control.sound.loop(block.ambientSound, self(),
block.ambientSoundVolume * ambientVolume());`
(BuildingComp.java:2271). SSOT expected after GREEN: symbols
+4, Done +1, contracts +1, schema +2, 11528/1685/1616/3023
-> 11532/1686/1617/3025. Slice sources: RepairTurret.java +
Blocks.java + Block.java + BuildingComp.java. No shard change:
RepairTurret.java matches no shard (the N2213-N2235
precedent).
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_repair_turret_ambient_sound_volume import DEFERRED as N2235_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
REPAIR_TURRET = 'core/src/mindustry/world/blocks/units/RepairTurret.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BLOCK = 'core/src/mindustry/world/Block.java'
PROOF = '/root/C07RepairTurretBindBlockIdProof'
BIND_OWNER = 'SourceRepairTurretBuildState.source_repair_turret_bind_frame_state'
TESTS = ['test_c07_repair_turret_bind_block_id_registration', 'test_all_c07_repair_turret_bind_block_id_input_evidence_is_exact', 'test_repair_turret_bind_frame_block_id_state', 'test_reference_graph_and_actual_c07_repair_turret_bind_block_id']
# The 4 slice sources the N2236 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/units/RepairTurret.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/world/Block.java',
]
EXACT_EXPRS = ['public final Building newBuilding(){', 'repairPoint = new RepairTurret("repair-point"){{', 'repairTurret = new RepairTurret("repair-turret"){{', 'public class RepairTurret extends Block{', 'control.sound.loop(block.ambientSound, self(), block.ambientSoundVolume * ambientVolume());', 'ambientSoundVolume = 0.9f;', 'ambientSoundVolume = 1.25f;']

# DEFERRED is carried from the N2235 register script via import --
# never retyped. No entry is resolved here (none names the bind
# stamp); the N2236 Windows-proof debt entry is appended (the
# N2211/N2228 lesson -- never retype the pool).
DEFERRED = N2235_DEFERRED + [
    'RepairTurret bind block_id Windows Godot proof -- debt in GOAL.md section 5, same as N2212-N2235: the N2236 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=REPAIR_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    bind_inputs = {
        'sprite': a('Sprite2D', 'public final Building newBuilding(){', 'The placed sprite the frame is bound on at placement (Block.java:1002, `public final Building newBuilding(){`): placement creates the Building and the port binds that Building state -- the frame -- on the sprite under the repair-turret frame meta key.', source=BLOCK),
        'block': a('Object', 'repairPoint = new RepairTurret("repair-point"){{', 'The catalog block being placed (Blocks.java:6386, `repairPoint = new RepairTurret("repair-point"){{` -- repair-turret, Blocks.java:6397, `repairTurret = new RepairTurret("repair-turret"){{`): its id string is the port block identity the bound frame records.', source=BLOCKS),
    }
    bind_outputs = {
        'applied': a('bool', 'public final Building newBuilding(){', 'Whether the bind applied (Block.java:1002, `public final Building newBuilding(){`): true when a fresh frame is bound for a RepairTurret build, false when the sprite is already bound or the block is not a RepairTurret build.', source=BLOCK),
        'frame': a('Dictionary', 'control.sound.loop(block.ambientSound, self(), block.ambientSoundVolume * ambientVolume());', 'The bound frame (BuildingComp.java:2271, `control.sound.loop(block.ambientSound, self(), block.ambientSoundVolume * ambientVolume());`): the Building state the ambient-sound loop reads block_id from; a fresh bind stamps `frame["block_id"] = str(block.id)` so the per-def volume (repair-point 0.9f, repair-turret 1.25f) resolves on a live frame.', source=BUILDING_COMP),
    }
    return bind_inputs, bind_outputs


def verify():
    """Check every EXACT_EXPRS line and every input/output
    java_expr appears verbatim in its upstream source, without
    touching any SSOT JSON. Exit 0 when all are present."""
    upstream = {}
    for source in SLICE_SOURCES:
        upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
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
            text = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
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
    bind_inputs, bind_outputs = definitions()

    entries = [
        ('N2236', BIND_OWNER, 'source_repair_turret_bind_frame_state', REPAIR_TURRET, 'mindustry.world.blocks.units.RepairTurret.RepairPointBuild', 'Block.newBuilding()', bind_inputs, bind_outputs, True, 'Dictionary'),
    ]
    all_names = []
    for sid, owner, prefix, source, cls, method, inputs, outputs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                symbol = name + '.' + field
                names.append(symbol)
                symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed RepairTurret bind frame state from RepairTurret.java + Blocks.java + Block.java + BuildingComp.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed RepairTurret bind frame state from RepairTurret.java + Blocks.java + Block.java + BuildingComp.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: input sprite, input block,
    # result applied, result frame.
    by_slice['N2236'] = [
        'source_repair_turret_bind_frame_state_input.sprite',
        'source_repair_turret_bind_frame_state_input.block',
        'source_repair_turret_bind_frame_state_result.applied',
        'source_repair_turret_bind_frame_state_result.frame',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2236', dict(status='done', java_source=REPAIR_TURRET, java_class='mindustry.world.blocks.units.RepairTurret.RepairPointBuild', java_method='Block.newBuilding()', godot_owner=BIND_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2236'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
