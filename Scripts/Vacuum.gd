extends Area2D

@export var suck_power := 200.0
@export var capture_time := 2.5
@export var facing_threshold := 0.7  # dot product; ~45 degree cone

var is_sucking := false
var sucked_ghost: Node2D = null
var capture_timer := 0.0

@onready var control: Control = get_parent().get_node("Control")
@onready var progress_bar: ProgressBar = get_parent().get_node("Control/VacuumProgress")

# The vacuum nozzle (Succ / SuccCollider) points along local +X
const FORWARD: Vector2 = Vector2.RIGHT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Succ.visible = false
	$SuccCollider.disabled = true
	control.visible = false
	progress_bar.reset()
	# Ghosts live on physics layer 2, so this area must be on layer 2 to detect them.
	collision_layer = 2

	# Give the suck zone an actual size (the scene shape is empty by default).
	var shape = RectangleShape2D.new()
	shape.size = Vector2(60, 34)
	$SuccCollider.shape = shape

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Aim the vacuum at the mouse cursor.
	var mouse_pos = get_global_mouse_position()
	var direction_to_mouse = mouse_pos - global_position
	if direction_to_mouse.length() > 0.001:
		rotation = direction_to_mouse.angle()

	is_sucking = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	$Succ.visible = is_sucking
	$SuccCollider.disabled = not is_sucking

	if sucked_ghost != null:
		# Release if LMB is let go, the ghost was freed, or the vacuum stopped facing it.
		if not is_sucking or sucked_ghost.is_queued_for_deletion():
			release_ghost()
			return

		var facing = FORWARD.rotated(rotation)
		var to_ghost = (sucked_ghost.global_position - global_position).normalized()
		if facing.dot(to_ghost) < facing_threshold:
			release_ghost()
			return

		capture_timer += delta
		control.visible = true
		if capture_timer >= capture_time:
			capture_ghost()
			return
	else:
		capture_timer = 0.0
		control.visible = false

	# Begin sucking a ghost that is already inside the nozzle (e.g. LMB held over it).
	if is_sucking and sucked_ghost == null:
		for body in get_overlapping_bodies():
			if body.is_in_group("Ghosts") and body.has_method("start_being_sucked"):
				var facing = FORWARD.rotated(rotation)
				var to_ghost = (body.global_position - global_position).normalized()
				if facing.dot(to_ghost) >= facing_threshold:
					start_sucking(body)
					break

func start_sucking(ghost: Node2D) -> void:
	sucked_ghost = ghost
	capture_timer = 0.0
	progress_bar.reset()
	control.visible = true
	ghost.start_being_sucked()

func capture_ghost() -> void:
	if sucked_ghost == null:
		return
	if sucked_ghost.has_method("capture"):
		sucked_ghost.capture()
	release_ghost()

func release_ghost() -> void:
	if sucked_ghost != null and sucked_ghost.has_method("stop_being_sucked"):
		sucked_ghost.stop_being_sucked()
	sucked_ghost = null
	capture_timer = 0.0
	progress_bar.reset()
	control.visible = false

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Ghosts"):
		return
	if not is_sucking or sucked_ghost != null:
		return
	# Only suck if the vacuum is facing the ghost.
	var facing = FORWARD.rotated(rotation)
	var to_ghost = (body.global_position - global_position).normalized()
	if facing.dot(to_ghost) < facing_threshold:
		return
	start_sucking(body)
