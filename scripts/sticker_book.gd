extends Node2D

const STICKER_INFO = {
	"daltooki": {"label": "달토끼 🐰", "emoji": "🐰"},
	"dalkongi": {"label": "달콩이 👶", "emoji": "👶"},
	"sunny":    {"label": "써니 ☀️",   "emoji": "☀️"},
	"byeoli":   {"label": "별이 ⭐",   "emoji": "⭐"},
	"all":      {"label": "완치왕 👑",  "emoji": "👑"},
}

func _ready():
	_build_stickers()

func _build_stickers():
	for key in STICKER_INFO:
		var info = STICKER_INFO[key]
		var collected = GameManager.collected_stickers.get(key, false)
		var slot = $StickerGrid.get_node_or_null(key)
		if not slot: continue
		slot.theme_override_font_sizes["font_size"] = 60
		if collected:
			slot.text = info["emoji"] + "\n" + info["label"]
			slot.modulate = Color(1, 1, 1)
		else:
			slot.text = "❓\n???"
			slot.modulate = Color(0.5, 0.5, 0.5)

func _on_home_pressed():
	SoundManager.play_sfx("sfx_click")
	SceneTransition.change_scene("res://scenes/Main.tscn")
