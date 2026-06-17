extends Node

const SAVE_PATH = "user://save.json"

func save_game():
	var data = {
		"stickers": GameManager.collected_stickers,
	}
	var f = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f:
		var result = JSON.parse_string(f.get_as_text())
		if result and result.has("stickers"):
			for k in result["stickers"]:
				GameManager.collected_stickers[k] = result["stickers"][k]

func _ready():
	load_game()
