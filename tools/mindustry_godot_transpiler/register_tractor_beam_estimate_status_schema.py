from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/world/blocks/defense/turrets/TractorBeamTurret.java"


def source_key(type_name: str, expression: str, method: str, rule: str, owner: str) -> dict:
    return {
        "type": type_name,
        "status": "source-backed",
        "java_source": SOURCE,
        "java_method": method,
        "java_expr": expression,
        "rule": rule,
        "used_by": [owner.lower()],
    }


def input_alias(type_name: str, schema_name: str, name: str, owner: str) -> dict:
    return {
        "type": type_name,
        "status": "generated",
        "alias_of": f"{schema_name}.{name}",
        "used_by": [owner.lower()],
    }


def register_estimate_dps(catalog: dict) -> None:
    owner = "PortGame.source_tractor_beam_turret_build_estimate_dps_state"
    method = "TractorBeamBuild.estimateDps()"
    entry = catalog["schemas"]["source_tractor_beam_turret_build_estimate_dps_result"]
    entry["keys"].update({
        "source_owner": source_key("String", "public float estimateDps(){", method, "Canonical runtime owner marker.", owner),
        "inner_class": source_key("String", "public class TractorBeamBuild extends BaseTurretBuild{", method, "Inner build class boundary.", owner),
        "override_expr": source_key("String", "@Override", method, "Override annotation for the upstream method.", owner),
        "zero_guard_expr": source_key("String", "if(!any || damage <= 0) return 0f;", method, "Zero-DPS guard expression.", owner),
        "return_expr": source_key("String", "return damage * 60f * efficiency * coolantMultiplier;", method, "Estimated DPS return expression.", owner),
        "any_state": input_alias("bool", "source_tractor_beam_turret_build_estimate_dps_input", "any_state", owner),
        "damage": input_alias("float", "source_tractor_beam_turret_build_estimate_dps_input", "damage", owner),
        "efficiency": input_alias("float", "source_tractor_beam_turret_build_estimate_dps_input", "efficiency", owner),
        "coolant_multiplier": input_alias("float", "source_tractor_beam_turret_build_estimate_dps_input", "coolant_multiplier", owner),
    })


def register_status_apply(catalog: dict) -> None:
    owner = "PortGame.source_tractor_beam_turret_build_update_tile_status_apply_state"
    method = "TractorBeamBuild.updateTile() status apply"
    entry = catalog["schemas"]["source_tractor_beam_turret_build_update_tile_status_apply_result"]
    entry["keys"].update({
        "status_gate_expr": source_key("String", "if(status != StatusEffects.none){", method, "Status-effect guard expression.", owner),
        "status_apply_expr": source_key("String", "target.apply(status, statusDuration);", method, "Status application expression.", owner),
        "status_field_expr": source_key("String", "status", method, "Status field selected by the upstream build.", owner),
        "status_duration_field_expr": source_key("String", "statusDuration", method, "Status duration field selected by the upstream build.", owner),
        "shoot_within_guard": input_alias("bool", "source_tractor_beam_turret_build_update_tile_status_apply_input", "shoot_within_guard", owner),
        "target_after": input_alias("Variant", "source_tractor_beam_turret_build_update_tile_status_apply_input", "target_after", owner),
        "status": input_alias("Variant", "source_tractor_beam_turret_build_update_tile_status_apply_input", "status", owner),
        "status_duration": input_alias("float", "source_tractor_beam_turret_build_update_tile_status_apply_input", "status_duration", owner),
        "status_gate_evaluated": source_key("bool", "Angles.within(rotation, dest, shootCone)", method, "Status branch is evaluated only after the shoot-within guard.", owner),
    })


def main() -> None:
    catalog = source_symbols.load_source_state_schema(GODOT)
    register_estimate_dps(catalog)
    register_status_apply(catalog)
    for schema_name in (
        "source_tractor_beam_turret_build_estimate_dps_result",
        "source_tractor_beam_turret_build_update_tile_status_apply_result",
    ):
        source_symbols.upsert_source_state_schema(GODOT, schema_name, catalog["schemas"][schema_name])
    for name in ("defense_slices", "defense_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
