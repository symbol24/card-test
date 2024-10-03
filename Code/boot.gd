extends Node2D

func _ready() -> void:
	Signals.LoadDataManager.emit()
	Manager.load_scene(1)
