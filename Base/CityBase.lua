local People = require("Base.PeopleBase")
local search = require("Tools.Search")

local City = {}

local seed = 654
local next = next



-- ############################################
--      Initilization functions + unload
-- ############################################
function City.Create(leader, peopleCount)
    local o = {}

    o.seed = seed
    o.year = 0

    o.leader = leader or People.CreateAdult(seed, 0, 0, love.math.random(35, 60))

    o.peopleCount = peopleCount or love.math.random(500, 10000)
    o.population = {}
    o.couples = {}
    o.population, o.couples, o.peopleCount = CreatePopulation(peopleCount, o.leader, o.seed) 

    o.population, o.peopleCount = BabyMaking(o.couples, o.population, o.peopleCount, o.seed)

    function o:newYear()
        self.year = self.year + 1
        self.seed = self.seed + 1
        for i = 1, self.peopleCount do
            self.population[i]:increaseAge()
        end
        self.population, self.couples = FindPartners(self.population, self.seed)
        self.population, self.peopleCount = BabyMaking(self.couples, self.population, self.peopleCount, self.seed)
        print("  ¤ Year: " .. self.year)
    end

    return o
end

function City.unloadPopulation(city)
    city.population = {}
    city.couples = {}
    city.peopleCount = 0
end

function CreatePopulation(amount, leader, currentSeed)
    local population = {}
    for i = 1, amount do
        local tempSeed = seed * love.math.noise(seed, i)
        tempSeed = math.floor(tempSeed)
        population[i] = People.CreateAdult(tempSeed)
        population[i]:setIndex(i)
    end
    population[1] = leader
    print("  -- Created base population")

    local babies = 0
    local couples = {}
    population, couples, babies = FindPartners(population, currentSeed)
    print("  -- Matched couples")

    amount = amount + babies - 1

    return population, couples, amount
end



-- ##################################################
--               Yearly functions
-- ##################################################
function FindPartners(population, currentSeed)
    local amount = #population

    -- Create children
    local babies = 0
    local couples = {}
    local probability = amount
    while true do
        if probability < amount * 0.3 then
            break
        end

        -- Find single person
        local randomIndex = math.floor(love.math.noise((currentSeed + #couples) * 2.8, (currentSeed + #couples) * 4.20) * amount)
        local indexDir = 1
        local firstParent = {}
        while true do
            if randomIndex + indexDir > amount or randomIndex + indexDir < 1 then
                indexDir = -indexDir
            end
            if population[randomIndex].partner[1] == nil and
             population[randomIndex].age >= 18 then
                firstParent = population[randomIndex]
                break
            end


            randomIndex = randomIndex + indexDir
        end

        local targetGender
        if firstParent.gender == 'm' then -- Find gender of parent
            targetGender = 'f'
        else
            targetGender = 'm'
        end

        -- Find Partner
        local itterations = 0
        while true do
            if randomIndex + indexDir > amount - 1 or randomIndex + indexDir < 1 then
                indexDir = -indexDir -- Change direction
            end
            if population[randomIndex].gender == targetGender and -- Found partner
             #population[randomIndex].partner < 1 and
             population[randomIndex].age >= 18 then
                couples[#couples + 1] = population[randomIndex]
                firstParent:addPartner(population[randomIndex])
                break
            end

            -- Break if no partners
            itterations = itterations + 1
            if itterations == amount then
                print("[Debug]No more partners, Line: " .. debug.getinfo(1).currentline .. " in CityBase.lua")
                break
            end

            randomIndex = randomIndex + indexDir
        end

        if itterations == amount then
            break
        end

        probability = probability - (1000 * (love.math.noise(currentSeed, currentSeed * 5) * 0.1))
    end


    return population, couples, babies
end

function BabyMaking(couples, population, amount, currentSeed)
    local amountOfKids = math.floor(#couples * love.math.noise(currentSeed, currentSeed))
    local currentIndex = math.floor(#couples * love.math.noise(currentSeed * 2.4, currentSeed * 4.2))

    local babies = 0

    for i = 1, amountOfKids do
        if currentIndex + 1 >= #couples - 1 then
            currentIndex = 1
        end

        if couples[currentIndex].gender == 'm' then
            population[amount + babies] = People.CreateChild(0, 0, couples[currentIndex], couples[currentIndex].partner[1], amount + babies)
        else
            population[amount + babies] = People.CreateChild(0, 0, couples[currentIndex].partner[1], couples[currentIndex], amount + babies)
        end

        babies = babies + 1
        currentIndex = currentIndex + 1
    end
    print("  -- Babies made: " .. amountOfKids)

    amount = amount + babies - 1

    return population, amount
end

return City