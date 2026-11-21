"""Register the BeamDrill() ctor field-defaults slice (N2401).

BeamDrill(String name) (BeamDrill.java:63-80, `public
BeamDrill(String name){`) sets the six BeamDrill-only field
defaults: the render flags (`drawArrow = false;`, :70,
`regionRotated1 = 1;`, :71, `ignoreLineRotation = true;`,
:72) and the ambient sound (`ambientSoundVolume = 0.05f;`,
:73, `ambientSound = Sounds.loopMineBeam;`, :74) plus the
block flag (`flags = EnumSet.of(BlockFlag.drill);`, :77).
The other ctor lines are NOT this slice: `super(name);`
(:64, N2185), `hasItems = true;` / `rotate = true;` /
`update = true;` / `solid = true;` (:66-69, N2180-N2183
and friends) and `envEnabled |= Env.space;` (:76, N2185)
all hit the ledgers already.

The Block base defaults the ctor overrides are `public
boolean drawArrow = true;` (Block.java:136), `public int
regionRotated1 = -1, regionRotated2 = -1;`
(Block.java:426), `public boolean ignoreLineRotation =
false;` (Block.java:130), `public Sound ambientSound =
Sounds.none;` (Block.java:351) and `public
EnumSet<BlockFlag> flags = EnumSet.of();`
(Block.java:251) -- while `public float ambientSoundVolume
= 0.05f;` (Block.java:353) already equals the ctor value,
so the ctor line only re-asserts it. `Sounds.loopMineBeam`
is the beam-mining loop sound asset ref
(core/assets/sounds/beams) -- it arrives as an explicit
Variant param, NOT re-ported. `EnumSet.of(BlockFlag.drill)`
is the block-flag enum value (`drill` -- "Is a drill.",
BlockFlag.java, core/src/mindustry/world/meta/BlockFlag.java)
-- it arrives as an explicit Variant param, NOT re-ported.

The three render-flag strings also appear in the Turret
ctor (N2400, same strings, different class) -- both
slices register them, but this register pins java_method
to the BeamDrill ctor (`BeamDrill.BeamDrill(String name)`),
never copied from N2400.

One pure function on the existing
SourceBeamDrillBuildState.gd (the N2394 init_state
precedent): it returns the computed frame defaults and
does NOT touch real audio playback. This is field
defaults only: NOT ambient C (N2304 HELD -- the
SoundControl updateLoops mixer), NO driver tick line.
Seven new result symbols: name, draw_arrow,
region_rotated_1, ignore_line_rotation,
ambient_sound_volume, ambient_sound, flags. Slice sources:
BeamDrill.java + Block.java + BlockFlag.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_beam_drill_update_tile import DEFERRED as N2398_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BEAM_DRILL = 'core/src/mindustry/world/blocks/production/BeamDrill.java'
BLOCK = 'core/src/mindustry/world/Block.java'
BLOCK_FLAG = 'core/src/mindustry/world/meta/BlockFlag.java'
PROOF = '/root/C07BeamDrillDefaultConstructorProof'
OWNER = 'SourceBeamDrillBuildState.source_beam_drill_default_constructor_state'
TESTS = ['test_c07_beam_drill_default_constructor_registration', 'test_all_c07_beam_drill_default_constructor_input_evidence_is_exact', 'test_beam_drill_default_constructor_state', 'test_reference_graph_and_actual_c07_beam_drill_default_constructor']
# The 3 slice sources the N2401 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/production/BeamDrill.java',
    'core/src/mindustry/world/Block.java',
    'core/src/mindustry/world/meta/BlockFlag.java',
]
EXACT_EXPRS = [
    'drawArrow = false;',
    'regionRotated1 = 1;',
    'ignoreLineRotation = true;',
    'ambientSoundVolume = 0.05f;',
    'ambientSound = Sounds.loopMineBeam;',
    'flags = EnumSet.of(BlockFlag.drill);',
]

# DEFERRED is carried from the N2398 register script via import --
# never retyped. This slice resolves NONE of the carried entries
# (the ctor is load-time block defaults, not the updateTile
# facing-harvest + dump half, the warmup gate / multiplier /
# lastDrillSpeed / time advance (N2155), or the updateLasers /
# updateFacing call sites (N2379)), so all are carried verbatim.
# One entry is added: N2401's Windows proof debt.
DEFERRED = list(N2398_DEFERRED) + [
    'BeamDrill() ctor field defaults Windows Godot proof -- debt in GOAL.md section 5, same as N2398: the N2401 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=BEAM_DRILL, **extra):
        return backed(typ, source, expr, rule, **extra)

    inputs = {
        'frame': a('Dictionary', 'public BeamDrill(String name){', 'The beam-drill frame (BeamDrill(), BeamDrill.java:63): carries no live keys for this load-time setup -- the ctor name and the two resource/enum params are passed explicitly, not as frame keys (the N2212 / N2224 per-def-param precedent); frame is the canonical first param of this family file.'),
        'block_name': a('String', 'public BeamDrill(String name){', 'The block name (BeamDrill.java:63, `public BeamDrill(String name){`): the ctor name argument (plasma-bore, large-plasma-bore, Blocks.java:3038-3065); it passes through to the result name key, and the six defaults below do not depend on it.'),
        'ambient_sound': a('Variant', 'ambientSound = Sounds.loopMineBeam;', 'The ambient sound ref (BeamDrill.java:74, `ambientSound = Sounds.loopMineBeam;`): the beam-mining loop sound asset ref (core/assets/sounds/beams) -- Sounds is NOT ported here: it arrives as an explicit Variant param and passes through to the result ambient_sound key; the Block base default it overrides is `public Sound ambientSound = Sounds.none;` (Block.java:351).'),
        'block_flags': a('Variant', 'flags = EnumSet.of(BlockFlag.drill);', 'The block flags (BeamDrill.java:77, `flags = EnumSet.of(BlockFlag.drill);`): the block-flag enum value (`drill` -- "Is a drill.", BlockFlag.java, core/src/mindustry/world/meta/BlockFlag.java) -- EnumSet is NOT ported here: it arrives as an explicit Variant param and passes through to the result flags key; the Block base default it overrides is `public EnumSet<BlockFlag> flags = EnumSet.of();` (Block.java:251).'),
    }
    outputs = {
        'name': a('String', 'public BeamDrill(String name){', 'The block name, read through (BeamDrill.java:63, `public BeamDrill(String name){`): the ctor name argument passed in as block_name.'),
        'draw_arrow': a('bool', 'drawArrow = false;', 'Whether to draw a rotation arrow (BeamDrill.java:70, `drawArrow = false;`): false -- the BeamDrill ctor disables the arrow the Block base default enables (`public boolean drawArrow = true;`, Block.java:136); a line of blocks never draws the arrow.'),
        'region_rotated_1': a('int', 'regionRotated1 = 1;', 'The first rotated region index (BeamDrill.java:71, `regionRotated1 = 1;`): 1 -- the icons() region index rotated in ConstructBlocks, overriding the Block base default (`public int regionRotated1 = -1, regionRotated2 = -1;`, Block.java:426).'),
        'ignore_line_rotation': a('bool', 'ignoreLineRotation = true;', 'Whether to ignore the line-drag rotation (BeamDrill.java:72, `ignoreLineRotation = true;`): true -- the drill does not face the line drag direction, overriding the Block base default (`public boolean ignoreLineRotation = false;`, Block.java:130).'),
        'ambient_sound_volume': a('float', 'ambientSoundVolume = 0.05f;', 'The ambient sound base volume (BeamDrill.java:73, `ambientSoundVolume = 0.05f;`): 0.05 -- the same value as the Block base default (`public float ambientSoundVolume = 0.05f;`, Block.java:353), so the ctor line only re-asserts it.'),
        'ambient_sound': a('Variant', 'ambientSound = Sounds.loopMineBeam;', 'The ambient sound ref, read through (BeamDrill.java:74, `ambientSound = Sounds.loopMineBeam;`): the beam-mining loop sound asset ref passed in as ambient_sound; the Block base default it overrides is `public Sound ambientSound = Sounds.none;` (Block.java:351).'),
        'flags': a('Variant', 'flags = EnumSet.of(BlockFlag.drill);', 'The block flags, read through (BeamDrill.java:77, `flags = EnumSet.of(BlockFlag.drill);`): the block-flag enum value passed in as block_flags; the Block base default it overrides is `public EnumSet<BlockFlag> flags = EnumSet.of();` (Block.java:251).'),
    }
    return (inputs, outputs)


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
        total += len(pair)
        for field, meta in pair.items():
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
    inputs, outputs = definitions()

    entries = [
        ('N2401', OWNER, 'source_beam_drill_default_constructor_state', BEAM_DRILL, 'mindustry.world.blocks.production.BeamDrill', 'BeamDrill.BeamDrill(String name)', inputs, outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BeamDrill() ctor field defaults from BeamDrill.java + Block.java + BlockFlag.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BeamDrill() ctor field defaults from BeamDrill.java + Block.java + BlockFlag.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: name, draw_arrow,
    # region_rotated_1, ignore_line_rotation,
    # ambient_sound_volume, ambient_sound, flags.
    by_slice['N2401'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2401', dict(status='done', java_source=BEAM_DRILL, java_class='mindustry.world.blocks.production.BeamDrill', java_method='BeamDrill.BeamDrill(String name)', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2401'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
