class_name MainMenu extends MenuControl


func _ready() -> void:
	Signals.ToggleLoadingScreen.emit(false)