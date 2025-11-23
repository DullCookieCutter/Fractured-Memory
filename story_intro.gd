extends Control

const DIALOGUE_QUEUE: PackedStringArray = [
	"The cold was a venom, sinking into my bones, absolute and immediate. It wasn't just temperature; it was the cold of a million years, clinging to my skin like frostbite.",
	"The air was a stagnant soup of ozone, metallic tang, and the cloying scent of something indefinably wrong, like old blood and electrical fire.",
	"\"...p\"",
	"I tried to push myself up, but my limbs were leaden. The darkness was a crushing weight, pressing on my eyeballs until geometric patterns of frantic red and blue light flashed behind them. ",
	"\"...ke....up\"",
	"I had no name, no past, only the frantic, choking pulse of terror in my ears.",
	"\"...wake...up\"",
	"I scraped my knuckles along the wall. The sound of my own breathing was frantic and ragged. Then, the voice—a sterile, amplified command that vibrated in the marrow of my jawbone.",
	"\"WAKE UP, %NAME%. The Sisyphus Protocol demands payment. The Fragments are your absolution.\"",
]

const NEXT_LEVEL_PATH = "res://game_scene.tscn"
var current_line_index: int = 0
var dialogue_history_text: String = "" 

@onready var dialogue_box = $DialogueBox
@onready var dialogue_label = $DialogueBox/MarginContainer/DialogueLabel
@onready var history_label = $ScrollContainer/HistoryLabel

func _ready():
	dialogue_box.visible = true 
	_next_line()

func _next_line():
	if current_line_index >= DIALOGUE_QUEUE.size():
		_finish_dialogue()
		return
	
	var raw_text = DIALOGUE_QUEUE[current_line_index]
	var player_name = GameData.get_player_name()
	var final_text = raw_text.replace("%NAME%", player_name)
	
	dialogue_label.text = final_text
	current_line_index += 1
	dialogue_history_text += "\n\n" + final_text
	history_label.text = dialogue_history_text
	
	print("Dialogue advanced. Click or press space to continue.")

func _unhandled_input(event):
	var advance_dialogue = false
	if event.is_action_pressed("ui_accept"):
		advance_dialogue = true
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		advance_dialogue = true
	if advance_dialogue:
		get_viewport().set_input_as_handled() 
		_next_line()

func _finish_dialogue():
	print("Dialogue sequence finished. Loading next level...")
	get_tree().change_scene_to_file(NEXT_LEVEL_PATH)
