from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
GAME = ROOT / "godot-mindustry" / "src" / "game"


PROXIMITY_CONSTANTS = {
    "SOURCE_BUILDING_UPDATE_PROXIMITY_METHOD": "public void updateProximity(){",
    "SOURCE_BUILDING_UPDATE_PROXIMITY_TMP_CLEAR": "tmpTiles.clear();",
    "SOURCE_BUILDING_UPDATE_PROXIMITY_PROXIMITY_CLEAR": "proximity.clear();",
    "SOURCE_BUILDING_UPDATE_PROXIMITY_EDGES": "Point2[] nearby = Edges.getEdges(block.size);",
    "SOURCE_BUILDING_UPDATE_PROXIMITY_WORLD_BUILD": "Building other = world.build(tile.x + point.x, tile.y + point.y);",
    "SOURCE_BUILDING_UPDATE_PROXIMITY_TEAM_GUARD": "if(other == null || other.team != team) continue;",
    "SOURCE_BUILDING_UPDATE_PROXIMITY_ADD_UNIQUE": "other.proximity.addUnique(self());",
    "SOURCE_BUILDING_UPDATE_PROXIMITY_TMP_ADD": "tmpTiles.add(other);",
    "SOURCE_BUILDING_UPDATE_PROXIMITY_ADD_SELF": "proximity.add(tile);",
    "SOURCE_BUILDING_UPDATE_PROXIMITY_ADDED": "onProximityAdded();",
    "SOURCE_BUILDING_UPDATE_PROXIMITY_UPDATE": "onProximityUpdate();",
    "SOURCE_BUILDING_UPDATE_PROXIMITY_OTHER_UPDATE": "other.onProximityUpdate();",
    "SOURCE_BUILDING_UPDATE_PROXIMITY_RECACHE": "if(!headless && block.drawCached) recache();",
}


def test_building_lifecycle_proximity_literals_have_one_existing_source_text_owner():
    owner = (GAME / "SourceBuildingLifecycleSourceTextState.gd").read_text(encoding="utf-8")
    module = (GAME / "SourceBuildingLifecycleProximityState.gd").read_text(encoding="utf-8")

    assert "class_name SourceBuildingLifecycleSourceTextState" in owner
    assert 'const source_building_lifecycle_source_text_state := preload("res://src/game/SourceBuildingLifecycleSourceTextState.gd")' in module
    for name, literal in PROXIMITY_CONSTANTS.items():
        assert f'const {name} := "{literal}"' in owner
        assert f"const {name} := source_building_lifecycle_source_text_state.{name}" in module
        assert f'const {name} := "{literal}"' not in module
