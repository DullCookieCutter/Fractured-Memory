extends Control

<<<<<<< HEAD
# --- SIGNALS AND CONSTANTS ---
signal dialogue_finished
const DIALOGUE_DATA_PATH = "res://Assets/Texture/UI Assets/dialogue_data.json"
const TYPING_SPEED = 0.01 

# --- LEVEL TRACKING ---
var current_level: int = 0
const FINAL_LEVEL: int = 3 

# --- STATE VARIABLES ---
var full_dialogue_data = {} 
var current_queue = []
var is_dialogue_active = false
var dialogue_history_text: String = "" 

var is_advancing = false 
var current_text_target = ""
var text_timer = Timer.new()

# --- NODE REFERENCES ---
=======
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

>>>>>>> 129ee4f4f9a9834257e8910df8188649eb3ff30a
@onready var dialogue_box = $DialogueBox
@onready var dialogue_label = $DialogueBox/MarginContainer/DialogueLabel
@onready var history_label = $ScrollContainer/HistoryLabel
@onready var scroll_container = $ScrollContainer
<<<<<<< HEAD
@onready var black_background = $BlackBackground 

# --- LIFECYCLE ---

func _ready():
	if not is_instance_valid(dialogue_box) or not is_instance_valid(dialogue_label):
		push_error("CRITICAL UI ERROR: DialogueBox or DialogueLabel node paths are incorrect or the nodes are missing in your scene. Check the @onready variables against your scene tree.")
		return
		
	load_dialogue_data()
	add_child(text_timer)
	text_timer.timeout.connect(_on_text_timer_timeout)
	
	dialogue_box.hide()
	scroll_container.visible = false 
	
	if current_level == 0:
		black_background.color = Color(0, 0, 0, 1)
		
	var fade_tween = create_tween()
	fade_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	fade_tween.tween_property(black_background, "color", Color(0, 0, 0, 0), 0.5)
	
	if dialogue_label is RichTextLabel:
		dialogue_label.bbcode_enabled = true

=======
@onready var black_background = $BlackBackground

func _ready():
	load_dialogue_data()
	dialogue_box.hide()
	black_background.color.a = 0.0
	add_child(text_timer)
	text_timer.timeout.connect(_on_text_timer_timeout)
	
>>>>>>> 129ee4f4f9a9834257e8910df8188649eb3ff30a
func load_dialogue_data():
	var file = FileAccess.open(DIALOGUE_DATA_PATH, FileAccess.READ)	
	if FileAccess.get_open_error() == OK:
		var json_text = file.get_as_text()
<<<<<<< HEAD
		var parsed_data = JSON.parse_string(json_text)
		
		if parsed_data is Dictionary:
			full_dialogue_data = parsed_data
			print("--- Dialogue Data Loaded Successfully. Keys found: " + str(full_dialogue_data.keys().size()))
		else:
			push_error("CRITICAL ERROR: Failed to parse JSON data. Check JSON format.")
	else:
		push_error("CRITICAL ERROR: Failed to load dialogue data file at: " + DIALOGUE_DATA_PATH + ". Error: " + str(FileAccess.get_open_error()))


# --- PUBLIC FUNCTIONS ---

func start_dialogue(dialogue_key: String):
	if is_dialogue_active: return
		
	var dialogue_array = full_dialogue_data.get(dialogue_key)
	
	if dialogue_array == null: 
		push_error("CRITICAL ERROR: Dialogue Key '%s' not found in full_dialogue_data. Check spelling or if JSON loaded." % dialogue_key)
		return
	
	current_queue = dialogue_array.duplicate()
	is_dialogue_active = true
	
	dialogue_box.modulate = Color(1, 1, 1, 1)
	dialogue_box.show()
	print("--- Dialogue Box UI Shown for Key: " + dialogue_key + " ---")
	
	advance_dialogue()

func start_combat_scene(combat_scene_path: String):
	scroll_container.visible = false
	dialogue_box.hide() 
	
	var error: Error = get_tree().change_scene_to_file(combat_scene_path) 
	
	if error != OK:
		push_error("CRITICAL ERROR: Failed to load combat scene path. Error code: " + str(error))


# --- CORE DIALOGUE LOGIC ---
func advance_dialogue():
	if is_advancing:
		_finish_typing()
		return
		
	if current_queue.is_empty():
		is_dialogue_active = false
		print("--- Dialogue sequence ended. ---")
		
		start_instant_scene_change()
		return

	var line_data = current_queue.pop_front()
	
	if not line_data is Dictionary or not line_data.has("speaker") or not line_data.has("text"):
		push_error("Dialogue line is malformed: " + str(line_data))
		return
		
	var speaker = line_data.speaker
	var text_content = line_data.text
	
	is_advancing = true
	
	if text_content.contains("%NAME%") and has_node("/root/GameData"):
		var name_to_use = GameData.player_name if GameData.player_name.length() > 0 else "Elias"
		text_content = text_content.replace("%NAME%", name_to_use)
	
	var full_line = "[color=yellow]%s:[/color] %s" % [speaker, text_content]
	current_text_target = full_line
	
	dialogue_label.clear()
	dialogue_label.text = current_text_target
	
	_start_typing()
	
	dialogue_history_text += "\n\n[color=white]%s[/color]" % [full_line.strip_edges()]
	history_label.text = dialogue_history_text
	
	call_deferred("set_scroll_to_max")

# --- TYPEWRITER FUNCTIONS ---
=======
		full_dialogue_data = JSON.parse_string(json_text)
		file.close()
		if full_dialogue_data == null:
			push_error("JSON Parse Error: Check dialogue_data.json syntax.")
	else:
		push_error("Failed to load dialogue data.")

>>>>>>> 129ee4f4f9a9834257e8910df8188649eb3ff30a
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

<<<<<<< HEAD
# --- INSTANT SCENE CHANGE ---
func start_instant_scene_change():
	scroll_container.visible = false
	dialogue_box.hide()
	emit_signal("dialogue_finished")
	
	current_level += 1
	var error: Error
	if current_level > FINAL_LEVEL:
		error = get_tree().change_scene_to_file("res://Scenes/ending_scene.tscn")
	else:
		var next_scene_path = "res://Scenes/game_scene_%d.tscn" % current_level
		error = get_tree().change_scene_to_file(next_scene_path)
		
	if error != OK:
		push_error("CRITICAL ERROR: Failed to load scene path. Error code: " + str(error))
		current_level = max(1, current_level - 1)


# --- UTILITY ---
func set_scroll_to_max():
	if is_instance_valid(scroll_container) and is_instance_valid(scroll_container.get_v_scroll_bar()):
		scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value

func _unhandled_input(event):
	var viewport = get_viewport()
	if not is_instance_valid(viewport):
		return

	if event.is_action_pressed("ui_text_select_all"):
		scroll_container.visible = not scroll_container.visible
		viewport.set_input_as_handled()
		return

	if event.is_action_pressed("interact"):
		if is_dialogue_active:
			advance_dialogue()
			viewport.set_input_as_handled()
=======
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
>>>>>>> 129ee4f4f9a9834257e8910df8188649eb3ff30a
