## One entry in an EnemyData's weighted_pool: a card id and how heavily it
## should be favored by the WEIGHTED_POOL deck strategy.
class_name WeightedCardEntry
extends Resource

@export var card_id: StringName = &""
@export var weight: float = 1.0

func _init() -> void:
	pass
