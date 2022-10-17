local Population = {}
local People = require("Base.PeopleBase")

function Population.CreatePopulation(amount, leader, currentSeed)
    local population = {}
    for i = 1, amount do
        local tempSeed = currentSeed * love.math.noise(currentSeed, i)
        tempSeed = math.floor(tempSeed)
        population[i] = People.CreateAdult(tempSeed)
        population[i]:setIndex(i)
    end
    population[1] = leader
    print("  -- Created base population")

    local babies = 0
    local couples = {}
    couples, babies = Population.FindPartners(population, couples, currentSeed)
    print("  -- Matched couples")

    amount = amount + babies - 1

    return population, couples, amount
end

-- Goes through population and finds singles and matches them
function Population.FindPartners(population, oldCouples, currentSeed)
    local amount = #population

    -- Create children
    local babies = 0
    local couples = oldCouples
    local probability = amount
    while true do
        if probability < amount * 0.3 then
            break
        end

        -- Find single person 
        -- why is it multiplied by #couples younger Alvin? 
        -- Answer: To add more difference between years
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
                print("[Debug] No more partners, Line: " .. debug.getinfo(1).currentline .. " in CityBase.lua")
                break
            end

            randomIndex = randomIndex + indexDir
        end

        if itterations == amount then
            break
        end

        probability = probability - (1000 * (love.math.noise(currentSeed, currentSeed * 5) * 0.1))
    end


    return couples, babies
end

-- Gets amount of kids that can be born from the seed and then creates as many as possible
-- One couple can't have several babies per year and they can't have more than 3
function Population.BabyMaking(couples, population, amount, currentSeed)
    local amountOfKids = math.floor(#couples * love.math.noise(currentSeed *1.345, currentSeed * 1.345))
    local currentIndex = math.max(math.floor(#couples * love.math.noise(currentSeed * 2.4, currentSeed * 4.2)), 1)

    print("[DEBUG] chance: " .. love.math.noise(currentSeed * 1.345, currentSeed * 1.345) .. " Seed: " .. currentSeed * 1.345 .. ", Line: " .. debug.getinfo(1).currentline .. " in CityBase.lua")

    local babies = 1

    for i = 1, amountOfKids do
        if currentIndex + 1 >= #couples - 1 then
            currentIndex = 1
        end

        if #couples[currentIndex].child > 2 then goto nextCycle end

        if couples[currentIndex].gender == 'm' then
            population[amount + babies] = People.CreateChild(0, 0, couples[currentIndex], couples[currentIndex].partner[1], amount + babies)
        else
            population[amount + babies] = People.CreateChild(0, 0, couples[currentIndex].partner[1], couples[currentIndex], amount + babies)
        end

        babies = babies + 1
        currentIndex = currentIndex + 1

        ::nextCycle::
    end
    print("  -- Babies made: " .. babies)

    if babies > 1 then
        amount = amount + babies - 1
    end

    return population, amount
end

return Population