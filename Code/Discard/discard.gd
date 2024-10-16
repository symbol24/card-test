class_name Discard extends Button


@export var flash_delay:float = 0.3

@onready var discard_area:Area2D = %discard_area

var card:Card
var in_area:bool = false
var discarded:Array[Card] = []
var over_outside_over_panel:bool = false
var entered_from_discard:bool = false


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_released("mouse_left") and card != null and entered_from_discard:
		Signals.DiscardCard.emit(card)


func _ready() -> void:
	discard_area.area_entered.connect(_area_entered)
	discard_area.area_exited.connect(_area_exited)
	Signals.DiscardReady.emit(self)
	Signals.NotifyDiscardEmpty.connect(_flash_discard)


func _pressed() -> void:
	Signals.ToggleDiscard.emit(true)


func _area_entered(_area) -> void:
	if _area.get_parent() is Card:
		card = _area.get_parent()
		entered_from_discard = true


func _area_exited(_area) -> void:
	if _area.get_parent() == card:
		card = null
		entered_from_discard = false


func _flash_discard(_color:Color = Color.RED) -> void:
	var tween:Tween = create_tween()
	tween.chain()
	tween.tween_property(self, "modulate", _color, flash_delay)
	tween.tween_property(self, "modulate", Color.WHITE, flash_delay)
