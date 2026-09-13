## Verifies the reusable CardBrowser's inbound/outbound API: populate()
## produces the right row count, and choosing the focused card emits
## card_chosen with the right data.
extends GutTest

const CARD_BROWSER_SCENE := preload("res://features/inventory/card_browser.tscn")

func test_populate_creates_one_row_per_card() -> void:
	var browser: CardBrowser = autofree(CARD_BROWSER_SCENE.instantiate())
	add_child_autofree(browser)

	var cards: Array[CardData] = [_make_card(&"a"), _make_card(&"b"), _make_card(&"c")]
	browser.populate(cards)

	assert_eq(browser.get_node("VBox/Split/Scroll/ListVBox").get_child_count(), 3)

func test_choosing_focused_card_emits_card_chosen() -> void:
	var browser: CardBrowser = autofree(CARD_BROWSER_SCENE.instantiate())
	add_child_autofree(browser)

	var target := _make_card(&"target")
	browser.populate([target, _make_card(&"other")])

	watch_signals(browser)
	var action_button: Button = browser.get_node("VBox/Split/DetailPanel/DetailVBox/ActionButton")
	action_button.pressed.emit()

	assert_signal_emitted_with_parameters(browser, "card_chosen", [target])

func _make_card(id: StringName) -> CardData:
	var card := CardData.new()
	card.id = id
	card.display_name = String(id)
	return card
