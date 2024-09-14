extends Node

const SEED_OPTIONS:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@#$%^&*?"
const STARTER_DECK = preload("res://Data/Decks/starter_deck.tres")

@export var seed_length:int = 10
@export var force_debug_seed:bool = false
@export var debug_seed:String = ""

var run_seed:String = ""
var run_seed_hash:int
var seeded_rng:SyRandomNumberGenerator

var player_data:PlayerData


func _ready() -> void:
	Signals.AddResource.connect(_add_resource)
	Signals.UseResource.connect(_use_resource)
	#UI.ButtonPressed.connect(_check_ui_btn)
	seeded_rng = SyRandomNumberGenerator.new()


func setup_rng() -> String:
	seeded_rng.previous_seed = seeded_rng.current_seed
	var new_seed:String = _get_seed(seed_length)
	if force_debug_seed: new_seed = debug_seed
	var new_hash:int = hash(new_seed)
	run_seed = new_seed
	run_seed_hash = new_hash
	seeded_rng.current_seed = new_seed
	seeded_rng.set_seed(run_seed_hash)
	return new_seed


func setup_player() -> void:
	if player_data != null: 
		var temp = player_data
		temp.queue_free.call_deferred()
	player_data = PlayerData.new()
	player_data.current_deck = STARTER_DECK
	player_data.current_deck.shuffle_deck()


func _get_seed(_length:int) -> String:
	var _seed:String = ""
	var l = SEED_OPTIONS.length() - 1
	for i in _length:
		_seed += SEED_OPTIONS[(randi_range(0,l))]
	return _seed


func _check_ui_btn(_id:String, _menu:String) -> void:
	if _id == "Play":
		setup_rng()
		setup_player()
		player_data.update_all_resources()


func _add_resource(_type:CardData.Resource_Type, _amount:int) -> void:
	player_data.add_resource(_type, _amount)


func _use_resource(_type:CardData.Resource_Type, _amount:int) -> void:
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
