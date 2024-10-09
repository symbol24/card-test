class_name Level extends MenuControl


func _ready() -> void:
	Manager.ToggleLoadingScreen.emit(false)
	await get_tree().create_timer(1).timeout
	Signals.PlayerDrawCards.emit(3)