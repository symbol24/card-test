extends Node


const SEED_OPTIONS:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@$%^&*?"
const DATAMANAGER = "res://Scenes/Utilities/data_manager.tscn"


@export var seed_length:int = 10
@export var force_debug_seed:bool = false
@export var debug_seed:String = ""
@export var use_btn_hide_delay:float = 5
@export var delay_to_discard:float = 0.2

# Game Elements
var discard_pile:Discard
var card_layer:Control

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

# Cards
var player_card_pool:Array[Card] = []
var event_card_pool:Array[Card] = []
var active_event_card:EventCard
var active_player_cards:Array[Card]
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
	Signals.DrawCard.connect(_draw_card)


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
	card_layer = get_tree().get_first_node_in_group("card_layer")


func _use_card(_card:Card) -> void:
	var energy:Cost = _card.data.get_resource(CardData.Resource_Type.ENERGY)
	if energy != null:
		Signals.AddResource.emit(energy.cost_type, energy.cost_amount)
		var tween:Tween = _card.create_tween()
		tween.tween_property(_card, "global_position", discard_pile.global_position, delay_to_discard)
		await tween.finished
		Signals.DiscardCard.emit(_card)
	

func _complete_card(_card:Card) -> void:
	if _card.is_in_group("player_card") and _card.data.type == CardData.Card_Type.RESOURCE:
		for each in _card.data.resources:
			Signals.AddResource.emit(each.cost_type, each.cost_amount)
	elif _card.is_in_group("event_card"):
		for reward in _card.data.get_reward():
			if reward.type != CardData.Card_Type.NOTHING:
				Signals.AddNewPlayerCard.emit(reward)
			else:
				Signals.DisplayNothingReward.emit()
	
	var tween:Tween
	for used in _card.used_cards:
		tween = used.create_tween()
		tween.tween_property(used, "global_position", discard_pile.global_position, delay_to_discard)
		await tween.finished
		Signals.DiscardCard.emit(used)

	if _card.is_in_group("player_card"):
		tween = _card.create_tween()
		tween.tween_property(_card, "global_position", discard_pile.global_position, delay_to_discard)
		await tween.finished
		Signals.DiscardCard.emit(_card)

	elif _card.is_in_group("event_card"):
		_card.queue_free.call_deferred()


func _add_player_card(_card_data:CardData) -> void:
	if _card_data != null:
		var new_card:Card = data_manager.default_player_card.instantiate()


func _draw_card(_deck:Deck) -> void:
	if _deck.deck_type == DeckData.Type.PLAYER:
		if Game.player_data.check_available_resource(CardData.Resource_Type.ENERGY, 1) and not Game.player_data.current_deck.is_deck_empty:
			_spawn_next_card(_deck)
			Game.player_data.use_resource(CardData.Resource_Type.ENERGY, 1)
		elif not Game.player_data.check_available_resource(CardData.Resource_Type.ENERGY, 1):
			Signals.NotifyResourceEmpty.emit(CardData.Resource_Type.ENERGY)
		elif Game.player_data.current_deck.is_deck_empty:
			Signals.NotifyDeckEmpty.emit(_deck)
	else:
		if Game.current_event_deck.is_deck_empty:
			Signals.NotifyDeckEmpty.emit(_deck)
		elif active_event_card != null:
			active_event_card.flash_card(Color.GREEN_YELLOW)
			#Signals.FlashCard.emit(active_event_card, Color.GREEN_YELLOW)
		else:
			_spawn_next_card(_deck)


func _spawn_next_card(_deck:Deck) -> void:
	var data_to_spawn:CardData
	if _deck.deck_type == DeckData.Type.EVENT:
		data_to_spawn = current_event_deck.draw_card()
	else:
		data_to_spawn = player_data.current_deck.draw_card()

	var new_card = _get_card_scene(_deck.deck_type)
	if _deck.deck_type == DeckData.Type.EVENT:
		active_event_card = new_card
	else:
		active_player_cards.append(new_card)

	card_layer.add_child.call_deferred(new_card)
	await new_card.ready
	new_card.setup_card(data_to_spawn)
	new_card.global_position = _deck.global_position
	new_card.z_index = Game.get_highest_card_z_index() + 1
	var final_pos:Vector2
	if _deck.deck_type == DeckData.Type.EVENT:
		new_card.name = "event_card"
		final_pos = _deck.card_placement_pos.global_position
	else:
		new_card.name = "card_"+str(cards_amount)
		cards_amount += 1
		final_pos = Vector2(_deck.card_placement_pos.global_position.x + (50 * current_hand_count), _deck.card_placement_pos.global_position.y + (50 * layer))

	var tween:Tween = new_card.create_tween()
	tween.tween_property(new_card, "global_position", final_pos, _deck.tween_time)
	current_hand_count += 1


func _get_card_scene(_type:DeckData.Type) -> Card:
	if _type == DeckData.Type.EVENT:
		if not event_card_pool.is_empty():
			return event_card_pool.pop_front()
		return data_manager.default_event_card.instantiate() as EventCard
	else:
		if not player_card_pool.is_empty():
			return player_card_pool.pop_front()
		return data_manager.default_player_card.instantiate() as Card



#func _draw_card() -> void:
#	var to_draw:CardData = Game.player_data.current_deck.draw_card()
#	if deck_type == DeckData.Type.EVENT: to_draw = Game.current_event_deck.draw_card()
#	var new_card = _get_card_scene()
#	active_cards.append(new_card)
#	card_layer.add_child.call_deferred(new_card)
#	await new_card.ready
#	new_card.setup_card(to_draw)
#	new_card.global_position = global_position
#	new_card.z_index = Game.get_highest_card_z_index() + 1
#	new_card.name = "card_"+str(cards_amount)
#	cards_amount += 1
#	var tween:Tween = new_card.create_tween()
#	var final_pos:Vector2 = Vector2(card_placement_pos.global_position.x + (50 * current_hand_count), card_placement_pos.global_position.y + (50 * layer))
#	tween.tween_property(new_card, "global_position", final_pos, tween_time)
#	current_hand_count += 1