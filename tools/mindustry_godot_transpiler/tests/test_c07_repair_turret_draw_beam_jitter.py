import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTurretBuildState.gd'
REPAIR_TURRET_DRAW_BEAM_JITTER_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTurretDrawBeamJitterProof.gd'


class C07RepairTurretDrawBeamJitterTests(unittest.TestCase):
    def test_c07_repair_turret_draw_beam_jitter_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2289']['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_draw_beam_jitter_state')
        # N2219 captured the deterministic beam state but left the
        # endpoint PRE-JITTER: the random jitter
        # (`lastEnd.add(offset.trns(` with
        # `rand.random(360f) + Time.time/2f,` and
        # `Mathf.sin(Time.time + rand.random(200f), 55f,
        # rand.random(target.hitSize() * 0.2f, target.hitSize() *
        # 0.45f))`, RepairTurret.java:121-124) needs arc Rand
        # modeling (rand.setSeed(id + target id),
        # RepairTurret.java:111) plus Time.time. arc Rand is
        # xorshift128+ (Rand.java, two long words seed0/seed1,
        # murmurHash3 seeding), deterministic per call via
        # setSeed; Time.time is the tick counter (Time.java:15,
        # 60fps units). The GDScript int64 xorshift was verified
        # live in Godot BEFORE this slice was built (throwaway
        # probe, deleted after the run): seed-10 draws
        # r1=257.980828 / r2=38.301969 / r3=3.008420 / r4=0.350668
        # and randomSeed-float-max(123, 360) = 348.595226,
        # matching the Python oracle vectors (5/5 pass). The
        # existing SourceMathState._source_arc_rand_* helpers are
        # NOT reused: they are a murmur hash-chain, not xorshift
        # -- they give 34.82 where the oracle says 348.5952.
        # Six new result symbols: rand_angle_draw,
        # rand_time_draw, rand_hit_draw, jitter_angle_deg,
        # jitter_amplitude, jitter_offset.
        self.assertEqual(
            ledger['N2289']['source_symbols'],
            [
                'source_repair_turret_draw_beam_jitter_state_result.rand_angle_draw',
                'source_repair_turret_draw_beam_jitter_state_result.rand_time_draw',
                'source_repair_turret_draw_beam_jitter_state_result.rand_hit_draw',
                'source_repair_turret_draw_beam_jitter_state_result.jitter_angle_deg',
                'source_repair_turret_draw_beam_jitter_state_result.jitter_amplitude',
                'source_repair_turret_draw_beam_jitter_state_result.jitter_offset',
            ],
        )
        for name in ledger['N2289']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/units/RepairTurret.java',
                    'arc-core/src/arc/math/Rand.java',
                    'arc-core/src/arc/math/Mathf.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2289']['runtime_proof'], '/root/C07RepairTurretDrawBeamJitterProof')
        self.assertEqual(
            ledger['N2289']['tests'],
            [
                'test_c07_repair_turret_draw_beam_jitter_registration',
                'test_all_c07_repair_turret_draw_beam_jitter_input_evidence_is_exact',
                'test_repair_turret_draw_beam_jitter_state',
                'test_reference_graph_and_actual_c07_repair_turret_draw_beam_jitter',
            ],
        )
        self.assertTrue(ledger['N2289']['deferred_exprs'])

    def test_all_c07_repair_turret_draw_beam_jitter_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2289']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                source = symbol['java_source']
                upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / source).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTurret.java',
            'arc-core/src/arc/math/Rand.java',
            'arc-core/src/arc/math/Mathf.java',
            'arc-core/src/arc/math/geom/Vec2.java',
            'arc-core/src/arc/util/Time.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
        for expr in ledger['N2289']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_turret_draw_beam_jitter_state(self):
        repair_turret = REPAIR_TURRET_STATE.read_text(encoding='utf-8')
        # The jitter is the three Rand draws seeded by id +
        # target id (RepairTurret.java:111, `rand.setSeed(id +
        # (target instanceof Entityc e ? e.id() : 0));`), guarded
        # by the target (`if(target != null){`,
        # RepairTurret.java:113): the first draw is the angle
        # (`rand.random(360f) + Time.time/2f,`,
        # RepairTurret.java:122), the second and third feed the
        # table-sin amplitude (`Mathf.sin(Time.time +
        # rand.random(200f), 55f, rand.random(target.hitSize() *
        # 0.2f, target.hitSize() * 0.45f))`,
        # RepairTurret.java:123), and the offset is trns(angle,
        # amplitude) rotated by the target rotation
        # (`).rotate(target instanceof Rotc rot ? rot.rotation() :
        # 0f));`, RepairTurret.java:124). arc Rand is xorshift128+
        # (Rand.java: `public long nextLong(){` / `s1 ^= s1 <<
        # 23;` / `return (this.seed1 = (s1 ^ s0 ^ (s1 >>> 17) ^
        # (s0 >>> 26))) + s0;`, seeded through murmurHash3,
        # `long seed0 = murmurHash3(seed == 0 ? Long.MIN_VALUE :
        # seed);`); nextFloat is `(nextLong() >>> 40) *
        # NORM_FLOAT` (`public float nextFloat(){` /
        # `return (float)((nextLong() >>> 40) * NORM_FLOAT);`).
        # GDScript >> is arithmetic while Java >>> is logical,
        # so the logical shifts are emulated by masking. The
        # pulse phase (`float f = (Time.time / 85f +
        # rand.random(1f)) % 1f;`, RepairTurret.java:138) is a
        # separate later slice (N2252): it is the FOURTH draw
        # from the SAME seeded sequence. There is NO driver tick
        # line: the frame carries no building id, target id,
        # target rotation or absolute tick, so the jitter cannot
        # be stamped live yet -- the N2219 draw_beam_state still
        # returns the pre-jitter beam_end.
        self.assertIn('static func source_arc_rand_xorshift_murmur_hash3(value: int) -> int:', repair_turret)
        self.assertIn('static func source_arc_rand_xorshift_set_seed(seed_value: int) -> Dictionary:', repair_turret)
        self.assertIn('static func source_arc_rand_xorshift_next_long(rand_state: Dictionary) -> int:', repair_turret)
        self.assertIn('static func source_arc_rand_xorshift_next_float(rand_state: Dictionary) -> float:', repair_turret)
        self.assertIn('static func source_arc_rand_xorshift_random_max(rand_state: Dictionary, max_value: float) -> float:', repair_turret)
        self.assertIn('static func source_arc_rand_xorshift_random_range(rand_state: Dictionary, min_value: float, max_value: float) -> float:', repair_turret)
        self.assertIn('static func source_repair_turret_draw_beam_jitter_state(building_id: int, target_id: int, time_ticks: float, target_hit_size: float, target_rotation_deg: float) -> Dictionary:', repair_turret)
        self.assertIn('var rand_state: Dictionary = source_arc_rand_xorshift_set_seed(building_id + target_id)', repair_turret)
        self.assertIn('var rand_angle_draw: float = source_arc_rand_xorshift_random_max(rand_state, 360.0)', repair_turret)
        self.assertIn('var rand_time_draw: float = source_arc_rand_xorshift_random_max(rand_state, 200.0)', repair_turret)
        self.assertIn('var rand_hit_draw: float = source_arc_rand_xorshift_random_range(rand_state, target_hit_size * 0.2, target_hit_size * 0.45)', repair_turret)
        self.assertIn('var jitter_angle_deg: float = rand_angle_draw + time_ticks / 2.0', repair_turret)
        self.assertIn('var jitter_amplitude: float = SourceMathState.source_arc_mathf_sin_scaled(time_ticks + rand_time_draw, 55.0, rand_hit_draw)', repair_turret)
        self.assertIn('var jitter_offset: Vector2 = Vector2(jitter_amplitude, 0.0).rotated(deg_to_rad(jitter_angle_deg)).rotated(deg_to_rad(target_rotation_deg))', repair_turret)
        self.assertIn('return {"rand_angle_draw": rand_angle_draw, "rand_time_draw": rand_time_draw, "rand_hit_draw": rand_hit_draw, "jitter_angle_deg": jitter_angle_deg, "jitter_amplitude": jitter_amplitude, "jitter_offset": jitter_offset}', repair_turret)
        for expr in [
            'rand.setSeed(id + (target instanceof Entityc e ? e.id() : 0));',
            'lastEnd.add(offset.trns(',
            'rand.random(360f) + Time.time/2f,',
            'Mathf.sin(Time.time + rand.random(200f), 55f, rand.random(target.hitSize() * 0.2f, target.hitSize() * 0.45f))',
            ').rotate(target instanceof Rotc rot ? rot.rotation() : 0f));',
            's1 ^= s1 << 23;',
            'return (this.seed1 = (s1 ^ s0 ^ (s1 >>> 17) ^ (s0 >>> 26))) + s0;',
            'long seed0 = murmurHash3(seed == 0 ? Long.MIN_VALUE : seed);',
            'return (float)((nextLong() >>> 40) * NORM_FLOAT);',
            'public static float sin(float radians, float scl, float mag){',
            'return sin(radians / scl) * mag;',
            'public Vec2 trns(float angle, float amount){',
            'return set(amount, 0).rotate(angle);',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, repair_turret)
        # The proof's keys drive the pure function with explicit
        # params (no live tick: the jitter state is pure Rand +
        # Time.time from explicit inputs): the seed-10 oracle
        # draws / the seed-10 jitter offset at time 0 / the
        # offset rotating with the target rotation / the offset
        # changing with time / the angle being the draw plus
        # half the time / the amplitude from the table sin / the
        # same seed giving the same offset / a different seed
        # giving a different offset. There is no live-tick key:
        # there is no driver line yet, the frame carries no
        # building id, target id, target rotation or absolute
        # tick. There is no pulse key: the pulse phase waits for
        # N2252.
        proof = REPAIR_TURRET_DRAW_BEAM_JITTER_PROOF.read_text(encoding='utf-8')
        for key in [
            'rand_draws_match_seed_10_oracle',
            'jitter_offset_seed_10_time_0',
            'jitter_offset_rotates_with_target_rotation',
            'jitter_offset_changes_with_time',
            'jitter_angle_is_rand_draw_plus_half_time',
            'jitter_amplitude_uses_table_sin',
            'jitter_is_deterministic_same_seed',
            'jitter_differs_across_seeds',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_repair_turret_draw_beam_jitter(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTurretDrawBeamJitterProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TURRET_DRAW_BEAM_JITTER_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'rand_draws_match_seed_10_oracle',
            'jitter_offset_seed_10_time_0',
            'jitter_offset_rotates_with_target_rotation',
            'jitter_offset_changes_with_time',
            'jitter_angle_is_rand_draw_plus_half_time',
            'jitter_amplitude_uses_table_sin',
            'jitter_is_deterministic_same_seed',
            'jitter_differs_across_seeds',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
