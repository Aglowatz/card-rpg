## The real battle screen, driven by BattleState. The player's only
## interactive decisions are which cards to play during their own MAIN_1 --
## combat (attacking, blocking, and spell targeting) uses AutoChoiceProvider
## on both sides for now, since a click-to-attack/block UI is future
## presentation polish, not part of proving the engine works end to end.
class_name Battle
extends Control

signal battle_finished(result: BattleResult)

## TODO(Phase 6, content pipeline): replace with a CardDB-driven deck once
## deckbuilding exists. This is every playable card in the demo pool.
const STARTER_DECK_PATHS: Array[String] = [
	"res://data/cards/mossy_bank.tres",
	"res://data/cards/mossy_bank.tres",
	"res://data/cards/sunken_stair.tres",
	"res://data/cards/spellbound_swordsman.tres",
	"res://data/cards/isle_magician.tres",
	"res://data/cards/tangled_root.tres",
	"res://data/cards/candle_wisp.tres",
	"res://data/cards/emberwick_bolt.tres",
	"res://data/cards/bramble_lash.tres",
	"res://data/cards/arc_conjurer.tres",
	"res://data/cards/spike_crawler.tres",
	"res://data/cards/cloud_sentinel.tres",
]

@onready var _header: Label = %HeaderLabel
@onready var _status_label: Label = %StatusLabel
@onready var _browser: CardBrowser = %CardBrowser
@onready var _end_turn_button: Button = %EndTurnButton
@onready var _flee_button: Button = %FleeButton

var _request: BattleRequest
var _battle: BattleState
var _player: Combatant
var _enemy: Combatant

func _ready() -> void:
	_browser.mode = CardBrowser.Mode.BATTLE_BROWSE
	_browser.card_chosen.connect(_on_card_chosen)
	_end_turn_button.pressed.connect(_on_end_turn_pressed)
	_flee_button.pressed.connect(_on_flee_pressed)

## Inbound API, called by GameRoot after instancing this scene.
func setup(request: BattleRequest) -> void:
	_request = request

	var enemy_data: EnemyData = load("res://data/enemies/%s.tres" % request.enemy_id)
	_header.text = "Battle vs. %s" % enemy_data.display_name

	_player = Combatant.new(request.player_life, "Player")
	for path in STARTER_DECK_PATHS:
		_player.library.append(CardInstance.new(load(path)))
	_player.library.shuffle()
	for i in 4:
		_player.draw_card()

	_enemy = Combatant.new(enemy_data.starting_life, enemy_data.display_name)
	var controller: EnemyController = null
	if enemy_data.controller_type == EnemyData.ControllerType.DECK:
		for card_data in enemy_data.deck:
			_enemy.library.append(CardInstance.new(card_data))
		_enemy.library.shuffle()
		for i in 4:
			_enemy.draw_card()
		controller = DeckPlayingController.new(enemy_data)
	else:
		controller = ScriptedIntentController.new(enemy_data)

	var providers: Array[ChoiceProvider] = [AutoChoiceProvider.new(), AutoChoiceProvider.new()]
	var controllers: Array[EnemyController] = [null, controller]
	_battle = BattleState.new([_player, _enemy], controllers, providers)

	_refresh()

func _on_card_chosen(card_data: CardData) -> void:
	if _battle.is_over() or _battle.active_combatant() != _player:
		return

	var instance := _find_in_hand(card_data)
	if instance == null:
		return

	if card_data.card_type == CardData.CardType.LAND:
		_battle.play_land(_player, instance)
	else:
		_battle.play_card(_player, instance)

	_refresh()
	_check_for_battle_end()

func _on_end_turn_pressed() -> void:
	if _battle.is_over():
		return
	# Advance through the rest of the player's turn, the whole enemy turn,
	# and the player's next untap/draw, stopping right when the player has
	# a fresh MAIN_1 to act in (or the battle ends along the way).
	while not _battle.is_over() and not (_battle.active_combatant() == _player and _battle.phase == BattleState.Phase.MAIN_1):
		_battle.advance_phase()

	_refresh()
	_check_for_battle_end()

func _on_flee_pressed() -> void:
	_finish(BattleResult.Outcome.FLED)

func _find_in_hand(card_data: CardData) -> CardInstance:
	for card in _player.hand:
		if card.data == card_data:
			return card
	return null

func _refresh() -> void:
	_status_label.text = "%s: %d life        %s: %d life" % [
		_player.display_name, _player.life,
		_enemy.display_name, _enemy.life,
	]
	var hand_cards: Array[CardData] = []
	for card in _player.hand:
		hand_cards.append(card.data)
	_browser.populate(hand_cards)
	_browser.focus_first()

func _check_for_battle_end() -> void:
	if not _battle.is_over():
		return
	var outcome := BattleResult.Outcome.VICTORY if _battle.winner() == _player else BattleResult.Outcome.DEFEAT
	_finish(outcome)

func _finish(outcome: BattleResult.Outcome) -> void:
	var life := _player.life if _player else _request.player_life
	battle_finished.emit(BattleResult.new(outcome, _request.enemy_id, maxi(life, 0)))
