extends Node2D

# 칫솔을 좌우로 5번 문지르기
var swipe_count = 0
const TARGET_SWIPES = 5
var dragging = false
var swipe_start_x = 0.0

@onready var guide_label = $GuideLabel
@onready var progress_label = $ProgressLabel
@onready var brush_item = $ToothbrushItem
@onready var teeth_zone = $TeethZone
@onready var teeth_label = $TeethZone/TeethLabel
@onready var patient_face = $PatientChar/PatientFace

func _ready():
	guide_label.text = "칫솔을 좌우로 문질러요! (%d번)" % TARGET_SWIPES
	progress_label.text = "0 / %d" % TARGET_SWIPES
	_play_entry_animations()

func _play_entry_animations():
	UIAnimations.fly_in_from_right(brush_item, 140.0, 0.1)
	UIAnimations.fly_in_from_bottom(guide_label, 60.0, 0.25)
	UIAnimations.pop_in(progress_label, 0.35)

func _input(event):
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		var pos = event.position
		if event.pressed and brush_item.get_global_rect().has_point(pos):
			dragging = true
			swipe_start_x = pos.x
		elif not event.pressed:
			dragging = false

	if (event is InputEventMouseMotion or event is InputEventScreenDrag) and dragging:
		var pos = event.position
		brush_item.global_position = pos - Vector2(150, 120)
		if teeth_zone.get_global_rect().has_point(pos):
			var dx = abs(pos.x - swipe_start_x)
			if dx > 70:
				swipe_count += 1
				swipe_start_x = pos.x
				_on_swipe()

func _on_swipe():
	SoundManager.play_sfx("sfx_brush")
	progress_label.text = "%d / %d" % [swipe_count, TARGET_SWIPES]
	# 치아가 점점 하얗게
	var white = swipe_count / float(TARGET_SWIPES)
	teeth_zone.color = Color(0.9 + white * 0.1, 0.9 + white * 0.1, 0.7 + white * 0.3, 0.7)
	var tw = create_tween()
	tw.tween_property(brush_item, "modulate", Color(0.7, 1.0, 1.0, 1), 0.08)
	tw.tween_property(brush_item, "modulate", Color(1, 1, 1, 1), 0.08)
	if swipe_count >= TARGET_SWIPES:
		_complete()

func _complete():
	dragging = false
	guide_label.text = "치아가 반짝반짝! ✅"
	UIAnimations.success_flash(guide_label)
	UIAnimations.celebration_pop(patient_face)
	patient_face.text = "🐰\n😁"
	teeth_label.text = "🦷✨🦷"
	_spawn_particles()
	await get_tree().create_timer(2.0).timeout
	GameManager.mark_treated("toothache")
	SceneTransition.change_scene("res://scenes/ExamRoom.tscn")

func _spawn_particles():
	for i in range(12):
		var lbl = Label.new()
		lbl.text = ["✨", "⭐", "🦷"][randi() % 3]
		lbl.add_theme_font_size_override("font_size", 48)
		lbl.position = teeth_zone.position + Vector2(randf_range(-60, 60), randf_range(-20, 20))
		add_child(lbl)
		var tw = create_tween()
		tw.tween_property(lbl, "position:y", lbl.position.y - 220, 0.8)
		tw.parallel().tween_property(lbl, "modulate:a", 0.0, 0.8)
		tw.tween_callback(lbl.queue_free)

func _on_back_pressed():
	SceneTransition.change_scene("res://scenes/ExamRoom.tscn")
