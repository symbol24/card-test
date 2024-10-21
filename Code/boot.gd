extends Node2D

func _ready() -> void:
	#Signals.DeleteSave.emit()
	Signals.LoadManagers.emit()
	await Signals.AllManagersLoaded
	Signals.Load.emit()
	await get_tree().create_timer(1).timeout
	Signals.LoadScene.emit("main_menu")
	queue_free.call_deferred()
