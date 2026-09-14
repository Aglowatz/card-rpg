## What the battle scene hands back to GameRoot when a battle ends.
class_name BattleResult
extends Resource

enum Outcome { VICTORY, DEFEAT, FLED }

@export var outcome: Outcome = Outcome.FLED
@export var enemy_id: StringName = &""
@export var remaining_player_life: int = 0

func _init(p_outcome: Outcome = Outcome.FLED, p_enemy_id: StringName = &"", p_remaining_player_life: int = 0) -> void:
	outcome = p_outcome
	enemy_id = p_enemy_id
	remaining_player_life = p_remaining_player_life
