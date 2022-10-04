local sceneHandler = require("Tools.SceneHandler")

function love.load()
    sceneHandler.init()
end

function love.update(dt)
    sceneHandler.update(dt)
end


function love.draw()
    sceneHandler.draw()    
end