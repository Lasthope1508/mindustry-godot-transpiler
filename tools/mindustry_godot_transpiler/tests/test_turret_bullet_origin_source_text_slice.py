from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


def test_turret_bullet_origin_literals_have_one_canonical_source_text_owner():
    source_text = (PROJECT / "src" / "game" / "SourceTurretSourceTextState.gd").read_text(encoding="utf-8")
    module = (PROJECT / "src" / "game" / "SourceTurretBulletOriginState.gd").read_text(encoding="utf-8")
    expected = {
        "SOURCE_TURRET_BULLET_ORIGIN_X_SPREAD": "xSpread = Mathf.range(xRand)",
        "SOURCE_TURRET_BULLET_ORIGIN_BULLET_X": "bulletX = x + Angles.trnsx(rotation - 90, shootX + xOffset + xSpread, shootY + yOffset)",
        "SOURCE_TURRET_BULLET_ORIGIN_BULLET_Y": "bulletY = y + Angles.trnsy(rotation - 90, shootX + xOffset + xSpread, shootY + yOffset)",
    }
    assert "class_name SourceTurretSourceTextState" in source_text
    assert 'const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")' in module
    for name, literal in expected.items():
        assert f'const {name} := "{literal}"' in source_text
        assert f"const {name} := source_turret_source_text_state.{name}" in module
        assert f'const {name} := "{literal}"' not in module
