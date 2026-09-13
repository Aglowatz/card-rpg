## Everything an Effect needs to resolve, bundled into one value object.
##
## Deliberately holds no Node references and no Texture2D references, so it
## can be constructed and passed around entirely inside src/core/ tests
## with no scene tree involved.
class_name EffectContext
extends RefCounted

var source: CardInstance
var target: CardInstance
var resolution_log: Array[String] = []

func _init(p_source: CardInstance = null, p_target: CardInstance = null) -> void:
	source = p_source
	target = p_target

## Effects call this instead of touching a target's stats directly, so the
## damage math stays in one place and is easy to unit test in isolation.
func deal_damage(recipient: CardInstance, amount: int) -> void:
	recipient.damage_taken += amount
	resolution_log.append("%s deals %d damage to %s" % [
		source.data.display_name if source else "unknown",
		amount,
		recipient.data.display_name,
	])
