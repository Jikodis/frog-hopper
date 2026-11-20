extends Node2D
## Your bedroom: where the game starts. The first time you're here, a short story plays
## in the dialogue box and the frog can't move until it ends. After that (for example,
## coming back in through the house door), the room is just a room.

## The opening story. Each line is a speaker and what they say.
## Rewrite these to change the story; nothing else needs to change.
const INTRO_LINES := [
	{"speaker": "Mom", "text": "Wake up, sleepyhead! The sun's been up for hours."},
	{"speaker": "Frog", "text": "Five more minutes..."},
	{"speaker": "Mom", "text": "The shops in town are open. If you catch some flies, you can buy something nice."},
	{"speaker": "Frog", "text": "Flies? I'm on it!"},
]

@onready var player: TownPlayer = $TownPlayer
@onready var dialogue_box: DialogueBox = $DialogueBox

func _ready() -> void:
	if Game.intro_done:
		return
	player.can_move = false
	dialogue_box.finished.connect(_on_intro_finished, CONNECT_ONE_SHOT)
	dialogue_box.start(INTRO_LINES)

func _on_intro_finished() -> void:
	Game.intro_done = true
	player.can_move = true
