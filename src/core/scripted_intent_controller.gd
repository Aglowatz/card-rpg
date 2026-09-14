## Plays a puzzle/boss enemy's turn from a fixed, looping intent sequence
## instead of a deck -- no hand, no mana, the intent's effects just
## resolve. Intents target the opponent's face by default, since they're
## authored for a specific scripted fight rather than needing general
## targeting logic.
class_name ScriptedIntentController
extends EnemyController

var enemy_data: EnemyData
var _intent_index: int = 0

func _init(p_enemy_data: EnemyData) -> void:
	enemy_data = p_enemy_data

func take_turn(battle: BattleState, combatant: Combatant) -> void:
	if enemy_data.intent_sequence.is_empty():
		return

	var intent := enemy_data.intent_sequence[_intent_index]
	_intent_index = (_intent_index + 1) % enemy_data.intent_sequence.size()

	if intent.summon != null:
		var creature := CardInstance.new(intent.summon)
		creature.summoning_sick = true
		combatant.battlefield.append(creature)
		return

	var target: Damageable = battle.opponent_of(combatant)
	var ctx := EffectContext.new(null, target)
	for effect in intent.effects:
		effect.resolve(ctx)
