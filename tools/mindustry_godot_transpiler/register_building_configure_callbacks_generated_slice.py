from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/entities/comp/BuildingComp.java"
PROOF = "/root/Main.BuildingConfigureStateModuleProof"
TESTS = ["test_building_configure_callbacks_generated_slice.py", "test_emitter.py", "test_playable.py"]


def field(type_name: str, method: str, expr: str, rule: str) -> dict:
    return {
        "type": type_name,
        "status": "generated",
        "java_source": SOURCE,
        "java_method": method,
        "java_expr": expr,
        "rule": rule,
    }


def main() -> None:
    callbacks = [
        ("on_configure_tapped", "onConfigureTapped(float x, float y)", "BuildingComp.java_method_onConfigureTapped_167", "PortGame.source_building_on_configure_tapped_state", "source_building_on_configure_tapped_result"),
        ("on_configure_closed", "onConfigureClosed()", "BuildingComp.java_method_onConfigureClosed_168", "PortGame.source_building_on_configure_closed_state", "source_building_on_configure_closed_result"),
        ("should_show_configure", "shouldShowConfigure(Player player)", "BuildingComp.java_method_shouldShowConfigure_169", "PortGame.source_building_should_show_configure_state", "source_building_should_show_configure_result"),
        ("should_hide_configure", "shouldHideConfigure(Player player)", "BuildingComp.java_method_shouldHideConfigure_170", "PortGame.source_building_should_hide_configure_state", "source_building_should_hide_configure_result"),
    ]
    symbols = {}
    for name, method, generated_owner, owner, canonical_schema in callbacks:
        symbols[f"building_{name}.generated_delegate"] = {
            "status": "source-backed",
            "source_slice": "N1958",
            "godot_owner": owner,
            "godot_symbol": f"generated_building_comp_{name}_bridge_result.result",
            "java_source": SOURCE,
            "java_method": method,
            "java_expr": f"public {'boolean' if name != 'on_configure_closed' else 'void'} {method.split('(')[0]}({method.split('(', 1)[1]}",
            "tests": TESTS,
            "runtime_proof": PROOF,
            "rule": f"Generated BuildingComp {method} delegates to the existing canonical {owner} state; no duplicate owner is introduced.",
        }
        source_symbols.upsert_source_state_schema(GODOT, f"generated_building_comp_{name}_bridge_result", {
            "status": "active", "owner": owner, "runtime_proof": PROOF,
            "keys": {
                "source_owner": field("String", method, f"{owner}", "Canonical owner marker."),
                "generated_owner": field("String", method, generated_owner, "Generated callback identity."),
                "result": field("Dictionary", method, f"{canonical_schema}", "Generated callback result from the canonical source bridge."),
                "canonical": field("Dictionary", method, f"{canonical_schema}", "Canonical source state used for parity comparison."),
                "matches": field("bool", method, "generated result == canonical result", "Generated and canonical states match."),
            },
        })
    source_symbols.upsert_source_symbols(GODOT, symbols)
    source_symbols.upsert_source_slice(GODOT, "N1958", {
        "status": "done", "java_source": SOURCE,
        "java_class": "mindustry.entities.comp.BuildingComp",
        "java_method": "onConfigureTapped(float x, float y), onConfigureClosed(), shouldShowConfigure(Player player), shouldHideConfigure(Player player)",
        "godot_owner": "PortGame.source_building_on_configure_tapped_state",
        "generated_owner": "BuildingComp.java_method_onConfigureTapped_167 / BuildingComp.java_method_onConfigureClosed_168 / BuildingComp.java_method_shouldShowConfigure_169 / BuildingComp.java_method_shouldHideConfigure_170",
        "exact_exprs": [
            "public boolean onConfigureTapped(float x, float y){",
            "public void onConfigureClosed(){}",
            "public boolean shouldShowConfigure(Player player){",
            "public boolean shouldHideConfigure(Player player){",
        ],
        "source_symbols": [f"building_{name}.generated_delegate" for name, *_ in callbacks],
        "tests": TESTS, "runtime_proof": PROOF,
        "rule": "Generated configure callbacks delegate to the existing canonical BuildingComp configure owners; behavior remains source-backed and centralized.",
    })
    for name in ("comp_slices", "comp_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
