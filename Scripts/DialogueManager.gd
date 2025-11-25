extends Control

signal dialogue_finished

const DIALOGUE_DATA_PATH = "res://Assets/Texture/UI Assets/dialogue_data.json"
const NEXT_LEVEL_PATH = "res://Scenes/game_scene_1.tscn"
var full_dialogue_data = {}
var current_queue = []
var is_dialogue_active = false
var dialogue_history_text: String = "" 
var is_advancing = false 
var current_text_target = ""
var text_timer = Timer.new()
const TYPING_SPEED = 0.03

@onready var dialogue_box = $DialogueBox
@onready var dialogue_label = $DialogueBox/MarginContainer/DialogueLabel
@onready var history_label = $ScrollContainer/HistoryLabel
@onready var scroll_container = $ScrollContainer
@onready var black_background = $BlackBackground

func _ready():
	load_dialogue_data()
	dialogue_box.hide()
	black_background.color.a = 0.0
	add_child(text_timer)
	text_timer.timeout.connect(_on_text_timer_timeout)
	
func load_dialogue_data():
	var file = FileAccess.open(DIALOGUE_DATA_PATH, FileAccess.READ)	
	if FileAccess.get_open_error() == OK:
		var json_text = file.get_as_text()
		full_dialogue_data = JSON.parse_string(json_text)
		file.close()
		if full_dialogue_data == null:
			push_error("JSON Parse Error: Check dialogue_data.json syntax.")
	else:
		push_error("Failed to load dialogue data.")

func _start_typing():
	dialogue_label.visible_characters = 0
	text_timer.wait_time = TYPING_SPEED
	text_timer.start()

func _finish_typing():
	text_timer.stop()
	dialogue_label.visible_characters = current_text_target.length()
	is_advancing = false

func _on_text_timer_timeout():
	dialogue_label.visible_characters += 1
	if dialogue_label.visible_characters >= current_text_target.length():
		_finish_typing()

func advance_dialogue():
	if is_advancing:
		_finish_typing()
		return
		
	if current_queue.is_empty():
		dialogue_box.hide()
		is_dialogue_active = false
		emit_signal("dialogue_finished")
		print("--- Dialogue sequence ended. ---")
		return

	var line_data = current_queue.pop_front()
	var speaker = line_data.speaker
	var text_content = line_data.text
	var _event = line_data.get("event", "none")
	var full_line = "[color=yellow]%s:[/color] %s" % [speaker, text_content]
	current_text_target = full_line
	
	dialogue_box.show()
	is_advancing = true
	dialogue_label.text = "" # Clear previous text
	_start_typing()
	
	dialogue_history_text += "\n" + full_line.strip_edges()
	history_label.text = dialogue_history_text
	scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value

func _unhandled_input(event):
	if event.is_action_pressed("ui_text_select_all"): 
		scroll_container.visible = not scroll_container.visible
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("Interact"): 
		if is_dialogue_active:
			advance_dialogue()
			get_viewport().set_input_as_handled()

func _finish_dialogue():
	print("Dialogue sequence finished. Loading next level...")
	get_tree().change_scene_to_file(NEXT_LEVEL_PATH)
