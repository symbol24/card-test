class_name EventDeckButton extends DeckButton


func _deck_btn_pressed() -> void:
	if can_draw:
		Signals.DrawCards.emit(deck_type, 1, false, true)