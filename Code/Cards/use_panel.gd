class_name UsePanel extends CardPanelContainer

@onready var use_area:Area2D = %use_area

var card:Card

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_released("mouse_left") and card != null:
		_release_card()

func _ready() -> void:
	super()
	use_area.area_entered.connect(_area_entered)
	use_area.area_exited.connect(_area_exited)

func _release_card() -> void:
	Signals.UseCard.emit(card)
	Signals.DiscardCard.emit(card)

func _area_entered(_area) -> void:
	if _area.get_parent() is Card:
		card = _area.get_parent() as Card

func _area_exited(_area) -> void:
	if _area.get_parent() == card:
		card = null
