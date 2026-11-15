import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_UNLOADER_STATE = ROOT / 'godot-mindustry/src/game/SourcePayloadUnloaderBuildState.gd'
PAYLOAD_UNLOADER_DUMP_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadUnloaderDumpProof.gd'
PAYLOAD_UNLOADER_DUMP_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadUnloaderDumpProof.tscn'
PAYLOAD_UNLOADER_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/blocks/payloads/PayloadUnloader.java'
PAYLOAD_LOADER_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/blocks/payloads/PayloadLoader.java'
BUILDING_COMP_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java'
LIQUID_MODULE_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/modules/LiquidModule.java'


class C07PayloadUnloaderDumpTests(unittest.TestCase):
    def test_c07_payload_unloader_dump_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2293']['godot_owner'], 'SourcePayloadUnloaderBuildState.source_payload_unloader_dump_state')
        # N2163 proved the PayloadUnloader family's live power
        # read, N2209 the shouldConsume gate (return payload !=
        # null, inherited verbatim from PayloadLoaderBuild, no
        # enabled term), N2232 the updateTile advance
        # (moveInPayload / moveOutPayload + unload
        # items/liquids + battery unload into lastOutputPower)
        # and N2279 the live payload fill -- but the advance
        # unloaded into stores that never drained: the dump
        # rows at the END of updateTile (PayloadUnloader.java:
        # 105-108, `dumpLiquid(liquids.current());` + `for(int
        # i = 0; i < offloadSpeed; i++){ dumpAccumulate(); }`,
        # offloadSpeed 4) were RED-deferred all along, so a
        # live payload-unloader filled to capacity and stopped
        # consuming. N2293 is the dump rows: ONE pure
        # (source_payload_unloader_dump_state) covers both the
        # liquid dump (dumpLiquid(current), scaling 2f, output
        # dir -1, through the shared dump_liquid_state routing)
        # and the item dump (offloadSpeed x dumpAccumulate(),
        # each adding delta() and firing dump(null) through
        # the shared dump_accumulate_state + dump_item_state
        # routing while the accumulator is >= 1f). The dump is
        # UNCONDITIONAL -- outside the payload-null check
        # (:52-54) and outside the shouldExport /
        # moveInPayload if-else (:57-103), so it runs even when
        # the unloader holds no payload and even when
        # efficiency is 0. Six new result symbols: the liquids
        # after the tick, the dumped liquid, the items after
        # the tick, the dumped item count, the cursor, and the
        # dump accumulator.
        self.assertEqual(
            ledger['N2293']['source_symbols'],
            [
                'source_payload_unloader_dump_state_result.liquids_after',
                'source_payload_unloader_dump_state_result.dumped_liquid',
                'source_payload_unloader_dump_state_result.items_after',
                'source_payload_unloader_dump_state_result.dumped_items',
                'source_payload_unloader_dump_state_result.cursor_after',
                'source_payload_unloader_dump_state_result.dump_accum_after',
            ],
        )
        for name in ledger['N2293']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/payloads/PayloadUnloader.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadUnloaderBuildState.source_payload_unloader_dump_state')
        self.assertEqual(ledger['N2293']['runtime_proof'], '/root/C07PayloadUnloaderDumpProof')
        self.assertEqual(
            ledger['N2293']['tests'],
            [
                'test_c07_payload_unloader_dump_registration',
                'test_all_c07_payload_unloader_dump_input_evidence_is_exact',
                'test_payload_unloader_dump_state',
                'test_reference_graph_and_actual_c07_payload_unloader_dump',
            ],
        )
        self.assertTrue(ledger['N2293']['deferred_exprs'])
        # This slice resolves the dump-rows entry (the dump is
        # live since N2293) and adds three narrower entries
        # (the neighbour live fill, the neighbour write-back,
        # and the campaign-unlock surfacing). The timer
        # cadence, the live front query, and the
        # movePayload/dumpPayload application entries stay
        # verbatim.
        self.assertFalse(any(entry.startswith('PayloadUnloader dump rows (') for entry in ledger['N2293']['deferred_exprs']))
        for prefix in [
            'PayloadUnloader dump neighbour live fill (',
            'PayloadUnloader dump neighbour write-back (',
            'PayloadUnloader dumpLiquid campaign unlock surfacing (',
            'PayloadUnloader updateTile timer cadence (',
            'PayloadUnloader live front query (',
            'PayloadUnloader movePayload/dumpPayload application (',
        ]:
            with self.subTest(prefix=prefix):
                self.assertTrue(any(entry.startswith(prefix) for entry in ledger['N2293']['deferred_exprs']))

    def test_all_c07_payload_unloader_dump_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2293']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadUnloaderBuildState.source_payload_unloader_dump_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/payloads/PayloadUnloader.java',
            'core/src/mindustry/world/blocks/payloads/PayloadLoader.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/modules/LiquidModule.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2293']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_unloader_dump_state(self):
        payload_unloader = PAYLOAD_UNLOADER_STATE.read_text(encoding='utf-8')
        # The dump rows at the END of updateTile
        # (PayloadUnloaderBuild.updateTile(),
        # PayloadUnloader.java:105-108), UNCONDITIONAL --
        # outside the payload-null check (:52-54) and outside
        # the shouldExport / moveInPayload if-else (:57-103):
        # `dumpLiquid(liquids.current());` (scaling 2f, output
        # dir -1, BuildingComp.java:877-882) + `for(int i = 0;
        # i < offloadSpeed; i++){ dumpAccumulate(); }`
        # (offloadSpeed 4, PayloadUnloader.java:9).
        # dumpLiquid (BuildingComp.java:886-908) early-returns
        # at <= 0.0001f (:889), unlocks the liquid on campaign
        # (:891), then scans proximity from the cdump cursor,
        # incrementDump once per iteration (:894), gating on
        # other.block.hasLiquids && canDumpLiquid &&
        # other.liquids != null (:901) and transferring (fract
        # - ofract) * block.liquidCapacity / scaling when
        # ofract < fract (:905); transferLiquid (:914-921)
        # flows min(neighbour free capacity, amount) only when
        # next.acceptLiquid(self(), liquid). dumpAccumulate()
        # (BuildingComp.java:1048-1050) delegates to
        # dumpAccumulate(null) (:1053-1061): `dumpAccum +=
        # delta(); while(dumpAccum >= 1f){ res |= dump(item);
        # dumpAccum -=1f; }` -- it may dump MULTIPLE times per
        # call, and the loop calls it 4 times per tick, so
        # dumpAccum grows by 4*delta each tick. dump(null)
        # (BuildingComp.java:1072-1114) scans neighbours outer
        # / content items inner and hands 1 item to the first
        # accepting neighbour, advancing cdump once per
        # neighbour checked. The liquid scan is a full cycle
        # (N neighbours = N incrementDump calls), so the
        # cursor only moves in the item phase (the N2286
        # cursor invariant). Keep each Java expr on ONE
        # comment line (the N2148 lesson: a split line fails
        # this test).
        self.assertIn('static func source_payload_unloader_dump_state', payload_unloader)
        self.assertIn('dumpLiquid(liquids.current());', payload_unloader)
        self.assertIn('for(int i = 0; i < offloadSpeed; i++){', payload_unloader)
        self.assertIn('dumpAccumulate();', payload_unloader)
        self.assertIn('public int offloadSpeed = 4;', payload_unloader)
        self.assertIn('public class PayloadUnloader extends PayloadLoader{', payload_unloader)
        self.assertIn('hasItems = true;', payload_unloader)
        self.assertIn('itemCapacity = 100;', payload_unloader)
        self.assertIn('liquidCapacity = 100f;', payload_unloader)
        self.assertIn('public void dumpLiquid(Liquid liquid){', payload_unloader)
        self.assertIn('dumpLiquid(liquid, 2f);', payload_unloader)
        self.assertIn('public void dumpLiquid(Liquid liquid, float scaling){', payload_unloader)
        self.assertIn('dumpLiquid(liquid, scaling, -1);', payload_unloader)
        self.assertIn('public void dumpLiquid(Liquid liquid, float scaling, int outputDir){', payload_unloader)
        self.assertIn('int dump = this.cdump;', payload_unloader)
        self.assertIn('if(liquids.get(liquid) <= 0.0001f) return;', payload_unloader)
        self.assertIn('if(!net.client() && state.isCampaign() && team == state.rules.defaultTeam) liquid.unlock();', payload_unloader)
        self.assertIn('for(int i = 0; i < proximity.size; i++){', payload_unloader)
        self.assertIn('incrementDump(proximity.size);', payload_unloader)
        self.assertIn('Building other = proximity.get((i + dump) % proximity.size);', payload_unloader)
        self.assertIn('if(outputDir != -1 && (outputDir + rotation) % 4 != relativeTo(other)) continue;', payload_unloader)
        self.assertIn('other = other.getLiquidDestination(self(), liquid);', payload_unloader)
        self.assertIn('if(other != null && other.block.hasLiquids && canDumpLiquid(other, liquid) && other.liquids != null){', payload_unloader)
        self.assertIn('float ofract = other.liquids.get(liquid) / other.block.liquidCapacity;', payload_unloader)
        self.assertIn('float fract = liquids.get(liquid) / block.liquidCapacity;', payload_unloader)
        self.assertIn('if(ofract < fract) transferLiquid(other, (fract - ofract) * block.liquidCapacity / scaling, liquid);', payload_unloader)
        self.assertIn('public boolean canDumpLiquid(Building to, Liquid liquid){', payload_unloader)
        self.assertIn('public void transferLiquid(Building next, float amount, Liquid liquid){', payload_unloader)
        self.assertIn('float flow = Math.min(next.block.liquidCapacity - next.liquids.get(liquid), amount);', payload_unloader)
        self.assertIn('if(next.acceptLiquid(self(), liquid)){', payload_unloader)
        self.assertIn('next.handleLiquid(self(), liquid, flow);', payload_unloader)
        self.assertIn('liquids.remove(liquid, flow);', payload_unloader)
        self.assertIn('public Building getLiquidDestination(Building from, Liquid liquid){', payload_unloader)
        self.assertIn('return self();', payload_unloader)
        self.assertIn('public boolean dumpAccumulate(){', payload_unloader)
        self.assertIn('return dumpAccumulate(null);', payload_unloader)
        self.assertIn('public boolean dumpAccumulate(Item item){', payload_unloader)
        self.assertIn('dumpAccum += delta();', payload_unloader)
        self.assertIn('while(dumpAccum >= 1f){', payload_unloader)
        self.assertIn('res |= dump(item);', payload_unloader)
        self.assertIn('dumpAccum -=1f;', payload_unloader)
        self.assertIn('public boolean dump(Item todump){', payload_unloader)
        self.assertIn('if(!block.hasItems || items.total() == 0 || proximity.size == 0 || (todump != null && !items.has(todump))) return false;', payload_unloader)
        self.assertIn('var allItems = content.items();', payload_unloader)
        self.assertIn('if(other.acceptItem(self(), item) && canDump(other, item)){', payload_unloader)
        self.assertIn('other.handleItem(self(), item);', payload_unloader)
        self.assertIn('items.remove(item, 1);', payload_unloader)
        self.assertIn('public void incrementDump(int prox){', payload_unloader)
        self.assertIn('if(prox != 0){', payload_unloader)
        self.assertIn('cdump = ((cdump + 1) % prox);', payload_unloader)
        self.assertIn('transient int cdump;', payload_unloader)
        self.assertIn('private transient float dumpAccum;', payload_unloader)
        self.assertIn('return Time.delta * timeScale;', payload_unloader)
        self.assertIn('public boolean canDump(Building to, Item item){', payload_unloader)
        self.assertIn('public Liquid current(){', payload_unloader)
        self.assertIn('return current;', payload_unloader)
        self.assertIn('private Liquid current = content.liquid(0);', payload_unloader)
        # The dump runs through the shared routing -- the
        # shared dump_liquid_state port (which binds
        # transfer_liquid_state), the shared
        # dump_accumulate_state (the static the bridge
        # source_dump_accumulate_attempt_state delegates to --
        # the bridge method is an instance method, so the
        # static pure calls the static it wraps), and the
        # shared dump_item_state routing -- never a hand-rolled
        # routing loop. The loop runs offloadSpeed (4) times.
        self.assertIn('dump_liquid_state(', payload_unloader)
        self.assertIn('dump_accumulate_state(', payload_unloader)
        self.assertIn('dump_item_state(', payload_unloader)
        self.assertIn('range(SOURCE_PAYLOAD_UNLOADER_OFFLOAD_SPEED)', payload_unloader)
        self.assertIn('source_building_liquid_state', payload_unloader)
        self.assertIn('source_building_item_dump_state', payload_unloader)
        # The driver wires the dump into the live tick AFTER
        # the advance (Java order: PayloadUnloader.java:105-108
        # after the moveInPayload branch :57-103), inside the
        # enabled gate like the advance (the N2195 precedent);
        # the neighbour arrays are frame inputs (default []).
        # The pure is called exactly once (its definition plus
        # the one tick call site).
        self.assertIn('source_payload_unloader_dump_state(frame, source_delta, time_scale, item_order, dump_neighbour_liquid_amounts, dump_neighbour_liquid_capacities, dump_neighbour_accepts_liquid, dump_neighbour_can_dump_liquid, dump_neighbour_accepts_item, dump_neighbour_can_dump_item)', payload_unloader)
        self.assertEqual(payload_unloader.count('source_payload_unloader_dump_state('), 2)
        self.assertIn('frame.get("dump_neighbour_liquid_amounts", [])', payload_unloader)
        self.assertIn('frame.get("dump_neighbour_liquid_capacities", [])', payload_unloader)
        self.assertIn('frame.get("dump_neighbour_accepts_liquid", [])', payload_unloader)
        self.assertIn('frame.get("dump_neighbour_can_dump_liquid", [])', payload_unloader)
        self.assertIn('frame.get("dump_neighbour_accepts_item", [])', payload_unloader)
        self.assertIn('frame.get("dump_neighbour_can_dump_item", [])', payload_unloader)
        self.assertIn('frame["cdump"]', payload_unloader)
        self.assertIn('frame["dump_accum"]', payload_unloader)
        self.assertIn('frame["dumped_liquid"]', payload_unloader)
        self.assertIn('frame["dumped_items"]', payload_unloader)
        # The fresh frame binds the dump keys with the Java
        # field defaults (cdump 0, dumpAccum 0f), and the tick
        # preserves them on a frame bound before this slice.
        self.assertIn('"cdump": 0', payload_unloader)
        self.assertIn('"dump_accum": 0.0', payload_unloader)
        self.assertIn('if not frame.has("cdump"):', payload_unloader)
        self.assertIn('if not frame.has("dump_accum"):', payload_unloader)
        # Scope correction, pinned by line number: the brief
        # cited the dump rows as PayloadUnloader.java:104-110,
        # but the dump statements are :105-108 (:104 is blank,
        # :109 closes updateTile). The dump sits OUTSIDE the
        # payload-null check and the shouldExport /
        # moveInPayload if-else (which closes at :103).
        unloader_lines = PAYLOAD_UNLOADER_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(unloader_lines[103].strip(), '')
        self.assertEqual(unloader_lines[104].strip(), 'dumpLiquid(liquids.current());')
        self.assertEqual(unloader_lines[105].strip(), 'for(int i = 0; i < offloadSpeed; i++){')
        self.assertEqual(unloader_lines[106].strip(), 'dumpAccumulate();')
        self.assertEqual(unloader_lines[107].strip(), '}')
        self.assertEqual(unloader_lines[108].strip(), '}')
        self.assertIn('public int offloadSpeed = 4;', PAYLOAD_UNLOADER_JAVA.read_text(encoding='utf-8'))
        self.assertIn('hasItems = true;', PAYLOAD_LOADER_JAVA.read_text(encoding='utf-8'))
        self.assertIn('liquidCapacity = 100f;', PAYLOAD_LOADER_JAVA.read_text(encoding='utf-8'))
        self.assertIn('private Liquid current = content.liquid(0);', LIQUID_MODULE_JAVA.read_text(encoding='utf-8'))
        self.assertIn('dumpAccum += delta();', BUILDING_COMP_JAVA.read_text(encoding='utf-8'))
        # The documented limits now record the dump rows as
        # live (N2293); the shouldConsume gate stays live
        # (N2209), the advance stays live (N2232), and the
        # live fill stays live (N2279).
        self.assertIn('dump rows live (N2293)', payload_unloader)
        self.assertNotIn('dump cadence waits for its own slice', payload_unloader)
        self.assertIn('shouldConsume gate live (N2209)', payload_unloader)
        self.assertIn('updateTile advance live (N2232)', payload_unloader)
        self.assertIn('live payload fill live (N2279)', payload_unloader)
        self.assertIn('static func source_payload_unloader_update_tile_advance_state', payload_unloader)
        self.assertIn('static func source_payload_unloader_should_consume_state', payload_unloader)
        self.assertIn('static func source_payload_unloader_handle_payload_state', payload_unloader)
        # The proof's keys drive the pure dump (the liquid
        # transfer, the 2f scaling, the item dump through the
        # accumulator, the 4*delta accumulator growth, the
        # no-transfer-when-full guards) plus the live tick (a
        # placed payload-unloader dumps both liquid and items
        # in one tick, even with no payload and efficiency 0).
        proof = PAYLOAD_UNLOADER_DUMP_PROOF.read_text(encoding='utf-8')
        for key in [
            'dump_transfers_liquid_to_neighbour',
            'dump_scales_liquid_by_two',
            'dump_items_via_accumulate',
            'dump_accum_grows_by_four_delta',
            'dump_no_transfer_when_neighbour_full',
            'live_tick_dumps_both',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourcePayloadUnloaderBuildState.gd")', proof)
        self.assertTrue(PAYLOAD_UNLOADER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('preload("res://src/game/SourceLiquidModuleState.gd")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/src/game/SourceLiquidModuleState.gd').is_file())
        self.assertIn('preload("res://src/game/SourceContentRegistryRuntimeState.gd")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/src/game/SourceContentRegistryRuntimeState.gd').is_file())
        scene = PAYLOAD_UNLOADER_DUMP_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07PayloadUnloaderDumpProof.gd', scene)
        self.assertIn('C07PayloadUnloaderDumpProof', scene)

    def test_reference_graph_and_actual_c07_payload_unloader_dump(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadUnloaderDumpProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_UNLOADER_DUMP_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'dump_transfers_liquid_to_neighbour',
            'dump_scales_liquid_by_two',
            'dump_items_via_accumulate',
            'dump_accum_grows_by_four_delta',
            'dump_no_transfer_when_neighbour_full',
            'live_tick_dumps_both',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
