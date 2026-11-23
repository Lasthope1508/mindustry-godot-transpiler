"""Register ContinuousTurretBuild.estimateDps()+hasAmmo()+shouldActiveSound() (N2389).

ContinuousTurretBuild.estimateDps()
(ContinuousTurret.java:43-46) returns 0f without
ammo, else shootType.damage * 60f over the
ContinuousBulletType damageInterval (5f default
when the shoot type is not a ContinuousBulletType).
ContinuousTurretBuild.hasAmmo()
(ContinuousTurret.java:60-62) is canConsume().
ContinuousTurretBuild.shouldActiveSound()
(ContinuousTurret.java:166-168) is bullets.any().
The three methods share one concern
(ContinuousTurretBuild ammo/sound state) and each
carries only one distinguishing expr, so they are
one slice (grouping approved by the main thread;
N2330/N2367/N2381/N2384/N2386 precedent). The
functions live in the existing PortBridge file
(opened by N2355), following the PortBridge
precedent (N2362/N2366/N2367/N2370/N2375) -- each
function gets its own owner
(PortGame.<function>_state), the N2384/N2386
three-method precedent, so every contract name
equals its GD function name (the batch-17
contract-name lesson).

RED decisions (resolved at RED): (1) The three
distinguishing exprs are `return shootType.damage
* 60f / (shootType instanceof ContinuousBulletType
c ? c.damageInterval : 5f);`, `return canConsume
();` and `return bullets.any();` (0 hits in both
ledgers at probe time). (2) `return bullets.any
();` is registered HERE -- LaserTurretBuild
.shouldActiveSound (LaserTurret.java:152-154,
byte-identical) is DEAD, never scoped again
(main-thread allocation, draft batch 21 §2.2).
(3) `if(!hasAmmo()) return 0f;` is evidence only
-- already owned by N2301 (TurretBuild
.estimateDps); hasAmmo is the callee of this very
slice and arrives as the explicit has_ammo param.
(4) shootType.damage / damageInterval arrive as
explicit floats (the N2330 param precedent) --
BulletType / ContinuousBulletType are NOT ported;
the pattern-matching ternary keeps its branch via
the explicit is_continuous_bullet_type param (5f
default otherwise). (5) canConsume() is the
TurretBuild callee (Turret.java:624-629) -- its
value arrives as the explicit can_consume param.
(6) The bullets Seq arrives as an explicit Array
(the N2330 param precedent); arc Seq.any() is
size > 0, so the port reads not bullets.is_empty
(). (7) NO driver line: three pure functions the
setup/tick reads, not per-tick writes.
Three new result symbols: estimate_dps, has_ammo,
should_active_sound.
Slice source: ContinuousTurret.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_continuous_turret_version_write_read import DEFERRED as N2375_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
CONTINUOUS_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java'
PROOF = '/root/C07ContinuousTurretEstimateDpsHasAmmoShouldActiveSoundProof'
ESTIMATE_DPS_OWNER = 'PortGame.source_continuous_turret_build_estimate_dps_state'
HAS_AMMO_OWNER = 'PortGame.source_continuous_turret_build_has_ammo_state'
SHOULD_ACTIVE_SOUND_OWNER = 'PortGame.source_continuous_turret_build_should_active_sound_state'
TESTS = ['test_c07_continuous_turret_estimate_dps_has_ammo_should_active_sound_registration', 'test_all_c07_continuous_turret_estimate_dps_has_ammo_should_active_sound_input_evidence_is_exact', 'test_continuous_turret_estimate_dps_has_ammo_should_active_sound_state', 'test_reference_graph_and_actual_c07_continuous_turret_estimate_dps_has_ammo_should_active_sound']
# The 1 slice source the N2389 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java',
]
EXACT_EXPRS = [
    '@Override',
    'public float estimateDps(){',
    'if(!hasAmmo()) return 0f;',
    'return shootType.damage * 60f / (shootType instanceof ContinuousBulletType c ? c.damageInterval : 5f);',
    'public boolean hasAmmo(){',
    'return canConsume();',
    'public boolean shouldActiveSound(){',
    'return bullets.any();',
]

# DEFERRED is carried from the N2375 register script via import --
# never retyped. All N2375 entries are carried verbatim (the
# Turret chain, the B/C notes, and N2355/N2362/N2366/N2367/N2370/
# N2375's own Windows proof debt -- none of them is resolved by
# this slice). One entry is added: N2389's Windows proof debt.
DEFERRED = list(N2375_DEFERRED) + [
    'ContinuousTurret estimateDps + hasAmmo + shouldActiveSound Windows Godot proof -- debt in GOAL.md section 5, same as N2375: the N2389 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=CONTINUOUS_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    estimate_dps_guard = 'if(!hasAmmo()) return 0f;'
    estimate_dps_line = 'return shootType.damage * 60f / (shootType instanceof ContinuousBulletType c ? c.damageInterval : 5f);'
    has_ammo_line = 'return canConsume();'
    should_active_sound_line = 'return bullets.any();'
    estimate_dps_inputs = {
        'has_ammo': a('bool', estimate_dps_guard, 'Whether the build has ammo, hasAmmo() (ContinuousTurret.java:44, `if(!hasAmmo()) return 0f;`): the callee of this very slice -- true when canConsume() holds (ContinuousTurret.java:60-62) -- false forces a 0f estimate.'),
        'shoot_type_damage': a('float', estimate_dps_line, 'The shoot type damage, shootType.damage (ContinuousTurret.java:45, `return shootType.damage * 60f / (shootType instanceof ContinuousBulletType c ? c.damageInterval : 5f);`): BulletType.damage -- the per-shot damage, scaled to per-second by 60f.'),
        'is_continuous_bullet_type': a('bool', estimate_dps_line, 'Whether the shoot type is a ContinuousBulletType, shootType instanceof ContinuousBulletType c (ContinuousTurret.java:45): true selects the type damageInterval, false selects the 5f default.'),
        'damage_interval': a('float', estimate_dps_line, 'The damage interval, c.damageInterval (ContinuousTurret.java:45): ContinuousBulletType.damageInterval -- the seconds between damage ticks; only read when the shoot type is a ContinuousBulletType.'),
    }
    estimate_dps_outputs = {
        'estimate_dps': a('float', estimate_dps_line, 'The estimated damage per second (ContinuousTurret.java:45, `return shootType.damage * 60f / (shootType instanceof ContinuousBulletType c ? c.damageInterval : 5f);`): 0f without ammo, else shootType.damage * 60f over the damage interval (5f default).'),
    }
    has_ammo_inputs = {
        'can_consume': a('bool', has_ammo_line, 'Whether the build can consume, canConsume() (ContinuousTurret.java:61, `return canConsume();`): the TurretBuild callee (Turret.java:624-629) -- the consume gate, false when the turret cannot consume.'),
    }
    has_ammo_outputs = {
        'has_ammo': a('bool', has_ammo_line, 'Whether the build has ammo (ContinuousTurret.java:61, `return canConsume();`): true exactly when the build can consume -- ContinuousTurret spends nothing directly, so ammo is the consume gate.'),
    }
    should_active_sound_inputs = {
        'bullets': a('Array', should_active_sound_line, 'The flying bullets, bullets (ContinuousTurret.java:167, `return bullets.any();`): the ContinuousTurretBuild bullets Seq (ContinuousTurret.java:39) as an explicit Array of BulletEntry dicts -- only its emptiness is read, never mutated.'),
    }
    should_active_sound_outputs = {
        'should_active_sound': a('bool', should_active_sound_line, 'Whether the active sound should play (ContinuousTurret.java:167, `return bullets.any();`): true exactly when at least one bullet is flying -- arc Seq.any() is size > 0.'),
    }
    return (estimate_dps_inputs, estimate_dps_outputs), (has_ammo_inputs, has_ammo_outputs), (should_active_sound_inputs, should_active_sound_outputs)


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
    (estimate_dps_inputs, estimate_dps_outputs), (has_ammo_inputs, has_ammo_outputs), (should_active_sound_inputs, should_active_sound_outputs) = definitions()

    entries = [
        ('N2389', ESTIMATE_DPS_OWNER, 'source_continuous_turret_build_estimate_dps_state', CONTINUOUS_TURRET, 'mindustry.world.blocks.defense.turrets.ContinuousTurret.ContinuousTurretBuild', 'ContinuousTurretBuild.estimateDps()', estimate_dps_inputs, estimate_dps_outputs, True, 'Dictionary'),
        ('N2389', HAS_AMMO_OWNER, 'source_continuous_turret_build_has_ammo_state', CONTINUOUS_TURRET, 'mindustry.world.blocks.defense.turrets.ContinuousTurret.ContinuousTurretBuild', 'ContinuousTurretBuild.hasAmmo()', has_ammo_inputs, has_ammo_outputs, True, 'Dictionary'),
        ('N2389', SHOULD_ACTIVE_SOUND_OWNER, 'source_continuous_turret_build_should_active_sound_state', CONTINUOUS_TURRET, 'mindustry.world.blocks.defense.turrets.ContinuousTurret.ContinuousTurretBuild', 'ContinuousTurretBuild.shouldActiveSound()', should_active_sound_inputs, should_active_sound_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed ContinuousTurretBuild.estimateDps()+hasAmmo()+shouldActiveSound() state from ContinuousTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed ContinuousTurretBuild.estimateDps()+hasAmmo()+shouldActiveSound() state from ContinuousTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: estimate_dps estimate_dps,
    # has_ammo has_ammo, should_active_sound
    # should_active_sound.
    by_slice['N2389'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2389', dict(status='done', java_source=CONTINUOUS_TURRET, java_class='mindustry.world.blocks.defense.turrets.ContinuousTurret.ContinuousTurretBuild', java_method='ContinuousTurretBuild.estimateDps(); ContinuousTurretBuild.hasAmmo(); ContinuousTurretBuild.shouldActiveSound()', godot_owner=ESTIMATE_DPS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2389'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
