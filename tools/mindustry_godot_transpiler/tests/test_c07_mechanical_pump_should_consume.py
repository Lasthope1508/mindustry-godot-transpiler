import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
MECHANICAL_PUMP_STATE = ROOT / 'godot-mindustry/src/game/SourceMechanicalPumpBuildState.gd'
MECHANICAL_PUMP_SHOULD_CONSUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MechanicalPumpShouldConsumeProof.gd'
MECHANICAL_PUMP_SHOULD_CONSUME_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MechanicalPumpShouldConsumeProof.tscn'


class C07MechanicalPumpShouldConsumeTests(unittest.TestCase):
    def test_c07_mechanical_pump_should_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2205']['godot_owner'], 'SourceMechanicalPumpBuildState.source_mechanical_pump_should_consume_state')
        # The mechanical-pump driver has run with
        # should_consume=true when enabled since the power.status
        # slice (N2154 deferred the gate: "needs liquid state the
        # tick does not track yet"). N2205 resolves it: the pure
        # source_mechanical_pump_should_consume_state gate mirrors
        # PumpBuild.shouldConsume exactly (Pump.java:155-157,
        # `return liquidDrop != null && liquids.get(liquidDrop) <
        # liquidCapacity - 0.01f && enabled;`) -- ALL THREE
        # conditions, including the enabled check (unlike the
        # LaunchPad/ShockwaveTower overrides, whose enabled
        # handling lives in updateConsumption,
        # BuildingComp.java:1954-1957, the disabled early
        # return). The gate reads liquid_drop (set by
        # onProximityUpdate, Pump.java:141-152, from the linked
        # tiles whose floor drops a liquid -- canPump,
        # Pump.java:106-108, `return tile != null &&
        # tile.floor().liquidDrop != null;` -- null when no
        # liquid floor sits under the footprint), the live
        # liquids amount for that drop (the sprite liquids meta,
        # read through the shared liquid module
        # source_get_state by liquid id), and the def-constant
        # liquidCapacity (rotary-pump 80f, Blocks.java:2308;
        # impulse-pump 200f, Blocks.java:2317 -- the catalog
        # carries no liquidCapacity for pump defs, so the driver
        # resolves it from the block id, the N2190/N2199 def
        # constant precedent; unknown Pump defs fall back to the
        # Block.java:77 default, `liquidCapacity = -1f;`). The
        # driver gathers liquid_drop per tick by calling the
        # existing N2087 proximity helper
        # (source_pump_proximity_state) and reading its return
        # value -- the helper also rewrites the sprite's
        # source_pump_building meta, but that meta is per-sprite,
        # so the scenario pump's sprite is untouched -- and
        # feeds should_consume to the machinery (the N2188/N2198/
        # N2200 gate precedent). When the gate is false,
        # updateConsumption forces efficiency to zero
        # (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();`, with
        # BuildingComp.java:1992-1994, `if(!update){` /
        # `efficiency = optionalEfficiency = 0f;`), so a full or
        # dry pump no longer reads power.status 1.0 while Java
        # efficiency is 0. Two new result symbols: the gate
        # verdict and the liquid drop it read.
        self.assertEqual(
            ledger['N2205']['source_symbols'],
            [
                'source_mechanical_pump_should_consume_state_result.should_consume',
                'source_mechanical_pump_should_consume_state_result.liquid_drop',
            ],
        )
        for name in ledger['N2205']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/Pump.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_mechanical_pump_should_consume_state_result.should_consume': 'SourceMechanicalPumpBuildState.source_mechanical_pump_should_consume_state',
                    'source_mechanical_pump_should_consume_state_result.liquid_drop': 'SourceMechanicalPumpBuildState.source_mechanical_pump_should_consume_state',
                }[name])
        self.assertEqual(ledger['N2205']['runtime_proof'], '/root/C07MechanicalPumpShouldConsumeProof')
        self.assertEqual(
            ledger['N2205']['tests'],
            [
                'test_c07_mechanical_pump_should_consume_registration',
                'test_all_c07_mechanical_pump_should_consume_input_evidence_is_exact',
                'test_mechanical_pump_should_consume_gate_state',
                'test_reference_graph_and_actual_c07_mechanical_pump_should_consume',
            ],
        )
        self.assertTrue(ledger['N2205']['deferred_exprs'])

    def test_all_c07_mechanical_pump_should_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2205']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_mechanical_pump_should_consume_state_result.should_consume': 'SourceMechanicalPumpBuildState.source_mechanical_pump_should_consume_state',
                    'source_mechanical_pump_should_consume_state_result.liquid_drop': 'SourceMechanicalPumpBuildState.source_mechanical_pump_should_consume_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/production/Pump.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/world/consumers/ConsumePower.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2205']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_mechanical_pump_should_consume_gate_state(self):
        pump = MECHANICAL_PUMP_STATE.read_text(encoding='utf-8')
        # The pure gate is PumpBuild.shouldConsume() exactly
        # (Pump.java:155, `public boolean shouldConsume(){`
        # with `return liquidDrop != null &&
        # liquids.get(liquidDrop) < liquidCapacity - 0.01f &&
        # enabled;`, Pump.java:156): the pump consumes only
        # while it has a liquid drop AND its stored amount of
        # that liquid is below capacity minus 0.01f AND it is
        # enabled. The override INCLUDES the enabled check --
        # unlike the LaunchPad (N2186) and ShockwaveTower
        # (N2187) overrides -- so the pure function reads
        # enabled from the frame (BuildingComp.java:77,
        # `transient boolean enabled = true;`; the BuildingComp
        # default shouldConsume, BuildingComp.java:755-756,
        # `return enabled;`, does not apply here because
        # PumpBuild overrides it). liquidDrop is the
        # onProximityUpdate field (Pump.java:114, `public
        # @Nullable Liquid liquidDrop = null;`, set by
        # onProximityUpdate, Pump.java:141-152: `liquidDrop =
        # other.floor().liquidDrop;` / `amount +=
        # other.floor().liquidMultiplier;` for each linked tile
        # passing canPump, Pump.java:106-108, `return tile !=
        # null && tile.floor().liquidDrop != null;`). The
        # liquids amount is liquids.get(liquidDrop) over the
        # sprite liquids meta (the LiquidModule dict, read
        # through the shared liquid module source_get_state by
        # liquid id, resolved from the drop name through the
        # catalog liquid_id_by_name map -- the factory
        # precedent). liquidCapacity is a def constant (the
        # catalog carries no liquidCapacity for pump defs):
        # rotary-pump 80f (`liquidCapacity = 80f;`,
        # Blocks.java:2308) / impulse-pump 200f
        # (`liquidCapacity = 200f;`, Blocks.java:2317), with the
        # Block.java:77 default (`liquidCapacity = -1f;`) as
        # the fallback for unknown Pump defs. When the gate is
        # false, updateConsumption folds efficiency to 0
        # (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();`, with
        # BuildingComp.java:1992-1994, `if(!update){` /
        # `efficiency = optionalEfficiency = 0f;`). The power
        # row itself is unchanged (N2154): the pure
        # ConsumePower read (`return build.power.status;`,
        # ConsumePower.java:39) over the stamped frame value,
        # for the rotary-pump (`consumePower(0.3f);`,
        # Blocks.java:2307) and impulse-pump
        # (`consumePower(1.3f);`, Blocks.java:2316) power
        # consumers, which count toward hasConsumers
        # (Block.java:1449, `hasConsumers = consumers.length >
        # 0;`). The pump accumulator follows the folded
        # efficiency (Pump.java:161, `if(efficiency > 0 &&
        # liquidDrop != null){` -- keep on ONE comment line,
        # the N2148 shootWarmup lesson: a split line fails this
        # test), and the maxPump fold (Pump.java:162, `float
        # maxPump = Math.min(liquidCapacity -
        # liquids.get(liquidDrop), amount * pumpAmount *
        # edelta());`). The updateTile advance (maxPump /
        # liquids.add / warmup / totalProgress / consTimer /
        # dumpLiquid, Pump.java:161-182) waits for its own
        # slice.
        self.assertIn('static func source_mechanical_pump_should_consume_state', pump)
        self.assertIn('public boolean shouldConsume(){', pump)
        self.assertIn('return liquidDrop != null && liquids.get(liquidDrop) < liquidCapacity - 0.01f && enabled;', pump)
        self.assertIn('public @Nullable Liquid liquidDrop = null;', pump)
        self.assertIn('return tile != null && tile.floor().liquidDrop != null;', pump)
        self.assertIn('liquidDrop = other.floor().liquidDrop;', pump)
        self.assertIn('amount += other.floor().liquidMultiplier;', pump)
        self.assertIn('boolean update = shouldConsume() && productionValid();', pump)
        self.assertIn('if(!update){', pump)
        self.assertIn('efficiency = optionalEfficiency = 0f;', pump)
        self.assertIn('return enabled;', pump)
        self.assertIn('liquidCapacity = 80f;', pump)
        self.assertIn('liquidCapacity = 200f;', pump)
        self.assertIn('liquidCapacity = -1f;', pump)
        self.assertIn('consumePower(0.3f);', pump)
        self.assertIn('consumePower(1.3f);', pump)
        self.assertIn('return build.power.status;', pump)
        self.assertIn('if(efficiency > 0 && liquidDrop != null){', pump)
        self.assertIn('float maxPump = Math.min(liquidCapacity - liquids.get(liquidDrop), amount * pumpAmount * edelta());', pump)
        self.assertIn('hasConsumers = consumers.length > 0;', pump)
        # The driver gathers the gate inputs per tick (the
        # proximity decision (a): call the existing N2087
        # helper and read liquid_drop from its return value;
        # the liquids store comes from the sprite meta; the
        # name -> id map comes from the liquid catalog) and
        # feeds the pure gate to the machinery (the N2188/N2198
        # gate precedent); the N2154 power row is preserved.
        self.assertIn('source_pump_proximity_state(game, cell)', pump)
        self.assertIn('SOURCE_BUILDING_LIQUIDS_META_KEY', pump)
        self.assertIn('source_get_state', pump)
        self.assertIn('liquid_id_by_name', pump)
        self.assertIn('var gate: Dictionary = source_mechanical_pump_should_consume_state(frame, proximity.get("liquid_drop", null), liquids, _liquid_capacity_for_block_id(block_id), liquid_id_by_name)', pump)
        self.assertIn('var should_consume: bool = bool(gate.get("should_consume", false))', pump)
        self.assertIn('static func source_mechanical_pump_power_status_row_state', pump)
        self.assertIn('static func source_mechanical_pump_tick_buildings_state', pump)
        # The old driver line (should_consume=true when
        # enabled, the whole line including its line end) is
        # gone.
        self.assertNotIn('\n\t\t\tvar should_consume: bool = bool(frame.get("enabled", true))\n', pump)
        # The proof's keys drive the pure gate (open when a
        # liquid drop sits under the footprint with room in the
        # store and the pump enabled; closed when dry, when
        # full, when disabled) plus the live tick (efficiency 0
        # when the gate is closed, old N2154 behavior kept when
        # the gate is open). There are no progress keys: the
        # updateTile advance (Pump.java:161-182) waits for its
        # own slice. The proof places a rotary-pump, a power
        # Pump, on shallow-water floor.
        # Static checks: the proof preloads the family state
        # file that exists, and the scene file references the
        # proof script that exists.
        proof = MECHANICAL_PUMP_SHOULD_CONSUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'gate_open_when_liquid_below_capacity',
            'gate_closed_when_no_liquid_drop',
            'gate_closed_when_liquids_full',
            'gate_closed_when_disabled',
            'efficiency_zero_when_gate_closed',
            'efficiency_kept_when_gate_open',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceMechanicalPumpBuildState.gd")', proof)
        self.assertIn('write_proof("C07MechanicalPumpShouldConsumeProof"', proof)
        self.assertTrue(MECHANICAL_PUMP_STATE.is_file())
        scene = MECHANICAL_PUMP_SHOULD_CONSUME_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07MechanicalPumpShouldConsumeProof.gd', scene)
        self.assertIn('[node name="C07MechanicalPumpShouldConsumeProof" type="Node"]', scene)

    def test_reference_graph_and_actual_c07_mechanical_pump_should_consume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07MechanicalPumpShouldConsumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_MECHANICAL_PUMP_SHOULD_CONSUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'gate_open_when_liquid_below_capacity',
            'gate_closed_when_no_liquid_drop',
            'gate_closed_when_liquids_full',
            'gate_closed_when_disabled',
            'efficiency_zero_when_gate_closed',
            'efficiency_kept_when_gate_open',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
