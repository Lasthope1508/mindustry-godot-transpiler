"""Register the Game SoundControl.reload() (N2339).

SoundControl.reload() (SoundControl.java:75-91,
`protected void reload(){` / `current = null;` /
`fade = 0f;` / `ambientMusic = Seq.with(Musics.game1,
Musics.game3, Musics.game6, Musics.game8, Musics.game9,
Musics.fine);` / `darkMusic = Seq.with(Musics.game2,
Musics.game5, Musics.game7, Musics.game4);` /
`bossMusic = Seq.with(Musics.boss1, Musics.boss2,
Musics.game2, Musics.game5);` / `for(var sound :
Core.assets.getAll(Sound.class, new Seq<>())){` /
`var file = Fi.get(Core.assets.getAssetFileName(sound));`
/ `if(file.parent().name().equals("ui")){` /
`sound.setBus(uiBus);` / `Events.fire(new
MusicRegisterEvent());` -- reload rebuilds the three
music lists from the Musics fields, assigns the uiBus
to every Sound asset whose file sits in the "ui"
folder, and fires a MusicRegisterEvent -- is one pure
static function on SourceSoundControlState.gd next to
the N2299 shouldPlay / isPlaying, N2306
alwaysPlayMusic, N2315 isDark, N2326 music getters,
N2331 findMusic and N2336 play/silence/keepSilent.
reload() is the producer of the three lists the N2326
getters read -- the getters are consumers, reload
writes the lists, so no getter is re-ported here and
reload does not wait for them. NO audio playback in
this slice (playback belongs to updateLoops, N2304,
held waiting for B); the setBus calls are returned as
bus-assignment state, never executed.

RED decisions (resolved at RED): (1) One slice entry
for the one method, following the N2336 precedent
(one ledger entry per method group, one function per
method). (2) current / fade arrive as explicit params
and are carried out reset (null / 0) -- the old
values are overwritten unconditionally, exactly as
Java ignores them (the keepSilent precedent, N2336);
has_current folds the null check (the N2306
precedent -- GDScript typed String params cannot take
null). (3) The asset enumeration (Core.assets.getAll)
and file-name resolution (Fi.get(getAssetFileName) +
file.parent().name()) arrive folded into one explicit
Dictionary param (sound name -> parent folder name);
the `.equals("ui")` check IS ported, case-sensitive,
in order. (4) Music arrives as its name String (the
N2287 precedent); the Musics field names are the
asset names (core/assets/music/*.ogg in the upstream
checkout). (5) Events.fire(new MusicRegisterEvent())
is evidence only -- the event system is NOT ported.
(6) The caller (Events.on(ClientLoadEvent, e ->
reload())) is NOT ported here. Six new result
symbols. Slice source: SoundControl.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_sound_control_play_silence import DEFERRED as N2336_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
SOUND_CONTROL = 'core/src/mindustry/audio/SoundControl.java'
PROOF = '/root/C07SoundControlReloadProof'
RELOAD_OWNER = 'SourceSoundControlState.source_sound_control_reload_state'
TESTS = ['test_c07_sound_control_reload_registration', 'test_all_c07_sound_control_reload_input_evidence_is_exact', 'test_sound_control_reload_state', 'test_reference_graph_and_actual_c07_sound_control_reload']
# The 1 slice source the N2339 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    SOUND_CONTROL,
]
EXACT_EXPRS = [
    'protected void reload(){',
    'current = null;',
    'fade = 0f;',
    'ambientMusic = Seq.with(Musics.game1, Musics.game3, Musics.game6, Musics.game8, Musics.game9, Musics.fine);',
    'darkMusic = Seq.with(Musics.game2, Musics.game5, Musics.game7, Musics.game4);',
    'bossMusic = Seq.with(Musics.boss1, Musics.boss2, Musics.game2, Musics.game5);',
    'for(var sound : Core.assets.getAll(Sound.class, new Seq<>())){',
    'var file = Fi.get(Core.assets.getAssetFileName(sound));',
    'if(file.parent().name().equals("ui")){',
    'sound.setBus(uiBus);',
    'Events.fire(new MusicRegisterEvent());',
    'protected @Nullable Music current;',
    'protected float fade;',
    'public Seq<Music> ambientMusic = Seq.with();',
    'public Seq<Music> darkMusic = Seq.with();',
    'public Seq<Music> bossMusic = Seq.with();',
    'public AudioBus uiBus = new AudioBus();',
]

# DEFERRED is carried from the N2336 register script via import --
# never retyped. All N2336 entries are carried verbatim (the
# N2326 chain, the B/C notes, and N2336's own Windows proof
# debt -- none of them is resolved by this slice). One entry
# is added: N2339's Windows proof debt.
DEFERRED = list(N2336_DEFERRED) + [
    'SoundControl.reload Windows Godot proof -- debt in GOAL.md section 5, same as N2287/N2299/N2306/N2315/N2326/N2331/N2336: the N2339 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=SOUND_CONTROL, **extra):
        return backed(typ, source, expr, rule, **extra)

    reload_inputs = {
        'has_current': a('bool', 'protected @Nullable Music current;', 'Whether a track is currently playing (SoundControl.java:34, `protected @Nullable Music current;`): arrives as an explicit bool param -- the null check is folded into this param (the N2306 precedent). The old value is ignored: reload() overwrites current unconditionally.'),
        'current': a('String', 'protected @Nullable Music current;', 'The currently playing track (SoundControl.java:34, `protected @Nullable Music current;`): arrives as an explicit String param, its name (the N2287 precedent); an unset current is passed as "" with has_current false and is never read -- reload() resets it to null whatever it was.'),
        'fade': a('float', 'protected float fade;', 'The fade level (SoundControl.java:35, `protected float fade;`): arrives as an explicit float param and is carried out reset to 0 -- the old value is ignored, exactly as Java overwrites it.'),
        'sound_parents': a('Dictionary', 'for(var sound : Core.assets.getAll(Sound.class, new Seq<>())){', 'Every loaded Sound asset with its file parent folder (SoundControl.java:84-86, `for(var sound : Core.assets.getAll(Sound.class, new Seq<>())){` / `var file = Fi.get(Core.assets.getAssetFileName(sound));` / `if(file.parent().name().equals("ui")){`): arrives as an explicit Dictionary param, sound name -> parent folder name -- the asset enumeration and file-name resolution are folded into the caller param (the findMusic precedent), while the `equals("ui")` check IS ported inside the function.'),
    }
    reload_outputs = {
        'current': a('String', 'current = null;', 'The track playing after reload (SoundControl.java:76, `current = null;`): always null -- reload() clears the current track, whatever was playing.'),
        'fade': a('float', 'fade = 0f;', 'The fade level after reload (SoundControl.java:77, `fade = 0f;`): always 0 -- reload() zeroes the fade, whatever it was.'),
        'ambient_music': a('Array', 'ambientMusic = Seq.with(Musics.game1, Musics.game3, Musics.game6, Musics.game8, Musics.game9, Musics.fine);', 'The rebuilt ambient music list (SoundControl.java:78, `ambientMusic = Seq.with(Musics.game1, Musics.game3, Musics.game6, Musics.game8, Musics.game9, Musics.fine);`): the six track names in exactly this order -- the producer side of the list the N2326 getAmbientMusic getter reads.'),
        'dark_music': a('Array', 'darkMusic = Seq.with(Musics.game2, Musics.game5, Musics.game7, Musics.game4);', 'The rebuilt dark music list (SoundControl.java:79, `darkMusic = Seq.with(Musics.game2, Musics.game5, Musics.game7, Musics.game4);`): the four track names in exactly this order -- the producer side of the list the N2326 getDarkMusic getter reads.'),
        'boss_music': a('Array', 'bossMusic = Seq.with(Musics.boss1, Musics.boss2, Musics.game2, Musics.game5);', 'The rebuilt boss music list (SoundControl.java:80, `bossMusic = Seq.with(Musics.boss1, Musics.boss2, Musics.game2, Musics.game5);`): the four track names in exactly this order -- the producer side of the list the N2326 getBossMusic getter reads.'),
        'ui_bus_sounds': a('Array', 'sound.setBus(uiBus);', 'The sounds assigned to the uiBus (SoundControl.java:87, `sound.setBus(uiBus);`): every sound whose parent folder is "ui", in registry order -- the bus-assignment state the driver applies; this slice NEVER touches audio itself, playback belongs to updateLoops (N2304, held waiting for B).'),
    }
    return (reload_inputs, reload_outputs)


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
    (reload_inputs, reload_outputs) = definitions()

    entries = [
        ('N2339', RELOAD_OWNER, 'source_sound_control_reload_state', SOUND_CONTROL, 'mindustry.audio.SoundControl', 'SoundControl.reload()', reload_inputs, reload_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed SoundControl reload state from SoundControl.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed SoundControl reload state from SoundControl.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2339'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2339', dict(status='done', java_source=SOUND_CONTROL, java_class='mindustry.audio.SoundControl', java_method='SoundControl.reload()', godot_owner=RELOAD_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2339'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
