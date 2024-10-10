class_name Deck extends CardPanelContainer


@export var deck_type:DeckData.Type
@export var card_placement_pos:Marker2D
@export var hand_count:int = 5
@export var tween_time:float = 2
@export var empty_color:Color = Color.RED
@export var empty_flash_time:float = 0.3

@onready var deck_area:Area2D = %deck_area
@onready var deck_btn:Button = %deck_btn

var can_draw:bool = false
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
	Signals.CardDiscarded.connect(_discard)
	Signals.DrawCards.connect(_signal_draw_card)
	Signals.UnlockDeck.connect(_unlock_deck)
	deck_btn.pressed.connect(_deck_btn_pressed)


func _deck_btn_pressed() -> void:
	if can_draw: 
		Signals.DrawCard.emit(self)

	
func _flash_empty() -> void:
	var tween:Tween = self.create_tween()
	var time:float = empty_flash_time/2
	tween.tween_property(self, "modulate", empty_color, time)
	tween.tween_property(self, "modulate", Color.WHITE, time)


func _discard(_card:Card) -> void:
	active_cards.erase(_card)


func _signal_draw_card(_type:DeckData.Type, _amount:int = 1) -> void:
	if deck_type == _type:
		for i in _amount:
			Signals.DrawCard.emit(self)


func _unlock_deck() -> void:
	can_draw = true