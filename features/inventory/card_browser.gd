## Reusable master-detail card inventory: a scrollable row list plus a
## focus-driven detail preview. Used both as a full-screen collection
## browser in the overworld and embedded in the battle screen -- the same
## scene, parameterized by `mode` -- per the reusable-inventory hard
## requirement in CLAUDE.md.
class_name CardBrowser
extends Control

const CARD_SCENE := preload("res://features/inventory/card.tscn")

enum Mode { COLLECTION, BATTLE_BROWSE }

signal card_highlighted(card: CardData)
signal card_chosen(card: CardData)

@export var mode: Mode = Mode.COLLECTION:
	set(value):
		mode = value
		if is_node_ready():
			_apply_mode()

@onready var _list_vbox: VBoxContainer = %ListVBox
@onready var _scroll: ScrollContainer = %Scroll
@onready var _detail_card: Card = %DetailCard
@onready var _filter_bar: Control = %FilterBar
@onready var _action_button: Button = %ActionButton

var _rows: Array[Card] = []
var _selected: CardData

func _ready() -> void:
	_scroll.follow_focus = true
	_action_button.pressed.connect(_on_action_button_pressed)
	_apply_mode()

## Inbound API: replace the list contents.
func populate(cards: Array[CardData]) -> void:
	for row in _rows:
		row.queue_free()
	_rows.clear()
	_selected = null
	_detail_card.data = null

	for card_data in cards:
		var row: Card = CARD_SCENE.instantiate()
		_list_vbox.add_child(row)
		row.data = card_data
		row.focus_mode = Control.FOCUS_ALL
		row.focus_entered.connect(_on_row_focused.bind(row))
		_rows.append(row)

	_link_focus_chain()
	if not _rows.is_empty():
		_on_row_focused(_rows[0])

## Inbound API: give keyboard/gamepad focus to the first row.
func focus_first() -> void:
	if not _rows.is_empty():
		_rows[0].grab_focus.call_deferred()

func _link_focus_chain() -> void:
	for i in _rows.size():
		var row := _rows[i]
		row.focus_neighbor_top = row.get_path_to(_rows[maxi(i - 1, 0)])
		row.focus_neighbor_bottom = row.get_path_to(_rows[mini(i + 1, _rows.size() - 1)])

func _on_row_focused(row: Card) -> void:
	_selected = row.data
	_detail_card.data = row.data
	card_highlighted.emit(row.data)
	_scroll.ensure_control_visible(row)

func _on_action_button_pressed() -> void:
	if _selected:
		card_chosen.emit(_selected)

func _apply_mode() -> void:
	match mode:
		Mode.COLLECTION:
			_filter_bar.visible = true
			_action_button.text = "Inspect"
		Mode.BATTLE_BROWSE:
			_filter_bar.visible = false
			_action_button.text = "Play"
