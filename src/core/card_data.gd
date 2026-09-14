## The immutable template for a card, authored as a .tres Resource.
##
## CardData never holds mutable per-copy state (current damage, temporary
## buffs, etc.) — that lives on CardInstance instead. Godot caches loaded
## resources, so load("res://data/cards/x.tres") always returns the SAME
## object; mutating a CardData in place would corrupt every copy of that
## card at once.
##
## Custom Resources need a parameterless _init() or they fail to load in
## the Inspector.
class_name CardData
extends Resource

## CREATURE cards use power/toughness and fight on the battlefield.
## SPELL cards use effects, resolving once against a chosen target, then go
## to the graveyard. LAND cards use neither -- playing one just permanently
## increases the controller's max mana.
enum CardType { CREATURE, LAND, SPELL }

@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var rules_text: String = ""
@export var card_type: CardType = CardType.CREATURE
@export var cost: int = 0
@export var power: int = 0
@export var toughness: int = 1
@export var effects: Array[Effect] = []
## Set directly per-card in its .tres -- several cards may share one
## underlying image where thematically apt. Null is fine; Card renders
## without an art panel until one is set, per the art law's placeholder
## rule.
@export var art: Texture2D = null

func _init() -> void:
	pass
