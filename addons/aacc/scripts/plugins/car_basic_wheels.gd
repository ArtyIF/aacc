## An AACC car plugin that applies simple suspension to the car. The wheels
## don't apply any torque force, other plugins are used for that instead.
class_name AACCPluginSuspension extends Node3D

@export_group("Transforms")
## The transforms of wheels that have the properties listed below. Also stores
## per-wheel information.
@export var wheels: Array[AACCSuspensionWheel] = []

@export_group("Shape")
## The radius of wheels. Half of the wheels' size.
@export var wheel_radius: float = 0.3
## The extra radius of wheels to make the car stick to the ground more.
@export var buffer_radius: float = 0.1
## The width of wheels.
## 
## AACC's wheels currently use 2 raycasts for the wheels.
@export var wheel_width: float = 0.3

@export_group("Suspension")
## The maximum length of the suspensions.
## [br][br]
## If the suspension length gets exceeded (because of the
## [member buffer_radius]), the suspension starts working in reverse, pulling
## the car to the ground instead of pushing it away from it. This can be useful
## to make the car stick to the ground better.
@export var suspension_length: float = 0.1
## The spring force the suspensions apply.
@export var suspension_spring: float = 3000.0
## The damper applied to the spring force the suspensions apply so they aren't
## too springy and out of control.
@export var suspension_damper: float = 300.0

@onready var _parent_car: AACCCar = owner as AACCCar


func _ready():
	for wheel in wheels:
		wheel.initialize(self)


func _physics_process(delta: float):
	for wheel in wheels:
		var force: float = wheel.calculate_force(delta)
		if wheel.is_colliding:
			force *= wheel.collision_normal.dot(global_transform.basis.y)
			
			var global_parent_com: Vector3 = _parent_car.to_global(Vector3.ZERO)
			_parent_car.add_force(wheel.collision_normal * force, wheel.collision_point - global_parent_com)
