from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/entities/comp/BuildingComp.java"
OWNER = "PortGame.source_building_draw_configure_state"
PROOF = "/root/Main.source_building_draw_configure_state"
TESTS = ["test_building_draw_configure_generated_delegate.py", "test_emitter.py", "test_playable.py"]
METHOD = "drawConfigure()"
JAVA_EXPR = "public void drawConfigure(){"
GENERATED_OWNER = "BuildingComp.java_method_drawConfigure_171"


def field(type_name: str, expr: str, rule: str) -> dict:
    return {"type": type_name, "status": "generated", "java_source": SOURCE, "java_method": METHOD, "java_expr": expr, "rule": rule}


def main() -> None:
    source_symbols.upsert_source_symbols(GODOT, {
        "building_draw_configure.generated_delegate": {
            "status": "source-backed", "source_slice": "N1959", "godot_owner": OWNER,
            "godot_symbol": "generated_building_comp_draw_configure_bridge_result.result", "java_source": SOURCE,
            "java_method": METHOD, "java_expr": JAVA_EXPR, "tests": TESTS, "runtime_proof": PROOF,
            "rule": "Generated BuildingComp drawConfigure delegates to the existing canonical drawConfigure owner.",
        },
    })
    source_symbols.upsert_source_slice(GODOT, "N1959", {
        "status": "done", "java_source": SOURCE, "java_class": "mindustry.entities.comp.BuildingComp",
        "java_method": METHOD, "godot_owner": OWNER, "generated_owner": GENERATED_OWNER,
        "exact_exprs": [JAVA_EXPR, "Draw.color(Pal.accent);", "Lines.stroke(1f);", "Lines.square(x, y, block.size * tilesize / 2f + 1f);", "Draw.reset();"],
        "source_symbols": ["building_draw_configure.generated_delegate"], "tests": TESTS, "runtime_proof": PROOF,
        "rule": "Generated drawConfigure delegates to the existing canonical draw state without duplicating rendering logic.",
    })
    source_symbols.upsert_source_state_schema(GODOT, "generated_building_comp_draw_configure_bridge_result", {
        "status": "active", "owner": OWNER, "runtime_proof": PROOF,
        "keys": {
            "source_owner": field("String", OWNER, "Canonical owner marker."),
            "generated_owner": field("String", GENERATED_OWNER, "Generated callback identity."),
            "result": field("Dictionary", "source_building_draw_configure_result", "Generated result from canonical draw state."),
            "canonical": field("Dictionary", "source_building_draw_configure_result", "Canonical draw state used for parity comparison."),
            "matches": field("bool", "generated result == canonical result", "Generated and canonical draw states match."),
        },
    })
    for name in ("comp_slices", "comp_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
