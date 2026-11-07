from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
GAME = ROOT / "godot-mindustry" / "src" / "game"


DISPLAY_CONSTANTS = {
    "SOURCE_OVERDRIVE_PROJECTOR_RANGE_METHOD": '"public float range(){\\n            return range;\\n        }"',
    "SOURCE_OVERDRIVE_PROJECTOR_SELECT_METHOD": '"public void drawSelect(){\\n            float realRange = range + phaseHeat * phaseRangeBoost;',
    "SOURCE_OVERDRIVE_PROJECTOR_PLACE_METHOD": '"public void drawPlace(int x, int y, int rotation, boolean valid){\\n        super.drawPlace(x, y, rotation, valid);',
    "SOURCE_OVERDRIVE_PROJECTOR_LIGHT_METHOD": '"public void drawLight(){"',
    "SOURCE_OVERDRIVE_PROJECTOR_LIGHT_CALL": '"Drawf.light(x, y, lightRadius * smoothEfficiency, baseColor, 0.7f * smoothEfficiency);"',
    "SOURCE_OVERDRIVE_PROJECTOR_LIGHT_EMIT_FIELD": '"emitLight = true;"',
    "SOURCE_OVERDRIVE_PROJECTOR_LIGHT_RADIUS_FIELD": '"lightRadius = 50f;"',
    "SOURCE_OVERDRIVE_PROJECTOR_LIGHT_BASE_COLOR_FIELD": '"public Color baseColor = Color.valueOf(\\"feb380\\");"',
    "SOURCE_OVERDRIVE_PROJECTOR_LIGHT_SMOOTH_EFFICIENCY_FIELD": '"public float heat, charge = Mathf.random(reload), phaseHeat, smoothEfficiency, useProgress;"',
    "SOURCE_OVERDRIVE_PROJECTOR_DRAW_METHOD": '"public void draw(){"',
    "SOURCE_OVERDRIVE_PROJECTOR_DRAW_LOD_GUARD": '"if(!Lod.l2) return;"',
    "SOURCE_OVERDRIVE_PROJECTOR_DRAW_LINE_DIMENSIONS": '"float r = Math.max(0f, Mathf.clamp(2f - f * 2f) * size * tilesize / 2f - f - 0.2f), w = Mathf.clamp(0.5f - f) * size * tilesize;"',
}


def test_overdrive_projector_display_literals_have_one_source_text_owner():
    source_text = (GAME / "SourceOverdriveProjectorSourceTextState.gd").read_text(encoding="utf-8")
    display = (GAME / "SourceOverdriveProjectorDisplayState.gd").read_text(encoding="utf-8")

    assert "class_name SourceOverdriveProjectorSourceTextState" in source_text
    assert 'const source_overdrive_projector_source_text_state := preload("res://src/game/SourceOverdriveProjectorSourceTextState.gd")' in display
    for name, literal in DISPLAY_CONSTANTS.items():
        assert f"const {name} := {literal}" in source_text
        assert f"const {name} := source_overdrive_projector_source_text_state.{name}" in display
        assert f"const {name} := {literal}" not in display
