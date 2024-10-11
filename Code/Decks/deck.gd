class_name DeckButton extends CardPanelContainer


@export var deck_type:DeckData.Type
@export var card_placement_pos:Marker2D
@export var empty_color:Color = Color.RED
@export var empty_flash_time:float = 0.3

@onready var deck_area:Area2D = %deck_area
@onready var deck_btn:Button = %deck_btn

var can_draw:bool = false


func _ready() -> void:
	super()
	Signals.UnlockDeck.connect(_unlock_deck)
	deck_btn.pressed.connect(_deck_btn_pressed)


func _deck_btn_pressed() -> void:
	if can_draw:
		Signals.DrawCards.emit(deck_type, 1, true)

	
func _flash_empty() -> void:
	var tween:Tween = create_tween()
	var time:float = empty_flash_time/2
	tween.tween_property(self, "modulate", empty_color, time)
	tween.tween_property(self, "modulate", Color.WHITE, time)


func _unlock_deck() -> void:
	can_draw = true