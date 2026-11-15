import json
import re
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
ACCELERATOR_STATE = ROOT / 'godot-mindustry/src/game/SourceAcceleratorBuildState.gd'
ACCELERATOR_LAUNCH_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07AcceleratorLaunchProof.gd'
ACCELERATOR_LAUNCH_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07AcceleratorLaunchProof.tscn'


class C07AcceleratorLaunchTests(unittest.TestCase):
    def test_c07_accelerator_launch_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2271']['godot_owner'], 'SourceAcceleratorBuildState.source_accelerator_can_launch_state')
        # N2183 proved the Accelerator family's live power read,
        # N2191 the updateTile advance (heat/statusLerp/
        # time/launchHeat/progress) and N2267 the launch-block
        # item consumer rows -- but the launch itself was never
        # modeled: canLaunch() (Accelerator.java:239-240,
        # `return isValid() && !net.client() &&
        # state.isCampaign() && efficiency > 0f &&
        # power.graph.getBatteryStored() >=
        # powerBufferRequirement-0.00001f && progress >= 1f &&
        # !launching;`) needs efficiency AND a full battery
        # (powerBufferRequirement 1,000,000f, Blocks.java:6826)
        # AND progress 1f AND not launching, and
        # buildConfiguration (Accelerator.java:258-290) consumes
        # the stored core-nucleus items, drains the battery via
        # useBatteries and resets progress to 0f. N2271 is the
        # canLaunch battery gate + the launch transition: the
        # pure gate (source_accelerator_can_launch_state)
        # evaluates the four tick-state conditions (the
        # environment half -- isValid / net.client /
        # state.isCampaign -- is NOT modeled, documented in the
        # docstring) and the pure transition
        # (source_accelerator_launch_state) mirrors consume()
        # (BuildingComp.java:1911-1915, each consumer's trigger;
        # ConsumeItems.trigger removes each requirement stack,
        # ConsumeItems.java:44-48, clamped by ItemModule.remove,
        # ItemModule.java:258-263) + `ItemSeq resources = new
        # ItemSeq();` / `resources.add(items);` /
        # `items.clear();` (Accelerator.java:266-268) +
        # useBatteries (PowerGraph.java:154-167, the total drain
        # `used = min(stored, needed)`) + `progress = 0f;`
        # (Accelerator.java:271). The driver evaluates the gate
        # on the one-shot frame key `launch_requested` (default
        # false) and clears the request in both cases -- Java
        # closes the dialog, there is no queue. The resources
        # are DISCARDED: Java hands them to
        # universe.updateLaunchResources(resources)
        # (Accelerator.java:281), which has no port equivalent.
        # The launching flag is NOT touched: beginLaunch
        # (Accelerator.java:334-337) sets it true via
        # renderer.showLaunch, which is deferred. Nine new
        # result symbols: the gate + its four per-condition
        # flags, the transition's items + resources + battery +
        # progress.
        self.assertEqual(
            ledger['N2271']['source_symbols'],
            [
                'source_accelerator_can_launch_state_result.can_launch',
                'source_accelerator_can_launch_state_result.efficiency_ok',
                'source_accelerator_can_launch_state_result.battery_ok',
                'source_accelerator_can_launch_state_result.progress_ok',
                'source_accelerator_can_launch_state_result.not_launching',
                'source_accelerator_launch_state_result.items',
                'source_accelerator_launch_state_result.resources',
                'source_accelerator_launch_state_result.battery_stored',
                'source_accelerator_launch_state_result.progress',
            ],
        )
        for name in ledger['N2271']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/campaign/Accelerator.java',
                    'core/src/mindustry/world/blocks/power/PowerGraph.java',
                    'core/src/mindustry/world/consumers/ConsumeItems.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/world/modules/ItemModule.java',
                    'core/src/mindustry/content/Blocks.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_accelerator_can_launch_state_result.can_launch': 'SourceAcceleratorBuildState.source_accelerator_can_launch_state',
                    'source_accelerator_can_launch_state_result.efficiency_ok': 'SourceAcceleratorBuildState.source_accelerator_can_launch_state',
                    'source_accelerator_can_launch_state_result.battery_ok': 'SourceAcceleratorBuildState.source_accelerator_can_launch_state',
                    'source_accelerator_can_launch_state_result.progress_ok': 'SourceAcceleratorBuildState.source_accelerator_can_launch_state',
                    'source_accelerator_can_launch_state_result.not_launching': 'SourceAcceleratorBuildState.source_accelerator_can_launch_state',
                    'source_accelerator_launch_state_result.items': 'SourceAcceleratorBuildState.source_accelerator_launch_state',
                    'source_accelerator_launch_state_result.resources': 'SourceAcceleratorBuildState.source_accelerator_launch_state',
                    'source_accelerator_launch_state_result.battery_stored': 'SourceAcceleratorBuildState.source_accelerator_launch_state',
                    'source_accelerator_launch_state_result.progress': 'SourceAcceleratorBuildState.source_accelerator_launch_state',
                }[name])
        self.assertEqual(ledger['N2271']['runtime_proof'], '/root/C07AcceleratorLaunchProof')
        self.assertEqual(
            ledger['N2271']['tests'],
            [
                'test_c07_accelerator_launch_registration',
                'test_all_c07_accelerator_launch_input_evidence_is_exact',
                'test_accelerator_launch_gate_state',
                'test_reference_graph_and_actual_c07_accelerator_launch',
            ],
        )
        self.assertTrue(ledger['N2271']['deferred_exprs'])

    def test_all_c07_accelerator_launch_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2271']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_accelerator_can_launch_state_result.can_launch': 'SourceAcceleratorBuildState.source_accelerator_can_launch_state',
                    'source_accelerator_can_launch_state_result.efficiency_ok': 'SourceAcceleratorBuildState.source_accelerator_can_launch_state',
                    'source_accelerator_can_launch_state_result.battery_ok': 'SourceAcceleratorBuildState.source_accelerator_can_launch_state',
                    'source_accelerator_can_launch_state_result.progress_ok': 'SourceAcceleratorBuildState.source_accelerator_can_launch_state',
                    'source_accelerator_can_launch_state_result.not_launching': 'SourceAcceleratorBuildState.source_accelerator_can_launch_state',
                    'source_accelerator_launch_state_result.items': 'SourceAcceleratorBuildState.source_accelerator_launch_state',
                    'source_accelerator_launch_state_result.resources': 'SourceAcceleratorBuildState.source_accelerator_launch_state',
                    'source_accelerator_launch_state_result.battery_stored': 'SourceAcceleratorBuildState.source_accelerator_launch_state',
                    'source_accelerator_launch_state_result.progress': 'SourceAcceleratorBuildState.source_accelerator_launch_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/campaign/Accelerator.java',
            'core/src/mindustry/world/blocks/power/PowerGraph.java',
            'core/src/mindustry/world/consumers/ConsumeItems.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/modules/ItemModule.java',
            'core/src/mindustry/type/ItemSeq.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2271']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_accelerator_launch_gate_state(self):
        accelerator = ACCELERATOR_STATE.read_text(encoding='utf-8')
        # The pure canLaunch gate lives on the accelerator build
        # state: canLaunch() (Accelerator.java:239-240) is the
        # conjunction of the environment half (isValid /
        # net.client / state.isCampaign -- NOT modeled, the
        # port has no net / campaign state) and the four
        # tick-state conditions the gate evaluates: efficiency
        # > 0f, battery_stored >= powerBufferRequirement -
        # 0.00001f, progress >= 1f (isCoreBuilt,
        # Accelerator.java:153-154) and !launching. The battery
        # side is getBatteryStored() (PowerGraph.java:118-127),
        # the enabled-battery total of power.status *
        # consPower.capacity; the requirement is the single-def
        # 1,000,000f (Blocks.java:6826). The pure launch
        # transition mirrors buildConfiguration's sector-select
        # branch (Accelerator.java:264-271, re-checked with
        # `if(canLaunch()){`): consume() (BuildingComp.java:
        # 1911-1915, each consumer's trigger; ConsumeItems.
        # trigger removes each requirement stack,
        # ConsumeItems.java:44-48, clamped by ItemModule.remove,
        # ItemModule.java:258-263) removes the core-nucleus
        # requirements (copper 8000 / lead 8000 / silicon 5000
        # / thorium 4000, Blocks.java:3154, N2267), then
        # `ItemSeq resources = new ItemSeq();` /
        # `resources.add(items);` / `items.clear();`
        # (Accelerator.java:266-268) snapshots the remainder
        # and empties the store, `power.graph.useBatteries
        # (powerBufferRequirement);` (Accelerator.java:270)
        # drains the battery total by min(stored, needed)
        # (PowerGraph.java:154-167; the per-battery
        # proportional scaling waits for a battery-list graph
        # slice) and `progress = 0f;` (Accelerator.java:271)
        # resets the core. The driver evaluates the gate on the
        # one-shot frame key `launch_requested` (default
        # false), applies the transition only when the gate
        # passes, DISCARDS the resources (Java hands them to
        # universe.updateLaunchResources(resources),
        # Accelerator.java:281 -- no port equivalent) and
        # CLEARS the request in both cases. The launching flag
        # is never touched: beginLaunch (Accelerator.java:
        # 334-337) sets it true via renderer.showLaunch
        # (Accelerator.java:273, deferred with the Time.runTask
        # launch, Accelerator.java:275-286, and the
        # acceleratorUse event, Accelerator.java:289).
        self.assertIn('static func source_accelerator_can_launch_state(efficiency: float, battery_stored: float, progress: float, launching: bool, power_buffer_requirement: float) -> Dictionary:', accelerator)
        self.assertIn('static func source_accelerator_launch_state(items: Dictionary, battery_stored: float, power_buffer_requirement: float, requirement_stacks: Array) -> Dictionary:', accelerator)
        self.assertIn('const SOURCE_ACCELERATOR_POWER_BUFFER_REQUIREMENT := 1000000.0', accelerator)
        self.assertIn('public boolean canLaunch(){', accelerator)
        self.assertIn('return isValid() && !net.client() && state.isCampaign() && efficiency > 0f && power.graph.getBatteryStored() >= powerBufferRequirement-0.00001f && progress >= 1f && !launching;', accelerator)
        self.assertIn('public boolean isCoreBuilt(){', accelerator)
        self.assertIn('return progress >= 1f;', accelerator)
        self.assertIn('public boolean launching;', accelerator)
        self.assertIn('public void buildConfiguration(Table table){', accelerator)
        self.assertIn('if(!canLaunch()) return;', accelerator)
        self.assertIn('if(canLaunch()){', accelerator)
        self.assertIn('consume();', accelerator)
        self.assertIn('ItemSeq resources = new ItemSeq();', accelerator)
        self.assertIn('resources.add(items);', accelerator)
        self.assertIn('items.clear();', accelerator)
        self.assertIn('power.graph.useBatteries(powerBufferRequirement);', accelerator)
        self.assertIn('progress = 0f;', accelerator)
        self.assertIn('renderer.showLaunch(this);', accelerator)
        self.assertIn('Time.runTask(launchDuration() - 6f, () -> {', accelerator)
        self.assertIn('universe.updateLaunchResources(resources);', accelerator)
        self.assertIn('Events.fire(Trigger.acceleratorUse);', accelerator)
        self.assertIn('consumeItems(launchBlock.requirements);', accelerator)
        self.assertIn('public void beginLaunch(boolean launching){', accelerator)
        self.assertIn('this.launching = true;', accelerator)
        self.assertIn('launching = false;', accelerator)
        self.assertIn('public float powerBufferRequirement;', accelerator)
        self.assertIn('public float getBatteryStored(){', accelerator)
        self.assertIn('totalAccumulator += battery.power.status * battery.block.consPower.capacity;', accelerator)
        self.assertIn('public float useBatteries(float needed){', accelerator)
        self.assertIn('float stored = getBatteryStored();', accelerator)
        self.assertIn('if(Mathf.equal(stored, 0f)) return 0f;', accelerator)
        self.assertIn('float used = Math.min(stored, needed);', accelerator)
        self.assertIn('float consumedPowerPercentage = Math.min(1.0f, needed / stored);', accelerator)
        self.assertIn('battery.power.status *= (1f-consumedPowerPercentage);', accelerator)
        self.assertIn('return used;', accelerator)
        self.assertIn('public void consume(){', accelerator)
        self.assertIn('for(Consume cons : block.consumers){', accelerator)
        self.assertIn('cons.trigger(self());', accelerator)
        self.assertIn('build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));', accelerator)
        self.assertIn('amount = Math.min(amount, items[item.id]);', accelerator)
        self.assertIn('items[item.id] -= amount;', accelerator)
        self.assertIn('if(items[i] != 0){', accelerator)
        self.assertIn('itemModule.each(this::add);', accelerator)
        self.assertIn('powerBufferRequirement = 1_000_000f;', accelerator)
        self.assertIn('requirements(Category.effect, with(Items.copper, 8000, Items.lead, 8000, Items.silicon, 5000, Items.thorium, 4000));', accelerator)
        # The gate returns the conjunction plus one flag per
        # tick-state condition; the transition returns the
        # emptied items, the resources remainder, the drained
        # battery total and progress 0.0. The tick wires the
        # one-shot `launch_requested` key: it evaluates the
        # gate through the pure function, applies the
        # transition through the pure function, and clears the
        # request -- the clear is outside the gate branch, so
        # it runs on a failed gate too. The battery_stored
        # frame input has no live fill (the graph summary
        # computes it but does not stamp it on the building
        # frame), so the gate reads the frame as-is.
        self.assertIn('"can_launch"', accelerator)
        self.assertIn('"efficiency_ok"', accelerator)
        self.assertIn('"battery_ok"', accelerator)
        self.assertIn('"progress_ok"', accelerator)
        self.assertIn('"not_launching"', accelerator)
        self.assertIn('"resources"', accelerator)
        self.assertIn('"launch_requested"', accelerator)
        self.assertIn('frame["launch_requested"] = false', accelerator)
        self.assertIn('source_accelerator_can_launch_state(float(frame.get("efficiency", 0.0)), float(frame.get("battery_stored", 0.0)), float(frame.get("progress", 0.0)), bool(frame.get("launching", false)), SOURCE_ACCELERATOR_POWER_BUFFER_REQUIREMENT)', accelerator)
        self.assertIn('source_accelerator_launch_state(frame.get("items", {}), float(frame.get("battery_stored", 0.0)), SOURCE_ACCELERATOR_POWER_BUFFER_REQUIREMENT, _accelerator_item_stacks_for_block(block_id))', accelerator)
        self.assertIn('frame["battery_stored"]', accelerator)
        # The proof's keys drive the pure gate (one failing
        # condition each: efficiency 0, short battery, progress
        # below 1, launching -- plus the battery boundary at
        # requirement - 0.00001) and the pure transition
        # (items cleared, resources = items minus requirements
        # clamped at 0 with only nonzero remainders kept --
        # ItemModule.each visits nonzero counts only,
        # ItemModule.java:100-106 -- battery drained by the
        # requirement, progress 0.0), plus the live tick (a requested launch
        # with a passing gate clears items / drains the battery
        # / resets progress / clears the request, a requested
        # launch with a failing gate clears the request and
        # changes nothing else, and launching is never
        # touched). The scene file exists and the proof
        # preloads scripts that exist.
        proof = ACCELERATOR_LAUNCH_PROOF.read_text(encoding='utf-8')
        for key in [
            'can_launch_requires_positive_efficiency',
            'can_launch_requires_full_battery',
            'can_launch_requires_progress_one',
            'can_launch_false_when_launching',
            'launch_clears_items_and_resets_progress',
            'launch_drains_battery_by_requirement',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertTrue(ACCELERATOR_LAUNCH_PROOF_SCENE.exists())
        self.assertIn('SourceAcceleratorBuildState.gd', proof)
        for preload in re.findall(r'preload\("(res://[^"]+)"\)', proof):
            with self.subTest(preload=preload):
                self.assertTrue((ROOT / 'godot-mindustry' / preload[len('res://'):]).is_file(), preload)
        scene = ACCELERATOR_LAUNCH_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07AcceleratorLaunchProof.gd', scene)

    def test_reference_graph_and_actual_c07_accelerator_launch(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07AcceleratorLaunchProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_ACCELERATOR_LAUNCH_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'can_launch_requires_positive_efficiency',
            'can_launch_requires_full_battery',
            'can_launch_requires_progress_one',
            'can_launch_false_when_launching',
            'launch_clears_items_and_resets_progress',
            'launch_drains_battery_by_requirement',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
