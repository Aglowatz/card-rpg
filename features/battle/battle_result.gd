## What the battle scene hands back to GameRoot when a battle ends.
class_name BattleResult
extends Resource

enum Outcome { VICTORY, DEFEAT, FLED }

@export var outcome: Outcome = Outcome.FLED
@export var enemy_id: StringName = &""

func _init(p_outcome: Outcome = Outcome.FLED, p_enemy_id: StringName = &"") -> void:
	outcome = p_outcome
	enemy_id = p_enemy_id
