"""Register the Turret family live-loop tick and placement frame binding (N2108).

The turret family's own tick did not exist in the live loop: drills,
pumps, conduits and the ContinuousLiquidTurret ticked every
simulate_factory tick, but a placed duo or lancer never had its frame
keys refreshed, so its cheating flag stayed at the false default and
TurretBuild.useAmmo() could never take its cheating branch live. N2108
wires the family tick the way N2102/N2103 wired the
ContinuousLiquidTurret tick: the frame is bound at placement and the
driver refreshes its keys from the live rules every tick.

Java: a placed block's Building is created by Block.newBuilding()
(Block.java:1002); the port's frame is that Building state, bound on
the sprite at placement through the Tile.setBlock proximity path (the
same path that binds the drill frame). Every tick the live loop runs
TurretBuild.updateTile() (Turret.java:490); ItemTurretBuild,
LiquidTurretBuild and PowerTurretBuild do not override updateTile, and
LaserTurretBuild/ContinuousTurretBuild call super.updateTile() first
(LaserTurret.java:67-68, ContinuousTurret.java:86-87), so that tick is
the family tick. The tick refreshes the frame's cheating flag from the
live rules (TeamComp.cheating(), TeamComp.java:17-19, through N2099's
helper), and TurretBuild.useAmmo() reads it (Turret.java:682,
`if(cheating()) return peekAmmo();`): a cheating ItemTurret fires
without spending ammo, while a non-cheating one spends ammoPerShot
(entry.amount -= ammoPerShot, pop when empty, totalAmmo -=
ammoPerShot clamped at 0, return entry.type()). ItemTurretBuild does
not override useAmmo, so the base implementation is the one the duo
runs; LiquidTurretBuild and PowerTurretBuild override it with their
own cheating branches (N1201, N1170) and never reach this path.
ContinuousLiquidTurret has its own frame and driver (N2103) and is
skipped here; PointDefenseTurret extends ReloadTurret,
TractorBeamTurret extends BaseTurret, RepairTurret extends Block and
BuildTurret extends BaseTurret, so none of them is a TurretBuild.
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
ITEM_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java'
LIQUID_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/LiquidTurret.java'
POWER_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/PowerTurret.java'
LASER_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/LaserTurret.java'
CONTINUOUS_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java'
BLOCK = 'core/src/mindustry/world/Block.java'
TILE = 'core/src/mindustry/world/Tile.java'
TEAM_COMP = 'core/src/mindustry/entities/comp/TeamComp.java'
TICK_FRAME_OWNER = 'SourceTurretBuildState.source_turret_tick_frame_state'
BIND_OWNER = 'SourceTurretBuildState.source_turret_bind_frame_state'
TICK_OWNER = 'SourceTurretBuildState.source_turret_tick_buildings_state'
USE_AMMO_OWNER = 'SourceTurretBuildState.source_turret_use_ammo_state'
PROOF = '/root/TurretLiveLoopProof'
TESTS = ['test_turret_live_loop_registration', 'test_all_turret_live_loop_input_evidence_is_exact', 'test_tick_wires_frame_and_use_ammo_reads_cheating', 'test_reference_graph_and_actual_turret_live_loop']
DEFERRED = [
    'Threading the frame cheating flag into TurretBuild.hasAmmo() (Turret.java:712, `|| cheating()`) so a cheating turret counts as having ammo with less than ammoPerShot is a later slice; useAmmo is the consumption skip wired here.',
    'Wiring the factory family tick to the live cheating value is a later slice.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'public class Turret extends ReloadTurret{',
    'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
    'public void updateTile(){',
    'if(cheating()) return peekAmmo();',
    'AmmoEntry entry = ammo.peek();',
    'entry.amount -= ammoPerShot;',
    'if(entry.amount <= 0) ammo.pop();',
    'totalAmmo -= ammoPerShot;',
    'totalAmmo = Math.max(totalAmmo, 0);',
    'return entry.type();',
    'return ammo.size == 0 ? null : ammo.peek().type();',
    'public final Building newBuilding(){',
    'public boolean cheating(){',
    'return team.rules().cheat;',
    'public class ItemTurret extends Turret{',
    'public class LiquidTurret extends Turret{',
    'public class PowerTurret extends Turret{',
    'public class LaserTurret extends PowerTurret{',
    'public class ContinuousTurret extends Turret{',
    'super.updateTile();',
]


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2108_tick_frame_inputs = {
        'frame': f('Dictionary', 'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{', 'The turret frame (the port Building state) the tick wires every tick.'),
        'block_implementation': f('String', 'public class Turret extends ReloadTurret{', "The block's implementation, from block.implementation like the drill tick sets it (N2097); the driver only ticks TurretBuild implementations."),
        'team_id': f('int', 'public boolean cheating(){', "The building's team id, from the sprite's team meta; cheating() reads this team's TeamRule.", source=TEAM_COMP),
        'rules_state': f('Dictionary', 'return team.rules().cheat;', 'The live game rules (Vars.state.rules, N2098), returned as-is so the cheat read stays live.', source=TEAM_COMP),
    }
    n2108_tick_frame_outputs = {
        'frame': f('Dictionary', 'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{', 'The wired frame, with block_implementation, team_id, rules_state and the live cheating flag set.'),
    }
    n2108_bind_inputs = {
        'sprite': f('Sprite2D', 'public final Building newBuilding(){', 'The placed Building sprite; only a Turret-family sprite gets a frame bound at placement.', source=BLOCK),
        'block': f('Object', 'public class ItemTurret extends Turret{', 'The typed block definition; the frame binds only when its implementation is a TurretBuild (ItemTurret, LiquidTurret, PowerTurret, LaserTurret, ContinuousTurret).', source=ITEM_TURRET),
    }
    n2108_bind_outputs = {
        'applied': f('bool', 'public final Building newBuilding(){', 'Whether the frame was actually bound at placement; false for any other block or an already-bound sprite.', source=BLOCK),
        'frame': f('Dictionary', 'public final Building newBuilding(){', 'The bound frame -- the port Building state created at placement (Block.newBuilding); empty until the live-loop tick fills its keys.', source=BLOCK),
    }
    n2108_tick_inputs = {
        'game': f('Object', 'build.onProximityUpdate();', 'The live game world: the placed-building index, the content catalog and the live rules the tick reads every tick.', source=TILE),
        'seconds': f('float', 'public void updateTile(){', 'The frame delta; the wiring itself only refreshes keys, so the delta is carried for the later shooting/consumption slices.'),
    }
    n2108_tick_outputs = {
        'ticked_count': f('int', 'public void updateTile(){', 'How many placed Turret-family builds had their frame keys refreshed this tick.'),
        'results_by_cell': f('Dictionary', 'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{', 'Per-cell wired frames, keyed by the game cell key like the drill tick results; a cell maps to its refreshed frame dict.'),
    }
    n2108_use_ammo_inputs = {
        'frame': f('Dictionary', 'if(cheating()) return peekAmmo();', 'The turret frame; its cheating flag decides whether the shot consumes ammo.'),
        'turret_properties': f('Dictionary', 'public BulletType useAmmo(){', "The block's registry properties (ammoPerShot, the ammo entries) the peek and the consumption read."),
        'stacks': f('Array', 'AmmoEntry entry = ammo.peek();', 'The ammo stacks (AmmoEntry list) the shot consumes from when not cheating.'),
        'total_ammo': f('int', 'totalAmmo -= ammoPerShot;', 'The total ammo before the shot; decremented by ammoPerShot when the shot consumes, clamped at 0.'),
    }
    n2108_use_ammo_outputs = {
        'cheating': f('bool', 'if(cheating()) return peekAmmo();', 'Whether the frame cheated, so the shot returned peekAmmo without consuming.'),
        'returned_ammo': f('Dictionary', 'return entry.type();', 'The bullet type the shot returns (the peek ammo type when cheating).'),
        'stacks_after': f('Array', 'if(entry.amount <= 0) ammo.pop();', 'The ammo stacks after the shot; untouched when cheating, the peek entry decremented (and popped when empty) otherwise.'),
        'total_ammo_after': f('int', 'totalAmmo = Math.max(totalAmmo, 0);', 'The total ammo after the shot; unchanged when cheating, totalAmmo - ammoPerShot clamped at 0 otherwise.'),
        'used': f('bool', 'return entry.type();', 'Whether the shot consumed ammo.'),
    }

    entries = [
        ('N2108', TICK_FRAME_OWNER, 'source_turret_tick_frame_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.updateTile()', n2108_tick_frame_inputs, n2108_tick_frame_outputs, True, 'Dictionary'),
        ('N2108', BIND_OWNER, 'source_turret_bind_frame_state', BLOCK, 'mindustry.world.Block', 'Block.newBuilding()', n2108_bind_inputs, n2108_bind_outputs, True, 'Dictionary'),
        ('N2108', TICK_OWNER, 'source_turret_tick_buildings_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.updateTile()', n2108_tick_inputs, n2108_tick_outputs, True, 'Dictionary'),
        ('N2108', USE_AMMO_OWNER, 'source_turret_use_ammo_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.useAmmo()', n2108_use_ammo_inputs, n2108_use_ammo_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret family live-loop tick and placement frame binding.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret family live-loop tick and placement frame binding; the frame is bound when the block is placed (Block.newBuilding) and its keys are refreshed from the live rules every simulate_factory tick, so TurretBuild.useAmmo() skips consumption for a cheating team.'))
        all_names.extend(names)
    by_slice['N2108'] = all_names
    # One slice row: the live-loop tick driver is the primary owner; the
    # frame wiring, placement bind and useAmmo helpers share the slice
    # (their symbols carry their own owner).
    source_symbols.upsert_source_slice(GODOT, 'N2108', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.updateTile(); Block.newBuilding(); TurretBuild.useAmmo()', godot_owner=TICK_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=all_names, tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
