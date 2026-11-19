"""Register the Turret charge sound state (N2271).

The deferred item named in the N2269/N2270 handoffs: "Turret
charge sound / charge effect for firstShotDelay > 0 -- effects/
sound wait for their own slice; N2269 only pins the
firstShotDelay > 0 branch exists (Turret.java:747-748)".

The charge branch (Turret.java:747-749, inside
TurretBuild.shoot(BulletType)):
`if(shoot.firstShotDelay > 0){`
`chargeSound.at(bulletX, bulletY, Mathf.random(soundPitchMin, soundPitchMax));`
`type.chargeEffect.at(bulletX, bulletY, rotation);`
`}`
runs when shooting begins and the shoot pattern carries a
first-shot delay. The delay itself defaults to 0
(ShootPattern.java:11 `public float firstShotDelay = 0;`) and
the sound defaults to silence (Turret.java:125-126 `/**
Sound emitted when shoot.firstShotDelay is >0 and shooting
begins. */ public Sound chargeSound = Sounds.none;`). Among
turret block defs, ONLY lancer sets either: `shoot.
firstShotDelay = 40f;` (Blocks.java:3564) and `chargeSound =
Sounds.chargeLancer;` (Blocks.java:3579), in `lancer = new
PowerTurret("lancer"){{` (Blocks.java:3560). Every other
turret reads the defaults, so the guard stays off and no
charge sound plays. The pitch range is the class default
(Turret.java:132 `public float soundPitchMin = 0.9f,
soundPitchMax = 1.1f;`); no def overrides it.

This slice is the N2143/N2270 catalog-capture pattern applied
to the charge sound: (1) the emitter captures firstShotDelay
(the `range` / `reload` numeric pattern) and chargeSound (the
Sounds.* name) for Turret-family blocks from the block
initializer's own assignment -- only lancer carries them;
(2) one pure read on the block,
source_turret_charge_sound_state(block), returns
{first_shot_delay, charge_sound, charge_emitted} -- the
catalog values when present, the class defaults 0.0 / "none"
otherwise, null-safe, with charge_emitted exactly the :747
guard (first_shot_delay > 0); (3) NO driver tick: the
emission happens inside shoot(), an event the driver has no
equivalent for yet -- the same event-driven precedent as
N2268 (configured dispatch), N2269 (delayed bullets are a
Time.run callback) and N2267. The bullet type's chargeEffect
(Turret.java:749, `type.chargeEffect.at(...)`, BulletType.
java:79 `public Effect chargeEffect = Fx.none;`) waits for
its own slice: the effect lives on the bullet type (lancer's
LaserBulletType shootType, `chargeEffect = new MultiEffect(
Fx.lancerLaserCharge, Fx.lancerLaserChargeBegin);`,
Blocks.java:3586), and the catalog has no shootType
bullet-effect representation yet, so this read pins the
sound side only. SSOT expected after GREEN: symbols +3,
Done +1, contracts +1, schema +3, 11640/1720/1654/3099 ->
11643/1721/1655/3102; defense shard slices 197 -> 198,
contracts 196 -> 197.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_power_heat_fold import DEFERRED as N2270_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
SHOOT_PATTERN = 'core/src/mindustry/entities/pattern/ShootPattern.java'
BULLET_TYPE = 'core/src/mindustry/entities/bullet/BulletType.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07TurretChargeStateProof'
CHARGE_OWNER = 'SourceTurretBuildState.source_turret_charge_sound_state'
TESTS = ['test_c07_turret_charge_state_registration', 'test_all_c07_turret_charge_state_input_evidence_is_exact', 'test_turret_charge_state', 'test_reference_graph_and_actual_c07_turret_charge_state']
# The slice sources the N2271 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/entities/pattern/ShootPattern.java',
    'core/src/mindustry/entities/bullet/BulletType.java',
    'core/src/mindustry/content/Blocks.java',
]
EXACT_EXPRS = ['public Sound chargeSound = Sounds.none;', 'Sound emitted when shoot.firstShotDelay is >0 and shooting begins.', 'public float firstShotDelay = 0;', 'public Effect chargeEffect = Fx.none;', 'if(shoot.firstShotDelay > 0){', 'chargeSound.at(bulletX, bulletY, Mathf.random(soundPitchMin, soundPitchMax));', 'type.chargeEffect.at(bulletX, bulletY, rotation);', 'shoot.firstShotDelay = 40f;', 'chargeSound = Sounds.chargeLancer;', 'chargeEffect = new MultiEffect(Fx.lancerLaserCharge, Fx.lancerLaserChargeBegin);', 'lancer = new PowerTurret("lancer"){{', 'public float soundPitchMin = 0.9f, soundPitchMax = 1.1f;']

# DEFERRED is carried from the N2270 register script via import --
# never retyped. The charge sound is done by this slice (it was
# the next item named in the N2269/N2270 handoffs); the charge
# effect, the canConsume() heat gate, calculateHeat live scan,
# findTarget, maxHealth/health re-sync, set(tile) world position
# and the other ItemTurret defs still wait.
DEFERRED = list(N2270_DEFERRED) + [
    'Turret charge sound for firstShotDelay > 0 -- DONE by this slice (N2271); it was the next item named in the N2269/N2270 handoffs. The catalog now captures firstShotDelay / chargeSound for Turret-family blocks (lancer 40f / chargeLancer, the only def that sets either), the pure read exposes them with the class defaults (0.0 / "none") otherwise, and charge_emitted pins the Turret.java:747 guard (first_shot_delay > 0). No driver tick: the emission happens inside shoot(), an event the driver has no equivalent for yet.',
    'Turret charge effect (BulletType.chargeEffect, Turret.java:749 `type.chargeEffect.at(bulletX, bulletY, rotation);`) -- waits for its own slice; the effect lives on the bullet type (lancer LaserBulletType shootType, `chargeEffect = new MultiEffect(Fx.lancerLaserCharge, Fx.lancerLaserChargeBegin);`, Blocks.java:3586), and the catalog has no shootType bullet-effect representation yet, so the N2271 read pins the sound side only.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    charge_inputs = {
        'block': a('Object', 'lancer = new PowerTurret("lancer"){{', 'The block definition the read resolves (Blocks.java:3560): the catalog block whose properties carry the per-block firstShotDelay / chargeSound overrides, or the class defaults when it carries none. Duo is the same shape with neither override (Blocks.java:3257).', source=BLOCKS),
    }
    charge_outputs = {
        'first_shot_delay': a('float', 'public float firstShotDelay = 0;', 'The first-shot delay in ticks before the first bullet fires (ShootPattern.java:11, the class default 0; the read returns the catalog value when the block carries one -- 40.0 for lancer, Blocks.java:3564).', source=SHOOT_PATTERN),
        'charge_sound': a('String', 'public Sound chargeSound = Sounds.none;', 'The name of the sound emitted when shooting begins with a first-shot delay (Turret.java:125-126, the class default Sounds.none; the read returns the catalog value when the block carries one -- "chargeLancer" for lancer, Blocks.java:3579).'),
        'charge_emitted': a('bool', 'if(shoot.firstShotDelay > 0){', 'Whether the charge branch runs at shoot() time (Turret.java:747 -- true exactly when first_shot_delay > 0; false for every turret that keeps the 0 default, including duo and malign).'),
    }
    return charge_inputs, charge_outputs


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
    charge_inputs, charge_outputs = definitions()

    entries = [
        ('N2271', CHARGE_OWNER, 'source_turret_charge_sound_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.shoot()', charge_inputs, charge_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret charge sound state from Turret.java / ShootPattern.java / Blocks.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret charge sound state from Turret.java / ShootPattern.java / Blocks.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: first_shot_delay, charge_sound, charge_emitted.
    by_slice['N2271'] = [
        'source_turret_charge_sound_state_result.first_shot_delay',
        'source_turret_charge_sound_state_result.charge_sound',
        'source_turret_charge_sound_state_result.charge_emitted',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2271', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.shoot()', godot_owner=CHARGE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2271'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
