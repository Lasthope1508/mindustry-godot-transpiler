from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/type/UnitType.java"


def key(type_name: str, method: str, expression: str, rule: str, owner: str) -> dict:
    return {
        "type": type_name,
        "status": "source-backed",
        "java_source": SOURCE,
        "java_method": method,
        "java_expr": expression,
        "rule": rule,
        "used_by": [owner.lower()],
    }


def add_query(catalog: dict, name: str, method_name: str, generated_method: str, generated_owner: str) -> None:
    owner = f"PortGame.source_unit_type_{name}_state"
    method = f"UnitType.{method_name}"
    entry = catalog["schemas"][f"source_unit_type_{name}_result"]
    entry["keys"].update({
        "source_owner": key("String", method, f"public boolean {method_name.split('(')[0].split('.')[-1]}(", "Canonical runtime owner marker.", owner),
        "source": key("String", method, SOURCE, "Upstream source identity.", owner),
        "method": key("String", method, method, "Canonical upstream method identity.", owner),
        "generated_owner": key("String", method, generated_owner, "Generated bridge owner identity recorded by source text.", owner),
        "generated_method": key("String", method, generated_method, "Generated bridge method identity recorded by source text.", owner),
    })


def main() -> None:
    catalog = source_symbols.load_source_state_schema(GODOT)
    add_query(catalog, "targetable", "targetable(Unit,Team)", "java_method_targetable_11", "UnitType.java_method_targetable_11")
    add_query(catalog, "hittable", "hittable(Unit)", "java_method_hittable_13", "UnitType.java_method_hittable_13")
    add_query(catalog, "killable", "killable(Unit)", "java_method_killable_12", "UnitType.java_method_killable_12")
    errors = source_symbols.validate_source_state_schema(catalog)
    if errors:
        raise ValueError("invalid source state schema: " + "; ".join(errors))
    source_ssot.write_json(GODOT, "state_schema", catalog)
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
