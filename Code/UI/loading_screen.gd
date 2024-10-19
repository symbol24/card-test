class_name CardLoadingScreen extends SyPanelContainer


@onready var loading_label:RichTextAnimation = %loading_label

var text = "loading_text"


func _ready() -> void:
	loading_label.anim_finished.connect(reset_progress)
	text = tr("loading_text")
	loading_label.bbcode = text


func reset_progress() -> void:
	await get_tree().create_timer(1).timeout
	loading_label.bbcode = text