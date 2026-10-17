extends Area2D

# Path to the room scene to load when the player passes through this door.
@export var next_room_path: String = ""
@export var spawn_marker_name: String = "SpawnPoint"

# Cached loaded scene so we don't reload from disk every time.
var _next_room: PackedScene = null

func _get_next_room() -> PackedScene:
	if _next_room == null and next_room_path != "":
		_next_room = load(next_room_path)
	return _next_room

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var next_room = _get_next_room()
		if next_room:
			GameManager.room_change_requested.emit(next_room, spawn_marker_name)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
