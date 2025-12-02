extends Node2D

# --- Configuration ---
const WORD_SCENE = preload("res://Scenes/TypingWord.tscn")
const WORD_LIST: Array[String] = ["GUILT", "FRACTURE", "SISYPHUS", "ABSOLUTION", "ARCHITECT", "INTEGRITY", "PROTOCOL", "DENIAL", "ECHO", "REGRET"]
const BASE_SPEED: float = 60.0
const SPEED_INCREASE_RATE: float = 2.0
const MIN_SPAWN_TIME: float = 1.5
const BASE_SPAWN_TIME: float = 3.0
const TIME_DECREASE_RATE: float = 0.01
const SCREEN_PADDING: float = 30.0
const WORDS_TO_WIN: int = 10

# --- Game State ---
var target_lives: int = 5
var enemies_defeated: int = 0
var active_word_node: Area2D = null
var is_game_active: bool = false

# --- Node References ---
@onready var lives_label: Label = $HUD/LivesLabel
@onready var feedback_label: Label = $HUD/FeedbackLabel
@onready var spawn_timer: Timer = $SpawnTimer
@onready var target_center: Vector2 = $Target.global_position

func _ready():
	set_process_unhandled_input(true)
	start_challenge()

# --- Game Flow ---
func start_challenge():
	target_lives = 5
	enemies_defeated = 0
	is_game_active = true
	feedback_label.text = ""
	update_lives_ui()
	
	for word in get_tree().get_nodes_in_group("words"):
		word.queue_free()
		
	spawn_timer.start(BASE_SPAWN_TIME)

func game_over():
	is_game_active = false
	spawn_timer.stop()
	feedback_label.text = "CHALLENGE FAILED!\nPress SPACE to Restart"
	
	for word in get_tree().get_nodes_in_group("words"):
		word.queue_free()
	
	active_word_node = null

func game_won():
	is_game_active = false
	spawn_timer.stop()
	feedback_label.text = "SANITY MAINTAINED!\nDefeated %d Words.\nPress SPACE to Restart" % enemies_defeated
	
	for word in get_tree().get_nodes_in_group("words"):
		word.queue_free()
	
	active_word_node = null
	var ending_scene_path = "res://Scenes/ending_scene.tscn" 
	var error = get_tree().change_scene_to_file(ending_scene_path)
	
	if error != OK:
		push_error("CRITICAL ERROR: Failed to load ending scene: " + ending_scene_path)

# --- Spawning ---
func _on_spawn_timer_timeout():
	if not is_game_active:
		return
		
	var new_word = WORD_SCENE.instantiate()
	
	if new_word == null:
		print("ERROR: Word scene instantiation failed. Check WORD_SCENE path.")
		return

	new_word.word_to_type = WORD_LIST[randi() % WORD_LIST.size()].to_upper()
	new_word.target_position = target_center
	
	var screen_size = get_viewport_rect().size
	var start_pos: Vector2
	var edge = randi() % 4
	
	match edge:
		0:
			start_pos = Vector2(randf_range(SCREEN_PADDING, screen_size.x - SCREEN_PADDING), SCREEN_PADDING)
		1:
			start_pos = Vector2(randf_range(SCREEN_PADDING, screen_size.x - SCREEN_PADDING), screen_size.y - SCREEN_PADDING)
		2:
			start_pos = Vector2(SCREEN_PADDING, randf_range(SCREEN_PADDING, screen_size.y - SCREEN_PADDING))
		3:
			start_pos = Vector2(screen_size.x - SCREEN_PADDING, randf_range(SCREEN_PADDING, screen_size.y - SCREEN_PADDING))
			
	add_child(new_word)
	new_word.global_position = start_pos
	new_word.setup_movement()
	new_word.speed = BASE_SPEED + (enemies_defeated * SPEED_INCREASE_RATE)
	new_word.target_hit.connect(_on_word_target_hit)
	
	var new_wait_time = BASE_SPAWN_TIME - (enemies_defeated * TIME_DECREASE_RATE)
	spawn_timer.wait_time = max(MIN_SPAWN_TIME, new_wait_time)

# --- Input Handling ---
func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		if not is_game_active and event.keycode == KEY_SPACE:
			start_challenge()
			return

		if not is_game_active:
			return

		var typed_char = char(event.unicode).to_upper()
		var is_a_letter = typed_char >= "A" and typed_char <= "Z"
		if typed_char.length() != 1 or not is_a_letter:
			return

		if active_word_node == null:
			for word_node in get_tree().get_nodes_in_group("words"):
				if word_node.word_to_type.begins_with(typed_char):
					active_word_node = word_node
					active_word_node.typed_substring = typed_char
					active_word_node.update_visuals()
					break
		
		elif active_word_node != null:
			var current_input_len = active_word_node.typed_substring.length()
			if current_input_len < active_word_node.word_to_type.length():
				var expected_char = active_word_node.word_to_type[current_input_len]
				
				if typed_char == expected_char:
					active_word_node.typed_substring += typed_char
					active_word_node.update_visuals()
					
					if active_word_node.typed_substring.length() == active_word_node.word_to_type.length():
						word_typed_success(active_word_node)


# --- Event Handlers ---
func _on_word_target_hit(word_node: Area2D):
	target_lives -= 1
	feedback_label.text = "COGNITIVE DRIFT! (-1 Life)"
	update_lives_ui()

	if active_word_node == word_node:
		active_word_node = null
		
	if target_lives <= 0:
		game_over()
		
func word_typed_success(word_node: Area2D):
	enemies_defeated += 1
	feedback_label.text = "SUCCESS! Word typed: %s" % word_node.word_to_type
	active_word_node = null
	
	if enemies_defeated >= WORDS_TO_WIN:
		game_won()
	else:
		word_node.queue_free()

# --- UI Updates ---
func update_lives_ui():
	lives_label.text = "LIVES: %d" % target_lives
	if target_lives == 1:
		lives_label.modulate = Color.RED
	else:
		lives_label.modulate = Color.WHITE
