extends Control
const NAME_INPUT_SCENE_PATH = "res://name_input.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	$MenuContainer/"Start Button".grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	pass


func _on_start_button_pressed():
	print("Starting Game...")
	get_tree().change_scene_to_file(NAME_INPUT_SCENE_PATH)

func _on_options_button_pressed() -> void:
	print("Opening Options Menu...")


func _on_quit_button_pressed() -> void:
	print("Quitting Game.")
	get_tree().quit()
