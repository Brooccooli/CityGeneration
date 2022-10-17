local People = require("Base.PeopleBase")
local Population = require("Base.PopulationBase")

local City = {}

local seed = 7654
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
    o.population, o.couples, o.peopleCount = Population.CreatePopulation(peopleCount, o.leader, o.seed) 

    o.population, o.peopleCount = Population.BabyMaking(o.couples, o.population, o.peopleCount, o.seed)

    function o:newYear()
        self.year = self.year + 1
        self.seed = self.seed + self.year
        local m, w = 0, 0
        for i = 1, self.peopleCount do
            self.population[i]:increaseAge()
            if self.population[i].gender == 'm' then m = m + 1 else w = w + 1 end
        end
        self.couples = Population.FindPartners(self.population, self.couples, self.seed)
        self.population, self.peopleCount = Population.BabyMaking(self.couples, self.population, self.peopleCount, self.seed)

        print("  ¤ Year: " .. self.year .. " Population: " .. self.peopleCount)
        print("               Men: " .. m .. "   Women: " .. w)
    end

    return o
end

function City.unloadPopulation(city)
    city.population = {}
    city.couples = {}
    city.peopleCount = 0
end

return City