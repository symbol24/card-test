extends Node2D

func _ready() -> void:
	Signals.LoadDataManager.emit()
	Signals.Load.emit()
	Manager.load_scene(1)
