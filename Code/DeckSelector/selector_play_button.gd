class_name SelectorPlayButton extends Button


@onready var selector:DeckSelectorMenu = get_parent() as DeckSelectorMenu


func _pressed() -> void:
	#print("selected event deck: ", selector.selected_event_deck)
	#print("selected player deck: ", selector.selected_player_deck)
	Signals.PlayWith.emit(selector.selected_event_deck, selector.selected_player_deck)
