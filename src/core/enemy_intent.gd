## One step in a ScriptedIntentController's sequence: either a set of
## effects that just happen on that enemy's turn, or a creature to summon
## directly onto its battlefield -- an intent does one or the other, never
## both. `label` is reserved for a future telegraph UI (showing the player
## what's coming before it resolves).
class_name EnemyIntent
extends Resource

@export var label: String = ""
@export var effects: Array[Effect] = []
## When set, this intent summons a copy of this CREATURE card onto the
## controller's battlefield instead of resolving effects.
@export var summon: CardData = null

func _init() -> void:
	pass
