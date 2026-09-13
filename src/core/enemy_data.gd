## Per-enemy battle configuration, authored as a .tres in data/enemies/.
## Mirrors the CardData split between script (here, in src/core/) and
## instance data (in data/). Two independent controller modes: most
## enemies play from a real deck with a configurable card-choice
## algorithm; puzzle and boss encounters instead run a fully scripted,
## telegraphable intent sequence with no deck at all.
class_name EnemyData
extends Resource

enum ControllerType { DECK, SCRIPTED_INTENT }
enum DeckStrategy { RANDOM, SCRIPTED_SEQUENCE, WEIGHTED_POOL }

@export var enemy_id: StringName = &""
@export var display_name: String = ""
@export var starting_life: int = 20
@export var controller_type: ControllerType = ControllerType.DECK

## DECK mode.
@export var deck: Array[CardData] = []
@export var deck_strategy: DeckStrategy = DeckStrategy.RANDOM
## Card ids, in order, walked across the whole battle (not reset per
## turn) -- ids not currently castable are skipped, not repeated.
@export var scripted_sequence: Array[StringName] = []
@export var weighted_pool: Array[WeightedCardEntry] = []

## SCRIPTED_INTENT mode.
@export var intent_sequence: Array[EnemyIntent] = []

func _init() -> void:
	pass
