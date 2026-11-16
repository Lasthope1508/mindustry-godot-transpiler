import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
GAME = ROOT / 'godot-mindustry/src/game'
FRACKER = GAME / 'SourceFrackerBuildState.gd'
BEAM_DRILL = GAME / 'SourceBeamDrillBuildState.gd'
SOLID_PUMP = GAME / 'SourceSolidPumpBuildState.gd'

FUNC_RE = re.compile(r'^(?:static\s+)?func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(')
FILLED_RE = re.compile(r'\bvar\s+filled\b')


def filled_counts(path):
    """Count `var filled` declarations per top-level function."""
    counts = {}
    current = None
    for line in path.read_text(encoding='utf-8').splitlines():
        match = FUNC_RE.match(line)
        if match:
            current = match.group(1)
            counts.setdefault(current, 0)
            continue
        if current is not None and FILLED_RE.search(line):
            counts[current] += 1
    return counts


class C07DuplicateVarFilledFixTests(unittest.TestCase):
    def test_tick_functions_declare_filled_at_most_once(self):
        # N2416: the SECOND real Godot error, found by the user
        # running Godot 4.6.2 on wave-23 -- GDScript forbids
        # redeclaring a local in the same function, so the
        # duplicate `var filled` declarations were parse errors
        # that blocked the whole project (and the N2360-N2362
        # proofs with it). Before the fix:
        #   Fracker  source_fracker_tick_buildings_state    x3
        #            (:802 linked tiles, :806 proximity
        #            fraction, :853 dump-liquid neighbour)
        #   BeamDrill source_beam_drill_tick_buildings_state x2
        #            (:1161 facing tiles, :1226 dump neighbour)
        #   SolidPump source_solid_pump_tick_buildings_state x2
        #            (:616 proximity fraction, :664 dump
        #            neighbour)
        # The fix keeps the FIRST `filled` in each function and
        # renames the later ones after their pure
        # (fraction_filled / dump_filled) -- local renames only,
        # no logic, call-order, or pure-signature change.
        self.assertEqual(
            filled_counts(FRACKER)['source_fracker_tick_buildings_state'], 1)
        self.assertEqual(
            filled_counts(BEAM_DRILL)['source_beam_drill_tick_buildings_state'], 1)
        self.assertEqual(
            filled_counts(SOLID_PUMP)['source_solid_pump_tick_buildings_state'], 1)

    def test_renamed_fill_results_exist_with_write_backs(self):
        # The renamed declarations still call the same pures
        # with the same arguments, and their write-backs read
        # the renamed variable.
        fracker = FRACKER.read_text(encoding='utf-8')
        beam_drill = BEAM_DRILL.read_text(encoding='utf-8')
        solid_pump = SOLID_PUMP.read_text(encoding='utf-8')
        # Kept first declarations (positive pins -- the sweep
        # cannot pass vacuously by deleting every fill).
        self.assertIn(
            'var filled: Dictionary = source_fracker_linked_tiles_live_fill_state(',
            fracker)
        self.assertIn(
            'var filled: Dictionary = source_beam_drill_facing_tiles_fill_state(',
            beam_drill)
        self.assertIn(
            'var filled: Dictionary = source_solid_pump_proximity_fraction_state(',
            solid_pump)
        self.assertIn(
            'frame["proximity_linked_tiles"] = filled.get("proximity_linked_tiles", [])',
            fracker)
        self.assertIn(
            'frame["facing_tiles"] = filled.get("facing_tiles", [])',
            beam_drill)
        self.assertIn(
            'frame["valid_tiles"] = filled["valid_tiles"]', solid_pump)
        self.assertIn('frame["boost"] = filled["boost"]', solid_pump)
        # Renamed declarations.
        self.assertIn(
            'var fraction_filled: Dictionary = source_fracker_proximity_fraction_state(',
            fracker)
        self.assertIn(
            'var dump_filled: Dictionary = source_fracker_dump_liquid_neighbour_live_fill_state(',
            fracker)
        self.assertIn(
            'var dump_filled: Dictionary = source_beam_drill_dump_neighbour_live_fill_state(',
            beam_drill)
        self.assertIn(
            'var dump_filled: Dictionary = source_solid_pump_dump_neighbour_live_fill_state(',
            solid_pump)
        # Renamed write-backs, and no stale `= filled` read of
        # the renamed results remains.
        self.assertIn(
            'frame["valid_tiles"] = fraction_filled["valid_tiles"]', fracker)
        self.assertIn('frame["boost"] = fraction_filled["boost"]', fracker)
        self.assertIn(
            'frame["dump_liquid_neighbours"] = dump_filled.get("dump_liquid_neighbours", [])',
            fracker)
        self.assertIn(
            'frame["dump_neighbour_accepts"] = dump_filled.get("dump_neighbour_accepts", [])',
            beam_drill)
        self.assertIn(
            'frame["dump_neighbour_can_dump"] = dump_filled.get("dump_neighbour_can_dump", [])',
            beam_drill)
        self.assertIn(
            'frame["dump_neighbour_liquid_amounts"] = dump_filled.get("dump_neighbour_liquid_amounts", [])',
            solid_pump)
        self.assertIn(
            'frame["dump_neighbour_liquid_capacities"] = dump_filled.get("dump_neighbour_liquid_capacities", [])',
            solid_pump)
        self.assertIn(
            'frame["dump_neighbour_accepts_liquid"] = dump_filled.get("dump_neighbour_accepts_liquid", [])',
            solid_pump)
        self.assertIn(
            'frame["dump_neighbour_can_dump_liquid"] = dump_filled.get("dump_neighbour_can_dump_liquid", [])',
            solid_pump)
        self.assertNotIn('= filled["valid_tiles"]', fracker)
        self.assertNotIn('= filled["boost"]', fracker)
        self.assertNotIn(
            '= filled.get("dump_liquid_neighbours"', fracker)
        self.assertNotIn(
            '= filled.get("dump_neighbour_accepts"', beam_drill)
        self.assertNotIn(
            '= filled.get("dump_neighbour_can_dump"', beam_drill)
        self.assertNotIn(
            '= filled.get("dump_neighbour_liquid_amounts"', solid_pump)
        self.assertNotIn(
            '= filled.get("dump_neighbour_liquid_capacities"', solid_pump)
        self.assertNotIn(
            '= filled.get("dump_neighbour_accepts_liquid"', solid_pump)
        self.assertNotIn(
            '= filled.get("dump_neighbour_can_dump_liquid"', solid_pump)

    def test_no_function_anywhere_declares_filled_twice(self):
        # N2416 repo-wide sweep (the N2337/N2355 durable-pin
        # precedent): 16 files declare `var filled`, and only
        # the 3 tick functions above ever declared it twice
        # (verified 2026-11-16 -- Separator / BurstDrill /
        # ItemBridge / MassDriver / Deconstructor / Pump /
        # LiquidBridge / Unloader / WallCrafter each declare
        # it once). This pin keeps the sweep durable so a
        # future slice cannot reintroduce a duplicate.
        offenders = []
        for path in sorted((ROOT / 'godot-mindustry').rglob('*.gd')):
            for func, count in filled_counts(path).items():
                if count >= 2:
                    offenders.append(
                        f'{path.relative_to(ROOT)}::{func} x{count}')
        self.assertEqual(offenders, [])


if __name__ == '__main__':
    unittest.main()
