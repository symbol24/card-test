class_name PauseButton extends Button


enum Pause {
				NA = 0,
				PAUSE = 1,
				UNPAUSE = 2,
			}

@export var destination:String = ""
@export var open:bool = false
@export var toggle_pause:Pause = Pause.NA


func _pressed() -> void:
	Signals.ToggleUiMenu.emit(destination, open)
	match toggle_pause:
		Pause.PAUSE:
			Game.toggle_pause(true)
		Pause.UNPAUSE:
			Game.toggle_pause(false)
		_:
			pass