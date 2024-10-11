extends CanvasLayer


@onready var loading_screen:PanelContainer = %LoadingScreen


func _ready() -> void:
	Signals.ButtonPressed.connect(_button_dispatcher)
	Signals.PlayWith.connect(_play_with)
	Signals.ToggleCardForButton.connect(_display_card_button)
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
	_button_dispatcher("play_with", "deck_selector")


func _toggle_loading_screen(_value:bool) -> void:
	if not _value:
		if Manager.level_data.loading_delay > 0.0:
			await get_tree().create_timer(Manager.level_data.loading_delay).timeout
	loading_screen.set_deferred("visible", _value)


func _display_card_button(_type:UiCardButton.Type, _card:Card, _display:bool) -> void:
	if not _display:
		if _card.ui_button != null:
			_card.btn_control.remove_child.call_deferred(_card.ui_button)
			_card.ui_button.queue_free.call_deferred()
			_card.ui_button = null
	else:
		if _type != null and _card.ui_button == null:
			var new_btn:UiCardButton = Game.data_manager.ui_card_btn.instantiate() as UiCardButton
			_card.btn_control.add_child.call_deferred(new_btn)
			if not new_btn.is_node_ready():
				await new_btn.ready
			var pos:Vector2 = Vector2(_card.size.x + _card.global_position.x + 10, _card.size.y + _card.global_position.y - new_btn.size.y - 5)
			if _card.global_position.x + _card.size.x > ProjectSettings.get_setting("display/window/size/viewport_width")-new_btn.size.x-10 and not _card.global_position.y + _card.size.y > ProjectSettings.get_setting("display/window/size/viewport_height")-new_btn.size.y-5:
				pos = Vector2(_card.global_position.x-110, _card.size.y - new_btn.size.y - 5)
			elif _card.global_position.y + _card.size.y > ProjectSettings.get_setting("display/window/size/viewport_height")-new_btn.size.y-5 and not _card.global_position.x + _card.size.x > ProjectSettings.get_setting("display/window/size/viewport_width")-new_btn.size.x-10:
				pos = Vector2(_card.size.x + _card.global_position.x + 10, _card.global_position.y + 5)
			elif _card.global_position.x + _card.size.x > ProjectSettings.get_setting("display/window/size/viewport_width")-new_btn.size.x-10 and _card.global_position.y + _card.size.y > ProjectSettings.get_setting("display/window/size/viewport_height")-new_btn.size.y-5:
				pos = Vector2(_card.global_position.x-110, _card.global_position.y + 5)
			new_btn.set_deferred("global_position", pos)
			new_btn.set_deferred("card", _card)
			new_btn.set_type.call_deferred(_type)
			new_btn.set_deferred("z_index", Game.get_highest_card_z_index()+1)

			_card.ui_button = new_btn