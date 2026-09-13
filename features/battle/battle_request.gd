## What GameRoot hands to the battle scene to start an encounter. A
## Resource so it stays inspector-authorable and testable with no scene
## tree involved.
class_name BattleRequest
extends Resource

@export var enemy_id: StringName = &""

func _init(p_enemy_id: StringName = &"") -> void:
	enemy_id = p_enemy_id
