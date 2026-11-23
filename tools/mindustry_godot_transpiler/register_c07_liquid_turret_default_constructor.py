"""Register the LiquidTurret(String name) ctor field defaults (N2406).

LiquidTurret(String name) (LiquidTurret.java:22-29, `public
LiquidTurret(String name){`) assigns 4 field defaults on the
LiquidTurret def: `loopSound = Sounds.loopSpray;` (:24),
`shootSound = Sounds.none;` (:25), `smokeEffect = Fx.none;`
(:26) and `shootEffect = Fx.none;` (:27). The other ctor lines
are NOT in this slice and are never re-registered:
`super(name);` is already the exact_expr of N2185,
`hasLiquids = true;` of N927/N2000/N2179/N2182/N2209 (all
0-hit re-probed at HEAD 042ac898, local + remote ledgers).
One GD function on SourceLiquidTurretBuildState.gd (the
LiquidTurret def-defaults file -- the LiquidTurret def lives
in the BuildState file, unlike BaseTurret which got its own
defaults file at N2405). The 4 values are Sound/Effect
references, NOT literals: they arrive as explicit Variant
params and pass through (the N2405 BaseTurret ctor precedent
for `EnumSet.of(BlockFlag.turret)`). The Turret base defaults
the ctor overrides are `public Sound loopSound =
Sounds.none;` (Turret.java:128), `public Sound shootSound =
Sounds.shootDuo;` (Turret.java:122) and the nullable `public
@Nullable Effect shootEffect;` / `public @Nullable Effect
smokeEffect;` (Turret.java:116/118, default null). The
defaults are frame data only; no Draw is ported, and the
ambient-sound driver (N2304, HELD) is untouched. Five new
result symbols: one per default plus the updated def frame.
One slice source: LiquidTurret.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_base_turret_default_constructor import DEFERRED as N2405_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
LIQUID_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/LiquidTurret.java'
PROOF = '/root/C07LiquidTurretDefaultConstructorProof'
CTOR_OWNER = 'SourceLiquidTurretBuildState.source_liquid_turret_default_constructor_state'
TESTS = ['test_c07_liquid_turret_default_constructor_registration', 'test_all_c07_liquid_turret_default_constructor_input_evidence_is_exact', 'test_liquid_turret_default_constructor_state', 'test_reference_graph_and_actual_c07_liquid_turret_default_constructor']
# The 1 slice source the N2406 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/LiquidTurret.java',
]
EXACT_EXPRS = [
    'loopSound = Sounds.loopSpray;',
    'shootSound = Sounds.none;',
    'smokeEffect = Fx.none;',
    'shootEffect = Fx.none;',
]

# DEFERRED is carried from the N2405 register script via import --
# never retyped. Nothing in it closes here: N2406 ports the
# LiquidTurret() ctor field defaults, which no N2405 entry lists.
# One entry is added: the N2406 Windows Godot proof debt
# (GOAL.md section 5).
DEFERRED = list(N2405_DEFERRED) + [
    'LiquidTurret() ctor field defaults N2406 Windows Godot proof -- debt in GOAL.md section 5, same as N2405: the N2406 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=LIQUID_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    ctor_inputs = {
        'liquid_turret_defaults': a('Dictionary', 'public LiquidTurret(String name){', 'The LiquidTurret def frame (LiquidTurret.java:22, `public LiquidTurret(String name){`): the family-convention first arg; the ctor writes its 4 field defaults into it, so liquid_turret_defaults is an in/out param -- keys already present keep their unrelated values, the 4 ctor keys are overwritten with the ctor values.'),
        'loop_sound': a('Variant', 'loopSound = Sounds.loopSpray;', 'The loop sound (LiquidTurret.java:24, `loopSound = Sounds.loopSpray;`): Turret.loopSound; the Sound reference arrives as an explicit Variant param and passes through to the result loop_sound key; the Turret base default it overrides is `public Sound loopSound = Sounds.none;` (Turret.java:128).'),
        'shoot_sound': a('Variant', 'shootSound = Sounds.none;', 'The shoot sound (LiquidTurret.java:25, `shootSound = Sounds.none;`): Turret.shootSound; the Sound reference arrives as an explicit Variant param and passes through to the result shoot_sound key; the Turret base default it overrides is `public Sound shootSound = Sounds.shootDuo;` (Turret.java:122).'),
        'smoke_effect': a('Variant', 'smokeEffect = Fx.none;', 'The smoke effect (LiquidTurret.java:26, `smokeEffect = Fx.none;`): Turret.smokeEffect; the Effect reference arrives as an explicit Variant param and passes through to the result smoke_effect key; the Turret base default it overrides is the nullable `public @Nullable Effect smokeEffect;` (Turret.java:118, default null).'),
        'shoot_effect': a('Variant', 'shootEffect = Fx.none;', 'The shoot effect (LiquidTurret.java:27, `shootEffect = Fx.none;`): Turret.shootEffect; the Effect reference arrives as an explicit Variant param and passes through to the result shoot_effect key; the Turret base default it overrides is the nullable `public @Nullable Effect shootEffect;` (Turret.java:116, default null).'),
    }
    ctor_outputs = {
        'loop_sound': a('Variant', 'loopSound = Sounds.loopSpray;', 'The loop sound, read through (LiquidTurret.java:24, `loopSound = Sounds.loopSpray;`): the Sound reference passed in as loop_sound; liquid turrets spray continuously, so the loop is the spray sound.'),
        'shoot_sound': a('Variant', 'shootSound = Sounds.none;', 'The shoot sound, read through (LiquidTurret.java:25, `shootSound = Sounds.none;`): the Sound reference passed in as shoot_sound; liquid turrets have no per-shot sound.'),
        'smoke_effect': a('Variant', 'smokeEffect = Fx.none;', 'The smoke effect, read through (LiquidTurret.java:26, `smokeEffect = Fx.none;`): the Effect reference passed in as smoke_effect; liquid turrets emit no smoke effect.'),
        'shoot_effect': a('Variant', 'shootEffect = Fx.none;', 'The shoot effect, read through (LiquidTurret.java:27, `shootEffect = Fx.none;`): the Effect reference passed in as shoot_effect; liquid turrets emit no shoot effect.'),
        'liquid_turret_defaults': a('Dictionary', 'public LiquidTurret(String name){', 'The updated LiquidTurret def frame (LiquidTurret.java:22, `public LiquidTurret(String name){`): the same in/out Dictionary -- unrelated keys preserved, the 4 ctor keys written with the ctor values.'),
    }
    return ctor_inputs, ctor_outputs


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
    ctor_inputs, ctor_outputs = definitions()

    entries = [
        ('N2406', CTOR_OWNER, 'source_liquid_turret_default_constructor_state', LIQUID_TURRET, 'mindustry.world.blocks.defense.turrets.LiquidTurret', 'LiquidTurret(String name)', ctor_inputs, ctor_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed LiquidTurret() ctor field defaults state from LiquidTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed LiquidTurret() ctor field defaults state from LiquidTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the 4 defaults in ctor
    # order, then the updated def frame.
    by_slice['N2406'] = [
        'source_liquid_turret_default_constructor_state_result.loop_sound',
        'source_liquid_turret_default_constructor_state_result.shoot_sound',
        'source_liquid_turret_default_constructor_state_result.smoke_effect',
        'source_liquid_turret_default_constructor_state_result.shoot_effect',
        'source_liquid_turret_default_constructor_state_result.liquid_turret_defaults',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2406', dict(status='done', java_source=LIQUID_TURRET, java_class='mindustry.world.blocks.defense.turrets.LiquidTurret', java_method='LiquidTurret(String name)', godot_owner=CTOR_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2406'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
