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
