extends Control

const TWN_TIME = 1

onready var SCREEN_SIZE = Vector2(576, 1024) #OS.get_window_size()

var on_main_menu = true

func _ready():
	$Menu.rect_size = self.rect_size * 0.8
	$Menu.rect_position.y = self.rect_size.y * 0.2
	$InvestmentMenu.rect_position.x = 1.5 * SCREEN_SIZE.x
	$PortfolioMenu.rect_position.x = -1.5 * SCREEN_SIZE.x
	$InvestmentMenu/BondDisplay/SwipeHandler.deactivate()
	$PortfolioMenu/Portfolio/SwipeHandler.deactivate()


func tween_menus(middle_position):
	$Tween.interpolate_property($Menu, "rect_position:x", null, middle_position, TWN_TIME, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($InvestmentMenu, "rect_position:x", null, middle_position + 1.5 * SCREEN_SIZE.x, TWN_TIME, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($PortfolioMenu, "rect_position:x", null, middle_position - 1.5 * SCREEN_SIZE.x, TWN_TIME, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($Background/TextureRect, "rect_position:x", null, middle_position/2 - 576, TWN_TIME, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()


func _on_Investments_pressed():
	on_main_menu = false
	$HUD.set_arrow_texture()
	tween_menus(-1.5 * SCREEN_SIZE.x)
	$InvestmentMenu/BondDisplay/SwipeHandler.activate()


func _on_Portfolio_pressed():
	on_main_menu = false
	$HUD.set_arrow_texture()
	$PortfolioMenu/Portfolio.update_bought_bonds()
	$PortfolioMenu/Portfolio/SwipeHandler.activate()
	tween_menus(1.5 * SCREEN_SIZE.x)


func _on_HUD_on_Back_pressed():
	if on_main_menu:
		var e = get_tree().change_scene("res://City.tscn")
		if e != 0:
			print("City scene couldn't be loaded")
	else:
		$HUD.set_city_texture()
		tween_menus(0)
		on_main_menu = true
		$InvestmentMenu/BondDisplay/SwipeHandler.deactivate()
		$PortfolioMenu/Portfolio/SwipeHandler.deactivate()
