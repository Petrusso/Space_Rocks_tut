extends Area2D


var vel=Vector2()
export var speed=700

func _ready():
	set_process(true)
	
func start_at(dir,pos):
	set_rot(dir)
	set_pos(pos)
	vel=Vector2(speed,0).rotated(dir+PI/2)
	
func _process(delta):
	set_pos(get_pos()+vel*delta)

func _on_visible_exit_screen():
	queue_free()

func _on_enemy_bullet_area_enter( area ):
	if area.has_method("damage") and not area.get_groups().has("enemies"): #Preventing from damaging enemies themselves(cause bullets apears IN area and damages it)
		queue_free()
		area.damage(global.enemy_bullet_damage)
