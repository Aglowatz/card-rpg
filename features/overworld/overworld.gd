## The 3D overworld root. Forwards enemy encounters and vendor
## interactions upward; GameRoot decides what happens with them (see
## features/ui/main.gd).
class_name Overworld
extends Node3D

signal encounter_triggered(enemy: Enemy)
signal vendor_interacted(vendor: Node3D)

@onready var _enemies: Array[Enemy] = [%ForestEnemy, %DungeonEnemy]
@onready var _player: Player = $Player

func _ready() -> void:
	for enemy in _enemies:
		enemy.encounter_triggered.connect(_on_enemy_encounter_triggered)
	_player.interact_requested.connect(_on_player_interact_requested)

func _on_enemy_encounter_triggered(enemy: Enemy) -> void:
	encounter_triggered.emit(enemy)

func _on_player_interact_requested(target: Node3D) -> void:
	if target.is_in_group("vendor"):
		vendor_interacted.emit(target)
