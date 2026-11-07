from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
GAME = ROOT / "godot-mindustry" / "src" / "game"


def test_math_source_text_owns_arc_java_literals():
    source_text = (GAME / "SourceMathSourceTextState.gd").read_text(encoding="utf-8")
    state = (GAME / "SourceMathState.gd").read_text(encoding="utf-8")

    expected = (
        'const SOURCE_MATHF_APPROACH_DELTA_METHOD := "public static float approachDelta(float from, float to, float speed){\\n        return approach(from, to, Time.delta * speed);\\n    }"',
        'const SOURCE_MATHF_APPROACH_DELTA_APPROACH_METHOD := "public static float approach(float from, float to, float speed){\\n        return from + Mathf.clamp(to - from, -speed, speed);\\n    }"',
        'const SOURCE_MATHF_DST_METHOD := "public static float dst(float x1, float y1, float x2, float y2){\\n        final float xd = x2 - x1;\\n        final float yd = y2 - y1;\\n        return (float)Math.sqrt(xd * xd + yd * yd);\\n    }"',
        'const SOURCE_ARC_MATHF_NUM_METHOD := "public static int num(boolean b){"',
        'const SOURCE_ANGLES_WITHIN_METHOD := "public static boolean within(float a, float b, float margin){\\n        return angleDist(a, b) <= margin;\\n    }"',
    )
    for literal in expected:
        assert literal in source_text
        assert literal not in state


def test_math_state_aliases_source_text_ssot():
    source_text = (GAME / "SourceMathSourceTextState.gd").read_text(encoding="utf-8")
    state = (GAME / "SourceMathState.gd").read_text(encoding="utf-8")

    assert 'const source_math_source_text_state := preload("res://src/game/SourceMathSourceTextState.gd")' in state
    for name in (
        "SOURCE_MATHF_APPROACH_DELTA_METHOD",
        "SOURCE_MATHF_APPROACH_DELTA_APPROACH_METHOD",
        "SOURCE_MATHF_APPROACH_DELTA_SCALED_SPEED",
        "SOURCE_MATHF_DST_METHOD",
        "SOURCE_MATHF_DST_XD_EXPR",
        "SOURCE_MATHF_DST_YD_EXPR",
        "SOURCE_MATHF_DST_RETURN_EXPR",
        "SOURCE_ARC_MATHF_NUM_METHOD",
        "SOURCE_ANGLES_WITHIN_METHOD",
    ):
        assert f"const {name} := source_math_source_text_state.{name}" in state
    assert "extends RefCounted" in source_text


def test_math_source_text_runtime_proof_is_registered_shape():
    proof = ROOT / "godot-mindustry" / "tools" / "runtime_proofs" / "SourceMathSourceTextModuleProof.gd"
    scene = ROOT / "godot-mindustry" / "tools" / "runtime_proofs" / "SourceMathSourceTextModuleProof.tscn"
    proof_source = proof.read_text(encoding="utf-8")
    scene_source = scene.read_text(encoding="utf-8")
    assert 'const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")' in proof_source
    assert 'runtime_proof_state.write_proof("SourceMathSourceTextModuleProof", proof)' in proof_source
    assert "get_tree().quit(runtime_proof_state.exit_code(proof))" in proof_source
    assert 'path="res://tools/runtime_proofs/SourceMathSourceTextModuleProof.gd"' in scene_source
