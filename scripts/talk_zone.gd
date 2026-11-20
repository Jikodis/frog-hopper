class_name TalkZone
extends Area2D
## A reusable "press Space here" spot. When the frog is standing inside it and presses
## interact, it emits `talked`. The scene decides what talking does (open a shop, start
## a conversation...). Shows a small hint while the frog is inside.

signal talked

## The hint shown while the frog stands here.
@export var hint_text := "Space: talk"

## Turn off while the conversation or shop is already open.
var enabled := true

var _player_inside := false

@onready var hint_label: Label = $HintLabel

func _ready() -> void:
	hint_label.text = hint_text
	hint_label.hide()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = true
		hint_label.visible = enabled

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = false
		hint_label.hide()

func set_enabled(value: bool) -> void:
	enabled = value
	hint_label.visible = enabled and _player_inside

func _unhandled_input(event: InputEvent) -> void:
	if enabled and _player_inside and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		talked.emit()
