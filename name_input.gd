extends Control
const GAME_SCENE_PATH = "res://story_intro.tscn"
const DEFAULT_NAME = "Elias"
const TRANSITION_DELAY = 1.5

@onready var name_line_edit = $Center/NameDialog/VBoxContainer/NameLineEdit
@onready var confirm_button = $Center/NameDialog/VBoxContainer/ConfirmButton
@onready var feedback_label = $Center/NameDialog/VBoxContainer/FeedbackLabel

func _ready():
	feedback_label.visible = false
	name_line_edit.grab_focus()
	confirm_button.pressed.connect(_on_confirm_button_pressed)
	name_line_edit.text_submitted.connect(_on_confirm_button_pressed)

func _on_confirm_button_pressed(_new_text = null):
	name_line_edit.editable = false
	confirm_button.disabled = true
	
	var player_input = name_line_edit.text.strip_edges()
	var name_to_use: String
	var feedback_message: String
	var timer = Timer.new()
	
	add_child(timer)
	
	if player_input.length() > 0:
		name_to_use = player_input
		feedback_message = "Your name has been set to: " + name_to_use
	else:
		name_to_use = DEFAULT_NAME
		feedback_message = "No name entered. Using default name: " + name_to_use
	
	GameData.player_name = name_to_use
	
	feedback_label.text = feedback_message
	feedback_label.visible = true
	
	timer.wait_time = TRANSITION_DELAY
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	
func _on_timer_timeout():
	print("--- TIMER TIMED OUT. ATTEMPTING SCENE CHANGE. ---") 
	
	# 5. Transition to the next scene (the game level)
	var error = get_tree().change_scene_to_file(GAME_SCENE_PATH)
	
	# DIAGNOSTIC: Check for scene loading errors
	if error != OK:
		print("ERROR: Failed to load scene! Check the path: " + GAME_SCENE_PATH)
		print("Error Code: " + str(error))
