extends Node

var noise : FastNoiseLite
var shake_camera : Camera2D = null
var shake_intensity : float = 0.0
var shake_duration : float = 0.0

func _ready() -> void:
	randomize()
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.fractal_octaves = 4

func _process(delta) -> void:
	if !shake_camera:
		return
	
	#end if the duration is up
	if shake_duration <= 0.0:
		shake_intensity = 0.0
		shake_duration = 0.0
		shake_camera.offset = Vector2.ZERO
		return
	
	shake_duration = shake_duration-delta
	
	var time = Time.get_unix_time_from_system()
	var time_msecs = (time - int(time))*1000.0
	
	shake_camera.offset = Vector2(sin(time_msecs * 0.03), sin(time_msecs * 0.07)) * shake_intensity * 0.5
	
	#var noise_x : float = noise.get_noise_1d(time_msecs*0.1)
	#var noise_y : float = noise.get_noise_1d(time_msecs*0.1+100)
	#shake_camera.offset = Vector2(noise_x, noise_y) * shake_intensity * 2.0

#swaps the camera, currently will continue shaking
func set_camera(camera:Camera2D) -> void:
	shake_camera = camera

#sets shake values, which are decayed by process
func shake(intensity:float, duration:float, camera:Camera2D=shake_camera) -> void:
	shake_camera = camera
	if shake_intensity < intensity and shake_duration < duration:
		shake_intensity = intensity
		shake_duration = duration
