extends Control

# --- ENDING SCENE CONSTANTS ---
const ENDING_DIALOGUE_KEY = "ending_scene"
const QUIT_SCENE_PATH = "res://Scenes/main_menu.tscn"
signal dialogue_finished
const DIALOGUE_DATA_PATH = "res://Assets/Texture/UI Assets/dialogue_data.json"
const TYPING_SPEED = 0.01 

# --- STATE VARIABLES ---
var full_dialogue_data = {} 
var current_queue = []
var is_dialogue_active = false
var dialogue_history_text: String = "" 
var is_advancing = false 
var current_text_target = ""
var text_timer = Timer.new()

# --- NODE REFERENCES ---
@onready var dialogue_box = $DialogueBox
@onready var dialogue_label = $DialogueBox/MarginContainer/DialogueLabel
@onready var history_label = $ScrollContainer/HistoryLabel
@onready var scroll_container = $ScrollContainer
@onready var white_background = $WhiteBackground 

# --- LIFECYCLE ---
func _ready():
	if not is_instance_valid(dialogue_box) or not is_instance_valid(dialogue_label):
		push_error("CRITICAL UI ERROR: DialogueBox or DialogueLabel node paths are incorrect or the nodes are missing in your scene.")
		return 

	load_dialogue_data()
	
	add_child(text_timer)
	text_timer.timeout.connect(_on_text_timer_timeout)
	
	dialogue_box.hide()
	scroll_container.visible = false 
	
	if dialogue_label is RichTextLabel:
		dialogue_label.bbcode_enabled = true
	white_background.color = Color(0, 0, 0, 0)
	
	if full_dialogue_data.has(ENDING_DIALOGUE_KEY):
		start_dialogue(ENDING_DIALOGUE_KEY)
	else:
		push_error("CRITICAL ERROR: Ending dialogue key '%s' not found in JSON data. Check dialogue_data.json." % ENDING_DIALOGUE_KEY)
		dialogue_box.show()
		dialogue_label.text = "[color=red]Game Over. Ending narrative missing. Check Console for details.[/color]"

# --- DIALOGUE SYSTEM FUNCTIONS ---
func load_dialogue_data():
	var file = FileAccess.open(DIALOGUE_DATA_PATH, FileAccess.READ)	
	if FileAccess.get_open_error() == OK:
		var json_text = file.get_as_text()
		var parsed_data = JSON.parse_string(json_text)
		
		if parsed_data is Dictionary:
			full_dialogue_data = parsed_data
		else:
			push_error("CRITICAL ERROR: Failed to parse JSON data. Check JSON format.")
	else:
		push_error("CRITICAL ERROR: Failed to load dialogue data file at: " + DIALOGUE_DATA_PATH + ". Error: " + str(FileAccess.get_open_error()))


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
	
	advance_dialogue()


func advance_dialogue():
	if is_advancing:
		_finish_typing()
		return

	if current_queue.is_empty():
		is_dialogue_active = false
		start_instant_scene_change()
		return

	var line_data = current_queue.pop_front()
	
	if not line_data is Dictionary or not line_data.has("speaker") or not line_data.has("text"):
		push_error("Dialogue line is malformed: " + str(line_data))
		return
		
	var speaker = line_data.speaker
	var text_content = line_data.text
	
	is_advancing = true
	
	var name_to_use = GameData.player_name if GameData.player_name.length() > 0 else "Elias"
	if Engine.has_singleton("GameData"):
		var player_name_prop = GameData.player_name as String
		if not player_name_prop.is_empty():
			name_to_use = player_name_prop
		else:
			push_warning("GameData player name is empty in EndingSceneManager. Using default 'Elias'.")
	else:
		push_warning("GameData Autoload not found. Using default player name 'Elias'.")
	if text_content.contains("%NAME%"):
		text_content = text_content.replace("%NAME%", name_to_use)
	if speaker.contains("%NAME%"):
		speaker = speaker.replace("%NAME%", name_to_use)
	
	var full_line = "[color=yellow]%s:[/color] %s" % [speaker, text_content]
	current_text_target = full_line
	
	dialogue_label.clear()	
	dialogue_label.text = current_text_target
	
	_start_typing()
	
	dialogue_history_text += "\n\n[color=white]%s[/color]" % [full_line.strip_edges()]
	history_label.text = dialogue_history_text
	call_deferred("set_scroll_to_max")

# --- TYPEWRITER FUNCTIONS ---
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

# --- INPUT & UTILITY ---
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

func set_scroll_to_max():
	if is_instance_valid(scroll_container) and is_instance_valid(scroll_container.get_v_scroll_bar()):
		scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value

# --- ENDING LOGIC ---
func start_instant_scene_change():
	scroll_container.visible = false
	dialogue_box.hide()
	emit_signal("dialogue_finished")
	
	print("--- Ending Narration Complete. Attempting transition to Title Screen. ---")
	var error: Error = get_tree().change_scene_to_file(QUIT_SCENE_PATH) 
	
	if error != OK:
		push_error("CRITICAL ERROR: Failed to load scene path: " + QUIT_SCENE_PATH + ". Quitting application.")
		dialogue_box.show()
		dialogue_label.text = "[color=red]ERROR: Next scene (%s) failed to load. Quitting application.[/color]" % QUIT_SCENE_PATH
		get_tree().quit.call_deferred()
