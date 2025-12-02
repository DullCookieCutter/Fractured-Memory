extends Node

var player_name: String = ""
<<<<<<< HEAD
var memories_collected: int = 0

func get_player_name() -> String:
	return player_name

func collect_memory(required_total: int) -> void:
	memories_collected += 1
	print("Memory Collected! Total: %d/%d" % [memories_collected, required_total])

func reset_memories_collected() -> void:
	memories_collected = 0
	print("Memory counter reset for new level.")
=======

func get_player_name() -> String:
	return player_name
>>>>>>> 129ee4f4f9a9834257e8910df8188649eb3ff30a
