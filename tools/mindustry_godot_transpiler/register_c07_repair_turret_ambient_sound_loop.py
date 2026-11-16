"""Register the RepairTurret ambient-sound live-loop gate rows (N2222).

N2221 captured when the turret plays its ambient sound
(shouldAmbientSound() = target != null && efficiency > 0f) and
what status it reports -- but nothing in the port captured the
live-loop call that actually loops the sound each tick:
BuildingComp.update() runs `if(!headless && block.ambientSound
!= Sounds.none && shouldAmbientSound()){` then
`control.sound.loop(block.ambientSound, self(),
block.ambientSoundVolume * ambientVolume());`
(BuildingComp.java:2270-2271, inside `public void update(){`,
BuildingComp.java:2262). The sound is `Sounds.beamHeal` and
its volume scale is `1f` (RepairTurret.java:66-67, `ambientSound
= Sounds.beamHeal;` / `ambientSoundVolume = 1f;`, set in the
RepairTurret constructor, so both defs share them), the Block
defaults they override are `public Sound ambientSound =
Sounds.none;` and `public float ambientSoundVolume = 0.05f;`
(Block.java:351, :353), and ambientVolume() is the folded
efficiency (BuildingComp.java:2015-2017, `public float
ambientVolume(){` / `return efficiency;`).

RED decisions (resolved at RED): (1) One pure function on the
same family file N2174 / N2188 / N2209 / N2212-N2215 / N2217 /
N2219-N2221 built, returning the loop decision (bool), the
sound (String) and the loop volume (float). (2) The gate reuses
the N2221 pure function
source_repair_turret_should_ambient_sound_state for the
shouldAmbientSound() leg (target + efficiency); headless
arrives as an explicit bool param (the SourceBlockGeometry
precedent -- the port has no game-level headless flag yet).
(3) The sound and volume are per-class consts
SOURCE_REPAIR_TURRET_AMBIENT_SOUND ("beamHeal") and
SOURCE_REPAIR_TURRET_AMBIENT_SOUND_VOLUME (1.0); volume is
ambientSoundVolume * ambientVolume() = 1.0 * efficiency, with
efficiency read from the frame (absent folds to 1.0, the N2174
missing-stamp precedent). (4) There is NO driver tick line:
the loop call is a sound side effect (control.sound.loop)
with no sink in the port yet, and nothing consumes an
ambient-loop stamp -- the driver tick line + sound-loop sink
wait for a game-level headless-source slice. Three new result
symbols: loop should_loop, sound, volume. Slice sources:
RepairTurret.java + BuildingComp.java (the update() gate +
ambientVolume()) + Block.java (the ambient defaults).
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_repair_turret_should_ambient_sound_status import DEFERRED as N2221_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
REPAIR_TURRET = 'core/src/mindustry/world/blocks/units/RepairTurret.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BLOCK = 'core/src/mindustry/world/Block.java'
PROOF = '/root/C07RepairTurretAmbientSoundLoopProof'
LOOP_OWNER = 'SourceRepairTurretBuildState.source_repair_turret_ambient_sound_loop_state'
TESTS = ['test_c07_repair_turret_ambient_sound_loop_registration', 'test_all_c07_repair_turret_ambient_sound_loop_input_evidence_is_exact', 'test_repair_turret_ambient_sound_loop_state', 'test_reference_graph_and_actual_c07_repair_turret_ambient_sound_loop']
# The 3 slice sources the N2222 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/units/RepairTurret.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/world/Block.java',
]
EXACT_EXPRS = ['if(!headless && block.ambientSound != Sounds.none && shouldAmbientSound()){', 'control.sound.loop(block.ambientSound, self(), block.ambientSoundVolume * ambientVolume());', 'ambientSound = Sounds.beamHeal;', 'ambientSoundVolume = 1f;', 'public float ambientVolume(){', 'return efficiency;', 'public Sound ambientSound = Sounds.none;', 'public float ambientSoundVolume = 0.05f;', 'return target != null && efficiency > 0f;']

# DEFERRED is carried from the N2221 register script via import --
# never retyped. The N2221 script's DEFERRED is a computed
# expression (list(...) + [...] over the N2220 import), NOT a plain
# list literal, so the N2218-style ast.literal_eval carry cannot
# recover it (ValueError: malformed node); the import recovers the
# runtime value verbatim. NOTE for the next slice: N2222's
# DEFERRED is likewise a computed list(...) + [...] expression, so
# carry it forward by import too, not by ast.literal_eval.
# NOTE: the N2221 pool entry claiming the RepairTurret
# ambient-sound live-loop gate "waits for its own slice" is
# SUPERSEDED in part by this slice -- the pure gate decision
# (should_loop / sound / volume) now exists; only the driver
# tick line + sound-loop sink still wait. The pool is cumulative
# history, so the old entry stays; the new entries below pin what
# is still deferred.
DEFERRED = list(N2221_DEFERRED) + [
    'RepairTurret ambient-sound live-loop driver call (the BuildingComp.update() loop gate calling shouldAmbientSound() each tick, BuildingComp.java:2270-2272 -- the pure gate decision exists (N2222), the driver tick line + sound-loop sink wait for a game-level headless-source slice).',
    'RepairTurret ambient-sound-loop Windows Godot proof -- debt in GOAL.md section 5, same as N2212-N2221: the N2222 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=REPAIR_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    loop_inputs = {
        'frame': a('Dictionary', 'if(!headless && block.ambientSound != Sounds.none && shouldAmbientSound()){', 'The repair-turret frame carrying the live target observation as `has_target` (stamped every tick by the N2212 acquire; absent means "no observation yet", so it reads false) and the folded `efficiency` (stamped every tick by the driver via apply_update_consumption_state; absent folds to 1.0, the N2174 missing-stamp precedent).', source=BUILDING_COMP),
        'headless': a('bool', 'if(!headless && block.ambientSound != Sounds.none && shouldAmbientSound()){', 'Whether the game runs headless (Vars.headless, BuildingComp.java:2270, `if(!headless && block.ambientSound != Sounds.none && shouldAmbientSound()){`): a headless game never loops the ambient sound; passed explicitly because the port has no game-level headless flag yet (the SourceBlockGeometry precedent).', source=BUILDING_COMP),
    }
    loop_outputs = {
        'should_loop': a('bool', 'if(!headless && block.ambientSound != Sounds.none && shouldAmbientSound()){', 'The live-loop gate (BuildingComp.java:2270, `if(!headless && block.ambientSound != Sounds.none && shouldAmbientSound()){`): true only in a headed game, with the block ambient sound set (beamHeal, not Sounds.none) and the N2221 shouldAmbientSound() gate true.', source=BUILDING_COMP),
        'sound': a('String', 'ambientSound = Sounds.beamHeal;', 'The ambient sound to loop (RepairTurret.java:66, `ambientSound = Sounds.beamHeal;`, set in the RepairTurret constructor, so both defs share it; the Block default it overrides is Sounds.none, Block.java:351).'),
        'volume': a('float', 'control.sound.loop(block.ambientSound, self(), block.ambientSoundVolume * ambientVolume());', 'The loop volume (BuildingComp.java:2271, `control.sound.loop(block.ambientSound, self(), block.ambientSoundVolume * ambientVolume());`): ambientSoundVolume (1f, RepairTurret.java:67) times ambientVolume() (the folded efficiency, BuildingComp.java:2015-2017).', source=BUILDING_COMP),
    }
    return loop_inputs, loop_outputs


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
    loop_inputs, loop_outputs = definitions()

    entries = [
        ('N2222', LOOP_OWNER, 'source_repair_turret_ambient_sound_loop_state', REPAIR_TURRET, 'mindustry.world.blocks.units.RepairTurret.RepairPointBuild', 'BuildingComp.update()', loop_inputs, loop_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed RepairTurret ambient-sound live-loop gate state from RepairTurret.java + BuildingComp.java + Block.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed RepairTurret ambient-sound live-loop gate state from RepairTurret.java + BuildingComp.java + Block.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: loop should_loop, sound,
    # volume.
    by_slice['N2222'] = [
        'source_repair_turret_ambient_sound_loop_state_result.should_loop',
        'source_repair_turret_ambient_sound_loop_state_result.sound',
        'source_repair_turret_ambient_sound_loop_state_result.volume',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2222', dict(status='done', java_source=REPAIR_TURRET, java_class='mindustry.world.blocks.units.RepairTurret.RepairPointBuild', java_method='BuildingComp.update()', godot_owner=LOOP_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2222'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
