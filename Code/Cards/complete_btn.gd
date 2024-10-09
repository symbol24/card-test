class_name CompleteCard extends Button


var card:Card


func _pressed() -> void:
	Signals.CompleteCard.emit(card)