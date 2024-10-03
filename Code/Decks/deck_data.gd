class_name DeckData extends Resource

enum Type {
			PLAYER = 0,
			EVENT = 1,
		  }

@export var id:String = ""
@export var cards:Array[CardData] = []
@export var type:Type

var play_cards:Array[CardData]
var is_deck_empty:bool:
	get:
		return play_cards.is_empty()


func draw_card() -> CardData:
	if play_cards.is_empty(): 
		push_error(id, " deck has not been shuffled")
	return play_cards.pop_front()


func setup_deck() -> void:
	if type == Type.EVENT:
		play_cards = cards.duplicate(true)
	else:
		shuffle_deck()


func shuffle_deck() -> void:
	Game.seeded_rng.check_seed_changed()
	var new_deck:Array[CardData]
	play_cards = cards.duplicate(true)
	for i in play_cards.size():
		var x:int = Game.seeded_rng.randi_range(0, play_cards.size()-1)
		new_deck.append(play_cards.pop_at(x))
	play_cards = new_deck


func _debug_print_cards(_cards:Array[CardData]) -> void:
	for card in _cards:
		print(card.id)
	print("------")
