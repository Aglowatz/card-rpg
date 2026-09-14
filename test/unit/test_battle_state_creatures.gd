## Creature casting, summoning sickness, combat, and destruction, driven
## entirely through BattleState's public API with no scene tree.
extends GutTest

func _creature_data(id: StringName, power: int, toughness: int) -> CardData:
	var data := CardData.new()
	data.id = id
	data.display_name = String(id)
	data.card_type = CardData.CardType.CREATURE
	data.power = power
	data.toughness = toughness
	return data

func _land_data() -> CardData:
	var data := CardData.new()
	data.id = &"land"
	data.display_name = "Land"
	data.card_type = CardData.CardType.LAND
	return data

func _make_battle(a: Combatant, b: Combatant) -> BattleState:
	var providers: Array[ChoiceProvider] = [AutoChoiceProvider.new(), AutoChoiceProvider.new()]
	var controllers: Array[EnemyController] = [null, null]
	return BattleState.new([a, b], controllers, providers)

func _advance(battle: BattleState, times: int) -> void:
	for i in times:
		battle.advance_phase()

func test_summoning_sickness_prevents_attacking_the_turn_a_creature_enters() -> void:
	var a := Combatant.new(20, "A")
	a.max_mana = 5
	var b := Combatant.new(20, "B")
	var battle := _make_battle(a, b)

	_advance(battle, 2) # UNTAP, DRAW -> now at MAIN_1
	var bear := CardInstance.new(_creature_data(&"bear", 2, 2))
	a.hand.append(bear)
	assert_true(battle.play_card(a, bear))

	_advance(battle, 4) # MAIN_1 -> COMBAT_ATTACKERS -> BLOCKERS -> DAMAGE -> MAIN_2
	assert_eq(b.life, 20, "a summoning-sick creature should not have attacked")

func test_creature_attacks_unblocked_on_a_later_turn() -> void:
	var a := Combatant.new(20, "A")
	a.max_mana = 5
	var b := Combatant.new(20, "B")
	var battle := _make_battle(a, b)

	_advance(battle, 2) # -> MAIN_1
	var bear := CardInstance.new(_creature_data(&"bear", 2, 2))
	a.hand.append(bear)
	battle.play_card(a, bear)
	_advance(battle, 7) # finish A's turn: MAIN_1..CLEANUP
	_advance(battle, 9) # all of B's turn, back to A's UNTAP
	_advance(battle, 2) # A's UNTAP, DRAW -> MAIN_1 (bear no longer summoning-sick)
	_advance(battle, 4) # MAIN_1 -> ... -> MAIN_2, bear attacks unblocked

	assert_eq(b.life, 18)

func test_blocked_combat_favorable_trade_destroys_only_the_attacker() -> void:
	var a := Combatant.new(20, "A")
	a.max_mana = 5
	var b := Combatant.new(20, "B")
	b.max_mana = 5
	var battle := _make_battle(a, b)

	# Give the attacker a creature that's already past summoning sickness by
	# placing it directly on the battlefield rather than playing it fresh.
	var attacker := CardInstance.new(_creature_data(&"attacker", 2, 3))
	attacker.summoning_sick = false
	a.battlefield.append(attacker)

	# 3 power kills the 3-toughness attacker; its 4 toughness survives the
	# attacker's 2 power -- a favorable block for the defender.
	var blocker := CardInstance.new(_creature_data(&"blocker", 3, 4))
	b.battlefield.append(blocker)

	_advance(battle, 2) # A's UNTAP, DRAW -> MAIN_1
	_advance(battle, 4) # MAIN_1 -> ... -> MAIN_2 (combat resolves)

	assert_true(attacker.is_destroyed())
	assert_true(a.graveyard.has(attacker))
	assert_false(blocker.is_destroyed())
	assert_true(b.battlefield.has(blocker))
	assert_eq(b.life, 20, "a blocked attacker should not damage the defender's face")

func test_play_land_is_limited_to_one_per_turn() -> void:
	var a := Combatant.new(20, "A")
	var b := Combatant.new(20, "B")
	var battle := _make_battle(a, b)

	_advance(battle, 2) # -> MAIN_1
	var first_land := CardInstance.new(_land_data())
	var second_land := CardInstance.new(_land_data())
	a.hand.append(first_land)
	a.hand.append(second_land)

	assert_true(battle.play_land(a, first_land))
	assert_false(battle.play_land(a, second_land))
	assert_push_error("already played a land this turn")
	assert_eq(a.max_mana, 1)
