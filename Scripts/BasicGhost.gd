extends RigidBody2D

# --- Movement ---
@export var move_speed := 150.0
@export var acceleration := 600.0
@export var max_speed := 400.0

# --- Orbiting the player ---
@export var orbit_radius := 140.0
@export var orbit_angular_speed := 1.2     # radians per second
@export var min_player_distance := 130.0   # ghost ~160px wide + player, so keep centres apart

# --- Vacuum ---
@export var suck_speed := 150.0
@export var suck_acceleration := 1500.0

var player: Node2D = null
var nozzle: Node2D = null
var ghost: AnimatedSprite2D = null

var being_sucked := false
var orbit_direction := 1.0                 # +1 clockwise, -1 counter-clockwise

var original_linear_damp := 0.0
var original_angular_damp := 0.0
var original_gravity_scale := 0.0

func _ready() -> void:
	player = get_node_or_null("/root/Root/PlayerNode/Player")
	nozzle = get_node_or_null("/root/Root/PlayerNode/Player/Vacuum2/Succ")
	ghost = get_node_or_null("AnimatedSprite2D")
	if ghost:
		ghost.play()

	original_linear_damp = linear_damp
	original_angular_damp = angular_damp
	original_gravity_scale = gravity_scale

	lock_rotation = true
	can_sleep = false
	orbit_direction = 1.0 if randf() < 0.5 else -1.0

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	state.angular_velocity = 0.0
	if not is_instance_valid(player):
		return

	var pos := state.transform.origin

	if being_sucked:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var target := nozzle.global_position if is_instance_valid(nozzle) else player.global_position
			var desired := pos.direction_to(target) * suck_speed
			state.linear_velocity = state.linear_velocity.move_toward(desired, suck_acceleration * state.step)
			return  # the vacuum handles capture timing
		stop_being_sucked()

	var desired_velocity := _get_desired_velocity(pos)
	state.linear_velocity = state.linear_velocity.move_toward(desired_velocity, acceleration * state.step)
	state.linear_velocity = state.linear_velocity.limit_length(max_speed)

	if ghost and absf(state.linear_velocity.x) > 10.0:
		ghost.flip_h = state.linear_velocity.x < 0.0   # invert if your art faces left

func _get_desired_velocity(pos: Vector2) -> Vector2:
	var player_pos := player.global_position
	var to_player := player_pos - pos

	# Too close: back away so the ghost never lands on the player.
	if to_player.length() < min_player_distance:
		return -to_player.normalized() * move_speed

	var current_angle := (pos - player_pos).angle()
	var target_angle := current_angle + orbit_direction * orbit_angular_speed * 0.5
	var target := player_pos + Vector2.from_angle(target_angle) * orbit_radius

	var speed := minf(move_speed, pos.distance_to(target) * 3.0)
	return pos.direction_to(target) * speed

# --- Vacuum ---

func start_being_sucked() -> void:
	being_sucked = true
	linear_damp = 0.0
	angular_damp = 0.0
	gravity_scale = 0.0
	sleeping = false
	freeze = false

func stop_being_sucked() -> void:
	being_sucked = false
	linear_damp = original_linear_damp
	angular_damp = original_angular_damp
	gravity_scale = original_gravity_scale

func capture() -> void:
	GameManager.capture_ghost(1)
	queue_free()
