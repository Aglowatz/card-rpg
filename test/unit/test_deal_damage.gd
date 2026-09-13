## Proves the src/core/ boundary holds: card data and effect resolution
## work with no Node and no scene tree at all.
extends GutTest

func test_deal_damage_reduces_target_toughness() -> void:
	var attacker_data := CardData.new()
	attacker_data.id = &"attacker"
	attacker_data.display_name = "Attacker"

	var target_data := CardData.new()
	target_data.id = &"target"
	target_data.display_name = "Target"
	target_data.toughness = 5

	var attacker := CardInstance.new(attacker_data)
	var target := CardInstance.new(target_data)

	var ctx := EffectContext.new(attacker, target)
	var effect := DealDamage.new(3)
	effect.resolve(ctx)

	assert_eq(target.current_toughness(), 2)
	assert_false(target.is_destroyed())

func test_deal_damage_can_destroy_target() -> void:
	var target_data := CardData.new()
	target_data.toughness = 2
	var target := CardInstance.new(target_data)

	var ctx := EffectContext.new(null, target)
	var effect := DealDamage.new(5)
	effect.resolve(ctx)

	assert_true(target.is_destroyed())

func test_card_data_describe_effect() -> void:
	var effect := DealDamage.new(4)
	assert_eq(effect.describe(), "Deal 4 damage.")
