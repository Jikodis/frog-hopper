extends Node2D
## The world map: a path of level stones. Walk to a stone and press Space to play it.
## The TOWN exit on the left goes back to the town gate.

## Where the frog stands when arriving from the town gate.
@onready var town_arrival: Marker2D = $TownArrival
@onready var player: TownPlayer = $TownPlayer
@onready var stones: Node2D = $Stones

func _ready() -> void:
	if SceneRouter.from_level:
		# Back from a level: stand just below that level's stone.
		for stone in stones.get_children():
			if stone.level_number == Game.current_level:
				player.global_position = stone.global_position + Vector2(0, 70)
	else:
		player.global_position = town_arrival.global_position
