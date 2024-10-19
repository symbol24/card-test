class_name InputManager extends Node2D


func _input(_event: InputEvent) -> void:
	if Game.active_level != null and not UI.is_result_displayed:
		if Input.is_action_just_pressed("toggle_pause"):
			_toggle_pause_menu()

		if Input.is_action_just_released("mouse_left"):
			Signals.CheckFailState.emit()


func _toggle_pause_menu() -> void:
	if get_tree().paused:
		Signals.ToggleUiMenu.emit("", false)
		Game.toggle_pause(false)
	elif not get_tree().paused:
		Signals.ToggleUiMenu.emit("pause_menu", true)
		Game.toggle_pause(true)
