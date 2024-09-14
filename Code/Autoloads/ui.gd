extends CanvasLayer







func _ready() -> void:
	Signals.ButtonPressed.connect(_button_dispatcher)
	


func _button_dispatcher(_id:String, _from:String) -> void:
	match _id:
		"main_menu":
			pass
		"play":
			Manager.load_scene(2)
		"play_with_starter_deck":
			Manager.load_scene(3)
