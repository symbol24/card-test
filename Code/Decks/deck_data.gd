class_name DeckData extends Resource

enum Type {
			PLAYER = 0,
			EVENT = 1,
		  }

@export var id:String = ""
@export var cards:Array[CardData] = []
@export var fail_id:String = ""
@export var type:Type
@export var tween_time:float = 0.3
@export var round_draw_amount:int = 3
@export var starting_hp:int = 3
@export var starting_energy:int = 5
@export var starting_weapons:int = 0

var play_cards:Array[CardData]
var is_deck_empty:bool:
	get:
		return play_cards.is_empty()
var discard:Array[CardData] = []


func draw_card() -> CardData:
	if play_cards.is_empty():
		push_error(id, " deck has not been shuffled")
	elif play_cards.size() == 1: 
		Signals.ToggleShuffleButton.emit(true)
	return play_cards.pop_front()


func setup_deck() -> void:
	play_cards = _set_card_datas(cards)
	if type == Type.PLAYER:
		var temp = play_cards.duplicate(true)
		play_cards = shuffle_deck(temp)


func shuffle_deck(_to_shuffle:Array[CardData]) -> Array[CardData]:
	Game.seeded_rng.check_seed_changed()
	var new_deck:Array[CardData]
	var dupe:Array[CardData] = _to_shuffle.duplicate(true)
	for i in _to_shuffle.size():
		var x:int = Game.seeded_rng.randi_range(0, dupe.size()-1)
		new_deck.append(dupe.pop_at(x))
	return new_deck


func shuffle_discard_into_deck() -> void:
	var temp:Array[CardData] = shuffle_deck(discard)
	play_cards.append_array(temp)
	discard.clear()


func _set_card_datas(_cards:Array[CardData]) -> Array[CardData]:
	var new_datas:Array[CardData] = []
	for each in _cards:
		var new_data:CardData = each.duplicate()
		new_data.costs.clear()
		for cost in each.costs:
			new_data.costs.append(cost.duplicate())
		new_data.resources.clear()
		for res in each.resources:
			new_data.resources.append(res.duplicate())
		new_data.rewards.clear()
		for reward in each.rewards:
			new_data.rewards.append(reward.duplicate())
		new_datas.append(new_data)
	return new_datas


func _debug_print_cards(_cards:Array[CardData]) -> void:
	for card in _cards:
		print(card.id)
	print("------")
