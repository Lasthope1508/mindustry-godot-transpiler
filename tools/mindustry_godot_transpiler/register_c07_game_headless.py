"""Register the game-level headless source (N2300, ambient A).

Vars.headless (Vars.java:208-209, `/** whether the game is
running on a headless server */` / `public static boolean
headless;`) is a static boolean, default false (Java static
booleans default false). The only assignment in the whole repo
is ServerLauncher.init() (ServerLauncher.java:45, `headless =
true;`). The port derives it from the display server instead
(decision 2026-11-17 ~12:56, Option 1, the first DisplayServer
use in the port): `DisplayServer.get_name() == "headless"`,
stamped onto the game node by SourceGameLoopRuntimeState.ready()
-- first, so every load step below sees the same value the
ambient gate (N657) reads. The ambient gate already takes this
value as its headless_mode input (BuildingComp.update,
BuildingComp.java:2270-2271, `if(!headless &&
block.ambientSound != Sounds.none && shouldAmbientSound()){` /
`control.sound.loop(block.ambientSound, self(),
block.ambientSoundVolume * ambientVolume());`); this slice only
supplies the input, it builds no second gate.

RED decisions (resolved at RED): (1) One pure accessor on its
own new game state file, following the paused accessor
precedent (SourceGameLoopRuntimeState.source_game_loop_paused_state,
N2123): source_game_headless_state(game) reads the game node's
headless flag; a null game reads false (no game, no headless
state), and a game without the flag reads null, which is not
headless like the Java default. (2) The flag is declared on the
game node next to the other game.set-stamped vars
(last_place_blocked precedent in
SourcePortGameBuildProjectorStatePortBridge.gd), default false,
the Java default -- ready() stamps it with game.set, so it must
exist on the instance. (3) There is NO driver tick line: the
RepairTurret driver (B, N2260) waits for A to land and its
accessor interface to be fixed; the SoundControl.updateLoops
aggregate mixer (C, N2243) waits for B. (4) The proof's gate
key calls the existing N657 pure gate directly with explicit
headless values -- it proves the input A supplies drives the
gate, without changing the gate. One new result symbol:
headless. Slice sources: Vars.java + ServerLauncher.java +
BuildingComp.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_repair_turret_ambient_sound_loop import DEFERRED as N2222_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
VARS = 'core/src/mindustry/Vars.java'
SERVER_LAUNCHER = 'server/src/mindustry/server/ServerLauncher.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
PROOF = '/root/C07GameHeadlessProof'
HEADLESS_OWNER = 'SourceGameHeadlessState.source_game_headless_state'
TESTS = ['test_c07_game_headless_registration', 'test_all_c07_game_headless_input_evidence_is_exact', 'test_game_headless_state', 'test_reference_graph_and_actual_c07_game_headless']
# The 3 slice sources the N2300 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/Vars.java',
    'server/src/mindustry/server/ServerLauncher.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
]
EXACT_EXPRS = ['/** whether the game is running on a headless server */', 'public static boolean headless;', 'headless = true;', 'if(!headless && block.ambientSound != Sounds.none && shouldAmbientSound()){', 'control.sound.loop(block.ambientSound, self(), block.ambientSoundVolume * ambientVolume());']

# DEFERRED is carried from the N2222 register script via import --
# never retyped. One carried entry is DROPPED here, not carried:
# the entry saying the driver tick line + sound-loop sink "wait
# for a game-level headless-source slice" -- N2300 IS that slice,
# so carrying it would leave a stale "waits for its own slice"
# row for done work. The B driver and C mixer entries below pin
# what is still deferred.
DEFERRED = [e for e in N2222_DEFERRED if 'wait for a game-level headless-source slice' not in e] + [
    'RepairTurret ambient-sound live-loop driver tick line (B, N2260) -- waits for A (N2300) to land and its accessor interface to be fixed; the driver calls the N2222 pure function with the headless value from SourceGameHeadlessState.',
    'SoundControl.updateLoops aggregate mixer (C, N2243) -- waits for B (N2260); no audio playback in the port yet (0 AudioStreamPlayer hits), beamHeal.ogg exists.',
    'Game headless-source Windows Godot proof -- debt in GOAL.md section 5, same as N2234-N2260, N2248-N2258: the N2300 proof runs headless on Linux here and waits for a Windows Godot run.',
    'PortGame headless property on non-headless servers -- the stamp reads DisplayServer; a dedicated launcher setter (Option 2) was rejected 2026-11-17 ~12:56 in favour of Option 1.',
]


def definitions():
    def a(typ, expr, rule, source=VARS, **extra):
        return backed(typ, source, expr, rule, **extra)

    headless_inputs = {
        'game': a('Object', 'public static boolean headless;', 'The live game (PortGame node): its headless flag is read from it; a null game or a game without the flag reads false, the Java default (Vars.java:209, `public static boolean headless;` defaults false) -- the paused accessor precedent (N2123).', source=VARS),
    }
    headless_outputs = {
        'headless': a('bool', 'public static boolean headless;', 'Whether the game runs on a headless server: the stamped DisplayServer derivation (decision 2026-11-17 ~12:56, Option 1), the value the N657 ambient gate reads as its headless_mode input (BuildingComp.java:2270-2271).', source=VARS),
    }
    return headless_inputs, headless_outputs


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
    headless_inputs, headless_outputs = definitions()

    entries = [
        ('N2300', HEADLESS_OWNER, 'source_game_headless_state', VARS, 'mindustry.Vars', 'Vars.headless', headless_inputs, headless_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed game headless source from Vars.java + ServerLauncher.java + BuildingComp.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed game headless source from Vars.java + ServerLauncher.java + BuildingComp.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: headless.
    by_slice['N2300'] = [
        'source_game_headless_state_result.headless',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2300', dict(status='done', java_source=VARS, java_class='mindustry.Vars', java_method='Vars.headless', godot_owner=HEADLESS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2300'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
