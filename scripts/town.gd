extends Node2D
## The town hub. Places the frog at the spawn SceneRouter remembered (beside the door
## it last used), or a default spot by the gate on first launch.

@onready var player: CharacterBody2D = $TownPlayer
@onready var default_spawn: Marker2D = $DefaultSpawn

func _ready() -> void:
	if SceneRouter.has_town_spawn:
		player.global_position = SceneRouter.town_spawn
	else:
		player.global_position = default_spawn.global_position
