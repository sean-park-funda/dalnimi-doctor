extends CanvasLayer

var overlay: ColorRect
var tween: Tween

func _ready():
	layer = 10
	overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)

func change_scene(path: String) -> void:
	_do_transition(path, Color(0, 0, 0, 1))

# 치료 성공 후 노란 플래시 전환
func change_scene_success(path: String) -> void:
	_do_transition(path, Color(1.0, 0.92, 0.1, 1))

func _do_transition(path: String, fade_color: Color) -> void:
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.color = Color(fade_color.r, fade_color.g, fade_color.b, 0)
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(overlay, "color:a", 1.0, 0.2)
	tween.tween_callback(func():
		get_tree().change_scene_to_file(path)
		_fade_in()
	)

func _fade_in() -> void:
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(overlay, "color:a", 0.0, 0.25)
	tween.tween_callback(func():
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	)
