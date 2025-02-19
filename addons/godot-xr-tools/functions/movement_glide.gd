tool
class_name XRToolsMovementGlide
extends XRToolsMovementProvider


##
## Movement Provider for Gliding
##
## @desc:
##     This script provides glide mechanics for the player. This script works
##     with the PlayerBody attached to the players ARVROrigin.
##
##     The player enables flying by moving the controllers apart further than
##     'glide_detect_distance'.
##
##     When gliding, the players fall speed will slew to 'glide_fall_speed' and
##     the velocity will slew to 'glide_forward_speed' in the direction the
##     player is facing.
##
##     Gliding is an exclusive motion operation, and so gliding should be ordered
##     after any Direct movement providers responsible for turning.
##


## Signal invoked when the player starts gliding
signal player_glide_start

## Signal invoked when the player ends gliding
signal player_glide_end


# Horizontal vector (multiply by this to get only the horizontal components
const HORIZONTAL := Vector3(1.0, 0.0, 1.0)


## Movement provider order
export var order : int = 35

## Controller separation distance to register as glide
export var glide_detect_distance : float = 1.0

## Minimum falling speed to be considered gliding
export var glide_min_fall_speed : float = -1.5

## Glide falling speed
export var glide_fall_speed : float = -2.0

## Glide forward speed
export var glide_forward_speed : float = 12.0

## Slew rate to transition to gliding
export var horizontal_slew_rate : float = 1.0

## Slew rate to transition to gliding
export var vertical_slew_rate : float = 2.0

## glide rotate with roll angle
export var turn_with_roll : bool = false

## Smooth turn speed in radians per second
export var roll_turn_speed : float = 1


# Left controller
onready var _left_controller := ARVRHelpers.get_left_controller(self)

# Right controller
onready var _right_controller := ARVRHelpers.get_right_controller(self)


# Add support for is_class on XRTools classes
func is_class(name : String) -> bool:
	return name == "XRToolsMovementGlide" or .is_class(name)


func physics_movement(delta: float, player_body: XRToolsPlayerBody, disabled: bool):
	# Skip if disabled or either controller is off
	if disabled or !enabled or !_left_controller.get_is_active() or !_right_controller.get_is_active():
		_set_gliding(false)
		return

	# If on the ground, or not falling, then not gliding
	if player_body.on_ground || player_body.velocity.y >= glide_min_fall_speed:
		_set_gliding(false)
		return

	# Get the controller left and right global horizontal positions
	var left_position := _left_controller.global_transform.origin
	var right_position := _right_controller.global_transform.origin
	var left_to_right_vector := right_position - left_position
	var left_to_right := (left_to_right_vector) * HORIZONTAL
	
	if turn_with_roll:
		var angle = -left_to_right_vector.y
		_rotate_player(player_body, roll_turn_speed * delta * angle)

	# Set gliding based on hand separation
	var separation := left_to_right.length() / ARVRServer.world_scale
	_set_gliding(separation >= glide_detect_distance)

	# Skip if not gliding
	if !is_active:
		return

	# Lerp the vertical velocity to glide_fall_speed
	var vertical_velocity := player_body.velocity.y
	vertical_velocity = lerp(vertical_velocity, glide_fall_speed, vertical_slew_rate * delta)

	# Lerp the horizontal velocity towards forward_speed
	var horizontal_velocity := player_body.velocity * HORIZONTAL
	var dir_forward := left_to_right.rotated(Vector3.UP, PI/2).normalized()
	var forward_velocity := dir_forward * glide_forward_speed
	horizontal_velocity = lerp(horizontal_velocity, forward_velocity, horizontal_slew_rate * delta)

	# Perform the glide
	var glide_velocity := horizontal_velocity + vertical_velocity * Vector3.UP
	player_body.velocity = player_body.move_body(glide_velocity)

	# Report exclusive motion performed (to bypass gravity)
	return true

# Rotate the origin node around the camera
func _rotate_player(player_body: XRToolsPlayerBody, angle: float):
	var t1 := Transform()
	var t2 := Transform()
	var rot := Transform()

	t1.origin = -player_body.camera_node.transform.origin
	t2.origin = player_body.camera_node.transform.origin
	rot = rot.rotated(Vector3(0.0, -1.0, 0.0), angle)
	player_body.origin_node.transform = (player_body.origin_node.transform * t2 * rot * t1).orthonormalized()

# Set the gliding state and fire any signals
func _set_gliding(active: bool) -> void:
	# Skip if no change
	if active == is_active:
		return

	# Update the is_gliding flag
	is_active = active;

	# Report transition
	if is_active:
		emit_signal("player_glide_start")
	else:
		emit_signal("player_glide_end")


# This method verifies the movement provider has a valid configuration.
func _get_configuration_warning():
	# Verify the left controller
	if !ARVRHelpers.get_left_controller(self):
		return "Unable to find left ARVRController node"

	# Verify the right controller
	if !ARVRHelpers.get_right_controller(self):
		return "Unable to find right ARVRController node"

	# Check glide parameters
	if glide_min_fall_speed > 0:
		return "Glide minimum fall speed must be zero or less"
	if glide_fall_speed > 0:
		return "Glide fall speed must be zero or less"
	if glide_min_fall_speed < glide_fall_speed:
		return "Glide fall speed must be faster than minimum fall speed"

	# Call base class
	return ._get_configuration_warning()
