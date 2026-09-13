## Everything an Effect needs to resolve, bundled into one value object.
##
## Deliberately holds no Node references and no Texture2D references, so it
## can be constructed and passed around entirely inside src/core/ tests
## with no scene tree involved. Target is Damageable rather than
## CardInstance so a spell can hit either a creature or a combatant's face
## through one typed interface.
class_name EffectContext
extends RefCounted

var source: CardInstance
var target: Damageable
var resolution_log: Array[String] = []

func _init(p_source: CardInstance = null, p_target: Damageable = null) -> void:
	source = p_source
	target = p_target

func append_log(entry: String) -> void:
	resolution_log.append(entry)
