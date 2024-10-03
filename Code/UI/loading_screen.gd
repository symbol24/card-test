class_name CardLoadingScreen extends PanelContainer


@onready var loading_label:RichTextAnimation = %loading_label

var text = "Loading"


func _ready() -> void:
	loading_label.anim_finished.connect(reset_progress)


func reset_progress() -> void:
	loading_label.bbcode = text