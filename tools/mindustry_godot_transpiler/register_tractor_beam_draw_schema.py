from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/world/blocks/defense/turrets/TractorBeamTurret.java"
OWNER = "PortGame.source_tractor_beam_turret_build_draw_state"
PROOF = "/root/Main.source_tractor_beam_turret_build_draw_state"
METHOD = "TractorBeamBuild.draw()"


def source_key(type_name: str, expression: str, rule: str) -> dict:
    return {
        "type": type_name,
        "status": "source-backed",
        "java_source": SOURCE,
        "java_method": METHOD,
        "java_expr": expression,
        "rule": rule,
        "used_by": [OWNER.lower()],
    }


def input_alias(type_name: str, name: str) -> dict:
    return {
        "type": type_name,
        "status": "generated",
        "alias_of": f"source_tractor_beam_turret_build_draw_input.{name}",
        "used_by": [OWNER.lower()],
    }


def main() -> None:
    keys = {
        "source_owner": source_key("String", "public void draw(){", "Canonical runtime owner marker for the draw state."),
        "inner_class": source_key("String", "public class TractorBeamBuild extends BaseTurretBuild{", "Inner build class boundary."),
        "method": source_key("String", "public void draw(){", "Draw method boundary."),
        "override_expr": source_key("String", "@Override", "Override annotation for the upstream draw method."),
        "base_rect_expr": source_key("String", "Draw.rect(baseRegion, x, y);", "Base region draw expression."),
        "shadow_expr": source_key("String", "Drawf.shadow(region, x - (size / 2f), y - (size / 2f), rotation - 90);", "Shadow draw expression."),
        "region_rect_expr": source_key("String", "Draw.rect(region, x, y, rotation - 90);", "Turret region draw expression."),
        "laser_guard_expr": source_key("String", "if(any && !isPayload()){", "Laser visibility guard."),
        "draw_z_expr": source_key("String", "Draw.z(Layer.bullet);", "Laser draw layer expression."),
        "angle_expr": source_key("String", "float ang = angleTo(lastX, lastY);", "Beam angle calculation."),
        "mixcol_expr": source_key("String", "Draw.mixcol(laserColor, Mathf.absin(4f, 0.6f));", "Laser color modulation expression."),
        "laser_expr": source_key("String", "Drawf.laser(laser, laserStart, laserEnd,\n                x + Angles.trnsx(ang, shootLength), y + Angles.trnsy(ang, shootLength),\n                lastX, lastY, strength * efficiency * laserWidth);", "Laser draw expression exactly as laid out in upstream source."),
        "mixcol_reset_expr": source_key("String", "Draw.mixcol();", "Laser color reset expression."),
        "base_region": input_alias("Variant", "base_region"),
        "region": input_alias("Variant", "region"),
        "x": input_alias("float", "x"),
        "y": input_alias("float", "y"),
        "rotation": input_alias("float", "rotation_value"),
        "size": input_alias("float", "size"),
        "any_state": input_alias("bool", "any_state"),
        "is_payload": input_alias("bool", "is_payload"),
        "last_x": input_alias("float", "last_x"),
        "last_y": input_alias("float", "last_y"),
        "laser_color": input_alias("Variant", "laser_color"),
        "mathf_absin_4_0_6": input_alias("float", "mathf_absin_4_0_6"),
        "laser": input_alias("Variant", "laser"),
        "laser_start": input_alias("Variant", "laser_start"),
        "laser_end": input_alias("Variant", "laser_end"),
        "shoot_length": input_alias("float", "shoot_length"),
        "strength": input_alias("float", "strength"),
        "efficiency": input_alias("float", "efficiency"),
        "laser_width": input_alias("float", "laser_width"),
        "draw_rotation": source_key("float", "rotation - 90", "Rotation used by the region draw call."),
        "base_rect_call": source_key("Dictionary", "Draw.rect(baseRegion, x, y);", "Base draw call state."),
        "shadow_call": source_key("Dictionary", "Drawf.shadow(region, x - (size / 2f), y - (size / 2f), rotation - 90);", "Shadow draw call state."),
        "region_rect_call": source_key("Dictionary", "Draw.rect(region, x, y, rotation - 90);", "Region draw call state."),
        "laser_guard": source_key("bool", "any && !isPayload()", "Evaluated laser visibility guard."),
        "angle_to_last": source_key("float", "angleTo(lastX, lastY)", "Evaluated beam angle."),
        "laser_start_x": source_key("float", "x + Angles.trnsx(ang, shootLength)", "Computed beam start X."),
        "laser_start_y": source_key("float", "y + Angles.trnsy(ang, shootLength)", "Computed beam start Y."),
        "laser_width_value": source_key("float", "strength * efficiency * laserWidth", "Computed beam width."),
        "draw_z_call": source_key("Dictionary", "Draw.z(Layer.bullet);", "Conditional laser layer call state."),
        "mixcol_call": source_key("Dictionary", "Draw.mixcol(laserColor, Mathf.absin(4f, 0.6f));", "Conditional laser color call state."),
        "laser_call": source_key("Dictionary", "Drawf.laser(laser, laserStart, laserEnd,\n                x + Angles.trnsx(ang, shootLength), y + Angles.trnsy(ang, shootLength),\n                lastX, lastY, strength * efficiency * laserWidth);", "Conditional laser call state."),
        "mixcol_reset_called": source_key("bool", "Draw.mixcol();", "Whether the conditional laser path reset color."),
    }
    source_symbols.upsert_source_state_schema(GODOT, "source_tractor_beam_turret_build_draw_result", {
        "status": "active",
        "owner": OWNER,
        "runtime_proof": PROOF,
        "source_slice": "N1239",
        "rule": "Dictionary returned by the source-backed TractorBeamBuild.draw state.",
        "keys": keys,
    })
    for name in ("defense_slices", "defense_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
