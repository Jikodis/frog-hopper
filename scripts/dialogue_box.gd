class_name DialogueBox
extends CanvasLayer
## A reusable dialogue box along the bottom of the screen.
##
## Call start() with a list of lines; each line is {"speaker": "...", "text": "..."}.
## The text types out letter by letter. Pressing "interact" shows the rest of the line
## at once, or, if the line is already showing, moves to the next one. After the last
## line the box hides and emits `finished`.
##
## The box never touches the frog or the scene it's in. It only emits signals; whoever
## opened it listens and decides what to do (that's the "talk via signals" rule).

signal started
signal finished

const CHARS_PER_SECOND := 40.0  # typing speed; bigger = faster text

@onready var panel: Panel = $Panel
@onready var speaker_label: Label = $Panel/SpeakerLabel
@onready var text_label: Label = $Panel/TextLabel
@onready var hint_label: Label = $Panel/HintLabel

var _lines: Array = []
var _index := 0
var _shown := 0.0  # how many letters of the current line are visible (fractional)

func _ready() -> void:
	panel.visible = false

func is_open() -> bool:
	return panel.visible

func start(lines: Array) -> void:
	if lines.is_empty():
		finished.emit()
		return
	_lines = lines
	_index = 0
	panel.visible = true
	started.emit()
	_show_line()

func _show_line() -> void:
	var line: Dictionary = _lines[_index]
	speaker_label.text = line.get("speaker", "")
	text_label.text = line.get("text", "")
	_shown = 0.0
	text_label.visible_characters = 0
	hint_label.visible = false

func _line_fully_shown() -> bool:
	var count := text_label.visible_characters
	return count == -1 or count >= text_label.text.length()

func _process(delta: float) -> void:
	if not is_open() or _line_fully_shown():
		return
	_shown += CHARS_PER_SECOND * delta
	text_label.visible_characters = int(_shown)
	if _line_fully_shown():
		hint_label.visible = true

func _unhandled_input(event: InputEvent) -> void:
	if not is_open() or not event.is_action_pressed("interact"):
		return
	get_viewport().set_input_as_handled()
	if not _line_fully_shown():
		# Impatient reader: skip the typing and show the whole line.
		text_label.visible_characters = -1  # -1 means "show everything"
		_shown = text_label.text.length()
		hint_label.visible = true
		return
	_index += 1
	if _index < _lines.size():
		_show_line()
	else:
		panel.visible = false
		finished.emit()
