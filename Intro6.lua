--- Marcos Bottenbley
--- mbotten1@jhu.edu

--- Rebecca Bushko
--- rbushko1@jhu.edu

--- Adam Ellenbogen
--- aellenb1@jhu.edu

--- David Miller
--- dmill118@jhu.edu

State = require("State")

local time = 0
local changed = 0
local bgm

local Intro6 = {
    bg = nil, pos = 0,
    script_pos = 1,
    lines = {}
}
Intro6.__index = Intro6

setmetatable(Intro6, {
    __index = State,
    __call = function (cls, ...)
        local self = setmetatable({}, cls)
        self:_init(...)
        return self
    end,
})

function Intro6:load()
    self.list_font = love.graphics.newFont("PressStart2P.ttf", 17)
    text_height = (self.list_font):getHeight()
    self.bg = love.graphics.newImage("gfx/intro_screen.png")

    self.pos = -(self.bg:getHeight() - height)

    bgm = love.audio.newSource("sfx/cutscene.ogg")
    bgm:setLooping(true)
end

function Intro6:start()
    self.lines = {
        "You've escaped, but you're not yet \nfinished with your mission.",
        "Between you and your foe are \nsix deadly waves of enemies.",
        "Defeat them to make your way \nto the final sector!"
    }

    time = 0
    changed = 0
    self.pos = -(self.bg:getHeight() - height)
    self.script_pos = 1

    bgm:play()
end

function Intro6:update(dt)
    time = time + 1 * dt
    self.pos = self.pos + 50 * dt

    if self.pos >= 0 then
        self.pos = 0
    end

    if math.floor(time) % 5 == 0 and self.script_pos < table.getn(self.lines) then
        if changed ~= math.floor(time) then
            self.script_pos = self.script_pos + 1
        end
        changed = math.floor(time)
    end

    if time > table.getn(self.lines) * 5 then
        switchTo(StageIntro)
    end
end

function Intro6:keyreleased(key)
    if time > 2 then
        switchTo(StageIntro)
    end
end

function Intro6:keypressed(key)
end

function Intro6:stop()
    time = 0
    changed = 0
    self.pos = -(self.bg:getHeight() - height)
    self.script_pos = 1

    bgm:stop()
end

function Intro6:draw()
    love.graphics.setFont(self.list_font)
    love.graphics.translate(0,self.pos)
    love.graphics.setColor(50,50,255,50)
    love.graphics.draw(self.bg, 0, 0)
    love.graphics.setColor(255, 255, 255, 255)

    if time >= 2 then
        love.graphics.translate(0, -self.pos)

        love.graphics.setColor(20, 20, 20, 160)
        love.graphics.rectangle("fill", 20, height/2 + text_height * 4 - 20, 680, 180)
        love.graphics.setColor(255, 255, 255, 255)
        -- border
        love.graphics.rectangle("line", 30, height/2 + text_height * 4 - 10, 660, 160)

        love.graphics.print(self.lines[self.script_pos], 45, height/2 + text_height * 4 + 5)
    end
end

return Intro6
