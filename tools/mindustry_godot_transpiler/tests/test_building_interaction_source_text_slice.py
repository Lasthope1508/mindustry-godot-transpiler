from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
GAME = ROOT / "godot-mindustry" / "src" / "game"


INTERACTION_CONSTANTS = {
    "SOURCE_BUILDING_UNIT_ON_COMMENT": "/** Called every frame a unit is on this. Hovering/flying/steppy units do not apply.  */",
    "SOURCE_BUILDING_UNIT_ON_METHOD": "public void unitOn(Unit unit){",
    "SOURCE_BUILDING_UNIT_ON_EMPTY_BODY": "public void unitOn(Unit unit){\\n    }",
    "SOURCE_BUILDING_UNIT_ON_ANY_COMMENT": "/** Called every frame a unit is on this. Applies to any unit.  */",
    "SOURCE_BUILDING_UNIT_ON_ANY_METHOD": "public void unitOnAny(Unit unit){",
    "SOURCE_BUILDING_UNIT_ON_ANY_EMPTY_BODY": "public void unitOnAny(Unit unit){\\n    }",
    "SOURCE_BUILDING_UNIT_REMOVED_COMMENT": "/** Called when a unit that spawned at this tile is removed. */",
    "SOURCE_BUILDING_UNIT_REMOVED_METHOD": "public void unitRemoved(Unit unit){",
    "SOURCE_BUILDING_UNIT_REMOVED_EMPTY_BODY": "public void unitRemoved(Unit unit){\\n    }",
}


def test_building_interaction_literals_have_one_existing_source_text_owner():
    owner = (GAME / "SourceBuildingSourceTextState.gd").read_text(encoding="utf-8")
    module = (GAME / "SourceBuildingInteractionState.gd").read_text(encoding="utf-8")

    assert "class_name SourceBuildingSourceTextState" in owner
    assert 'const source_building_source_text_state := preload("res://src/game/SourceBuildingSourceTextState.gd")' in module
    for name, literal in INTERACTION_CONSTANTS.items():
        assert f'const {name} := "{literal}"' in owner
        assert f"const {name} := source_building_source_text_state.{name}" in module
        assert f'const {name} := "{literal}"' not in module
