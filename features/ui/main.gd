## The persistent game root. Holds the overworld and battle as siblings and
## swaps between them by freezing/hiding rather than reloading, so
## overworld state (player position, world flags) survives an encounter
## with zero serialization code -- see the encounter-transition design in
## docs/ROADMAP.md Phase 3.
class_name GameRoot
extends Node

const BATTLE_SCENE := preload("res://features/battle/battle.tscn")
const FADE_DURATION := 0.35
const MAX_PLAYER_LIFE := 20

## TODO(Phase 6, content pipeline): replace with a CardDB lookup of the
## player's actual collection once one exists. For now this is every
## playable card in the demo pool.
const ALL_CARD_PATHS: Array[String] = [
	"res://data/cards/arc_conjurer.tres",
	"res://data/cards/cloud_sentinel.tres",
	"res://data/cards/dandelion_gust.tres",
	"res://data/cards/drifting_isle.tres",
	"res://data/cards/isle_magician.tres",
	"res://data/cards/mossy_bank.tres",
	"res://data/cards/spark_wisp.tres",
	"res://data/cards/spellbound_swordsman.tres",
	"res://data/cards/sunken_stair.tres",
	"res://data/cards/veteran_blade.tres",
]

@onready var _overworld: Overworld = %Overworld
@onready var _battle_holder: Node = %BattleHolder
@onready var _fade: ColorRect = %Fade
@onready var _inventory_layer: CanvasLayer = %InventoryLayer
@onready var _inventory_browser: CardBrowser = %InventoryBrowser

var _battle: Battle
var _inventory_open: bool = false
var _player_life: int = MAX_PLAYER_LIFE

func _ready() -> void:
	_overworld.encounter_triggered.connect(_on_encounter_triggered)
	_overworld.vendor_interacted.connect(_on_vendor_interacted)
	_inventory_browser.mode = CardBrowser.Mode.COLLECTION

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory") and _battle == null and not _inventory_open:
		_open_inventory("Collection")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("toggle_inventory") and _inventory_open:
		_close_inventory()
		get_viewport().set_input_as_handled()

func _on_vendor_interacted(vendor: Node3D) -> void:
	if _battle != null or _inventory_open:
		return
	_open_inventory("Card Vendor")

func _open_inventory(title: String) -> void:
	_inventory_open = true
	_inventory_layer.visible = true
	_overworld.process_mode = Node.PROCESS_MODE_DISABLED

	var cards: Array[CardData] = []
	for path in ALL_CARD_PATHS:
		cards.append(load(path))
	_inventory_browser.set_title(title)
	_inventory_browser.populate(cards)
	_inventory_browser.focus_first()

func _close_inventory() -> void:
	_inventory_open = false
	_inventory_layer.visible = false
	_overworld.process_mode = Node.PROCESS_MODE_INHERIT

func _on_encounter_triggered(enemy: Enemy) -> void:
	if _battle != null or _inventory_open:
		return
	_start_battle(BattleRequest.new(enemy.enemy_id, _player_life))

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

	_player_life = result.remaining_player_life
	# Defeat is a setback, not a campaign reset: full heal and back to town,
	# per the "death is a setback within a dungeon" rule in CLAUDE.md. There
	# is no real checkpoint system yet -- this is a minimal stand-in for one.
	if result.outcome == BattleResult.Outcome.DEFEAT:
		_player_life = MAX_PLAYER_LIFE
		var player: Node3D = _overworld.get_node("Player")
		player.global_position = Vector3.ZERO

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
