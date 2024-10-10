class_name DiscardLayer extends Control


@onready var discard_panel:PanelContainer = %discard_panel
@onready var exit_btn:Button = %exit_btn
@onready var discard_control:Control = %discard_control


func _ready() -> void:
	Signals.ToggleDiscard.connect(_toggle_display)
	exit_btn.pressed.connect(_btn_pressed)


func add_child_to_discard(_card:Card) -> void:
	var parent = _card.get_parent()
	if parent != null:
		if parent != discard_control:
			push_error(_card.name, " already has parent ", parent.name, ".")
		else:
			push_warning(_card.name, " already has parent ", parent.name, ".")
	else:
		discard_control.add_child.call_deferred(_card)


func remove_child_from_discard(_card:Card) -> void:
	var parent = _card.get_parent()
	if parent != null:
		if parent != discard_control:
			push_error(_card.name, " already has parent ", parent.name, ".")
		else:
			discard_control.remove_child.call_deferred(_card)
	else:
		push_warning(_card.name, " does not have a parent.")


func _toggle_display(_display:bool) -> void:
	set_deferred("z_index", Game.get_highest_card_z_index()+1)
	set_deferred("visible", _display)


func _btn_pressed() -> void:
	_toggle_display(false)