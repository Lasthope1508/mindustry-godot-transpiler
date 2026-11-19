"""Register the TurretBuild findTarget / findEnemy / validateTarget / canHeal targeting (N2270).

TurretBuild.findTarget() / findEnemy() / validateTarget() /
canHeal() (Turret.java:631-663, `protected boolean
validateTarget(){` / `return !Units.invalidateTarget(target,
canHeal() ? Team.derelict : team, x, y) || controlled() ||
logicControlled();` (:631-633), `protected boolean
canHeal(){` / `return targetHealing && hasAmmo() &&
peekAmmo().collidesTeam && peekAmmo().heals();`
(:635-637), `protected Posc findEnemy(float range){`
(:639-649), `protected void findTarget(){` (:651-663)).
validateTarget calls Units.invalidateTarget with range
Float.MAX_VALUE (Units.java:160-162, `return
invalidateTarget(target, team, x, y, Float.MAX_VALUE);`),
so the within-range branch of invalidateTarget
(Units.java:151-158) is dead and only four observed flags
remain. findEnemy calls Units.bestEnemy for the air-only
branch (:641) and Units.bestTarget otherwise (:645-647);
bestTarget checks units first via bestEnemy and only then
buildings via findEnemyTile (Units.java:284-294), bestEnemy
picks by sort.cost with the targetPriority tie-break
(Units.java:318-338), the default sort is
UnitSorts.closest = Unit::dst2 (UnitSorts.java:11), and
the building fallback runs BlockIndexer.findEnemyTile
with the UnitSorts.buildingDefault priority
(UnitSorts.java:22). findTarget tries findEnemy(range),
then findEnemy(trackRange) only when
`!Mathf.equal(trackRange, range)` and no target yet, then
Units.findAllyTile when still null and canHeal() (:651-663);
Mathf.equal is an epsilon compare (Mathf.java:544-546,
`return Math.abs(a - b) <= FLOAT_ROUNDING_ERROR;`,
FLOAT_ROUNDING_ERROR = 0.000001f).

RED decisions (resolved at RED): (1) Five pure functions on
SourceTurretBuildState.gd next to the N2261 estimateDps /
N2308 warmup rows -- can_heal, invalidate_target,
validate_target, find_enemy, find_target. (2) All live
values arrive as explicit params (the N2188 precedent) --
range / track_range, hasAmmo / peekAmmo flags, controlled /
logicControlled, unitFilter / buildingFilter / unitSort via
candidate flags and the dst2 cost. (3) NO driver line:
updateTile calls findTarget() at :570 and validateTarget()
at :491/:573 -- the driver is its own later slice (the
N2244 fogRadius / N2261 estimateDps accessor precedent).
(4) The team passed to invalidateTarget is Team.derelict
when canHeal() holds, else the turret team -- the driver
computes target_same_team against that team; the pure
functions never hard-code a team id. (5)
SourceTurretTargetingState.gd is NOT reused: it only picks
the nearest candidate by distance and has no slice owner --
it lacks the predicate filters, the targetPriority
tie-break and the building fallback this slice ports.
(6) Deviations from the scope plan, all verified against
the real upstream: the scope's Turret.java path was
`defense/Turret.java` -- the real path is
`defense/turrets/Turret.java`; find_enemy takes an extra
`team_is_derelict` bool because bestEnemy/bestTarget
return null for a derelict team (Units.java:285/319);
unit candidates carry an extra `team_is_derelict` flag
because bestEnemy skips derelict-team units
(Units.java:326); building candidates carry an extra
`priority` (block.priority) because
BlockIndexer.findEnemyTile selects by
UnitSorts.buildingDefault priority, not nearest-only;
building within-range is computed in GD from dst2/hit_size
(`bdst = dst - hitSize/2 < range`, BlockIndexer.java:512-513)
because the scope's building shape had no within_range
flag. Five new result symbols: can_heal, target_invalid,
validate_target, find_enemy.target, find_target.target.
Slice sources: Turret.java + Units.java + UnitSorts.java +
BlockIndexer.java + BulletType.java + Mathf.java.
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
UNITS = 'core/src/mindustry/entities/Units.java'
UNIT_SORTS = 'core/src/mindustry/entities/UnitSorts.java'
BLOCK_INDEXER = 'core/src/mindustry/ai/BlockIndexer.java'
BULLET_TYPE = 'core/src/mindustry/entities/bullet/BulletType.java'
MATHF = 'arc-core/src/arc/math/Mathf.java'
PROOF = '/root/C07TurretFindTargetProof'
CAN_HEAL_OWNER = 'SourceTurretBuildState.source_turret_can_heal_state'
INVALIDATE_OWNER = 'SourceTurretBuildState.source_turret_invalidate_target_state'
VALIDATE_OWNER = 'SourceTurretBuildState.source_turret_validate_target_state'
FIND_ENEMY_OWNER = 'SourceTurretBuildState.source_turret_find_enemy_state'
FIND_TARGET_OWNER = 'SourceTurretBuildState.source_turret_find_target_state'
TESTS = ['test_c07_turret_find_target_registration', 'test_all_c07_turret_find_target_input_evidence_is_exact', 'test_turret_find_target_state', 'test_reference_graph_and_actual_c07_turret_find_target']
# The 6 slice sources the N2270 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files (arc-core sources live under arc-upstream).
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/entities/Units.java',
    'core/src/mindustry/entities/UnitSorts.java',
    'core/src/mindustry/ai/BlockIndexer.java',
    'core/src/mindustry/entities/bullet/BulletType.java',
    'arc-core/src/arc/math/Mathf.java',
]
EXACT_EXPRS = [
    'protected boolean validateTarget(){',
    'return !Units.invalidateTarget(target, canHeal() ? Team.derelict : team, x, y) || controlled() || logicControlled();',
    'protected boolean canHeal(){',
    'return targetHealing && hasAmmo() && peekAmmo().collidesTeam && peekAmmo().heals();',
    'protected Posc findEnemy(float range){',
    'if(targetAir && !targetGround){',
    'return Units.bestEnemy(team, x, y, range, e -> !e.dead() && !e.isGrounded() && unitFilter.get(e), unitSort);',
    'boolean buildings = targetGround && targetBlocks && (ammo == null || ammo.targetBlocks), missiles = ammo == null || ammo.targetMissiles;',
    'e -> !e.dead() && unitFilter.get(e) && (e.isGrounded() || targetAir) && (!e.isGrounded() || targetGround) && (missiles || !(e instanceof TimedKillc)),',
    'b -> buildings && buildingFilter.get(b), unitSort);',
    'protected void findTarget(){',
    'float trackRange = trackingRange(), range = range();',
    'target = findEnemy(range);',
    'if(!Mathf.equal(trackRange, range) && target == null){',
    'target = findEnemy(trackRange);',
    'if(target == null && canHeal()){',
    'target = Units.findAllyTile(team, x, y, range, b -> b.damaged() && b != this);',
    'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
    'public boolean targetHealing = false;',
    'public Sortf unitSort = UnitSorts.closest;',
    'public boolean controlled(){',
    'return unit.isPlayer();',
    'public boolean logicControlled(){',
    'return logicControlTime > 0;',
    'public @Nullable BulletType peekAmmo(){',
    'public boolean hasAmmo(){',
    'public static boolean invalidateTarget(Posc target, Team team, float x, float y, float range){',
    'return invalidateTarget(target, team, x, y, Float.MAX_VALUE);',
    '(target instanceof Teamc t && t.team() == team) ||',
    '(target instanceof Healthc h && !h.isValid()) ||',
    '(target instanceof Unit u && !u.targetable(team));',
    'public static Teamc bestTarget(Team team, float x, float y, float range, Boolf<Unit> unitPred, Boolf<Building> tilePred, Sortf sort){',
    'Unit unit = bestEnemy(team, x, y, range, unitPred, sort);',
    'return findEnemyTile(team, x, y, range, tilePred);',
    'public static Unit bestEnemy(Team team, float x, float y, float range, Boolf<Unit> predicate, Sortf sort){',
    'if(e.dead() || !predicate.get(e) || e.team == Team.derelict || !e.within(x, y, range + e.hitSize/2f) || !e.targetable(team) || e.inFogTo(team)) return;',
    'float cost = sort.cost(e, x, y);',
    'if((result == null || cost < cdist || e.type.targetPriority > cpriority) && e.type.targetPriority >= cpriority){',
    'public static Building findAllyTile(Team team, float x, float y, float range, Boolf<Building> pred){',
    'return indexer.findTile(team, x, y, range, pred);',
    'public static Building findEnemyTile(Team team, float x, float y, float range, Boolf<Building> pred){',
    'closest = Unit::dst2,',
    'buildingDefault = b -> b.block.priority,',
    'float dist = candidate.dst(x, y) - candidate.hitSize() / 2f;',
    'float bdst = next.dst(x, y) - next.hitSize() / 2f;',
    'if(bdst < range && (closest == null ||',
    'public boolean collidesTeam = false;',
    'public boolean heals(){',
    'return Math.abs(a - b) <= FLOAT_ROUNDING_ERROR;',
    'public static final float FLOAT_ROUNDING_ERROR = 0.000001f; // 32 bits',
]

# DEFERRED is carried from the N2308 register script via import --
# never retyped. Nothing in it closes here: findTarget was never a
# deferred entry of the Turret chain. Five entries are added: the
# N2270 Windows Godot proof debt (GOAL.md section 5), the
# findTarget/validateTarget driver tick lines, the live Units
# queries (driver-side observed-dict stamping), the
# SourceTurretTargetingState.gd non-reuse note, and the
# trackingRange / hasAmmo / peekAmmo follow-ups.
DEFERRED = N2308_DEFERRED + [
    'Turret findTarget() Windows Godot proof -- debt in GOAL.md section 5, same as N2148/N2227: the N2270 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Wire the Turret findTarget/validateTarget driver tick lines (source_turret_tick_buildings_state) once the tick frame tracks target / is_shooting / controlled / logicControlled; N2270 is pure-function-only (the N2294 updateTile precedent). updateTile calls findTarget() at Turret.java:570 and validateTarget() at :491/:573.',
    'Port the live Units queries (Units.nearbyEnemies scan, BlockIndexer.findEnemyTile/findTile, Units.inFogTo) as driver-side observed-dict stamping; N2270 selects from observed dicts only and proves no live query.',
    'SourceTurretTargetingState.gd target_selection_state is NOT the findTarget port: it only picks the nearest candidate by distance, with no predicate filters, no targetPriority tie-break and no building fallback; it has no slice owner and must not be wired as the TurretBuild targeting path.',
    'Port TurretBuild.trackingRange() (Turret.java:349-351) and range() (N740) as explicit values; N2270 takes range/track_range as explicit floats. Port TurretBuild.hasAmmo() (Turret.java:698-712, ammo-swap side effect) and peekAmmo() (Turret.java:693-695) as their own slices; N2270 takes their flags explicitly.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    can_heal_inputs = {
        'frame': a('Dictionary', 'protected boolean canHeal(){', 'The turret frame (accepted for the family call shape; this leg reads no live frame key -- all live values arrive as explicit params, the N2188 per-def-param precedent, because the tick frame tracks no ammo state yet).'),
        'target_healing': a('bool', 'public boolean targetHealing = false;', 'Whether the turret heals instead of damaging: the Turret def flag targetHealing (Turret.java:95), default false; passed explicitly because it is per-def static state, not a live frame key.'),
        'has_ammo': a('bool', 'public boolean hasAmmo(){', 'Whether the turret has usable ammo: the TurretBuild.hasAmmo() gate (Turret.java:698-712, ammo-swap side effect, canConsume gate); passed explicitly because hasAmmo() has a side effect and the tick frame tracks no ammo state yet.'),
        'peek_collides_team': a('bool', 'public boolean collidesTeam = false;', 'Whether the peeked bullet collides with its own team: BulletType.collidesTeam (BulletType.java:127), default false; passed explicitly because peekAmmo() (Turret.java:693) is not ported here.', source=BULLET_TYPE),
        'peek_heals': a('bool', 'public boolean heals(){', 'Whether the peeked bullet heals: BulletType.heals() (BulletType.java:447); passed explicitly because peekAmmo() (Turret.java:693) is not ported here.', source=BULLET_TYPE),
    }
    can_heal_outputs = {
        'can_heal': a('bool', 'return targetHealing && hasAmmo() && peekAmmo().collidesTeam && peekAmmo().heals();', 'Whether this turret can heal: targetHealing && hasAmmo() && peekAmmo().collidesTeam && peekAmmo().heals() (Turret.java:635-637); hasAmmo() short-circuits first in Java, so a null peek never reaches the field reads.'),
    }
    invalidate_inputs = {
        'frame': a('Dictionary', 'public static boolean invalidateTarget(Posc target, Team team, float x, float y, float range){', 'The turret frame (accepted for the family call shape; this leg reads no live frame key -- the four invalidation flags arrive as explicit params, the N2188 precedent).', source=UNITS),
        'target_is_null': a('bool', 'return target == null ||', 'Whether the target is null: the first disjunct of Units.invalidateTarget (Units.java:152); the driver computes it from the live target reference.', source=UNITS),
        'target_same_team': a('bool', '(target instanceof Teamc t && t.team() == team) ||', 'Whether the target is a Teamc on the team argument: the third disjunct of Units.invalidateTarget (Units.java:154); the team argument is Team.derelict when canHeal() holds, else the turret team (Turret.java:632) -- the driver computes this flag against that team, never a hard-coded team id.', source=UNITS),
        'target_health_invalid': a('bool', '(target instanceof Healthc h && !h.isValid()) ||', 'Whether the target is a Healthc that is not valid: the fourth disjunct of Units.invalidateTarget (Units.java:155); the driver computes it from the live target health state.', source=UNITS),
        'target_unit_not_targetable': a('bool', '(target instanceof Unit u && !u.targetable(team));', 'Whether the target is a Unit that is not targetable by the team argument: the fifth disjunct of Units.invalidateTarget (Units.java:156); the driver computes it from the live unit state.', source=UNITS),
    }
    invalidate_outputs = {
        'target_invalid': a('bool', 'public static boolean invalidateTarget(Posc target, Team team, float x, float y){', 'Whether the target is invalid: the 4-arg overload validateTarget() calls (Units.java:160-162), which forwards with range Float.MAX_VALUE so the within-range branch (Units.java:153) is dead and only the four observed flags remain.', source=UNITS),
    }
    validate_inputs = {
        'frame': a('Dictionary', 'protected boolean validateTarget(){', 'The turret frame (accepted for the family call shape; this leg reads no live frame key -- the invalidation flag and the control flags arrive as explicit params, the N2188 precedent).'),
        'target_invalid': a('bool', 'return !Units.invalidateTarget(target, canHeal() ? Team.derelict : team, x, y) || controlled() || logicControlled();', 'Whether the current target is invalid: the Units.invalidateTarget result (Turret.java:632), computed by source_turret_invalidate_target_state against the derelict team when canHeal() holds, else the turret team.'),
        'is_controlled': a('bool', 'public boolean controlled(){', 'Whether a player controls the turret unit: TurretBuild.controlled() (Turret.java:441-443, `return unit.isPlayer();`); passed explicitly because the tick frame tracks no unit/player key yet.'),
        'is_logic_controlled': a('bool', 'public boolean logicControlled(){', 'Whether logic controls the turret: TurretBuild.logicControlled() (Turret.java:445-447, `return logicControlTime > 0;`); passed explicitly because the tick frame tracks no logic key yet.'),
    }
    validate_outputs = {
        'validate_target': a('bool', 'return !Units.invalidateTarget(target, canHeal() ? Team.derelict : team, x, y) || controlled() || logicControlled();', 'Whether the target stays valid: (not target_invalid) or is_controlled or is_logic_controlled (Turret.java:631-633); an invalid target is kept only while a player or logic controls the turret.'),
    }
    find_enemy_inputs = {
        'frame': a('Dictionary', 'protected Posc findEnemy(float range){', 'The turret frame (accepted for the family call shape; this leg reads no live frame key -- the range, the def flags, the ammo flags and the observed candidate lists arrive as explicit params, the N2188 precedent).'),
        'team_is_derelict': a('bool', 'if(team == Team.derelict) return null;', 'Whether the turret team is derelict: Units.bestTarget/bestEnemy return null for a derelict team (Units.java:285/319); passed explicitly because the tick frame tracks no team key yet.', source=UNITS),
        'range': a('float', 'return Units.bestEnemy(team, x, y, range, e -> !e.dead() && !e.isGrounded() && unitFilter.get(e), unitSort);', 'The standard targeting range in world pixels: TurretBuild.range() (Turret.java:342-345, N740); passed explicitly because range() reads peekAmmo() and the tick frame tracks no ammo state yet.'),
        'target_air': a('bool', 'if(targetAir && !targetGround){', 'Whether the turret targets air: the Turret def flag targetAir (Turret.java:89), default true; passed explicitly because it is per-def static state, not a live frame key.'),
        'target_ground': a('bool', 'e -> !e.dead() && unitFilter.get(e) && (e.isGrounded() || targetAir) && (!e.isGrounded() || targetGround) && (missiles || !(e instanceof TimedKillc)),', 'Whether the turret targets ground: the Turret def flag targetGround (Turret.java:91), default true; passed explicitly because it is per-def static state, not a live frame key.'),
        'target_blocks': a('bool', 'boolean buildings = targetGround && targetBlocks && (ammo == null || ammo.targetBlocks), missiles = ammo == null || ammo.targetMissiles;', 'Whether the turret targets blocks: the Turret def flag targetBlocks (Turret.java:93), default true; gates the building fallback together with targetGround and the ammo targetBlocks flag (Turret.java:644).'),
        'ammo_is_null': a('bool', 'var ammo = peekAmmo();', 'Whether the peeked ammo is null: peekAmmo() (Turret.java:693, `public @Nullable BulletType peekAmmo(){`); a null ammo makes both missiles and buildings true (Turret.java:644); passed explicitly because peekAmmo() is not ported here.'),
        'ammo_target_blocks': a('bool', 'boolean buildings = targetGround && targetBlocks && (ammo == null || ammo.targetBlocks), missiles = ammo == null || ammo.targetMissiles;', 'Whether the peeked ammo targets blocks: BulletType.targetBlocks, read through peekAmmo() (Turret.java:644); passed explicitly because peekAmmo() is not ported here.'),
        'ammo_target_missiles': a('bool', 'boolean buildings = targetGround && targetBlocks && (ammo == null || ammo.targetBlocks), missiles = ammo == null || ammo.targetMissiles;', 'Whether the peeked ammo targets missiles: BulletType.targetMissiles, read through peekAmmo() (Turret.java:644); a false value excludes timed-kill units (TimedKillc) from the general branch (Turret.java:646).'),
        'unit_candidates': a('Array', 'public static Unit bestEnemy(Team team, float x, float y, float range, Boolf<Unit> predicate, Sortf sort){', 'The observed enemy-unit candidates: each dict carries dead, team_is_derelict, within_range (e.within(x, y, range + hitSize/2), Units.java:326), targetable, in_fog, unit_filter, is_grounded, is_timed_kill, dst2 (the UnitSorts.closest cost, UnitSorts.java:11), target_priority and hit_size, plus an id key so the driver can resolve the chosen dict (the N2242 observed-dict precedent); the live nearbyEnemies scan stays on the driver side.', source=UNITS),
        'building_candidates': a('Array', 'public static Building findEnemyTile(Team team, float x, float y, float range, Boolf<Building> pred){', 'The observed enemy-building candidates: each dict carries building_filter, priority (block.priority, UnitSorts.buildingDefault, UnitSorts.java:22), dst2 and hit_size, plus an id key; the within-range check (bdst = dst - hitSize/2 < range, BlockIndexer.java:512-513) is computed in GD from dst2/hit_size; the live indexer.findEnemyTile scan stays on the driver side.', source=UNITS),
    }
    find_enemy_outputs = {
        'target': a('Dictionary', 'public static Teamc bestTarget(Team team, float x, float y, float range, Boolf<Unit> unitPred, Boolf<Building> tilePred, Sortf sort){', 'The chosen target, or null: the bestEnemy winner when any unit passes (Units.java:287-289), else the findEnemyTile winner when buildings are considered (Units.java:290-291), else null; the returned value is the chosen observed dict itself.', source=UNITS),
    }
    find_target_inputs = {
        'frame': a('Dictionary', 'protected void findTarget(){', 'The turret frame (accepted for the family call shape; this leg reads no live frame key -- the ranges and the found targets arrive as explicit params, the N2188 precedent).'),
        'range': a('float', 'float trackRange = trackingRange(), range = range();', 'The standard targeting range in world pixels: TurretBuild.range() (Turret.java:342-345, N740); passed explicitly because range() reads peekAmmo() and the tick frame tracks no ammo state yet.'),
        'track_range': a('float', 'float trackRange = trackingRange(), range = range();', 'The tracking range in world pixels: TurretBuild.trackingRange() (Turret.java:349-351, `return range() + trackingRange - range;`); passed explicitly because trackingRange() is not ported yet.'),
        'found_standard': a('Variant', 'target = findEnemy(range);', 'The target found in the standard range: the driver findEnemy(range) result (Turret.java:654), an observed dict or null; always preferred over the tracking-range target.'),
        'found_track': a('Variant', 'target = findEnemy(trackRange);', 'The target found in the tracking range: the driver findEnemy(trackRange) result (Turret.java:657), an observed dict or null; tried only when the ranges differ and no standard target was found.'),
        'can_heal': a('bool', 'if(target == null && canHeal()){', 'Whether the turret can heal: the canHeal() result (Turret.java:635-637), computed by source_turret_can_heal_state; gates the ally-tile fallback (Turret.java:661).'),
        'ally_tile': a('Variant', 'target = Units.findAllyTile(team, x, y, range, b -> b.damaged() && b != this);', 'The ally tile to heal: the driver Units.findAllyTile result (Turret.java:662, `b -> b.damaged() && b != this`), an observed dict or null; the live indexer.findTile scan stays on the driver side.'),
    }
    find_target_outputs = {
        'target': a('Dictionary', 'if(!Mathf.equal(trackRange, range) && target == null){', 'The target after the fallback chain: the standard-range target when present, else the tracking-range target when the ranges differ (Mathf.equal epsilon 0.000001f, Mathf.java:544-546/10), else the ally tile when canHeal() holds, else null (Turret.java:651-663).'),
    }
    return can_heal_inputs, can_heal_outputs, invalidate_inputs, invalidate_outputs, validate_inputs, validate_outputs, find_enemy_inputs, find_enemy_outputs, find_target_inputs, find_target_outputs


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
    can_heal_inputs, can_heal_outputs, invalidate_inputs, invalidate_outputs, validate_inputs, validate_outputs, find_enemy_inputs, find_enemy_outputs, find_target_inputs, find_target_outputs = definitions()

    entries = [
        ('N2270', CAN_HEAL_OWNER, 'source_turret_can_heal_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.canHeal()', can_heal_inputs, can_heal_outputs, True, 'Dictionary'),
        ('N2270', INVALIDATE_OWNER, 'source_turret_invalidate_target_state', UNITS, 'mindustry.entities.Units', 'Units.invalidateTarget(Posc, Team, float, float, float)', invalidate_inputs, invalidate_outputs, True, 'Dictionary'),
        ('N2270', VALIDATE_OWNER, 'source_turret_validate_target_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.validateTarget()', validate_inputs, validate_outputs, True, 'Dictionary'),
        ('N2270', FIND_ENEMY_OWNER, 'source_turret_find_enemy_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.findEnemy(float)', find_enemy_inputs, find_enemy_outputs, True, 'Dictionary'),
        ('N2270', FIND_TARGET_OWNER, 'source_turret_find_target_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.findTarget()', find_target_inputs, find_target_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed TurretBuild findTarget/findEnemy/validateTarget/canHeal state from Turret.java + Units.java + UnitSorts.java + BlockIndexer.java + BulletType.java + Mathf.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed TurretBuild findTarget/findEnemy/validateTarget/canHeal state from Turret.java + Units.java + UnitSorts.java + BlockIndexer.java + BulletType.java + Mathf.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: can_heal, target_invalid,
    # validate_target, find_enemy.target, find_target.target.
    by_slice['N2270'] = [
        'source_turret_can_heal_state_result.can_heal',
        'source_turret_invalidate_target_state_result.target_invalid',
        'source_turret_validate_target_state_result.validate_target',
        'source_turret_find_enemy_state_result.target',
        'source_turret_find_target_state_result.target',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2270', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.findTarget(); TurretBuild.findEnemy(float); TurretBuild.validateTarget(); TurretBuild.canHeal()', godot_owner=FIND_TARGET_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2270'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
