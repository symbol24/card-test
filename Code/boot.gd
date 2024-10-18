extends Node2D

func _ready() -> void:
	#Signals.DeleteSave.emit()
	Signals.LoadManagers.emit()
	await Signals.AllManagersLoaded
	Signals.Load.emit()
	Manager.load_scene(1)
