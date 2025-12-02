extends Area2D

@export var sign_message: String = "Welcome to the Glintwood Forest! Press [E] to read."
@onready var hud = get_tree().get_first_node_in_group("hud")
var player_is_nearby: bool = false
var interaction_active: bool = false
<<<<<<< HEAD
const INTERACT_ACTION = "interact"
=======
const INTERACT_ACTION = "Interact"
>>>>>>> 129ee4f4f9a9834257e8910df8188649eb3ff30a

signal interaction_possible(is_possible)

func _process(_delta: float):
	if player_is_nearby and not interaction_active:
		if Input.is_action_just_pressed(INTERACT_ACTION):
			interact()

func _ready():
	pass

func _update_interact_prompt(is_possible: bool):
	var prompt_label = $CanvasLayer/HUD/InteractionPrompt 
	
	if is_possible:
		prompt_label.text = "Press [E] to Read"
		prompt_label.show()
	else:
		prompt_label.hide()

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		player_is_nearby = true
		interaction_possible.emit(true)

func _on_body_exited(body: Node2D):
	if body.is_in_group("player"):
		player_is_nearby = false
		interaction_possible.emit(false)

func interact():
	print("--- SIGN READ ---")
	print(sign_message)
	print("-----------------")
	interaction_possible.emit(false)
	if hud:
		var dialogue_box = hud.get_node("DialogueBox") 
		if dialogue_box:
			dialogue_box.show_dialogue(sign_message)
