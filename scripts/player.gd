extends Area2D

export var rot_speed=2.6
export var thrust=500
export var max_vel= 400
export var friction=0.65
var shield_level=global.shield_max
var shield_up=true

export (PackedScene) var bullet=preload("res://scenes/player_bullet.tscn") #
#var bullet=preload("res://scenes/player_bullet.tscn")

onready var bullet_container=get_node("bullet_container")
onready var shoot_sounds = get_node("shoot_sounds")
onready var gun_timer=get_node("gun_timer")

var screen_size = Vector2()
var pos = Vector2()
var vel = Vector2()
var acc =Vector2 ()
var rot = 0 

func _ready():
	screen_size=get_viewport_rect().size
	pos=screen_size/6
	#set_pos(Vector2(0,0))#pos)
	set_process(true)
	#set_process_input(true)

#func _input(event):
#	pass

func _process(delta):
	if shield_up:
		shield_level=min(shield_level+global.shield_regen*delta, 100)
	if shield_level <=0 and shield_up:
		shield_up=false
		shield_level=0
		get_node("shield").hide()
		print ("shl: ", shield_level, "\ndelta: ", delta)
	if Input.is_action_pressed("player_shoot"):
		if gun_timer.get_time_left() ==0:
			shoot()
	if Input.is_action_pressed("player_left"):
		rot+=rot_speed*delta
	if Input.is_action_pressed("player_right"):
		rot-=rot_speed*delta
	if Input.is_action_pressed("player_thrust"):
		acc=Vector2(thrust, 0).rotated(rot)
		get_node("exhaust").show()
	else:
		get_node("exhaust").hide()
		acc=Vector2(0,0)
	acc +=vel*-friction
	#print ("ACC: ", acc)
	vel+=acc*delta
	pos+=vel*delta
	if pos.x >screen_size.width:
		pos.x=0
	if pos.x <0:
		pos.x=screen_size.width
	if pos.y >screen_size.height:
		pos.y=0
	if pos.y<0:
		pos.y=screen_size.height
	set_pos(pos)
	set_rot(rot -PI/2)

func shoot():
	gun_timer.start() 
	var b=bullet.instance() 
	bullet_container.add_child(b)
	b.start_at(get_rot(), get_node("muzzle").get_global_pos(),vel)
	shoot_sounds.play("laser2")
	
	

func _on_player_body_enter( body ):
	if body.get_groups().has("asteroids"):
		if shield_up:
			body.explode(vel)
			shield_level-=global.ast_damage[body.size]
			
		else:
			global.game_over=false