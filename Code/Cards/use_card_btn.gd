class_name UiCardButton extends Button


enum Type {
			COMPLETE = 0,
			USE = 1,
			PAY = 2,
			NONE = 3,
		}


var type:Type
var card:Card


func _pressed() -> void:
	match type:
		Type.COMPLETE:
			Signals.CompleteCard.emit(card)
		Type.USE:
			Signals.UseCard.emit(card)
		Type.PAY:
			Signals.PayResourceFromCard.emit(card)
	


func set_type(_type:Type) -> void:
	type = _type
	match type:
		Type.COMPLETE:
			text = tr("complete_card_btn")
		Type.USE:
			text = tr("use_card_btn")
		Type.PAY:
			text = tr("pay_card_btn")