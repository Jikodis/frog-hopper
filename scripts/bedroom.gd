extends Node2D
## Your bedroom: where the game starts. The first time you're here, a short story plays
## in the dialogue box and the frog can't move until it ends. After that (coming back in
## through the house door, or opening the game again), the room is just a room.
## Furniture you've bought shows up here (see furniture.gd).

## The opening story. Each line is a speaker and what they say.
## Rewrite these to change the story; nothing else needs to change.
const INTRO_LINES := [
	{"speaker": "Dad", "text": "Wake up, sleepyhead! The sun's been up for hours."},
	{"speaker": "Frog", "text": "Five more minutes..."},
	{"speaker": "Dad", "text": "The shops in town are open. If you catch some flies, you can buy something nice."},
	{"speaker": "Frog", "text": "Flies? I'm on it!"},
]

@onready var player: TownPlayer = $TownPlayer
@onready var dialogue_box: DialogueBox = $DialogueBox

func _ready() -> void:
	# The Big Bed replaces the small one.
	if Game.owns("big_bed"):
		$Bed.queue_free()
	if Game.intro_done:
		return
	player.can_move = false
	dialogue_box.finished.connect(_on_intro_finished, CONNECT_ONE_SHOT)
	dialogue_box.start(INTRO_LINES)

func _on_intro_finished() -> void:
	Game.mark_intro_done()  # saved, so the story only plays on a new game
	player.can_move = true
