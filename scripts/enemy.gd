extends Area2D

signal explode 

var bullet=preload("res://scenes/enemy_bullet.tscn")
onready var paths=get_node("enemy_paths")
onready var bullet_container=get_node("bullet_container")
onready var shoot_timer=get_node("shoot_timer")
onready var shoot_sounds = get_node("shoot_sounds")

var path
var health=global.enemy_health
var follow
#var remote #Removed it to follow var
var speed=150
var target=null

func _ready():
	add_to_group("enemies")
	set_process(true)
	randomize()
	get_node("anim").play("rotate")
	path=paths.get_children()[randi()%paths.get_child_count()]
	follow=PathFollow2D.new()
	follow.set_loop(false)
	path.add_child(follow)
	twunit_offset()
	shoot_timer.set_wait_time(1.5) #vary by level
	shoot_timer.start()
	
func twunit_offset():
	var tween=Tween.new()
	add_child(tween)
	tween.interpolate_property(follow,"unit_offset",0,1,8, tween.TRANS_SINE,tween.EASE_IN)#from 0(start) to 1 end(beacause unit offset show paths between 0(start) and 1(end). For 6 seconds
	tween.set_repeat(true)
	tween.start()
	
func _process(delta):
	follow.set_offset(follow.get_offset()+speed*delta)
	set_pos(follow.get_global_pos())
	if follow.get_unit_offset()>=1: #Bug: exit_screen emits signal at start with some paths
		queue_free()
func damage(amount):
	health-=amount
	if health<=0:
		global.score+=global.enemy_points
		emit_signal("explode", get_global_pos()) #pass to main scene
		queue_free()
		
func shoot1():
	var dir=get_global_pos()-target.get_global_pos()
	var b=bullet.instance()
	bullet_container.add_child(b)
	b.start_at(dir.angle(), get_global_pos())
	
func shoot3():
	var dir=get_global_pos()-target.get_global_pos()
	for a in [-0.1,0,0.1]:
		shoot_sounds.play("laser1")
		var b=bullet.instance()
		bullet_container.add_child(b)
		b.start_at(dir.angle()+a, get_global_pos())
		
func _on_shoot_timer_timeout():
	randomize()
	var ra=randi()%2
	print ("ra:",ra)
	if ra==1:
		shoot3()
	else:
		shoot1()
