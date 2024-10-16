extends Node


const SEED_OPTIONS:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@$%^&*?"
const DATAMANAGER = "res://Scenes/Utilities/data_manager.tscn"


@export var seed_length:int = 10
@export var force_debug_seed:bool = false
@export var debug_seed:String = ""
@export var use_btn_hide_delay:float = 5
@export var delay_to_discard:float = 0.2
@export var card_spawn_time:float = 0.3
@export var new_card_wait:float = 1
@export var check_fail_delay:float = 5
@export var post_check_delay:float = 10

# Game Elements
var discard_pile:Discard
var card_layer:Control
var discard_layer:DiscardLayer
var player_deck_button:DeckButton
var event_deck_button:DeckButton

# RNG
var run_seed:String = ""
var run_seed_hash:int
var seeded_rng:SyRandomNumberGenerator

# Player data and data management
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
var discarded_player_cards:Array[Card] = []
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

# Check Fail
var checking_fail:bool = false


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	seeded_rng = SyRandomNumberGenerator.new()
	Signals.PlayWith.connect(_set_decks)
	Signals.DiscardReady.connect(_set_play_variables)
	Signals.AddResource.connect(_add_resource)
	Signals.UseResource.connect(_use_resource)
	Signals.LoadDataManager.connect(_setup_data_manager)
	Signals.CheckCardsOnCard.connect(_check_card_completion)
	Signals.DiscardCard.connect(_discard_player_card)
	Signals.UseCard.connect(_use_card)
	Signals.CompleteCard.connect(_complete_card)
	Signals.DrawCards.connect(_multiple_draw_card)
	Signals.PayResourceFromCard.connect(_pay_resource_from_card)
	Signals.ShuffleDeck.connect(_shuffle_discard_under_deck)
	Signals.CheckFailState.connect(_check_fail_coroutine)
	Signals.ResetGameData.connect(_reset_data)


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
		player_data = null
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
		current_event_deck = data_manager.get_deck(_id, _type).duplicate(true)
		current_event_deck.setup_deck()
	else:
		player_data.current_deck = data_manager.get_deck(_id, _type).duplicate(true)
		player_data.current_deck.setup_deck()


func toggle_pause(value:bool = false) -> void:
	get_tree().paused = value


func reset_decks() -> void:
	current_event_deck.setup_deck()
	player_data.current_deck.setup_deck()


func _set_play_variables(_disc:Discard) ->void:
	discard_pile = _disc
	card_layer = get_tree().get_first_node_in_group("card_layer")
	discard_layer = get_tree().get_first_node_in_group("discard_layer")
	player_deck_button = get_tree().get_first_node_in_group("player_deck")
	event_deck_button = get_tree().get_first_node_in_group("event_deck")


func _set_decks(_event_id:String,_player_id:String) -> void:
	load_deck(_event_id, DeckData.Type.EVENT)
	load_deck(_player_id, DeckData.Type.PLAYER)


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
	player_data.use_resource(_type, _amount)


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
	_receiver.data.reset_cost_payed()
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
				#print("Used card: ", each["card"].name)
				used_payers.append(each["card"])
	_receiver.used_cards = used_payers

	for c in costs:
		if c["payed"]:
			_receiver.data.set_cost_payed(c["type"], true)
	
	_check_card_cost_payed(_receiver)


func _check_card_cost_payed(_card:Card) -> void:
	if not _card.data.costs.is_empty():
		if _card.data.cost_payed:
			if _card.data.has_only_payables:
				Signals.ToggleCardForButton.emit(UiCardButton.Type.COMPLETE, _card, true)
			else:
				Signals.ToggleCardForButton.emit(UiCardButton.Type.COMPLETE, _card, true)
		else:
			Signals.ToggleCardForButton.emit(UiCardButton.Type.COMPLETE, _card, false)


func _use_card(_card:Card) -> void:
	var energy:Cost = _card.data.get_resource(CardData.Resource_Type.ENERGY)
	if energy != null:
		Signals.AddResource.emit(energy.cost_type, energy.cost_amount)
		var tween:Tween = _card.create_tween()
		tween.tween_property(_card, "global_position", discard_pile.global_position, delay_to_discard)
		await tween.finished
		_discard_player_card(_card)


func _pay_resource_from_card(_card:Card) -> void:
	var resources:Array[Cost] = _card.data.costs
	if not resources.is_empty():
		for each in resources:
			if each.cost_type in _card.data.payables:
				if player_data.check_available_resource(each.cost_type, each.cost_amount):
					Signals.UseResource.emit(each.cost_type, each.cost_amount)
					each.payed = true
				else:
					Signals.NotifyResourceEmpty.emit(each.cost_type)
		
		Signals.ToggleCardForButton.emit(UiCardButton.Type.PAY, _card, false)
		_check_card_cost_payed(_card)


func _complete_card(_card:Card) -> void:
	if _card.is_in_group("player_card"):
		if _card.data.type == CardData.Card_Type.RESOURCE:
			for each in _card.data.resources:
				Signals.AddResource.emit(each.cost_type, each.cost_amount)
		
	elif _card.is_in_group("event_card"):
		var reward_array:Array[CardData] = _card.data.get_reward()
		for reward in reward_array:
			if reward.type == CardData.Card_Type.SUCCESS:
				Signals.DisplayResultScreen.emit(reward.id, true)
			elif reward.type == CardData.Card_Type.NOTHING:
				Signals.DisplaySmallPopup.emit("No reward received.", 3)
			else:
				_add_player_card(reward, Vector2((1920/2)-100, (1080/2)-150))
				Signals.DisplaySmallPopup.emit(reward.id + " received.", 3)

	if not _card.used_cards.is_empty():
		for used in _card.used_cards:
			await used.move_card(used.global_position, discard_pile.global_position, delay_to_discard)
			_discard_player_card(used)

	_card.complete_card(discard_pile, delay_to_discard)


func _add_player_card(_card_data:CardData, _spawn_pos:Vector2) -> void:
	if _card_data != null:
		var new_card:Card = data_manager.default_player_card.instantiate()
		card_layer.add_child(new_card)
		new_card.setup_card(_card_data)
		new_card.z_index = get_highest_card_z_index() + 1
		new_card.global_position = _spawn_pos
		await get_tree().create_timer(new_card_wait).timeout
		await new_card.move_card(_spawn_pos, discard_pile.global_position, delay_to_discard)
		_discard_player_card(new_card)


func _multiple_draw_card(_type:DeckData.Type, _amount:int = 1, _use_cost:bool = false, _shuffle_player_cards:bool = false) -> void:
	if _type == DeckData.Type.PLAYER:
		for i in _amount:
			_draw_card(player_deck_button, _use_cost)

	elif _type == DeckData.Type.EVENT:
		var result:int = 0
		for i in _amount:
			result += _draw_card(event_deck_button, _use_cost)

		if result > 0 and _shuffle_player_cards:
			current_hand_count = 0
			layer = 0
			await _clear_active_player_cards()
			_shuffle_discard_under_deck()
			_multiple_draw_card(DeckData.Type.PLAYER, player_data.current_deck.round_draw_amount)


func _draw_card(_deck:DeckButton, _use_cost:bool = false) -> int:
	if _deck.deck_type == DeckData.Type.PLAYER:
		if not Game.player_data.current_deck.is_deck_empty:
			var draw:bool = true
			if _use_cost:
				if Game.player_data.check_available_resource(CardData.Resource_Type.ENERGY, 1):
					Game.player_data.use_resource(CardData.Resource_Type.ENERGY, 1)
				else:
					Signals.NotifyResourceEmpty.emit(CardData.Resource_Type.ENERGY)
					draw = false
			if draw: 
				_spawn_next_card(_deck)
				return 1
			else: 
				return 0
		else:
			Signals.NotifyDeckEmpty.emit(_deck)
			return 0
	else:
		if active_event_card != null:
			Signals.FlashCard.emit(active_event_card, Color.GREEN_YELLOW)
			return 0
		elif Game.current_event_deck.is_deck_empty:
			Signals.NotifyDeckEmpty.emit(_deck)
			return 0
		else:
			_spawn_next_card(_deck)
			return 1


func _spawn_next_card(_deck:DeckButton) -> void:
	var data_to_spawn:CardData = null
	if _deck.deck_type == DeckData.Type.EVENT:
		data_to_spawn = current_event_deck.draw_card()
	else:
		data_to_spawn = player_data.current_deck.draw_card()

	if data_to_spawn == null:
		Signals.NotifyDeckEmpty.emit(_deck)
		return

	var new_card = _get_card_scene(_deck.deck_type)

	card_layer.add_child.call_deferred(new_card)
	if not new_card.is_node_ready():
		await new_card.ready
	new_card.clear_data()
	new_card.setup_card(data_to_spawn)
	new_card.global_position = _deck.global_position
	new_card.z_index = Game.get_highest_card_z_index() + 1

	var final_pos:Vector2
	if _deck.deck_type == DeckData.Type.EVENT:
		active_event_card = new_card
		new_card.name = data_to_spawn.id
		final_pos = _deck.card_placement_pos.global_position
	else:
		active_player_cards.append(new_card)
		new_card.name = data_to_spawn.id + "_"+str(cards_amount)
		new_card.is_in_discard = false
		cards_amount += 1
		final_pos = Vector2(_deck.card_placement_pos.global_position.x + (50 * current_hand_count), _deck.card_placement_pos.global_position.y + (50 * layer))

	new_card.move_card(new_card.global_position, final_pos, card_spawn_time)

	current_hand_count += 1


func _discard_player_card(_card:Card) -> void:
	if _card.is_in_discard: return
	card_layer.remove_child.call_deferred(_card)
	discard_layer.add_child.call_deferred(_card)
	_card.set_deferred("global_position", Vector2(randf_range(300,1220), randf_range(200,450)))
	_card.discard()
	if discarded_player_cards.find(_card) == -1:
		discarded_player_cards.append(_card)
	active_player_cards.erase(_card)


func _shuffle_discard_under_deck() -> void:
	if discarded_player_cards.is_empty():
		Signals.NotifyDiscardEmpty.emit()
		return

	for each in discarded_player_cards:
		var data_to_add:CardData = each.data.duplicate(true)
		player_data.current_deck.discard.append(data_to_add)
		discard_layer.remove_child.call_deferred(each)
		_return_to_card_pool(each)
	discarded_player_cards.clear()
	player_data.current_deck.shuffle_discard_into_deck()


func _clear_active_player_cards() -> void:
	while not active_player_cards.is_empty():
		var each:Card = active_player_cards.pop_front()
		await each.move_card(each.global_position, discard_pile.global_position, delay_to_discard/2)
		_discard_player_card(each)


func _return_to_card_pool(_card:Card) -> void:
	if _card is EventCard:
		event_card_pool.append(_card)
	else:
		player_card_pool.append(_card)


func _get_card_scene(_type:DeckData.Type) -> Card:
	if _type == DeckData.Type.EVENT:
		if not event_card_pool.is_empty():
			var to_return:Card = event_card_pool.pop_front()
			to_return.clear_data()
			return to_return
		return data_manager.default_event_card.instantiate() as EventCard
	else:
		if not player_card_pool.is_empty():
			return player_card_pool.pop_front()
		return data_manager.default_player_card.instantiate() as Card


func _check_fail_coroutine() -> void:
	if not checking_fail:
		checking_fail = true
		await get_tree().create_timer(check_fail_delay).timeout
		var can_play:bool = _check_fail_state()
		if not can_play:
			var fail_id:String = player_data.current_deck.fail_id if player_data.current_deck.fail_id != "" else "generic_fail"
			Signals.DisplayResultScreen.emit(fail_id, false)
		else:
			await get_tree().create_timer(post_check_delay).timeout
		checking_fail = false


func _check_fail_state() -> bool:
	if active_event_card != null:
		var can_play:bool = false
		var card_costs:Array[Cost] = active_event_card.data.costs

		# check energy to draw
		if not can_play:
			#print("Checking energy: ", player_data.check_available_resource(CardData.Resource_Type.ENERGY, 1))
			if player_data.check_available_resource(CardData.Resource_Type.ENERGY, 1):
				can_play = true

		# Check each resource against active event card costs
		if not can_play:
			#print("Checking payable costs.")
			for cost in card_costs:
				if cost.cost_type in active_event_card.data.payables:
					#print("Checking payable: ", player_data.check_available_resource(cost.cost_type, cost.cost_amount))
					if player_data.check_available_resource(cost.cost_type, cost.cost_amount):
						can_play = true
						break

		# check each active card against active event card
		if not can_play:
			#print("Checking active cards.")
			for each in active_player_cards:
				for res in each.data.resources:
					if not res.cost_type in active_event_card.data.payables:
						for cost in card_costs:
							#print("if player card resource >= event card cost: ", res.cost_type == cost.cost_type and res.cost_amount >= cost.cost_amount)
							if res.cost_type == cost.cost_type and res.cost_amount >= cost.cost_amount:
								can_play = true
								break

		# check active cards to gain energy
		if not can_play:
			#print("Checking if player has energy in active cards.")
			for each in active_player_cards:
				for res in each.data.resources:
					if res.cost_type == CardData.Resource_Type.ENERGY:
						can_play = true
						break

		return can_play
	return true


func _reset_data() -> void:
	if active_event_card != null:
		active_event_card.queue_free()
	active_event_card = null
	active_player_cards.clear()
	discarded_player_cards.clear()
	current_hand_count = 0
	layer = 0
	current_hand_count = 0
	checking_fail = false


func _print_cards(_array:Array[Card]) -> void:
	if not _array.is_empty():
		for each in _array:
			print("Card id: ", each)
	print("Total cards: ", _array.size())


func _print_payed(_array:Array[Cost]) -> void:
	if not _array.is_empty():
		for each in _array:
			print("Cost type: ", each.cost_type, " and is payed: ", each.payed)
	print("------------")
