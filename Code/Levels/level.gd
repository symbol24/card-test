class_name Level extends MenuControl


func _ready() -> void:
	Manager.ToggleLoadingScreen.emit(false)
	await get_tree().create_timer(1).timeout
	Signals.DrawCards.emit(DeckData.Type.PLAYER, 3)
	Signals.DrawCards.emit(DeckData.Type.EVENT, 1)
	await get_tree().create_timer(1).timeout
	Signals.UnlockDeck.emit()
