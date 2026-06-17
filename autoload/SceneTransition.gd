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

func change_scene(path: String):
	_fade_out(path)

func _fade_out(path: String):
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(overlay, "color:a", 1.0, 0.25)
	tween.tween_callback(func():
		get_tree().change_scene_to_file(path)
		_fade_in()
	)

func _fade_in():
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(overlay, "color:a", 0.0, 0.25)
	tween.tween_callback(func():
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	)
