"""Register the LaserTurret activeSoundVolume() + shouldActiveSound() (N2418).

LaserTurretBuild.activeSoundVolume()
(LaserTurret.java:147-149, `@Override` /
`public float activeSoundVolume(){` /
`return 1f;`) and LaserTurretBuild.shouldActiveSound()
(LaserTurret.java:152-154, `@Override` /
`public boolean shouldActiveSound(){` /
`return bullets.any();`) are one pure function on the
SourceLaserTurretBuildPortBridge.gd, following the
merged-method precedent (N2346 Turret
activeSoundVolume/shouldActiveSound, N2389
ContinuousTurret estimateDps/hasAmmo/shouldActiveSound).
The volume is a constant 1f and the sound gate is
bullets.any(); both are read by the same updateTile
soundLoop call, and both take the same bullets-any()
state.

RED decisions (resolved at RED): (1) One slice entry
for the two methods, one pure function, ONE owner
(PortGame.source_laser_turret_build_active_sound_state,
the N2360 PortGame.* convention for PortBridge files:
the catalog validator discovers PortBridge files as
port_game.*, registering the bridge filename as owner
breaks implementation_linkage validation). (2) The
bullets seq is NOT ported: its emptiness arrives as
the explicit has_bullets param (the N2330 param
precedent). `bullets.any()` is `return bullets.any();`
-- text-shared with N2389 (ContinuousTurretBuild,
a different class with the same one-line body) and
registered under this java_method (the N632-N639 vs
N1078-N1085 precedent); `return 1f;` is generic
(11 local slices) and registered the same way (the
N2318/N2346 precedent). (3) Both inputs are scalars
-- there is no dict frame input, so there is no
input-unmutated proof key for this slice (unlike the
frame-taking Turret accessors). (4) NO audio playback
in this slice (playback belongs to the updateTile
tick, which reads both -- soundLoop itself is NOT
ported here). (5) NO driver line: pure read accessors
the tick reads, not per-tick writes. (6) Evidence,
not ownership: the twin-class overrides own their
own bodies -- TurretBuild base (N2346,
shootWarmup-driven), ContinuousTurretBuild (N2389)
-- and are NOT touched here. Two new result symbols:
active_sound_volume + should_active_sound. Slice
source: LaserTurret.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_laser_turret_should_consume import DEFERRED as N2360_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
LASER_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/LaserTurret.java'
PROOF = '/root/C07LaserTurretActiveSoundVolumeProof'
ACTIVE_SOUND_OWNER = 'PortGame.source_laser_turret_build_active_sound_state'
TESTS = ['test_c07_laser_turret_active_sound_volume_registration', 'test_all_c07_laser_turret_active_sound_volume_input_evidence_is_exact', 'test_laser_turret_active_sound_volume_state', 'test_reference_graph_and_actual_c07_laser_turret_active_sound_volume']
# The 1 slice source the N2418 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/LaserTurret.java',
]
EXACT_EXPRS = [
    'public class LaserTurret extends PowerTurret{',
    'public class LaserTurretBuild extends PowerTurretBuild{',
    '@Override',
    'public float activeSoundVolume(){',
    'return 1f;',
    'public boolean shouldActiveSound(){',
    'return bullets.any();',
    'public Seq<BulletEntry> bullets = new Seq<>();',
]

# DEFERRED is carried from the N2360 register script via import --
# never retyped. All N2360 entries are carried verbatim (the
# N2355 chain, the B/C notes, and N2360's own Windows proof
# debt -- none of them is resolved by this slice). One entry
# is added: N2418's Windows proof debt.
DEFERRED = list(N2360_DEFERRED) + [
    'LaserTurret activeSoundVolume/shouldActiveSound Windows Godot proof -- debt in GOAL.md section 5, same as N2360: the N2418 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=LASER_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    active_sound_inputs = {
        'has_bullets': a('bool', 'return bullets.any();', 'Whether the bullets seq is non-empty, bullets.any() (LaserTurret.java:153): the seq itself is NOT ported -- its emptiness arrives as an explicit param (the N2330 param precedent).'),
    }
    active_sound_outputs = {
        'active_sound_volume': a('float', 'return 1f;', 'The active-sound volume (LaserTurret.java:148, `return 1f;`): a constant 1f -- the laser loop always plays at full volume while it sounds.'),
        'should_active_sound': a('bool', 'return bullets.any();', 'Whether the active loop sound should play (LaserTurret.java:153, `return bullets.any();`): true while a bullet is around, false otherwise.'),
    }
    return (active_sound_inputs, active_sound_outputs)


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
    (active_sound_inputs, active_sound_outputs) = definitions()

    entries = [
        ('N2418', ACTIVE_SOUND_OWNER, 'source_laser_turret_build_active_sound_state', LASER_TURRET, 'mindustry.world.blocks.defense.turrets.LaserTurret.LaserTurretBuild', 'LaserTurretBuild.activeSoundVolume(); LaserTurretBuild.shouldActiveSound()', active_sound_inputs, active_sound_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed LaserTurretBuild.activeSoundVolume()/shouldActiveSound() state from LaserTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed LaserTurretBuild.activeSoundVolume()/shouldActiveSound() state from LaserTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: active_sound_volume, should_active_sound.
    by_slice['N2418'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2418', dict(status='done', java_source=LASER_TURRET, java_class='mindustry.world.blocks.defense.turrets.LaserTurret.LaserTurretBuild', java_method='LaserTurretBuild.activeSoundVolume(); LaserTurretBuild.shouldActiveSound()', godot_owner=ACTIVE_SOUND_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2418'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
