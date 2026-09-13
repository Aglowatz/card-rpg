## Renders a single CardData. All visuals are procedural StyleBoxFlat /
## Label nodes — no image assets. Presentation only; no game logic lives
## here beyond forwarding input to the EventBus.
class_name Card
extends PanelContainer

const PANEL_COLOR := Color("2c2440")
const ACCENT_COLOR := Color("ffd23f")

@export var data: CardData:
	set(value):
		data = value
		_refresh()

@onready var _name_label: Label = %NameLabel
@onready var _cost_label: Label = %CostLabel
@onready var _rules_label: Label = %RulesLabel
@onready var _stats_label: Label = %StatsLabel

func _ready() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL_COLOR
	style.border_color = ACCENT_COLOR
	style.set_border_width_all(3)
	style.set_corner_radius_all(22)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	add_theme_stylebox_override("panel", style)

	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)

	_refresh()

func _refresh() -> void:
	if not is_node_ready() or data == null:
		return
	_name_label.text = data.display_name
	_cost_label.text = str(data.cost)
	_rules_label.text = data.rules_text
	_stats_label.text = "%d / %d" % [data.power, data.toughness]

func _on_mouse_entered() -> void:
	if data:
		EventBus.card_hovered.emit(data.id)

func _on_mouse_exited() -> void:
	if data:
		EventBus.card_unhovered.emit(data.id)

func _on_gui_input(event: InputEvent) -> void:
	var mouse_event := event as InputEventMouseButton
	if data and mouse_event and mouse_event.pressed:
		EventBus.card_clicked.emit(data.id)
