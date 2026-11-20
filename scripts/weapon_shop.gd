extends Node2D
## The weapon shop. Walk up to the counter and press Space: the shopkeeper says hello in
## the dialogue box, then the shop list opens. The frog can't walk while either is open.

const GREETING := [
	{"speaker": "Shopkeeper", "text": "Welcome, little frog! Every sword here is sharp... mostly."},
]

@onready var player: TownPlayer = $TownPlayer
@onready var talk_zone: TalkZone = $TalkZone
@onready var dialogue_box: DialogueBox = $DialogueBox
@onready var shop_panel: ShopPanel = $ShopPanel

func _ready() -> void:
	talk_zone.talked.connect(_on_talked)
	dialogue_box.finished.connect(_on_greeting_finished)
	shop_panel.closed.connect(_on_shop_closed)

func _on_talked() -> void:
	talk_zone.set_enabled(false)
	player.can_move = false
	dialogue_box.start(GREETING)

func _on_greeting_finished() -> void:
	shop_panel.open(ItemCatalog.WEAPONS, "Weapon Shop")

func _on_shop_closed() -> void:
	player.can_move = true
	talk_zone.set_enabled(true)
