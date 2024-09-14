class_name DeckData extends Resource

enum Type {
			Player,
			Event
		  }

@export var id:String = ""
@export var cards:Array[CardData] = []


func shuffle_deck() -> void:
	_debug_print_cards(cards)
	Game.seeded_rng.check_seed_changed()
	var new_deck:Array[CardData]
	for i in cards.size():
		var x:int = Game.seeded_rng.randi_range(0, cards.size()-1)
		new_deck.append(cards.pop_at(x))
	cards = new_deck
	_debug_print_cards(cards)


func _debug_print_cards(_cards:Array[CardData]) -> void:
	for card in _cards:
		print(card.id)
	print("------")
