"""Register the Game SoundControl() default constructor (N2414).

SoundControl() (SoundControl.java:45-68,
`public SoundControl(){` -- the ctor registers three
event subscriptions (ClientLoadEvent -> reload,
WaveEvent -> the delayed boss/chance leg, ResetEvent
-> lastPlayed + sound-bus stop/play) and calls
setupFilters() once) is one pure static function on
SourceSoundControlState.gd next to the N2411 update
driver tick. NO audio playback in this slice
(playback belongs to updateLoops, N2304, held
waiting for B); the bus and playback calls are
returned as command state, never executed.

RED decisions (resolved at RED): (1) One slice
entry for the one method, following the N2411
driver-tick precedent (one ledger entry per method,
one function per method) -- the ctor keeps its own
function and delegates to the pure static funcs in
the same file, it does NOT re-port them. (2) SCOPE
CORRECTION vs the draft (batch 30 §1): the draft
listed 12 lines as 0-hit, probed BEFORE N2411
merged. N2411 (SoundControl.update(),
SoundControl.java:128-195) already owns
`setupFilters();` (:149), `lastPlayed =
Time.millis();` (:188), `Core.audio.soundBus.stop();`
(:152) and `Core.audio.soundBus.play();` (:148/:156)
-- the same lines repeat in update() -- so this
slice registers only the 8 lines that are 0-hit in
BOTH ledgers at base 1571952f. The ctor drives the
other four through the N2349 delegate and the
reset-leg commands, never re-registering them.
`playOnce(getBossMusic().random(lastRandomPlayed));`
(:53, N2326/N2347) and `playRandom();` (:55, N2306)
are likewise NOT re-registered -- the ctor drives
them through the play_boss_once / play_random
Callables. (3) The 3 Events.on subscriptions are
ported as explicit Callable params (the main-thread
decision for batch 30 slot 1, following the N2377
drawer-Callable + N2411 driver-tick precedent):
reload_handler (zero-arg, N2339 reload), play_boss_once
(the N2345 playOnce signature -- the caller owns
the boss-music pick, getBossMusic().random
(lastRandomPlayed)), play_random (the N2347
signature -- the caller owns the boss / dark /
ambient lists and the RNG draw). The ctor never
calls the engine itself. (4) The wave leg is
evaluated once with explicit outcomes: the delay
`Mathf.random(8f, 15f) * 60f` arrives as
wave_delay_ticks (a Time.run ticks delay, 480-900
ticks = 8-15s at 60fps); the boss check
(`state.rules.spawns.contains(...)`, :50) arrives
as wave_is_boss -- `state.wave - 2` and the spawn
lookup stay with the caller; the chance roll
(`Mathf.chance(musicWaveChance)`, :54) arrives as
wave_chance_roll (the N2315 chance-roll precedent),
and musicWaveChance (SoundControl.java:20, 0.46f)
arrives as an explicit float param. (5) The reset
leg writes lastPlayed from the explicit now_millis
param (Time.millis() stays with the caller) and
records the sound-bus stop/play as commands.
(6) setupFilters (N2349) is called directly -- its
commands come first in the commands array because
they run at construction time. (7) Music arrives
as its name String (the N2287 precedent);
has_boss_music folds the null check on the picked
boss track (the N2306 precedent). (8) Fourteen
new result symbols (client_load_event,
client_load_subscribed, reload_called, wave_event,
wave_subscribed, wave_delay_ticks, music_wave_chance,
wave_action, wave_music, reset_event,
reset_subscribed, last_played, setup_filters_called,
commands). Slice source: SoundControl.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_sound_control_update import DEFERRED as N2411_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
SOUND_CONTROL = 'core/src/mindustry/audio/SoundControl.java'
PROOF = '/root/C07SoundControlDefaultConstructorProof'
DEFAULT_CONSTRUCTOR_OWNER = 'SourceSoundControlState.source_sound_control_default_constructor_state'
TESTS = ['test_c07_sound_control_default_constructor_registration', 'test_all_c07_sound_control_default_constructor_input_evidence_is_exact', 'test_sound_control_default_constructor_state', 'test_reference_graph_and_actual_c07_sound_control_default_constructor']
# The 1 slice source the N2414 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    SOUND_CONTROL,
]
# The 8 registered lines of SoundControl() (SoundControl.java:45-68)
# -- only the lines 0-hit in BOTH ledgers at base 1571952f (see the
# SCOPE CORRECTION in the module docstring: the draft's other 4
# lines are N2411-owned since N2411 merged).
EXACT_EXPRS = [
    'Events.on(ClientLoadEvent.class, e -> reload());',
    'Events.on(WaveEvent.class, e -> Time.run(Mathf.random(8f, 15f) * 60f, () -> {',
    'boolean boss = state.rules.spawns.contains(group -> group.getSpawned(state.wave - 2) > 0 && group.effect == StatusEffects.boss);',
    'if(boss){',
    '}else if(Mathf.chance(musicWaveChance)){',
    '}));',
    'Events.on(ResetEvent.class, e -> {',
    '});',
]

# DEFERRED is carried from the N2411 register script via import --
# never retyped. All N2411 entries are carried verbatim (the
# N2352 chain, the B/C notes, and N2411's own Windows proof
# debt -- none of them is resolved by this slice). One entry
# is added: N2414's Windows proof debt.
DEFERRED = list(N2411_DEFERRED) + [
    'SoundControl() default constructor Windows Godot proof -- debt in GOAL.md section 5, same as N2287/N2299/N2306/N2315/N2326/N2331/N2336/N2339/N2345/N2347/N2349/N2352/N2411: the N2414 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=SOUND_CONTROL, **extra):
        return backed(typ, source, expr, rule, **extra)

    default_constructor_inputs = {
        'reload_handler': a('Callable', 'Events.on(ClientLoadEvent.class, e -> reload());', 'The ClientLoadEvent handler (SoundControl.java:46, `Events.on(ClientLoadEvent.class, e -> reload());`): arrives as a zero-arg Callable -- reload() itself is N2339 and is NOT re-ported here; the ctor registers the handler and the model fires it once, recording reload_called.'),
        'wave_delay_ticks': a('float', 'Events.on(WaveEvent.class, e -> Time.run(Mathf.random(8f, 15f) * 60f, () -> {', 'The Time.run delay for the WaveEvent leg (SoundControl.java:49, `Time.run(Mathf.random(8f, 15f) * 60f, () -> {`): 480-900 ticks (8-15s at 60fps); arrives as an explicit float param -- the RNG draw stays with the caller (the N2315 chance-roll precedent).'),
        'wave_is_boss': a('bool', 'boolean boss = state.rules.spawns.contains(group -> group.getSpawned(state.wave - 2) > 0 && group.effect == StatusEffects.boss);', 'Whether a boss spawned in the wave (SoundControl.java:50, `boolean boss = state.rules.spawns.contains(...)`): arrives as an explicit bool param -- the spawns lookup and `state.wave - 2` stay with the caller; selects the playOnce boss leg.'),
        'wave_chance_roll': a('bool', '}else if(Mathf.chance(musicWaveChance)){', 'Whether the per-wave chance roll hit (SoundControl.java:54, `}else if(Mathf.chance(musicWaveChance)){`): arrives as an explicit bool param -- the RNG OUTCOME (the N2315 chance-roll precedent), so this function never rolls RNG itself; selects the playRandom leg when there is no boss.'),
        'music_wave_chance': a('float', 'public float finTime = 120f, foutTime = 120f, musicInterval = 3f * Time.toMinutes, musicChance = 0.8f, musicWaveChance = 0.46f;', 'The musicWaveChance field (SoundControl.java:20, `musicWaveChance = 0.46f`): arrives as an explicit float param; the field itself is NOT re-registered -- only the chance-roll outcome drives the leg.'),
        'play_boss_once': a('Callable', 'playOnce(getBossMusic().random(lastRandomPlayed));', 'The playOnce boss leg (SoundControl.java:53, `playOnce(getBossMusic().random(lastRandomPlayed));`): arrives as a Callable with the N2345 playOnce signature (has_music, music, has_current, current, fade, has_last_random_played, last_random_played, should_play) -- the caller owns the boss-music pick, so the random draw stays with the caller.'),
        'play_random': a('Callable', 'playRandom();', 'The playRandom leg (SoundControl.java:55, `playRandom();`): arrives as a Callable with the N2347 playRandom signature (has_current, current, fade, has_last_random_played, last_random_played) -- the caller owns the boss / dark / ambient lists and the RNG draw, so the random pick stays with the caller.'),
        'filter': a('Variant', 'protected AudioFilter filter = new BiquadFilter(){{', 'The SoundControl filter (SoundControl.java:39, `protected AudioFilter filter = new BiquadFilter(){{ set(0, 500, 1); }};`): arrives as an explicit opaque Variant param -- the driver owns the live filter object (the N2287 precedent); passed through to the setupFilters delegate (N2349).'),
        'has_current': a('bool', 'if(current != null && !current.isPlaying()){', 'Whether a track is currently playing (SoundControl.java:133, `if(current != null && !current.isPlaying()){`): arrives as an explicit bool param -- the null check is folded into this param (the N2306 precedent); passed to the music delegates.'),
        'current': a('String', 'protected @Nullable Music current;', 'The currently playing track (SoundControl.java:34, `protected @Nullable Music current;`): arrives as an explicit String param, its name (the N2287 precedent); an unset current is passed as "" with has_current false and is never read.'),
        'fade': a('float', 'protected float fade;', 'The fade level (SoundControl.java:35, `protected float fade;`): arrives as an explicit float param; passed to the music delegates.'),
        'has_last_random_played': a('bool', 'protected Music lastRandomPlayed;', 'Whether a last random track is saved (SoundControl.java:31, `protected Music lastRandomPlayed;`): arrives as an explicit bool param -- the null check is folded into this param (the N2306 precedent); passed to the music delegates.'),
        'last_random_played': a('String', 'protected Music lastRandomPlayed;', 'The last random track played (SoundControl.java:31, `protected Music lastRandomPlayed;`): arrives as an explicit String param, its name (the N2287 precedent); passed to the music delegates.'),
        'should_play': a('bool', 'if(!shouldPlay()){', 'The shouldPlay() gate (SoundControl.java:304, `if(!shouldPlay()){` in play()): arrives as an explicit bool param -- the gate itself is N2299 (`return Core.settings.getInt("musicvol") > 0;`) and is NOT re-ported here; passed to the playOnce delegate.'),
        'has_boss_music': a('bool', 'playOnce(getBossMusic().random(lastRandomPlayed));', 'Whether a boss track was picked (SoundControl.java:53, `playOnce(getBossMusic().random(lastRandomPlayed));`): arrives as an explicit bool param -- the null check on the picked track is folded into this param (the N2306 precedent); only read when the wave is a boss wave.'),
        'boss_music': a('String', 'playOnce(getBossMusic().random(lastRandomPlayed));', 'The picked boss track (SoundControl.java:53, `playOnce(getBossMusic().random(lastRandomPlayed));`): arrives as an explicit String param, its name (the N2287 precedent); only read when the wave is a boss wave.'),
        'now_millis': a('int', 'lastPlayed = Time.millis();', 'The current time in millis (SoundControl.java:61, `lastPlayed = Time.millis();` in the ResetEvent leg): arrives as an explicit int param -- Time.millis() stays with the caller; the reset leg writes it to last_played.'),
    }
    default_constructor_outputs = {
        'client_load_event': a('String', 'Events.on(ClientLoadEvent.class, e -> reload());', 'The event the first subscription listens to (SoundControl.java:46, `Events.on(ClientLoadEvent.class, e -> reload());`): the literal "ClientLoadEvent" -- the subscription is registered, never fired by the ctor itself.'),
        'client_load_subscribed': a('bool', 'Events.on(ClientLoadEvent.class, e -> reload());', 'Whether the ClientLoadEvent subscription is registered (SoundControl.java:46): always true -- the ctor unconditionally registers it.'),
        'reload_called': a('bool', 'Events.on(ClientLoadEvent.class, e -> reload());', 'Whether the reload handler fired in the model (SoundControl.java:46): always true -- the model fires each registered handler once.'),
        'wave_event': a('String', 'Events.on(WaveEvent.class, e -> Time.run(Mathf.random(8f, 15f) * 60f, () -> {', 'The event the second subscription listens to (SoundControl.java:49, `Events.on(WaveEvent.class, e -> Time.run(...`): the literal "WaveEvent".'),
        'wave_subscribed': a('bool', 'Events.on(WaveEvent.class, e -> Time.run(Mathf.random(8f, 15f) * 60f, () -> {', 'Whether the WaveEvent subscription is registered (SoundControl.java:49): always true -- the ctor unconditionally registers it.'),
        'wave_delay_ticks': a('float', 'Events.on(WaveEvent.class, e -> Time.run(Mathf.random(8f, 15f) * 60f, () -> {', 'The Time.run delay carried in the wave subscription (SoundControl.java:49, `Mathf.random(8f, 15f) * 60f`): the wave_delay_ticks param, carried out again -- 480-900 ticks.'),
        'music_wave_chance': a('float', 'public float finTime = 120f, foutTime = 120f, musicInterval = 3f * Time.toMinutes, musicChance = 0.8f, musicWaveChance = 0.46f;', 'The musicWaveChance field carried in the wave subscription (SoundControl.java:20, `musicWaveChance = 0.46f`): the param, carried out again.'),
        'wave_action': a('String', 'if(boss){', 'Which wave leg fired (SoundControl.java:52, `if(boss){` / :54 `}else if(Mathf.chance(musicWaveChance)){`): "play_boss_once" when the wave is a boss wave, "play_random" when it is not and the chance roll hit, "none" otherwise.'),
        'wave_music': a('String', 'playOnce(getBossMusic().random(lastRandomPlayed));', 'The track the wave leg started (SoundControl.java:53, `playOnce(getBossMusic().random(lastRandomPlayed));`): the picked boss track when the boss leg fired, the playRandom pick when the random leg fired, "" when no leg fired.'),
        'reset_event': a('String', 'Events.on(ResetEvent.class, e -> {', 'The event the third subscription listens to (SoundControl.java:60, `Events.on(ResetEvent.class, e -> {`): the literal "ResetEvent".'),
        'reset_subscribed': a('bool', 'Events.on(ResetEvent.class, e -> {', 'Whether the ResetEvent subscription is registered (SoundControl.java:60): always true -- the ctor unconditionally registers it.'),
        'last_played': a('int', 'lastPlayed = Time.millis();', 'When the last track was started, in millis (SoundControl.java:61, `lastPlayed = Time.millis();` in the ResetEvent leg): now_millis when the reset leg fired in the model.'),
        'setup_filters_called': a('bool', 'setupFilters();', 'Whether setupFilters() ran (SoundControl.java:58, `setupFilters();`): always true -- the ctor calls it once, directly through the N2349 delegate.'),
        'commands': a('Array', 'Core.audio.soundBus.stop();', 'The playback commands this call issues, in ctor order (SoundControl.java:58 setupFilters / :64 soundBus.stop / :65 soundBus.play, plus the delegate commands from playOnce / playRandom): the setupFilters commands first (they run at construction time), then the fired wave-leg commands, then the reset-leg sound_bus_stop / sound_bus_play. One Dictionary per call (`action`, plus `slot`/`param`/`value` for the filter, `track` for track commands). The driver applies them -- this slice NEVER plays audio itself; playback belongs to updateLoops (N2304, held waiting for B).'),
    }
    return (default_constructor_inputs, default_constructor_outputs)


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
    (default_constructor_inputs, default_constructor_outputs) = definitions()

    entries = [
        ('N2414', DEFAULT_CONSTRUCTOR_OWNER, 'source_sound_control_default_constructor_state', SOUND_CONTROL, 'mindustry.audio.SoundControl', 'SoundControl()', default_constructor_inputs, default_constructor_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed SoundControl default constructor state from SoundControl.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed SoundControl default constructor state from SoundControl.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2414'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2414', dict(status='done', java_source=SOUND_CONTROL, java_class='mindustry.audio.SoundControl', java_method='SoundControl()', godot_owner=DEFAULT_CONSTRUCTOR_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2414'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
