extends CharacterBody3D

## Flight parameters
@export var max_speed := 12.0
@export var min_speed := 4.0
@export var acceleration := 0.7
@export var maneuverability := 3.0
@export var lift_factor := 0.6
@export var gravity := 9.8
@export var min_altitude := 3.0

## Wing parameters
@export var left_wing: Node3D
@export var right_wing: Node3D
@export var max_flap_angle := 70.0
@export var flap_speed := 6.0
@export var banking_factor := 0.4

## Behavior parameters
@export var wander_radius := 6.0
@export var target_node: Node3D
@export var ground_avoid_distance := 6.0

var _velocity := Vector3.ZERO
var _wander_angle := 0.0
var _current_flap_phase := 0.0
var _flap_intensity := 1.0
var _is_active := true

func _ready():
	# Initialize with forward velocity
	_velocity = -transform.basis.z * min_speed  # Godot's forward is -Z
	_velocity.y = min_speed * 0.5

func _physics_process(delta: float) -> void:
	if !_is_active:
		return
	
	# Calculate movement direction
	var steering = _calculate_steering(delta)
	
	# Apply physics
	_apply_movement_forces(steering, delta)
	_enforce_altitude_limits()
	
	# Execute movement
	velocity = _velocity
	move_and_slide()
	
	# Update visuals
	_update_visuals(delta)

func _calculate_steering(delta: float) -> Vector3:
	var steering: Vector3
	
	if target_node:
		steering = _seek(target_node.global_position)
	else:
		steering = _wander(delta)
	
	steering += _avoid_ground()
	return steering.limit_length(acceleration)

func _apply_movement_forces(steering: Vector3, delta: float):
	_velocity = (_velocity + steering).limit_length(max_speed)
	
	# Apply lift and gravity
	var lift = _calculate_lift()
	_velocity.y += (-gravity + lift) * delta
	
	# Prevent backward movement
	var forward_dir = -transform.basis.z
	if _velocity.dot(forward_dir) < 0:
		_velocity = _velocity.slide(forward_dir)

func _update_visuals(delta: float):
	_animate_wings(delta)
	_update_rotation(delta)

func _animate_wings(delta: float):
	if !left_wing or !right_wing:
		return
	
	# Update flapping animation
	_current_flap_phase += delta * flap_speed * (0.8 + _velocity.length() / max_speed * 0.5)
	var flap_amount = sin(_current_flap_phase) * _flap_intensity
	var flap_angle = flap_amount * max_flap_angle
	var banking_effect = -_velocity.x * banking_factor
	
	# Apply to wings (X-axis for up/down flapping)
	left_wing.rotation.x = deg_to_rad(flap_angle + banking_effect)
	right_wing.rotation.x = deg_to_rad(-flap_angle + banking_effect)
	
	# Secondary feather movement
	if left_wing.has_node("Feathers"):
		left_wing.get_node("Feathers").rotation.x = deg_to_rad(flap_angle * 0.8)
	if right_wing.has_node("Feathers"):
		right_wing.get_node("Feathers").rotation.x = deg_to_rad(-flap_angle * 0.8)

func _update_rotation(delta: float):
	if _velocity.length() > 0.1:
		var direction = _velocity.normalized()
		
		# Yaw (left/right turning)
		rotation.y = lerp_angle(
			rotation.y, 
			atan2(direction.x, direction.z), 
			delta * maneuverability
		)
		
		# Pitch (up/down tilting)
		rotation.x = lerp(
			rotation.x,
			clamp(-direction.y * 0.5, -0.5, 0.5),
			delta * 3.0
		)
		
		# Roll (banking)
		rotation.z = lerp(
			rotation.z,
			-_velocity.x * 0.1,
			delta * 4.0
		)

func _seek(target_pos: Vector3) -> Vector3:
	var to_target = (target_pos - global_position).normalized()
	var desired = to_target * max_speed
	
	# Add vertical bias
	if to_target.y > 0:
		desired.y = to_target.y * max_speed
	
	return (desired - _velocity)

func _wander(delta: float) -> Vector3:
	_wander_angle += randf_range(-1.0, 1.0) * delta * 2.0
	
	var forward = _velocity.normalized()
	if forward.length_squared() < 0.1:
		forward = -transform.basis.z
	
	var circle_pos = forward * wander_radius
	var displacement = Vector3(
		cos(_wander_angle),
		sin(_wander_angle) * 0.7,
		sin(_wander_angle)
	).rotated(Vector3.UP, atan2(forward.x, forward.z))
	
	return (circle_pos + displacement).normalized() * max_speed - _velocity

func _avoid_ground() -> Vector3:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		global_position,
		global_position + Vector3.DOWN * ground_avoid_distance,
		collision_mask
	)
	var result = space_state.intersect_ray(query)
	
	if result:
		var distance = global_position.distance_to(result.position)
		if distance < min_altitude:
			var strength = 1.0 - (distance / min_altitude)
			return Vector3.UP * strength * acceleration * 3.0
	
	return Vector3.ZERO

func _calculate_lift() -> float:
	var flap_progress = (sin(_current_flap_phase) + 1) / 2
	var speed_factor = inverse_lerp(min_speed, max_speed, _velocity.length())
	return lift_factor * flap_progress * speed_factor

func _enforce_altitude_limits():
	if global_position.y < min_altitude:
		_velocity.y = max(_velocity.y, 0)
		global_position.y = max(global_position.y, min_altitude)

func set_active(state: bool):
	_is_active = state
	if state:
		_velocity = -transform.basis.z * min_speed
