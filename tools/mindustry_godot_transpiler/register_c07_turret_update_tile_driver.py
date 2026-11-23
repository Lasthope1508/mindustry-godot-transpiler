"""Register the TurretBuild.updateTile() remaining driver-tick legs (N2397).

TurretBuild.updateTile() remaining driver-tick legs
(Turret.java:494-499, :548-557, :566-608,
`if(unit.isPlayer()){ //there's no reason to update
this when a player isn't controlling it` /
`unit.ammo(getAmmoFraction());` /
`soundLoop.update(x, y, shouldActiveSound(),
activeSoundVolume());` /
`if(reloadWhileCharging || !charging()){` /
`updateReload();` / `if(state.rules.fog){` /
`float newRange = hasAmmo() ? peekAmmo().rangeChange :
0f;` / `if(newRange != lastRangeChange){` /
`lastRangeChange = newRange;` /
`fogControl.forceUpdate(team, this);` /
`if(hasAmmo()){` /
`if(Float.isNaN(reloadCounter)) reloadCounter = 0;` /
`if(timer(timerTarget, target != null ?
newTargetInterval : targetInterval)){` /
`findTarget();` / `boolean canShoot;` /
`if(controlled()){ //player behavior` /
`targetPos.set(unit.aimX(), unit.aimY());` /
`canShoot = unit.isShooting();` /
`}else if(logicControlled()){ //logic behavior` /
`canShoot = logicShooting;` /
`}else{ //default AI behavior` /
`if(!controlled()){` / `unit.aimX(targetPos.x);` /
`unit.aimY(targetPos.y);` / `if(alwaysShooting){`)
on `public class TurretBuild extends ReloadTurretBuild
implements ControlBlock{` (Turret.java:277), inside
updateTile() (Turret.java:490). The guard lines are
registered with their Java trailing comments, so they
are distinct from the same bare text owned elsewhere
(`if(unit.isPlayer()){` alone is N1899
BuildingComp.handleUnitPayload; `}else{` alone is owned
by sixteen slices). NOT registered:
`updateCooling();` (N2241), `wasShooting = true;`
(N2362), `updateShooting();` (remote N2269),
`if(soundLoop != null){` (N2350). Call-sites already
owned arrive as Callables/params, never re-registered:
updateReload/updateCooling (N2241), findTarget (N2316),
validateTarget/charging/controlled/logicControlled
(N2324/N2297), getAmmoFraction (N2348/N2355),
shouldActiveSound/activeSoundVolume (N2346).

RED decisions (resolved at RED): (1) One pure function
on SourceTurretBuildState.gd next to the N2308 warmup
driver, following the N2308 updateTile precedent: the
five legs share one frame and one owner,
`SourceTurretBuildState.source_turret_update_tile_driver_state`
(main thread approved the merge 2026-11-22 ~01:1x,
precedent N2395 derelict 26 exprs in one slice). (2)
All live values arrive as explicit params (the N2188
precedent) -- the tick frame tracks no ammo/sound/
reload/fog/target keys yet, so there is NO driver tick
line (the N2308/N2294 updateTile precedent); the
driver waits until those frame keys are tracked. (3)
The player branch sets targetPos from the unit aim and
reads canShoot from unit.isShooting(); the logic branch
reads canShoot from logicShooting; the default-AI
branch (targetPosition/within, remote N2250) is NOT
ported, so can_shoot stays null there -- the frame
never invents a within() read. (4) The aim write runs
exactly when !controlled(), after the branch, on the
(possibly updated) targetPos. (5) The fog leg only
force-updates when the range actually changed; with no
ammo the new range is 0f. (6) A NaN reloadCounter
resets to 0 inside the hasAmmo block only; with no
ammo the block is skipped entirely and the NaN is
kept. (7) updateReload() is a call-site (body N2241):
the frame records that it was called when the gate is
open, never re-ports its body; updateShooting()
(remote N2269) and wasShooting (N2362) are NOT
registered: only the alwaysShooting gate is recorded.
(8) getAmmoFraction() is Turret.java:324-326 (base
returns 1f); the unit ammo write only runs for a
player-controlled unit, so a non-player unit applies
nothing (null). Fourteen new result symbols. Slice
source: Turret.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_update_tile_warmup import DEFERRED as N2308_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
PROOF = '/root/C07TurretUpdateTileDriverProof'
DRIVER_OWNER = 'SourceTurretBuildState.source_turret_update_tile_driver_state'
TESTS = ['test_c07_turret_update_tile_driver_registration', 'test_all_c07_turret_update_tile_driver_input_evidence_is_exact', 'test_turret_update_tile_driver_state', 'test_reference_graph_and_actual_c07_turret_update_tile_driver']
# The 1 slice source the N2397 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
]
EXACT_EXPRS = [
    "if(unit.isPlayer()){ //there's no reason to update this when a player isn't controlling it",
    'unit.ammo(getAmmoFraction());',
    'soundLoop.update(x, y, shouldActiveSound(), activeSoundVolume());',
    'if(reloadWhileCharging || !charging()){',
    'updateReload();',
    'if(state.rules.fog){',
    'float newRange = hasAmmo() ? peekAmmo().rangeChange : 0f;',
    'if(newRange != lastRangeChange){',
    'lastRangeChange = newRange;',
    'fogControl.forceUpdate(team, this);',
    'if(hasAmmo()){',
    'if(Float.isNaN(reloadCounter)) reloadCounter = 0;',
    'if(timer(timerTarget, target != null ? newTargetInterval : targetInterval)){',
    'findTarget();',
    'boolean canShoot;',
    'if(controlled()){ //player behavior',
    'targetPos.set(unit.aimX(), unit.aimY());',
    'canShoot = unit.isShooting();',
    '}else if(logicControlled()){ //logic behavior',
    'canShoot = logicShooting;',
    '}else{ //default AI behavior',
    'if(!controlled()){',
    'unit.aimX(targetPos.x);',
    'unit.aimY(targetPos.y);',
    'if(alwaysShooting){',
]

# DEFERRED is carried from the N2308 register script via import --
# never retyped. Nothing in it closes here: N2397 covers part of
# what its "rest of updateTile" entry lists, but the validateTarget
# / isShooting lines, the recoil/heat/charge/unit legs, the
# activationTimer leg and the default-AI targetPosition/within
# legs are still unported. Three entries are added: the N2397
# Windows Godot proof debt (GOAL.md section 5), the rest of
# updateTile still unported after N2397, and the driver tick
# line (waits for the frame keys).
DEFERRED = N2308_DEFERRED + [
    'Turret updateTile driver N2397 Windows Godot proof -- debt in GOAL.md section 5, same as N2308: the N2397 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Port the rest of TurretBuild.updateTile() (Turret.java:491-492 validateTarget/isShooting, :517-547 recoil/heat/charge/unit/logicControlTime/heatReq/rotate, :558-564 activationTimer, :581-604 default-AI targetPosition/within/turnToTarget/shoot gate) as their own slices; N2397 covers the player-ammo/soundLoop/reload-gate/fog-range/hasAmmo-targeting legs :494-499, :548-557, :566-608 (minus the remote-N2250/N2251/N2269/N2279-owned lines inside them).',
    'Wire the Turret updateTile driver tick line (source_turret_tick_buildings_state) once the tick frame tracks ammo/sound/reload/fog/target keys; N2397 is pure-function-only (the N2308/N2294 updateTile precedent).',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    driver_inputs = {
        'frame': a('Dictionary', 'public void updateTile(){', 'The turret frame (accepted for the family call shape; this leg reads no live frame key -- all live values arrive as explicit params, the N2188 per-def-param precedent, because the tick frame tracks no ammo/sound/reload/fog/target keys).'),
        'is_player': a('bool', "if(unit.isPlayer()){ //there's no reason to update this when a player isn't controlling it", 'Whether a player controls the turret unit: TurretBuild.updateTile() (Turret.java:494) gates the unit ammo sync on unit.isPlayer() -- "there\'s no reason to update this when a player isn\'t controlling it"; passed explicitly because the tick frame tracks no unit/player key. A non-player unit applies nothing.'),
        'ammo_fraction': a('float', 'unit.ammo(getAmmoFraction());', 'The ammo fraction to sync onto the unit: getAmmoFraction() (Turret.java:324-326, `public float getAmmoFraction(){` / `return 1f;`, "ammo as a fraction of capacity; used for direct turret control HUD"), N2348/N2355 -- it arrives as an explicit float param, NOT re-ported here; only applied when is_player.'),
        'has_sound_loop': a('bool', 'public @Nullable SoundLoop soundLoop = (loopSound == Sounds.none ? null : new SoundLoop(loopSound, loopSoundVolume));', 'Whether the turret has a sound loop: TurretBuild.soundLoop (Turret.java:298), null when loopSound == Sounds.none; passed explicitly because the tick frame tracks no soundLoop key. An absent loop carries a null update.'),
        'x': a('float', 'soundLoop.update(x, y, shouldActiveSound(), activeSoundVolume());', 'The build x position passed to soundLoop.update (Turret.java:499): BuildingComp x, passed explicitly because the tick frame tracks no position key for this leg.'),
        'y': a('float', 'soundLoop.update(x, y, shouldActiveSound(), activeSoundVolume());', 'The build y position passed to soundLoop.update (Turret.java:499): BuildingComp y, passed explicitly because the tick frame tracks no position key for this leg.'),
        'should_active_sound': a('bool', 'public boolean shouldActiveSound(){', 'Whether the loop sound should play: TurretBuild.shouldActiveSound() (Turret.java:826-828, `public boolean shouldActiveSound(){` / `return shootWarmup > 0.01f && loopSound != Sounds.none;`), N2346 -- it arrives as an explicit bool param, NOT re-ported here.'),
        'active_sound_volume': a('float', 'public float activeSoundVolume(){', 'The loop sound volume scale: TurretBuild.activeSoundVolume() (Turret.java:822-824, `public float activeSoundVolume(){` / `return shootWarmup;`), N2346 -- it arrives as an explicit float param, NOT re-ported here.'),
        'reload_while_charging': a('bool', 'public boolean reloadWhileCharging = true;', 'Whether the turret reloads while charging: Turret.reloadWhileCharging (Turret.java:82), default true; the reload gate (Turret.java:548) opens while charging only when this is true; passed explicitly because it is per-def static state, not a live frame key.'),
        'charging': a('bool', 'public boolean charging(){', 'Whether the turret is charging a shot: TurretBuild.charging() (Turret.java:715-717, `public boolean charging(){` / `return queuedBullets > 0 && shoot.firstShotDelay > 0;`); passed explicitly because queuedBullets / firstShotDelay are not tracked in the tick frame yet. The gate opens whenever the turret is not charging.'),
        'fog': a('bool', 'if(state.rules.fog){', 'Whether fog is enabled: state.rules.fog (Turret.java:553); the fog leg does nothing at all when false; passed explicitly because the tick frame tracks no rules/fog key for this leg.'),
        'has_ammo': a('bool', 'if(hasAmmo()){', 'Whether the turret has ammo: TurretBuild.hasAmmo() (Turret.java:698-712, with the ammo-queue swap and the canConsume() gate) -- it arrives as an explicit bool param, NOT re-ported here; it gates both the fog range read and the whole targeting block.'),
        'ammo_range_change': a('float', 'float newRange = hasAmmo() ? peekAmmo().rangeChange : 0f;', 'The peeked ammo range change: peekAmmo().rangeChange (Turret.java:554, the BulletType rangeChange read through Turret.range() at Turret.java:343-344); passed explicitly because peekAmmo() is not re-ported here; with no ammo the new range is 0f.'),
        'last_range_change': a('float', 'float lastRangeChange;', 'The last fog range change: TurretBuild.lastRangeChange (Turret.java:300), Java default 0f; compared against the new range each fog tick; passed explicitly because the tick frame tracks no last_range_change key yet.'),
        'reload_counter': a('float', 'if(Float.isNaN(reloadCounter)) reloadCounter = 0;', 'The reload counter: ReloadTurretBuild.reloadCounter, read by shouldConsume() (Turret.java:365) and progress (Turret.java:426); a NaN value resets to 0 inside the hasAmmo block (Turret.java:567); passed explicitly because the tick frame tracks no reload_counter key for this leg.'),
        'timer_target_ready': a('bool', 'if(timer(timerTarget, target != null ? newTargetInterval : targetInterval)){', 'Whether the target timer fired: timer(timerTarget, target != null ? newTargetInterval : targetInterval) (Turret.java:569; timer() is TimerComp.java:10, `public boolean timer(int index, float time){`; timerTarget is Turret.java:40, `public final int timerTarget = timers++;`; targetInterval is Turret.java:42, `public float targetInterval = 20;`, newTargetInterval Turret.java:44) -- it arrives as an explicit bool param, NOT re-ported here; findTarget() runs only when it is true.'),
        'validate_target': a('bool', 'if(validateTarget()){', 'Whether the current target is still valid: TurretBuild.validateTarget() (Turret.java:573, N2324/N2297) -- it arrives as an explicit bool param, NOT re-ported here; the canShoot branches run only inside it.'),
        'controlled': a('bool', 'public boolean controlled(){', 'Whether a player controls the turret unit: TurretBuild.controlled() (Turret.java:441-443, `public boolean controlled(){` / `return unit.isPlayer();`); passed explicitly because the tick frame tracks no unit/player key. The player branch runs when true; the aim write runs exactly when false.'),
        'logic_controlled': a('bool', 'public boolean logicControlled(){', 'Whether logic controls the turret unit: TurretBuild.logicControlled() (Turret.java:445-447, `public boolean logicControlled(){` / `return logicControlTime > 0;`); passed explicitly because the tick frame tracks no logicControlTime key. The logic branch runs when controlled is false and this is true.'),
        'target_pos': a('Vector2', 'public Vec2 targetPos = new Vec2();', 'The aim target position: TurretBuild.targetPos (Turret.java:290), the Vec2 the player branch sets from the unit aim and the aim write reads back; passed explicitly because the tick frame tracks no target_pos key for this leg.'),
        'unit_aim_x': a('float', 'unit.aimX(targetPos.x);', 'The unit aim x: unit.aimX() (Turret.java:591, `unit.aimX(targetPos.x);`) -- the player branch reads it to set targetPos, and the aim write writes it back when !controlled(); passed explicitly because the tick frame tracks no unit aim key.'),
        'unit_aim_y': a('float', 'unit.aimY(targetPos.y);', 'The unit aim y: unit.aimY() (Turret.java:592, `unit.aimY(targetPos.y);`) -- the player branch reads it to set targetPos, and the aim write writes it back when !controlled(); passed explicitly because the tick frame tracks no unit aim key.'),
        'unit_is_shooting': a('bool', 'canShoot = unit.isShooting();', 'Whether the unit is shooting: unit.isShooting() (Turret.java:578, `canShoot = unit.isShooting();`) -- the player branch reads it as canShoot; passed explicitly because the tick frame tracks no unit shooting key.'),
        'logic_shooting': a('bool', 'public boolean logicShooting = false;', 'Whether logic is shooting: TurretBuild.logicShooting (Turret.java:288), default false, set by the logic sense legs (Turret.java:385/395); the logic branch reads it as canShoot; passed explicitly because the tick frame tracks no logic_shooting key for this leg.'),
        'always_shooting': a('bool', 'public boolean alwaysShooting = false;', 'Whether the turret always shoots: Turret.alwaysShooting (Turret.java:103), default false; the gate at Turret.java:607 fires only inside the hasAmmo block; passed explicitly because it is per-def static state, not a live frame key. Only the gate is recorded -- wasShooting = true and updateShooting() inside it belong to N2362 / remote N2269.'),
    }
    driver_outputs = {
        'unit_ammo_fraction': a('Variant', 'unit.ammo(getAmmoFraction());', 'The ammo fraction applied to the unit (Turret.java:495, `unit.ammo(getAmmoFraction());`): the ammo_fraction param when is_player, else null -- a non-player unit applies nothing.'),
        'sound_loop_update': a('Variant', 'soundLoop.update(x, y, shouldActiveSound(), activeSoundVolume());', 'The soundLoop update call (Turret.java:499, `soundLoop.update(x, y, shouldActiveSound(), activeSoundVolume());`): {"x": x, "y": y, "active": should_active_sound, "volume": active_sound_volume} when has_sound_loop, else null -- SoundLoop.update is an arc audio call, so the frame records the call, never re-ports it.'),
        'reload_gate_open': a('bool', 'if(reloadWhileCharging || !charging()){', 'Whether the reload gate is open (Turret.java:548, `if(reloadWhileCharging || !charging()){`): true whenever the turret is not charging, or while charging when reloadWhileCharging is true -- "turret always reloads regardless of whether it\'s targeting something".'),
        'update_reload_called': a('bool', 'updateReload();', 'Whether updateReload() was called (Turret.java:549, `updateReload();`): true exactly when the reload gate is open; updateReload() (Turret.java:719-720, body N2241) is a call-site, so the frame records the call, never re-ports its body. updateCooling() on the next line is N2241 and is NOT recorded here.'),
        'last_range_change': a('float', 'lastRangeChange = newRange;', 'The last fog range change after the tick (Turret.java:556, `lastRangeChange = newRange;`): the new range when fog is on and it changed, else the incoming value.'),
        'fog_range_changed': a('bool', 'if(newRange != lastRangeChange){', 'Whether the fog range changed this tick (Turret.java:555, `if(newRange != lastRangeChange){`): true exactly when fog is on and the new range differs from lastRangeChange.'),
        'fog_force_update_called': a('bool', 'fogControl.forceUpdate(team, this);', 'Whether fogControl.forceUpdate(team, this) was called (Turret.java:557, `fogControl.forceUpdate(team, this);`): true exactly when the fog range changed; FogControl.forceUpdate (FogControl.java:177) is an engine call, so the frame records the call, never re-ports it.'),
        'reload_counter': a('float', 'if(Float.isNaN(reloadCounter)) reloadCounter = 0;', 'The reload counter after the tick (Turret.java:567, `if(Float.isNaN(reloadCounter)) reloadCounter = 0;`): 0 when has_ammo and the incoming value is NaN, else the incoming value -- with no ammo the block is skipped entirely and a NaN is kept.'),
        'find_target_called': a('bool', 'findTarget();', 'Whether findTarget() was called (Turret.java:570, `findTarget();`): true exactly when has_ammo and the target timer fired; findTarget() (body N2316) is a call-site, so the frame records the call, never re-ports its body.'),
        'target_pos': a('Vector2', 'targetPos.set(unit.aimX(), unit.aimY());', 'The aim target position after the tick (Turret.java:577, `targetPos.set(unit.aimX(), unit.aimY());`): set from the unit aim in the player branch, unchanged in the logic and default-AI branches (the default-AI targetPosition leg is remote N2250).'),
        'can_shoot': a('Variant', 'boolean canShoot;', 'Whether the turret can shoot this tick (Turret.java:574, `boolean canShoot;`): unit_is_shooting in the player branch, logic_shooting in the logic branch, null in the default-AI branch -- the within() read there (remote N2250) is NOT ported, so the frame never invents it; null outside a valid target or with no ammo.'),
        'unit_aim_x': a('float', 'unit.aimX(targetPos.x);', 'The unit aim x after the tick (Turret.java:591, `unit.aimX(targetPos.x);`): the targetPos x when !controlled() (after the branch), else the incoming unit aim x.'),
        'unit_aim_y': a('float', 'unit.aimY(targetPos.y);', 'The unit aim y after the tick (Turret.java:592, `unit.aimY(targetPos.y);`): the targetPos y when !controlled() (after the branch), else the incoming unit aim y.'),
        'always_shooting_gate': a('bool', 'if(alwaysShooting){', 'Whether the alwaysShooting gate fired (Turret.java:607, `if(alwaysShooting){`): true exactly when has_ammo and always_shooting -- only the gate is recorded; wasShooting = true and updateShooting() inside it belong to N2362 / remote N2269.'),
    }
    return driver_inputs, driver_outputs


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
    driver_inputs, driver_outputs = definitions()

    entries = [
        ('N2397', DRIVER_OWNER, 'source_turret_update_tile_driver_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.updateTile()', driver_inputs, driver_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed TurretBuild.updateTile() remaining driver-tick legs from Turret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed TurretBuild.updateTile() remaining driver-tick legs from Turret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: unit_ammo_fraction, sound_loop_update,
    # reload_gate_open, update_reload_called, last_range_change,
    # fog_range_changed, fog_force_update_called, reload_counter,
    # find_target_called, target_pos, can_shoot, unit_aim_x,
    # unit_aim_y, always_shooting_gate.
    by_slice['N2397'] = [
        'source_turret_update_tile_driver_state_result.unit_ammo_fraction',
        'source_turret_update_tile_driver_state_result.sound_loop_update',
        'source_turret_update_tile_driver_state_result.reload_gate_open',
        'source_turret_update_tile_driver_state_result.update_reload_called',
        'source_turret_update_tile_driver_state_result.last_range_change',
        'source_turret_update_tile_driver_state_result.fog_range_changed',
        'source_turret_update_tile_driver_state_result.fog_force_update_called',
        'source_turret_update_tile_driver_state_result.reload_counter',
        'source_turret_update_tile_driver_state_result.find_target_called',
        'source_turret_update_tile_driver_state_result.target_pos',
        'source_turret_update_tile_driver_state_result.can_shoot',
        'source_turret_update_tile_driver_state_result.unit_aim_x',
        'source_turret_update_tile_driver_state_result.unit_aim_y',
        'source_turret_update_tile_driver_state_result.always_shooting_gate',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2397', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.updateTile()', godot_owner=DRIVER_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2397'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
