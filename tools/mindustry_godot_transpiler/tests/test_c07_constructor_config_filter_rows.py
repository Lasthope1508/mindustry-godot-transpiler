import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
CONSTRUCTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceConstructorBuildState.gd'
CONSTRUCTOR_CONFIG_FILTER_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ConstructorConfigFilterRowsProof.gd'
CONSTRUCTOR_CONFIG_FILTER_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ConstructorConfigFilterRowsProof.tscn'


class C07ConstructorConfigFilterRowsTests(unittest.TestCase):
    def test_c07_constructor_config_filter_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2455']['godot_owner'], 'SourceConstructorBuildState.source_constructor_can_produce_state')
        # The Constructor tick is live (N2216
        # shouldConsume gate + N2265 dynamic item
        # row + N2274 updateTile advance) and the
        # draw rows are live (N2440 draw /
        # drawSelect / placeEffect) but NOTHING
        # modeled the config / filter rows:
        # canProduce (Constructor.java:54-56, all
        # 7 conditions), config(Block) (:32-37,
        # progress reset BEFORE the canProduce
        # gate) + configClear (:31/:38, recipe =
        # null) + buildConfiguration (:66-70, the
        # ItemSelection.buildTable picker) +
        # config() (:73-75, returns recipe) +
        # setStats (:41-47, Stat.output "@x@ ~
        # @x@" + Stat.buildSpeed percent).
        # N2455 ports them as THREE pure-only
        # pures (the N2442/N2449 precedent): the
        # can-produce gate, the config fold over
        # the discriminated action (set / clear /
        # none, the N2449 precedent) and the
        # stats rows. Six new result symbols.
        self.assertEqual(
            ledger['N2455']['source_symbols'],
            [
                'source_constructor_can_produce_state_result.can_produce',
                'source_constructor_config_state_result.recipe',
                'source_constructor_config_state_result.progress_reset',
                'source_constructor_config_state_result.configure_call',
                'source_constructor_stats_state_result.output_stat',
                'source_constructor_stats_state_result.build_speed_stat',
            ],
        )
        expected_sources = {
            'source_constructor_can_produce_state_result.can_produce': 'core/src/mindustry/world/blocks/payloads/Constructor.java',
            'source_constructor_config_state_result.recipe': 'core/src/mindustry/world/blocks/payloads/Constructor.java',
            'source_constructor_config_state_result.progress_reset': 'core/src/mindustry/world/blocks/payloads/Constructor.java',
            'source_constructor_config_state_result.configure_call': 'core/src/mindustry/world/blocks/payloads/Constructor.java',
            'source_constructor_stats_state_result.output_stat': 'core/src/mindustry/world/blocks/payloads/Constructor.java',
            'source_constructor_stats_state_result.build_speed_stat': 'core/src/mindustry/world/blocks/payloads/Constructor.java',
        }
        for name in ledger['N2455']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], expected_sources[name])
                self.assertTrue(symbol['godot_owner'].startswith('SourceConstructorBuildState.source_constructor_'))
        self.assertEqual(ledger['N2455']['runtime_proof'], '/root/C07ConstructorConfigFilterRowsProof')
        self.assertEqual(
            ledger['N2455']['tests'],
            [
                'test_c07_constructor_config_filter_rows_registration',
                'test_all_c07_constructor_config_filter_rows_input_evidence_is_exact',
                'test_constructor_config_filter_rows_state',
                'test_reference_graph_and_actual_c07_constructor_config_filter_rows',
            ],
        )
        self.assertTrue(ledger['N2455']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #8 (1-based
        # in the merged advances-29 DEFERRED base):
        # the Constructor config / filter rows
        # entry is REMOVED -- filter, min/max
        # block size, canProduce, config(Block),
        # configClear, buildConfiguration,
        # config() and setStats are all live now
        # (the pure's recipe IS the post-action
        # config() value, Constructor.java:73-75).
        # Net 253 - 1 = 252. The remaining
        # Constructor gaps STAY: the live recipe
        # config fill (#99 in the merged 253
        # base -- no live fill sets
        # frame["recipe"] yet) and the frame
        # items intake (#169). NOTE (brief
        # correction, verified first): the brief
        # said to pin write/read #84 and per-def
        # #86, but #84/#86 in the merged 253
        # file are LightBlock entries, not
        # Constructor -- there is no Constructor
        # write/read or per-def entry in the
        # merged base, so #99/#169 are pinned
        # instead.
        self.assertFalse(any(entry.startswith('Constructor config / filter rows (') for entry in ledger['N2455']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Constructor live recipe config fill (') for entry in ledger['N2455']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Constructor frame items intake (') for entry in ledger['N2455']['deferred_exprs']))
        self.assertEqual(len(ledger['N2455']['deferred_exprs']), 252)

    def test_all_c07_constructor_config_filter_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2455']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceConstructorBuildState.source_constructor_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/payloads/Constructor.java',
            'core/src/mindustry/world/blocks/payloads/BlockProducer.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/meta/Stat.java',
            'core/src/mindustry/world/meta/Stats.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2455']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_constructor_config_filter_rows_state(self):
        constructor = CONSTRUCTOR_STATE.read_text(encoding='utf-8')
        # The config / filter rows (Constructor
        # filter/min/max, Constructor.java:21-22;
        # config(Block) + configClear, :31-38;
        # setStats, :41-47; getPlanConfigs,
        # :50-52; canProduce, :54-56;
        # buildConfiguration, :66-70; config(),
        # :73-75): canProduce is the 7-condition
        # gate over the caller-supplied block
        # dict + filter name list; config(Block)
        # resets progress BEFORE the canProduce
        # check (:33 runs before :34), so a
        # non-producible block still resets
        # progress while the recipe stays put;
        # configClear sets recipe = null with
        # NO progress reset (:31/:38, registered
        # twice in Java, same lambda);
        # buildConfiguration opens the
        # ItemSelection picker over filter-empty
        # ? select(canProduce) : filter and the
        # pure records it as a CALL (the N2449
        # precedent); config() returns recipe,
        # so the pure's recipe IS the post-action
        # config() value; setStats adds
        # Stat.output "@x@ ~ @x@" with [min,
        # min, max, max] and Stat.buildSpeed as
        # a percent of the RAW buildSpeed
        # (addPercent formats at display,
        # Stats.java:38, the N2451 precedent).
        # Defs (verified first): constructor
        # (filter 7 walls/containers + beam-node,
        # Blocks.java:6666; buildSpeed 0.6f,
        # :6662; min/max class defaults 1/2) and
        # large-constructor (empty filter, min 3
        # / max 4, buildSpeed 0.75f,
        # Blocks.java:6675-6677). Pure-only: the
        # tick never calls canProduce /
        # buildConfiguration / setStats (config
        # is live since N2462). Keep
        # each Java expr on ONE comment line (the
        # N2148 lesson: a split line fails this
        # test).
        self.assertIn('static func source_constructor_can_produce_state', constructor)
        self.assertIn('static func source_constructor_config_state', constructor)
        self.assertIn('static func source_constructor_stats_state', constructor)
        self.assertIn('public class Constructor extends BlockProducer{', constructor)
        self.assertIn('public Seq<Block> filter = new Seq<>();', constructor)
        self.assertIn('public int minBlockSize = 1, maxBlockSize = 2;', constructor)
        self.assertIn('configurable = true;', constructor)
        self.assertIn('clearOnDoubleTap = true;', constructor)
        self.assertIn('configClear((ConstructorBuild tile) -> tile.recipe = null);', constructor)
        self.assertIn('config(Block.class, (ConstructorBuild tile, Block block) -> {', constructor)
        self.assertIn('if(tile.recipe != block) tile.progress = 0f;', constructor)
        self.assertIn('if(canProduce(block)){', constructor)
        self.assertIn('tile.recipe = block;', constructor)
        self.assertIn('public void setStats(){', constructor)
        self.assertIn('super.setStats();', constructor)
        self.assertIn('stats.add(Stat.output, "@x@ ~ @x@", minBlockSize, minBlockSize, maxBlockSize, maxBlockSize);', constructor)
        self.assertIn('stats.addPercent(Stat.buildSpeed, buildSpeed);', constructor)
        self.assertIn('public void getPlanConfigs(Seq<UnlockableContent> options){', constructor)
        self.assertIn('options.add(content.blocks().select(this::canProduce));', constructor)
        self.assertIn('public boolean canProduce(Block b){', constructor)
        self.assertIn('return b.isVisible() && b.size >= minBlockSize && b.size <= maxBlockSize && !(b instanceof CoreBlock) && !state.rules.isBanned(b) && b.environmentBuildable() && (filter.isEmpty() || filter.contains(b));', constructor)
        self.assertIn('public class ConstructorBuild extends BlockProducerBuild{', constructor)
        self.assertIn('public @Nullable Block recipe;', constructor)
        self.assertIn('public void buildConfiguration(Table table){', constructor)
        self.assertIn('ItemSelection.buildTable(Constructor.this, table, filter.isEmpty() ? content.blocks().select(Constructor.this::canProduce) : filter, () -> recipe, this::configure, selectionRows, selectionColumns);', constructor)
        self.assertIn('public Object config(){', constructor)
        self.assertIn('return recipe;', constructor)
        self.assertIn('buildSpeed = new Stat("buildSpeed"),', constructor)
        self.assertIn('output = new Stat("output", StatCat.crafting),', constructor)
        self.assertIn('public float buildSpeed = 0.4f;', constructor)
        self.assertIn('buildSpeed = 0.6f;', constructor)
        self.assertIn('buildSpeed = 0.75f;', constructor)
        self.assertIn('maxBlockSize = 4;', constructor)
        self.assertIn('minBlockSize = 3;', constructor)
        self.assertIn('filter = Seq.with(Blocks.tungstenWallLarge, Blocks.berylliumWallLarge, Blocks.carbideWallLarge, Blocks.reinforcedSurgeWallLarge, Blocks.reinforcedLiquidContainer, Blocks.reinforcedContainer, Blocks.beamNode);', constructor)
        self.assertIn('public void addPercent(Stat stat, float value){', constructor)
        self.assertIn('add(stat, StatValues.number((int)(value * 100), StatUnit.percent));', constructor)
        # The documented limits record the
        # config/filter rows as live.
        self.assertIn('Config/filter rows live (N2455)', constructor)
        # The proof's keys drive the pures (the
        # visible/core/banned/buildable
        # predicates, the size gate at both defs'
        # bounds, the filter list, the set/clear
        # config fold incl. the
        # reset-before-gate semantics, and the
        # stats rows at both defs).
        proof = CONSTRUCTOR_CONFIG_FILTER_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'can_produce_visible',
            'can_produce_size_gate',
            'can_produce_filter',
            'config_set',
            'config_clear',
            'stats_def',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceConstructorBuildState.gd")', proof)
        self.assertTrue(CONSTRUCTOR_STATE.exists())
        self.assertTrue(CONSTRUCTOR_CONFIG_FILTER_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07ConstructorConfigFilterRowsProof.gd', CONSTRUCTOR_CONFIG_FILTER_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_constructor_config_filter_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ConstructorConfigFilterRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_CONSTRUCTOR_CONFIG_FILTER_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'can_produce_visible',
            'can_produce_size_gate',
            'can_produce_filter',
            'config_set',
            'config_clear',
            'stats_def',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
