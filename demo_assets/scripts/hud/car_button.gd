extends Button

@export_file("*.tscn;TSCN", "*.scn;SCN", "*.res;RES") var car_path: String

func _ready() -> void:
	pressed.connect(_button_press)

func _button_press() -> void:
	var new_car: Car = load(car_path).instantiate()
	$"/root/DemoScene".add_child(new_car)
	AACCGlobal.car = new_car
