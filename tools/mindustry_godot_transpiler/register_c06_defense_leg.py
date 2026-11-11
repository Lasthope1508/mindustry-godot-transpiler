"""Register the C06 defense leg (N2122).

C06 chains the whole bootstrap world through the real game loop, and
the defense leg is the last link: the duo must lead its shots at a
moving dagger (Predict.intercept) and the dagger must die and be
swept from the live enemy list (HealthComp.kill -> Unit.remove).

Proving the session chain in N2121 exposed the belt tick bug; this
slice proves the defense chain and exposes two more live-loop gaps
in the turret aim, both fixed here. First, the sim aimed from the
turret's grid cell: turret_fire_state and turret_shot_application_state
used `Vector2(cell)` as the origin, so find_enemy_target measured the
range from (19, 7) in pixel space and angle_to_target aimed from
there, and the bullet spawned there too — the turret acquired the
dagger only while it was in the far west and lost it once it walked
east. Java aims from the building's world x/y (Turret.targetPosition
calls Predict.intercept(this, pos, ...) and angleTo(targetPos) reads
this.x/this.y), so the origin is now the turret's world position:
find_enemy_target converts the cell before the range check, the
angle path converts it before the aim, and the shot application
converts it before the bullet origin. Second, there was no lead at
all: the aim used the target's current sprite position, while the
bullet needs ~64 ticks to cross 160px and the dagger walks 32px in
that time — every shot missed by the lead distance. Turret
targetPosition now runs Predict.intercept (predictTarget is the
Turret default, true; the duo runs accurateDelay with
moveWhileCharging, so the charge offset is zero) and the turret
rotates onto the intercept point.

The death sweep is the other half: the bullet step lowers the
dagger's health but nothing ever killed it — simulate_units only
removed enemies that reached the core, so a bullet-killed dagger
kept walking, kept being targeted, and kept damaging the core.
HealthComp.damage kills at health <= 0, HealthComp.kill clamps the
health, marks it dead and removes it, a non-flying unit's killed()
destroys it, and UnitComp.remove drops it from its team; the new
sweep runs at the top of simulate_units and frees the dead sprite
and drops the enemy from the live list. The destroy() effects
(explosion, sound, UnitDestroyEvent, wreck decal, shoot-on-death,
crash damage) live in SourceUnitDestroyState and stay deferred.

Java: Predict.intercept(float, float, float, float, float, float,
float) + quad(float, float, float); TurretBuild.targetPosition(Posc);
HealthComp.damage(float)/kill(); UnitComp.killed()/remove().

Deferred: the destroy() effects above; the bullet hit check still
uses only the bullet's hitSize (4.0) — Java's physics collision
adds the target's hitbox, the port's target_step_state does not add
the target's hitSize; the turret shootY offset (3.0) is used as-is
in the pixel frame; the per-class shouldConsume() bodies
(UnitFactory.java:446, Reconstructor.java:368,
UnitAssembler.java:389); ConsumeItemDynamic.trigger plan stacks;
UnitAssembler plan dynamics; power-graph shouldConsumePower from
the live frame; pause/timeScale/disable/removal and
source-exhaustion/output-full acts.
"""
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
PREDICT = 'core/src/mindustry/entities/Predict.java'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
HEALTH_COMP = 'core/src/mindustry/entities/comp/HealthComp.java'
UNIT_COMP = 'core/src/mindustry/entities/comp/UnitComp.java'
INTERCEPT_OWNER = 'SourcePredictState.source_predict_intercept_state'
QUAD_OWNER = 'SourcePredictState.source_predict_quad_state'
TARGET_POSITION_OWNER = 'SourceTurretCombatState.source_turret_target_position_state'
SWEEP_OWNER = 'SourceEnemyUnitRuntimeState.source_enemy_units_sweep_dead_state'
PROOF = '/root/C06DefenseProof'
TESTS = ['test_c06_defense_leg_registration', 'test_all_c06_defense_leg_input_evidence_is_exact', 'test_defense_leg_reads_live_turret_and_enemy_state', 'test_reference_graph_and_actual_c06_defense_leg']
DEFERRED = [
    'The Unit.destroy() effects (explosion, sound, UnitDestroyEvent, wreck decal, shoot-on-death mounts, crash damage, UnitComp.java:863-959) are later slices; the sweep removes the dead enemy from the live list and frees its sprite, and SourceUnitDestroyState already holds the sub-behaviors unwired.',
    'The bullet hit check still uses only the bullet hitSize (4.0, BulletType.java:43): Java collides the bullet hitbox against the unit hitbox, so the effective radius adds the target hitSize, while the port target_step_state checks distance <= bullet_hit_size only. A hit-fidelity slice owns that.',
    'The turret shootY offset (3.0, Blocks.java duo) is used as-is in the pixel frame: the bullet spawns 3px forward of the turret center instead of the Java 3 source units. A world-scale slice owns the unit conversion.',
    'The three per-class shouldConsume() bodies (UnitFactory.java:446, Reconstructor.java:368, UnitAssembler.java:389) are later slices; the tick passes the frame enabled flag as should_consume until then.',
    'The plan stacks leave only at unit completion via ConsumeItemDynamic.trigger (ConsumeItemDynamic.java:53-56); the per-tick second pass removes nothing for items, so the production slice owns the trigger.',
    'The UnitAssembler plan dynamics (ConsumePayloadDynamic, ConsumeItemDynamic over plan().itemReq, ConsumeLiquidsDynamic over plan().liquidReq, UnitAssembler.java:158-160) are later slices; the registry captures no assembler plans yet, so no dynamic rows bind for them.',
    'Power graph shouldConsumePower from the live frame enabled flag is a later slice: Java ConsumePower.requestedPower gates on entity.shouldConsume(), but the port uses static catalog properties, so disabling a building does not change the power graph needed value and a disable -> battery-charges act is not possible yet.',
    'Pause/timeScale/disable/removal and source-exhaustion/output-full acts are later C06 slices.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'public static Vec2 intercept(float srcx, float srcy, float dstx, float dsty, float dstvx, float dstvy, float v){',
    'dstvx /= Time.delta;',
    'dstvy /= Time.delta;',
    'float a = dstvx * dstvx + dstvy * dstvy - v * v;',
    'float b = 2 * (dstvx * tx + dstvy * ty);',
    'float c = tx * tx + ty * ty;',
    'Vec2 ts = quad(a, b, c);',
    'Vec2 sol = vresult.set(dstx, dsty);',
    'float t0 = ts.x, t1 = ts.y;',
    'float t = Math.min(t0, t1);',
    'if(t < 0) t = Math.max(t0, t1);',
    'if(t > 0){',
    'sol.set(dstx + dstvx * t, dsty + dstvy * t);',
    'return sol;',
    'private static Vec2 quad(float a, float b, float c){',
    'if(Math.abs(a) < 1e-6){',
    'if(Math.abs(b) < 1e-6){',
    'sol = Math.abs(c) < 1e-6 ? vec.set(0, 0) : null;',
    'vec.set(-c / b, -c / b);',
    'float disc = b * b - 4 * a * c;',
    'if(disc >= 0){',
    'disc = Mathf.sqrt(disc);',
    'a = 2 * a;',
    'sol = vec.set((-b - disc) / a, (-b + disc) / a);',
    'public void targetPosition(Posc pos){',
    'if(!hasAmmo() || pos == null) return;',
    'BulletType bullet = peekAmmo();',
    'if(accurateDelay && !moveWhileCharging && pos instanceof Hitboxc h){',
    'offset.set(h.deltaX(), h.deltaY()).scl(shoot.firstShotDelay / Time.delta);',
    'if(predictTarget && bullet.speed >= 0.01f){',
    'targetPos.set(Predict.intercept(this, pos, offset.x, offset.y, bullet.speed));',
    'targetPos.set(pos);',
    'if(targetPos.isZero()){',
    'public boolean accurateDelay = true;',
    'public boolean moveWhileCharging = true;',
    'public boolean predictTarget = true;',
    'void damage(float amount){',
    'health -= amount;',
    'if(health <= 0 && !dead){',
    'void kill(){',
    'health = Math.min(health, 0);',
    'dead = true;',
    'killed();',
    'remove();',
    'if(!type.flying || !type.createWreck){',
    'public void remove(){',
    'team.data().updateCount(type, -1);',
    'controller.removed(self());',
]


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=PREDICT, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2122_intercept_inputs = {
        'src_x': f('float', 'float srcx', 'The shooter X (the turret world x).'),
        'src_y': f('float', 'float srcy', 'The shooter Y (the turret world y).'),
        'dst_x': f('float', 'float dstx', 'The target X at the call.'),
        'dst_y': f('float', 'float dsty', 'The target Y at the call.'),
        'dst_vx': f('float', 'float dstvx', 'The target X velocity as a per-frame displacement (its Hitboxc deltaX); divided by Time.delta to a per-tick velocity.'),
        'dst_vy': f('float', 'float dstvy', 'The target Y velocity as a per-frame displacement (its Hitboxc deltaY); divided by Time.delta to a per-tick velocity.'),
        'bullet_speed': f('float', 'float v){', 'The bullet speed per tick.'),
        'time_delta': f('float', 'dstvx /= Time.delta;', 'Time.delta in ticks: the frame delta scaled to 60fps ticks; the per-frame displacement is divided by it.'),
    }
    n2122_intercept_outputs = {
        'intercept_x': f('float', 'sol.set(dstx + dstvx * t, dsty + dstvy * t);', 'The intercept X: where the target will be when the bullet arrives.'),
        'intercept_y': f('float', 'sol.set(dstx + dstvx * t, dsty + dstvy * t);', 'The intercept Y: where the target will be when the bullet arrives.'),
        'intercept_time': f('float', 'float t = Math.min(t0, t1);', 'The smallest positive root: the ticks until the bullet meets the target.'),
        'used_intercept': f('bool', 'if(t > 0){', 'True when a positive root exists and the intercept point is used; false falls back to the current position.'),
    }
    n2122_quad_inputs = {
        'a': f('float', 'float a,', 'The quadratic a term (dstv^2 - v^2).'),
        'b': f('float', 'float b,', 'The quadratic b term (2 * (dstv . t)).'),
        'c': f('float', 'float c){', 'The quadratic c term (t^2).'),
    }
    n2122_quad_outputs = {
        'has_roots': f('bool', 'if(disc >= 0){', 'True when the discriminant is non-negative and roots exist.'),
        'root0': f('float', 'sol = vec.set((-b - disc) / a, (-b + disc) / a);', 'The first root (-b - disc) / 2a.'),
        'root1': f('float', 'sol = vec.set((-b - disc) / a, (-b + disc) / a);', 'The second root (-b + disc) / 2a.'),
    }
    n2122_target_position_inputs = {
        'game': f('Object', 'public void targetPosition(Posc pos){', 'The live game: the turret cell, its peeked ammo, the enemy type speed and the core position are read from it.', source=TURRET),
        'origin': f('Vector2', 'Predict.intercept(this, pos, offset.x, offset.y, bullet.speed)', 'The shooter: the turret build itself (`this`), passed as its grid cell and converted to its world position.', source=TURRET),
        'target': f('Dictionary', 'if(!hasAmmo() || pos == null) return;', 'The enemy target dict (sprite + type); null or ammo-less returns the current position.', source=TURRET),
    }
    n2122_target_position_outputs = {
        'target_position': f('Dictionary', 'targetPos.set(Predict.intercept(this, pos, offset.x, offset.y, bullet.speed));', 'The aim point: the intercept point when predictTarget holds, else the target current position.', source=TURRET),
        'used_intercept': f('bool', 'if(predictTarget && bullet.speed >= 0.01f){', 'True when the intercept ran (predictTarget and bullet.speed >= 0.01).', source=TURRET),
        'bullet_speed': f('float', 'bullet.speed >= 0.01f', 'The peeked bullet speed per tick; below 0.01 the aim falls back to the current position.', source=TURRET),
    }
    n2122_sweep_inputs = {
        'game': f('Object', 'void kill(){', 'The live game: its enemy list is swept for dead units.', source=HEALTH_COMP),
    }
    n2122_sweep_outputs = {
        'swept_count': f('int', 'if(health <= 0 && !dead){', 'How many enemies were swept this call (health <= 0 and not yet dead).', source=HEALTH_COMP),
        'swept_health': f('float', 'health = Math.min(health, 0);', 'The summed clamped health of the swept enemies.', source=HEALTH_COMP),
        'remaining_count': f('int', 'public void remove(){', 'How many enemies remain live after the sweep.', source=UNIT_COMP),
    }

    entries = [
        ('N2122', INTERCEPT_OWNER, 'source_predict_intercept_state', PREDICT, 'mindustry.entities.Predict', 'Predict.intercept(float, float, float, float, float, float, float)', n2122_intercept_inputs, n2122_intercept_outputs, True, 'Dictionary'),
        ('N2122', QUAD_OWNER, 'source_predict_quad_state', PREDICT, 'mindustry.entities.Predict', 'Predict.quad(float, float, float)', n2122_quad_inputs, n2122_quad_outputs, True, 'Dictionary'),
        ('N2122', TARGET_POSITION_OWNER, 'source_turret_target_position_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.targetPosition(Posc)', n2122_target_position_inputs, n2122_target_position_outputs, True, 'Dictionary'),
        ('N2122', SWEEP_OWNER, 'source_enemy_units_sweep_dead_state', HEALTH_COMP, 'mindustry.entities.comp.HealthComp', 'HealthComp.damage(float); HealthComp.kill(); UnitComp.killed(); UnitComp.remove()', n2122_sweep_inputs, n2122_sweep_outputs, True, 'Dictionary'),
    ]
    all_names = []
    for sid, owner, prefix, source, cls, method, inputs, outputs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                # N2029 symbol naming: schema name + '.' + field.
                symbol = name + '.' + field
                names.append(symbol)
                symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed C06 defense leg: Predict.intercept lead targeting and the death sweep.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed C06 defense leg: the turret leads its shots at the intercept point and dead enemies are swept from the live list, so a dagger crossing the duo field of fire dies before it reaches the core.'))
        all_names.extend(names)

    by_slice['N2122'] = sorted(all_names)
    # One slice row: the intercept is the primary owner; the quad,
    # the target position and the sweep share the slice (their
    # symbols carry their own owners). The one-line wiring changes
    # fold into this slice: find_enemy_target converts the turret
    # cell to its world position before the range check, the aim path
    # converts it before the angle, and the shot application converts
    # it before the bullet origin.
    source_symbols.upsert_source_slice(GODOT, 'N2122', dict(status='done', java_source=PREDICT, java_class='mindustry.entities.Predict', java_method='Predict.intercept(float, float, float, float, float, float, float); Predict.quad(float, float, float); TurretBuild.targetPosition(Posc); HealthComp.damage(float); HealthComp.kill(); UnitComp.killed(); UnitComp.remove()', godot_owner=INTERCEPT_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=sorted(all_names), tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
    main()
