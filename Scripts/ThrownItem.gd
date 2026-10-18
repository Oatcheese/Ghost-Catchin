extends RigidBody2D

@export var throw_interval_min := 3.0       # seconds between throws (random in this range)
@export var throw_interval_max := 6.0
@export var throw_speed := 500.0
@export var retry_interval := 0.2           # how often to re-check LOS while waiting for a shot
@export_flags_2d_physics var los_mask := 1  # layers that block line of sight (walls only)

@export var damage := 1
@export var bounce_speed := 300.0           # speed the book rebounds away from the player
@export var armed_time := 1.5               # how long after a throw the book can deal damage

var player: Node2D = null
var throwing_enabled := true                # set false while the player is holding the book, etc.
var _timer := 0.0
var _armed := false
var _armed_left := 0.0
var _hitbox: Area2D = null

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as Node2D
	_reset_timer()
	_setup_hitbox()

# The book stops colliding with the player physically (so it can never push them)
# and uses an Area2D copy of its own collision shape to detect hits instead.
func _setup_hitbox() -> void:
	var player_body := player as CollisionObject2D
	var src := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if player_body == null or src == null:
		push_warning("Book hitbox not created: need a player in the 'player' group and a CollisionShape2D child.")
		return

	add_collision_exception_with(player_body)

	_hitbox = Area2D.new()
	_hitbox.collision_layer = 0
	_hitbox.collision_mask = player_body.collision_layer
	var cs := CollisionShape2D.new()
	cs.shape = src.shape
	cs.transform = src.transform
	_hitbox.add_child(cs)
	add_child(_hitbox)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	if _armed:
		_armed_left -= delta
		if _armed_left <= 0.0:
			_armed = false
		elif _hitbox and _hitbox.overlaps_body(player):
			_hit_player()

	if not throwing_enabled:
		return

	_timer -= delta
	if _timer > 0.0:
		return

	var ghosts := get_tree().get_nodes_in_group("Ghosts")
	if ghosts.is_empty():
		_timer = retry_interval
		return

	if _has_clear_shot():
		_throw()
		_reset_timer()
	else:
		_timer = retry_interval   # keep checking so it fires the moment a shot opens up

func _hit_player() -> void:
	_armed = false   # one hit per throw

	GameManager.damage_player()

	# Bounce away from the player.
	var away := player.global_position.direction_to(global_position)
	sleeping = false
	linear_velocity = away * bounce_speed

func _reset_timer() -> void:
	_timer = randf_range(throw_interval_min, throw_interval_max)

func _has_clear_shot() -> bool:
	var query := PhysicsRayQueryParameters2D.create(global_position, player.global_position, los_mask, [get_rid()])
	var hit := get_world_2d().direct_space_state.intersect_ray(query)

	# Clear if nothing is in the way, or the first thing hit is the player.
	return hit.is_empty() or hit.get("collider") == player

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.name == "Damage Collisions":
		if (linear_velocity.x * -1 > 20 || linear_velocity.y * -1 > 20):
			GameManager.damage_player(1)

func _throw() -> void:
	sleeping = false
	var dir := global_position.direction_to(player.global_position)
	linear_velocity = Vector2.ZERO
	apply_central_impulse(dir * throw_speed * mass)
	_armed = true
	_armed_left = armed_time
