class_name SaveIcon extends SyPanelContainer


@export var time_displayed:float = 5
@export var cycle_times:int = 3

@onready var save_icon: TextureRect = %save_icon


func _ready() -> void:
	Signals.DisplaySaveIcon.connect(_display_save_icon)
	set_modulate(Color.TRANSPARENT)


func _display_save_icon() -> void:
	Signals.ToggleUiMenu.emit("save_icon", true)
	var tween_time:float = (time_displayed/3)/2
	var tween:Tween = create_tween()
	tween.chain()
	for i in cycle_times:
		tween.tween_property(self, "modulate", Color.WHITE, tween_time)
		tween.tween_property(self, "modulate", Color.TRANSPARENT, tween_time)
	await tween.finished
	
	Signals.ToggleUiMenu.emit("save_icon", false)
