"""Register the Turret charge effect state (N2273).

The deferred item named in the N2269/N2270/N2271/N2272 handoffs:
"Turret charge effect (BulletType.chargeEffect,
Turret.java:749) -- waits for its own slice; the effect
lives on the bullet type (lancer LaserBulletType shootType,
`chargeEffect = new MultiEffect(Fx.lancerLaserCharge,
Fx.lancerLaserChargeBegin);`, Blocks.java:3586), and the
catalog has no shootType bullet-effect representation yet."

The charge branch (Turret.java:747-749, inside
TurretBuild.shoot(BulletType)):
`if(shoot.firstShotDelay > 0){`
`chargeSound.at(bulletX, bulletY, Mathf.random(soundPitchMin, soundPitchMax));`
`type.chargeEffect.at(bulletX, bulletY, rotation);`
`}`
runs when shooting begins and the shoot pattern carries a
first-shot delay. The effect defaults to none
(BulletType.java:78-79 `/** Effect created when charging
starts; only usable in single-shot weapons with a
firstShotDelay / shotDelay. */ public Effect chargeEffect =
Fx.none;`) and the delay defaults to 0 (ShootPattern.
java:11 `public float firstShotDelay = 0;`). Among turret
block defs, ONLY lancer sets either: `shoot.
firstShotDelay = 40f;` (Blocks.java:3564) and, on its
LaserBulletType shootType (`shootType = new
LaserBulletType(140){{`, Blocks.java:3583), `chargeEffect =
new MultiEffect(Fx.lancerLaserCharge,
Fx.lancerLaserChargeBegin);` (Blocks.java:3586), in `lancer
= new PowerTurret("lancer"){{` (Blocks.java:3560). Every
other turret reads the defaults, so the guard stays off
and no charge effect plays.

This slice is the N2143/N2271 catalog-capture pattern
applied to the charge effect: (1) the emitter captures
chargeEffect (the MultiEffect construction verbatim,
without `new` -- there is no single Fx.* member name to
store, unlike chargeSound) for Turret-family blocks from
the block initializer's own assignment -- only lancer
carries it; (2) one pure read on the block,
source_turret_charge_effect_state(block), returns
{first_shot_delay, charge_effect, charge_effect_emitted}
-- the catalog values when present, the class defaults
0.0 / "none" otherwise, null-safe, with
charge_effect_emitted exactly the :747 guard
(first_shot_delay > 0); (3) NO driver tick: the emission
happens inside shoot(), an event the driver has no
equivalent for yet -- the same event-driven precedent as
N2268 (configured dispatch), N2269 (delayed bullets are a
Time.run callback) and N2271 (charge sound). The
first_shot_delay key is kept for consistency with N2271:
the guard reads it, and the two charge slices share the
same guard input. SSOT expected after GREEN: symbols +3,
Done +1, contracts +1, schema +2, 11644/1722/1656/3103 ->
11647/1723/1657/3105; defense shard slices 199 -> 200,
contracts 198 -> 199.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_can_consume_heat_gate import DEFERRED as N2272_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
SHOOT_PATTERN = 'core/src/mindustry/entities/pattern/ShootPattern.java'
BULLET_TYPE = 'core/src/mindustry/entities/bullet/BulletType.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07TurretChargeEffectProof'
CHARGE_OWNER = 'SourceTurretBuildState.source_turret_charge_effect_state'
TESTS = ['test_c07_turret_charge_effect_registration', 'test_all_c07_turret_charge_effect_input_evidence_is_exact', 'test_turret_charge_effect', 'test_reference_graph_and_actual_c07_turret_charge_effect']
# The slice sources the N2273 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/entities/pattern/ShootPattern.java',
    'core/src/mindustry/entities/bullet/BulletType.java',
    'core/src/mindustry/content/Blocks.java',
]
EXACT_EXPRS = ['public Effect chargeEffect = Fx.none;', 'Effect created when charging starts; only usable in single-shot weapons with a firstShotDelay / shotDelay.', 'public float firstShotDelay = 0;', 'if(shoot.firstShotDelay > 0){', 'chargeSound.at(bulletX, bulletY, Mathf.random(soundPitchMin, soundPitchMax));', 'type.chargeEffect.at(bulletX, bulletY, rotation);', 'shoot.firstShotDelay = 40f;', 'chargeEffect = new MultiEffect(Fx.lancerLaserCharge, Fx.lancerLaserChargeBegin);', 'lancer = new PowerTurret("lancer"){{', 'shootType = new LaserBulletType(140){{']

# DEFERRED is carried from the N2272 register script via import --
# never retyped. The charge effect is done by this slice (it was
# the next item named in the N2269/N2270/N2271/N2272 handoffs);
# calculateHeat live scan, findTarget, maxHealth/health re-sync,
# set(tile) world position and the other ItemTurret defs still wait.
DEFERRED = list(N2272_DEFERRED) + [
    'Turret charge effect (BulletType.chargeEffect, Turret.java:749 `type.chargeEffect.at(bulletX, bulletY, rotation);`) -- DONE by this slice (N2273); it was the next item named in the N2269/N2270/N2271/N2272 handoffs. The catalog now captures chargeEffect for Turret-family blocks (lancer only, `MultiEffect(Fx.lancerLaserCharge, Fx.lancerLaserChargeBegin)` on its LaserBulletType shootType, Blocks.java:3586), the pure read exposes it with the class default "none" otherwise, and charge_effect_emitted pins the Turret.java:747 guard (first_shot_delay > 0). No driver tick: the emission happens inside shoot(), an event the driver has no equivalent for yet.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    charge_inputs = {
        'block': a('Object', 'lancer = new PowerTurret("lancer"){{', 'The block definition the read resolves (Blocks.java:3560): the catalog block whose properties carry the per-block firstShotDelay / chargeEffect overrides, or the class defaults when it carries none. Duo is the same shape with neither override (Blocks.java:3257).', source=BLOCKS),
    }
    charge_outputs = {
        'first_shot_delay': a('float', 'public float firstShotDelay = 0;', 'The first-shot delay in ticks before the first bullet fires (ShootPattern.java:11, the class default 0; the read returns the catalog value when the block carries one -- 40.0 for lancer, Blocks.java:3564).', source=SHOOT_PATTERN),
        'charge_effect': a('String', 'public Effect chargeEffect = Fx.none;', 'The name of the effect emitted when shooting begins with a first-shot delay (BulletType.java:78-79, the class default Fx.none; the read returns the catalog value when the block carries one -- "MultiEffect(Fx.lancerLaserCharge, Fx.lancerLaserChargeBegin)" for lancer, Blocks.java:3586).', source=BULLET_TYPE),
        'charge_effect_emitted': a('bool', 'if(shoot.firstShotDelay > 0){', 'Whether the charge branch runs at shoot() time (Turret.java:747 -- true exactly when first_shot_delay > 0; false for every turret that keeps the 0 default, including duo and malign).'),
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
        ('N2273', CHARGE_OWNER, 'source_turret_charge_effect_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.shoot()', charge_inputs, charge_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret charge effect state from Turret.java / ShootPattern.java / BulletType.java / Blocks.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret charge effect state from Turret.java / ShootPattern.java / BulletType.java / Blocks.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: first_shot_delay, charge_effect, charge_effect_emitted.
    by_slice['N2273'] = [
        'source_turret_charge_effect_state_result.first_shot_delay',
        'source_turret_charge_effect_state_result.charge_effect',
        'source_turret_charge_effect_state_result.charge_effect_emitted',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2273', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.shoot()', godot_owner=CHARGE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2273'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
