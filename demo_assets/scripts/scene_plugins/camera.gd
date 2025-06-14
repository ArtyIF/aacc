class_name AACCDemoCamera extends ScenePluginBase

@onready var camera: Camera3D = $Camera
@onready var follow_node: Node3D
@onready var follow_offset_node: Node3D
@onready var hood_camera_node: Node3D

@onready var last_position: Vector3 = camera.global_position
@onready var direction_target: Vector3 = camera.global_basis.z
@onready var smoothed_direction: Vector3 = camera.global_basis.z
@onready var up_vector_target: Vector3 = Vector3.UP
@onready var smoothed_up_vector: Vector3 = Vector3.UP

var use_hood_camera: bool = false

var plugin_wp: CarWheelsProcessor

func _ready() -> void:
	process_priority = 1000

func _on_car_changed(new_car: Car) -> void:
	super(new_car)
	if is_instance_valid(car):
		plugin_wp = car.get_plugin(&"WheelsProcessor")
		# TODO: use a plugin instead
		follow_node = car.get_node(^"Visuals")
		follow_offset_node = car.get_node(^"FollowCameraOffset")
		hood_camera_node = car.get_node(^"HoodCamera")

func _process(delta: float) -> void:
	if not is_instance_valid(car):
		last_position = Vector3.ZERO
		direction_target = -Vector3.FORWARD
		smoothed_direction = -Vector3.FORWARD
		up_vector_target = Vector3.UP
		smoothed_up_vector = Vector3.UP
		return

	var smooth_amount_direction: float = 10.0
	var smooth_amount_up: float = 10.0
	var node_transform: Transform3D = hood_camera_node.get_global_transform_interpolated() if use_hood_camera else follow_node.get_global_transform_interpolated()

	if use_hood_camera:
		camera.global_position = node_transform.origin
		direction_target = node_transform.basis.z
		up_vector_target = node_transform.basis.y
	else:
		up_vector_target = plugin_wp.ground_average_normal
		var velocity: Vector3 = (last_position - node_transform.origin) / delta
		velocity = velocity.slide(up_vector_target)
		smooth_amount_direction = clamp(remap(velocity.length(), 0.0, 10.0, 0.0, 10.0), 0.0, 10.0)
		if not velocity.is_zero_approx():
			direction_target = velocity.normalized()
		smooth_amount_up = 1.0

	if Input.is_action_just_pressed(&"aaccdemo_camera"):
		smoothed_up_vector = up_vector_target
		smoothed_direction = direction_target
		use_hood_camera = not use_hood_camera

	if up_vector_target.distance_to(smoothed_up_vector) > 0.001:
		smoothed_up_vector = smoothed_up_vector.slerp(up_vector_target, delta * smooth_amount_up)
	if direction_target.distance_to(smoothed_direction) > 0.001:
		smoothed_direction = smoothed_direction.slerp(direction_target, delta * smooth_amount_direction)
		smoothed_direction = smoothed_direction.slide(smoothed_up_vector).normalized()
	camera.global_basis = Basis.looking_at(-smoothed_direction, smoothed_up_vector)

	if not use_hood_camera:
		var follow_camera_offset: Vector3 = follow_offset_node.position
		camera.global_position = node_transform.origin + (smoothed_direction * follow_camera_offset.z) + (smoothed_up_vector * follow_camera_offset.y)

	last_position = follow_node.get_global_transform_interpolated().origin
