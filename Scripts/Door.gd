extends Node2D

@export var next_room_path: String = ""
@export var spawn_marker_name: String = "SpawnPoint"

var _next_room: PackedScene = null
var _door_sprite: AnimatedSprite2D = null
var _interaction_area: Area2D = null
var _teleport_area: Area2D = null

func _get_next_room() -> PackedScene:
	if _next_room == null and next_room_path != "":
		_next_room = load(next_room_path)
	return _next_room

func _ready() -> void:
	_interaction_area = get_node_or_null("InteractionArea")
	_teleport_area = get_node_or_null("TeleportArea")
	_door_sprite = get_node_or_null("DoorSprite")

	if _interaction_area:
		_interaction_area.body_entered.connect(_on_interaction_area_body_entered)
		_interaction_area.body_exited.connect(_on_interaction_area_body_exited)
	
	if _teleport_area:
		_teleport_area.body_entered.connect(_on_teleport_area_body_entered)

func _on_teleport_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var next_room = _get_next_room()
		if next_room:
			GameManager.room_change_requested.emit(next_room, spawn_marker_name)

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_door_sprite.frame = 1

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_door_sprite.frame = 0
