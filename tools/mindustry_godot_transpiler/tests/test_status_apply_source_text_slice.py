import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


class StatusApplySourceTextSliceTests(unittest.TestCase):
    def test_status_apply_literals_have_one_existing_canonical_owner(self):
        defaults = (PROJECT / "src" / "game" / "SourceStatusDefaults.gd").read_text(encoding="utf-8")
        module = (PROJECT / "src" / "game" / "SourceStatusApplyState.gd").read_text(encoding="utf-8")
        expected = {
            "STATUS_APPLY_RESULT_METHOD": "public void apply(StatusEffect effect, float duration){",
            "STATUS_APPLY_RESULT_GUARD": "if(effect == StatusEffects.none || effect == null || isImmune(effect)) return;",
            "STATUS_APPLY_RESULT_WEAPON_SHOOT_STATUS_FIELD": "public StatusEffect shootStatus = StatusEffects.none;",
            "STATUS_APPLY_RESULT_WEAPON_DURATION_FIELD": "public float shootStatusDuration = 60f * 5f;",
            "STATUS_APPLY_RESULT_WEAPON_CALL": "unit.apply(shootStatus, shootStatusDuration);",
        }
        self.assertIn("class_name SourceStatusDefaults", defaults)
        self.assertIn('const source_status_defaults := preload("res://src/game/SourceStatusDefaults.gd")', module)
        for name, literal in expected.items():
            self.assertIn(f'const {name} := "{literal}"', defaults)
            self.assertIn(f"const SOURCE_{name} := source_status_defaults.{name}", module)
            self.assertNotIn(f'const SOURCE_{name} := "{literal}"', module)

    def test_status_apply_runtime_proof_is_canonicalized(self):
        proof = (PROJECT / "tools" / "runtime_proofs" / "StatusApplyModuleProof.gd").read_text(encoding="utf-8")
        scene = PROJECT / "tools" / "runtime_proofs" / "StatusApplyModuleProof.tscn"
        self.assertTrue(scene.exists())
        self.assertIn('const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")', proof)
        self.assertIn('proof["matches"] =', proof)
        self.assertIn('proof["registry_valid"]', proof)
        self.assertIn('proof["one_headquarter_per_ssot"]', proof)
        self.assertIn('runtime_proof_state.write_proof("StatusApplyModuleProof", proof)', proof)
        self.assertIn("get_tree().quit(runtime_proof_state.exit_code(proof))", proof)


if __name__ == "__main__":
    unittest.main()
