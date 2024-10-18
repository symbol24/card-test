class_name SyButton extends Button


@export var id:String = ""
@export var send_clear:bool = false

var parent_menu:MenuControl


func _ready() -> void:
	parent_menu = get_parent() as MenuControl
	
	
func _pressed() -> void:
	if send_clear: Signals.ClearPlayVariables.emit()
	Signals.ButtonPressed.emit(id, parent_menu.id if parent_menu != null else "")
