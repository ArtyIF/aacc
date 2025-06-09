class_name AACCDemoCarSelect extends ScenePluginBase

@export var first_button: Button

func _process(_delta: float) -> void:
	if not car:
		if not $"CarSelect".visible:
			first_button.call_deferred(&"grab_focus")
		$"CarSelect".visible = true
	else:
		$"CarSelect".visible = false
		if Input.is_action_just_pressed("aaccdemo_change_car"):
			car.queue_free()
