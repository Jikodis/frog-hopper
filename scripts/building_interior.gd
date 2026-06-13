extends Node2D
## A reusable empty room shown for any building. Displays which building you're in.

@onready var name_label: Label = $NameLabel

func _ready() -> void:
	name_label.text = SceneRouter.current_building
