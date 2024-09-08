extends Node

signal AddResource(type:CardData.Cost_Type, amount:int)
signal UseResource(type:CardData.Cost_Type, amount:int)
signal ResourceUpdated(type:CardData.Cost_Type, amount:int)
signal DiscardCard(card:Card)
signal UseCard(card:Card)
signal ToggleColliders(value:bool)

var player_data:PlayerData

func _ready() -> void:
	AddResource.connect(_add_resource)
	UseResource.connect(_use_resource)
	UI.ButtonPressed.connect(_check_ui_btn)

func setup_player() -> void:
	if player_data != null: 
		var temp = player_data
		temp.queue_free.call_deferred()
	player_data = PlayerData.new()

func _check_ui_btn(_id:String, _menu:String) -> void:
	if _id == "Play":
		setup_player()
		player_data.update_all_resources()

func _add_resource(_type:CardData.Cost_Type, _amount:int) -> void:
	player_data.add_resource(_type, _amount)

func _use_resource(_type:CardData.Cost_Type, _amount:int) -> void:
	player_data._use_resource(_type, _amount)

func _get_all_cards() -> Array[Card]:
	var all:Array = get_tree().get_nodes_in_group("card") as Array[Card]
	var cards:Array[Card] = []
	for each in all:
		if each is Card:
			cards.append(each as Card)
	return cards

func get_highest_card_z_index() -> int:
	var all:Array[Card] = _get_all_cards()
	if all.is_empty(): return 0
	var z:int = 0
	for card in all:
		if card.z_index > z:
			z = card.z_index
	if z >= 4096:
		_reset_card_z_indexes()
		z = get_highest_card_z_index()
	return z

func _reset_card_z_indexes() -> void:
	var all:Array[Card] = _get_all_cards()
	var z:int = 1
	for card in all:
		card.z_index = z
		z += 1