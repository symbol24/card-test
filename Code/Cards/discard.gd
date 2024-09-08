class_name Discard extends CardPanelContainer

@onready var discard_area:Area2D = %discard_area
@onready var discard_hidden_panel:Control = %DiscardHiddenArea

var card:Card
var in_area:bool = false
var discarded:Array[Card] = []
var over_outside_over_panel:bool = false
var entered_from_discard:bool = false

func _input(_event: InputEvent) -> void:
    if Input.is_action_just_pressed("mouse_left") and in_area:
        _toggle_hidden_panel()

    if Input.is_action_just_pressed("mouse_left") and discard_hidden_panel.visible and over_outside_over_panel:
        _toggle_hidden_panel()

    if Input.is_action_just_released("mouse_left") and card != null and entered_from_discard:
        _card_released()

func _ready() -> void:
    super()
    Game.DiscardCard.connect(_discard_card)
    discard_area.area_entered.connect(_area_entered)
    discard_area.area_exited.connect(_area_exited)
    mouse_entered.connect(_mouse_entered)
    mouse_exited.connect(_mouse_exited)
    discard_hidden_panel.mouse_entered.connect(_discard_hidden_panel_mouse_entered)
    discard_hidden_panel.mouse_exited.connect(_discard_hidden_panel_mouse_exited)

func _discard_card(_card:Card) -> void:
    card = _card
    _card_released()

func _card_released() -> void:
    if card != null:
        var temp:Card = card
        print(card.get_parent())
        card.get_parent().remove_child(card)
        discard_hidden_panel.add_child.call_deferred(temp)
        temp.set_deferred("position", Vector2(randf_range(210,970), randf_range(110,450)))
        discarded.append(temp)

func _toggle_hidden_panel() -> void:
    discard_hidden_panel.set_deferred("visible", !discard_hidden_panel.visible)

func _mouse_entered() -> void:
    in_area = true

func _mouse_exited() -> void:
    in_area = false

func _discard_hidden_panel_mouse_entered() -> void:
    over_outside_over_panel = true

func _discard_hidden_panel_mouse_exited() -> void:
    over_outside_over_panel = false

func _area_entered(_area) -> void:
    if _area.get_parent() is Card:
        card = _area.get_parent()
        entered_from_discard = true

func _area_exited(_area) -> void:
    if _area.get_parent() == card:
        card = null
        entered_from_discard = false
