class_name UseCardBtn extends Button


var card:Card


func _pressed() -> void:
	Signals.UseCard.emit(card)