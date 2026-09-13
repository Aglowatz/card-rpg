## A world enemy: touching it triggers a battle. A separate interact area
## is reserved for future vendors/NPCs/passive enemies that should use a
## press-to-interact prompt instead of touch-triggering -- see the
## touch-to-battle hard requirement in CLAUDE.md.
class_name Enemy
extends CharacterBody3D

signal encounter_triggered(enemy: Enemy)

@export var enemy_id: StringName = &"slime_enemy"

@onready var _sprite: Sprite3D = %Sprite3D
@onready var _touch_area: Area3D = %TouchArea

func _ready() -> void:
	SpriteDefaults.configure(_sprite, ArtRegistry.sprite(enemy_id))
	_touch_area.body_entered.connect(_on_touch_area_body_entered)

func _on_touch_area_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	# Debounce: stop monitoring immediately so a lingering overlap can't
	# fire a second encounter while the battle transition is in flight.
	_touch_area.set_deferred("monitoring", false)
	encounter_triggered.emit(self)
