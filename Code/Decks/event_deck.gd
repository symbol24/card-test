class_name EventDeck extends CardPanelContainer


@export var card_placement_pos:Marker2D
@export var hand_count:int = 5
@export var tween_time:float = 2

@onready var deck_area:Area2D = %deck_area
@onready var deck_btn:Button = %event_deck_btn

var card_layer:Control
var card_scene_pool:Array[Card] = []
var current_hand_count:int = 0:
	set(value):
		current_hand_count = value
		if current_hand_count >= 5:
			layer += 1
			current_hand_count = 0
var layer:int = 0:
	set(value):
		layer = value
		if layer > 2: layer = 0
var active_card:EventCard = null


func _ready() -> void:
	super()
	Signals.NullActiveCard.connect(_null_active)
	card_layer = get_tree().get_first_node_in_group("card_layer")
	deck_btn.pressed.connect(_deck_btn_pressed)


func _deck_btn_pressed() -> void:
	if active_card == null and not Game.current_event_deck.is_deck_empty:
		_draw_card()
	elif active_card != null:
		Signals.NotifyActiveEventCard.emit(active_card)
	elif Game.player_data.current_deck.is_deck_empty:
		Signals.NotifyEventDeckEmpty.emit()


func _get_card_scene() -> EventCard:
	if not card_scene_pool.is_empty():
		return card_scene_pool.pop_front()
	return Game.data_manager.default_event_card.instantiate() as EventCard


func _draw_card() -> void:
	var new_card:EventCard = _get_card_scene()
	if new_card != null:
		card_layer.add_child.call_deferred(new_card)
		await new_card.ready
		new_card.setup_card(Game.current_event_deck.draw_card())
		new_card.global_position = global_position
		active_card = new_card
		var tween:Tween = new_card.create_tween()
		var final_pos:Vector2 = Vector2(card_placement_pos.global_position.x + (50 * current_hand_count), card_placement_pos.global_position.y + (50 * layer))
		tween.tween_property(new_card, "global_position", final_pos, tween_time)
		current_hand_count += 1


func _null_active() -> void:
	active_card = null