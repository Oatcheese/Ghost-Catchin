extends RigidBody2D

var enemySpeed = 20.0
var playerPosition
var tooClose
var velocity
var vacc

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var enemyDirection
	playerPosition = get_node("/root/Root/PlayerNode/Player").global_position
	var ghost_pos = global_position

	# If the vacuum is sucking this ghost, pull it toward the vacuum.
	if being_sucked and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var vacuum_node = get_node("/root/Root/PlayerNode/Player/Vacuum2")
		var vacuum_pos = vacuum_node.global_position if vacuum_node != null else playerPosition
		var dir = vacuum_pos - ghost_pos
		linear_velocity = linear_velocity.move_toward(dir.normalized() * suck_speed, suck_speed * 10 * delta)
		# Let the vacuum handle capture timing.
		return
	elif being_sucked:
		# LMB was released before capture.
		being_sucked = false

	if tooClose:
		# Flee directly away from the player.
		enemyDirection = ghost_pos.direction_to(playerPosition) * -1
	else:
			# Chase the player.
		enemyDirection = ghost_pos.direction_to(playerPosition)
	if enemyDirection.length() > 0 and not being_sucked:
		apply_impulse(enemyDirection * enemySpeed, Vector2(0, 0))

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if not being_sucked:
		var min = Vector2(-400, -400)
		var max = Vector2(400, 400)
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
		tooClose = true
	
	if body.get_groups().has("Throwables"):
		body.apply_impulse(playerPosition * 0.5, Vector2(0, 0))

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		tooClose = false
