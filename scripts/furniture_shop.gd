extends Node2D
## The furniture shop. Same as the weapon shop, with its own greeting and list: walk up
## to the counter and press Space. What you buy shows up in your bedroom.

const GREETING := [
	{"speaker": "Shopkeeper", "text": "Hello, little frog! Let's make your room cozy."},
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
	shop_panel.open(ItemCatalog.FURNITURE, "Furniture Shop")

func _on_shop_closed() -> void:
	player.can_move = true
	talk_zone.set_enabled(true)
