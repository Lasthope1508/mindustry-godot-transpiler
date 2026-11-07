import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"
PROOF_DIR = PROJECT / "tools" / "runtime_proofs"

CANONICALIZED_RUNTIME_PROOFS = [
    "ControlInputModuleProof.gd",
    "InputEventRuntimeStateModuleProof.gd",
    "InputViewportRuntimeModuleProof.gd",
    "FactoryRuntimeModuleProof.gd",
    "GeneratedClassPathHeadquarterProof.gd",
    "GeneratedClassRuntimeModuleProof.gd",
    "RootPolicyShardModuleProof.gd",
    "RuntimeSummaryModuleProof.gd",
    "SourceMathAngleModuleProof.gd",
    "SsotHeadquarterRegistryProof.gd",
    "AbilityModuleProof.gd",
    "BasicCompStateModuleProof.gd",
    "BuildSelectionModuleProof.gd",
    "ChildStateModuleProof.gd",
    "ItemEntryModuleProof.gd",
    "PlayableContentDefaultsModuleProof.gd",
    "ProjectorBoostRuntimeModuleProof.gd",
    "SelectedBuildStateModuleProof.gd",
    "BlockInitBufferedPowerModuleProof.gd",
    "BlockInitBuildingDefaultModuleProof.gd",
    "BlockInitBuildTimeModuleProof.gd",
    "BlockInitClipModuleProof.gd",
    "BlockInitConsumerModuleProof.gd",
    "BlockInitFlagsModuleProof.gd",
    "BlockInitHealthModuleProof.gd",
    "BlockInitItemLiquidFiltersModuleProof.gd",
    "BlockInitLogicConfigurableModuleProof.gd",
    "BlockInitPlacementModuleProof.gd",
    "BlockInitSandboxVisibilityModuleProof.gd",
    "BlockInitSetBarsCallModuleProof.gd",
    "BlockInitSoundModuleProof.gd",
    "BlockInitStatsCategoriesModuleProof.gd",
    "BlockQueryBasicModuleProof.gd",
    "BlockQueryConsumerModuleProof.gd",
    "BlockQueryDarknessModuleProof.gd",
    "BlockQueryFilterModuleProof.gd",
    "BlockQueryModuleProof.gd",
    "BlockQueryPlacementModuleProof.gd",
    "DisplayProfileRuntimeModuleProof.gd",
    "HudRuntimeStateModuleProof.gd",
    "PlayableSmokeRuntimeProof.gd",
    "TextureRuntimeModuleProof.gd",
    "ConveyorRuntimeStateModuleProof.gd",
    "GameLoopRuntimeStateModuleProof.gd",
    "WaveTimingRuntimeModuleProof.gd",
    "BuildPayloadModuleProof.gd",
    "ConstructBuildStateModuleProof.gd",
    "PlacedBlockStateModuleProof.gd",
    "EnemyUnitRuntimeModuleProof.gd",
    "UnitDestroyModuleProof.gd",
    "UnitFallingStateModuleProof.gd",
    "UnitMetadataCallbackModuleProof.gd",
    "UnitPayloadBasicModuleProof.gd",
    "UnitPayloadContentModuleProof.gd",
    "UnitPayloadDrawModuleProof.gd",
    "UnitPayloadDumpModuleProof.gd",
    "UnitPayloadDumpOverlapGuardModuleProof.gd",
    "UnitPayloadDumpSolidityGuardModuleProof.gd",
    "UnitPayloadIoModuleProof.gd",
    "UnitPayloadRequirementsModuleProof.gd",
    "PowerGeneratedRuntimeStateModuleProof.gd",
    "PowerGeneratorModuleProof.gd",
    "PowerGeneratorPuddleVectorModuleProof.gd",
    "PlacedPowerBatteryRuntimeModuleProof.gd",
    "PlacedPowerDistributionRuntimeModuleProof.gd",
    "PlacedPowerGraphStateModuleProof.gd",
    "PowerGraphBatteryDistributionModuleProof.gd",
    "PowerGraphDefaultRequestedPowerProof.gd",
    "PowerGraphDefaultRoleCallbackProof.gd",
    "PowerTurretBuildModuleProof.gd",
    "ConsumePowerModuleProof.gd",
    "ConsumeGeneratedRuntimeStateModuleProof.gd",
    "ConsumeItemAttributeGeneratedRuntimeStateModuleProof.gd",
    "ConsumeItemDynamicGeneratedRuntimeStateModuleProof.gd",
    "ConsumeItemEfficiencyGeneratedRuntimeStateModuleProof.gd",
    "ConsumeItemExplodeGeneratedRuntimeStateModuleProof.gd",
    "ConsumeItemFilterGeneratedRuntimeStateModuleProof.gd",
    "ConsumeItemListGeneratedRuntimeStateModuleProof.gd",
    "ConsumeItemsGeneratedRuntimeStateModuleProof.gd",
    "ConsumeLiquidFlammableModuleProof.gd",
    "ConsumeLiquidBaseGeneratedRuntimeStateModuleProof.gd",
    "ConsumeLiquidFilterGeneratedRuntimeStateModuleProof.gd",
    "ConsumeLiquidFlammableGeneratedRuntimeStateModuleProof.gd",
    "ConsumeLiquidsDynamicGeneratedRuntimeStateModuleProof.gd",
    "ConsumeLiquidsGeneratedRuntimeStateModuleProof.gd",
    "BuildingControlStateModuleProof.gd",
    "BuildingDestructionStateModuleProof.gd",
    "BuildingDrawStateModuleProof.gd",
    "BuildingEfficiencyStateModuleProof.gd",
    "BuildingGeometryStateModuleProof.gd",
    "BuildingLifecycleStateModuleProof.gd",
    "BuildingMetaStateModuleProof.gd",
    "BuildingPowerStateModuleProof.gd",
    "BuildingSetPropStateModuleProof.gd",
    "BuildingTetherStateModuleProof.gd",
    "BuildingVisibilityStateModuleProof.gd",
    "BlockSenseModuleProof.gd",
    "BuilderRuntimeStateModuleProof.gd",
    "BuilderDrawStateModuleProof.gd",
    "BuildPayloadLifecycleModuleProof.gd",
    "BlockCheckContentArrayCapacityModuleProof.gd",
    "BlockConsumeModuleProof.gd",
    "BlockGetDependenciesModuleProof.gd",
    "BlockLoadModuleProof.gd",
    "BlockMetadataModuleProof.gd",
    "BlockPlanModuleProof.gd",
    "BlockPostInitModuleProof.gd",
    "BlockProducerModuleProof.gd",
    "BlockReinitializeConsumersModuleProof.gd",
    "BlockPlacementModuleProof.gd",
    "BlockRequirementsStateModuleProof.gd",
    "BlockResearchRequirementsStateModuleProof.gd",
    "BlockUnitStateModuleProof.gd",
    "BaseTurretDrawModuleProof.gd",
    "ContinuousLiquidTurretBuildModuleProof.gd",
    "ItemTurretBuildModuleProof.gd",
    "LiquidTurretBuildModuleProof.gd",
    "ShootPatternModuleProof.gd",
    "TurretAmmoModuleProof.gd",
    "TurretCellRegistryModuleProof.gd",
    "TurretCombatModuleProof.gd",
    "TurretInitModuleProof.gd",
    "TurretLiquidInitModuleProof.gd",
    "TurretOutputsItemsModuleProof.gd",
    "TurretPlacementModuleProof.gd",
    "TurretPresentationModuleProof.gd",
    "TurretPropertyModuleProof.gd",
    "TurretRangeModuleProof.gd",
    "TurretRuntimeCallbackModuleProof.gd",
    "TurretSimulationModuleProof.gd",
    "TurretStatsBarsModuleProof.gd",
    "MendProjectorRuntimeModuleProof.gd",
    "OverdriveProjectorRuntimeModuleProof.gd",
    "SyncStateModuleProof.gd",
    "UnitTetherStateModuleProof.gd",
    "TractorBeamLifecycleModuleProof.gd",
    "TractorBeamUpdateTileFlowModuleProof.gd",
    "TractorBeamUpdateTileRetargetModuleProof.gd",
    "TractorBeamAngleStateModuleProof.gd",
    "TractorBeamAnyTrueStateModuleProof.gd",
    "TractorBeamDamagePierceStateModuleProof.gd",
    "TractorBeamDrawStateModuleProof.gd",
    "TractorBeamImpulseNetStateModuleProof.gd",
    "TractorBeamLastTargetPositionStateModuleProof.gd",
    "TractorBeamLookTargetGuardStateModuleProof.gd",
    "TractorBeamRotationStateModuleProof.gd",
    "TractorBeamShootWhenPossibleGuardStateModuleProof.gd",
    "TractorBeamSoundLoopStateModuleProof.gd",
    "TractorBeamStatusApplyStateModuleProof.gd",
    "TractorBeamStrengthStateModuleProof.gd",
    "BuildingConfigureStateModuleProof.gd",
    "BuildingDamageModuleProof.gd",
    "BuildingDisplayStateModuleProof.gd",
    "BuildingInteractionModuleProof.gd",
    "BuildingInteractionStateModuleProof.gd",
    "BuildingItemDumpStateModuleProof.gd",
    "BuildingItemStateModuleProof.gd",
    "BuildingLiquidStateModuleProof.gd",
    "BuildingPayloadStateModuleProof.gd",
    "BuildingSenseModuleProof.gd",
    "BuildingTimeStateModuleProof.gd",
    "BulletRuntimeModuleProof.gd",
    "BulletTypeCallbackModuleProof.gd",
    "BulletTypeCreateCoreStateModuleProof.gd",
    "BulletTypeCreateFragsStateModuleProof.gd",
    "WeaponBulletEffectsModuleProof.gd",
    "WeaponMountAutoTargetModuleProof.gd",
    "WeaponMountKinematicsModuleProof.gd",
    "WeaponShootModuleProof.gd",
    "StatusApplyModuleProof.gd",
    "DrillDumpRuntimeStateModuleProof.gd",
    "DrillInventoryCallbackModuleProof.gd",
    "DrillProductionRuntimeStateModuleProof.gd",
    "DrillRuntimeStateModuleProof.gd",
    "ItemTransportRuntimeStateModuleProof.gd",
    "WorldInitialBuildRuntimeStateModuleProof.gd",
    "WorldTerrainRuntimeStateModuleProof.gd",
    "CampaignSectorModuleProof.gd",
    "CampaignShellModuleProof.gd",
    "CampaignShellUiRuntimeProof.gd",
]


POWER_RUNTIME_PROOFS_READY_FOR_CANONICAL_EXIT = [
    "PlacedPowerBatteryRuntimeModuleProof.gd",
    "PlacedPowerDistributionRuntimeModuleProof.gd",
    "PlacedPowerGraphStateModuleProof.gd",
    "PowerGraphBatteryDistributionModuleProof.gd",
    "PowerGraphDefaultRequestedPowerProof.gd",
    "PowerGraphDefaultRoleCallbackProof.gd",
    "PowerTurretBuildModuleProof.gd",
]


TRACTOR_BEAM_LEAF_RUNTIME_PROOFS_READY_FOR_CANONICAL_EXIT = [
    "TractorBeamAngleStateModuleProof.gd",
    "TractorBeamAnyTrueStateModuleProof.gd",
    "TractorBeamDamagePierceStateModuleProof.gd",
    "TractorBeamDrawStateModuleProof.gd",
    "TractorBeamImpulseNetStateModuleProof.gd",
    "TractorBeamLastTargetPositionStateModuleProof.gd",
    "TractorBeamLookTargetGuardStateModuleProof.gd",
    "TractorBeamRotationStateModuleProof.gd",
    "TractorBeamShootWhenPossibleGuardStateModuleProof.gd",
    "TractorBeamSoundLoopStateModuleProof.gd",
    "TractorBeamStatusApplyStateModuleProof.gd",
    "TractorBeamStrengthStateModuleProof.gd",
]


BUILDING_RUNTIME_PROOFS_READY_FOR_CANONICAL_EXIT = [
    "BuildingConfigureStateModuleProof.gd",
    "BuildingDamageModuleProof.gd",
    "BuildingDisplayStateModuleProof.gd",
    "BuildingInteractionModuleProof.gd",
    "BuildingInteractionStateModuleProof.gd",
    "BuildingItemDumpStateModuleProof.gd",
    "BuildingItemStateModuleProof.gd",
    "BuildingLiquidStateModuleProof.gd",
    "BuildingPayloadStateModuleProof.gd",
    "BuildingSenseModuleProof.gd",
    "BuildingTimeStateModuleProof.gd",
]

BULLET_WEAPON_RUNTIME_PROOFS_READY_FOR_CANONICAL_EXIT = [
    "BulletRuntimeModuleProof.gd",
    "BulletTypeCallbackModuleProof.gd",
    "BulletTypeCreateCoreStateModuleProof.gd",
    "BulletTypeCreateFragsStateModuleProof.gd",
    "WeaponBulletEffectsModuleProof.gd",
    "WeaponMountAutoTargetModuleProof.gd",
    "WeaponMountKinematicsModuleProof.gd",
    "WeaponShootModuleProof.gd",
]

DRILL_ITEM_TRANSPORT_RUNTIME_PROOFS_READY_FOR_CANONICAL_EXIT = [
    "DrillDumpRuntimeStateModuleProof.gd",
    "DrillInventoryCallbackModuleProof.gd",
    "DrillProductionRuntimeStateModuleProof.gd",
    "DrillRuntimeStateModuleProof.gd",
    "ItemTransportRuntimeStateModuleProof.gd",
]

CAMPAIGN_RUNTIME_PROOFS_READY_FOR_CANONICAL_EXIT = [
    "CampaignSectorModuleProof.gd",
    "CampaignShellModuleProof.gd",
    "CampaignShellUiRuntimeProof.gd",
]


class RuntimeProofStateSliceTests(unittest.TestCase):
    def test_runtime_proof_state_canonically_writes_json_and_exits_by_matches(self):
        source_path = PROOF_DIR / "RuntimeProofState.gd"
        self.assertTrue(source_path.exists(), "RuntimeProofState.gd must own runtime proof finalization")
        source = source_path.read_text(encoding="utf-8")

        self.assertIn("class_name RuntimeProofState", source)
        self.assertIn("static func proof_path(proof_name: String) -> String:", source)
        self.assertIn('ProjectSettings.globalize_path("res://tools/runtime_proofs/" + proof_name + ".json")', source)
        self.assertIn("static func write_proof(proof_name: String, proof: Dictionary) -> String:", source)
        self.assertIn("proof_file.store_string(proof_json)", source)
        self.assertIn("proof_file.flush()", source)
        self.assertIn("static func exit_code(proof: Dictionary) -> int:", source)
        self.assertIn('return 0 if bool(proof.get("matches", false)) else 1', source)

    def test_input_and_factory_runtime_proofs_use_canonical_finalizer(self):
        for proof_name in CANONICALIZED_RUNTIME_PROOFS:
            with self.subTest(proof=proof_name):
                proof_source = (PROOF_DIR / proof_name).read_text(encoding="utf-8")
                module_name = proof_name.removesuffix(".gd")

                self.assertIn('const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")', proof_source)
                self.assertIn('proof["matches"] =', proof_source)
                self.assertIn('runtime_proof_state.write_proof("%s", proof)' % module_name, proof_source)
                self.assertIn("get_tree().quit(runtime_proof_state.exit_code(proof))", proof_source)
                self.assertIn("await get_tree().process_frame", proof_source)
                self.assertNotIn("await get_tree().create_timer(60.0).timeout", proof_source)
                self.assertNotIn("get_tree().quit(0)", proof_source)


    def test_power_runtime_proofs_define_registry_guarded_matches_schema(self):
        for proof_name in POWER_RUNTIME_PROOFS_READY_FOR_CANONICAL_EXIT:
            with self.subTest(proof=proof_name):
                proof_source = (PROOF_DIR / proof_name).read_text(encoding="utf-8")
                self.assertIn('proof["matches"] =', proof_source)
                matches_block = proof_source.split('proof["matches"] =', 1)[1].split("print(", 1)[0]
                self.assertIn('proof["registry_valid"]', matches_block)
                self.assertIn('proof["one_headquarter_per_ssot"]', matches_block)

    def test_tractor_beam_leaf_runtime_proofs_define_registry_guarded_matches_schema(self):
        for proof_name in TRACTOR_BEAM_LEAF_RUNTIME_PROOFS_READY_FOR_CANONICAL_EXIT:
            with self.subTest(proof=proof_name):
                proof_source = (PROOF_DIR / proof_name).read_text(encoding="utf-8")
                self.assertIn('proof["matches"] =', proof_source)
                matches_block = proof_source.split('proof["matches"] =', 1)[1].split("print(", 1)[0]
                self.assertIn('proof["registry_valid"]', matches_block)
                self.assertIn('proof["one_headquarter_per_ssot"]', matches_block)

    def test_building_runtime_proofs_define_registry_guarded_matches_schema(self):
        for proof_name in BUILDING_RUNTIME_PROOFS_READY_FOR_CANONICAL_EXIT:
            with self.subTest(proof=proof_name):
                proof_source = (PROOF_DIR / proof_name).read_text(encoding="utf-8")
                self.assertIn('proof["matches"] =', proof_source)
                matches_block = proof_source.split('proof["matches"] =', 1)[1].split("print(", 1)[0]
                if "var proof_matches:" in proof_source:
                    matches_block = proof_source.split("var proof_matches:", 1)[1].split('proof["matches"] =', 1)[0] + matches_block
                self.assertIn('proof["registry_valid"]', matches_block)
                self.assertIn('proof["one_headquarter_per_ssot"]', matches_block)

    def test_bullet_weapon_runtime_proofs_define_registry_guarded_matches_schema(self):
        for proof_name in BULLET_WEAPON_RUNTIME_PROOFS_READY_FOR_CANONICAL_EXIT:
            with self.subTest(proof=proof_name):
                proof_source = (PROOF_DIR / proof_name).read_text(encoding="utf-8")
                self.assertIn('proof["matches"] =', proof_source)
                matches_block = proof_source.split('proof["matches"] =', 1)[1].split("print(", 1)[0]
                self.assertIn('proof["registry_valid"]', matches_block)
                self.assertIn('proof["one_headquarter_per_ssot"]', matches_block)

    def test_drill_item_transport_runtime_proofs_define_registry_guarded_matches_schema(self):
        for proof_name in DRILL_ITEM_TRANSPORT_RUNTIME_PROOFS_READY_FOR_CANONICAL_EXIT:
            with self.subTest(proof=proof_name):
                proof_source = (PROOF_DIR / proof_name).read_text(encoding="utf-8")
                self.assertIn('proof["matches"] =', proof_source)
                matches_block = proof_source.split('proof["matches"] =', 1)[1].split("print(", 1)[0]
                self.assertIn('proof["registry_valid"]', matches_block)
                self.assertIn('proof["one_headquarter_per_ssot"]', matches_block)

    def test_campaign_runtime_proofs_define_registry_guarded_matches_schema(self):
        for proof_name in CAMPAIGN_RUNTIME_PROOFS_READY_FOR_CANONICAL_EXIT:
            with self.subTest(proof=proof_name):
                proof_source = (PROOF_DIR / proof_name).read_text(encoding="utf-8")
                self.assertIn('proof["matches"] =', proof_source)
                matches_block = proof_source.split('proof["matches"] =', 1)[1].split("print(", 1)[0]
                self.assertIn('proof["registry_valid"]', matches_block)
                self.assertIn('proof["one_headquarter_per_ssot"]', matches_block)

    def test_placed_power_graph_runtime_proof_uses_metadata_only_fake_sprites(self):
        proof_source = (PROOF_DIR / "PlacedPowerGraphStateModuleProof.gd").read_text(encoding="utf-8")
        self.assertIn("class FakeSprite:", proof_source)
        self.assertIn("extends RefCounted", proof_source)
        self.assertNotIn("Sprite2D.new()", proof_source)


if __name__ == "__main__":
    unittest.main()
