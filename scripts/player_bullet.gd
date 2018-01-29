extends Area2D

var vel=Vector2()
export var speed=10
onready var puff=get_node("puff")

func _ready():
	set_fixed_process(true)

func start_at(dir,pos, v):
	set_rot(dir)
	set_pos(pos)
	vel=v+Vector2(speed,0).rotated(dir+PI/2)

func _fixed_process(delta):
	set_pos(get_pos()+vel*delta)


func _on_lifetime_timeout():
	queue_free()

func _on_player_bullet_body_enter(body):
	if body.get_groups().has("asteroids"):
		body.explode(vel.normalized())
		queue_free()
		print (body.get_name())

func _on_player_bullet_area_enter( area ):
	if area.get_groups().has("enemies"):
		queue_free()
		area.damage(global.bullet_damage)
