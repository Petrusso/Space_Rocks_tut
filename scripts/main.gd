extends Node
#onready var splabel=get_node("speed_label")
#onready var shlabel=get_node("shield_label")
onready var player=get_node("player")
onready var asteroid_container=get_node("asteroid_container")
onready var expl_sounds = get_node("expl_sounds")
onready var HUD=get_node("HUD")

var file2check=File.new() #to check existence of files (textures for hud bars)
var asteroid = preload("res://scenes/asteroid.tscn")
var explosion = preload("res://scenes/explosion.tscn")
onready var spawns = get_node("spawn_locations")
var texture

func _ready():
	set_process(true)
	get_node("music").play()

func show_hud_shield():
	var shield_level=player.shield_level
	var color="green"
	if shield_level<40:
		color="red"
	elif shield_level<70:
		color="yellow"
	if file2check.file_exists("res://art/gui/barHorizontal_%s_mid 200.png" %color):
		texture=load("res://art/gui/barHorizontal_%s_mid 200.png" %color) ## NICE!!!!!
	else:
		print ("Error loading texture")
		get_tree().quit()
	HUD.get_node("shield_bar").set_progress_texture(texture)
	HUD.get_node("shield_bar").set_value(shield_level)

func _process(delta):
	show_hud_shield()
	HUD.get_node("score").set_text(str(global.score))
	if asteroid_container.get_child_count() == 0:
		global.level+=1
		for i in range(global.level):
			spawn_asteroid("big", spawns.get_child(i).get_pos(),
					   Vector2(0, 0))
#	shlabel.set_text("Shield: "+str(player.shield_level))
#	splabel.set_text("Speed: "+str(sqrt(player.vel.x*player.vel.x+player.vel.y*player.vel.y)))
	
func spawn_asteroid(size,pos,vel):
	var a = asteroid.instance()
	a.init(size,pos,vel)
	asteroid_container.add_child(a)
	a.connect("explode", self, "explode_asteroid")
	#DO_NOT_REMOVE_!!!!!!!!!!!!    #a.init(size,pos,vel) !!IMPORTANT!!! INIT was here at first. when the asteroids get added to the scene with asteroid_container.add_child(a) they will be in the same location as the player (if you followed along with the video and moved them). That will trigger them to instantly explode before their position gets moved... Look at comments: https://www.youtube.com/watch?v=XGKROE7BFWY

	
func explode_asteroid(size,pos,vel,hit_vel):
	var newsize = global.break_pattern[size]
	print ("LA:",size, newsize)
	if newsize:
		for offset in [-1, 1]:
			var newpos = pos + hit_vel.tangent().clamped(25) * offset
			var newvel = (vel + hit_vel.tangent() * offset) * 0.9
			spawn_asteroid(newsize, newpos, newvel)
	var expl = explosion.instance()
	add_child(expl)
	expl.set_pos(pos)
	expl.play()
	expl_sounds.play("expl1")