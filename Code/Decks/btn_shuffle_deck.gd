class_name BtnShuffleDeck extends Button


func _ready() -> void:
	set_deferred("disabled", true)
	Signals.ToggleShuffleButton.connect(_toggle_btn)


func _pressed() -> void:
	Signals.ShuffleDeck.emit()
	_toggle_btn(true)


func _toggle_btn(_value:bool) -> void:
	set_deferred("disabled", _value)