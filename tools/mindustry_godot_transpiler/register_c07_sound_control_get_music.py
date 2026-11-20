"""Register the Game SoundControl music getters (N2326).

SoundControl.getBossMusic() / getAmbientMusic() /
getDarkMusic() (SoundControl.java:270-284,
`protected Seq<Music> getBossMusic(){` / `if(state.rules
.darkMusic != null) return state.rules.darkMusic.map(
MusicContainer::get).removeAll(m -> m == null);` /
`return state.getPlanet() != null && state.getPlanet()
.darkMusic != null ? state.getPlanet().darkMusic :
bossMusic;` / `protected Seq<Music> getAmbientMusic(){` /
`if(state.rules.ambientMusic != null) return state
.rules.ambientMusic.map(MusicContainer::get).removeAll(
m -> m == null);` / `return state.getPlanet() != null
&& state.getPlanet().ambientMusic != null ? state
.getPlanet().ambientMusic : ambientMusic;` / `protected
Seq<Music> getDarkMusic(){` / `return state.getPlanet()
!= null && state.getPlanet().darkMusic != null ? state
.getPlanet().darkMusic : darkMusic;`) are the three
music-list getters playRandom() reads (SoundControl.
java:258-262, `playOnce(getBossMusic().random(
lastRandomPlayed));` / `playOnce(getDarkMusic().random(
lastRandomPlayed));` / `playOnce(getAmbientMusic().
random(lastRandomPlayed));`). Each is one pure function
on SourceSoundControlState.gd next to the N2299
shouldPlay / isPlaying, N2306 alwaysPlayMusic and
N2315 isDark gates. NO audio playback in this slice
(playback belongs to updateLoops, N2304, held waiting
for B).

RED decisions (resolved at RED): (1) Three pure
functions, one per getter, following the per-method
precedent of this file -- no merged helper, so each
getter keeps its own ledger entry, symbols and
contract. (2) QUIRK, ported verbatim, NOT "fixed":
boss and dark read the SAME `state.rules.darkMusic` /
planet `darkMusic` in the rules / planet branch (boss
has no field of its own there); only the fallback
differs -- `bossMusic` for boss, `darkMusic` for dark.
The shared rules line (`if(state.rules.darkMusic !=
null) return state.rules.darkMusic.map(MusicContainer
::get).removeAll(m -> m == null);`) is byte-identical
for boss (:271) and dark (:281), so it appears once
in EXACT_EXPRS and covers both. (3) Music arrives as
its name String (the N2287 precedent: the sound itself
is its name String; MusicContainer carries a `name`,
MusicContainer.java:9). The `MusicContainer::get`
resolution (MusicContainer.java:18-24, lazy
`SoundControl.findMusic(name)`, null when the asset is
not found) is folded into the caller param -- the
container accessor chain is NOT ported in this slice
(the N2315 precedent for accessor chains) -- while
the `.removeAll(m -> m == null)` filter IS ported: the
function builds a fresh Array of the non-null names,
in order, and never mutates its inputs. (4) The null
branches arrive as explicit bool `has_*` params (the
N2306 precedent -- GDScript typed Array params cannot
take null, proven by the first proof run: `Cannot pass
a value of type "null" as "Array"`): has_rules_dark_
music is `state.rules.darkMusic != null` and
has_planet_dark_music is `state.getPlanet() != null &&
state.getPlanet().darkMusic != null`; a seq param is
only read when its flag is true, and an unset seq is
passed as an empty Array. The field fallbacks
(`bossMusic` / `ambientMusic` / `darkMusic`,
SoundControl.java:23-27, all init `Seq.with()`) are
never null. The planet / fallback branches return the
seq as-is, matching Java aliasing.
(5) playRandom() / playOnce() / update() stay OUT of
scope -- they call these getters but are separate
slices; updateLoops() is N2304, held. Three new
result symbols. Slice source: SoundControl.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_sound_control_is_dark import DEFERRED as N2315_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
SOUND_CONTROL = 'core/src/mindustry/audio/SoundControl.java'
PROOF = '/root/C07SoundControlGetMusicProof'
BOSS_MUSIC_OWNER = 'SourceSoundControlState.source_sound_control_get_boss_music_state'
AMBIENT_MUSIC_OWNER = 'SourceSoundControlState.source_sound_control_get_ambient_music_state'
DARK_MUSIC_OWNER = 'SourceSoundControlState.source_sound_control_get_dark_music_state'
TESTS = ['test_c07_sound_control_get_music_registration', 'test_all_c07_sound_control_get_music_input_evidence_is_exact', 'test_sound_control_get_music_state', 'test_reference_graph_and_actual_c07_sound_control_get_music']
# The 1 slice source the N2326 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    SOUND_CONTROL,
]
EXACT_EXPRS = [
    'protected Seq<Music> getBossMusic(){',
    # Byte-identical for boss (:271) and dark (:281) -- one
    # entry covers both; only the fallback differs.
    'if(state.rules.darkMusic != null) return state.rules.darkMusic.map(MusicContainer::get).removeAll(m -> m == null);',
    'return state.getPlanet() != null && state.getPlanet().darkMusic != null ? state.getPlanet().darkMusic : bossMusic;',
    'protected Seq<Music> getAmbientMusic(){',
    'if(state.rules.ambientMusic != null) return state.rules.ambientMusic.map(MusicContainer::get).removeAll(m -> m == null);',
    'return state.getPlanet() != null && state.getPlanet().ambientMusic != null ? state.getPlanet().ambientMusic : ambientMusic;',
    'protected Seq<Music> getDarkMusic(){',
    'return state.getPlanet() != null && state.getPlanet().darkMusic != null ? state.getPlanet().darkMusic : darkMusic;',
    'playOnce(getBossMusic().random(lastRandomPlayed));',
    'playOnce(getDarkMusic().random(lastRandomPlayed));',
    'playOnce(getAmbientMusic().random(lastRandomPlayed));',
]

# DEFERRED is carried from the N2315 register script via import --
# never retyped. All N2315 entries are carried verbatim (the
# N2306 chain, the B/C notes, and N2315's own Windows proof
# debt -- none of them is resolved by this slice). One entry
# is added: N2326's Windows proof debt.
DEFERRED = list(N2315_DEFERRED) + [
    'SoundControl.getBossMusic()/getAmbientMusic()/getDarkMusic() Windows Godot proof -- debt in GOAL.md section 5, same as N2287/N2299/N2306/N2315: the N2326 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=SOUND_CONTROL, **extra):
        return backed(typ, source, expr, rule, **extra)

    rules_dark_music = a('Array', 'state.rules.darkMusic', 'The rules dark-music list (SoundControl.java:271/281, `state.rules.darkMusic`; Rules.java:171, `@Nullable Seq<MusicContainer> darkMusic`): arrives as an explicit Array param of already-resolved music names (String or null -- the MusicContainer::get resolution, MusicContainer.java:18-24, is folded into the caller param, NOT ported here). Only read when has_rules_dark_music is true.')
    planet_dark_music = a('Array', 'state.getPlanet().darkMusic', 'The planet dark-music list (SoundControl.java:272/282, `state.getPlanet().darkMusic`; Planet.java:147, `@Nullable Seq<Music> darkMusic`): arrives as an explicit Array param. Only read when has_planet_dark_music is true.')
    boss_music_inputs = {
        'has_rules_dark_music': a('bool', 'state.rules.darkMusic != null', 'Whether the rules dark-music list is set (SoundControl.java:271, `state.rules.darkMusic != null`): arrives as an explicit bool param -- the null check is folded into this param (the N2306 precedent; GDScript typed Array params cannot take null).'),
        'rules_dark_music': rules_dark_music,
        'has_planet_dark_music': a('bool', 'state.getPlanet() != null && state.getPlanet().darkMusic != null', 'Whether the planet dark-music list is set (SoundControl.java:272, `state.getPlanet() != null && state.getPlanet().darkMusic != null`): arrives as an explicit bool param -- the planet-null and list-null checks are folded into this param (the N2306 precedent).'),
        'planet_dark_music': planet_dark_music,
        'boss_music': a('Array', 'bossMusic', 'The field fallback (SoundControl.java:272, `bossMusic`; SoundControl.java:27, `public Seq<Music> bossMusic = Seq.with();`): arrives as an explicit Array param, never null. QUIRK: boss reads the SHARED rules/planet darkMusic in the branches above -- it has no field of its own there -- and only the fallback is its own.'),
    }
    boss_music_outputs = {
        'boss_music': a('Array', 'protected Seq<Music> getBossMusic(){', 'The boss music list (SoundControl.java:270-273): the rules list with nulls removed when rules.darkMusic is set, else the planet darkMusic when set, else the bossMusic field. The caller picks a random track from it in playRandom() (SoundControl.java:258, `playOnce(getBossMusic().random(lastRandomPlayed));`).'),
    }
    ambient_music_inputs = {
        'has_rules_ambient_music': a('bool', 'state.rules.ambientMusic != null', 'Whether the rules ambient-music list is set (SoundControl.java:276, `state.rules.ambientMusic != null`): arrives as an explicit bool param -- the null check is folded into this param (the N2306 precedent; GDScript typed Array params cannot take null).'),
        'rules_ambient_music': a('Array', 'state.rules.ambientMusic', 'The rules ambient-music list (SoundControl.java:276, `state.rules.ambientMusic`; Rules.java:169, `@Nullable Seq<MusicContainer> ambientMusic`): arrives as an explicit Array param of already-resolved music names (String or null -- the MusicContainer::get resolution is folded into the caller param, NOT ported here). Only read when has_rules_ambient_music is true.'),
        'has_planet_ambient_music': a('bool', 'state.getPlanet() != null && state.getPlanet().ambientMusic != null', 'Whether the planet ambient-music list is set (SoundControl.java:277, `state.getPlanet() != null && state.getPlanet().ambientMusic != null`): arrives as an explicit bool param -- the planet-null and list-null checks are folded into this param (the N2306 precedent).'),
        'planet_ambient_music': a('Array', 'state.getPlanet().ambientMusic', 'The planet ambient-music list (SoundControl.java:277, `state.getPlanet().ambientMusic`; Planet.java:145, `@Nullable Seq<Music> ambientMusic`): arrives as an explicit Array param. Only read when has_planet_ambient_music is true.'),
        'ambient_music': a('Array', 'ambientMusic', 'The field fallback (SoundControl.java:277, `ambientMusic`; SoundControl.java:23, `public Seq<Music> ambientMusic = Seq.with();`): arrives as an explicit Array param, never null.'),
    }
    ambient_music_outputs = {
        'ambient_music': a('Array', 'protected Seq<Music> getAmbientMusic(){', 'The ambient music list (SoundControl.java:275-278): the rules list with nulls removed when rules.ambientMusic is set, else the planet ambientMusic when set, else the ambientMusic field. The caller picks a random track from it in playRandom() (SoundControl.java:262, `playOnce(getAmbientMusic().random(lastRandomPlayed));`).'),
    }
    dark_music_inputs = {
        'has_rules_dark_music': a('bool', 'state.rules.darkMusic != null', 'Whether the rules dark-music list is set (SoundControl.java:281, `state.rules.darkMusic != null`): arrives as an explicit bool param -- the null check is folded into this param (the N2306 precedent; GDScript typed Array params cannot take null). QUIRK: this is the SAME list boss reads in its rules branch -- ported verbatim, NOT "fixed".'),
        'rules_dark_music': a('Array', 'state.rules.darkMusic', 'The rules dark-music list (SoundControl.java:281, `state.rules.darkMusic`; Rules.java:171, `@Nullable Seq<MusicContainer> darkMusic`): arrives as an explicit Array param of already-resolved music names (String or null -- the MusicContainer::get resolution, MusicContainer.java:18-24, is folded into the caller param, NOT ported here). Only read when has_rules_dark_music is true.'),
        'has_planet_dark_music': a('bool', 'state.getPlanet() != null && state.getPlanet().darkMusic != null', 'Whether the planet dark-music list is set (SoundControl.java:282, `state.getPlanet() != null && state.getPlanet().darkMusic != null`): arrives as an explicit bool param -- the planet-null and list-null checks are folded into this param (the N2306 precedent).'),
        'planet_dark_music': a('Array', 'state.getPlanet().darkMusic', 'The planet dark-music list (SoundControl.java:282, `state.getPlanet().darkMusic`; Planet.java:147, `@Nullable Seq<Music> darkMusic`): arrives as an explicit Array param. Only read when has_planet_dark_music is true.'),
        'dark_music': a('Array', 'darkMusic', 'The field fallback (SoundControl.java:282, `darkMusic`; SoundControl.java:25, `public Seq<Music> darkMusic = Seq.with();`): arrives as an explicit Array param, never null. QUIRK: only this fallback differs from boss -- the rules/planet branches are shared.'),
    }
    dark_music_outputs = {
        'dark_music': a('Array', 'protected Seq<Music> getDarkMusic(){', 'The dark music list (SoundControl.java:280-283): the rules list with nulls removed when rules.darkMusic is set, else the planet darkMusic when set, else the darkMusic field. The caller picks a random track from it in playRandom() (SoundControl.java:260, `playOnce(getDarkMusic().random(lastRandomPlayed));`).'),
    }
    return (boss_music_inputs, boss_music_outputs), (ambient_music_inputs, ambient_music_outputs), (dark_music_inputs, dark_music_outputs)


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
    (boss_music_inputs, boss_music_outputs), (ambient_music_inputs, ambient_music_outputs), (dark_music_inputs, dark_music_outputs) = definitions()

    entries = [
        ('N2326', BOSS_MUSIC_OWNER, 'source_sound_control_get_boss_music_state', SOUND_CONTROL, 'mindustry.audio.SoundControl', 'SoundControl.getBossMusic()', boss_music_inputs, boss_music_outputs, True, 'Dictionary'),
        ('N2326', AMBIENT_MUSIC_OWNER, 'source_sound_control_get_ambient_music_state', SOUND_CONTROL, 'mindustry.audio.SoundControl', 'SoundControl.getAmbientMusic()', ambient_music_inputs, ambient_music_outputs, True, 'Dictionary'),
        ('N2326', DARK_MUSIC_OWNER, 'source_sound_control_get_dark_music_state', SOUND_CONTROL, 'mindustry.audio.SoundControl', 'SoundControl.getDarkMusic()', dark_music_inputs, dark_music_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed SoundControl music getter state from SoundControl.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed SoundControl music getter state from SoundControl.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2326'] = [
        'source_sound_control_get_boss_music_state_result.boss_music',
        'source_sound_control_get_ambient_music_state_result.ambient_music',
        'source_sound_control_get_dark_music_state_result.dark_music',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2326', dict(status='done', java_source=SOUND_CONTROL, java_class='mindustry.audio.SoundControl', java_method='SoundControl.getBossMusic()/getAmbientMusic()/getDarkMusic()', godot_owner=BOSS_MUSIC_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2326'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
