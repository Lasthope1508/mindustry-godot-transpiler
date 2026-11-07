from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/entities/comp/BuildingComp.java"
PROOF = "/root/Main.BuildingHeatStateModuleProof"
TESTS = ["test_building_heat_slice.py", "test_emitter.py", "test_source_parity.py"]


def symbol(name: str, owner: str, method: str, expression: str, rule: str) -> tuple[str, dict]:
    return name, {
        "status": "source-backed",
        "godot_owner": owner,
        "godot_symbol": f"source_building_heat_result.{name.rsplit('.', 1)[-1]}",
        "rule": rule,
        "tests": TESTS,
        "runtime_proof": PROOF,
        "java_source": SOURCE,
        "java_method": method,
        "java_expr": expression,
    }


def main() -> None:
    definitions = [
        ("N1921", "PortGame.source_building_calculate_heat_default_state", "calculateHeat(float[])", [
            "public float calculateHeat(float[] sideHeat){",
            "return calculateHeat(sideHeat, null);",
        ], "building_calculate_heat_default"),
        ("N1922", "PortGame.source_building_calculate_heat_state", "calculateHeat(float[], IntSet)", [
            "public float calculateHeat(float[] sideHeat, @Nullable IntSet cameFrom){",
            "Arrays.fill(sideHeat, 0f);",
            "if(cameFrom != null) cameFrom.clear();",
            "boolean split = build.block instanceof HeatConductor cond && cond.splitHeat;",
            "if(!(build instanceof HeatConductorBuild hc && hc.cameFrom.contains(id()))){",
            "int contactPoints = Math.min",
            "add /= 3f;",
            "sideHeat[Mathf.mod(relativeTo(build), 4)] += add;",
            "cameFrom.addAll(hc.cameFrom);",
            "cond.updateHeat();",
        ], "building_calculate_heat"),
    ]
    all_symbols: dict[str, dict] = {}
    for slice_id, owner, method, expressions, prefix in definitions:
        entries = [symbol(f"{prefix}.method", owner, method, expressions[0], "Canonical BuildingComp heat overload preserves source traversal and heat distribution semantics.")]
        entries.extend(
            symbol(f"{prefix}.expr_{index}", owner, method, expression, "Canonical BuildingComp heat overload preserves source traversal and heat distribution semantics.")
            for index, expression in enumerate(expressions[1:], start=1)
        )
        source_symbols.upsert_source_slice(GODOT, slice_id, {
            "status": "done",
            "java_source": SOURCE,
            "java_class": "mindustry.entities.comp.BuildingComp",
            "java_method": method,
            "godot_owner": owner,
            "exact_exprs": expressions,
            "source_symbols": [name for name, _entry in entries],
            "tests": TESTS,
            "runtime_proof": PROOF,
            "rule": "Source-backed heat overload and traversal contract.",
        })
        all_symbols.update(dict(entries))

    owner = "PortGame.source_building_calculate_heat_state"
    source_symbols.upsert_source_api_contract(GODOT, owner, {
        "status": "active",
        "source_slice": "N1922",
        "java_source": SOURCE,
        "source_method": "BuildingComp.calculateHeat(float[], IntSet)",
        "params": [
            {"name": "side_heat", "type": "Array", "schema": "source_building_heat_input.side_heat"},
            {"name": "came_from", "type": "Array", "schema": "source_building_heat_input.came_from"},
            {"name": "proximity", "type": "Array", "schema": "source_building_heat_input.proximity"},
        ],
        "return_keys": ["source_owner", "side_heat", "came_from", "heat", "contact_traces", "update_heat_calls"],
        "tests": TESTS,
        "runtime_proof": PROOF,
        "rule": "One canonical BuildingComp heat owner serves both generated overloads and keeps Java traversal dependencies explicit.",
    })
    source_symbols.upsert_source_api_contract(GODOT, "PortGame.source_building_calculate_heat_default_state", {
        "status": "active",
        "source_slice": "N1921",
        "java_source": SOURCE,
        "source_method": "BuildingComp.calculateHeat(float[])",
        "params": [
            {"name": "side_heat", "type": "Array", "schema": "source_building_heat_input.side_heat"},
            {"name": "proximity", "type": "Array", "schema": "source_building_heat_input.proximity"},
        ],
        "return_keys": ["source_owner", "side_heat", "heat"],
        "tests": TESTS,
        "runtime_proof": PROOF,
        "rule": "The one-argument Java overload delegates to the canonical nullable-cameFrom overload.",
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_building_heat_input", {
        "status": "active", "owner": "PortGame.source_building_calculate_heat_state", "runtime_proof": PROOF,
        "keys": {
            "side_heat": {"type": "Array", "status": "explicit-input", "java_source": SOURCE, "java_expr": "Arrays.fill(sideHeat, 0f);", "rule": "Mutable side heat array supplied by the caller."},
            "came_from": {"type": "Array", "status": "explicit-input", "java_source": SOURCE, "java_expr": "cameFrom.clear();", "rule": "Mutable traversal set supplied by the caller."},
            "proximity": {"type": "Array", "status": "explicit-input", "java_source": SOURCE, "java_expr": "for(var build : proximity){", "rule": "Explicit nearby building traversal input."},
        },
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_building_heat_result", {
        "status": "active", "owner": "PortGame.source_building_calculate_heat_state", "runtime_proof": PROOF,
        "keys": {
            "source_owner": {"type": "String", "status": "source-backed", "java_source": SOURCE, "java_expr": "return heat;", "rule": "Canonical runtime owner marker."},
            "source": {"type": "String", "status": "source-backed", "java_source": SOURCE, "java_expr": "public float calculateHeat(float[] sideHeat, @Nullable IntSet cameFrom){", "rule": "Canonical upstream source marker."},
            "method": {"type": "String", "status": "source-backed", "java_source": SOURCE, "java_expr": "public float calculateHeat(float[] sideHeat, @Nullable IntSet cameFrom){", "rule": "Canonical overload method marker."},
            "side_heat": {"type": "Array", "status": "source-backed", "java_source": SOURCE, "java_expr": "sideHeat[Mathf.mod(relativeTo(build), 4)] += add;", "rule": "Heat accumulated per side."},
            "came_from": {"type": "Array", "status": "source-backed", "java_source": SOURCE, "java_expr": "cameFrom.add(build.id);", "rule": "Traversal identifiers accumulated without duplicate IntSet entries."},
            "heat": {"type": "float", "status": "source-backed", "java_source": SOURCE, "java_expr": "heat += add;", "rule": "Total transferred heat."},
            "contact_traces": {"type": "Array", "status": "generated", "java_expr": "source-backed trace of each accepted proximity build", "rule": "Proof-visible traversal trace."},
            "update_heat_calls": {"type": "Array", "status": "source-backed", "java_source": SOURCE, "java_expr": "cond.updateHeat();", "rule": "Heat conductor update calls recorded for proof."},
        },
    })
    shared_keys = {
        "source_owner": "source_building_heat_result.source_owner",
        "source": "source_building_heat_result.source",
        "method": "source_building_heat_result.method",
        "side_heat": "source_building_heat_result.side_heat",
        "came_from": "source_building_heat_result.came_from",
        "heat": "source_building_heat_result.heat",
        "contact_traces": "source_building_heat_result.contact_traces",
        "update_heat_calls": "source_building_heat_result.update_heat_calls",
    }
    for schema_name, owner in (
        ("source_building_calculate_heat_default_result", "PortGame.source_building_calculate_heat_default_state"),
        ("source_building_calculate_heat_result", "PortGame.source_building_calculate_heat_state"),
    ):
        source_symbols.upsert_source_state_schema(GODOT, schema_name, {
            "status": "active",
            "owner": owner,
            "runtime_proof": PROOF,
            "keys": {
                key: {"type": "Variant", "status": "generated", "alias_of": alias}
                for key, alias in shared_keys.items()
            },
        })
    source_symbols.upsert_source_symbols(GODOT, all_symbols)
    for name in ("comp_slices", "comp_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
