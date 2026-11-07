from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
GAME = ROOT / "godot-mindustry" / "src" / "game"


MEND_CONSTANTS = {
    "SOURCE_MEND_PROJECTOR_REPAIR_HEAL_CALL": '"other.heal(other.maxHealth() * (healPercent + phaseHeat * phaseBoost) / 100f * efficiency);"',
    "SOURCE_MEND_PROJECTOR_REPAIR_FORMULA": '"other.maxHealth() * (healPercent + phaseHeat * phaseBoost) / 100f * efficiency"',
    "SOURCE_MEND_PROJECTOR_REPAIR_MAX_HEALTH": '"other.maxHealth()"',
    "SOURCE_MEND_PROJECTOR_REPAIR_HEAL_PERCENT_FIELD": '"public float healPercent = 12f;"',
    "SOURCE_MEND_PROJECTOR_REPAIR_PHASE_BOOST_FIELD": '"public float phaseBoost = 12f;"',
    "SOURCE_MEND_PROJECTOR_PROGRESS_METHOD": '"public double sense(LAccess sensor){\\n            if(sensor == LAccess.progress) return Mathf.clamp(charge / reload);\\n            return super.sense(sensor);\\n        }"',
    "SOURCE_MEND_PROJECTOR_PROGRESS_SENSOR_GATE": '"if(sensor == LAccess.progress) return Mathf.clamp(charge / reload);"',
    "SOURCE_MEND_PROJECTOR_PROGRESS_CLAMP_EXPR": '"Mathf.clamp(charge / reload)"',
    "SOURCE_MEND_PROJECTOR_PROGRESS_RATIO_EXPR": '"charge / reload"',
    "SOURCE_MEND_PROJECTOR_PROGRESS_SUPER_SENSE": '"return super.sense(sensor);"',
    "SOURCE_MEND_PROJECTOR_RANGE_METHOD": '"public float range(){\\n            return range;\\n        }"',
    "SOURCE_MEND_PROJECTOR_RANGE_RETURN": '"return range;"',
    "SOURCE_MEND_PROJECTOR_RANGE_FIELD": '"public float range = 60f;"',
    "SOURCE_MEND_PROJECTOR_RANGE_PHASE_RANGE_BOOST_FIELD": '"public float phaseRangeBoost = 50f;"',
    "SOURCE_MEND_PROJECTOR_RANGE_REAL_RANGE_EXPR": '"float realRange = range + phaseHeat * phaseRangeBoost;"',
    "SOURCE_MEND_PROJECTOR_LIGHT_METHOD": '"public void drawLight(){\\n            Drawf.light(x, y, lightRadius * smoothEfficiency, baseColor, 0.7f * smoothEfficiency);\\n        }"',
    "SOURCE_MEND_PROJECTOR_LIGHT_CALL": '"Drawf.light(x, y, lightRadius * smoothEfficiency, baseColor, 0.7f * smoothEfficiency);"',
    "SOURCE_MEND_PROJECTOR_LIGHT_RADIUS_EXPR": '"lightRadius * smoothEfficiency"',
    "SOURCE_MEND_PROJECTOR_LIGHT_ALPHA_EXPR": '"0.7f * smoothEfficiency"',
    "SOURCE_MEND_PROJECTOR_SELECT_METHOD": '"public void drawSelect(){\\n            float realRange = range + phaseHeat * phaseRangeBoost;\\n\\n            indexer.eachBlock(this, realRange, other -> true, other -> Drawf.selected(other, Tmp.c1.set(baseColor).a(Mathf.absin(4f, 1f))));\\n\\n            Drawf.dashCircle(x, y, realRange, baseColor);\\n        }"',
    "SOURCE_MEND_PROJECTOR_SELECT_REAL_RANGE": '"float realRange = range + phaseHeat * phaseRangeBoost;"',
    "SOURCE_MEND_PROJECTOR_SELECT_EACH_BLOCK": '"indexer.eachBlock(this, realRange, other -> true, other -> Drawf.selected(other, Tmp.c1.set(baseColor).a(Mathf.absin(4f, 1f))));"',
    "SOURCE_MEND_PROJECTOR_SELECT_SELECTED_CALL": '"Drawf.selected(other, Tmp.c1.set(baseColor).a(Mathf.absin(4f, 1f)))"',
    "SOURCE_MEND_PROJECTOR_SELECT_DASH_CIRCLE": '"Drawf.dashCircle(x, y, realRange, baseColor);"',
    "SOURCE_MEND_PROJECTOR_SELECT_BASE_COLOR_FIELD": '"public Color baseColor = Color.valueOf(\\"84f491\\");"',
    "SOURCE_MEND_PROJECTOR_PLACE_METHOD": '"public void drawPlace(int x, int y, int rotation, boolean valid){\\n        super.drawPlace(x, y, rotation, valid);\\n\\n        Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range, baseColor);\\n\\n        indexer.eachBlock(player.team(), x * tilesize + offset, y * tilesize + offset, range, other -> true, other -> Drawf.selected(other, Tmp.c1.set(baseColor).a(Mathf.absin(4f, 1f))));\\n    }"',
    "SOURCE_MEND_PROJECTOR_PLACE_SUPER": '"super.drawPlace(x, y, rotation, valid);"',
    "SOURCE_MEND_PROJECTOR_PLACE_DASH_CIRCLE": '"Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range, baseColor);"',
    "SOURCE_MEND_PROJECTOR_PLACE_EACH_BLOCK": '"indexer.eachBlock(player.team(), x * tilesize + offset, y * tilesize + offset, range, other -> true, other -> Drawf.selected(other, Tmp.c1.set(baseColor).a(Mathf.absin(4f, 1f))));"',
    "SOURCE_MEND_PROJECTOR_PLACE_SELECTED_CALL": '"Drawf.selected(other, Tmp.c1.set(baseColor).a(Mathf.absin(4f, 1f)))"',
    "SOURCE_MEND_PROJECTOR_DRAW_METHOD": '"public void draw(){\\n            float f = 1f - (Time.time / 100f) % 1f;\\n\\n            if(!Lod.l2) return;\\n\\n            Draw.color(baseColor, phaseColor, phaseHeat);\\n            Draw.alpha(heat * Mathf.absin(Time.time, 50f / Mathf.PI2, 1f) * 0.5f * Lod.alpha2);\\n            Draw.rect(topRegion, x, y);\\n            Draw.alpha(Lod.alpha2);\\n            Lines.stroke((2f * f + 0.2f) * heat);\\n            Lines.square(x, y, Math.min(1f + (1f - f) * size * tilesize / 2f, size * tilesize/2f));\\n\\n            Draw.reset();\\n        }"',
    "SOURCE_MEND_PROJECTOR_DRAW_F_EXPR": '"float f = 1f - (Time.time / 100f) % 1f;"',
    "SOURCE_MEND_PROJECTOR_DRAW_COLOR_BLEND": '"Draw.color(baseColor, phaseColor, phaseHeat);"',
    "SOURCE_MEND_PROJECTOR_DRAW_TOP_ALPHA": '"Draw.alpha(heat * Mathf.absin(Time.time, 50f / Mathf.PI2, 1f) * 0.5f * Lod.alpha2);"',
    "SOURCE_MEND_PROJECTOR_DRAW_SQUARE_RADIUS": '"Lines.square(x, y, Math.min(1f + (1f - f) * size * tilesize / 2f, size * tilesize/2f));"',
}


def test_mend_projector_source_text_has_one_owner():
    source_text = (GAME / "SourceMendProjectorSourceTextState.gd").read_text(encoding="utf-8")
    repair_state = (GAME / "SourceMendProjectorState.gd").read_text(encoding="utf-8")
    display_state = (GAME / "SourceMendProjectorDisplayState.gd").read_text(encoding="utf-8")

    assert "class_name SourceMendProjectorSourceTextState" in source_text
    assert 'const source_mend_projector_source_text_state := preload("res://src/game/SourceMendProjectorSourceTextState.gd")' in repair_state
    assert 'const source_mend_projector_source_text_state := preload("res://src/game/SourceMendProjectorSourceTextState.gd")' in display_state
    for name, literal in MEND_CONSTANTS.items():
        assert f"const {name} := {literal}" in source_text
        assert f"const {name} := source_mend_projector_source_text_state.{name}" in (repair_state if "REPAIR_" in name or "PROGRESS_" in name else display_state)
        assert f"const {name} := {literal}" not in repair_state
        assert f"const {name} := {literal}" not in display_state
