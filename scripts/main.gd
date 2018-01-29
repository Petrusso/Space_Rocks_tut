extends Node

var asteroid = preload("res://scenes/asteroid.tscn")
var explosion = preload("res://scenes/explosion.tscn")
var enemy=preload("res://scenes/enemy.tscn")
onready var spawns = get_node("spawn_locations")
onready var player=get_node("player")
onready var asteroid_container=get_node("asteroid_container")
onready var expl_sounds = get_node("expl_sounds")
onready var HUD=get_node("HUD")
onready var enemy_timer=get_node("enemy_timer")

func _ready():
	set_process(true)
	get_node("music").play()
	player.connect("sig_explode_player",self,"explode_player")
	begin_next_level()

func begin_next_level():
	global.level+=1
	enemy_timer.stop()
	enemy_timer.set_wait_time(rand_range(2,10))
	enemy_timer.start()
	HUD.show_message("Wave %s" % global.level)
	for i in range(global.level):
		spawn_asteroid("big", spawns.get_child(i).get_pos(),  Vector2(0, 0))
func _process(delta):
	HUD.update(player)
	if asteroid_container.get_child_count() == 0:
		begin_next_level()

func spawn_asteroid(size,pos,vel):
	var a = asteroid.instance()
	a.init(size,pos,vel)
	asteroid_container.add_child(a)
	a.connect("explode", self, "explode_asteroid")
	#DO_NOT_REMOVE_!!!!!!!!!!!! Check   #a.init(size,pos,vel) !!IMPORTANT!!! INIT was here at first. when the asteroids get added to the scene with asteroid_container.add_child(a) they will be in the same location as the player (if you followed along with the video and moved them). That will trigger them to instantly explode before their position gets moved... Look at comments: https://www.youtube.com/watch?v=XGKROE7BFWY

	
func explode_asteroid(size,pos,vel,hit_vel):
	var newsize = global.break_pattern[size]
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
	
func explode_player():
	player.disable()
	var expl=explosion.instance()
	add_child(expl)
	expl.set_animation("sonic")
	expl.scale(Vector2(1.5,1.5))
	expl.set_pos(player.pos)
	expl.play()
	expl_sounds.play("expl1")
	HUD.show_message("GAME OVER \n\n Restart in: "+str(get_node("restart_timer").get_wait_time())+"  sec")
	get_node("restart_timer").start()
func explode_enemy(pos):
	var expl=explosion.instance()
	expl.set_pos(pos)
	add_child(expl)
	expl.set_animation("sonic")
	expl_sounds.play("expl1")
	expl.play()
	
func _on_restart_timer_timeout():
	global.new_game()

func _on_enemy_timer_timeout():
	var e=enemy.instance()
	e.set_pos(Vector2(-100,-100)) #set initial pos somewhere outside to prevent enemy from spawning for sec in the middle of the screen
	add_child(e)
	e.target=player
	e.connect("explode", self, "explode_enemy")
	enemy_timer.set_wait_time(rand_range(2,10))
	enemy_timer.start()
