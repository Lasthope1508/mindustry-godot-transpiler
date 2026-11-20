"""Register the Game SoundControl.findMusic(String) lookup (N2331).

SoundControl.findMusic(String) (SoundControl.java:387-395,
`public static @Nullable Music findMusic(String name){` /
`if(name == null) return null;` / `Music cached =
Core.assets.getOrNull(name, Music.class);` / `if(cached ==
null) cached = Core.assets.getOrNull(name + ".ogg",
Music.class);` / `if(cached == null) cached =
Core.assets.getOrNull(name + ".mp3", Music.class);` /
`if(cached == null) cached = Core.assets.getOrNull(
"music/" + name + ".ogg", Music.class);` / `if(cached ==
null) cached = Core.assets.getOrNull("music/" + name +
".mp3", Music.class);` / `return cached;`) is the static
music lookup MusicContainer.get() reads
(MusicContainer.java:18-24, lazy `SoundControl.findMusic(
name)`, null when the asset is not found). It is one pure
static function on SourceSoundControlState.gd next to the
N2299 shouldPlay / isPlaying, N2306 alwaysPlayMusic, N2315
isDark and N2326 music getters. NO audio playback in this
slice (playback belongs to updateLoops, N2304, held waiting
for B); NO audio is loaded -- findMusic only resolves a
name.

RED decisions (resolved at RED): (1) One pure static
function, following the per-method precedent of this file
-- no merged helper, so findMusic keeps its own ledger
entry, symbol and contract. (2) The five-branch order is
kept exactly, NOT "fixed": the `.ogg` branch runs before
`.mp3`, and the `music/` branches run after the plain
ones. (3) The Core.assets lookup arrives as an explicit
Dictionary param -- the asset registry, lookup key
(String) -> resolved asset name (String); a missing key
reads null, exactly `Core.assets.getOrNull(key,
Music.class)`. The returned value is the registry value
-- the resolved name -- not the lookup key. (4) Music
arrives as its resolved name String (the N2287 precedent:
the sound itself is its name String). (5) The null name
arrives as an explicit bool `has_name` param (the N2306
precedent -- GDScript typed String params cannot take
null): has_name is `name != null`, and an unset name is
passed as "" with has_name false. (6) findMusic does NOT
depend on the three N2326 music getters: it resolves one
name at a time and never reads a music list. (7)
playRandom() / playOnce() / update() stay OUT of scope --
they call findMusic through MusicContainer.get() but are
separate slices; updateLoops() is N2304, held. One new
result symbol. Slice source: SoundControl.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_sound_control_get_music import DEFERRED as N2326_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
SOUND_CONTROL = 'core/src/mindustry/audio/SoundControl.java'
PROOF = '/root/C07SoundControlFindMusicProof'
FIND_MUSIC_OWNER = 'SourceSoundControlState.source_sound_control_find_music_state'
TESTS = ['test_c07_sound_control_find_music_registration', 'test_all_c07_sound_control_find_music_input_evidence_is_exact', 'test_sound_control_find_music_state', 'test_reference_graph_and_actual_c07_sound_control_find_music']
# The 1 slice source the N2331 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    SOUND_CONTROL,
]
EXACT_EXPRS = [
    'public static @Nullable Music findMusic(String name){',
    'if(name == null) return null;',
    'Music cached = Core.assets.getOrNull(name, Music.class);',
    'if(cached == null) cached = Core.assets.getOrNull(name + ".ogg", Music.class);',
    'if(cached == null) cached = Core.assets.getOrNull(name + ".mp3", Music.class);',
    'if(cached == null) cached = Core.assets.getOrNull("music/" + name + ".ogg", Music.class);',
    'if(cached == null) cached = Core.assets.getOrNull("music/" + name + ".mp3", Music.class);',
    'return cached;',
]

# DEFERRED is carried from the N2326 register script via import --
# never retyped. All N2326 entries are carried verbatim (the
# N2315 chain, the B/C notes, and N2326's own Windows proof
# debt -- none of them is resolved by this slice). One entry
# is added: N2331's Windows proof debt.
DEFERRED = list(N2326_DEFERRED) + [
    'SoundControl.findMusic(String) Windows Godot proof -- debt in GOAL.md section 5, same as N2287/N2299/N2306/N2315/N2326: the N2331 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=SOUND_CONTROL, **extra):
        return backed(typ, source, expr, rule, **extra)

    find_music_inputs = {
        'has_name': a('bool', 'name == null', 'Whether the music name is set (SoundControl.java:388, `if(name == null) return null;`): arrives as an explicit bool param -- the null check is folded into this param (the N2306 precedent; GDScript typed String params cannot take null). A null name reads null at once, whatever name says.'),
        'name': a('String', 'public static @Nullable Music findMusic(String name){', 'The music name to resolve (SoundControl.java:387, `findMusic(String name)`): arrives as an explicit String param; an unset name is passed as "" with has_name false and is never read.'),
        'assets': a('Dictionary', 'Core.assets.getOrNull(name, Music.class)', 'The Core.assets registry (SoundControl.java:389-393, `Core.assets.getOrNull(...)` five times): arrives as an explicit Dictionary param, lookup key (String) -> resolved asset name (String); a missing key reads null, exactly getOrNull. NO audio is loaded in this slice -- the registry only maps names, it never plays or loads a file.'),
    }
    find_music_outputs = {
        'found_music': a('String', 'return cached;', 'The resolved music name (SoundControl.java:394, `return cached;`): the registry value of the first of the five branches that hits -- name, name + ".ogg", name + ".mp3", "music/" + name + ".ogg", "music/" + name + ".mp3" -- in exactly that order, or null when no branch hits (or the name itself is null). MusicContainer.get() reads it lazily (MusicContainer.java:18-24).'),
    }
    return (find_music_inputs, find_music_outputs)


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
    (find_music_inputs, find_music_outputs) = definitions()

    entries = [
        ('N2331', FIND_MUSIC_OWNER, 'source_sound_control_find_music_state', SOUND_CONTROL, 'mindustry.audio.SoundControl', 'SoundControl.findMusic(String)', find_music_inputs, find_music_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed SoundControl findMusic state from SoundControl.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed SoundControl findMusic state from SoundControl.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2331'] = [
        'source_sound_control_find_music_state_result.found_music',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2331', dict(status='done', java_source=SOUND_CONTROL, java_class='mindustry.audio.SoundControl', java_method='SoundControl.findMusic(String)', godot_owner=FIND_MUSIC_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2331'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
