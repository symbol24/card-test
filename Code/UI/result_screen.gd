class_name ResultScreen extends SyPanelContainer


@onready var btn_result_return:Button = %btn_result_return
@onready var btn_result_retry:Button = %btn_result_retry
@onready var result_title:RicherTextLabel = %result_title
@onready var result_text:RicherTextLabel = %result_text


func set_title(_success:bool = false) -> void:
	if not result_title.is_node_ready():
		await result_title.ready
	var text:String = tr("result_title_success") if _success else tr("result_title_failure")
	result_title.set_deferred("bbcode", text)


func set_result_text(_result_id:String) -> void:
	if not result_text.is_node_ready():
		await result_text.ready
	result_text.set_deferred("bbcode", tr(_result_id))


func set_buttons(_success:bool = false) -> void:
	if not btn_result_return.is_node_ready():
		await btn_result_return.ready
	if not btn_result_retry.is_node_ready():
		await btn_result_retry.ready
	if _success:
		btn_result_return.set_deferred("visible", true)
		btn_result_retry.set_deferred("visible", false)
	else:
		btn_result_return.set_deferred("visible", true)
		btn_result_retry.set_deferred("visible", true)
