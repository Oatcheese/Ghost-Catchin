extends Node2D

@onready var room_container: Node2D = $RoomContainer

var current_room: Node2D = null

func _ready() -> void:
	GameManager.room_change_requested.connect(_change_room, CONNECT_DEFERRED)
	
	# Load the starting room
	var start_room = load("res://Scenes/StartRoom.tscn")
	_change_room(start_room, "SpawnPoint")

func _change_room(next_scene: PackedScene, spawn_marker: String) -> void:
	# Remove the old room if there is one
	if current_room:
		current_room.queue_free()

	# Instance and add the new room
	current_room = next_scene.instantiate()
	room_container.add_child(current_room)

	# Move the player to the spawn marker in the new room
	var player = get_tree().get_first_node_in_group("player")
	var spawn = current_room.get_node_or_null(spawn_marker)
	
	if player and spawn:
		player.global_position = spawn.global_position
	elif player:
		# Fallback: center of room if no spawn marker found
		player.global_position = Vector2(160, 88)

	GameManager.current_room_name = next_scene.resource_path
