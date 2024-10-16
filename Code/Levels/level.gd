class_name Level extends MenuControl


func _ready() -> void:
	Manager.LoadingComplete.connect(_finish_loading_level)


func _finish_loading_level() -> void:
	Game.player_data.setup_player_data()
	Manager.ToggleLoadingScreen.emit(false)
	await get_tree().create_timer(2).timeout
	print("Amount to draw: ", Game.player_data.current_deck.round_draw_amount)
	Signals.DrawCards.emit(DeckData.Type.PLAYER, Game.player_data.current_deck.round_draw_amount, false)
	Signals.DrawCards.emit(DeckData.Type.EVENT, Game.current_event_deck.round_draw_amount, false)
	await get_tree().create_timer(1).timeout
	Signals.UnlockDeck.emit()
