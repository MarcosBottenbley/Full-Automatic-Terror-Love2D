--- Marcos Bottenbley
--- mbotten1@jhu.edu

--- Rebecca Bushko
--- rbushko1@jhu.edu

--- Adam Ellenbogen
--- aellenb1@jhu.edu

--- David Miller
--- dmill118@jhu.edu


--1000x1000
--(x,y) 1000,1000
--128x128
Enemy = require("Enemy")
Winhole = require("Winhole")
math.randomseed(os.time())

local time = 0
local t_timer = 0
local lvltime = 0
local spawned = false
local destx = 0
local desty = 0
local l_timer = 0
local max_health = 69

--pos stuff
-- 0 = top middle
-- 1 = top left corner
-- 2 = left middle
-- 3 = bottom left corner
-- 4 = bottom middle
-- 5 = bottom right corner
-- 6 = right middle
-- 7 = top right corner
local MoonBoss = {
    img = "gfx/moon_boss.png",
    width = 128, height = 128,
    frames = 9, states = 2,
    delay = 0.12, sprites = {},
    bounding_rad = 64, type = 'b',
    health = 69, s_timer = 0,
    dmg_timer = 0, shoot_angle = 0,
    vel = 100, damaged = false,
    move_angle = 0, bouncing,
    b_timer, b_angle, pos = 0,
    laser = false
}
MoonBoss.__index = MoonBoss

setmetatable(MoonBoss, {
    __index = Enemy,
    __call = function (cls, ... )
        local self = setmetatable({}, cls)
        self:_init(...)
        return self
    end,
})

function MoonBoss:_init(x,y)
    Enemy._init(self, x, y, v, self.img, self.width, self.height, self.frames, self.states, self.delay)
    self.validCollisions = {2, 3, 8}

    self.beamone = BossLaser(self.x - self.width/2, self.y, "down", false)
    self.beamtwo = BossLaser(self.x + self.width/2, self.y, "down", false)
    table.insert(objects, self.beamone)
    table.insert(objects, self.beamtwo)
end

function MoonBoss:load()
    Object.load(self)
    bosshit = love.audio.newSource("sfx/bosshit.ogg")
    bosshit:setLooping(false)
end

function MoonBoss:update(dt, swidth, sheight, px, py)
    Enemy.update(self, dt, swidth, sheight)
    time = time + dt
    t_timer = t_timer + dt
    l_timer = l_timer + dt
    if self:inArena(px,py) then
        lvltime = lvltime + dt
    end

    self.s_timer = self.s_timer + dt
    if self.damaged then
        self.dmg_timer = self.dmg_timer + dt
    end

    if math.floor(time) % 5 == 0 then
            spawned = false
    end


    self:move()
    if self.health % 10 == 0 and l_timer < 10 then
        self:laserMode()
        self:updateLaser()
        if not self.laser then
            self.laser = true
        end
    else
        self.laser = false
        self:changePos()
        if l_timer >= 10 then
            self.health = self.health - 1
        end
        if self.laser then
            self.laser = false
        end
        l_timer = 0
    end

    self.beamone:setStatus(self.laser)
    self.beamtwo:setStatus(self.laser)

    if math.floor(time) % 5 == 1 and self:inArena(px,py) and not spawned and lvltime > 10 and not self.laser then
        local rand = math.random(3)
        spawned = true
        if rand == 1 then
            self:spawn4(px,py)
            self:spawn4(px,py)
        elseif rand == 2 then
            self:spawnAround(px,py)
        elseif rand == 3 then
            self:spawnCircleBorg(px,py)
        end
    end

    self:checkpos()

    if self.dmg_timer > 0.2 then
        self.damaged = false
        self.dmg_timer = 0
    end
end

function MoonBoss:inArena(px,py)
    if px > 1000 and px < 2000 then
        if py > 1000 and py < 2000 then
            return true
        end
    end
end

function MoonBoss:draw()
    self:drawHealthBar()
    if self.damaged then
        Object.draw(self,255,100,100)
    else
        Object.draw(self,255,255,255)
    end
end

function MoonBoss:drawHealthBar()
    local percent = math.floor((self.health / max_health) * 100)
    local length = (self.width * percent) /100
    if percent > 50 then
        love.graphics.setColor(0, 255, 0, 150)
    elseif percent < 50 and percent > 20 then
        love.graphics.setColor(222, 209, 37, 150)
    else
        love.graphics.setColor(255, 0, 0, 150)
    end
    love.graphics.rectangle("fill", self.x - self.width/2, self.y - 100, length , 10)
    love.graphics.setColor(255, 255, 255, 255)
end

function MoonBoss:checkpos( ... )
    if self.x == (1000 + self.width) and self.y == (1000 + self.height) then
        self.pos = 1
        t_timer = 0
    elseif self.x == (1000 + self.width) and self.y == 1500 then
        self.pos = 2
        t_timer = 0
    elseif self.x == (1000 + self.width) and self.y == (2000 - self.height) then
        self.pos = 3
        t_timer = 0
    elseif self.x == 1500 and self.y == (2000 - self.height) then
        self.pos = 4
        t_timer = 0
    elseif self.x == (2000 - self.width) and self.y == (2000 - self.height) then
        self.pos = 5
        t_timer = 0
    elseif self.x == (2000 - self.width) and self.y == 1500 then
        self.pos = 6
        t_timer = 0
    elseif self.x == (2000 - self.width) and self.y == (1000 + self.height) then
        self.pos = 7
        t_timer = 0
    elseif self.x == 1500 and self.y == (1000 + self.height) then
        self.pos = 0
        t_timer = 0
    elseif self.x == (1000 + self.width) and self.y == (1000 - self.height) then
        self.pos = 8
        t_timer = 0
    elseif self.x == (2000 - self.width) and self.y == (1000 - self.height) then
        self.pos = 9
        t_timer = 0
    end
end

function MoonBoss:changePos( ... )
    if self.pos == 7 then
        --self:move(1500, 1000 + self.height) -- 0
        destx = 1500
        desty = 1000 + self.height
    elseif self.pos == 6 then
        --self:move(2000 - self.width, 1000 + self.height) -- 7
        destx = 2000 - self.width
        desty = 1000 + self.height
    elseif self.pos == 5 then
        --self:move(2000 - self.width, 1500) -- 6
        destx = 2000 - self.width
        desty = 1500
    elseif self.pos == 4 then
        --self:move(2000 - self.width, 2000 - self.height) -- 5
        destx = 2000 - self.width
        desty = 2000 - self.height
    elseif self.pos == 3 then
        --self:move(1500, 2000 - self.height) -- 4
        destx = 1500
        desty = 2000 - self.height
    elseif self.pos == 2 then
        --self:move(1000 + self.width, 2000 - self.height) -- 3
        destx = 1000 + self.width
        desty = 2000 - self.height
    elseif self.pos == 1 then
        --self:move(1000 + self.width, 1500) -- 2
        destx = 1000 + self.width
        desty = 1500
    elseif self.pos == 0 then
        --self:move(1000 + self.width, 1000 + self.height) -- 1
        destx = 1000 + self.width
        desty = 1000 + self.height
    elseif self.pos > 7 then
        destx = 1000 + self.width
        desty = 1000 + self.height
    end
end

function MoonBoss:laserMode()
    if self.pos < 8  or self.pos == 9 then
        destx = 1000 + self.width
        desty = 1000 - self.height
    elseif self.pos == 8 then
        destx = 2000 - self.width
        desty = 1000 - self.height
    end
end

function MoonBoss:hit()
    self.health = self.health - 1
    self.damaged = true
    self.dmg_timer = 0
    bosshit:play()
end

function MoonBoss:updateLaser()
    self.beamone:setX(self.x - self.width/2)
    self.beamone:setY(self.y)

    self.beamtwo:setX(self.x + self.width/2)
    self.beamtwo:setY(self.y)
end

function MoonBoss:move()
    local factor = self:easeOutCubic(t_timer, 0, 1, 5)
    self.x = self.x + (destx - self.x) * factor

    self.y = self.y + (desty - self.y) * factor
end

function MoonBoss:easeOutCubic(t, b, c, d)
    local t1 = t / d
    t1 = t1 - 1
    return c*(t1*t1*t1 + 1) + b
end

function MoonBoss:alive()
    return self.health > 0
end

function MoonBoss:getHealth(...)
    return self.health
end

function MoonBoss:spawn4()
    local g1
    local g2
    local g3
    local g4
    if self.pos == 2 or self.pos == 6 then
        g1 = ObjectHole(self.x,self.y + 50,'g')
        g2 = ObjectHole(self.x,self.y - 50,'g')
        g3 = ObjectHole(self.x,self.y + 100,'g')
        g4 = ObjectHole(self.x,self.y - 100,'g')
    else
        g1 = ObjectHole(self.x + 50,self.y,'g')
        g2 = ObjectHole(self.x - 50,self.y,'g')
        g3 = ObjectHole(self.x + 100,self.y,'g')
        g4 = ObjectHole(self.x - 100,self.y,'g')
    end
    table.insert(objects, g1)
    table.insert(objects, g2)
    table.insert(objects, g3)
    table.insert(objects, g4)
end

function MoonBoss:spawnCircleBorg(px,py)
    local c1 = ObjectHole(px,py+150,'c')
    local c2 = ObjectHole(px,py-150,'c')
    local c3 = ObjectHole(px+150,py,'c')
    local c4 = ObjectHole(px-150,py,'c')

    table.insert(objects, c1)
    table.insert(objects, c2)
    table.insert(objects, c3)
    table.insert(objects, c4)
end

function MoonBoss:spawnAround(px, py)
    local g1 = ObjectHole(px,py+200,'g')
    local g2 = ObjectHole(px,py-200,'g')
    local g3 = ObjectHole(px+200,py,'g')
    local g4 = ObjectHole(px-200,py,'g')

    table.insert(objects, g1)
    table.insert(objects, g2)
    table.insert(objects, g3)
    table.insert(objects, g4)
end

function MoonBoss:getHitBoxes( ... )
    local hb = {}
    local hb_1 = {self.x, self.y, self.bounding_rad}
    table.insert(hb, hb_1)

    return hb
end

function MoonBoss:collide(obj)
    if obj:getID() == 3 then
        self:hit()
        if not self:alive() then
            time = 0
            Enemy.collide(self, obj)
            local gh = Winhole(self.x, self.y)
            table.insert(objects, gh)
        end
    end
end

function MoonBoss:getType( ... )
    return self.type
end

return MoonBoss
