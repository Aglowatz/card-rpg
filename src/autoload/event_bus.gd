## Global signal bus. No state lives here — only signals.
##
## Systems that need to react to something happening elsewhere in the game
## connect to a signal here instead of reaching into another node directly.
extends Node

signal card_hovered(card_id: StringName)
signal card_unhovered(card_id: StringName)
signal card_clicked(card_id: StringName)
signal effect_resolved(effect_description: String)
