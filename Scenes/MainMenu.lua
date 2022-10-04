local scene = {}

scene.name = "Main menu"

scene.active = false

function scene.load(parent)
    scene.parentTable = parent
    scene.active = true
end

function scene.update(dt)
end

function scene.keyreleased(key)
    if not scene.active then return end

    if key == 'c' then
        scene.parentTable.newScene(scene.parentTable.cityTestScene)
        scene.active = false
    end
end

function scene.draw()
    local x, y = love.window.getMode()
    love.graphics.print("Main menu", (x * 0.5) - (#"Main menu" * 0.5), 10)
    love.graphics.print("C: Create city", (x * 0.5) - (#"C: Create city" * 0.5), 100)
    love.graphics.print("version: 0.1", 0, y - 20)
end 

return scene