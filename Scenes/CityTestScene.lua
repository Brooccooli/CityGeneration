local people = require("Base.PeopleBase")
local city = require("Base.CityBase")

local scene = {}

scene.name = "City"

local mayor = {}
local myCity = {}
local startCitySize = 1000
local personInCity = 1
local peopleToPrint = {}

local printStats = false

local deltaTime = 0
local mouseScroll = {x = 0, y = 0}

local n = 'n'

scene.active = true



-- #######################################
--            load and deload
-- #######################################
function scene.load(parent)
    scene.parentTable = parent
    mayor = people.CreateAdult(420)
    print("  # Created mayor ")
    myCity = city.Create(mayor, startCitySize)
    print("  # Created population")
    peopleToPrint[1] = myCity.population[1]
    scene.active = true
    print("_______________________________________")
    print("| Mayor: " .. mayor.firstName .. " " .. mayor.lastName)
    print("| Population count: " .. myCity.peopleCount) 
    print("|______________________________________")
end

function scene.unload()
    print("          Unload city")
    print("  -- " .. #myCity.population .. " People killed")
    city.unloadPopulation(myCity)
end



-- ###############################
--            Controls
-- ###############################
-- Scrolling
function love.wheelmoved(x, y)
    mouseScroll.x = mouseScroll.x + x * 3
    mouseScroll.y = mouseScroll.y + y * 10
    mouseScroll.y = math.min(0, mouseScroll.y)
end

function scene.keyreleased(key)
    if not scene.active then
        return
    end

    if printStats then
        if key == 't' then
            printStats = false
        end
        return
    end

    -- Menu
    if key == 'b' then
        scene.active = false
    end
    if key == 't' then
        printStats = true
    end
    if key == 'y' then
        myCity:newYear()
    end

    -- Select people
    if key == 'n' then
        mouseScroll.x, mouseScroll.y = 0, 0
        local tempPerson = peopleToPrint[1]
        peopleToPrint = {}
        peopleToPrint[1] = myCity.population[love.math.random(startCitySize, myCity.peopleCount)]
        --peopleToPrint[1] = myCity.population[tempPerson.index + 1]
    end
    if key == 'f' then
        mouseScroll.x, mouseScroll.y = 0, 0
        if peopleToPrint[1].father.index == -1 then return end

        local tempPerson = peopleToPrint[1]
        peopleToPrint = {}
        peopleToPrint[1] = myCity.population[tempPerson.index].father
    end
    if key == 'm' then
        mouseScroll.x, mouseScroll.y = 0, 0
        if peopleToPrint[1].mother.index == -1 then return end

        local tempPerson = peopleToPrint[1]
        peopleToPrint = {}
        peopleToPrint[1] = myCity.population[tempPerson.index].mother
    end
    if key == 'p' then
        mouseScroll.x, mouseScroll.y = 0, 0
        if peopleToPrint[1].partner[1] == nil then return end

        local tempPerson = peopleToPrint[1]
        peopleToPrint = {}
        peopleToPrint[1] = myCity.population[tempPerson.index].partner[1]
    end
    if key == 'c' then
        mouseScroll.x, mouseScroll.y = 0, 0
        if #peopleToPrint[1].child > 0 then
            local tempParent = peopleToPrint[1]
            for i = #tempParent.child, 1, -1 do
                peopleToPrint[i] = tempParent.child[i]
            end
        end
    end

    key = ''
end



-- ####################################
--       Love2D base functions
-- ####################################
function scene.update(dt)
    deltaTime = dt
end

function scene.draw()
    local menuString = ""
    local mainString = ""
    if printStats then
        mouseScroll.x, mouseScroll.y = 0, 0
        menuString = menuString .. "T: Go back"
        mainString = "\n" .. people.PrintStats(peopleToPrint[1])        
    else
        -- Top menu
        menuString = menuString .. " | B: Main menu | T: Show stats | Y: Forward one year |"
        menuString = menuString .. "\n\n   | N: Random child | F: Father | M: Mother | C: Children | P: Partner |"

        -- Create String of all people to print
        for i = 1, #peopleToPrint do
            mainString = mainString .. "\n" .. "\n" .. "current citizen number: " .. peopleToPrint[i].index
            mainString = mainString .. "\n" .. people.PrintRelations(peopleToPrint[i])
        end
    end
    love.graphics.setColor(0.6, 0.6, 1)
    love.graphics.print(mainString, 20, 40 + mouseScroll.y)
    
    local x, y = love.window.getMode()
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, x, 50)
    love.graphics.setColor(1, 0.6, 1)
    love.graphics.print(menuString, 0, 0)

    local x, y = love.window.getMode()
    love.graphics.print(math.floor(deltaTime * 1000) * 0.001, x - 100, y - 30)
end

return scene