class_name DataManager extends Node


@export_category("PackedScenes")
@export var default_player_card:PackedScene
@export var default_player_deck:PackedScene
@export var default_event_card:PackedScene
@export var default_event_deck:PackedScene
@export var event_deck_selector_button:PackedScene
@export var player_deck_selector_button:PackedScene
@export var grabber_selector_panel:PackedScene

@export_category("Player Decks")
@export var player_decks:Array[DeckData]

@export_category("Event Decks")
@export var event_decks:Array[DeckData]


func get_deck(_id:String, _type:DeckData.Type) -> DeckData:
	var list = event_decks if _type == DeckData.Type.EVENT else player_decks
	for deck in list:
		if deck.id == _id: return deck
	
	push_error("No deck found with id: ", _id)
	return null
