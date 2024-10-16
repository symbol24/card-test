class_name DeckSelectorButton extends Button


var id:String = ""
var type:DeckData.Type


func _ready() -> void:
	Signals.SelectDeck.connect(_deselect)


func setup_button_data(_id:String, _type:DeckData.Type) -> void:
	id = _id
	type = _type


func _toggled(toggled_on: bool) -> void:
	if toggled_on:
		Signals.SelectDeck.emit(id, type)
	else:
		Signals.SelectDeck.emit("", type)


func _deselect(_id:String, _type:DeckData.Type) -> void:
	if _id != id and _type == type:
		set_pressed_no_signal(false)
		