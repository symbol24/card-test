class_name Card extends CardPanelContainer


@export var use_btn_hide_delay:float = 5
@export var delay_to_discard:float = 0.2
@export var flash_delay:float = 0.3

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
var ui_btn_displayed:bool = false
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
	Signals.FlashCard.connect(_flash_card)
	card_area.area_entered.connect(_area_entered)
	card_area.area_exited.connect(_area_exited)
	mouse_entered.connect(_display_ui_button)
	mouse_exited.connect(_hide_ui_button)


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
		await _set_up_cost()
		title.text = _card_data.title
		text.text = _card_data.text
		if _card_data.image != null and _card_data.image is CompressedTexture2D:
			image.texture = _card_data.image


func clear_data() -> void:
	if data != null:
		is_in_discard = false
		overlapping_cards.clear()
		used_cards.clear()
		ui_btn_displayed = false
		use_btn_timer_on = false
		use_btn_timer = 0.0
		data = null
		if cost_grid != null: _clear_costs()
		if ui_button != null: 
			ui_button.queue_free()
			ui_button = null
		title.text = ""
		text.text = ""


func complete_card(_discard:Discard = null, _time:float = 0.2) -> void:
	if data.destroy_on_complete:
		queue_free.call_deferred()
	else:
		await move_card(global_position, _discard.global_position, _time)
		Signals.DiscardCard.emit(self)


func move_card(from:Vector2, to:Vector2, time:float) -> void:
	global_position = from
	var tween:Tween = create_tween()
	tween.tween_property(self, "global_position", to, time)
	await tween.finished


func _set_up_cost() -> GridContainer:
	var grid:GridContainer = GridContainer.new()
	grid.custom_minimum_size = Vector2(20,20)
	grid.columns = 1
	cost_area.add_child.call_deferred(grid)
	if not grid.is_node_ready():
		await grid.ready
	var columns:int = 0
	print("Card ", name, " has ", data.costs.size(), " costs.")
	for _cost:Cost in data.costs:
		var amount = _cost.cost_amount if _cost.cost_amount >= 0 else -_cost.cost_amount
		for count in amount:
			var new_texture_rect:TextureRect = TextureRect.new()
			new_texture_rect.texture = _cost.cost_texture
			new_texture_rect.custom_minimum_size = Vector2(20,20)
			grid.add_child.call_deferred(new_texture_rect)
			columns += 1
	print("card ", name, " has ", columns, " column(s)")
	grid.set_deferred("columns", columns)
	cost_grid = grid
	return grid


func _clear_costs() -> void:
	var children = cost_grid.get_children()
	for child in children:
		cost_grid.remove_child.call_deferred(child)
		child.queue_free.call_deferred()
	cost_grid.queue_free.call_deferred()
	set_deferred("cost_grid", null)


func _display_ui_button() -> void:
	if not is_in_discard :
		var btn_type:UiCardButton.Type = UiCardButton.Type.NONE
		var payable:Cost = data.get_payable()
		if data.type == CardData.Card_Type.RESOURCE and data.contains_resource(CardData.Resource_Type.ENERGY):
			btn_type = UiCardButton.Type.USE
		elif payable != null and not payable.payed:
			btn_type = UiCardButton.Type.PAY
		
		if btn_type != UiCardButton.Type.NONE:
			Signals.ToggleCardForButton.emit(btn_type, self, true)
			ui_btn_displayed = true


func _hide_ui_button() -> void:
	if ui_btn_displayed:
		use_btn_timer_on = true
		use_btn_timer = 0.0


func _hide_button() -> void:
	use_btn_timer_on = false
	Signals.ToggleCardForButton.emit(UiCardButton.Type.USE, self, false)		


func _area_entered(_area) -> void:
	var _enterer = _area.get_parent()
	if not is_in_discard and _enterer != null and _enterer is Card:
		overlapping_cards.append(_enterer)
		Signals.CheckCardsOnCard.emit(self, overlapping_cards)


func _area_exited(_area) -> void:
	var _enterer = _area.get_parent()
	if _enterer != null and _enterer is Card:
		overlapping_cards.erase(_enterer)
		Signals.CheckCardsOnCard.emit(self, overlapping_cards)
		print("Exited card: ", name)
		print("Used cards: ")
		Game._print_cards(used_cards)


func _reshuffle() -> void:
	is_in_discard = false


func _flash_card(_card:Card, _color:Color = Color.RED) -> void:
	if _card == self:
		var tween:Tween = self.create_tween()
		var time:float = flash_delay/2
		tween.tween_property(self, "modulate", _color, time)
		tween.tween_property(self, "modulate", Color.WHITE, time)