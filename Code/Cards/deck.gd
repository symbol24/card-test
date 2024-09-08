class_name Deck extends CardPanelContainer



@onready var deck_area:Area2D = %deck_area
@onready var card_layer:Control = %card_layer
@onready var deck_btn:Button = %deck_btn

func _ready() -> void:
    super()
    deck_btn.pressed.connect(_deck_btn_pressed)


func _deck_btn_pressed() -> void:
    if Game.player_data.check_available_resource(CardData.Cost_Type.ENERGY, 1):
        print("pressed deck")
        Game.player_data.use_resource(CardData.Cost_Type.ENERGY, 1)