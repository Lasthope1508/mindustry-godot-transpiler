import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
IMPACT_REACTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceImpactReactorBuildState.gd'
IMPACT_REACTOR_BAR_STATS_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ImpactReactorBarStatsRowsProof.gd'
IMPACT_REACTOR_BAR_STATS_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ImpactReactorBarStatsRowsProof.tscn'


class C07ImpactReactorBarStatsRowsTests(unittest.TestCase):
    def test_c07_impact_reactor_bar_stats_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2450']['godot_owner'], 'SourceImpactReactorBuildState.source_impact_reactor_power_bar_state')
        # The ImpactReactor tick is live (N2182
        # power.status row + N2192 updateTile advance
        # + N2254 liquid row + N2266 item row + timer
        # + N2391 sense rows + N2430 draw rows +
        # N2438 drawPlan rows) but NOTHING modeled
        # setBars() / setStats(): the power bar
        # (ImpactReactor.java:44-52) shows the NET
        # output (getPowerProduction() minus the
        # consPower usage, floored at 0, * 60 *
        # timeScale, Strings.fixed 1-place) under
        # the bar.poweroutput key in Pal.powerBar
        # with the raw productionEfficiency
        # fraction, and setStats() (ImpactReactor.
        # java:56-70) adds productionTime
        # (itemDuration / 60f, when the block has
        # items) and the warmupTime composite label
        # (autoFixed(max, 2) + seconds + " ~ " +
        # autoFixed(equal, 2) + seconds + power
        # equilibrium, when the block has a power
        # consumer). N2450 ports them as TWO
        # pure-only pures (the N2442 stats precedent
        # + the N2422 bar precedent): the bar pure
        # takes the caller-supplied getPowerProduction
        # live read + consPower usage + timeScale +
        # productionEfficiency and returns the label
        # + color + raw fraction, and the stats pure
        # takes itemDuration + the hasItems /
        # hasConsPower gates + warmupSpeed +
        # consPower usage + powerProduction and
        # returns the production time + the warmup
        # label. Five new result symbols: the bar
        # label + color + fraction, the stats
        # production time + warmup label.
        self.assertEqual(
            ledger['N2450']['source_symbols'],
            [
                'source_impact_reactor_power_bar_state_result.label',
                'source_impact_reactor_power_bar_state_result.color',
                'source_impact_reactor_power_bar_state_result.fraction',
                'source_impact_reactor_stats_state_result.production_time_seconds',
                'source_impact_reactor_stats_state_result.warmup_time_label',
            ],
        )
        expected_owners = {
            'source_impact_reactor_power_bar_state_result.label': 'SourceImpactReactorBuildState.source_impact_reactor_power_bar_state',
            'source_impact_reactor_power_bar_state_result.color': 'SourceImpactReactorBuildState.source_impact_reactor_power_bar_state',
            'source_impact_reactor_power_bar_state_result.fraction': 'SourceImpactReactorBuildState.source_impact_reactor_power_bar_state',
            'source_impact_reactor_stats_state_result.production_time_seconds': 'SourceImpactReactorBuildState.source_impact_reactor_stats_state',
            'source_impact_reactor_stats_state_result.warmup_time_label': 'SourceImpactReactorBuildState.source_impact_reactor_stats_state',
        }
        for name in ledger['N2450']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/power/ImpactReactor.java')
                self.assertEqual(symbol['godot_owner'], expected_owners[name])
        self.assertEqual(ledger['N2450']['runtime_proof'], '/root/C07ImpactReactorBarStatsRowsProof')
        self.assertEqual(
            ledger['N2450']['tests'],
            [
                'test_c07_impact_reactor_bar_stats_rows_registration',
                'test_all_c07_impact_reactor_bar_stats_rows_input_evidence_is_exact',
                'test_impact_reactor_bar_stats_rows_state',
                'test_reference_graph_and_actual_c07_impact_reactor_bar_stats_rows',
            ],
        )
        self.assertTrue(ledger['N2450']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #73 (1-based in
        # the merged advances-28 DEFERRED base): the
        # ImpactReactor setBars / setStats rows entry
        # is REMOVED -- the power bar and both stat
        # rows are live now. Net 258 - 1 = 257. The
        # power-production, explosion, read/write,
        # per-def stat, shouldConsume, impactPower
        # and disabled-early-return entries STAY.
        self.assertFalse(any(entry.startswith('ImpactReactor setBars / setStats rows (') for entry in ledger['N2450']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ImpactReactor power-production rows (') for entry in ledger['N2450']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ImpactReactor explosion rows (') for entry in ledger['N2450']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ImpactReactor read/write rows (') for entry in ledger['N2450']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ImpactReactor per-def stat rows (') for entry in ledger['N2450']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ImpactReactor shouldConsume gate') for entry in ledger['N2450']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ImpactReactor impactPower event rows (') for entry in ledger['N2450']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ImpactReactor disabled-early-return rows (') for entry in ledger['N2450']['deferred_exprs']))
        self.assertEqual(len(ledger['N2450']['deferred_exprs']), 257)

    def test_all_c07_impact_reactor_bar_stats_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2450']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceImpactReactorBuildState.source_impact_reactor_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/power/ImpactReactor.java',
            'core/src/mindustry/world/blocks/power/PowerGenerator.java',
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/meta/Stat.java',
            'core/src/mindustry/world/meta/StatUnit.java',
            'core/src/mindustry/graphics/Pal.java',
            'core/src/mindustry/ui/Bar.java',
            'core/assets/bundles/bundle.properties',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        # Strings.fixed / autoFixed and the
        # Mathf clamp / pow live in arc, not
        # mindustry (the N2191 precedent):
        # fixedBuilder truncates (Strings.
        # java:735), autoFixed truncates then
        # strips precision (Strings.java:710-722),
        # clamp(float) clamps to [0, 1]
        # (Mathf.java:402-404), pow is Math.pow
        # (Mathf.java:212-213).
        upstream['arc-core/src/arc/util/Strings.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/util/Strings.java').read_text(encoding='utf-8')
        upstream['arc-core/src/arc/math/Mathf.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/math/Mathf.java').read_text(encoding='utf-8')
        for expr in ledger['N2450']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_impact_reactor_bar_stats_rows_state(self):
        impact_reactor = IMPACT_REACTOR_STATE.read_text(encoding='utf-8')
        # The power bar (ImpactReactor.setBars(),
        # ImpactReactor.java:44-52): super.setBars()
        # then addBar("power", ...) with the label
        # lambda (Core.bundle.format("bar.
        # poweroutput", Strings.fixed(Math.max(
        # entity.getPowerProduction() - (consPower
        # == null ? 0f : consPower.usage), 0) * 60
        # * entity.timeScale(), 1))), the color
        # lambda (() -> Pal.powerBar) and the
        # fraction lambda (() -> entity.
        # productionEfficiency). getPowerProduction
        # is the caller-supplied live read
        # (PowerGenerator.java:156-158, enabled ?
        # powerProduction * productionEfficiency :
        # 0f) -- the producer fold itself waits
        # for its own slice (DEFERRED #71). The
        # usage is the ConsumePower field (public
        # float usage;, ConsumePower.java:10),
        # 0f when consPower is null. Strings.
        # fixed TRUNCATES (arc Strings.java:735),
        # it does NOT round (the N2426 lesson).
        # The label is the bundle key + the
        # formatted amount -- Core.bundle.format
        # composes the rendered "Power Output:
        # 6300.0" at render (bar.poweroutput =
        # Power Output: {0}, bundle.properties:
        # 1287; the N2422 precedent). The color
        # token is Pal.powerBar (powerBar =
        # Color.valueOf("ec7b4c"), Pal.java:93).
        # The fraction is RAW: the Bar itself
        # clamps at render (Bar.java:33/:80; clamp
        # to [0, 1] is return Math.max(Math.min(
        # value, 1f), 0f);, Mathf.java:402-404) --
        # the N2422 lesson.
        # The stats rows (ImpactReactor.setStats(),
        # ImpactReactor.java:56-70): super.setStats()
        # then productionTime (itemDuration / 60f,
        # StatUnit.seconds) when hasItems, and the
        # warmupTime composite label when consPower
        # != null: max = -ln(0.001) / warmupSpeed
        # / 60, equal = -ln(1 - (usage /
        # powerProduction)^(1/5)) / warmupSpeed /
        # 60, autoFixed to 2 places then joined
        # with the LOCALIZED units -- "seconds"
        # (unit.seconds, bundle.properties:1360)
        # and "power equilibrium" (unit.
        # powerequilibrium, bundle.properties:
        # 1357) via StatUnit.localized() (return
        # Core.bundle.get("unit." + name.
        # toLowerCase(Locale.ROOT));, StatUnit.
        # java:61). autoFixed truncates to the max
        # digits then strips precision (arc
        # Strings.java:710-722). Mathf.pow is
        # Math.pow (Mathf.java:212-213), and log()
        # is the natural log. The tokens are exact:
        # warmupTime (Stat.java:64) and
        # productionTime (Stat.java:69), seconds
        # (StatUnit.java:26) and powerEquilibrium
        # (StatUnit.java:23).
        # Def constants, verified first (Blocks.
        # java:2632-2645): powerProduction 130f,
        # itemDuration 140f (NOT the class default
        # 60f, ImpactReactor.java:20), consumePower
        # 25f; warmupSpeed is NOT overridden, so
        # the class default 0.001f (ImpactReactor.
        # java:19) applies. At the def: net (130 -
        # 25) * 60 = 6300.0, production time 140 /
        # 60 = 2.33s, max 115.12s, equal 21.16s.
        # Pure-only: the tick never calls setBars /
        # setStats. Keep each Java expr on ONE
        # comment line (the N2148 lesson: a split
        # line fails this test).
        self.assertIn('static func source_impact_reactor_power_bar_state', impact_reactor)
        self.assertIn('static func source_impact_reactor_stats_state', impact_reactor)
        self.assertIn('public void setBars(){', impact_reactor)
        self.assertIn('super.setBars();', impact_reactor)
        self.assertIn('addBar("power", (GeneratorBuild entity) -> new Bar(() ->', impact_reactor)
        self.assertIn('Core.bundle.format("bar.poweroutput",', impact_reactor)
        self.assertIn('Strings.fixed(Math.max(entity.getPowerProduction() - (consPower == null ? 0f : consPower.usage), 0) * 60 * entity.timeScale(), 1)),', impact_reactor)
        self.assertIn('() -> Pal.powerBar,', impact_reactor)
        self.assertIn('() -> entity.productionEfficiency));', impact_reactor)
        self.assertIn('public float getPowerProduction(){', impact_reactor)
        self.assertIn('return enabled ? powerProduction * productionEfficiency : 0f;', impact_reactor)
        self.assertIn('public float usage;', impact_reactor)
        self.assertIn('dec.append((int)(float)(d * Math.pow(10, decimalPlaces) + 0.0001f));', impact_reactor)
        self.assertIn('bar.poweroutput = Power Output: {0}', impact_reactor)
        self.assertIn('powerBar = Color.valueOf("ec7b4c"),', impact_reactor)
        self.assertIn('lastValue = value = Mathf.clamp(fraction.get());', impact_reactor)
        self.assertIn('float computed = Mathf.clamp(fraction.get());', impact_reactor)
        self.assertIn('return Math.max(Math.min(value, 1f), 0f);', impact_reactor)
        self.assertIn('public void setStats(){', impact_reactor)
        self.assertIn('if(hasItems){', impact_reactor)
        self.assertIn('stats.add(Stat.productionTime, itemDuration / 60f, StatUnit.seconds);', impact_reactor)
        self.assertIn('if(consPower != null){', impact_reactor)
        self.assertIn('float max = -(float)Math.log(0.001f) / warmupSpeed / 60f;', impact_reactor)
        self.assertIn('float equal = -(float)Math.log(1f - Mathf.pow(consPower.usage / powerProduction, 1f / 5f)) / warmupSpeed / 60f;', impact_reactor)
        self.assertIn('stats.add(Stat.warmupTime, t -> {', impact_reactor)
        self.assertIn('t.add(Strings.autoFixed(max, 2) + " " + StatUnit.seconds.localized() + (consPower != null ?', impact_reactor)
        self.assertIn('" ~ " + Strings.autoFixed(equal, 2) + " " + StatUnit.seconds.localized() + " " + StatUnit.powerEquilibrium.localized() : ""));', impact_reactor)
        self.assertIn('value = (float)Mathf.floor(value * Mathf.pow(10, max) + 0.001f) / Mathf.pow(10, max);', impact_reactor)
        self.assertIn('return fixed(value, Math.min(max, precision));', impact_reactor)
        self.assertIn('return (float)Math.pow(a, b);', impact_reactor)
        self.assertIn('warmupTime = new Stat("warmupTime", StatCat.power),', impact_reactor)
        self.assertIn('productionTime = new Stat("productionTime", StatCat.crafting),', impact_reactor)
        self.assertIn('seconds = new StatUnit("seconds"),', impact_reactor)
        self.assertIn('powerEquilibrium = new StatUnit("powerEquilibrium"),', impact_reactor)
        self.assertIn('return Core.bundle.get("unit." + name.toLowerCase(Locale.ROOT));', impact_reactor)
        self.assertIn('unit.seconds = seconds', impact_reactor)
        self.assertIn('unit.powerequilibrium = power equilibrium', impact_reactor)
        self.assertIn('public float warmupSpeed = 0.001f;', impact_reactor)
        self.assertIn('public float itemDuration = 60f;', impact_reactor)
        self.assertIn('impactReactor = new ImpactReactor("impact-reactor"){{', impact_reactor)
        self.assertIn('powerProduction = 130f;', impact_reactor)
        self.assertIn('itemDuration = 140f;', impact_reactor)
        self.assertIn('consumePower(25f);', impact_reactor)
        # The documented limits record the bar /
        # stats rows as live.
        self.assertIn('Bar / stats rows live (N2450)', impact_reactor)
        # The proof's keys drive the two pures (the
        # bar label at the def net 6300.0 + the
        # null-consPower 7800.0 + the truncation
        # case 6000.0 + the timeScale half 3150.0,
        # the zero floor at/below the usage, the
        # raw fraction above 1.0, the production
        # time at the def 140f + the class default
        # 60f, the warmup label "115.12 seconds ~
        # 21.16 seconds power equilibrium" at the
        # def, and the null gates).
        proof = IMPACT_REACTOR_BAR_STATS_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'bar_label_net',
            'bar_label_zero_floor',
            'bar_fraction_raw',
            'stats_production_time',
            'stats_warmup_label',
            'stats_gates_null',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceImpactReactorBuildState.gd")', proof)
        self.assertTrue(IMPACT_REACTOR_STATE.exists())
        self.assertTrue(IMPACT_REACTOR_BAR_STATS_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07ImpactReactorBarStatsRowsProof.gd', IMPACT_REACTOR_BAR_STATS_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_impact_reactor_bar_stats_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ImpactReactorBarStatsRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_IMPACT_REACTOR_BAR_STATS_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'bar_label_net',
            'bar_label_zero_floor',
            'bar_fraction_raw',
            'stats_production_time',
            'stats_warmup_label',
            'stats_gates_null',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
