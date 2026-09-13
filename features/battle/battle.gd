## Stub battle screen. Stands in for the real combat engine (a later
## phase): shows the card inventory component in battle-browse mode and
## resolves immediately via Win/Lose/Flee. Proves the encounter transition,
## overworld state preservation, and CardBrowser reuse end to end before
## the real engine exists.
class_name Battle
extends Control

signal battle_finished(result: BattleResult)

const SAMPLE_CARD_PATHS: Array[String] = [
	"res://data/cards/spark_wisp.tres",
	"res://data/cards/cloud_sentinel.tres",
	"res://data/cards/dandelion_gust.tres",
]

@onready var _header: Label = %HeaderLabel
@onready var _browser: CardBrowser = %CardBrowser
@onready var _win_button: Button = %WinButton
@onready var _lose_button: Button = %LoseButton
@onready var _flee_button: Button = %FleeButton

var _request: BattleRequest

func _ready() -> void:
	_browser.mode = CardBrowser.Mode.BATTLE_BROWSE
	_win_button.pressed.connect(_on_win_pressed)
	_lose_button.pressed.connect(_on_lose_pressed)
	_flee_button.pressed.connect(_on_flee_pressed)

## Inbound API, called by GameRoot after instancing this scene.
func setup(request: BattleRequest) -> void:
	_request = request
	_header.text = "Battle vs. %s" % request.enemy_id

	var cards: Array[CardData] = []
	for path in SAMPLE_CARD_PATHS:
		cards.append(load(path))
	_browser.populate(cards)
	_browser.focus_first()

func _on_win_pressed() -> void:
	_finish(BattleResult.Outcome.VICTORY)

func _on_lose_pressed() -> void:
	_finish(BattleResult.Outcome.DEFEAT)

func _on_flee_pressed() -> void:
	_finish(BattleResult.Outcome.FLED)

func _finish(outcome: BattleResult.Outcome) -> void:
	battle_finished.emit(BattleResult.new(outcome, _request.enemy_id))
