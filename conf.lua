function love.conf(t)
	t.window.title = "City generation"
	t.window.icon = "Assets/massiveMultiplayer.png"
	t.window.resizable = true
	t.window.minwidth = 800
	t.window.minheight = 600

	t.modules.sound = false
	t.modules.physics = false

	t.console = true
end