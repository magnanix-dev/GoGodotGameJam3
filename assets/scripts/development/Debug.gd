extends Control

onready var fps_label = $FPS
onready var seed_label = $Seed

var frame_time = 0.0
var frame_count = 0.0

func _process(delta):
	update_fps(delta)

func update_fps(delta):
	frame_time += delta
	frame_count += 1
	if (frame_time > 1.0):
		var fps = frame_count / frame_time
		fps_label.text = "FPS: " + str(int(fps))
		frame_time = 0
		frame_count = 0
	seed_label.text = "Seed:\n" + str(Global._seed)
