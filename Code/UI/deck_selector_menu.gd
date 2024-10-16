class_name DeckSelectorMenu extends MenuControl


@onready var event_hbox:HBoxContainer = %event_hbox
@onready var player_hbox:HBoxContainer = %player_hbox
@onready var play_button:Button = %play_button
@onready var seed_rtl:RicherTextLabel = %seed_rtl

var selected_event_deck:String = ""
var selected_player_deck:String = ""
var event_buttons:Array[DeckSelectorButton]
var player_buttons:Array[DeckSelectorButton]


func _ready() -> void:
	Signals.SelectDeck.connect(_set_deck)
	play_button.disabled = true
	_build_selector_buttons(DeckData.Type.EVENT)
	_build_selector_buttons(DeckData.Type.PLAYER)
	if not seed_rtl.is_node_ready(): await seed_rtl.ready
	_set_seed()
	Manager.ToggleLoadingScreen.emit(false)


func _set_seed() -> void:
	Game.setup_rng()
	seed_rtl.set_deferred("bbcode", tr("seed_rtl") + " " + Game.seeded_rng.current_seed)


func _build_selector_buttons(_type:DeckData.Type) -> void:
	var decks:Array[DeckData]
	var hbox:HBoxContainer
	var selector:DeckSelectorButton
	match _type:
		DeckData.Type.EVENT:
			decks = Game.data_manager.event_decks
			hbox = event_hbox
			selector = Game.data_manager.event_deck_selector_button.instantiate()
		DeckData.Type.PLAYER:
			decks = Game.data_manager.player_decks
			hbox = player_hbox
			selector = Game.data_manager.player_deck_selector_button.instantiate()
	for deck in decks:
		var button:DeckSelectorButton = selector.duplicate()
		button.name = deck.id
		button.text = tr(deck.id)
		button.setup_button_data(deck.id, deck.type)
		hbox.add_child.call_deferred(button)
		event_buttons.append(button)


func _set_deck(_id:String, _type:DeckData.Type) -> void:
	match _type:
		DeckData.Type.PLAYER:
			selected_player_deck = _id
		DeckData.Type.EVENT:
			selected_event_deck = _id
	
	if selected_player_deck != "" and selected_event_deck != "":
		play_button.disabled = false
	else:
		play_button.disabled = true