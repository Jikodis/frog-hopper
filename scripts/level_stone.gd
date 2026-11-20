extends Node2D
## A stepping stone on the world map for one level. Stand on it and press Space to play.
## Its color shows the level's state: gray = locked, yellow = open, green = beaten.

const LOCKED_COLOR := Color(0.45, 0.45, 0.45)
const OPEN_COLOR := Color(0.95, 0.8, 0.25)
const BEATEN_COLOR := Color(0.3, 0.75, 0.35)

@export var level_number := 1

@onready var visual: ColorRect = $Visual
@onready var number_label: Label = $NumberLabel
@onready var name_label: Label = $NameLabel
@onready var talk_zone: TalkZone = $TalkZone

func _ready() -> void:
	var level := LevelCatalog.find(level_number)
	number_label.text = str(level_number)
	if Game.is_beaten(level_number):
		visual.color = BEATEN_COLOR
		name_label.text = "%s (done)" % level["name"]
	elif Game.is_unlocked(level_number):
		visual.color = OPEN_COLOR
		name_label.text = level["name"]
	else:
		visual.color = LOCKED_COLOR
		name_label.text = "Locked"
	talk_zone.talked.connect(_on_talked)

func _on_talked() -> void:
	if Game.is_unlocked(level_number):
		SceneRouter.go_to_level(level_number)
	else:
		name_label.text = "Beat level %d first" % (level_number - 1)
