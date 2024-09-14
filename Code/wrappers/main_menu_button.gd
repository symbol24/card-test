class_name MainMenuButton extends Button

@export var id:String = ""

var parent_menu:MenuControl


func _ready() -> void:
	parent_menu = get_parent() as MenuControl
	
	
func _pressed() -> void:
	Signals.ButtonPressed.emit(id, parent_menu.id)
