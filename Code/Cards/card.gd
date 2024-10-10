class_name Card extends CardPanelContainer


@export var use_btn_hide_delay:float = 5
@export var delay_to_discard:float = 0.2

@onready var cost_area:Control = %cost_area
@onready var title:RichTextLabel = %title
@onready var text:RichTextLabel = %text
@onready var card_area:Area2D = %card_area
@onready var image: TextureRect = %image
@onready var btn_control:Control = %btn_control

var data:CardData
var cost_grid:GridContainer
var ui_button:Button = null
var overlapping_cards:Array[Card] = []
var used_cards:Array[Card]
var use_displayed:bool = false
var use_btn_timer_on:bool = false
var use_btn_timer:float = 0.0:
	set(value):
		use_btn_timer = value
		if use_btn_timer >= use_btn_hide_delay:
			use_btn_timer = 0.0
			_hide_button()
var is_in_discard:bool = false


func _ready() -> void:
	super()
	card_area.area_entered.connect(_area_entered)
	card_area.area_exited.connect(_area_exited)
	mouse_entered.connect(_display_use_button)
	mouse_exited.connect(_hide_use_button)


func _process(delta: float) -> void:
	if use_btn_timer_on: use_btn_timer += delta


func discard() -> void:
	is_in_discard = true
	if data.is_mandatory:
		for each in data.resources:
			Signals.AddResource.emit(each.cost_type, each.cost_amount)


func setup_card(_card_data:CardData) -> void:
	if _card_data != null:
		data = _card_data
		cost_grid = _set_up_cost(_card_data)
		cost_area.add_child.call_deferred(cost_grid)
		title.text = _card_data.title
		text.text = _card_data.text
		if _card_data.image != null and _card_data.image is CompressedTexture2D:
			image.texture = _card_data.image


func clear_data() -> void:
	if data != null:
		is_in_discard = false
		overlapping_cards.clear()
		used_cards.clear()
		use_displayed = false
		use_btn_timer_on = false
		use_btn_timer = 0.0
		data = null
		if cost_grid != null: cost_grid.queue_free.call_deferred()
		title.text = ""
		text.text = ""


func move_card(from:Vector2, to:Vector2, time:float) -> void:
	global_position = from
	var tween:Tween = create_tween()
	tween.tween_property(self, "global_position", to, time)
	await tween.finished


func _set_up_cost(_card_data:CardData) -> GridContainer:
	var grid:GridContainer = GridContainer.new()
	grid.columns = 1
	grid.custom_minimum_size = Vector2(20,20)
	var columns:int = 0
	for _cost:Cost in _card_data.costs:
		for count in _cost.cost_amount:
			var new_texture_rect:TextureRect = TextureRect.new()
			new_texture_rect.texture = _cost.cost_texture
			new_texture_rect.custom_minimum_size = Vector2(20,20)
			grid.add_child.call_deferred(new_texture_rect)
			columns += 1
	grid.columns = columns if columns > 0 else 1
	return grid


func _display_use_button() -> void:
	if not is_in_discard and data.type == CardData.Card_Type.RESOURCE and data.contains_resource(CardData.Resource_Type.ENERGY):
		Signals.ToggleCardForButton.emit(Game.data_manager.ui_use_btn, self, true)
		use_displayed = true


func _hide_use_button() -> void:
	if use_displayed:
		use_btn_timer_on = true
		use_btn_timer = 0.0


func _hide_button() -> void:
	use_btn_timer_on = false
	Signals.ToggleCardForButton.emit(null, self, false)		


func _area_entered(_area) -> void:
	var _enterer = _area.get_parent()
	print(data.id, " is considered in discrad? ", is_in_discard)
	if not is_in_discard and _enterer != null and _enterer is Card:
		print("Card entered: ", _enterer.data.id)
		overlapping_cards.append(_enterer)
		Signals.CheckCardsOnCard.emit(self, overlapping_cards)


func _area_exited(_area) -> void:
	var _enterer = _area.get_parent()
	if _enterer != null and _enterer is Card:
		overlapping_cards.erase(_enterer)
		Signals.CheckCardsOnCard.emit(self, overlapping_cards)


func _reshuffle() -> void:
	is_in_discard = false
