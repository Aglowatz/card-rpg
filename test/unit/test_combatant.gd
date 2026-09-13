## Combatant zone/mana mechanics, with no BattleState involved.
extends GutTest

func _card(id: StringName, card_type: CardData.CardType = CardData.CardType.CREATURE) -> CardInstance:
	var data := CardData.new()
	data.id = id
	data.display_name = String(id)
	data.card_type = card_type
	return CardInstance.new(data)

func test_draw_card_moves_top_of_library_to_hand() -> void:
	var combatant := Combatant.new(20, "Test")
	combatant.library = [_card(&"a"), _card(&"b")]

	combatant.draw_card()

	assert_eq(combatant.hand.size(), 1)
	assert_eq(combatant.library.size(), 1)

func test_draw_from_empty_library_is_a_safe_no_op() -> void:
	var combatant := Combatant.new(20, "Test")
	combatant.draw_card()
	assert_eq(combatant.hand.size(), 0)

func test_gain_land_mana_increases_max_mana_and_caps() -> void:
	var combatant := Combatant.new(20, "Test")
	for i in Combatant.MAX_MANA + 5:
		combatant.gain_land_mana()
	assert_eq(combatant.max_mana, Combatant.MAX_MANA)

func test_refill_mana_sets_current_mana_to_max() -> void:
	var combatant := Combatant.new(20, "Test")
	combatant.gain_land_mana()
	combatant.gain_land_mana()
	combatant.mana = 0
	combatant.refill_mana()
	assert_eq(combatant.mana, 2)

func test_take_damage_reduces_life_and_reports_defeat() -> void:
	var combatant := Combatant.new(5, "Test")
	combatant.take_damage(3)
	assert_eq(combatant.life, 2)
	assert_false(combatant.is_defeated())
	combatant.take_damage(2)
	assert_true(combatant.is_defeated())
