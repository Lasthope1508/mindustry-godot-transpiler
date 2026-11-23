"""Register the Drill()+BurstDrill() ctor field-defaults slice (N2403).

Drill(String name) (Drill.java:76-88, `public
Drill(String name){`) sets the three Drill-only field
defaults: the block group (`group =
BlockGroup.drills;`, :80) and the ambient sound
(`ambientSound = Sounds.loopDrill;`, :82,
`ambientSoundVolume = 0.019f;`, :83).
BurstDrill(String name) (BurstDrill.java:35-45, `public
BurstDrill(String name){`) sets the four BurstDrill-only
field defaults: the drill effect (`drillEffectRnd =
0f;`, :41, `drillEffect = Fx.shockwave;`, :42) and the
ambient sound (`ambientSoundVolume = 0.18f;`, :43,
`ambientSound = Sounds.drillCharge;`, :44).
One grouped slice: two ctors of one Drill family, same
concern "Drill family ctor defaults" -- main-thread
decision 2026-11-22, batch 26 slot 1 (APPROVED gộp; the
N2395/N2397/N2399 group precedent).
The other ctor lines are NOT this slice: `super(name);`
(N2185), `update = true;` / `solid = true;` /
`hasItems = true;` (N2180-N2183 and friends),
`hasLiquids = true;` (N927/N2000/N2179/N2182/N2209),
`envEnabled |= Env.space;` (N2185) and `flags =
EnumSet.of(BlockFlag.drill);` (N2401, batch 25 -- the
N2403 worker re-probed at HEAD 5ffcadd1 and confirmed
it is owned by N2401 now). `hardnessDrillMultiplier =
0f;` (BurstDrill.java:38) is owned by N2344
(getDrillTime, batch 5) -- evidence only.

The Block base defaults the ctors override are `public
BlockGroup group = BlockGroup.none;` (Block.java:249),
`public Sound ambientSound = Sounds.none;`
(Block.java:351) and `public float ambientSoundVolume
= 0.05f;` (Block.java:353), and the Drill base defaults
are `public Effect drillEffect = Fx.mine;`
(Drill.java:53) and `public float drillEffectRnd =
-1f;` (Drill.java:55). `Sounds.loopDrill` /
`Sounds.drillCharge` are the drill loop sound asset
refs -- they arrive as explicit Variant params, NOT
re-ported. `BlockGroup.drills` is the block-group enum
value -- it arrives as an explicit Variant param, NOT
re-ported. `Fx.shockwave` is the burst effect ref -- it
arrives as an explicit Variant param, NOT re-ported.

Two pure functions on the existing
SourceBurstDrillBuildState.gd (the N2399 two-function
precedent): they return the computed frame defaults and
do NOT touch real audio playback. This is field
defaults only: NOT ambient C (N2304 HELD -- the
SoundControl updateLoops mixer), NO driver tick line.
Nine new result symbols: Drill name, group,
ambient_sound, ambient_sound_volume; BurstDrill name,
drill_effect_rnd, drill_effect, ambient_sound_volume,
ambient_sound. Slice sources: Drill.java +
BurstDrill.java + Block.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_drill_draw_place import DEFERRED as N2351_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
DRILL = 'core/src/mindustry/world/blocks/production/Drill.java'
BURST_DRILL = 'core/src/mindustry/world/blocks/production/BurstDrill.java'
BLOCK = 'core/src/mindustry/world/Block.java'
PROOF = '/root/C07DrillBurstDrillDefaultConstructorProof'
DRILL_OWNER = 'SourceBurstDrillBuildState.source_drill_default_constructor_state'
BURST_OWNER = 'SourceBurstDrillBuildState.source_burst_drill_default_constructor_state'
TESTS = ['test_c07_drill_burst_drill_default_constructor_registration', 'test_all_c07_drill_burst_drill_default_constructor_input_evidence_is_exact', 'test_drill_burst_drill_default_constructor_state', 'test_reference_graph_and_actual_c07_drill_burst_drill_default_constructor']
# The 3 slice sources the N2403 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/production/Drill.java',
    'core/src/mindustry/world/blocks/production/BurstDrill.java',
    'core/src/mindustry/world/Block.java',
]
EXACT_EXPRS = [
    'group = BlockGroup.drills;',
    'ambientSound = Sounds.loopDrill;',
    'ambientSoundVolume = 0.019f;',
    'drillEffectRnd = 0f;',
    'drillEffect = Fx.shockwave;',
    'ambientSoundVolume = 0.18f;',
    'ambientSound = Sounds.drillCharge;',
]

# DEFERRED is carried from the N2351 register script via import --
# never retyped. All N2351 entries are carried verbatim (the
# drawPlace remainder notes -- none of them is resolved by
# this slice). One entry is added: N2403's Windows proof debt.
DEFERRED = list(N2351_DEFERRED) + [
    'Drill()+BurstDrill() ctor field defaults Windows Godot proof -- debt in GOAL.md section 5, same as N2351: the N2403 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=DRILL, **extra):
        return backed(typ, source, expr, rule, **extra)

    drill_inputs = {
        'frame': a('Dictionary', 'public Drill(String name){', 'The drill frame (Drill(), Drill.java:76): carries no live keys for this load-time setup -- the ctor name and the two resource/enum params are passed explicitly, not as frame keys (the N2212 / N2224 per-def-param precedent); frame is the canonical first param of this family file.'),
        'block_name': a('String', 'public Drill(String name){', 'The block name (Drill.java:76, `public Drill(String name){`): the ctor name argument (mechanical-drill, pneumatic-drill, laser-drill, blast-drill, Blocks.java:2865-2919); it passes through to the result name key, and the three defaults below do not depend on it.'),
        'ambient_sound': a('Variant', 'ambientSound = Sounds.loopDrill;', 'The ambient sound ref (Drill.java:82, `ambientSound = Sounds.loopDrill;`): the drill loop sound asset ref -- Sounds is NOT ported here: it arrives as an explicit Variant param and passes through to the result ambient_sound key; the Block base default it overrides is `public Sound ambientSound = Sounds.none;` (Block.java:351).'),
        'group': a('Variant', 'group = BlockGroup.drills;', 'The block group (Drill.java:80, `group = BlockGroup.drills;`): the block-group enum value -- BlockGroup is NOT ported here: it arrives as an explicit Variant param and passes through to the result group key; the Block base default it overrides is `public BlockGroup group = BlockGroup.none;` (Block.java:249).'),
    }
    drill_outputs = {
        'name': a('String', 'public Drill(String name){', 'The block name, read through (Drill.java:76, `public Drill(String name){`): the ctor name argument passed in as block_name.'),
        'group': a('Variant', 'group = BlockGroup.drills;', 'The block group, read through (Drill.java:80, `group = BlockGroup.drills;`): the block-group enum value passed in as group; the Block base default it overrides is `public BlockGroup group = BlockGroup.none;` (Block.java:249).'),
        'ambient_sound': a('Variant', 'ambientSound = Sounds.loopDrill;', 'The ambient sound ref, read through (Drill.java:82, `ambientSound = Sounds.loopDrill;`): the drill loop sound asset ref passed in as ambient_sound; the Block base default it overrides is `public Sound ambientSound = Sounds.none;` (Block.java:351).'),
        'ambient_sound_volume': a('float', 'ambientSoundVolume = 0.019f;', 'The ambient sound base volume (Drill.java:83, `ambientSoundVolume = 0.019f;`): 0.019 -- quieter than the Block base default (`public float ambientSoundVolume = 0.05f;`, Block.java:353).'),
    }
    burst_inputs = {
        'frame': a('Dictionary', 'public BurstDrill(String name){', 'The burst-drill frame (BurstDrill(), BurstDrill.java:35): carries no live keys for this load-time setup -- the ctor name and the two resource refs are passed explicitly, not as frame keys (the N2212 / N2224 per-def-param precedent); frame is the canonical first param of this family file.', source=BURST_DRILL),
        'block_name': a('String', 'public BurstDrill(String name){', 'The block name (BurstDrill.java:35, `public BurstDrill(String name){`): the ctor name argument (impact-drill, eruption-drill, Blocks.java:3070-3093); it passes through to the result name key, and the four defaults below do not depend on it.', source=BURST_DRILL),
        'ambient_sound': a('Variant', 'ambientSound = Sounds.drillCharge;', 'The ambient sound ref (BurstDrill.java:44, `ambientSound = Sounds.drillCharge;`): the drill-charge sound asset ref -- Sounds is NOT ported here: it arrives as an explicit Variant param and passes through to the result ambient_sound key; the Block base default it overrides is `public Sound ambientSound = Sounds.none;` (Block.java:351).', source=BURST_DRILL),
        'drill_effect': a('Variant', 'drillEffect = Fx.shockwave;', 'The drill effect ref (BurstDrill.java:42, `drillEffect = Fx.shockwave;`): the burst shockwave effect ref -- Fx is NOT ported here: it arrives as an explicit Variant param and passes through to the result drill_effect key; the Drill base default it overrides is `public Effect drillEffect = Fx.mine;` (Drill.java:53).', source=BURST_DRILL),
    }
    burst_outputs = {
        'name': a('String', 'public BurstDrill(String name){', 'The block name, read through (BurstDrill.java:35, `public BurstDrill(String name){`): the ctor name argument passed in as block_name.', source=BURST_DRILL),
        'drill_effect_rnd': a('float', 'drillEffectRnd = 0f;', 'The drill effect random factor (BurstDrill.java:41, `drillEffectRnd = 0f;`): 0 -- the burst effect always spawns at the block center, overriding the Drill base default (`public float drillEffectRnd = -1f;`, Drill.java:55).', source=BURST_DRILL),
        'drill_effect': a('Variant', 'drillEffect = Fx.shockwave;', 'The drill effect ref, read through (BurstDrill.java:42, `drillEffect = Fx.shockwave;`): the burst shockwave effect ref passed in as drill_effect; the Drill base default it overrides is `public Effect drillEffect = Fx.mine;` (Drill.java:53).', source=BURST_DRILL),
        'ambient_sound_volume': a('float', 'ambientSoundVolume = 0.18f;', 'The ambient sound base volume (BurstDrill.java:43, `ambientSoundVolume = 0.18f;`): 0.18 -- louder than the Block base default (`public float ambientSoundVolume = 0.05f;`, Block.java:353).', source=BURST_DRILL),
        'ambient_sound': a('Variant', 'ambientSound = Sounds.drillCharge;', 'The ambient sound ref, read through (BurstDrill.java:44, `ambientSound = Sounds.drillCharge;`): the drill-charge sound asset ref passed in as ambient_sound; the Block base default it overrides is `public Sound ambientSound = Sounds.none;` (Block.java:351).', source=BURST_DRILL),
    }
    return ((drill_inputs, drill_outputs), (burst_inputs, burst_outputs))


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
    pairs = definitions()

    entries = [
        ('N2403', DRILL_OWNER, 'source_drill_default_constructor_state', DRILL, 'mindustry.world.blocks.production.Drill', 'Drill.Drill(String name)', pairs[0][0], pairs[0][1], True, 'Dictionary'),
        ('N2403', BURST_OWNER, 'source_burst_drill_default_constructor_state', BURST_DRILL, 'mindustry.world.blocks.production.BurstDrill', 'BurstDrill.BurstDrill(String name)', pairs[1][0], pairs[1][1], True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Drill()/BurstDrill() ctor field defaults from Drill.java + BurstDrill.java + Block.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Drill()/BurstDrill() ctor field defaults from Drill.java + BurstDrill.java + Block.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: Drill outputs; BurstDrill
    # outputs.
    by_slice['N2403'] = [
        'source_drill_default_constructor_state_result.name',
        'source_drill_default_constructor_state_result.group',
        'source_drill_default_constructor_state_result.ambient_sound',
        'source_drill_default_constructor_state_result.ambient_sound_volume',
        'source_burst_drill_default_constructor_state_result.name',
        'source_burst_drill_default_constructor_state_result.drill_effect_rnd',
        'source_burst_drill_default_constructor_state_result.drill_effect',
        'source_burst_drill_default_constructor_state_result.ambient_sound_volume',
        'source_burst_drill_default_constructor_state_result.ambient_sound',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2403', dict(status='done', java_source=DRILL, java_class='mindustry.world.blocks.production.Drill', java_method='Drill.Drill(String name)/BurstDrill.BurstDrill(String name)', godot_owner=DRILL_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2403'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
