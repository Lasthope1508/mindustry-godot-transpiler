"""Register the Turret activeSoundVolume() + shouldActiveSound() (N2346).

TurretBuild.activeSoundVolume() (Turret.java:822-824,
`public float activeSoundVolume(){` / `return shootWarmup;`
/ `}`) and TurretBuild.shouldActiveSound()
(Turret.java:826-829, `public boolean shouldActiveSound(){`
/ `return shootWarmup > 0.01f && loopSound != Sounds.none;`
/ `}`) are two pure static functions on
SourceTurretBuildState.gd next to the N2343 isShooting
accessor. shootWarmup is the TurretBuild field
(Turret.java:286, `public float shootWarmup, charge,
warmupHold = 0f;`); loopSound is the Turret def field
(Turret.java:128, `public Sound loopSound = Sounds.none;`).
NO audio playback in this slice (playback belongs to the
updateTile tick at :499, which reads both through
`soundLoop.update(x, y, shouldActiveSound(),
activeSoundVolume());` -- soundLoop itself, :298, is NOT
ported here).

RED decisions (resolved at RED): (1) One slice entry for
the two methods, following the N2345 precedent (one ledger
entry per method group, one function per method) --
activeSoundVolume keeps its own function and
shouldActiveSound keeps its own. (2) shootWarmup arrives
as the explicit float shoot_warmup (the updateTile warmup
:502 precedent -- the field is written by updateTile
:512/:514, NOT ported here; this slice only reads it).
(3) `loopSound != Sounds.none` arrives as the explicit
bool has_loop_sound (the minRange has_ammo precedent --
a null/non-none check carried as an explicit bool;
GDScript has no Sound object here). (4) The frame carries
no tracked key for either accessor (the minRange :593
precedent -- the tick frame tracks no warmup/loop-sound
state yet), so all live values arrive as explicit params.
(5) NO driver line: both are read accessors/predicates
the updateTile() tick reads at :499 -- wiring them into
the driver waits for the updateTile caller slice (the
shouldTurn/isShooting precedent). (6) Evidence, not
ownership: the body `return shootWarmup;` already appears
in N2297[3] (warmup(), Turret.java:355, a different
method with the same one-line body) and in remote
N2250[41]/N2253[20] (updateTile) -- none of them owns
activeSoundVolume(). Two new result symbols: one per
function. Slice source: Turret.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_is_shooting import DEFERRED as N2343_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
PROOF = '/root/C07TurretActiveSoundVolumeProof'
VOLUME_OWNER = 'SourceTurretBuildState.source_turret_active_sound_volume_state'
SOUND_OWNER = 'SourceTurretBuildState.source_turret_should_active_sound_state'
TESTS = ['test_c07_turret_active_sound_volume_registration', 'test_all_c07_turret_active_sound_volume_input_evidence_is_exact', 'test_turret_active_sound_volume_state', 'test_reference_graph_and_actual_c07_turret_active_sound_volume']
# The 1 slice source the N2346 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
]
EXACT_EXPRS = [
    'public class Turret extends ReloadTurret{',
    'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
    'public float activeSoundVolume(){',
    'return shootWarmup;',
    'public boolean shouldActiveSound(){',
    'return shootWarmup > 0.01f && loopSound != Sounds.none;',
    'public float shootWarmup, charge, warmupHold = 0f;',
    'public Sound loopSound = Sounds.none;',
]

# DEFERRED is carried from the N2343 register script via import --
# never retyped. All N2343 entries are carried verbatim (the
# N2337 chain, the B/C notes, and N2343's own Windows proof
# debt -- none of them is resolved by this slice). One entry
# is added: N2346's Windows proof debt.
DEFERRED = list(N2343_DEFERRED) + [
    'Turret activeSoundVolume/shouldActiveSound Windows Godot proof -- debt in GOAL.md section 5, same as N2343: the N2346 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    volume_inputs = {
        'frame': a('Dictionary', 'public float activeSoundVolume(){', 'The turret frame (TurretBuild.activeSoundVolume, Turret.java:822): the family-convention first arg every Turret pure function takes; it carries no tracked key for this accessor -- the tick frame tracks no warmup state yet, so the live value arrives as an explicit param (the N2188 precedent).'),
        'shoot_warmup': a('float', 'public float shootWarmup, charge, warmupHold = 0f;', 'The turret warmup level (`shootWarmup`, Turret.java:822-824): the TurretBuild field (`public float shootWarmup, charge, warmupHold = 0f;`, Turret.java:286); arrives as an explicit float param (the updateTile warmup :502 precedent). Written by updateTile :512/:514, not ported here.'),
    }
    volume_outputs = {
        'active_sound_volume': a('float', 'return shootWarmup;', 'The active-sound volume (Turret.java:823, `return shootWarmup;`): the warmup level echoed unchanged -- the loop-sound volume the updateTile tick passes at :499.'),
    }
    sound_inputs = {
        'frame': a('Dictionary', 'public boolean shouldActiveSound(){', 'The turret frame (TurretBuild.shouldActiveSound, Turret.java:826): the family-convention first arg every Turret pure function takes; it carries no tracked key for this predicate -- the tick frame tracks no warmup/loop-sound state yet, so the live values arrive as explicit params (the N2188 precedent).'),
        'shoot_warmup': a('float', 'public float shootWarmup, charge, warmupHold = 0f;', 'The turret warmup level (`shootWarmup`, Turret.java:827): the TurretBuild field (`public float shootWarmup, charge, warmupHold = 0f;`, Turret.java:286); arrives as an explicit float param (the updateTile warmup :502 precedent). The Java `>` against 0.01f is strict: exactly 0.01 does not sound.'),
        'has_loop_sound': a('bool', 'public Sound loopSound = Sounds.none;', 'Whether the turret def has a loop sound (`loopSound != Sounds.none`, Turret.java:827): the Turret def field (`public Sound loopSound = Sounds.none;`, Turret.java:128); arrives as an explicit bool param -- the non-none check is folded into this param (the minRange has_ammo precedent; GDScript has no Sound object here).'),
    }
    sound_outputs = {
        'should_active_sound': a('bool', 'return shootWarmup > 0.01f && loopSound != Sounds.none;', 'Whether the active loop sound should play (Turret.java:827, `return shootWarmup > 0.01f && loopSound != Sounds.none;`): true only when the turret is warm enough AND a loop sound is configured.'),
    }
    return (volume_inputs, volume_outputs, sound_inputs, sound_outputs)


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
    inputs_outputs = [definitions()]
    total = len(EXACT_EXPRS)
    for pair in inputs_outputs:
        for keys in pair:
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
    (volume_inputs, volume_outputs, sound_inputs, sound_outputs) = definitions()

    entries = [
        ('N2346', VOLUME_OWNER, 'source_turret_active_sound_volume_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.activeSoundVolume()', volume_inputs, volume_outputs, True, 'Dictionary'),
        ('N2346', SOUND_OWNER, 'source_turret_should_active_sound_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.shouldActiveSound()', sound_inputs, sound_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed TurretBuild.activeSoundVolume()/shouldActiveSound() state from Turret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed TurretBuild.activeSoundVolume()/shouldActiveSound() state from Turret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: active_sound_volume, should_active_sound.
    by_slice['N2346'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2346', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.activeSoundVolume(); TurretBuild.shouldActiveSound()', godot_owner=VOLUME_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2346'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
