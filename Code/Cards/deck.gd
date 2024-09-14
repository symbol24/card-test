class_name Deck extends CardPanelContainer



@onready var deck_area:Area2D = %deck_area
@onready var deck_btn:Button = %deck_btn

var cards:Array[CardData] = []
var card_layer:Control

func _ready() -> void:
	super()
	card_layer = get_tree().get_first_node_in_group("card_layer")
	deck_btn.pressed.connect(_deck_btn_pressed)


func _deck_btn_pressed() -> void:
	if Game.player_data.check_available_resource(CardData.Resource_Type.ENERGY, 1):
		print("pressed deck")
		Game.player_data.use_resource(CardData.Resource_Type.ENERGY, 1)
