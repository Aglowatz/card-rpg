## A puzzle/boss enemy's fixed intent sequence: no deck, no mana, effects
## just resolve in order and loop -- the alternative to DeckPlayingController
## for scripted encounters.
extends GutTest

func _damage_intent(label: String, amount: int) -> EnemyIntent:
	var intent := EnemyIntent.new()
	intent.label = label
	intent.effects = [DealDamage.new(amount)]
	return intent

func _make_battle(enemy: Combatant, other: Combatant) -> BattleState:
	var providers: Array[ChoiceProvider] = [AutoChoiceProvider.new(), AutoChoiceProvider.new()]
	var controllers: Array[EnemyController] = [null, null]
	return BattleState.new([enemy, other], controllers, providers)

func test_intent_sequence_executes_in_order_and_loops() -> void:
	var enemy_data := EnemyData.new()
	enemy_data.intent_sequence = [_damage_intent("big", 5), _damage_intent("small", 1)]

	var enemy := Combatant.new(20, "Enemy")
	var other := Combatant.new(20, "Other")
	var battle := _make_battle(enemy, other)
	var controller := ScriptedIntentController.new(enemy_data)

	controller.take_turn(battle, enemy)
	assert_eq(other.life, 15, "the first intent should deal 5")

	controller.take_turn(battle, enemy)
	assert_eq(other.life, 14, "the second intent should deal 1")

	controller.take_turn(battle, enemy)
	assert_eq(other.life, 9, "the sequence should loop back to the first intent")

func test_summon_intent_puts_a_creature_on_the_battlefield_instead_of_dealing_damage() -> void:
	var creature_data := CardData.new()
	creature_data.id = &"golem"
	creature_data.card_type = CardData.CardType.CREATURE
	creature_data.power = 3
	creature_data.toughness = 5

	var summon_intent := EnemyIntent.new()
	summon_intent.label = "Summoning a guardian"
	summon_intent.summon = creature_data

	var enemy_data := EnemyData.new()
	enemy_data.intent_sequence = [summon_intent, _damage_intent("jab", 2)]

	var enemy := Combatant.new(20, "Enemy")
	var other := Combatant.new(20, "Other")
	var battle := _make_battle(enemy, other)
	var controller := ScriptedIntentController.new(enemy_data)

	controller.take_turn(battle, enemy)
	assert_eq(enemy.battlefield.size(), 1, "the summon intent should add a creature")
	assert_eq(enemy.battlefield[0].data.id, &"golem")
	assert_true(enemy.battlefield[0].summoning_sick)
	assert_eq(other.life, 20, "a summon intent should not also deal damage")

	controller.take_turn(battle, enemy)
	assert_eq(other.life, 18, "the alternating damage intent should still fire on the next turn")
	assert_eq(enemy.battlefield.size(), 1, "the damage intent should not summon a second creature")

func test_empty_intent_sequence_is_a_safe_no_op() -> void:
	var enemy_data := EnemyData.new()
	var enemy := Combatant.new(20, "Enemy")
	var other := Combatant.new(20, "Other")
	var battle := _make_battle(enemy, other)

	ScriptedIntentController.new(enemy_data).take_turn(battle, enemy)

	assert_eq(other.life, 20)
