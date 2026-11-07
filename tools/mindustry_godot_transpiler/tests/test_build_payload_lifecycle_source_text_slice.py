from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
GAME = ROOT / "godot-mindustry" / "src" / "game"


LIFECYCLE_CONSTANTS = {
    "SOURCE_BUILD_PAYLOAD_PLACE_DEFAULT_METHOD": "public void place(Tile tile){",
    "SOURCE_BUILD_PAYLOAD_PLACE_DEFAULT_DELEGATE_EXPR": "place(tile, 0);",
    "SOURCE_BUILD_PAYLOAD_PLACE_METHOD": "public void place(Tile tile, int rotation){",
    "SOURCE_BUILD_PAYLOAD_PLACE_SET_BLOCK_EXPR": "tile.setBlock(build.block, build.team, rotation, () -> build);",
    "SOURCE_BUILD_PAYLOAD_PLACE_BUILD_SUPPLIER_EXPR": "() -> build",
    "SOURCE_BUILD_PAYLOAD_PLACE_DROPPED_EXPR": "build.dropped();",
    "SOURCE_BUILD_PAYLOAD_UPDATE_METHOD": "public void update(@Nullable Unit unitHolder, @Nullable Building buildingHolder){",
    "SOURCE_BUILD_PAYLOAD_UPDATE_GUARD_EXPR": "if(unitHolder != null && (!build.block.updateInUnits || (!state.rules.unitPayloadUpdate && !build.block.alwaysUpdateInUnits))) return;",
    "SOURCE_BUILD_PAYLOAD_UPDATE_PAYLOAD_EXPR": "build.updatePayload(unitHolder, buildingHolder);",
    "SOURCE_BUILD_PAYLOAD_DESTROYED_METHOD": "public void destroyed(){",
    "SOURCE_BUILD_PAYLOAD_DESTROYED_DEAD_ASSIGN_EXPR": "build.dead = true;",
    "SOURCE_BUILD_PAYLOAD_DESTROYED_ON_DESTROYED_EXPR": "build.onDestroyed();",
    "SOURCE_BUILD_PAYLOAD_REMOVE_METHOD": "public void remove(){",
    "SOURCE_BUILD_PAYLOAD_REMOVE_EXPR": "build.remove();",
}


def test_build_payload_lifecycle_literals_have_one_source_text_owner():
    owner = (GAME / "SourceBuildPayloadSourceTextState.gd").read_text(encoding="utf-8")
    module = (GAME / "SourceBuildPayloadLifecycleState.gd").read_text(encoding="utf-8")

    assert "class_name SourceBuildPayloadSourceTextState" in owner
    assert 'const source_build_payload_source_text_state := preload("res://src/game/SourceBuildPayloadSourceTextState.gd")' in module
    for name, literal in LIFECYCLE_CONSTANTS.items():
        assert f'const {name} := "{literal}"' in owner
        assert f"const {name} := source_build_payload_source_text_state.{name}" in module
        assert f'const {name} := "{literal}"' not in module
