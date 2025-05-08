# Attach this script to a Camera3D node that's a child of your target
extends Camera3D

@export var follow_distance := 5.0
@export var height_offset := 2.0
@export var look_at_offset := Vector3(0, 1, 0)  # Look slightly above target

func _process(delta):
	var target = get_parent()
	if target:
		# Position camera behind target
		global_position = target.global_position - target.global_transform.basis.z * follow_distance
		global_position.y = target.global_position.y + height_offset
		
		# Make camera look at target
		look_at(target.global_position + look_at_offset, Vector3.UP)
