"""Register the Game SoundControl.loop() accumulator (N2287).

SoundControl.loop() (SoundControl.java:93-117) owns all three
overloads in this one slice -- they are one method family and
the two small ones delegate to the 4-arg accumulator:
loop(Sound, float) (:93-97, headless guard + Core.camera.position),
loop(Sound, Position, float) (:99-101, pitch defaults 1f) and
loop(Sound, Position, float, float) (:103-117, the accumulator).
The accumulator takes the SoundData for the sound (`sounds.get
(sound, SoundData::new)`, :109) and adds to it: baseVol from
Sound.calcFalloff (Sound.java:151-157), vol = baseVol * volume,
volume += vol (clamped to [0, 1]), pitch += pitch * vol, total
+= baseVol, totalVolume += vol, sum += pos * baseVol. This is an
independent game slice, NOT ambient C: it only accumulates
numbers into SoundData (SoundControl.java:378-385) and does not
touch SoundControl.updateLoops() (N2264, held waiting for the
Windows driver tick B, N2260), nor depend on the RepairTurret
driver tick. NO audio playback in this slice (playback belongs
to updateLoops).

RED decisions (resolved at RED): (1) Three pure functions on
the new game state file (the N2259 precedent: a game-level slice
gets its own state file; PortGame.gd is main-thread-only) --
the 4-arg accumulator plus two thin delegating wrappers that
re-stamp their own owner on the delegated result. (2) Every live
value arrives as an explicit param: headless (the N2259 accessor
supplies it), camera position (Core.camera.position),
Core.audio falloff (Audio.java:13, 16000f) and the Sound falloff
offset (Sound.java:32, 0f); the previous SoundData is one
Dictionary arg, an empty prev being a fresh SoundData::new.
(3) calcFalloff is used as a helper, not re-ported as its own
slice: its formula is kept exactly -- dst2 is the squared camera
distance minus falloffOffset squared floored at 0, and the
one-arg Mathf.clamp is the [0, 1] clamp (Mathf.java:402-404,
`return Math.max(Math.min(value, 1f), 0f);`), never "fixed" into
a two-bound clamp. Its headless branch is subsumed by the loop
guard (:104 runs before :106), and the port's single headless
param covers both Vars.headless and Core.app.isHeadless() (both
derive from the same DisplayServer check, N2259 Option 1).
(4) Sounds.none is the string "none" (the N2222 precedent).
(5) soundID and curVolume are NOT written by loop() -- updateLoops
owns them -- so the accumulator carries them through unchanged;
they are result symbols of each overload all the same. 24 new
result symbols. Slice sources: SoundControl.java + Sound.java +
Audio.java + Vars.java + Mathf.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_game_headless import DEFERRED as N2259_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
SOUND_CONTROL = 'core/src/mindustry/audio/SoundControl.java'
SOUND = 'arc-core/src/arc/audio/Sound.java'
AUDIO = 'arc-core/src/arc/audio/Audio.java'
VARS = 'core/src/mindustry/Vars.java'
MATHF = 'arc-core/src/arc/math/Mathf.java'
PROOF = '/root/C07SoundControlLoopProof'
LOOP_OWNER = 'SourceSoundControlState.source_sound_control_loop_state'
POSITION_OWNER = 'SourceSoundControlState.source_sound_control_loop_position_state'
VOLUME_OWNER = 'SourceSoundControlState.source_sound_control_loop_volume_state'
TESTS = ['test_c07_sound_control_loop_registration', 'test_all_c07_sound_control_loop_input_evidence_is_exact', 'test_sound_control_loop_state', 'test_reference_graph_and_actual_c07_sound_control_loop']
# The 5 slice sources the N2287 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    SOUND_CONTROL,
    SOUND,
    AUDIO,
    VARS,
    MATHF,
]
EXACT_EXPRS = [
    'public void loop(Sound sound, float volume){',
    'if(Vars.headless) return;',
    'loop(sound, Core.camera.position, volume);',
    'public void loop(Sound sound, Position pos, float volume){',
    'loop(sound, pos, volume, 1f);',
    'public void loop(Sound sound, Position pos, float volume, float pitch){',
    'if(Vars.headless || sound == Sounds.none || volume <= 0.00001f) return;',
    'float baseVol = sound.calcFalloff(pos.getX(), pos.getY());',
    'float vol = baseVol * volume;',
    'SoundData data = sounds.get(sound, SoundData::new);',
    'data.volume += vol;',
    'data.pitch += pitch * vol;',
    'data.volume = Mathf.clamp(data.volume, 0f, 1f);',
    'data.total += baseVol;',
    'data.totalVolume += vol;',
    'data.sum.add(pos.getX() * baseVol, pos.getY() * baseVol);',
    'protected ObjectMap<Sound, SoundData> sounds = new ObjectMap<>();',
    'protected static class SoundData{',
    'float volume, pitch;',
    'float total;',
    'Vec2 sum = new Vec2();',
    'int soundID;',
    'float curVolume, totalVolume;',
    'public float calcFalloff(float x, float y){',
    'if(Core.app.isHeadless()) return 1f;',
    'float dst2 = Math.max(Mathf.dst2(x, y, Core.camera.position.x, Core.camera.position.y) - falloffOffset*falloffOffset, 0f);',
    'return Mathf.clamp(1f / (dst2 / Core.audio.falloff));',
    'public float falloff = 16000f;',
    'float falloffOffset = 0f;',
    'public static boolean headless;',
    '/** whether the game is running on a headless server */',
    'public static float clamp(float value){',
    'return Math.max(Math.min(value, 1f), 0f);',
    'public static float dst2(float x1, float y1, float x2, float y2){',
    'return xd * xd + yd * yd;',
]

# DEFERRED is carried from the N2259 register script via import --
# never retyped. All four N2259 entries are DROPPED here, not
# carried -- matched by their exact start, never by a loose
# substring (a loose 'Windows Godot proof' match would also drop
# the seven other slices' Windows-proof debts the chain carries):
# the B entry's "waits for A (N2259) to land" is resolved (A has
# landed; B itself is still Windows-line work, restated below
# with the N2287 accumulator it now feeds); the C entry is
# restated below with its renumbered number N2264 (N2259 still
# said N2243) and the SoundData the N2287 accumulator fills; the
# headless Windows-proof entry belongs to N2259, replaced by
# N2287's own; the PortGame headless-property entry is N2259-only.
# Four entries are added: the restated B, the restated C, the
# soundID/curVolume carry-through note, and N2287's Windows proof
# debt.
DEFERRED = [e for e in N2259_DEFERRED if not e.startswith('RepairTurret ambient-sound live-loop driver tick line') and not e.startswith('SoundControl.updateLoops aggregate mixer') and not e.startswith('Game headless-source Windows Godot proof') and not e.startswith('PortGame headless property')] + [
    'RepairTurret ambient-sound live-loop driver tick line (B, N2260) -- A (N2259) has landed; the driver calls the N2222 pure function with the headless value from SourceGameHeadlessState and feeds its sound/volume into the N2287 loop accumulator (SourceSoundControlState.source_sound_control_loop_state). B is Windows-line work, still waiting.',
    'SoundControl.updateLoops aggregate mixer (C, N2264) -- waits for B (N2260); it consumes the SoundData the N2287 accumulator fills (volume/pitch/total/totalVolume/sum) and owns playback; no audio playback in the port yet (0 AudioStreamPlayer hits), beamHeal.ogg exists.',
    'SoundData.soundID and SoundData.curVolume are written by updateLoops (C, N2264), not by loop() -- N2287 carries them through the accumulator unchanged.',
    'SoundControl.loop() Windows Godot proof -- debt in GOAL.md section 5, same as N2259: the N2287 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=SOUND_CONTROL, **extra):
        return backed(typ, source, expr, rule, **extra)

    loop_inputs = {
        'sound': a('String', 'public void loop(Sound sound, Position pos, float volume, float pitch){', 'The sound being looped (SoundControl.java:103): its name String; Sounds.none is the string "none" (the N2222 precedent) and the guard returns the previous SoundData unchanged for it.'),
        'pos_x': a('float', 'pos.getX()', 'The sound position x (SoundControl.java:106, `sound.calcFalloff(pos.getX(), pos.getY())`, and :115, the sum weighting): the Position the 4-arg overload loops at.'),
        'pos_y': a('float', 'pos.getY()', 'The sound position y (SoundControl.java:106, `sound.calcFalloff(pos.getX(), pos.getY())`, and :115, the sum weighting): the Position the 4-arg overload loops at.'),
        'volume': a('float', 'if(Vars.headless || sound == Sounds.none || volume <= 0.00001f) return;', 'The loop volume (SoundControl.java:104): at or below 0.00001f the guard returns the previous SoundData unchanged; otherwise vol = baseVol * volume (:107).'),
        'pitch': a('float', 'data.pitch += pitch * vol;', 'The loop pitch (SoundControl.java:111, `data.pitch += pitch * vol;`): weighted by vol, not by baseVol.'),
        'headless': a('bool', 'public static boolean headless;', 'Whether the game runs on a headless server (Vars.java:209, `public static boolean headless;`, default false): the N2259 accessor supplies it; a headless game returns the previous SoundData unchanged (SoundControl.java:104).', source=VARS),
        'camera_x': a('float', 'Core.camera.position.x', 'The camera (listener) position x (Sound.java:154, `Mathf.dst2(x, y, Core.camera.position.x, Core.camera.position.y)`): calcFalloff measures the squared distance from the sound position to here.', source=SOUND),
        'camera_y': a('float', 'Core.camera.position.y', 'The camera (listener) position y (Sound.java:154): calcFalloff measures the squared distance from the sound position to here.', source=SOUND),
        'audio_falloff': a('float', 'public float falloff = 16000f;', 'Core.audio falloff (Audio.java:13, `public float falloff = 16000f;`): the divisor in calcFalloff (`1f / (dst2 / Core.audio.falloff)`, Sound.java:155).', source=AUDIO),
        'falloff_offset': a('float', 'float falloffOffset = 0f;', 'The Sound falloff offset (Sound.java:32, `float falloffOffset = 0f;`): its square is subtracted from the squared distance before the 0 floor (Sound.java:154).', source=SOUND),
        'prev': a('Dictionary', 'SoundData data = sounds.get(sound, SoundData::new);', 'The previous SoundData for this sound (SoundControl.java:109, `sounds.get(sound, SoundData::new)`): an empty Dictionary is a fresh SoundData, all fields zero; a guard return hands it back unchanged.'),
    }
    loop_outputs = {
        'volume': a('float', 'data.volume = Mathf.clamp(data.volume, 0f, 1f);', 'The accumulated volume (SoundControl.java:110 + :112, `data.volume += vol;` then `data.volume = Mathf.clamp(data.volume, 0f, 1f);`): the three-arg clamp, folded into one line.'),
        'pitch': a('float', 'data.pitch += pitch * vol;', 'The accumulated pitch (SoundControl.java:111, `data.pitch += pitch * vol;`).'),
        'total': a('float', 'data.total += baseVol;', 'The accumulated base volume (SoundControl.java:113, `data.total += baseVol;`): the unscaled falloff sum updateLoops averages over.'),
        'total_volume': a('float', 'data.totalVolume += vol;', 'The accumulated scaled volume (SoundControl.java:114, `data.totalVolume += vol;`).'),
        'sum_x': a('float', 'data.sum.add(pos.getX() * baseVol, pos.getY() * baseVol);', 'The accumulated position-weighted x (SoundControl.java:115, `data.sum.add(pos.getX() * baseVol, pos.getY() * baseVol);`): the Vec2 sum field (SoundControl.java:381, `Vec2 sum = new Vec2();`), stored as sum_x / sum_y.'),
        'sum_y': a('float', 'data.sum.add(pos.getX() * baseVol, pos.getY() * baseVol);', 'The accumulated position-weighted y (SoundControl.java:115): the Vec2 sum field, stored as sum_x / sum_y.'),
        'sound_id': a('int', 'int soundID;', 'The playing sound id (SoundControl.java:383, `int soundID;`): NOT written by loop() -- updateLoops owns it -- carried through unchanged from prev (default 0).'),
        'cur_volume': a('float', 'float curVolume, totalVolume;', 'The current playing volume (SoundControl.java:384, `float curVolume, totalVolume;`): NOT written by loop() -- updateLoops owns it -- carried through unchanged from prev (default 0.0).'),
    }
    position_inputs = {
        'sound': a('String', 'public void loop(Sound sound, Position pos, float volume){', 'The sound being looped (SoundControl.java:99): its name String; Sounds.none is the string "none" and the guard returns the previous SoundData unchanged for it.'),
        'pos_x': a('float', 'pos.getX()', 'The sound position x (SoundControl.java:106, via the delegated 4-arg call): the Position the 3-arg overload loops at.'),
        'pos_y': a('float', 'pos.getY()', 'The sound position y (SoundControl.java:106, via the delegated 4-arg call): the Position the 3-arg overload loops at.'),
        'volume': a('float', 'loop(sound, pos, volume, 1f);', 'The loop volume (SoundControl.java:101, `loop(sound, pos, volume, 1f);`): forwarded to the 4-arg accumulator unchanged.'),
        'headless': a('bool', 'public static boolean headless;', 'Whether the game runs on a headless server (Vars.java:209): the N2259 accessor supplies it; a headless game returns the previous SoundData unchanged.', source=VARS),
        'camera_x': a('float', 'Core.camera.position.x', 'The camera (listener) position x (Sound.java:154): calcFalloff measures the squared distance from the sound position to here.', source=SOUND),
        'camera_y': a('float', 'Core.camera.position.y', 'The camera (listener) position y (Sound.java:154): calcFalloff measures the squared distance from the sound position to here.', source=SOUND),
        'audio_falloff': a('float', 'public float falloff = 16000f;', 'Core.audio falloff (Audio.java:13): the divisor in calcFalloff (Sound.java:155).', source=AUDIO),
        'falloff_offset': a('float', 'float falloffOffset = 0f;', 'The Sound falloff offset (Sound.java:32): its square is subtracted from the squared distance before the 0 floor (Sound.java:154).', source=SOUND),
        'prev': a('Dictionary', 'SoundData data = sounds.get(sound, SoundData::new);', 'The previous SoundData for this sound (SoundControl.java:109): an empty Dictionary is a fresh SoundData, all fields zero.'),
    }
    position_outputs = {
        'volume': a('float', 'data.volume = Mathf.clamp(data.volume, 0f, 1f);', 'The accumulated volume (SoundControl.java:110 + :112): the delegated accumulator result.'),
        'pitch': a('float', 'data.pitch += pitch * vol;', 'The accumulated pitch (SoundControl.java:111): pitch defaults to 1f in this overload (SoundControl.java:101, `loop(sound, pos, volume, 1f);`), so pitch after one loop at the camera is vol.'),
        'total': a('float', 'data.total += baseVol;', 'The accumulated base volume (SoundControl.java:113): the delegated accumulator result.'),
        'total_volume': a('float', 'data.totalVolume += vol;', 'The accumulated scaled volume (SoundControl.java:114): the delegated accumulator result.'),
        'sum_x': a('float', 'data.sum.add(pos.getX() * baseVol, pos.getY() * baseVol);', 'The accumulated position-weighted x (SoundControl.java:115): the delegated accumulator result.'),
        'sum_y': a('float', 'data.sum.add(pos.getX() * baseVol, pos.getY() * baseVol);', 'The accumulated position-weighted y (SoundControl.java:115): the delegated accumulator result.'),
        'sound_id': a('int', 'int soundID;', 'The playing sound id (SoundControl.java:383): carried through unchanged from prev.'),
        'cur_volume': a('float', 'float curVolume, totalVolume;', 'The current playing volume (SoundControl.java:384): carried through unchanged from prev.'),
    }
    volume_inputs = {
        'sound': a('String', 'public void loop(Sound sound, float volume){', 'The sound being looped (SoundControl.java:93): its name String; Sounds.none is the string "none" and the guard returns the previous SoundData unchanged for it.'),
        'volume': a('float', 'loop(sound, Core.camera.position, volume);', 'The loop volume (SoundControl.java:96, `loop(sound, Core.camera.position, volume);`): forwarded to the 3-arg overload unchanged.'),
        'headless': a('bool', 'if(Vars.headless) return;', 'Whether the game runs on a headless server (SoundControl.java:94, `if(Vars.headless) return;`): the N2259 accessor supplies it; enforced by the accumulator the call delegates to.'),
        'camera_x': a('float', 'loop(sound, Core.camera.position, volume);', 'The camera position x (SoundControl.java:96, `loop(sound, Core.camera.position, volume);`): in this overload the sound position IS the camera position, so camera_x serves as both the position and the listener.'),
        'camera_y': a('float', 'loop(sound, Core.camera.position, volume);', 'The camera position y (SoundControl.java:96): in this overload the sound position IS the camera position, so camera_y serves as both the position and the listener.'),
        'audio_falloff': a('float', 'public float falloff = 16000f;', 'Core.audio falloff (Audio.java:13): the divisor in calcFalloff (Sound.java:155).', source=AUDIO),
        'falloff_offset': a('float', 'float falloffOffset = 0f;', 'The Sound falloff offset (Sound.java:32): its square is subtracted from the squared distance before the 0 floor (Sound.java:154).', source=SOUND),
        'prev': a('Dictionary', 'SoundData data = sounds.get(sound, SoundData::new);', 'The previous SoundData for this sound (SoundControl.java:109): an empty Dictionary is a fresh SoundData, all fields zero.'),
    }
    volume_outputs = {
        'volume': a('float', 'data.volume = Mathf.clamp(data.volume, 0f, 1f);', 'The accumulated volume (SoundControl.java:110 + :112): the delegated accumulator result.'),
        'pitch': a('float', 'data.pitch += pitch * vol;', 'The accumulated pitch (SoundControl.java:111): pitch defaults to 1f in this overload chain (SoundControl.java:101), so pitch after one loop at the camera is vol.'),
        'total': a('float', 'data.total += baseVol;', 'The accumulated base volume (SoundControl.java:113): the delegated accumulator result.'),
        'total_volume': a('float', 'data.totalVolume += vol;', 'The accumulated scaled volume (SoundControl.java:114): the delegated accumulator result.'),
        'sum_x': a('float', 'data.sum.add(pos.getX() * baseVol, pos.getY() * baseVol);', 'The accumulated position-weighted x (SoundControl.java:115): the delegated accumulator result.'),
        'sum_y': a('float', 'data.sum.add(pos.getX() * baseVol, pos.getY() * baseVol);', 'The accumulated position-weighted y (SoundControl.java:115): the delegated accumulator result.'),
        'sound_id': a('int', 'int soundID;', 'The playing sound id (SoundControl.java:383): carried through unchanged from prev.'),
        'cur_volume': a('float', 'float curVolume, totalVolume;', 'The current playing volume (SoundControl.java:384): carried through unchanged from prev.'),
    }
    return loop_inputs, loop_outputs, position_inputs, position_outputs, volume_inputs, volume_outputs


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
    loop_inputs, loop_outputs, position_inputs, position_outputs, volume_inputs, volume_outputs = definitions()

    entries = [
        ('N2287', LOOP_OWNER, 'source_sound_control_loop_state', SOUND_CONTROL, 'mindustry.audio.SoundControl', 'SoundControl.loop(Sound, Position, float, float)', loop_inputs, loop_outputs, True, 'Dictionary'),
        ('N2287', POSITION_OWNER, 'source_sound_control_loop_position_state', SOUND_CONTROL, 'mindustry.audio.SoundControl', 'SoundControl.loop(Sound, Position, float)', position_inputs, position_outputs, True, 'Dictionary'),
        ('N2287', VOLUME_OWNER, 'source_sound_control_loop_volume_state', SOUND_CONTROL, 'mindustry.audio.SoundControl', 'SoundControl.loop(Sound, float)', volume_inputs, volume_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed SoundControl.loop() state from SoundControl.java + Sound.java + Audio.java + Vars.java + Mathf.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed SoundControl.loop() state from SoundControl.java + Sound.java + Audio.java + Vars.java + Mathf.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: loop.volume, loop.pitch,
    # loop.total, loop.total_volume, loop.sum_x, loop.sum_y,
    # loop.sound_id, loop.cur_volume, then the same 8 for the
    # position overload, then the same 8 for the volume overload.
    by_slice['N2287'] = [
        'source_sound_control_loop_state_result.volume',
        'source_sound_control_loop_state_result.pitch',
        'source_sound_control_loop_state_result.total',
        'source_sound_control_loop_state_result.total_volume',
        'source_sound_control_loop_state_result.sum_x',
        'source_sound_control_loop_state_result.sum_y',
        'source_sound_control_loop_state_result.sound_id',
        'source_sound_control_loop_state_result.cur_volume',
        'source_sound_control_loop_position_state_result.volume',
        'source_sound_control_loop_position_state_result.pitch',
        'source_sound_control_loop_position_state_result.total',
        'source_sound_control_loop_position_state_result.total_volume',
        'source_sound_control_loop_position_state_result.sum_x',
        'source_sound_control_loop_position_state_result.sum_y',
        'source_sound_control_loop_position_state_result.sound_id',
        'source_sound_control_loop_position_state_result.cur_volume',
        'source_sound_control_loop_volume_state_result.volume',
        'source_sound_control_loop_volume_state_result.pitch',
        'source_sound_control_loop_volume_state_result.total',
        'source_sound_control_loop_volume_state_result.total_volume',
        'source_sound_control_loop_volume_state_result.sum_x',
        'source_sound_control_loop_volume_state_result.sum_y',
        'source_sound_control_loop_volume_state_result.sound_id',
        'source_sound_control_loop_volume_state_result.cur_volume',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2287', dict(status='done', java_source=SOUND_CONTROL, java_class='mindustry.audio.SoundControl', java_method='SoundControl.loop(Sound, float); SoundControl.loop(Sound, Position, float); SoundControl.loop(Sound, Position, float, float)', godot_owner=LOOP_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2287'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
