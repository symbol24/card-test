class_name DeckData extends Resource

enum Type {
			PLAYER = 0,
			EVENT = 1,
		  }

@export var id:String = ""
@export var cards:Array[CardData] = []
@export var type:Type
@export var tween_time:float = 0.3
@export var round_draw_amount:int = 3
@export var starting_hp:int = 3

var play_cards:Array[CardData]
var is_deck_empty:bool:
	get:
		return play_cards.is_empty()
var discard:Array[CardData] = []


func draw_card() -> CardData:
	if play_cards.is_empty(): 
		push_error(id, " deck has not been shuffled")
	return play_cards.pop_front()


func setup_deck() -> void:
	if type == Type.EVENT:
		play_cards = cards.duplicate(true)
	else:
		play_cards = shuffle_deck(cards)


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


func _debug_print_cards(_cards:Array[CardData]) -> void:
	for card in _cards:
		print(card.id)
	print("------")
