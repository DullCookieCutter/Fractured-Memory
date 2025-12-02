extends StaticBody2D

@export_multiline var block_dialogue: String = "A faded red block. The paint is chipped from use."
@onready var interactable: Area2D = $Interactable
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	interactable.interact = _on_interact

func _get_door_requirement() -> int:
	var door_node = get_tree().get_first_node_in_group("Doors") 
	
	if not door_node:
		door_node = get_tree().get_root().find_child("Doors", true, false) 
	
	if is_instance_valid(door_node) and door_node.has_method("_on_interact"): 
		return door_node.required_memories
	
	return 1 

func _on_interact():
	if interactable.is_interactable:
		var required_count = _get_door_requirement()
		print("--- RED BLOCK INTERACTED ---")
		print(block_dialogue)
		GameData.collect_memory(required_count)
		interactable.is_interactable = false
