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

func test_empty_intent_sequence_is_a_safe_no_op() -> void:
	var enemy_data := EnemyData.new()
	var enemy := Combatant.new(20, "Enemy")
	var other := Combatant.new(20, "Other")
	var battle := _make_battle(enemy, other)

	ScriptedIntentController.new(enemy_data).take_turn(battle, enemy)

	assert_eq(other.life, 20)
