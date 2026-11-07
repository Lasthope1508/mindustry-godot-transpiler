from pathlib import Path

from mindustry_port import source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/entities/bullet/BulletType.java"
OWNER = "PortGame.source_bullet_type_draw_parts_state"
PROOF = "/root/Main.source_bullet_type_draw_parts_state"


def source_key(type_name: str, expression: str, rule: str) -> dict:
    return {
        "type": type_name,
        "status": "source-backed",
        "java_source": SOURCE,
        "java_method": "drawParts(Bullet b)",
        "java_expr": expression,
        "rule": rule,
    }


def main() -> None:
    source_symbols.upsert_source_state_schema(GODOT, "source_bullet_type_draw_parts_result", {
        "status": "active",
        "owner": OWNER,
        "runtime_proof": PROOF,
        "keys": {
            "bulletType": {"type": "Dictionary", "status": "generated", "alias_of": "bullet_type_state"},
            "bullet": {"type": "Dictionary", "status": "generated", "alias_of": "bullet_state"},
            "parts": source_key("Array", "if(parts.size > 0){", "Bullet type parts collection traversed by drawParts."),
            "gatePassed": source_key("bool", "if(parts.size > 0){", "Drawing occurs only when parts are present."),
            "fin": source_key("float", "DrawPart.params.life = b.fin();", "Bullet lifetime fraction passed into draw parameters."),
            "partParams": source_key("Dictionary", "DrawPart.params.set(b.fin(), 0f, 0f, 0f, 0f, 0f, b.x, b.y, b.rotation());", "Shared DrawPart parameters after set and life assignment."),
            "partDrawCalls": source_key("Array", "parts.get(i).draw(DrawPart.params);", "One draw call per part in source order."),
            "partsDrawn": source_key("bool", "if(parts.size > 0){", "Whether the source draw gate ran."),
            "paramsSetSource": source_key("String", "DrawPart.params.set(b.fin(), 0f, 0f, 0f, 0f, 0f, b.x, b.y, b.rotation());", "Exact parameter-set expression."),
            "paramsLifeSource": source_key("String", "DrawPart.params.life = b.fin();", "Exact lifetime assignment after parameter set."),
            "partDrawSource": source_key("String", "parts.get(i).draw(DrawPart.params);", "Exact per-part draw expression."),
        },
    })


if __name__ == "__main__":
    main()
