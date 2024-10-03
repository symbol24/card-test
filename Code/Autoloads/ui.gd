extends CanvasLayer


@onready var loading_screen:PanelContainer = %LoadingScreen


func _ready() -> void:
	Signals.ButtonPressed.connect(_button_dispatcher)
	Signals.PlayWith.connect(_play_with)
	Manager.ToggleLoadingScreen.connect(_toggle_loading_screen)


func _button_dispatcher(_id:String, _from:String) -> void:
	match _id:
		"main_menu":
			pass
		"deck_selector":
			Game.setup_rng()
			Game.setup_player()
			Manager.load_scene(2)
		"play_with":
			Manager.load_scene(3)


func _play_with(_event_id:String, _player_id:String) -> void:
	Game.load_deck(_event_id, DeckData.Type.EVENT)
	Game.load_deck(_player_id, DeckData.Type.PLAYER)
	_button_dispatcher("play_with", "deck_selector")


func _toggle_loading_screen(_value:bool) -> void:
	if not _value:
		if Manager.level_data.loading_delay > 0.0:
			await get_tree().create_timer(Manager.level_data.loading_delay).timeout
	loading_screen.set_deferred("visible", _value)