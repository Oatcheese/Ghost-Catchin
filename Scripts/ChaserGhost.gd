extends RigidBody2D

var enemySpeed = 20.0
var playerPosition
var tooClose
var velocity
var vacc

# The ghost circles the player on a ring instead of charging straight into them.
@export var orbit_radius := 140.0
@export var orbit_angular_speed := 1.2  # radians per second
# The ghost sprite is ~160px wide, so it must keep its centre at least ~120px
# away (half ghost + half player) to avoid overlapping the player.
@export var min_player_distance := 130.0
var orbit_angle := 0.0

var being_sucked := false
@export var suck_speed := 150.0
@export var capture_distance := 40.0
var original_linear_damp := 0.0
var original_angular_damp := 0.0
var original_gravity_scale := 0.0
var original_lock_rotation := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	vacc = get_node("/root/Root/PlayerNode/Player/Vacuum2/Succ")
	original_linear_damp = linear_damp
	original_angular_damp = angular_damp
	original_gravity_scale = gravity_scale
	original_lock_rotation = lock_rotation
	# Stagger ghosts so they don't all orbit in lockstep.
	orbit_angle = randf() * TAU

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var enemyDirection
	playerPosition = get_node("/root/Root/PlayerNode/Player").global_position
	var ghost_pos = global_position

	# If the vacuum is sucking this ghost, pull it into the vacuum nozzle (the
	# Succ sprite), not into the player standing behind it.
	if being_sucked and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var nozzle_pos = vacc.global_position if is_instance_valid(vacc) else playerPosition
		var dir = nozzle_pos - ghost_pos
		linear_velocity = linear_velocity.move_toward(dir.normalized() * suck_speed, suck_speed * 10 * delta)
		# Let the vacuum handle capture timing.
		return
	elif being_sucked:
		# LMB was released before capture.
		being_sucked = false

	# Orbit the player by steering toward a point on a ring that keeps spinning.
	orbit_angle += orbit_angular_speed * delta

	enemyDirection = ghost_pos.direction_to(playerPosition)

	if enemyDirection.length() > 0 and not being_sucked:
		apply_impulse(enemyDirection * enemySpeed, Vector2(0, 0))

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if not being_sucked:
		var min = Vector2(-200, -200)
		var max = Vector2(200, 200)
		linear_velocity = linear_velocity.clamp(min, max)

func start_being_sucked() -> void:
	being_sucked = true
	linear_damp = 0.0
	angular_damp = 0.0
	gravity_scale = 0.0
	lock_rotation = true
	sleeping = false
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	freeze = false

func stop_being_sucked() -> void:
	being_sucked = false
	linear_damp = original_linear_damp
	angular_damp = original_angular_damp
	gravity_scale = original_gravity_scale
	lock_rotation = original_lock_rotation
	freeze = false
	apply_impulse(Vector2.ZERO, Vector2.ZERO)

func capture() -> void:
	GameManager.capture_ghost(1)
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		GameManager.damage_player(1)
