"""Register the ShieldWall damage() coupling (N2203).

The ShieldWall's damage() coupling, following the N2202 pure-function
pattern. N2202 closed the broken() half (ShieldWall.java:91-92,
`return breakTimer > 0 || !canConsume();`) with one pure function over
the break timer and the live potential efficiency, but left the damage
path unmodeled with a documented limit: damage()
(ShieldWall.java:100-117) reads broken() to decide how much of the
incoming damage the shield absorbs (`float shieldTaken = broken() ?
0f : Math.min(shield, damage);`, ShieldWall.java:102), drops the shield
by the absorbed amount, flashes hit when anything was absorbed, sets
breakTimer = breakCooldown when the shield breaks, and passes only the
leftover damage to super.damage -- yet the port had no damage function
at all, so a shield wall hit by a bullet would take the full damage
straight to building health as if it had no shield. N2203 closes the
damage() half with one pure function
(source_shield_wall_damage_state) over the frame keys (`shield`, `hit`,
`break_timer`, `potential_efficiency`) plus the incoming damage, reusing
the N2202 broken() coupling instead of re-implementing it. RED
decisions (pinned by this slice): when the frame carries NO `shield`
key, default to shieldHealth 900.0 (the Java field init,
ShieldWall.java:44, `public float shield = shieldHealth, shieldRadius
= 0f;`, shieldHealth 900f, ShieldWall.java:15) -- absent means "shield
never damaged yet", not "shield gone"; when the frame carries NO `hit`
key, default to 0.0 (the WallBuild field default, Wall.java:89,
`protected float hit;`); the `break_timer` / `potential_efficiency`
defaults are the N2202 ones (0.0 / 1.0). The residual damage is
returned for the caller; applying it to building health (super.damage,
BuildingComp.java:2059-2080, modeled by SourceBuildingDamageState)
waits for a live damage call site -- no ShieldWall damage caller exists
in the port yet. damage() is event-driven, not a tick, so there is no
driver line in the tick and no live-tick proof keys; the proof calls the
pure function directly with synthetic frames. Shard change expected: the
defense shard selects java_source paths under /world/blocks/defense/
and ShieldWall.java lives there -- defense_slices 165 -> 166,
defense_api_contracts 164 -> 165 (verify at the GREEN register run).

Composition, not re-implementation: the N2202 broken() coupling
(SourceShieldWallBuildState.source_shield_wall_broken_state) already
models ShieldWallBuild.broken() over break_timer and
potential_efficiency, and SourceBuildingDamageState already models the
BuildingComp.damage(float) super.damage target; N2203 does not touch
either. N2203 supplies the missing pure damage() coupling; no new
consumer rows, no tick change. The shield wall's power draw stays
static (ConsumePower 3f / 60f = 0.05), so the folded efficiency is the
min over the *modeled* consumers (power only). No updateTile advance:
the breakTimer decay / shield regen / hit decay / shieldRadius lerp
(ShieldWall.java:74-89) waits for its own slice; the proof carries no
shield-regen keys. Single def (shielded-wall, size 2, health 260 *
wallHealthMultiplier * 4, armor 15f, chanceDeflect 8f,
Blocks.java:1903-1916).
"""
import ast
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
SHIELD_WALL = 'core/src/mindustry/world/blocks/defense/ShieldWall.java'
WALL = 'core/src/mindustry/world/blocks/defense/Wall.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
CONSUME_POWER = 'core/src/mindustry/world/consumers/ConsumePower.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07ShieldWallDamageProof'
OWNER = 'SourceShieldWallBuildState.source_shield_wall_damage_state'
TESTS = ['test_c07_shield_wall_damage_registration', 'test_all_c07_shield_wall_damage_input_evidence_is_exact', 'test_shield_wall_damage_state', 'test_reference_graph_and_actual_c07_shield_wall_damage']
EXACT_EXPRS = ['public void damage(float damage){', 'float shieldTaken = broken() ? 0f : Math.min(shield, damage);', 'shield -= shieldTaken;', 'if(shieldTaken > 0){', 'hit = 1f;', 'if(shield <= 0.00001f && shieldTaken > 0){', 'breakTimer = breakCooldown;', 'if(damage - shieldTaken > 0){', 'super.damage(damage - shieldTaken);', 'public boolean broken(){', 'return breakTimer > 0 || !canConsume();', 'public float breakTimer;', 'public float shieldHealth = 900f;', 'public float breakCooldown = 60f * 10f;', 'public float regenSpeed = 2f;', 'public float shield = shieldHealth, shieldRadius = 0f;', 'public class ShieldWall extends Wall{', 'public class ShieldWallBuild extends WallBuild{', 'protected float hit;', 'public boolean canConsume(){', 'return potentialEfficiency > 0;', 'transient float potentialEfficiency;', 'if(dead()) return;', 'health -= handleDamage(damage);', 'if(health <= 0){', 'return build.power.status;', 'consumePower(3f / 60f);', 'update = true;', 'shield = Mathf.clamp(shield + regenSpeed * edelta(), 0f, shieldHealth);', 'shieldRadius = Mathf.lerpDelta(shieldRadius, broken() ? 0f : 1f, 0.12f);']

# DEFERRED is carried from the N2175 register script via AST --
# never retyped. The N2175 script's DEFERRED is a plain list
# literal, so ast.literal_eval recovers it verbatim. The N2202
# script's DEFERRED is NOT a plain literal (it is a comprehension
# over the N2175 list plus a literal tail), so it cannot be
# literal_eval'd whole -- instead the N2202 replacement is applied
# here in code and the N2202 tail (its 3 new entries) is recovered
# by literal_eval of the right side of its BinOp. The N2202 entry
# for the damage rows is then REPLACED (not carried): N2203 closes
# the damage() half, so the entry now records damage() as done and
# the residual super.damage wiring as still deferred. The new N2203
# entries below are the handoff's deferred items that are not
# already in that list.
_N2175_REGISTER = Path(__file__).resolve().parent / 'register_c07_shield_wall_power_status.py'
_N2175_DEFERRED = next(
    ast.literal_eval(node.value)
    for node in ast.walk(ast.parse(_N2175_REGISTER.read_text(encoding='utf-8')))
    if isinstance(node, ast.Assign)
    and any(isinstance(target, ast.Name) and target.id == 'DEFERRED' for target in node.targets)
)
_N2202_REGISTER = Path(__file__).resolve().parent / 'register_c07_shield_wall_broken.py'
_N2202_NEW = next(
    ast.literal_eval(node.value.right)
    for node in ast.walk(ast.parse(_N2202_REGISTER.read_text(encoding='utf-8')))
    if isinstance(node, ast.Assign)
    and any(isinstance(target, ast.Name) and target.id == 'DEFERRED' for target in node.targets)
)


def _n2202_deferred(entry):
    if entry.startswith('ShieldWall broken() / damage rows'):
        return 'ShieldWall broken() coupling -- DONE in N2202 (source_shield_wall_broken_state, ShieldWall.java:91-93, broken() returns breakTimer > 0 || !canConsume() with canConsume() from BuildingComp.java:1917-1919); damage() rows (damage absorbs min(shield, damage) and sets breakTimer = breakCooldown when the shield breaks, ShieldWall.java:101-117) still wait for their own slice.'
    return entry


def _n2203_deferred(entry):
    if entry.startswith('ShieldWall broken() coupling -- DONE in N2202'):
        return 'ShieldWall damage() coupling -- DONE in N2203 (source_shield_wall_damage_state, ShieldWall.java:100-117, damage() absorbs min(shield, damage) when whole, flashes hit, sets breakTimer = breakCooldown when the shield breaks, and returns the residual for super.damage); the residual super.damage wiring (applying residual_damage to building health via BuildingComp.damage(float), BuildingComp.java:2059-2080) still waits for a live damage call site -- no ShieldWall damage caller exists in the port yet.'
    return entry


DEFERRED = [_n2203_deferred(_n2202_deferred(entry)) for entry in _N2175_DEFERRED] + _N2202_NEW + [
    'ShieldWall damage() residual super.damage wiring -- the N2203 pure function returns residual_damage for the caller but no driver or bullet path applies it to building health yet (super.damage is BuildingComp.damage(float), BuildingComp.java:2059-2080, modeled by SourceBuildingDamageState); the caller wiring waits for a live damage call site slice.',
    'ShieldWall damage() live shield / hit stamping -- the N2203 pure function reads frame shield (absent defaults to shieldHealth 900.0) and hit (absent defaults to 0.0) as proof-stamped observations; the future updateTile-advance slice stamps shield live (regen, ShieldWall.java:80) and hit live (decay, ShieldWall.java:83-86), and the read/write slice stamps shield on load (ShieldWall.java:119-130).',
    'ShieldWall damage() Windows Godot proof -- debt in GOAL.md section 5, same as N2175-N2202: the N2203 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def main():
    symbols = {}

    def f(typ, expr, rule, source=SHIELD_WALL, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2203_inputs = {
        'frame': f('Dictionary', 'float shieldTaken = broken() ? 0f : Math.min(shield, damage);', 'The building frame carrying the shield observation (ShieldWall.java:44, `public float shield = shieldHealth, shieldRadius = 0f;`, shieldHealth 900f, ShieldWall.java:15), the hit flash (Wall.java:89, `protected float hit;`), the break_timer observation (ShieldWall.java:45, `public float breakTimer;`) and the potential_efficiency observation stamped by the N2175 machinery (BuildingComp.java:1989, `potentialEfficiency = efficiency;`); a missing shield key means the shield was never damaged yet (900.0), a missing hit key means no flash (0.0), a missing break_timer key means no break in progress (0.0), a missing potential_efficiency key means no machinery run yet (1.0, not "no power").'),
        'damage': f('float', 'public void damage(float damage){', 'The incoming damage amount (ShieldWall.java:100, `public void damage(float damage){`); the shield absorbs min(shield, damage) of it when the wall is whole, the rest is the residual for super.damage.'),
    }
    n2203_outputs = {
        'shield_taken': f('float', 'float shieldTaken = broken() ? 0f : Math.min(shield, damage);', 'The damage absorbed by the shield (ShieldWall.java:102): 0 when broken() is true, else min(shield, damage); broken() is the N2202 coupling (ShieldWall.java:91-93) over break_timer and canConsume() (BuildingComp.java:1917-1919).'),
        'shield': f('float', 'shield -= shieldTaken;', 'The shield left after the hit (ShieldWall.java:104): the incoming shield minus shield_taken, from the field init shieldHealth 900f (ShieldWall.java:44-45, 15); 0.0 when the shield breaks.'),
        'hit': f('float', 'protected float hit;', 'The hit flash (ShieldWall.java:105-106, `if(shieldTaken > 0){` / `hit = 1f;`, hit declared in WallBuild, Wall.java:89, `protected float hit;`): 1.0 when anything was absorbed, otherwise the incoming hit value unchanged.', source=WALL),
        'break_timer': f('float', 'breakTimer = breakCooldown;', 'The break timer after the hit (ShieldWall.java:109-110, `if(shield <= 0.00001f && shieldTaken > 0){` / `breakTimer = breakCooldown;`, breakCooldown 60f * 10f, ShieldWall.java:16): breakCooldown when the shield was driven to zero by this hit, otherwise the incoming break_timer unchanged.'),
        'residual_damage': f('float', 'super.damage(damage - shieldTaken);', 'The leftover damage for super.damage (ShieldWall.java:113-114, `if(damage - shieldTaken > 0){` / `super.damage(damage - shieldTaken);`): damage minus shield_taken; super.damage is BuildingComp.damage(float) (BuildingComp.java:2059-2080, `if(dead()) return;` / `health -= handleDamage(damage);` / `if(health <= 0){`). Returned for the caller -- no live damage call site applies it yet.'),
    }

    entries = [
        ('N2203', OWNER, 'source_shield_wall_damage_state', SHIELD_WALL, 'mindustry.world.blocks.defense.ShieldWall.ShieldWallBuild', 'ShieldWallBuild.damage(float)', n2203_inputs, n2203_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed ShieldWall damage() coupling from ShieldWall.java / Wall.java / BuildingComp.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed ShieldWall damage() coupling from ShieldWall.java / Wall.java / BuildingComp.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the absorbed amount, the shield
    # left, the hit flash, the break timer, the residual damage.
    by_slice['N2203'] = [
        'source_shield_wall_damage_state_result.shield_taken',
        'source_shield_wall_damage_state_result.shield',
        'source_shield_wall_damage_state_result.hit',
        'source_shield_wall_damage_state_result.break_timer',
        'source_shield_wall_damage_state_result.residual_damage',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2203', dict(status='done', java_source=SHIELD_WALL, java_class='mindustry.world.blocks.defense.ShieldWall.ShieldWallBuild', java_method='ShieldWallBuild.damage(float)', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2203'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
