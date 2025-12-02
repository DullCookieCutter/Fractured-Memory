extends StaticBody2D

@export var required_memories: int = 3 

@export var next_scene_path: String = "res://Scenes/game_scene_2.tscn"
@export_multiline var door_dialogue_locked: String = "The exit is barred by a heavy silence. I feel like I'm forgetting something important..."
@export_multiline var door_dialogue_unlocked: String = "A strange clicking sound echoes, and the lock has been released. It's time to move on."

@onready var interactable: Area2D = $Interactable
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	interactable.interact_name = "Approach Door"
	interactable.interact = _on_interact
	
	print("Door Requirement: %d memories needed." % required_memories)

func _on_interact():
	var current_memories = GameData.memories_collected
	
	if current_memories >= required_memories:
		print("--- DOOR UNLOCKED ---")
		print(door_dialogue_unlocked)
		
		interactable.is_interactable = false
		_open_door()
	else:
		var progress_message = "I need to remember more... (Found %d/%d memories)." % [current_memories, required_memories]
		print("--- DOOR LOCKED ---")
		print(door_dialogue_locked + " " + progress_message)

func _open_door():
	if sprite_2d:
		sprite_2d.hide()
	
	var dialogue_manager = get_tree().get_first_node_in_group("dialogue_manager") 
	GameData.reset_memories_collected() 
	
	if dialogue_manager:
		dialogue_manager.start_instant_scene_change()
	else:
		print("Door opened, but DialogueManager not found to load next scene!")
		get_tree().change_scene_to_file(next_scene_path)
