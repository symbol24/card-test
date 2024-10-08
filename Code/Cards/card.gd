class_name Card extends CardPanelContainer


@export var move_delay:float = 0.2

@onready var cost_area:Control = %cost_area
@onready var title:RichTextLabel = %title
@onready var text:RichTextLabel = %text
@onready var card_area:Area2D = %card_area
@onready var image: TextureRect = %image

var data:CardData
var cost_grid:GridContainer


func _ready() -> void:
	super()


func discard() -> void:
	Signals.CardDiscarded.emit(self)


func setup_card(_card_data:CardData) -> void:
	if _card_data != null:
		data = _card_data
		if cost_grid != null: cost_grid.queue_free.call_deferred()
		cost_area.add_child.call_deferred(_set_up_cost(_card_data))
		title.text = _card_data.title
		text.text = _card_data.text
		if _card_data.image != null and _card_data.image is CompressedTexture2D:
			image.texture = _card_data.image


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
