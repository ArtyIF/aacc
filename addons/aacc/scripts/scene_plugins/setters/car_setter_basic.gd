class_name CarSetterBasic extends ScenePluginBase
@export var car_to_set: Car

func set_car() -> void:
	AACCGlobal.car = car_to_set

func _ready() -> void:
	set_car()

#func _physics_process(_delta: float) -> void:
#	set_car()
