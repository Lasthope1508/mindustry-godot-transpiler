import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_DECONSTRUCTOR_STATE = ROOT / 'godot-mindustry/src/game/SourcePayloadDeconstructorBuildState.gd'
PAYLOAD_DECONSTRUCTOR_ACCEPT_PAYLOAD_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadDeconstructorAcceptPayloadProof.gd'
PAYLOAD_DECONSTRUCTOR_ACCEPT_PAYLOAD_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadDeconstructorAcceptPayloadProof.tscn'


class C07PayloadDeconstructorAcceptPayloadTests(unittest.TestCase):
    def test_c07_payload_deconstructor_accept_payload_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2297']['godot_owner'], 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_accept_payload_state')
        # The payload-deconstructor intake (N2291) applies the
        # frame incoming_payload push when the frame payload is
        # null -- the base gate only (acceptPayload returns
        # `this.payload == null`, PayloadBlock.java:117) -- but
        # the Deconstructor's own acceptance gates were never
        # ported: acceptPayload (PayloadDeconstructor.java:
        # 104-106) also requires deconstructing == null, the
        # payload to carry deconstructable requirements, and
        # the payload to fit maxPayloadSize, and
        # acceptUnitPayload (PayloadDeconstructor.java:92-95)
        # gates a dropped unit on its type (allowedInPayloads,
        # not core-spawned), its total requirements, and its
        # hitSize against the same max. N2297 ports both gates
        # as registered pures and wires their verdicts to the
        # frame (accepts_payload / accepts_unit_payload) from
        # the frame offered descriptors. Nine new result
        # symbols: the five acceptPayload results (the verdict
        # plus the four distinct conjuncts -- the redundant
        # super term is the payload_empty term again) plus the
        # four acceptUnitPayload results (the verdict, the
        # combined allowed term, requirements, fits).
        self.assertEqual(
            ledger['N2297']['source_symbols'],
            [
                'source_payload_deconstructor_accept_payload_state_result.accepts',
                'source_payload_deconstructor_accept_payload_state_result.deconstructing_empty',
                'source_payload_deconstructor_accept_payload_state_result.payload_empty',
                'source_payload_deconstructor_accept_payload_state_result.has_requirements',
                'source_payload_deconstructor_accept_payload_state_result.fits',
                'source_payload_deconstructor_accept_unit_payload_state_result.accepts',
                'source_payload_deconstructor_accept_unit_payload_state_result.allowed',
                'source_payload_deconstructor_accept_unit_payload_state_result.has_requirements',
                'source_payload_deconstructor_accept_unit_payload_state_result.fits',
            ],
        )
        for name in ledger['N2297']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], {
                    'source_payload_deconstructor_accept_payload_state_result.accepts': 'core/src/mindustry/world/blocks/payloads/PayloadDeconstructor.java',
                    'source_payload_deconstructor_accept_payload_state_result.deconstructing_empty': 'core/src/mindustry/world/blocks/payloads/PayloadDeconstructor.java',
                    'source_payload_deconstructor_accept_payload_state_result.payload_empty': 'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
                    'source_payload_deconstructor_accept_payload_state_result.has_requirements': 'core/src/mindustry/world/blocks/payloads/PayloadDeconstructor.java',
                    'source_payload_deconstructor_accept_payload_state_result.fits': 'core/src/mindustry/world/blocks/payloads/Payload.java',
                    'source_payload_deconstructor_accept_unit_payload_state_result.accepts': 'core/src/mindustry/world/blocks/payloads/PayloadDeconstructor.java',
                    'source_payload_deconstructor_accept_unit_payload_state_result.allowed': 'core/src/mindustry/world/blocks/payloads/PayloadDeconstructor.java',
                    'source_payload_deconstructor_accept_unit_payload_state_result.has_requirements': 'core/src/mindustry/world/blocks/payloads/PayloadDeconstructor.java',
                    'source_payload_deconstructor_accept_unit_payload_state_result.fits': 'core/src/mindustry/world/blocks/payloads/PayloadDeconstructor.java',
                }[name])
                self.assertEqual(symbol['godot_owner'], {
                    'source_payload_deconstructor_accept_payload_state_result.accepts': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_accept_payload_state',
                    'source_payload_deconstructor_accept_payload_state_result.deconstructing_empty': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_accept_payload_state',
                    'source_payload_deconstructor_accept_payload_state_result.payload_empty': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_accept_payload_state',
                    'source_payload_deconstructor_accept_payload_state_result.has_requirements': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_accept_payload_state',
                    'source_payload_deconstructor_accept_payload_state_result.fits': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_accept_payload_state',
                    'source_payload_deconstructor_accept_unit_payload_state_result.accepts': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_accept_unit_payload_state',
                    'source_payload_deconstructor_accept_unit_payload_state_result.allowed': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_accept_unit_payload_state',
                    'source_payload_deconstructor_accept_unit_payload_state_result.has_requirements': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_accept_unit_payload_state',
                    'source_payload_deconstructor_accept_unit_payload_state_result.fits': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_accept_unit_payload_state',
                }[name])
        self.assertEqual(ledger['N2297']['runtime_proof'], '/root/C07PayloadDeconstructorAcceptPayloadProof')
        self.assertEqual(
            ledger['N2297']['tests'],
            [
                'test_c07_payload_deconstructor_accept_payload_registration',
                'test_all_c07_payload_deconstructor_accept_payload_input_evidence_is_exact',
                'test_payload_deconstructor_accept_payload_state',
                'test_reference_graph_and_actual_c07_payload_deconstructor_accept_payload',
            ],
        )
        self.assertTrue(ledger['N2297']['deferred_exprs'])

    def test_all_c07_payload_deconstructor_accept_payload_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2297']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_payload_deconstructor_accept_payload_state_result.accepts': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_accept_payload_state',
                    'source_payload_deconstructor_accept_payload_state_result.deconstructing_empty': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_accept_payload_state',
                    'source_payload_deconstructor_accept_payload_state_result.payload_empty': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_accept_payload_state',
                    'source_payload_deconstructor_accept_payload_state_result.has_requirements': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_accept_payload_state',
                    'source_payload_deconstructor_accept_payload_state_result.fits': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_accept_payload_state',
                    'source_payload_deconstructor_accept_unit_payload_state_result.accepts': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_accept_unit_payload_state',
                    'source_payload_deconstructor_accept_unit_payload_state_result.allowed': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_accept_unit_payload_state',
                    'source_payload_deconstructor_accept_unit_payload_state_result.has_requirements': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_accept_unit_payload_state',
                    'source_payload_deconstructor_accept_unit_payload_state_result.fits': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_accept_unit_payload_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/payloads/PayloadDeconstructor.java',
            'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
            'core/src/mindustry/world/blocks/payloads/Payload.java',
            'core/src/mindustry/world/blocks/payloads/BuildPayload.java',
            'core/src/mindustry/world/blocks/payloads/UnitPayload.java',
            'core/src/mindustry/type/UnitType.java',
            'core/src/mindustry/entities/comp/UnitComp.java',
            'core/src/mindustry/Vars.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2297']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_deconstructor_accept_payload_state(self):
        payload_deconstructor = PAYLOAD_DECONSTRUCTOR_STATE.read_text(encoding='utf-8')
        # The pure acceptPayload gate ports
        # PayloadDeconstructorBuild.acceptPayload(Building
        # source, Payload payload)
        # (PayloadDeconstructor.java:104-106):
        # `return deconstructing == null && this.payload ==
        # null && super.acceptPayload(source, payload) &&
        # payload.requirements().length > 0 &&
        # payload.fits(maxPayloadSize);`
        # `deconstructing == null` reads the nullable field
        # `public @Nullable Payload deconstructing;`
        # (PayloadDeconstructor.java:52); `this.payload ==
        # null` reads the held payload (`public @Nullable T
        # payload;`, PayloadBlock.java:92);
        # `super.acceptPayload(source, payload)` is the
        # PayloadBlock base gate (PayloadBlock.java:116-118,
        # `return this.payload == null;`) -- the SAME term
        # as the one before it, so it is REDUNDANT here, and
        # the pure ANDs it in again anyway to stay
        # Java-exact. `payload.requirements().length > 0`
        # requires deconstructable requirements (a
        # BuildPayload's are its block requirements,
        # `return build.block.requirements;`,
        # BuildPayload.java:66-68; a UnitPayload's are its
        # unit type total requirements, `return
        # unit.type.getTotalRequirements();`,
        # UnitPayload.java:61-63). `payload.fits(
        # maxPayloadSize)` is the Payload default (`return
        # size() / tilesize <= s;`, Payload.java:50-52): a
        # BuildPayload is block.size tiles (`return
        # build.block.size * tilesize;`,
        # BuildPayload.java:86-88), so it fits when
        # block.size <= maxPayloadSize (4,
        # PayloadDeconstructor.java:18, `public float
        # maxPayloadSize = 4;`).
        self.assertIn('static func source_payload_deconstructor_accept_payload_state', payload_deconstructor)
        self.assertIn('return deconstructing == null && this.payload == null && super.acceptPayload(source, payload) && payload.requirements().length > 0 && payload.fits(maxPayloadSize);', payload_deconstructor)
        self.assertIn('public @Nullable Payload deconstructing;', payload_deconstructor)
        self.assertIn('public @Nullable T payload;', payload_deconstructor)
        self.assertIn('return this.payload == null;', payload_deconstructor)
        self.assertIn('public float maxPayloadSize = 4;', payload_deconstructor)
        self.assertIn('default boolean fits(float s){', payload_deconstructor)
        self.assertIn('return size() / tilesize <= s;', payload_deconstructor)
        self.assertIn('return build.block.size * tilesize;', payload_deconstructor)
        self.assertIn('return build.block.requirements;', payload_deconstructor)
        self.assertIn('return unit.type.getTotalRequirements();', payload_deconstructor)
        self.assertIn('SOURCE_PAYLOAD_DECONSTRUCTOR_MAX_PAYLOAD_SIZE := 4.0', payload_deconstructor)
        # The pure acceptUnitPayload gate ports
        # PayloadDeconstructorBuild.acceptUnitPayload(Unit
        # unit) (PayloadDeconstructor.java:92-95):
        # `return payload == null && deconstructing ==
        # null && unit.type.allowedInPayloads &&
        # !unit.spawnedByCore`
        # `&& unit.type.getTotalRequirements().length > 0
        # && unit.hitSize / tilesize <= maxPayloadSize;`
        # `unit.type.allowedInPayloads` is the unit-type
        # flag (`allowedInPayloads = true,`,
        # UnitType.java:189, "if false, this unit cannot
        # be moved into payloads"); `!unit.spawnedByCore`
        # reads the unit flag (`boolean spawnedByCore;`,
        # UnitComp.java:52);
        # `unit.type.getTotalRequirements().length > 0`
        # requires deconstructable requirements (`public
        # ItemStack[] getTotalRequirements(){`,
        # UnitType.java:1323); `unit.hitSize / tilesize <=
        # maxPayloadSize` is the UnitPayload fits check
        # inlined: a UnitPayload is hitSize pixels
        # (`return unit.hitSize;`, UnitPayload.java:99-101),
        # so it fits when hitSize / 8 <= 4, i.e. hitSize
        # <= 32 (`public static final int tilesize = 8;`,
        # Vars.java:135). The gate is what canControlSelect
        # consults before a player drops a unit on the
        # block (PayloadBlock.java:103-105).
        self.assertIn('static func source_payload_deconstructor_accept_unit_payload_state', payload_deconstructor)
        self.assertIn('return payload == null && deconstructing == null && unit.type.allowedInPayloads && !unit.spawnedByCore', payload_deconstructor)
        self.assertIn('&& unit.type.getTotalRequirements().length > 0 && unit.hitSize / tilesize <= maxPayloadSize;', payload_deconstructor)
        self.assertIn('allowedInPayloads = true,', payload_deconstructor)
        self.assertIn('boolean spawnedByCore;', payload_deconstructor)
        self.assertIn('public ItemStack[] getTotalRequirements(){', payload_deconstructor)
        self.assertIn('return unit.hitSize;', payload_deconstructor)
        self.assertIn('public static final int tilesize = 8;', payload_deconstructor)
        self.assertIn('canControlSelect', payload_deconstructor)
        # The driver wires both verdicts onto the frame
        # from the frame offered descriptors (default null
        # -- no live source offers them yet, so a live
        # deconstructor with no offer reads both verdicts
        # false) plus the frame payload / deconstructing
        # null-ness. The N2291 intake guard stays the
        # frame null check only -- it does not consult
        # these verdicts yet (wiring the intake through
        # the full gate waits for its own slice).
        self.assertIn('frame["accepts_payload"]', payload_deconstructor)
        self.assertIn('frame["accepts_unit_payload"]', payload_deconstructor)
        self.assertIn('frame["offered_payload"]', payload_deconstructor)
        self.assertIn('frame["offered_unit"]', payload_deconstructor)
        self.assertIn('source_payload_deconstructor_accept_payload_state(offered_payload, has_payload, has_deconstructing)', payload_deconstructor)
        self.assertIn('source_payload_deconstructor_accept_unit_payload_state(offered_unit, has_payload, has_deconstructing)', payload_deconstructor)
        # The documented limits now record the acceptance
        # gates as live; the N2291 live fill, the N2233
        # advance and the N2210 gate text stays.
        self.assertIn('Acceptance gates live (N2297)', payload_deconstructor)
        self.assertIn('Live deconstructing fill live (N2291)', payload_deconstructor)
        self.assertIn('updateTile advance (N2233)', payload_deconstructor)
        self.assertIn('shouldConsume gate live (N2210)', payload_deconstructor)
        # The proof's keys drive the pure acceptPayload
        # (accept when empty with requirements, reject
        # when deconstructing busy, reject an
        # empty-requirements payload) and the pure
        # acceptUnitPayload (accept when allowed, reject a
        # core-spawned unit, reject an oversize unit), plus
        # the live tick wiring both verdicts from the
        # offered descriptors. Static checks: the proof
        # preloads the family state file that exists, and
        # the scene file references the proof script that
        # exists.
        proof = PAYLOAD_DECONSTRUCTOR_ACCEPT_PAYLOAD_PROOF.read_text(encoding='utf-8')
        for key in [
            'accepts_payload_when_empty_with_requirements',
            'rejects_payload_when_deconstructing_busy',
            'rejects_empty_requirements_payload',
            'accepts_unit_when_allowed',
            'rejects_core_spawned_unit',
            'rejects_oversize_unit',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourcePayloadDeconstructorBuildState.gd")', proof)
        self.assertIn('payload_deconstructor_build_state.source_payload_deconstructor_accept_payload_state(', proof)
        self.assertIn('payload_deconstructor_build_state.source_payload_deconstructor_accept_unit_payload_state(', proof)
        self.assertTrue(PAYLOAD_DECONSTRUCTOR_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = PAYLOAD_DECONSTRUCTOR_ACCEPT_PAYLOAD_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07PayloadDeconstructorAcceptPayloadProof.gd', scene)
        self.assertIn('C07PayloadDeconstructorAcceptPayloadProof', scene)

    def test_reference_graph_and_actual_c07_payload_deconstructor_accept_payload(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadDeconstructorAcceptPayloadProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_DECONSTRUCTOR_ACCEPT_PAYLOAD_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'accepts_payload_when_empty_with_requirements',
            'rejects_payload_when_deconstructing_busy',
            'rejects_empty_requirements_payload',
            'accepts_unit_when_allowed',
            'rejects_core_spawned_unit',
            'rejects_oversize_unit',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
