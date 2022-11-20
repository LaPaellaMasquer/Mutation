extends KinematicBody2D
signal hit

# Declare member variables here
const MOUSE_AREA=3.0
const MOUSE_RADIUS = 50
var start=false
export var speed = 200
onready var screenSize = get_viewport_rect().size

var velocity=Vector2.ZERO
var size
var nb_sbire=0


func start(pos):
	size=1
	position=pos
#	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	show()
	$petit.disabled=false
	
func _physics_process(delta):
	if start:
		var target_pos=get_global_mouse_position()
		
		if target_pos.distance_to(global_position)< MOUSE_AREA:
			return
		velocity=Steering.arrive_to(velocity,global_position,target_pos,speed,MOUSE_RADIUS,size*1.5)
		velocity=move_and_slide(velocity)
		$Sprite.rotation=velocity.angle()
		
		if get_slide_count()>0:
			var collision=get_slide_collision(0)
			col(collision.collider)
		
		if size>=100:
			emit_signal("hit")

func col(body):
	if body.is_in_group("Mob"):
		var mob
		if body.is_lead:
			mob=body
		else:
			mob=body.target
		if body.cursor!=true:
			if mob.size > size && size<=1 && mob.color=="b":
					hide()
					emit_signal("hit")
					$petit.set_deferred("disabled", true)
			elif mob.size<=size:
				infect(mob)
				size+=mob.size
				mob.size=size
				nb_sbire+=1

func infect(victime):
	if(victime.is_lead):
		for v in victime.get_children():
			if v.is_in_group("Mob"):
				infect(v)
	victime.is_lead=false
	victime.cursor=true
	victime.target=$"."
	victime.target_pos=$".".position
	victime.color="v"
	victime.get_node("AnimatedSprite").animation = "v"+String(victime.default_size)

