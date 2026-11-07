from pathlib import Path

from mindustry_port import source_ssot, source_symbols


GODOT = Path(__file__).resolve().parents[2] / "godot-mindustry"
SOURCE = "core/src/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.java"
INNER = "public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{"


def source(owner: str, method: str, expression: str, type_name: str = "String") -> dict:
    return {"type": type_name, "status": "source-backed", "java_source": SOURCE, "java_method": method, "java_expr": expression, "rule": "Exact upstream source expression.", "used_by": [owner.lower()]}


def main() -> None:
    catalog = source_symbols.load_source_state_schema(GODOT)
    specs = {
        "can_consume": ("PortGame.source_continuous_liquid_turret_build_can_consume_state", "public boolean canConsume(){", {
            "source_owner": ("public boolean canConsume(){", "String"), "inner_class": (INNER, "String"), "field": ("activated", "String"), "override_expr": ("@Override", "String"), "return_expr": ("return hasCorrectAmmo() && super.canConsume();", "String")}),
        "get_ammo_fraction": ("PortGame.source_continuous_liquid_turret_build_get_ammo_fraction_state", "public float getAmmoFraction(){", {
            "source_owner": ("public float getAmmoFraction(){", "String"), "inner_class": (INNER, "String"), "override_expr": ("@Override", "String"), "return_expr": ("return liquids.currentAmount() / liquidCapacity;", "String")}),
        "peek_ammo": ("PortGame.source_continuous_liquid_turret_build_peek_ammo_state", "public BulletType peekAmmo(){", {
            "source_owner": ("public BulletType peekAmmo(){", "String"), "inner_class": (INNER, "String"), "field": ("activated", "String"), "override_expr": ("@Override", "String"), "return_expr": ("return ammoTypes.get(liquids.current());", "String")}),
        "sense_object": ("PortGame.source_continuous_liquid_turret_build_sense_object_state", "public Object senseObject(LAccess sensor){", {
            "source_owner": ("public Object senseObject(LAccess sensor){", "String"), "inner_class": (INNER, "String"), "field": ("activated", "String"), "switch_return_expr": ("case currentAmmoType -> liquids.current();", "String")}),
        "should_consume": ("PortGame.source_continuous_liquid_turret_build_should_consume_state", "public boolean shouldConsume(){", {
            "source_owner": ("public boolean shouldConsume(){", "String"), "inner_class": (INNER, "String"), "field": ("activated", "String"), "return_expr": ("return super.shouldConsume() && activated;", "String")}),
        "use_ammo": ("PortGame.source_continuous_liquid_turret_build_use_ammo_state", "public BulletType useAmmo(){", {
            "source_owner": ("public BulletType useAmmo(){", "String"), "inner_class": (INNER, "String"), "field": ("activated", "String"), "override_expr": ("@Override", "String"), "return_expr": ("return peekAmmo();", "String")}),
    }
    for name, (owner, method, entries) in specs.items():
        schema = catalog["schemas"][f"source_continuous_liquid_turret_build_{name}_result"]
        for key_name, (expression, type_name) in entries.items():
            schema["keys"][key_name] = source(owner, method, expression, type_name)
    errors = source_symbols.validate_source_state_schema(catalog)
    if errors:
        raise ValueError("invalid source state schema: " + "; ".join(errors))
    source_ssot.write_json(GODOT, "state_schema", catalog)
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
