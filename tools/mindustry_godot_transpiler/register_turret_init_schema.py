from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
OWNER = "PortGame.source_turret_init_state"
PROOF = "/root/Main.source_turret_init_state"


def input_alias(type_name: str, name: str, schema_name: str | None = None) -> dict:
    return {
        "type": type_name,
        "status": "explicit-input",
        "alias_of": f"source_turret_init_input.{schema_name or name}",
        "used_by": [OWNER.lower()],
    }


def main() -> None:
    keys = {
        "shoot_y": input_alias("float", "shoot_y"),
        "shoot_y_is_negative_infinity": input_alias("bool", "shoot_y_is_negative_infinity"),
        "size": input_alias("float", "size"),
        "source_tilesize": input_alias("float", "source_tilesize"),
        "elevation": input_alias("float", "elevation"),
        "recoil_time": input_alias("float", "recoil_time"),
        "reload": input_alias("float", "reload"),
        "cooldown_time": input_alias("float", "cooldown_time"),
        "new_target_interval": input_alias("float", "new_target_interval"),
        "target_interval": input_alias("float", "target_interval"),
        "target_ground": input_alias("bool", "target_ground"),
        "disable_overlap_check": input_alias("bool", "disable_overlap_check"),
        "range": input_alias("float", "range_value", "range"),
        "tracking_range": input_alias("float", "tracking_range"),
    }
    source_symbols.upsert_source_state_schema(GODOT, "source_turret_init_result", {"status": "active", "owner": OWNER, "runtime_proof": PROOF, "source_slice": "N1156", "rule": "Dictionary returned by the source-backed Turret.init default assignment state.", "keys": {**source_symbols.load_source_state_schema(GODOT)["schemas"]["source_turret_init_result"]["keys"], **keys}})
    for name in ("defense_slices", "defense_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
