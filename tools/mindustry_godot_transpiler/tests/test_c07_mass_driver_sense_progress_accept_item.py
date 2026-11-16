import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
MASS_DRIVER_STATE = ROOT / 'godot-mindustry/src/game/SourceMassDriverBuildState.gd'
MASS_DRIVER_SENSE_PROGRESS_ACCEPT_ITEM_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MassDriverSenseProgressAcceptItemProof.gd'


class C07MassDriverSenseProgressAcceptItemTests(unittest.TestCase):
    def test_c07_mass_driver_sense_progress_accept_item_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2208']['godot_owner'], 'SourceMassDriverBuildState.source_mass_driver_sense_state')
        # MassDriverBuild overrides sense for LAccess.progress
        # (MassDriver.java:224, `public double sense(LAccess
        # sensor){` with `if(sensor == LAccess.progress)
        # return Mathf.clamp(1f - reloadCounter);`,
        # MassDriver.java:225) over the reload counter
        # (MassDriver.java:117, `public float reloadCounter =
        # 0f;`), which the updateTile advance alone drains
        # (MassDriver.java:143, `reloadCounter =
        # Mathf.clamp(reloadCounter - edelta() / reload);`)
        # and fire() resets (MassDriver.java:291,
        # `reloadCounter = 1f;`). A logic processor reading
        # `progress` on a mass driver currently gets NaN/null:
        # the BuildingComp sense switch has NO progress case
        # (BuildingComp.java:2093, `public double
        # sense(LAccess sensor){` + 2123, `default -> Float.NaN;
        # //gets converted to null in logic`), while Java
        # returns the clamped reload fraction. N2208 closes
        # that gap with one pure function over one frame key
        # (`reload_counter`, float) plus the sensor string,
        # following the N2206 launch-pad sense precedent
        # exactly: the pure function takes (frame, sensor) --
        # the sensor parameter because sense is a logic read
        # over an enum, not a tick write -- and returns the
        # generic laccess wire shape (`sense_value` +
        # `sense_value_is_nan`,
        # SourceBlockSenseState.laccess_state) plus an explicit
        # `handled` flag, so a caller can tell "handled, value
        # is a clamped fraction" from "not handled -- fall
        # through to super.sense" (MassDriver.java:226,
        # `return super.sense(sensor);`). The same slice adds
        # the intake predicate: MassDriverBuild.acceptItem
        # (MassDriver.java:285, `public boolean
        # acceptItem(Building source, Item item){` with
        # `return items.total() < itemCapacity && linkValid();`,
        # MassDriver.java:287) -- a second pure function over
        # one frame key (`items_total`, float) plus the
        # per-def itemCapacity and the caller-computed
        # link_valid flag, returning `accept_item`. RED
        # decisions (pinned by this slice): (1) sensor
        # spelling is "progress" -- LAccess.java:28 lists
        # `progress,`, and the generic sense layer matches
        # sensor strings by enum name ("health", "maxHealth",
        # "color", ...). (2) An absent `reload_counter` key
        # reads 0.0, NOT NaN: `public float reloadCounter =
        # 0f;` is the Java init value, so a freshly built
        # driver senses clamp(1 - 0) = 1.0 -- fully reloaded,
        # the only observable Java behavior at init -- and
        # returning 1.0 regresses nothing, because no consumer
        # reads this value yet (the sense-dispatch hook does
        # not exist); absent -> NaN would preserve the port's
        # current UNFAITHFUL output instead. (3) The clamp
        # edge: reloadCounter 1.0 (just fired) senses 0.0,
        # 0.5 senses 0.5, a negative counter (impossible in
        # Java -- the counter only drains toward 0 and fire
        # resets it to 1) floors to 1.0 anyway through the
        # clamp. (4) An absent `items_total` key reads 0.0 --
        # a fresh ItemModule totals 0 (`protected int total;`,
        # ItemModule.java:25, with `public int total(){` /
        # `return total;`, ItemModule.java:174-175) -- so a
        # fresh driver with a valid link accepts items, which
        # IS the Java init behavior. (5) linkValid() is a
        # world query (`protected boolean linkValid(){` with
        # `if(link == -1) return false;` and `return
        # world.build(this.link) instanceof MassDriverBuild
        # other && other.block == block && other.team == team
        # && within(other, range);`, MassDriver.java:346-349),
        # so the pure accept function takes `link_valid` as a
        # caller-computed bool; computing it from link state
        # is its own later slice (link/config rows deferred).
        # (6) itemCapacity is per-def: mass-driver 120
        # (Blocks.java:2170, `itemCapacity = 120;`), class
        # default 10 (Block.java:75, `public int itemCapacity
        # = 10;`); the caller passes it in, the N2207
        # launch-pad precedent. Two new result symbols: the
        # sensed value and the accept predicate.
        self.assertEqual(
            ledger['N2208']['source_symbols'],
            [
                'source_mass_driver_sense_state_result.sense_value',
                'source_mass_driver_accept_item_state_result.accept_item',
            ],
        )
        for name in ledger['N2208']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/distribution/MassDriver.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/logic/LAccess.java',
                    'core/src/mindustry/content/Blocks.java',
                    'core/src/mindustry/world/Block.java',
                    'core/src/mindustry/world/modules/ItemModule.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_mass_driver_sense_state_result.sense_value': 'SourceMassDriverBuildState.source_mass_driver_sense_state',
                    'source_mass_driver_accept_item_state_result.accept_item': 'SourceMassDriverBuildState.source_mass_driver_accept_item_state',
                }[name])
        self.assertEqual(ledger['N2208']['runtime_proof'], '/root/C07MassDriverSenseProgressAcceptItemProof')
        self.assertEqual(
            ledger['N2208']['tests'],
            [
                'test_c07_mass_driver_sense_progress_accept_item_registration',
                'test_all_c07_mass_driver_sense_progress_accept_item_input_evidence_is_exact',
                'test_mass_driver_sense_progress_accept_item_state',
                'test_reference_graph_and_actual_c07_mass_driver_sense_progress_accept_item',
            ],
        )
        self.assertTrue(ledger['N2208']['deferred_exprs'])

    def test_all_c07_mass_driver_sense_progress_accept_item_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2208']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_mass_driver_sense_state_result.sense_value': 'SourceMassDriverBuildState.source_mass_driver_sense_state',
                    'source_mass_driver_accept_item_state_result.accept_item': 'SourceMassDriverBuildState.source_mass_driver_accept_item_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/distribution/MassDriver.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/logic/LAccess.java',
            'core/src/mindustry/world/modules/ItemModule.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2208']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_mass_driver_sense_progress_accept_item_state(self):
        mass_driver = MASS_DRIVER_STATE.read_text(encoding='utf-8')
        # The pure sense override lives on the mass-driver
        # build state next to the N2171 power row:
        # MassDriverBuild overrides sense (MassDriver.java:224,
        # `public double sense(LAccess sensor){` with
        # `if(sensor == LAccess.progress) return
        # Mathf.clamp(1f - reloadCounter);`,
        # MassDriver.java:225) over the reload counter
        # (MassDriver.java:117, `public float reloadCounter =
        # 0f;`), which the updateTile advance alone drains
        # (MassDriver.java:143, `reloadCounter =
        # Mathf.clamp(reloadCounter - edelta() / reload);`)
        # and fire() resets (MassDriver.java:291,
        # `reloadCounter = 1f;`). Non-progress sensors fall
        # through to super.sense (MassDriver.java:226,
        # `return super.sense(sensor);`), and the BuildingComp
        # super switch has NO progress case
        # (BuildingComp.java:2093, `public double
        # sense(LAccess sensor){` + 2123, `default -> Float.NaN;
        # //gets converted to null in logic`), so a logic read
        # of `progress` on a mass driver currently returns
        # NaN/null while Java returns the clamped fraction. Do
        # NOT confuse sense with progress(): `public float
        # progress(){` + `return 0f;`
        # (BuildingComp.java:617-619) is a DIFFERENT method the
        # sense switch never calls. The sensor enum value is
        # `progress,` (LAccess.java:28). The same expression
        # drives the reload bar: Mathf.clamp one-arg clamps to
        # [0, 1]; the GDScript spelling is clampf(value, 0.0,
        # 1.0) -- the SourceShockwaveTowerBuildState.gd:306
        # precedent. Sense is a logic read, not a tick write:
        # NO driver tick line belongs here (the N2206 sense
        # precedent -- the proof calls the pure function
        # directly with synthetic frames); the
        # logic-processor integration -- how a logic `sense
        # progress` read on a placed mass driver reaches this
        # family function -- is its own later slice. Do NOT
        # extend the generic
        # SourceBlockSenseState.laccess_state: it is the
        # Block-level sense (Block.java:1651-1664), takes no
        # frame/reload-counter input, and adding family state
        # there would break its generic shape.
        self.assertIn('static func source_mass_driver_sense_state(frame: Dictionary, sensor: String)', mass_driver)
        # The sense cases, pinned as the pure function's
        # decision structure: the frame carries the live counter
        # as `reload_counter` (float, stamped by the future
        # updateTile advance); the function reads it with a null
        # default, and an ABSENT key reads 0.0 -- the Java init
        # default (`public float reloadCounter = 0f;`), so a
        # freshly built driver senses 1.0, NOT NaN.
        # reload_counter=1.0 (just fired) senses 0.0;
        # reload_counter=0.5 senses 0.5; sensor "health" falls
        # through (handled false, sense_value null,
        # sense_value_is_nan true); all progress cases run
        # through the one expression, `clampf(1.0 -
        # reload_counter, 0.0, 1.0)`.
        self.assertIn('frame.get("reload_counter", null)', mass_driver)
        with self.subTest(case='reload_counter=1.0 just fired senses 0.0'):
            self.assertIn('clampf(1.0 - reload_counter, 0.0, 1.0)', mass_driver)
        with self.subTest(case='reload_counter=0.5 senses 0.5'):
            self.assertIn('clampf(1.0 - reload_counter, 0.0, 1.0)', mass_driver)
        with self.subTest(case='no reload_counter key senses 1.0 (Java init, fully reloaded)'):
            self.assertIn('0.0 if observed == null else float(observed)', mass_driver)
        with self.subTest(case='non-progress sensor falls through to super.sense'):
            self.assertIn('return {"handled": false, "sense_value": null, "sense_value_is_nan": true}', mass_driver)
        with self.subTest(case='progress sensor returns handled true with the clamped fraction'):
            self.assertIn('return {"handled": true, "sense_value": fraction, "sense_value_is_nan": false}', mass_driver)
        with self.subTest(case='sensor string is the LAccess enum name'):
            self.assertIn('sensor == "progress"', mass_driver)
        # The pure accept predicate lives beside the sense
        # function: MassDriverBuild.acceptItem
        # (MassDriver.java:285, `public boolean
        # acceptItem(Building source, Item item){` with
        # `return items.total() < itemCapacity && linkValid();`,
        # MassDriver.java:287) -- "mass drivers that output
        # only cannot accept items" (MassDriver.java:286).
        # The frame carries the held items as `items_total`
        # (float, absent defaults to 0.0 -- a fresh ItemModule
        # totals 0, `protected int total;`,
        # ItemModule.java:25, with `public int total(){` /
        # `return total;`, ItemModule.java:174-175). The
        # per-def itemCapacity is 120 for mass-driver
        # (Blocks.java:2170, `itemCapacity = 120;`, with
        # `size = 3;`, `reload = 200f;`, `range = 440f;`),
        # class default 10 (Block.java:75, `public int
        # itemCapacity = 10;`). linkValid() is a world query
        # (`protected boolean linkValid(){` with `if(link ==
        # -1) return false;` and `return world.build(this.link)
        # instanceof MassDriverBuild other && other.block ==
        # block && other.team == team && within(other, range);`,
        # MassDriver.java:346-349), so the caller passes
        # `link_valid` in; acceptItem is an intake predicate,
        # not a tick write, so NO driver tick line belongs
        # here either -- the intake/dump integration that calls
        # it is its own later slice.
        self.assertIn('static func source_mass_driver_accept_item_state(frame: Dictionary, item_capacity: float, link_valid: bool)', mass_driver)
        self.assertIn('var items_total: float = float(frame.get("items_total", 0.0))', mass_driver)
        with self.subTest(case='items below capacity with a valid link accepts'):
            self.assertIn('return {"accept_item": items_total < item_capacity and link_valid}', mass_driver)
        with self.subTest(case='items at capacity rejects'):
            self.assertIn('return {"accept_item": items_total < item_capacity and link_valid}', mass_driver)
        with self.subTest(case='no valid link rejects'):
            self.assertIn('return {"accept_item": items_total < item_capacity and link_valid}', mass_driver)
        self.assertIn('public double sense(LAccess sensor){', mass_driver)
        self.assertIn('if(sensor == LAccess.progress) return Mathf.clamp(1f - reloadCounter);', mass_driver)
        self.assertIn('return super.sense(sensor);', mass_driver)
        self.assertIn('public float reloadCounter = 0f;', mass_driver)
        self.assertIn('public boolean acceptItem(Building source, Item item){', mass_driver)
        self.assertIn('return items.total() < itemCapacity && linkValid();', mass_driver)
        self.assertIn('protected boolean linkValid(){', mass_driver)
        self.assertIn('if(link == -1) return false;', mass_driver)
        self.assertIn('return world.build(this.link) instanceof MassDriverBuild other && other.block == block && other.team == team && within(other, range);', mass_driver)
        self.assertIn('reloadCounter = Mathf.clamp(reloadCounter - edelta() / reload);', mass_driver)
        self.assertIn('reloadCounter = 1f;', mass_driver)
        self.assertIn('public class MassDriver extends Block{', mass_driver)
        self.assertIn('public class MassDriverBuild extends Building implements RotBlock{', mass_driver)
        self.assertIn('default -> Float.NaN; //gets converted to null in logic', mass_driver)
        self.assertIn('public float progress(){', mass_driver)
        self.assertIn('return 0f;', mass_driver)
        self.assertIn('progress,', mass_driver)
        self.assertIn('itemCapacity = 120;', mass_driver)
        self.assertIn('reload = 200f;', mass_driver)
        self.assertIn('range = 440f;', mass_driver)
        self.assertIn('public int itemCapacity = 10;', mass_driver)
        self.assertIn('protected int total;', mass_driver)
        self.assertIn('public int total(){', mass_driver)
        self.assertIn('return total;', mass_driver)
        self.assertIn('source_mass_driver_sense_state(frame, sensor)', mass_driver)
        self.assertIn('source_mass_driver_accept_item_state(frame, item_capacity, link_valid)', mass_driver)
        self.assertIn('static func source_mass_driver_tick_buildings_state', mass_driver)
        # The proof's keys drive the two pure functions
        # directly with synthetic frames (fraction fresh / 0.0
        # just fired / 0.5 half reloaded / fall-through for a
        # non-progress sensor / accept below capacity with a
        # valid link / reject when full or unlinked). There are
        # no driver-tick / updateTile / link / fire keys: sense
        # is a logic read and acceptItem is an intake
        # predicate, not tick writes (the N2206 precedent), the
        # updateTile advance (MassDriver.java:133-221) and the
        # link-validity computation wait for their own slices,
        # and the logic-processor dispatch hook that routes a
        # placed driver's `sense progress` read to this
        # function is its own later slice.
        proof = MASS_DRIVER_SENSE_PROGRESS_ACCEPT_ITEM_PROOF.read_text(encoding='utf-8')
        for key in [
            'sense_progress_fresh_driver_full',
            'sense_progress_after_fire_zero',
            'sense_progress_half_reloaded',
            'sense_fall_through_non_progress',
            'accept_item_below_capacity_with_link',
            'accept_item_full_or_no_link_rejects',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_mass_driver_sense_progress_accept_item(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07MassDriverSenseProgressAcceptItemProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_MASS_DRIVER_SENSE_PROGRESS_ACCEPT_ITEM_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'sense_progress_fresh_driver_full',
            'sense_progress_after_fire_zero',
            'sense_progress_half_reloaded',
            'sense_fall_through_non_progress',
            'accept_item_below_capacity_with_link',
            'accept_item_full_or_no_link_rejects',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
