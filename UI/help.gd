extends Control


var page = 0
var pages = ["Part1", "Part2", "Part3"]
@export var page_max = 2


func _ready():
	page = 0
	$AnimationPlayer.play(pages[page])
	$Navigation/Container/Prev.hide()


func _on_prev_pressed():
	page = clamp(page - 1, 0, page_max)
	$AnimationPlayer.play(pages[page])
	if page == 0:
		$Navigation/Container/Prev.hide()
	else:
		$Navigation/Container/Prev.show()
	$Navigation/Container/Done.hide()
	$Navigation/Container/Next.show()


func _on_next_pressed():
	page = clamp(page + 1, 0, page_max)
	$AnimationPlayer.play(pages[page])
	if page == page_max:
		$Navigation/Container/Next.hide()
		$Navigation/Container/Done.show()
	if page > 0:
		$Navigation/Container/Prev.show()


func _on_animation_player_animation_finished(anim_name):
	if anim_name == pages.back():
		print("Help Ended")
		$Navigation/Container/Done.show()
		$Navigation/Container/Next.hide()


func _on_done_pressed():
	self.hide()
