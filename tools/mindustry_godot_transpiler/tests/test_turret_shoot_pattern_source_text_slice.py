from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
GAME = ROOT / "godot-mindustry" / "src" / "game"


SHOOT_PATTERN_CONSTANTS = {
    "SOURCE_SHOOT_ALTERNATE_INDEX_FORMULA": "float index = ((totalShots + i + barrelOffset) % barrels) - (barrels-1)/2f;",
    "SOURCE_SHOOT_ALTERNATE_HANDLER_CALL": "handler.shoot(index * spread * -Mathf.sign(mirror), 0, 0f, firstShotDelay + shotDelay * i);",
    "SOURCE_SHOOT_ALTERNATE_BARREL_INCREMENTER": "if(barrelIncrementer != null) barrelIncrementer.run();",
}


def test_turret_shoot_pattern_literals_have_one_existing_source_text_owner():
    owner = (GAME / "SourceShootPatternSourceTextState.gd").read_text(encoding="utf-8")
    module = (GAME / "SourceTurretShootPatternState.gd").read_text(encoding="utf-8")

    for name, literal in SHOOT_PATTERN_CONSTANTS.items():
        assert f'const {name} := "{literal}"' in owner
        assert f'const {name} := "{literal}"' not in module
        assert f"const {name} := source_shoot_pattern_source_text_state.{name}" in module

