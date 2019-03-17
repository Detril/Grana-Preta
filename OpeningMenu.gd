extends Control

const LABEL_TWN_SPEED = 1.5


func _ready():
	var label_size = $Label.rect_size
	$Label.set_position(OS.window_size/2 - label_size/2)
	play_start_animation()


func _input(event):
	if event.is_action_pressed("click"):
		play_enter_animation()
		yield($AnimationTween, "tween_completed")
		get_tree().change_scene("res://City.tscn")


func play_start_animation():
	pass


func play_enter_animation():
	var Twn = $AnimationTween
	var label_pos = $Label.rect_position
	Twn.interpolate_property($Label, "rect_scale", Vector2(1, 1), Vector2(2, 2), LABEL_TWN_SPEED, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT, 0.2)
	Twn.interpolate_property($Label, "modulate", Color(1, 1, 1), Color(1, 1, 1, 0), LABEL_TWN_SPEED, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT, 0.2)
	Twn.interpolate_property($Label, "rect_position", label_pos, label_pos - $Label.rect_size/2, LABEL_TWN_SPEED, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT, 0.2)
	Twn.start()
	# play some sound for responsivity