from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
GAME = ROOT / "godot-mindustry" / "src" / "game"


ICON_CONSTANTS = {
    "SOURCE_UNIT_ICON_COMMENT": "/** @return a preview UI icon for this unit. */",
    "SOURCE_UNIT_ICON_METHOD": "public TextureRegion icon(){",
    "SOURCE_UNIT_ICON_RETURN": "return type.uiIcon;",
    "SOURCE_UNIT_ICON_UI_ICON_FIELD": "public TextureRegion uiIcon;",
    "SOURCE_UNIT_ICON_UI_ICON_LOAD": 'uiIcon = Core.atlas.find(getContentType().name() + "-" + name + "-ui", fullIcon);',
    "SOURCE_UNIT_ICON_CALL": "icon()",
    "SOURCE_UNIT_ICON_RETURN_VALUE": "type.uiIcon",
}


def test_unit_icon_literals_have_one_existing_unit_source_text_owner():
    owner = (GAME / "SourceUnitUpdateSourceTextState.gd").read_text(encoding="utf-8")
    metadata = (GAME / "SourceUnitMetadataState.gd").read_text(encoding="utf-8")

    for name, literal in ICON_CONSTANTS.items():
        gdscript_literal = literal.replace('\\', '\\\\').replace('"', '\\"')
        assert f'const {name} := "{gdscript_literal}"' in owner
        assert f'const {name} := "{gdscript_literal}"' not in metadata
        assert f"const {name} := source_unit_update_source_text_state.{name}" in metadata
