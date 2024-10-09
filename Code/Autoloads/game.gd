extends Node


const SEED_OPTIONS:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@$%^&*?"
const STARTER_DECK = preload("res://Data/Decks/starter_deck.tres")
const DATAMANAGER = "res://Scenes/Utilities/data_manager.tscn"


@export var seed_length:int = 10
@export var force_debug_seed:bool = false
@export var debug_seed:String = ""
@export var use_btn_hide_delay:float = 5
@export var delay_to_discard:float = 0.2


var discard_pile:Discard

var run_seed:String = ""
var run_seed_hash:int
var seeded_rng:SyRandomNumberGenerator

var player_data:PlayerData
var current_event_deck:DeckData
var data_manager:DataManager
var is_loading := false
var to_load := ""
var load_complete := false
var loading_status := 0.0
var progress := []


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	Signals.DiscardReady.connect(_set_discard)
	Signals.AddResource.connect(_add_resource)
	Signals.UseResource.connect(_use_resource)
	Signals.LoadDataManager.connect(_setup_data_manager)
	Signals.CheckCardsOnCard.connect(_check_card_completion)
	seeded_rng = SyRandomNumberGenerator.new()
	Signals.UseCard.connect(_use_card)
	Signals.CompleteCard.connect(_complete_card)


func _process(_delta: float) -> void:
	if is_loading:
		loading_status = ResourceLoader.load_threaded_get_status(to_load, progress)
		
		# When loading is complete in ResourceLoader, launch the _complete_load function.
		if loading_status == ResourceLoader.THREAD_LOAD_LOADED:
			if !load_complete:
				load_complete = true
				_complete_load()


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


func load_deck(_id:String, _type:DeckData.Type) -> void:
	if _type == DeckData.Type.EVENT:
		current_event_deck = data_manager.get_deck(_id, _type)
		current_event_deck.setup_deck()
	else:
		player_data.current_deck = data_manager.get_deck(_id, _type)
		player_data.current_deck.setup_deck()


func _setup_data_manager() -> void:
	to_load = DATAMANAGER
	ResourceLoader.load_threaded_request(to_load)
	is_loading = true
	load_complete = false
	progress.clear()
	loading_status = 0.0


func _complete_load() -> void:
	is_loading = false
	
	# Get the new level from the ResourceLoader and instantiate it.
	var new := ResourceLoader.load_threaded_get(to_load)
	var instantiated = new.instantiate()
	add_child.call_deferred(instantiated)

	match to_load:
		DATAMANAGER:
			data_manager = instantiated
		_:
			pass


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


func _reset_card_z_indexes() -> void:
	var all:Array[Card] = _get_all_cards()
	var z:int = 1
	for card in all:
		card.z_index = z
		z += 1


func _check_card_completion(_receiver:Card, _payers:Array[Card]) -> void:
	var costs:Array[Dictionary]
	var payments:Array[Dictionary]
	for each in _receiver.data.costs:
		var new_cost:Dictionary = {
									"type": each.cost_type,
									"tot_amount":each.cost_amount,
									"amount_payed":0,
									"payed":false,
									}
		costs.append(new_cost)

	for c in _payers:
		for each in c.data.resources:
			var new_res:Dictionary = {
									"type": each.cost_type,
									"tot_amount":each.cost_amount,
									"amount_used":0,
									"card":c
									}
			payments.append(new_res)
	
	for c in costs:
		for p in payments:
			if not c["payed"] and p["type"] == c["type"] and p["amount_used"] < p["tot_amount"]:
				var to_pay:int = c["tot_amount"] - c["amount_payed"]
				var amount_avail:int = p["tot_amount"] - p["amount_used"]
				if amount_avail > to_pay:
					amount_avail -= to_pay
				c["amount_payed"] += amount_avail
				p["amount_used"] += amount_avail

				if c["amount_payed"] == c["tot_amount"]:
					c["payed"] = true

	var used_payers:Array[Card] = []
	for each in payments:
		if each["amount_used"] > 0:
			if used_payers.find(each["card"]) == -1:
				used_payers.append(each["card"])
	_receiver.used_cards = used_payers

	var payed:int = 0
	for c in costs:
		if c["payed"]:
			payed += 1

	if not costs.is_empty() and payed == costs.size():
		Signals.ToggleCardForButton.emit(data_manager.ui_complete_btn, _receiver, true)
	else:
		Signals.ToggleCardForButton.emit(null, _receiver, false)


func _set_discard(_discard:Discard) ->void:
	discard_pile = _discard


func _use_card(_card:Card) -> void:
	var energy:Cost = _card.data.get_resource(CardData.Resource_Type.ENERGY)
	if energy != null:
		Signals.AddResource.emit(energy.cost_type, energy.cost_amount)
		var tween:Tween = _card.create_tween()
		tween.tween_property(_card, "global_position", discard_pile.global_position, delay_to_discard)
		await tween.finished
		Signals.DiscardCard.emit(_card)
	

func _complete_card(_card:Card) -> void:
	for each in _card.data.resources:
		Signals.AddResource.emit(each.cost_type, each.cost_amount)
	
	var tween:Tween
	for used in _card.used_cards:
		tween = used.create_tween()
		tween.tween_property(used, "global_position", discard_pile.global_position, delay_to_discard)
		await tween.finished
		Signals.DiscardCard.emit(used)

	tween = _card.create_tween()
	tween.tween_property(_card, "global_position", discard_pile.global_position, delay_to_discard)
	await tween.finished
	Signals.DiscardCard.emit(_card)
