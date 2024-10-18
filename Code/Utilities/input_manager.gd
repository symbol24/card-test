class_name InputManager extends Node2D


func _input(event: InputEvent) -> void:
	pass


func _toggle_pause_menu() -> void:
	if get_tree().paused:
		Signals.ToggleUiMenu.emit("", false)
		Game.toggle_pause(false)
	elif not get_tree().paused:
		Signals.ToggleUiMenu.emit("pause_menu", true)
		Game.toggle_pause(true)
