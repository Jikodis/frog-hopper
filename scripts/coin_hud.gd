extends CanvasLayer
## Shows how many coins you have. Listens to Game, so it updates by itself.

@onready var coins_label: Label = $CoinsLabel

func _ready() -> void:
	_update(Game.coins)
	Game.coins_changed.connect(_update)

func _update(new_coins: int) -> void:
	coins_label.text = "Coins: %d" % new_coins
