class_name PayResourceBtn extends Button


var card:Card


func _pressed() -> void:
	if card != null:
		Signals.PayResourceFromCard.emit(card)