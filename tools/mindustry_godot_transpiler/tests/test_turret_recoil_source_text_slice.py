from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
GAME = ROOT / "godot-mindustry" / "src" / "game"


RECOIL_CONSTANTS = {
    "SOURCE_TURRET_RECOIL_TIME_INIT_FALLBACK": "if(recoilTime < 0f) recoilTime = reload;",
    "SOURCE_TURRET_RECOIL_TIME_DECAY_USE": "curRecoil = Mathf.approachDelta(curRecoil, 0, 1 / recoilTime);",
    "SOURCE_TURRET_RECOIL_OFFSET_FORMULA": "recoilOffset.trns(rotation, -Mathf.pow(curRecoil, recoilPow) * recoil);",
}


def test_turret_recoil_literals_have_one_existing_source_text_owner():
    owner = (GAME / "SourceTurretSourceTextState.gd").read_text(encoding="utf-8")
    module = (GAME / "SourceTurretRecoilState.gd").read_text(encoding="utf-8")

    for name, literal in RECOIL_CONSTANTS.items():
        assert f'const {name} := "{literal}"' in owner
        assert f'const {name} := "{literal}"' not in module
        assert f"const {name} := source_turret_source_text_state.{name}" in module

