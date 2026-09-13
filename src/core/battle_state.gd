## Orchestrates one battle between two Combatants: the turn/phase state
## machine, playing lands and cards, and combat resolution. No Node, no
## Texture2D, no await -- runnable and assertable from a GUT test with no
## window opened, per the architectural law in CLAUDE.md.
##
## A combatant with a null EnemyController is driven manually: a caller
## (a test today, real UI in Phase 5) calls play_land()/play_card()
## directly during that combatant's main phases, then calls
## advance_phase() to move on. A combatant with a controller has its
## whole turn played automatically when its main phase is reached.
class_name BattleState
extends RefCounted

enum Phase {
	UNTAP,
	DRAW,
	MAIN_1,
	COMBAT_ATTACKERS,
	COMBAT_BLOCKERS,
	COMBAT_DAMAGE,
	MAIN_2,
	END,
	CLEANUP,
}

var phase: Phase = Phase.UNTAP
var turn_number: int = 1
var active_index: int = 0

var _combatants: Array[Combatant]
var _controllers: Array[EnemyController]
var _choice_providers: Array[ChoiceProvider]

var _current_attackers: Array[CardInstance] = []
var _current_blocks: Array[BlockAssignment] = []

var _battle_over: bool = false
var _winner: Combatant

func _init(
	p_combatants: Array[Combatant],
	p_controllers: Array[EnemyController],
	p_choice_providers: Array[ChoiceProvider],
) -> void:
	_combatants = p_combatants
	_controllers = p_controllers
	_choice_providers = p_choice_providers

func active_combatant() -> Combatant:
	return _combatants[active_index]

func opponent_of(combatant: Combatant) -> Combatant:
	return _combatants[1] if combatant == _combatants[0] else _combatants[0]

func is_over() -> bool:
	return _battle_over

func winner() -> Combatant:
	return _winner

## Attempts to play a land from the combatant's hand. Returns false (and
## logs why) if the play is illegal.
func play_land(combatant: Combatant, card: CardInstance) -> bool:
	if _battle_over or combatant != active_combatant():
		push_error("play_land: not this combatant's turn")
		return false
	if card.data.card_type != CardData.CardType.LAND:
		push_error("play_land: %s is not a land" % card.data.display_name)
		return false
	if not combatant.hand.has(card):
		push_error("play_land: card not in hand")
		return false
	if combatant.has_played_land_this_turn:
		push_error("play_land: already played a land this turn")
		return false

	combatant.hand.erase(card)
	combatant.gain_land_mana()
	combatant.has_played_land_this_turn = true
	return true

## Attempts to cast a creature or spell from the combatant's hand. `target`
## is only used by spells; when omitted, the combatant's ChoiceProvider
## picks among the opponent's face and battlefield creatures.
func play_card(combatant: Combatant, card: CardInstance, target: Damageable = null) -> bool:
	if _battle_over or combatant != active_combatant():
		push_error("play_card: not this combatant's turn")
		return false
	if card.data.card_type == CardData.CardType.LAND:
		push_error("play_card: use play_land() for lands")
		return false
	if not combatant.hand.has(card):
		push_error("play_card: card not in hand")
		return false
	if combatant.mana < card.data.cost:
		push_error("play_card: not enough mana for %s" % card.data.display_name)
		return false

	combatant.mana -= card.data.cost
	combatant.hand.erase(card)

	if card.data.card_type == CardData.CardType.CREATURE:
		card.tapped = false
		card.summoning_sick = true
		combatant.battlefield.append(card)
	else:
		var resolved_target := target
		if resolved_target == null:
			resolved_target = _choice_providers[_index_of(combatant)].choose_target(
				_valid_spell_targets(combatant)
			)
		var ctx := EffectContext.new(card, resolved_target)
		for effect in card.data.effects:
			effect.resolve(ctx)
		combatant.graveyard.append(card)
		_check_state_based_actions()

	return true

## Runs the current phase's automatic work, then moves to the next phase.
func advance_phase() -> void:
	if _battle_over:
		return

	match phase:
		Phase.UNTAP:
			var combatant := active_combatant()
			for creature in combatant.battlefield:
				creature.tapped = false
				creature.summoning_sick = false
			combatant.has_played_land_this_turn = false
			combatant.refill_mana()
			phase = Phase.DRAW
		Phase.DRAW:
			active_combatant().draw_card()
			phase = Phase.MAIN_1
		Phase.MAIN_1:
			_run_controller_turn()
			phase = Phase.COMBAT_ATTACKERS
		Phase.COMBAT_ATTACKERS:
			_declare_attackers()
			phase = Phase.COMBAT_BLOCKERS
		Phase.COMBAT_BLOCKERS:
			_declare_blockers()
			phase = Phase.COMBAT_DAMAGE
		Phase.COMBAT_DAMAGE:
			_resolve_combat_damage()
			phase = Phase.MAIN_2
		Phase.MAIN_2:
			_run_controller_turn()
			phase = Phase.END
		Phase.END:
			phase = Phase.CLEANUP
		Phase.CLEANUP:
			active_index = 1 - active_index
			turn_number += 1
			phase = Phase.UNTAP

func _run_controller_turn() -> void:
	var controller := _controllers[active_index]
	if controller != null:
		controller.take_turn(self, active_combatant())
		_check_state_based_actions()

func _declare_attackers() -> void:
	var combatant := active_combatant()
	var eligible: Array[CardInstance] = []
	for creature in combatant.battlefield:
		if creature.data.card_type == CardData.CardType.CREATURE and not creature.tapped and not creature.summoning_sick:
			eligible.append(creature)

	_current_attackers = _choice_providers[active_index].choose_attackers(eligible)
	for attacker in _current_attackers:
		attacker.tapped = true

func _declare_blockers() -> void:
	if _current_attackers.is_empty():
		_current_blocks = []
		return

	var defender_index := 1 - active_index
	var defender := _combatants[defender_index]
	var eligible: Array[CardInstance] = []
	for creature in defender.battlefield:
		if creature.data.card_type == CardData.CardType.CREATURE and not creature.tapped:
			eligible.append(creature)

	_current_blocks = _choice_providers[defender_index].choose_blockers(_current_attackers, eligible)

func _resolve_combat_damage() -> void:
	var defender := _combatants[1 - active_index]
	for attacker in _current_attackers:
		var block := _find_block_for(attacker)
		if block != null:
			attacker.take_damage(block.blocker.data.power)
			block.blocker.take_damage(attacker.data.power)
		else:
			defender.take_damage(attacker.data.power)

	_current_attackers = []
	_current_blocks = []
	_check_state_based_actions()

func _find_block_for(attacker: CardInstance) -> BlockAssignment:
	for block in _current_blocks:
		if block.attacker == attacker:
			return block
	return null

func _valid_spell_targets(combatant: Combatant) -> Array[Damageable]:
	var opponent := opponent_of(combatant)
	var targets: Array[Damageable] = [opponent]
	for creature in opponent.battlefield:
		targets.append(creature)
	return targets

func _index_of(combatant: Combatant) -> int:
	return 0 if combatant == _combatants[0] else 1

func _check_state_based_actions() -> void:
	for combatant in _combatants:
		var survivors: Array[CardInstance] = []
		for creature in combatant.battlefield:
			if creature.is_defeated():
				combatant.graveyard.append(creature)
			else:
				survivors.append(creature)
		combatant.battlefield = survivors

	if _battle_over:
		return
	for combatant in _combatants:
		if combatant.is_defeated():
			_battle_over = true
			_winner = opponent_of(combatant)
			return
