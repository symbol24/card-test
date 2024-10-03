class_name MainMenu extends MenuControl


func _ready() -> void:
	Manager.ToggleLoadingScreen.emit(false)