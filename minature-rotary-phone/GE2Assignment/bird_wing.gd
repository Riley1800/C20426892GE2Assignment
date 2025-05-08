extends Node3D
class_name BirdWing

## Wing segments
@export var wing_base: Node3D    # Part that connects to body
@export var wing_tip: Node3D     # Outer wing part (main flapping)
@export var secondary_feathers: Array[Node3D]  # Additional feather groups

## Movement parameters
@export var flap_speed: float = 4.0
@export var max_flap_angle: float = 60.0  # Degrees
@export var max_feather_angle: float = 30.0
@export var recovery_speed: float = 2.0  # How fast wing returns to rest
@export var banking_factor: float = 0.3  # How much banking affects wing

## Internal state
var _flap_phase: float = 0.0
var _is_flapping: bool = false
var _current_flap_intensity: float = 0.0
var _time: float = 0.0

func _ready():
	# Auto-detect wing parts if not manually assigned
	if !wing_base:
		wing_base = get_node("BodyWingConnection")
	if !wing_tip:
		wing_tip = get_node("WingEdge")
	if secondary_feathers.is_empty():
		for child in get_children():
			if "Feathers" in child.name:
				secondary_feathers.append(child)

func _process(delta: float):
	_time += delta
	
	# Get banking influence from parent (bird torso)
	var banking_effect := 0.0
	if get_parent().has_method("get_banking_angle"):
		banking_effect = get_parent().get_banking_angle() * banking_factor
	
	if _is_flapping:
		_current_flap_intensity = lerp(_current_flap_intensity, 1.0, delta * 5.0)
		_flap_phase = wrapf(_flap_phase + delta * flap_speed, 0.0, TAU)
	else:
		_current_flap_intensity = lerp(_current_flap_intensity, 0.0, delta * recovery_speed)
	
	# Calculate wing positions
	var flap_progress := sin(_flap_phase) * _current_flap_intensity
	var base_rot := deg_to_rad(flap_progress * max_flap_angle * 0.3 + banking_effect)
	var tip_rot := deg_to_rad(flap_progress * max_flap_angle + banking_effect)
	
	# Apply rotations
	if wing_base:
		wing_base.rotation.x = base_rot
	if wing_tip:
		wing_tip.rotation.x = tip_rot
	
	# Animate secondary feathers with slight delay
	for i in secondary_feathers.size():
		var delay_factor := float(i) / secondary_feathers.size()
		var delayed_phase := wrapf(_flap_phase - delay_factor * 0.5, 0.0, TAU)
		var feather_flap := sin(delayed_phase) * _current_flap_intensity
		secondary_feathers[i].rotation.x = deg_to_rad(feather_flap * max_feather_angle)

func start_flapping():
	_is_flapping = true

func stop_flapping():
	_is_flapping = false

func set_flap_speed(speed: float):
	flap_speed = clamp(speed, 0.5, 10.0)

func set_flap_intensity(intensity: float):
	_current_flap_intensity = clamp(intensity, 0.0, 1.0)
