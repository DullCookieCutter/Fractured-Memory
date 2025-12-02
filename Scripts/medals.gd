extends StaticBody2D

@export_multiline var medal_dialogue: String = "A tarnished medal. It smells like ambition and regret. Another piece of the puzzle returns."
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
		print("--- MEDAL MEMORY INTERACTED ---")
		print(medal_dialogue)
		
		GameData.collect_memory(required_count)
		interactable.is_interactable = false
