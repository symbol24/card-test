class_name Card extends CardPanelContainer

@export var move_delay:float = 0.2

@onready var cost_area:Control = %cost_area
@onready var title:RichTextLabel = %title
@onready var text:RichTextLabel = %text
@onready var image_sprite:Sprite2D = %image
@onready var card_area:Area2D = %card_area

var data:CardData
var in_area:bool = false
var is_dragged:bool = false
var connection_point:Vector2

func _input(_event: InputEvent) -> void:
	if Input.is_action_pressed("mouse_left") and in_area and not is_dragged:
		_click_card()
	
	elif Input.is_action_just_released("mouse_left") and is_dragged:
		is_dragged = false
		connection_point = Vector2.ZERO
		

func _ready() -> void:
	super()
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)

func _physics_process(delta: float) -> void:
	if is_dragged:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "global_position", get_global_mouse_position()-connection_point, delta+move_delay)

func _click_card() -> void:
	connection_point = get_local_mouse_position()
	is_dragged = true
	z_index = Game.get_highest_card_z_index() + 1

func _mouse_entered() -> void:
	in_area = true


func _mouse_exited() -> void:
	in_area = false
