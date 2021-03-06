--- Marcos Bottenbley
--- mbotten1@jhu.edu

--- Rebecca Bushko
--- rbushko1@jhu.edu

--- Adam Ellenbogen
--- aellenb1@jhu.edu

--- David Miller
--- dmill118@jhu.edu

Enemy = require("Enemy")
EnemyBullet = require("EnemyBullet")
math.randomseed(os.time())

local DualMaster = {
    img = "gfx/enemy_3_t.png",
    width = 60, height = 44,
    frames = 3, states = 2,
    delay = 0.12, sprites = {},
    bounding_rad = 20, type = 'd',
    fireRate = 5, timer = 5,
    goRight, thrusters = {}
}
DualMaster.__index = DualMaster

setmetatable(DualMaster, {
    __index = Enemy,
    __call = function (cls, ... )
        local self = setmetatable({}, cls)
        self:_init(...)
        return self
    end,
})

--- initializes phantom ships with random positions but consistent
--- movement speed

function DualMaster:_init()
    self.vel = math.random(70,140)
    local choice = {true, false}
    self.goRight = choice[math.random(2)]
    Enemy._init(self, self.x, self.y, self.vel, self.img, self.width, self.height, self.frames, self.states, self.delay)
    self:intitializeThrusters()
    self.thrusters = {-6,-11,-6,13}
end

function DualMaster:update(dt, swidth, sheight, px, py)
    self.timer = self.timer + dt
    Enemy.update(self, dt, swidth, sheight)

    if self.timer > self.fireRate then
        if self:shoot(px, py) then
            self.timer = 0
        end
    end

    --move/stop moving during explosion
    if not self.collided then
        if self.goRight then
            self.x = self.x + self.vel*dt
        else
            self.x = self.x - self.vel*dt
        end
    end

    --wrap around screen
    if self.x > bg_width then
        self.x = 1
    elseif self.x < 0 then
        self.x = bg_width - 1
    end

    --dualmaster shouldn't be vertically offscreen
    if self.y > bg_height or self.y < 0 then
        self.dead = true
    end
end

function DualMaster:draw()
    if self.goRight then
        Enemy.draw(self, 255, 255, 255)
    else
        Object.draw(self, 255, 255, 255, math.pi)
    end
    if not self.goRight then
        love.graphics.draw(self.particles, self.x, self.y, 0, 1, 1, self.thrusters[1], self.thrusters[2])
        love.graphics.draw(self.particles, self.x, self.y, 0, 1, 1, self.thrusters[3], self.thrusters[4])
    else
        love.graphics.draw(self.particles, self.x, self.y, math.pi, 1, 1, self.thrusters[1], self.thrusters[2])
        love.graphics.draw(self.particles, self.x, self.y, math.pi, 1, 1, self.thrusters[3], self.thrusters[4])
    end
end

function DualMaster:shoot(px, py)
    --massively hacky
    local playerInFront = false
    if (px > self.x and px < self.x + 400 and self.goRight) or
    (px < self.x and px > self.x - 400 and not self.goRight) then
        playerInFront = true
    end

    if (py < self.y + self.height and py > self.y - self.height) and
    playerInFront then
        -- local b1 = EnemyBullet(self.x + 40, self.y, 600, 0)
        -- local b2 = EnemyBullet(self.x - 40, self.y, 600, math.pi)
        if self.goRight then
            local b1 = EnemyBullet(self.x + 25, self.y + 10, 600, 0)
            local b2 = EnemyBullet(self.x + 25, self.y - 10, 600, 0)
        else
            local b1 = EnemyBullet(self.x - 25, self.y + 10, -600, 0)
            local b2 = EnemyBullet(self.x - 25, self.y - 10, -600, 0)
        end
        table.insert(objects, b1)
        table.insert(objects, b2)
        return true
    else
        return false
    end
end

function DualMaster:getType()
    return self.type
end

function DualMaster:getHitBoxes( ... )
    local hb = {}
    local hb_1 = {self.x, self.y, self.bounding_rad}
    table.insert(hb, hb_1)

    return hb
end

function DualMaster:collide(obj)
    if obj:getID() ~= 1 then
        Enemy.collide(self, obj)
    end
end

function DualMaster:intitializeThrusters()
    self.particles:setParticleLifetime(1, 1.1)
    self.particles:setEmissionRate(10)
    self.particles:setSizeVariation(1)
    self.particles:setLinearAcceleration(60, 0, 80, 0)
    self.particles:setColors(240, 240, 255, 255, 255, 0, 0, 100)
end

return DualMaster
