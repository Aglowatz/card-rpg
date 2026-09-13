## One step in a ScriptedIntentController's sequence: a set of effects that
## just happen on that enemy's turn, plus a label reserved for a future
## telegraph UI (showing the player what's coming before it resolves).
class_name EnemyIntent
extends Resource

@export var label: String = ""
@export var effects: Array[Effect] = []

func _init() -> void:
	pass
