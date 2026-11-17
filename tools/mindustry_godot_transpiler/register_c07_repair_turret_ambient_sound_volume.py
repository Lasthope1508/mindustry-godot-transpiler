"""Register the RepairTurret per-def ambientSoundVolume rows (N2235).

N2222 pinned the 1.0 class default (RepairTurret.java:67,
`ambientSoundVolume = 1f;`) for both defs, but Blocks.java
overrides it per def: repair-point 0.9f (:6393,
`ambientSoundVolume = 0.9f;`) and repair-turret 1.25f (:6408,
`ambientSoundVolume = 1.25f;`), so the ambient-sound loop
(BuildingComp.java:2270-2271, `if(!headless &&
block.ambientSound != Sounds.none &&
shouldAmbientSound()){` / `control.sound.loop(block.
ambientSound, self(), block.ambientSoundVolume *
ambientVolume());`) used 1.0 for both defs -- wrong against
the catalog. (The N2234 handoff and its DEFERRED entry cite
the repair-point line as :6394; the correct line is :6393,
verified with grep -n on disk.) The class default is
`ambientSoundVolume = 1f;` (RepairTurret.java:67, set in the
RepairTurret constructor alongside `ambientSound =
Sounds.beamHeal;`, RepairTurret.java:66); the Block defaults
they override are `public Sound ambientSound = Sounds.none;`
and `public float ambientSoundVolume = 0.05f;` (Block.
java:351, :353); ambientVolume() is the folded efficiency
(BuildingComp.java:2015-2017, `public float ambientVolume(){`
/ `return efficiency;`). The two defs are `repairPoint = new
RepairTurret("repair-point"){{` (Blocks.java:6386) and
`repairTurret = new RepairTurret("repair-turret"){{`
(Blocks.java:6397), of the block `public class RepairTurret
extends Block{` (RepairTurret.java:25).

RED decisions (resolved at RED): (1) One pure function on the
same family file, taking the block id explicitly (per-def
static state, not a live frame key -- the N2212 / N2220
precedent) and returning the per-def volume, with the 1.0
class default as the fallback for an unknown def. (2) The
loop keeps its two-arg signature -- the N2222 test pins it
verbatim -- and resolves the volume through the new function
from `frame.get("block_id", "")` (the AdjacentFactory /
Factory / UnitFactory precedent for reading block_id off
the frame); a frame with no block_id falls back to the 1.0
class default, so the N2222 tests stay green unchanged.
(3) There is NO driver tick line: the volume is a catalog
read and the loop itself has no driver call yet (the N2222
sound side effect with no sink); live repair-turret frames
do not stamp block_id yet, so the per-def volume activates
when the caller supplies the frame's block_id -- stamping
it at bind is its own later slice. (4) The N2234 DEFERRED
entry "RepairTurret per-def ambientSoundVolume correction"
is RESOLVED here (filtered by substring, so the :6394 line
typo in that entry cannot break the filter) and replaced by
the N2235 Windows-proof debt entry; the pool stays 278.
One new result symbol: ambient_sound_volume. SSOT expected
after GREEN: symbols +1, Done +1, contracts +1, schema +2,
11527/1684/1615/3021 -> 11528/1685/1616/3023. Slice sources:
RepairTurret.java + Blocks.java + BuildingComp.java +
Block.java. No shard change: RepairTurret.java matches no
shard (the N2213-N2234 precedent).
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_repair_turret_sense_object import DEFERRED as N2234_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
REPAIR_TURRET = 'core/src/mindustry/world/blocks/units/RepairTurret.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BLOCK = 'core/src/mindustry/world/Block.java'
PROOF = '/root/C07RepairTurretAmbientSoundVolumeProof'
VOLUME_OWNER = 'SourceRepairTurretBuildState.source_repair_turret_ambient_sound_volume_state'
TESTS = ['test_c07_repair_turret_ambient_sound_volume_registration', 'test_all_c07_repair_turret_ambient_sound_volume_input_evidence_is_exact', 'test_repair_turret_ambient_sound_volume_state', 'test_reference_graph_and_actual_c07_repair_turret_ambient_sound_volume']
# The 4 slice sources the N2235 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/units/RepairTurret.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/world/Block.java',
]
EXACT_EXPRS = ['ambientSoundVolume = 0.9f;', 'ambientSoundVolume = 1.25f;', 'ambientSoundVolume = 1f;', 'control.sound.loop(block.ambientSound, self(), block.ambientSoundVolume * ambientVolume());', 'if(!headless && block.ambientSound != Sounds.none && shouldAmbientSound()){', 'repairPoint = new RepairTurret("repair-point"){{', 'repairTurret = new RepairTurret("repair-turret"){{', 'public class RepairTurret extends Block{', 'public float ambientSoundVolume = 0.05f;', 'public float ambientVolume(){', 'return efficiency;']

# DEFERRED is carried from the N2234 register script via import --
# never retyped. The N2234 entry "RepairTurret per-def
# ambientSoundVolume correction" is RESOLVED by this slice and
# filtered out by substring (its :6394 line cite is a typo for
# :6393, so an exact-string filter would be brittle); every other
# entry is carried verbatim (the N2211/N2228 lesson -- never
# retype the pool).
DEFERRED = [e for e in N2234_DEFERRED if 'ambientSoundVolume correction' not in e] + [
    'RepairTurret per-def ambientSoundVolume Windows Godot proof -- debt in GOAL.md section 5, same as N2212-N2234: the N2235 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=REPAIR_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    volume_inputs = {
        'block_id': a('String', 'repairPoint = new RepairTurret("repair-point"){{', 'The block id (Blocks.java:6386, `repairPoint = new RepairTurret("repair-point"){{` -- repair-turret, Blocks.java:6397, `repairTurret = new RepairTurret("repair-turret"){{`): the per-def identity whose catalog ambientSoundVolume override the resolver returns, passed explicitly because it is per-def static state, not a live frame key (the N2212 / N2220 per-def-param precedent).', source=BLOCKS),
    }
    volume_outputs = {
        'ambient_sound_volume': a('float', 'control.sound.loop(block.ambientSound, self(), block.ambientSoundVolume * ambientVolume());', 'The per-def ambient-sound volume scale (BuildingComp.java:2271, `control.sound.loop(block.ambientSound, self(), block.ambientSoundVolume * ambientVolume());`): repair-point 0.9f (Blocks.java:6393, `ambientSoundVolume = 0.9f;`), repair-turret 1.25f (Blocks.java:6408, `ambientSoundVolume = 1.25f;`), any other def the 1f class default (RepairTurret.java:67, `ambientSoundVolume = 1f;`).', source=BUILDING_COMP),
    }
    return volume_inputs, volume_outputs


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
    volume_inputs, volume_outputs = definitions()

    entries = [
        ('N2235', VOLUME_OWNER, 'source_repair_turret_ambient_sound_volume_state', REPAIR_TURRET, 'mindustry.world.blocks.units.RepairTurret.RepairPointBuild', 'BuildingComp.update()', volume_inputs, volume_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed RepairTurret per-def ambientSoundVolume state from RepairTurret.java + Blocks.java + BuildingComp.java + Block.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed RepairTurret per-def ambientSoundVolume state from RepairTurret.java + Blocks.java + BuildingComp.java + Block.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: ambient_sound_volume.
    by_slice['N2235'] = [
        'source_repair_turret_ambient_sound_volume_state_result.ambient_sound_volume',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2235', dict(status='done', java_source=REPAIR_TURRET, java_class='mindustry.world.blocks.units.RepairTurret.RepairPointBuild', java_method='BuildingComp.update()', godot_owner=VOLUME_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2235'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
