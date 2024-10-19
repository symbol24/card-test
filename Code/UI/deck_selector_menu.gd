class_name DeckSelectorMenu extends MenuControl


@export var check_delay:float = 5

@onready var event_hbox:HBoxContainer = %event_hbox
@onready var player_hbox:HBoxContainer = %player_hbox
@onready var play_button:Button = %play_button
@onready var seed_rtl:RichTextLabel = %seed_rtl

var selected_event_deck:String = ""
var selected_player_deck:String = ""
var buttons:Array[DeckSelectorButton]


func _ready() -> void:
	#print("in Deck selector menu ready")
	Signals.SelectDeck.connect(_set_deck)
	Signals.UnlockDeckInSave.connect(_unlock_displayed_deck)
	play_button.disabled = true
	_build_selector_buttons(DeckData.Type.EVENT)
	_build_selector_buttons(DeckData.Type.PLAYER)
	if not seed_rtl.is_node_ready(): await seed_rtl.ready
	_set_seed()
	Game.setup_player()
	Manager.ToggleLoadingScreen.emit(false)
	await get_tree().create_timer(check_delay).timeout
	Signals.CheckDeckUnlock.emit()


func _set_seed() -> void:
	Game.setup_rng()
	seed_rtl.set_deferred("text", tr("seed_rtl") + Game.seeded_rng.current_seed)


func _build_selector_buttons(_type:DeckData.Type) -> void:
	var decks:Array[DeckData]
	var hbox:HBoxContainer
	var selector:DeckSelectorButton
	#print("PLAYER Decks unlocked: ", SaveSystem.data.unlocked_player_decks)
	#print("EVENT Decks unlocked: ", SaveSystem.data.unlocked_event_decks)
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
		buttons.append(button)
		
		if not deck.starter_deck and not SaveSystem.data.is_deck_unlocked_by_id(deck.id):
			button.set_disabled(true)
			button.set_visible(false)
		

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


func _unlock_displayed_deck(_data:DeckData) -> void:
	var to_display:String = tr("unlocked_deck_message")
	# TODO: Parse text to display right message
	Signals.DisplaySmallPopup.emit(to_display)
	# TODO: Add animation for unlock
	for each in buttons:
		if each.name == _data.id:
			each.set_visible(true)
			each.set_disabled(false)
