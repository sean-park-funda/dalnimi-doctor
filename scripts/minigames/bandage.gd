extends Node2D

enum State { OINTMENT, BANDAGE, DONE }
var state = State.OINTMENT
var swipe_count = 0
var swipe_start = Vector2.ZERO
var dragging_bandage = false

@onready var guide_label = $GuideLabel
@onready var wound_zone = $WoundZone
@onready var bandage_item = $BandageItem
@onready var ointment_item = $OintmentItem
@onready var progress_label = $ProgressLabel

func _ready():
	bandage_item.visible = false
	guide_label.text = "연고를 상처에 발라요! (문지르기 2번)"
	progress_label.text = "0 / 2"

func _input(event):
	match state:
		State.OINTMENT:
			_handle_ointment(event)
		State.BANDAGE:
			_handle_bandage(event)

func _handle_ointment(event):
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		if event.pressed:
			swipe_start = event.position
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		var pos = event.position if event is InputEventScreenDrag else event.position
		var wound_rect = wound_zone.get_global_rect()
		if wound_rect.has_point(pos):
			var dist = abs(pos.x - swipe_start.x)
			if dist > 80:
				swipe_count += 1
				swipe_start = pos
				progress_label.text = "%d / 2" % swipe_count
				SoundManager.play_sfx("sfx_brush")
				_flash_wound()
				if swipe_count >= 2:
					_advance_to_bandage()

func _flash_wound():
	var tw = create_tween()
	tw.tween_property(wound_zone, "color", Color(1,1,0.5,0.8), 0.1)
	tw.tween_property(wound_zone, "color", Color(1,0.5,0.5,0.5), 0.1)

func _advance_to_bandage():
	state = State.BANDAGE
	ointment_item.visible = false
	bandage_item.visible = true
	guide_label.text = "밴드를 상처 위에 올려요! 🩹"
	progress_label.text = ""

func _handle_bandage(event):
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		dragging_bandage = event.pressed
	if (event is InputEventMouseMotion or event is InputEventScreenDrag) and dragging_bandage:
		var pos = event.position if event is InputEventScreenDrag else event.position
		bandage_item.global_position = pos - Vector2(60, 30)
		var wound_rect = wound_zone.get_global_rect()
		if wound_rect.has_point(pos):
			_complete()

func _complete():
	if state == State.DONE: return
	state = State.DONE
	SoundManager.play_sfx("sfx_bandage")
	guide_label.text = "다 나았어요! ✅"
	wound_zone.color = Color(0.8, 1.0, 0.8, 0.8)
	bandage_item.global_position = wound_zone.global_position
	_spawn_particles()
	await get_tree().create_timer(2.0).timeout
	GameManager.mark_treated("wound")
	SceneTransition.change_scene("res://scenes/ExamRoom.tscn")

func _spawn_particles():
	for i in range(10):
		var lbl = Label.new()
		lbl.text = ["✨","🩹","💛"][randi() % 3]
		lbl.add_theme_font_size_override("font_size", 48)
		lbl.position = wound_zone.position + Vector2(randf_range(-40,40), randf_range(-40,40))
		add_child(lbl)
		var tw = create_tween()
		tw.tween_property(lbl, "position:y", lbl.position.y - 180, 0.7)
		tw.parallel().tween_property(lbl, "modulate:a", 0.0, 0.7)
		tw.tween_callback(lbl.queue_free)
