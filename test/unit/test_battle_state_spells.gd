## Spell casting: resolves its effect against a chosen (or defaulted)
## target, then goes to the graveyard.
extends GutTest

func _spell_data(id: StringName, amount: int, cost: int = 1) -> CardData:
	var data := CardData.new()
	data.id = id
	data.display_name = String(id)
	data.card_type = CardData.CardType.SPELL
	data.cost = cost
	data.effects = [DealDamage.new(amount)]
	return data

func _creature_data(id: StringName, power: int, toughness: int) -> CardData:
	var data := CardData.new()
	data.id = id
	data.card_type = CardData.CardType.CREATURE
	data.power = power
	data.toughness = toughness
	return data

func _make_battle(a: Combatant, b: Combatant) -> BattleState:
	var providers: Array[ChoiceProvider] = [AutoChoiceProvider.new(), AutoChoiceProvider.new()]
	var controllers: Array[EnemyController] = [null, null]
	return BattleState.new([a, b], controllers, providers)

func test_spell_with_explicit_target_hits_that_target_and_goes_to_graveyard() -> void:
	var a := Combatant.new(20, "A")
	a.mana = 5
	var b := Combatant.new(20, "B")
	var battle := _make_battle(a, b)

	var creature := CardInstance.new(_creature_data(&"target", 1, 5))
	b.battlefield.append(creature)

	var bolt := CardInstance.new(_spell_data(&"bolt", 3))
	a.hand.append(bolt)

	assert_true(battle.play_card(a, bolt, creature))
	assert_eq(creature.current_toughness(), 2)
	assert_true(a.graveyard.has(bolt))
	assert_false(a.hand.has(bolt))

func test_spell_with_no_explicit_target_defaults_to_the_opponents_face() -> void:
	var a := Combatant.new(20, "A")
	a.mana = 5
	var b := Combatant.new(20, "B")
	var battle := _make_battle(a, b)

	var bolt := CardInstance.new(_spell_data(&"bolt", 4))
	a.hand.append(bolt)

	battle.play_card(a, bolt)

	assert_eq(b.life, 16)

func test_cannot_play_spell_without_enough_mana() -> void:
	var a := Combatant.new(20, "A")
	a.mana = 0
	var b := Combatant.new(20, "B")
	var battle := _make_battle(a, b)

	var bolt := CardInstance.new(_spell_data(&"bolt", 4, 3))
	a.hand.append(bolt)

	assert_false(battle.play_card(a, bolt))
	assert_true(a.hand.has(bolt), "an illegal play should not remove the card from hand")
