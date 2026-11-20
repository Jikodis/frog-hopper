class_name ShopPanel
extends CanvasLayer
## A reusable shop list. open(items) shows each item with its price; up/down picks a
## row, interact buys it, and the last row, Leave, closes the panel (emits `closed`).
##
## The panel never decides whether you can afford something: it asks Game.buy(), which
## holds all the money rules. That's why every future shop can reuse this panel as is.

signal closed

const ROW_FONT_SIZE := 24

@onready var panel: Panel = $Panel
@onready var title_label: Label = $Panel/TitleLabel
@onready var rows: VBoxContainer = $Panel/Rows
@onready var message_label: Label = $Panel/MessageLabel

var _items: Array = []
var _selected := 0

func _ready() -> void:
	panel.visible = false

func is_open() -> bool:
	return panel.visible

func open(items: Array, title: String = "Shop") -> void:
	_items = items
	_selected = 0
	title_label.text = title
	message_label.text = "Up/Down to choose, Space to buy"
	panel.visible = true
	_render()

func _row_count() -> int:
	return _items.size() + 1  # every item, plus Leave

func _render() -> void:
	for child in rows.get_children():
		child.queue_free()
	for i in _row_count():
		var label := Label.new()
		label.add_theme_font_size_override("font_size", ROW_FONT_SIZE)
		var pointer := "> " if i == _selected else "   "
		if i < _items.size():
			var item: Dictionary = _items[i]
			var price := "Owned" if Game.owns(item["id"]) else "%d coins" % item["price"]
			label.text = "%s%s  -  %s" % [pointer, item["name"], price]
		else:
			label.text = pointer + "Leave"
		rows.add_child(label)

func _unhandled_input(event: InputEvent) -> void:
	if not is_open():
		return
	if event.is_action_pressed("move_up"):
		_selected = (_selected - 1 + _row_count()) % _row_count()
	elif event.is_action_pressed("move_down"):
		_selected = (_selected + 1) % _row_count()
	elif event.is_action_pressed("interact"):
		if _selected == _items.size():
			_close()
		else:
			_try_buy(_items[_selected])
	else:
		return
	get_viewport().set_input_as_handled()
	if is_open():
		_render()

func _try_buy(item: Dictionary) -> void:
	if Game.owns(item["id"]):
		message_label.text = "You already have the %s." % item["name"]
	elif Game.buy(item):
		message_label.text = "You bought the %s!" % item["name"]
	else:
		message_label.text = "Not enough coins."

func _close() -> void:
	panel.visible = false
	closed.emit()
