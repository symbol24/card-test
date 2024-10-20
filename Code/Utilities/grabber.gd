class_name Grabber extends Node2D


@export var move_delay:float = 0.2
@export var move_offset:Vector2 = Vector2(10,0)

@onready var player_deck:DeckButton = get_tree().get_first_node_in_group("player_deck")
@onready var event_deck:DeckButton = get_tree().get_first_node_in_group("event_deck")
@onready var discard:Discard = get_tree().get_first_node_in_group("discard")

var grabbed_items:Array = []
var grabbing:bool = false
var multi_grab:bool = false
var connection_point:Vector2
var selector_panel:GrabberSelectorPanel = null
var panels:Array = []
var multi_enabled:bool = false


func _input(_event: InputEvent) -> void:
	if not get_tree().paused and Game.active_level != null and not UI.is_result_displayed:
		if Input.is_action_just_pressed("mouse_left"):
			_grab()
			
		elif Input.is_action_just_released("mouse_left"):
			_release()


func _process(delta: float) -> void:
	if grabbing and not grabbed_items.is_empty():
		var tween:Tween = self.create_tween()
		tween.parallel()
		var i:int = 0
		for each in grabbed_items:
			#tween.parallel()
			tween.tween_property(each, "global_position", get_global_mouse_position()-connection_point+(move_offset*i), delta+move_delay)
			i += 1
	elif not grabbing and selector_panel != null and not Game.discard_layer.is_visible():
		var tween:Tween = self.create_tween()
		tween.tween_method(selector_panel.set_panel_size, selector_panel.size, get_global_mouse_position(), delta)


func _grab() -> void:
	if grabbed_items.is_empty():
		_click_card()
		if not grabbed_items.is_empty():
			grabbing = true
		else:
			if multi_enabled:
				var new_panel = Game.data_manager.grabber_selector_panel.instantiate()
				UI.add_child.call_deferred(new_panel)
				new_panel.set_deferred("custom_minimum_size", Vector2.ZERO)
				new_panel.set_deferred("size", Vector2.ZERO)
				new_panel.set_deferred("position", get_global_mouse_position())
				new_panel.set_deferred("z_index", Game.get_highest_card_z_index()+1)
				selector_panel = new_panel
				panels.append(new_panel)
	elif not grabbed_items.is_empty():
		grabbing = true


func _click_card() -> void:
	if not grabbing:
		if Game.discard_layer.is_visible():
			var discarded_cards:Array[Card] = _get_cards(true)
			for each in discarded_cards:
				var area:Vector2 = each.global_position + each.size
				if get_global_mouse_position().x >= each.global_position.x and get_global_mouse_position().x <= area.x and get_global_mouse_position().y >= each.global_position.y and get_global_mouse_position().y <= area.y:
					grabbed_items.append(each)
		elif not Game.discard_layer.is_visible():
			var active_cards:Array[Card] = _get_cards(false)
			for each in active_cards:
				if each != null:
					var area:Vector2 = each.global_position + each.size
					if get_global_mouse_position().x >= each.global_position.x and get_global_mouse_position().x <= area.x and get_global_mouse_position().y >= each.global_position.y and get_global_mouse_position().y <= area.y:
						grabbed_items.append(each)
			if Game.active_event_card != null:
				var area:Vector2 = Game.active_event_card.global_position + Game.active_event_card.size
				if get_global_mouse_position().x >= Game.active_event_card.global_position.x and get_global_mouse_position().x <= area.x and get_global_mouse_position().y >= Game.active_event_card.global_position.y and get_global_mouse_position().y <= area.y:
					grabbed_items.append(Game.active_event_card)

		if not grabbed_items.is_empty():
			var highest_z:int = 0
			for each in grabbed_items:
				if each.z_index > highest_z: 
					highest_z = each.z_index
			var to_remove:Array[Card]
			for each in grabbed_items:
				if each.z_index != highest_z:
					to_remove.append(each)
			for each in to_remove:
				grabbed_items.erase(each)
			if grabbed_items.is_empty():
				push_error("No more grabbed items, your algo is wrong dofus")
			else:
				Signals.ToggleCollider.emit(false)
				connection_point = grabbed_items[0].get_local_mouse_position()
				grabbed_items[0].z_index = Game.get_highest_card_z_index() + 1


func _release() -> void:
	if grabbing:
		grabbing = false
		grabbed_items.clear()
		Signals.ToggleCollider.emit(true)
	elif selector_panel != null:
		grabbed_items = _get_panel_cards(selector_panel)
		selector_panel.queue_free()
		if not panels.is_empty():
			for each in panels:
				if each != null:
					each.queue_free.call_deferred()
			panels.clear()


func _get_panel_cards(_panel:GrabberSelectorPanel) -> Array[Card]:
	var cards:Array[Card] = []
	var panel_start:Vector2 = _panel.global_position
	var panel_end:Vector2 = _panel.global_position + _panel.size
	if Game.discard_layer.is_visible() and not Game.discarded_player_cards.is_empty():
		for card in discard.discarded:
			if card != null:
				var card_end:Vector2 = card.global_position + card.size
				if (card.global_position.x >= panel_start.x and card_end.x <= panel_end.x) and (card.global_position.y >= panel_start.y and card_end.y <= panel_end.y):
					cards.append(card)
	elif not Game.discard_layer.is_visible() and not Game.active_player_cards.is_empty():
		for card in Game.active_player_cards:
			if card != null:
				var card_end:Vector2 = card.global_position + card.size
				if (card.global_position.x >= panel_start.x and card_end.x <= panel_end.x) and (card.global_position.y >= panel_start.y and card_end.y <= panel_end.y):
					cards.append(card)

	return cards


func _get_cards(_is_discarded:bool = false) -> Array[Card]:
	var all_cards = get_tree().get_nodes_in_group("card")
	var cards:Array[Card] = []
	for each in all_cards:
		if each.is_in_discard == _is_discarded:
			cards.append(each as Card)

	return cards