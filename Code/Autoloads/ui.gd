extends CanvasLayer

@onready var level_layer:Control = %level_layer
@onready var screens:Array[SyPanelContainer] = []

var active_result_screen:ResultScreen = null
var is_result_displayed:bool:
	get:
		return active_result_screen != null and active_result_screen.visible


func _ready() -> void:
	var children = get_children()
	for child in children:
		if child is SyPanelContainer: screens.append(child)
	Signals.ButtonPressed.connect(_button_dispatcher)
	Signals.PlayWith.connect(_play_with)
	Signals.ToggleCardForButton.connect(_display_card_button)
	Signals.ToggleUiMenu.connect(_toggle_screen)
	Signals.DisplayResultScreen.connect(_display_result_screen)
	Signals.ToggleLoadingScreen.connect(_toggle_loading_screen)


func _button_dispatcher(_id:String, _from:String) -> void:
	match _id:
		"main_menu":
			pass
		"deck_selector":
			Signals.Save.emit()
			Signals.LoadScene.emit("deck_selector")
		"play_with":
			Signals.LoadScene.emit("play_level")
		"btn_result_retry":
			Signals.ResetGameData.emit()
			Game.reset_decks()
			Signals.LoadScene.emit("play_level")
		"btn_result_return":
			Signals.ResetGameData.emit()
			Signals.LoadScene.emit("deck_selector")
		"debug_result_success":
			Signals.DisplayResultScreen.emit("result_success", true)
		"debug_result_failure":
			Signals.DisplayResultScreen.emit("result_failure", false)
		"delete_save":
			Signals.DeleteAndLoad.emit()
		"bugs_btn":
			OS.shell_open("https://forms.gle/2zZqJd7tn48aEnX77")
		"discord_btn":
			OS.shell_open("https://discord.gg/53jFqh7GPt")
		_:
			pass


func _play_with(_event_id:String, _player_id:String) -> void:
	_button_dispatcher("play_with", "deck_selector")


func _toggle_loading_screen(_value:bool) -> void:
	if not _value:
		if Game.scene_manager.level_data.extra_loading_time > 0.0:
			await get_tree().create_timer(Game.scene_manager.level_data.extra_loading_time).timeout
	_toggle_screen("loading_screen", _value)


func _display_card_button(_type:UiCardButton.Type, _card:Card, _display:bool) -> void:
	if not _display:
		_card.clear_ui_buttons()
	else:
		if _type != null and _card.ui_buttons.is_empty():
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
			new_btn.set_deferred("z_index", Game.get_highest_card_z_index()+1000)

			_card.ui_buttons.append(new_btn)


func _toggle_screen(_id:String, _value:bool) -> void:
	for each in screens:
		if each != null:
			each.set_deferred("visible", false)
			if each.id == _id:
				each.set_deferred("visible", _value)


func _display_result_screen(_result_id:String, _success:bool) -> void:
	if active_result_screen != null:
		active_result_screen.queue_free()
		active_result_screen = null
	var panel:SyPanelContainer = _get_already_present("result_screen")
	if panel == null:
		panel = Game.data_manager.result_screen.instantiate()
		add_child.call_deferred(panel)
		screens.append.call_deferred(panel)
		if not panel.is_node_ready():
			await panel.ready
	panel.set_buttons(_success)
	panel.set_title(_success)
	panel.set_result_text(_result_id)
	active_result_screen = panel
	_toggle_screen("result_screen", true)


func _get_already_present(_panel:String) -> SyPanelContainer:
	for each in screens:
		if _panel == each.id: return each
	return null