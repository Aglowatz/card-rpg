## One declared block: this creature is blocking that attacker.
class_name BlockAssignment
extends RefCounted

var attacker: CardInstance
var blocker: CardInstance

func _init(p_attacker: CardInstance, p_blocker: CardInstance) -> void:
	attacker = p_attacker
	blocker = p_blocker
