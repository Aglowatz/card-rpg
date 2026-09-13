## Hello-world scene: loads three CardData resources into a hand and wires
## their signals through the EventBus, proving the whole pipeline connects.
extends Control

const CARD_SCENE := preload("res://features/card/card.tscn")

const CARD_PATHS: Array[String] = [
	"res://data/cards/spark_wisp.tres",
	"res://data/cards/cloud_sentinel.tres",
	"res://data/cards/dandelion_gust.tres",
]

@onready var _hand: HBoxContainer = %Hand
@onready var _status_label: Label = %StatusLabel

func _ready() -> void:
	for path: String in CARD_PATHS:
		var data: CardData = load(path)
		var card: Card = CARD_SCENE.instantiate()
		_hand.add_child(card)
		card.data = data

	EventBus.card_hovered.connect(_on_card_hovered)
	EventBus.card_clicked.connect(_on_card_clicked)

func _on_card_hovered(card_id: StringName) -> void:
	_status_label.text = "Hovering: %s" % card_id

func _on_card_clicked(card_id: StringName) -> void:
	_status_label.text = "Clicked: %s" % card_id
	print("card_clicked: ", card_id)
