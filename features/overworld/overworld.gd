## The 3D overworld root. Forwards enemy encounters upward; GameRoot decides
## what happens with them (see features/ui/main.gd).
class_name Overworld
extends Node3D

signal encounter_triggered(enemy: Enemy)

@onready var _enemies: Array[Enemy] = [%Enemy]

func _ready() -> void:
	for enemy in _enemies:
		enemy.encounter_triggered.connect(_on_enemy_encounter_triggered)

func _on_enemy_encounter_triggered(enemy: Enemy) -> void:
	encounter_triggered.emit(enemy)
