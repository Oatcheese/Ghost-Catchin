extends Area2D

# Path to the room scene to load when the player passes through this door.
@export var next_room_path: String = ""
@export var spawn_marker_name: String = "SpawnPoint"

# Frame of the AnimatedSprite2D shown when the door is open / closed.
@export var open_frame: int = 1
@export var closed_frame: int = 0

# Cached loaded scene so we don't reload from disk every time.
var _next_room: PackedScene = null

# Reference to the door's AnimatedSprite2D (null if this door uses a plain Sprite2D).
var _animated_sprite: AnimatedSprite2D = null

func _get_next_room() -> PackedScene:
	if _next_room == null and next_room_path != "":
		_next_room = load(next_room_path)
	return _next_room

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_animated_sprite = get_node_or_null("AnimatedSprite2D")

	# Optional: a smaller child Area2D named "InteractionArea" handles room changes.
	var interaction_area = get_node_or_null("InteractionArea")
	if interaction_area:
		interaction_area.body_entered.connect(_on_interaction_area_body_entered)
		interaction_area.body_exited.connect(_on_interaction_area_body_exited)

# Switch the door's animated sprite to the open or closed frame.
func _set_door_opened(opened: bool) -> void:
	if _animated_sprite == null:
		return
	# Stop the animation so the door stays on the chosen frame instead of looping.
	_animated_sprite.stop()
	if (opened):
		_animated_sprite.frame = open_frame
	else:
		_animated_sprite.frame = closed_frame

# Player got close: open the door (animation only, no room change yet).
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var next_room = _get_next_room()
		if next_room:
			GameManager.room_change_requested.emit(next_room, spawn_marker_name)

# Player is standing on the door: change rooms.
func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_set_door_opened(true)
			
func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_set_door_opened(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
