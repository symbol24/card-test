class_name Level extends MenuControl


func _ready() -> void:
	Manager.ToggleLoadingScreen.emit(false)