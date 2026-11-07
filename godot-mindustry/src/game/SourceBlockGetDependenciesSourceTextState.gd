extends RefCounted
class_name SourceBlockGetDependenciesSourceTextState

const SOURCE_BLOCK_GET_DEPENDENCIES_SOURCE := "core/src/mindustry/world/Block.java"
const SOURCE_BLOCK_GET_DEPENDENCIES_METHOD := "public void getDependencies(Cons<UnlockableContent> cons){"
const SOURCE_BLOCK_GET_DEPENDENCIES_JAVA_METHOD_GET_DEPENDENCIES_119 := "java_method_getDependencies_119"
const SOURCE_BLOCK_GET_DEPENDENCIES_GENERATED_OWNER := "block.java_method_getDependencies_119"
const SOURCE_BLOCK_GET_DEPENDENCIES_REQUIREMENTS_COMMENT := "//just requires items"
const SOURCE_BLOCK_GET_DEPENDENCIES_REQUIREMENTS_LOOP_EXPR := "for(ItemStack stack : requirements){"
const SOURCE_BLOCK_GET_DEPENDENCIES_CONS_GET_ITEM_EXPR := "cons.get(stack.item);"
const SOURCE_BLOCK_GET_DEPENDENCIES_INPUTS_COMMENT := "//also requires inputs"
const SOURCE_BLOCK_GET_DEPENDENCIES_CONSUME_BUILDER_LOOP_EXPR := "for(var c : consumeBuilder){"
const SOURCE_BLOCK_GET_DEPENDENCIES_OPTIONAL_GUARD_EXPR := "if(c.optional) continue;"
const SOURCE_BLOCK_GET_DEPENDENCIES_CONSUME_ITEMS_GUARD_EXPR := "if(c instanceof ConsumeItems i){"
const SOURCE_BLOCK_GET_DEPENDENCIES_CONSUME_ITEMS_LOOP_EXPR := "for(ItemStack stack : i.items){"
