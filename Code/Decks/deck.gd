class_name Deck extends CardPanelContainer


@export var deck_type:DeckData.Type
@export var card_placement_pos:Marker2D
@export var hand_count:int = 5
@export var tween_time:float = 2
@export var empty_color:Color = Color.RED
@export var empty_flash_time:float = 0.3

@onready var deck_area:Area2D = %deck_area
@onready var deck_btn:Button = %deck_btn

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
var cards_amount:int = 0
var active_cards:Array[Card] = []


func _ready() -> void:
	super()
	Signals.NotifyPlayerDeckEmpty.connect(_flash_empty)
	Signals.CardDiscarded.connect(_discard)
	card_layer = get_tree().get_first_node_in_group("card_layer")
	deck_btn.pressed.connect(_deck_btn_pressed)


func _deck_btn_pressed() -> void:
	if Game.player_data.check_available_resource(CardData.Resource_Type.ENERGY, 1) and not Game.player_data.current_deck.is_deck_empty:
		_draw_card()
		Game.player_data.use_resource(CardData.Resource_Type.ENERGY, 1)
	elif not Game.player_data.check_available_resource(CardData.Resource_Type.ENERGY, 1):
		Signals.NotifyResourceEmpty.emit(CardData.Resource_Type.ENERGY)
	elif Game.player_data.current_deck.is_deck_empty:
		Signals.NotifyPlayerDeckEmpty.emit()


func _get_card_scene() -> Card:
	if not card_scene_pool.is_empty():
		return card_scene_pool.pop_front()
	if deck_type == DeckData.Type.EVENT:
		return Game.data_manager.default_event_card.instantiate() as EventCard
	return Game.data_manager.default_player_card.instantiate() as Card


func _draw_card() -> void:
	var new_card = _get_card_scene()
	active_cards.append(new_card)
	card_layer.add_child.call_deferred(new_card)
	await new_card.ready
	new_card.setup_card(Game.player_data.current_deck.draw_card())
	new_card.global_position = global_position
	new_card.z_index = Game.get_highest_card_z_index() + 1
	new_card.name = "card_"+str(cards_amount)
	cards_amount += 1
	var tween:Tween = new_card.create_tween()
	var final_pos:Vector2 = Vector2(card_placement_pos.global_position.x + (50 * current_hand_count), card_placement_pos.global_position.y + (50 * layer))
	tween.tween_property(new_card, "global_position", final_pos, tween_time)
	current_hand_count += 1

	
func _flash_empty() -> void:
	var tween:Tween = self.create_tween()
	var time:float = empty_flash_time/2
	tween.tween_property(self, "modulate", empty_color, time)
	tween.tween_property(self, "modulate", Color.WHITE, time)


func _discard(_card:Card) -> void:
	active_cards.erase(_card)
