## The persistent game root. Holds the overworld and battle as siblings and
## swaps between them by freezing/hiding rather than reloading, so
## overworld state (player position, world flags) survives an encounter
## with zero serialization code -- see the encounter-transition design in
## docs/ROADMAP.md Phase 3.
class_name GameRoot
extends Node

const BATTLE_SCENE := preload("res://features/battle/battle.tscn")
const FADE_DURATION := 0.35

## TODO(Phase 6, content pipeline): replace with a CardDB lookup of the
## player's actual collection once one exists.
const SAMPLE_CARD_PATHS: Array[String] = [
	"res://data/cards/spark_wisp.tres",
	"res://data/cards/cloud_sentinel.tres",
	"res://data/cards/dandelion_gust.tres",
]

@onready var _overworld: Overworld = %Overworld
@onready var _battle_holder: Node = %BattleHolder
@onready var _fade: ColorRect = %Fade
@onready var _inventory_layer: CanvasLayer = %InventoryLayer
@onready var _inventory_browser: CardBrowser = %InventoryBrowser

var _battle: Battle
var _inventory_open: bool = false

func _ready() -> void:
	_overworld.encounter_triggered.connect(_on_encounter_triggered)
	_inventory_browser.mode = CardBrowser.Mode.COLLECTION

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory") and _battle == null:
		_toggle_inventory()
		get_viewport().set_input_as_handled()

func _toggle_inventory() -> void:
	_inventory_open = not _inventory_open
	_inventory_layer.visible = _inventory_open
	_overworld.process_mode = (
		Node.PROCESS_MODE_DISABLED if _inventory_open else Node.PROCESS_MODE_INHERIT
	)
	if _inventory_open:
		var cards: Array[CardData] = []
		for path in SAMPLE_CARD_PATHS:
			cards.append(load(path))
		_inventory_browser.populate(cards)
		_inventory_browser.focus_first()

func _on_encounter_triggered(enemy: Enemy) -> void:
	if _battle != null or _inventory_open:
		return
	_start_battle(BattleRequest.new(enemy.enemy_id))

func _start_battle(request: BattleRequest) -> void:
	await _fade_out()

	_overworld.process_mode = Node.PROCESS_MODE_DISABLED
	_overworld.visible = false

	_battle = BATTLE_SCENE.instantiate()
	_battle_holder.add_child(_battle)
	_battle.setup(request)
	_battle.battle_finished.connect(_on_battle_finished, CONNECT_ONE_SHOT)

	await _fade_in()

func _on_battle_finished(result: BattleResult) -> void:
	await _fade_out()

	_battle.queue_free()
	_battle = null

	_overworld.visible = true
	_overworld.process_mode = Node.PROCESS_MODE_INHERIT

	await _fade_in()

func _fade_out(duration: float = FADE_DURATION) -> void:
	var tween := create_tween()
	tween.tween_property(_fade, "color:a", 1.0, duration)
	await tween.finished

func _fade_in(duration: float = FADE_DURATION) -> void:
	var tween := create_tween()
	tween.tween_property(_fade, "color:a", 0.0, duration)
	await tween.finished
