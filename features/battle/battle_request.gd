## What GameRoot hands to the battle scene to start an encounter. A
## Resource so it stays inspector-authorable and testable with no scene
## tree involved.
class_name BattleRequest
extends Resource

@export var enemy_id: StringName = &""
## The player's life total carried in from the overworld, per the
## constitution's "death is a setback within a dungeon" rule -- battles
## are not independent, life persists across them.
@export var player_life: int = 20

func _init(p_enemy_id: StringName = &"", p_player_life: int = 20) -> void:
	enemy_id = p_enemy_id
	player_life = p_player_life
