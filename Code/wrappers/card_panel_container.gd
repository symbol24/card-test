class_name CardPanelContainer extends PanelContainer


@onready var collider:CollisionShape2D = %collider

func _ready() -> void:
	Signals.ToggleColliders.connect(_toggle_collider)

func _toggle_collider(_value:bool) -> void:
	collider.set_deferred("disabled", _value)
