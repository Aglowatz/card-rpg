## The three configurable card-selection strategies a deck-playing enemy
## can use, driven directly against a BattleState with no phase cycling
## needed (take_turn only cares that the combatant is the active one).
extends GutTest

func _creature_data(id: StringName, cost: int) -> CardData:
	var data := CardData.new()
	data.id = id
	data.card_type = CardData.CardType.CREATURE
	data.cost = cost
	data.power = 1
	data.toughness = 1
	return data

func _land_data(id: StringName) -> CardData:
	var data := CardData.new()
	data.id = id
	data.card_type = CardData.CardType.LAND
	return data

func _make_battle(enemy: Combatant, other: Combatant) -> BattleState:
	var providers: Array[ChoiceProvider] = [AutoChoiceProvider.new(), AutoChoiceProvider.new()]
	var controllers: Array[EnemyController] = [null, null]
	return BattleState.new([enemy, other], controllers, providers)

func test_deck_playing_controller_plays_a_land_before_anything_else() -> void:
	var enemy_data := EnemyData.new()
	var enemy := Combatant.new(20, "Enemy")
	var other := Combatant.new(20, "Other")
	var battle := _make_battle(enemy, other)

	enemy.hand.append(CardInstance.new(_land_data(&"land_a")))
	enemy.hand.append(CardInstance.new(_land_data(&"land_b")))

	var controller := DeckPlayingController.new(enemy_data)
	controller.take_turn(battle, enemy)

	assert_eq(enemy.max_mana, 1, "only one land should be played per turn")
	assert_eq(enemy.hand.size(), 1)

func test_random_strategy_is_deterministic_for_a_given_seed() -> void:
	var enemy_data := EnemyData.new()
	enemy_data.deck_strategy = EnemyData.DeckStrategy.RANDOM

	var results: Array[StringName] = []
	for i in 2:
		var enemy := Combatant.new(20, "Enemy")
		enemy.mana = 1
		var other := Combatant.new(20, "Other")
		var battle := _make_battle(enemy, other)
		enemy.hand.append(CardInstance.new(_creature_data(&"a", 1)))
		enemy.hand.append(CardInstance.new(_creature_data(&"b", 1)))

		var controller := DeckPlayingController.new(enemy_data)
		controller.rng.seed = 42
		controller.take_turn(battle, enemy)

		assert_eq(enemy.battlefield.size(), 1, "mana for exactly one creature should be spent")
		results.append(enemy.battlefield[0].data.id)

	assert_eq(results[0], results[1], "the same seed should make the same choice")

func test_scripted_sequence_skips_cards_not_currently_in_hand() -> void:
	var enemy_data := EnemyData.new()
	enemy_data.deck_strategy = EnemyData.DeckStrategy.SCRIPTED_SEQUENCE
	enemy_data.scripted_sequence = [&"x", &"y"]

	var enemy := Combatant.new(20, "Enemy")
	enemy.mana = 5
	var other := Combatant.new(20, "Other")
	var battle := _make_battle(enemy, other)
	enemy.hand.append(CardInstance.new(_creature_data(&"y", 1)))

	var controller := DeckPlayingController.new(enemy_data)
	controller.take_turn(battle, enemy)

	assert_eq(enemy.battlefield.size(), 1)
	assert_eq(enemy.battlefield[0].data.id, &"y")

func test_weighted_pool_plays_the_only_affordable_candidate() -> void:
	var enemy_data := EnemyData.new()
	enemy_data.deck_strategy = EnemyData.DeckStrategy.WEIGHTED_POOL
	var entry := WeightedCardEntry.new()
	entry.card_id = &"only"
	entry.weight = 1.0
	enemy_data.weighted_pool = [entry]

	var enemy := Combatant.new(20, "Enemy")
	enemy.mana = 5
	var other := Combatant.new(20, "Other")
	var battle := _make_battle(enemy, other)
	enemy.hand.append(CardInstance.new(_creature_data(&"only", 1)))

	var controller := DeckPlayingController.new(enemy_data)
	controller.take_turn(battle, enemy)

	assert_eq(enemy.battlefield.size(), 1)
	assert_eq(enemy.battlefield[0].data.id, &"only")
