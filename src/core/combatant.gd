## One side of a battle: a life total, a growing mana pool fed by lands,
## and the four zones a card moves through. Damageable so a spell can hit
## a combatant's face the same way it hits a creature.
class_name Combatant
extends Damageable

const MAX_MANA: int = 10

var display_name: String = ""
var life: int
var max_mana: int = 0
var mana: int = 0
var has_played_land_this_turn: bool = false

var library: Array[CardInstance] = []
var hand: Array[CardInstance] = []
var battlefield: Array[CardInstance] = []
var graveyard: Array[CardInstance] = []

func _init(p_life: int = 20, p_display_name: String = "") -> void:
	life = p_life
	display_name = p_display_name

## Moves the top of the library into hand. A no-op (not fatigue damage) if
## the library is empty -- deck-out punishment is a future card-effect
## concern, not a base rule for v1.
func draw_card() -> void:
	if library.is_empty():
		return
	hand.append(library.pop_back())

func gain_land_mana() -> void:
	max_mana = mini(max_mana + 1, MAX_MANA)

func refill_mana() -> void:
	mana = max_mana

func take_damage(amount: int) -> void:
	life -= amount

func is_defeated() -> bool:
	return life <= 0
