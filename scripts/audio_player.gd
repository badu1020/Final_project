extends AudioStreamPlayer2D


const main_menu_music = preload("res://assets/Foozle_M0001_Eerie_Space_Music/Kaito Shoma - Hotline [TubeRipper.cc].mp3")
var vol: float = ConfigHandler.load_audio()*25


func _play_music(music : AudioStream, volume = vol):
	print(vol)
	if stream == music:
		return
	
	stream = music
	volume_db = volume
	play()
	
func play_music_level():
	_play_music(main_menu_music)

func stop_music():
	# Immediately stop playback
	if playing:
		stop()

func apply_saved_volume() -> void:
	var volume = ConfigHandler.load_audio() # 0.0 – 1.0
	var volume_db = lerp(-80.0, 0.0, volume)
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		volume_db
	)
