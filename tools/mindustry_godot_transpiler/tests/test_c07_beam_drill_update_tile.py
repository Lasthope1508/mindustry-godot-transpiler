import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BEAM_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBeamDrillBuildState.gd'
BEAM_DRILL_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BeamDrillUpdateTileProof.gd'


class C07BeamDrillUpdateTileTests(unittest.TestCase):
    def test_c07_beam_drill_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2398']['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_update_tile_state')
        # BeamDrillBuild.updateTile() (BeamDrill.java:237-265,
        # `public void updateTile(){`) -- this slice is the
        # facing-harvest + dump half: `float drillTime =
        # getDrillTime(lastItem);` (:247),
        # `boostWarmup = Mathf.lerpDelta(boostWarmup,
        # optionalEfficiency, 0.1f);` (:248), the harvest gate
        # `if(time >= drillTime){` (:253) with the facing loop
        # `for(Tile tile : facing){` (:254), `Item drop = tile
        # == null ? null : tile.wallDrop();` (:255), the
        # capacity gate `if(items.total() < itemCapacity &&
        # drop != null){` (:256), `items.add(drop, 1);`
        # (:257), `produced(drop);` (:258), `time %=
        # drillTime;` (:261), and the dump `dump();` (:264).
        # NOT this slice: `super.updateTile();` (generic),
        # `if(lasers[0] == null) updateLasers();` /
        # `updateFacing();` (N2379), the warmup gate
        # `warmup = Mathf.approachDelta(...)` / `float
        # multiplier = ...` / `lastDrillSpeed = ...` /
        # `time += edelta() * multiplier;` (all N2155), the
        # timer gate `if(timer(timerDump, dumpTime /
        # timeScale)){` (N691/N2068/N2072/N2073/N2294 --
        # arrives as the dump_ready bool). getDrillTime is
        # BeamDrill's own method (BeamDrill.java:216-217,
        # `return drillTime / drillMultipliers.get(item,
        # 1f);`, N2388/N2344) -- arrives as the explicit
        # get_drill_time Callable. wallDrop() / produced() /
        # dump() are engine APIs -- wallDrop reads the tile
        # Dictionary "wall_drop" (the N2379 precedent),
        # produced / dump / items.add arrive as explicit
        # Callables (the N2377 drawer precedent). `time` is
        # the BeamDrillBuild field (`public float time;`,
        # BeamDrill.java:225) shared with N2155 -- taken
        # in/out, NOT re-registered. The 10 distinguishing
        # exprs are the 0-hit lines re-probed at base
        # 84ea01c4 in both ledgers; overlap with N2394
        # (same file, merged 3c614dd1) is 0/10. Eight new
        # result symbols: drill_time, boost_warmup, time,
        # harvested, get_drill_time_called,
        # items_add_called, produced_called, dump_called.
        self.assertEqual(
            ledger['N2398']['source_symbols'],
            [
                'source_beam_drill_update_tile_state_result.drill_time',
                'source_beam_drill_update_tile_state_result.boost_warmup',
                'source_beam_drill_update_tile_state_result.time',
                'source_beam_drill_update_tile_state_result.harvested',
                'source_beam_drill_update_tile_state_result.get_drill_time_called',
                'source_beam_drill_update_tile_state_result.items_add_called',
                'source_beam_drill_update_tile_state_result.produced_called',
                'source_beam_drill_update_tile_state_result.dump_called',
            ],
        )
        for name in ledger['N2398']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/BeamDrill.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'arc-core/src/arc/math/Mathf.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2398']['runtime_proof'], '/root/C07BeamDrillUpdateTileProof')
        self.assertEqual(
            ledger['N2398']['tests'],
            [
                'test_c07_beam_drill_update_tile_registration',
                'test_all_c07_beam_drill_update_tile_input_evidence_is_exact',
                'test_beam_drill_update_tile_state',
                'test_reference_graph_and_actual_c07_beam_drill_update_tile',
            ],
        )
        self.assertTrue(ledger['N2398']['deferred_exprs'])

    def test_all_c07_beam_drill_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2398']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/production/BeamDrill.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'arc-core/src/arc/math/Mathf.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
        for expr in ledger['N2398']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_beam_drill_update_tile_state(self):
        state = BEAM_DRILL_STATE.read_text(encoding='utf-8')
        # BeamDrillBuild.updateTile() (BeamDrill.java:237-265):
        # the harvest half -- drillTime from getDrillTime
        # (BeamDrill.java:216-217), boostWarmup lerpDelta
        # (Mathf.java:430-432), the harvest gate + facing
        # loop + capacity gate + items.add + produced +
        # time %= drillTime, and the dump() behind the
        # timer gate (N691 generic -- arrives as
        # dump_ready). getDrillTime / items.add / produced /
        # dump arrive as explicit Callables, NOT re-ported;
        # wallDrop reads the tile Dictionary "wall_drop"
        # (the N2379 updateFacing precedent). `time` is
        # shared with N2155 -- in/out, NOT re-registered.
        # NO driver tick line: this IS the driver-tick
        # state function itself, driven by the live loop
        # with synthetic frames in the proof (no live tick).
        self.assertIn('static func source_beam_drill_update_tile_state(frame: Dictionary, last_item: Variant, boost_warmup: float, optional_efficiency: float, time: float, time_delta: float, facing: Array, items_total: int, item_capacity: int, dump_ready: bool, get_drill_time: Callable, items_add: Callable, produced: Callable, dump: Callable) -> Dictionary:', state)
        self.assertIn('return {"drill_time": drill_time, "boost_warmup": boost_warmup_after, "time": time_after, "harvested": harvested, "get_drill_time_called": get_drill_time_called, "items_add_called": items_add_called, "produced_called": produced_called, "dump_called": dump_called}', state)
        for expr in [
            'float drillTime = getDrillTime(lastItem);',
            'boostWarmup = Mathf.lerpDelta(boostWarmup, optionalEfficiency, 0.1f);',
            'if(time >= drillTime){',
            'for(Tile tile : facing){',
            'Item drop = tile == null ? null : tile.wallDrop();',
            'if(items.total() < itemCapacity && drop != null){',
            'items.add(drop, 1);',
            'produced(drop);',
            'time %= drillTime;',
            'dump();',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        # The proof's keys drive the pure function with
        # synthetic frames (no live tick): drillTime comes
        # from the get_drill_time Callable / boostWarmup
        # lerps toward optionalEfficiency at 0.1 per delta /
        # below the gate nothing is harvested and time is
        # unchanged / at/above the gate each facing drop is
        # added + produced / null tiles and null drops are
        # skipped but time still wraps / a full item store
        # blocks adds but time still wraps / time wraps by
        # modulo after harvest / dump fires only when the
        # timer gate is ready / the result-key shapes.
        proof = BEAM_DRILL_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in [
            'drill_time_from_get_drill_time',
            'boost_warmup_lerp_delta',
            'harvest_below_gate_no_add',
            'harvest_adds_drop_and_produces',
            'harvest_skips_null_tile_and_null_drop',
            'harvest_blocked_when_items_full',
            'time_modulo_after_harvest',
            'dump_called_when_ready',
            'dump_not_called_when_not_ready',
            'returns_only_expected_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_beam_drill_update_tile(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BeamDrillUpdateTileProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BEAM_DRILL_UPDATE_TILE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'drill_time_from_get_drill_time',
            'boost_warmup_lerp_delta',
            'harvest_below_gate_no_add',
            'harvest_adds_drop_and_produces',
            'harvest_skips_null_tile_and_null_drop',
            'harvest_blocked_when_items_full',
            'time_modulo_after_harvest',
            'dump_called_when_ready',
            'dump_not_called_when_not_ready',
            'returns_only_expected_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
