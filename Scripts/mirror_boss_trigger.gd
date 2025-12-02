extends StaticBody2D

@export var boss_dialogue_key: String = "MIRROR_BOSS_INTRO"
@export var combat_scene_path: String = "res://Scenes/typing_combat_manager.tscn"
@onready var interactable: Area2D = $Interactable 
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var dialogue_manager = get_tree().get_first_node_in_group("dialogue_manager") 

func _ready() -> void:
	if is_instance_valid(interactable):
		interactable.interact = _on_interact
		interactable.interact_name = "Reflect"
	if is_instance_valid(dialogue_manager):
		pass 
	else:
		push_error("CRITICAL ERROR: DialogueManager not found in group 'dialogue_manager'.")


func _on_interact():
	if interactable.is_interactable:
		print("--- MIRROR INTERACTED: INSTANT COMBAT START ---")
		interactable.is_interactable = false 
		_start_combat_scene()
		
func _start_combat_scene():
	if is_instance_valid(dialogue_manager):
		dialogue_manager.start_combat_scene(combat_scene_path)
		
		print("--- STARTING COMBAT: Delegated to DialogueManager.start_combat_scene ---")
	else:
		push_error("DialogueManager missing. Using direct scene change.")
		var error = get_tree().change_scene_to_file(combat_scene_path)
	
		if error != OK:
			push_error("CRITICAL ERROR: Failed to load combat scene path: " + combat_scene_path)
