"""Register the Arc math call-sites used by PowerGenerator.createExplosion()."""

from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SCHEMA = "source_power_generator_create_explosion_puddle_vector_result"
OWNER = "PortGame.source_power_generator_create_explosion_puddle_vector_state"


def key(source: str, method: str, expression: str) -> dict:
    return {
        "type": "String",
        "status": "source-backed",
        "java_source": source,
        "java_method": method,
        "java_expr": expression,
        "rule": "Exact Arc/PowerGenerator call-site used by the canonical vector state.",
        "used_by": [OWNER.lower()],
    }


def main() -> None:
    catalog = source_symbols.load_source_state_schema(GODOT)
    catalog["schemas"][SCHEMA]["keys"].update({
        "mathf_random_float_method": key("arc-core/src/arc/math/Mathf.java", "random(float range)", "public static float random(float range){"),
        "mathf_random_float_return": key("arc-core/src/arc/math/Mathf.java", "random(float range)", "return rand.nextFloat() * range;"),
        "vec2_trns_method": key("arc-core/src/arc/math/geom/Vec2.java", "trns(float angle, float amount)", "public Vec2 trns(float angle, float amount){"),
        "vec2_trns_return": key("arc-core/src/arc/math/geom/Vec2.java", "trns(float angle, float amount)", "return set(amount, 0).rotate(angle);"),
        "vec2_rotate_method": key("arc-core/src/arc/math/geom/Vec2.java", "rotate(float degrees)", "public Vec2 rotate(float degrees){"),
        "vec2_rotate_return": key("arc-core/src/arc/math/geom/Vec2.java", "rotate(float degrees)", "return rotateRad(degrees * Mathf.degreesToRadians);"),
        "vec2_rotate_rad_method": key("arc-core/src/arc/math/geom/Vec2.java", "rotateRad(float radians)", "public Vec2 rotateRad(float radians){"),
    })
    errors = source_symbols.validate_source_state_schema(catalog)
    if errors:
        raise ValueError("invalid PowerGenerator vector schema: " + "; ".join(errors))
    source_ssot.write_json(GODOT, "state_schema", catalog)
    for module in source_ssot.registered_modules(GODOT):
        if module.canonical_module == "state_schema":
            source_ssot.write_registered_json(GODOT, module.name, source_ssot.build_extension_shard(GODOT, module.name))
    source_symbols.write_source_symbol_audit_report(GODOT)
    print("registered_power_generator_vector_math_keys=7")


if __name__ == "__main__":
    main()
