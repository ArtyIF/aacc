@icon("res://addons/aacc/icons/car_wheel.svg")
class_name CarWheel extends Node3D

@export_group("Shape")
## The radius of the wheel. Half of the wheel's size.
@export var wheel_radius: float = 0.3
## The extra radius of the wheel to make the car stick to the ground more.
@export var buffer_radius: float = 0.1
## The width of the wheel.
## 
## AACC's wheels currently use 2 raycasts for the wheels.
@export var wheel_width: float = 0.3

@export_group("Suspension")
## The maximum length of the suspension.
##
## If the suspension length gets exceeded (because of the
## [member buffer_radius]), the suspension starts working in reverse, pulling
## the car to the ground instead of pushing it away from it. This can be useful
## to make the car stick to the ground better.
@export var suspension_length: float = 0.1
## The spring force the suspension applies.
@export var suspension_spring: float = 3000.0
## The damper applied to the spring force the suspension applies so it wasn't
## too springy and out of control.
@export var suspension_damper: float = 300.0

### NODES ###
var raycast_instance_1: RayCast3D
var raycast_instance_2: RayCast3D
var parent_car: Car

### COMPRESSION ###
var last_compression: float = 0.0
var last_compression_set: bool = false

### EXTERNAL ###
var is_colliding: bool = false
var collision_point: Vector3
var collision_normal: Vector3
var distance: float


func _ready():
	raycast_instance_1 = RayCast3D.new()
	raycast_instance_1.target_position = (
		Vector3.DOWN * (wheel_radius + suspension_length + buffer_radius)
	)
	raycast_instance_1.enabled = true
	raycast_instance_1.hit_from_inside = false
	raycast_instance_1.hit_back_faces = false
	raycast_instance_1.collision_mask = 1
	raycast_instance_1.process_physics_priority = -1000
	raycast_instance_1.transform = raycast_instance_1.transform.translated_local(
		Vector3.RIGHT * wheel_width
	)
	add_child(raycast_instance_1)

	raycast_instance_2 = RayCast3D.new()
	raycast_instance_2.target_position = (
		Vector3.DOWN * (wheel_radius + suspension_length + buffer_radius)
	)
	raycast_instance_2.enabled = true
	raycast_instance_2.hit_from_inside = false
	raycast_instance_2.hit_back_faces = false
	raycast_instance_2.collision_mask = 1
	raycast_instance_2.process_physics_priority = -1000
	add_child(raycast_instance_2)

	parent_car = get_parent() as Car


func _physics_process(delta: float):
	if raycast_instance_1.is_colliding() or raycast_instance_2.is_colliding():
		is_colliding = true

		var distance_1 = raycast_instance_1.global_position.distance_to(
			raycast_instance_1.get_collision_point()
		)
		var distance_2 = raycast_instance_2.global_position.distance_to(
			raycast_instance_2.get_collision_point()
		)

		if raycast_instance_1.is_colliding() and raycast_instance_2.is_colliding():
			collision_point = (
				raycast_instance_1.get_collision_point().
					lerp(raycast_instance_2.get_collision_point(), 0.5)
			)
			collision_normal = (
				raycast_instance_1.get_collision_normal().
					slerp(raycast_instance_2.get_collision_normal(), 0.5)
			)
			distance = lerp(distance_1, distance_2, 0.5)
		else:
			# TODO: DRY
			collision_point = (
				raycast_instance_1.get_collision_point()
				if raycast_instance_1.is_colliding()
				else raycast_instance_2.get_collision_point()
			)
			collision_normal = (
				raycast_instance_1.get_collision_normal()
				if raycast_instance_1.is_colliding()
				else raycast_instance_2.get_collision_normal()
			)
			distance = distance_1 if raycast_instance_1.is_colliding() else distance_2

		var compression: float = 1.0 - ((distance - wheel_radius) / suspension_length)
		if not last_compression_set:
			last_compression = compression
			last_compression_set = true

		if not parent_car.freeze:
			var suspension_magnitude: float = 0.0
			suspension_magnitude += compression * suspension_spring

			var compression_delta: float = (compression - last_compression) / delta
			suspension_magnitude += compression_delta * suspension_damper
			last_compression = compression

			suspension_magnitude *= collision_normal.dot(global_transform.basis.y)

			var global_parent_com: Vector3 = parent_car.to_global(Vector3.ZERO)
			parent_car.apply_force(
				collision_normal * suspension_magnitude, collision_point - global_parent_com
			)

		
	else:
		is_colliding = false
		last_compression = 0
