from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"


def explicit(type_name: str, java_source: str, java_method: str, java_expr: str, rule: str, owner: str) -> dict:
    return {
        "type": type_name,
        "status": "explicit-input",
        "java_source": java_source,
        "java_method": java_method,
        "java_expr": java_expr,
        "rule": rule,
        "used_by": [owner.lower()],
    }


def upsert_input(name: str, owner: str, proof: str, keys: dict) -> None:
    source_symbols.upsert_source_state_schema(GODOT, name, {
        "status": "active",
        "owner": owner.lower(),
        "runtime_proof": proof,
        "keys": keys,
    })


def main() -> None:
    sync_source = "core/src/mindustry/entities/comp/SyncComp.java"
    sync_proof = "/root/Main.SyncCompGeneratedRuntimeModuleProof"
    upsert_input(
        "source_sync_is_sync_hidden_input",
        "PortGame.source_sync_is_sync_hidden_state",
        sync_proof,
        {"player": explicit("Variant", sync_source, "isSyncHidden(Player player)", "Player player", "Explicit Player argument.", "PortGame.source_sync_is_sync_hidden_state")},
    )
    upsert_input(
        "source_sync_remove_client_removed_entity_input",
        "PortGame.source_sync_remove_client_removed_entity_state",
        sync_proof,
        {
            "net_client": explicit("bool", sync_source, "remove()", "Vars.net.client()", "Explicit client gate input.", "PortGame.source_sync_remove_client_removed_entity_state"),
            "entity_id": explicit("int", sync_source, "remove()", "id()", "Explicit entity identifier input.", "PortGame.source_sync_remove_client_removed_entity_state"),
        },
    )
    upsert_input(
        "source_sync_update_interpolate_input",
        "PortGame.source_sync_update_interpolate_state",
        sync_proof,
        {
            "net_client": explicit("bool", sync_source, "update()", "Vars.net.client()", "Explicit network client input.", "PortGame.source_sync_update_interpolate_state"),
            "is_local": explicit("bool", sync_source, "update()", "isLocal()", "Explicit local-player input.", "PortGame.source_sync_update_interpolate_state"),
            "is_remote": explicit("bool", sync_source, "update()", "isRemote()", "Explicit remote-player input.", "PortGame.source_sync_update_interpolate_state"),
        },
    )

    unit_source = "core/src/mindustry/entities/comp/UnitComp.java"
    unit_proof = "/root/Main.UnitCompGeneratedRuntimeModuleProof"
    double_name = "source_unit_set_prop_laccess_double_input"
    double_schema = source_symbols.load_source_state_schema(GODOT)["schemas"][double_name]
    double_schema["keys"].update({
        "value": explicit("float", unit_source, "UnitComp.setProp(LAccess,double)", "value", "Property value.", "PortGame.source_unit_set_prop_laccess_double_state"),
        "unit_state": explicit("Dictionary", unit_source, "UnitComp.setProp(LAccess,double)", "this", "Explicit mutable unit state.", "PortGame.source_unit_set_prop_laccess_double_state"),
        "source_tilesize": explicit("float", unit_source, "UnitComp.setProp(LAccess,double)", "tilesize", "World tile-size dependency used by velocity properties.", "PortGame.source_unit_set_prop_laccess_double_state"),
    })
    source_symbols.upsert_source_state_schema(GODOT, double_name, double_schema)

    object_name = "source_unit_set_prop_laccess_object_input"
    object_schema = source_symbols.load_source_state_schema(GODOT)["schemas"][object_name]
    object_schema["keys"]["unit_state"] = explicit("Dictionary", unit_source, "UnitComp.setProp(LAccess,Object)", "this", "Explicit mutable unit state.", "PortGame.source_unit_set_prop_laccess_object_state")
    source_symbols.upsert_source_state_schema(GODOT, object_name, object_schema)

    # These legacy contracts name shared source expressions directly. Keep the
    # names stable while giving each dependency one canonical typed schema.
    source_symbols.upsert_source_state_schema(GODOT, "world.tileWorld(aimX, aimY)", {
        "status": "active",
        "owner": "port_game.source_bullet_type_create_aim_state",
        "runtime_proof": "/root/Main.source_bullet_type_create_aim_state",
        "keys": {"value": explicit("Variant", "core/src/mindustry/entities/bullet/BulletType.java", "create(...)", "world.tileWorld(aimX, aimY)", "World tile lookup dependency.", "PortGame.source_bullet_type_create_aim_state")},
    })
    for expression, owner, proof, method in (
        ("Mathf.random(lifeScaleRandMin, lifeScaleRandMax)", "PortGame.source_bullet_type_create_lifetime_payload_damage_state", "/root/Main.source_bullet_type_create_lifetime_payload_damage_state", "create(...)") ,
        ("Mathf.random(velocityScaleRandMin, velocityScaleRandMax)", "PortGame.source_bullet_type_create_velocity_position_state", "/root/Main.source_bullet_type_create_velocity_position_state", "create(...)") ,
    ):
        source_symbols.upsert_source_state_schema(GODOT, expression, {
            "status": "active",
            "owner": owner,
            "runtime_proof": proof,
            "keys": {"value": explicit("float", "arc-core/src/arc/math/Mathf.java", method, expression, "Canonical random-factor dependency.", owner)},
        })
    source_symbols.upsert_source_state_schema(GODOT, "bullet.damageMultiplier()", {
        "status": "active",
        "owner": "PortGame.source_bullet_type_create_lifetime_payload_damage_state",
        "runtime_proof": "/root/Main.source_bullet_type_create_lifetime_payload_damage_state",
        "keys": {"value": explicit("float", "core/src/mindustry/entities/bullet/BulletType.java", "damageMultiplier(Bullet b)", "bullet.damageMultiplier()", "Canonical bullet damage multiplier dependency.", "PortGame.source_bullet_type_create_lifetime_payload_damage_state")},
    })

    projector_source = "core/src/mindustry/world/blocks/defense/MendProjector.java; core/src/mindustry/world/blocks/defense/OverdriveProjector.java"
    projector_owners = [
        "PortGame.source_mend_projector_draw_state", "PortGame.source_mend_projector_light_state",
        "PortGame.source_mend_projector_place_state", "PortGame.source_mend_projector_progress",
        "PortGame.source_mend_projector_range", "PortGame.source_mend_projector_repair_amount",
        "PortGame.source_mend_projector_select_state", "PortGame.source_overdrive_projector_boost_bar_fraction",
        "PortGame.source_overdrive_projector_draw_state", "PortGame.source_overdrive_projector_light_state",
        "PortGame.source_overdrive_projector_place_state", "PortGame.source_overdrive_projector_range",
        "PortGame.source_overdrive_projector_real_boost", "PortGame.source_overdrive_projector_select_state",
        "PortGame.source_overdrive_projector_target_filter_state",
    ]
    source_symbols.upsert_source_state_schema(GODOT, "content_block_state", {
        "status": "active",
        "owner": "PortGame.source_block_metadata_state",
        "runtime_proof": "/root/Main.SourceBlockMetadataStateModuleProof",
        "keys": {
            "range": explicit("float", projector_source, "MendProjector.range()/OverdriveProjector.range()", "range", "Projector range field.", projector_owners[0]),
            "phaseRangeBoost": explicit("float", projector_source, "MendProjector.range()/OverdriveProjector.range()", "phaseRangeBoost", "Phase projector range boost field.", projector_owners[4]),
            "healPercent": explicit("float", projector_source, "MendProjector.repairAmount()", "healPercent", "Mend projector heal percentage field.", projector_owners[5]),
            "phaseBoost": explicit("float", projector_source, "MendProjector.repairAmount()", "phaseBoost", "Mend projector phase boost field.", projector_owners[5]),
            "speedBoost": explicit("float", projector_source, "OverdriveProjector.realBoost()", "speedBoost", "Overdrive speed boost field.", projector_owners[12]),
            "speedBoostPhase": explicit("float", projector_source, "OverdriveProjector.realBoost()", "speedBoostPhase", "Overdrive phase speed boost field.", projector_owners[12]),
            "canOverdrive": explicit("bool", "core/src/mindustry/world/Block.java", "Block.canOverdrive", "other.block.canOverdrive", "Target block overdrive eligibility field.", projector_owners[-1]),
            "size": explicit("int", "core/src/mindustry/world/Block.java", "Block.size", "other.block.size", "Block footprint field.", projector_owners[0]),
        },
    })
    source_ssot.write_registered_json(GODOT, "unit_comp_state_schema", source_ssot.build_extension_shard(GODOT, "unit_comp_state_schema"))


if __name__ == "__main__":
    main()
