local Person = {}

local skip = "skip"
local next = next



-- ##########################################
--        Initilization functions
-- ##########################################
function Person.CreateAdult(seed, x, y, father, mother, age, child, index)
    local o = {}

    o.pos = {}
    o.pos.x = x or 0
    o.pos.y = y or 0

    o.seed = seed or 666

    o.index = index or 1
    function o:setIndex(i)
        self.index = i
    end

    if love.math.noise(seed, seed * 8) > 0.5 then
        o.gender = 'm'
    else
        o.gender = 'f'
    end


    o.age = age or math.floor(100 - (love.math.noise(seed, seed * 3) * 82))
    o.maxLength = ((love.math.noise(o.seed, o.seed * 2.5) * 50) + 155)
    o.length = Length(o.age, o.maxLength)

    function o:increaseAge()
        self.age = self.age + 1
        self.length = Length(self.age, self.maxLength)
    end

    o = Relations(o, father, mother, child)

    o.firstName = Name(seed or 420)
    o.lastName = "fail"
    if o.father == Person.god or o.mother == Person.god then
    o.lastName =  Name(seed * 0.5 or 420)
    else
        if love.math.noise(seed * 9, seed * 3) > 0.5 then
            o.lastName = o.father.lastName
        else
            o.lastName = o.mother.lastName
        end
    end

    o.stats = Stats(o.age, seed)

    return o
end

function Person.CreateChild(x, y, father, mother, index)
    local newSeed = ((father.seed + index)) + ((mother.seed + index))
    local o = Person.CreateAdult(newSeed, x or 0, y or 0, father, mother, 0, nil, index)
    father:addChild(o, true)
    mother:addChild(o, false)
    return o
end



-- ###########################################
--          Create human functions
-- ###########################################
function Name(seed)
    local nameStart = {"Vi", "Vo", "Ba", "Am", "Gaf", "T", "Lo", "Av", "Bav", "Ge", "Bi"}
    local nameEnd = {"gi", "go", "ge", "ga", "va", "ve", "vy", "lag", "lot", "tla", "blo", "al", "olv", "oel", "fi", "fa", "fe", "imo", "afe", "eof", "ma"}

    local nameRand = math.max(1, math.floor(love.math.noise(seed, seed * 0.5) * #nameStart))
    local name = nameStart[nameRand]

    for i = 1, math.max(1, math.floor(love.math.noise(seed * 7, seed * 3) * 2)) do
        local nameRand = math.max(1, math.floor(love.math.noise(seed + (i + 52), seed + (i * -42)) * #nameEnd))
        name = name .. nameEnd[nameRand]
    end

    return name
end

function Relations(o, father, mother, child)
    o.father = father or Person.god
    o.mother = mother or Person.god
    o.siblings = {}
    function o:addSibling(sibling)
        print("Sibling count before: " .. #self.siblings)
        self.siblings[#self.siblings + 1] = sibling
        print("Sibling count after: " .. #self.siblings)
    end

    o.child = {}
    function o:addChild(child, addSiblings)
        self.child[#self.child + 1] = child
        if #self.child > 1 and addSiblings then
            for i = 1, #self.child - 1 do
                -- Add Child to siblings
                self.child[i]:addSibling(child)
                -- Add siblings to Child
                child:addSibling(self.child[i])
            end
        end
    end
    if not child == nil then
        o.addChild(child)
    end
    o.partner = {}
    function o:addPartner(partner)
        o.partner[1] = partner
        partner.partner[1] = o
    end

    return o
end

function Length(age, length)
    local newLength = length
    if age < 18 then
        if age == 0 then
            age = 1
        end
        newLength = newLength * (age / 18)
    end
    
    return math.floor(newLength)
end

function Stats(age, seed)
    local o = {}

    o.strength = 0
    o.speed = 0
    o.inteligence = 0
    o.charisma = 0
    o.stealth = 0

    -- Lua version of switch case
    local addStats = {}
    addStats[1] = function () o.strength = o.strength + 1 end
    addStats[2] = function () o.speed = o.speed + 1 end
    addStats[3] = function () o.inteligence = o.inteligence + 1 end
    addStats[4] = function () o.charisma = o.charisma + 1 end
    addStats[5] = function () o.stealth = o.stealth + 1 end

    for i = 1, age do
        local whichStat = math.floor(math.max(1, (love.math.noise(seed, i * 8) * (#addStats + 1))))
        addStats[whichStat]()
    end

    return o
end



-- ###########################################
--             Print functions
-- ###########################################
function Person.PrintRelations(person)
    local string = ("Name: " .. person.firstName .. " " .. person.lastName ..
        "\n Gender: " .. person.gender ..
        "\n Age: " .. person.age .. 
        "\n Length: " .. person.length .. 
        "\n  Father: " .. person.father.firstName .. " " .. person.father.lastName .. 
        "\n  Mother: " .. person.mother.firstName .. " " .. person.mother.lastName)
    
    if #person.partner > 0 then
        string = string .. "\n Partner: " .. person.partner[1].firstName .. " " .. person.partner[1].lastName
    end

    if #person.child > 0 then
        string = string .. "\n"
        for i = 1, #person.child do
            string = string .. "\n" .. "  Child: " .. person.child[i].firstName .. " " .. person.child[i].lastName
        end
    end

    if #person.siblings > 0 then
        string = string .. "\n"
        for i = 1, #person.siblings do
            string = string .. "\n" .. "  Sibling: " .. person.siblings[i].firstName .. " " .. person.siblings[i].lastName
        end
    end

    return string
end

function Person.PrintStats(person)
    local string = "Name: " .. person.firstName .. " " .. person.lastName ..
        "\n\n" .. "  Strength: " .. person.stats.strength ..
        "\n" .. "  Speed: " .. person.stats.speed ..
        "\n" .. "  Inteligence: " .. person.stats.inteligence ..
        "\n" .. "  Charisma: " .. person.stats.charisma ..
        "\n" .. "  Stealth: " .. person.stats.stealth

    return string
end

Person.god = Person.CreateAdult(420, 0, 0, skip, skip, 1000)
Person.god:setIndex(-1)
Person.god.firstName = "Heavenly"
Person.god.lastName = "God"

return Person