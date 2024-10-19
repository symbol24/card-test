class_name SyButton extends Button


@export var id:String = ""
@export var send_clear:bool = false
	
	
func _pressed() -> void:
	if send_clear: Signals.ClearPlayVariables.emit()
	Signals.ButtonPressed.emit(id, "")
