local sceneHandler = {}

sceneHandler.cityTestScene = require("Scenes.CityTestScene")
local mainMenuScene = require("Scenes.MainMenu")

local currentScene = {}
local selectScene = {}
local next = next

local loadNewScene = 2

function sceneHandler.init()
    currentScene = sceneHandler.cityTestScene
end

-- Sets next scene to be loaded
function sceneHandler.newScene(scene)
    selectScene = scene
end

function sceneHandler.update(dt)
    currentScene.update(dt)
end

-- Calls the scenes keyreleased functions
function love.keyreleased(key)
    if key == "escape" then
      love.event.quit()
    end
    currentScene.keyreleased(key)
end

function sceneHandler.draw()
    -- Change to main menu if scene is deactivated
    if not currentScene.active and loadNewScene < 1 then
        -- If selectScene hasn't been changed then switch to main menu
        if next(selectScene) == nil then
            currentScene = mainMenuScene
            sceneHandler.cityTestScene.unload()
        else -- Load currentScene
            currentScene = selectScene
            selectScene = {}
        end
        loadNewScene = 2 -- Set load scene
    end

    if loadNewScene > 0 then
        -- Load print "loading new scene" before loading new scene
        love.graphics.print("Loading " .. currentScene.name .. "...", 20, 20)
        if loadNewScene == 1 then
            for i = 1, 10 do print("\n") end
            print("########################################")
            print("          Loading " .. currentScene.name .. " scene")
            LoadScene()
            print("      == Scene " .. currentScene.name .. " loaded ==")
            print("    [DATA] Memory usage: " .. math.floor(collectgarbage("count")) .. "k")
        end
        loadNewScene = loadNewScene - 1
    else
        -- Draw scene
        currentScene.draw()
    end
end

-- Load new scene and then collect garbage
function LoadScene()
    currentScene.load(sceneHandler)    
    collectgarbage("collect")
end

return sceneHandler